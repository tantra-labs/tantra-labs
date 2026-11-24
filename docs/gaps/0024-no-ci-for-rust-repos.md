# 0024 — No CI for the seven Rust repos; existing pipelines cannot resolve sibling path dependencies

**Status**: open
**Filed**: 2026-11-23 — workspace design review (root plan 0021) · **Kind**: deployment · **Severity**: critical
**Plan**: [0023](../plans/0023-build-ci-release-engineering.md)

## What's stubbed or hardcoded

The code that routes orders and gates risk has no automated verification anywhere but a developer machine.

- `.github/workflows/ci.yml` exists only in adapters, data, docs, examples, ffi, strategies, ui and ui-web.
  `tantra-core`, `tantra-ledger`, `tantra-risk`, `tantra-market`, `tantra-exec`, `tantra-runtime` and `tantra-agent`
  have none; root `.github/workflows/` is empty.
- `tantra-ffi/.github/workflows/ci.yml:13` uses a bare `actions/checkout@v4`, but `tantra-ffi/Cargo.toml:18` has
  `tantra-core = { path = "../tantra-core" }`, so the job cannot compile in a standalone checkout.
- `tantra-ui/.github/workflows/ci.yml:15` uses `submodules: recursive`, which fetches ui's own submodules, but
  ui path-depends on sibling repos `../tantra-core`, `../tantra-exec/...`, `../tantra-agent/...`.
- `.gitmodules` URLs use an SSH host alias (`git@github.com-dev:tantra-labs/...`), unusable on GitHub Actions runners.
- Python repos `pip install` `tantra>=0.1.0`, which is published nowhere.
- Existing Rust CI uses floating `dtolnay/rust-toolchain@stable` and never `--profile prod` (`tantra-ffi/.github/workflows/ci.yml:31`).

| Repo tracker / evidence | Severity | What it covers |
|---|---|---|
| [risk 0015](../../tantra-risk/docs/gaps/0015-latency-sla-ci-gate.md) | medium | Latency SLA not verified in CI |
| [examples 0009](../../tantra-examples/docs/gaps/0009-ci-installs-wheel-and-siblings.md) | high | CI installs neither wheel nor siblings |
| `tantra-agent/crates/tantra-agent-chat/tests/dependency_rules.rs` | n/a | Tier rules R1-R4 only run locally |
| `.gitmodules` | n/a | SSH alias URLs, 14 submodules uninitialised on fresh clone, ui-web not a submodule |

## Why

- Binding rules (parallel tests dir, clippy `-D warnings`, `dependency_rules.rs`, DAG checks) are unenforced; a
  regression in the order or risk path lands unnoticed.
- The ffi and ui pipelines are very likely red on any real push, so "has CI" gives false confidence.
- `.agents/rules/build-discipline.md` makes `prod` canonical, yet the artifact is never built in CI (the LTO
  link-OOM class is invisible until a release).

## How to close it

1. Root: add a reusable workflow (`workflow_call`, input `repo`) that checks out the superproject at a pinned SHA
   with `submodules: recursive` over HTTPS and a deploy token, then runs `make -C <repo> check test`.
2. Change `.gitmodules` URLs to HTTPS (keep the SSH alias locally via `url.insteadOf`); add `tantra-ui-web` as a
   submodule; add `scripts/bootstrap.sh` (`git submodule update --init --recursive`).
3. Each of the seven Rust repos gets a thin `ci.yml` calling the reusable workflow; fix ffi/ui to use it.
4. Pin the toolchain per [0025](0025-reproducible-builds-lockfiles-toolchain.md) and run `make check` and
   `make prod` (sccache) for binary repos; MSRV job at 1.85 for core, ledger and risk.
5. Python jobs build the wheel (`maturin build`) first and install it before testing adapters, strategies, examples.
6. Add the risk latency gate and `dependency_rules.rs` as required checks.

**Verification**: push a no-op PR and require every check; a deliberately broken clippy or `#[cfg(test)]`
in `src/` must fail the job; runtime test-bin link must complete on a 7 GB runner (or use the documented
targeted-binary fallback).

## Related

- Root plan 0019 P4.6 (`make verify-architecture`) provides the gate content; this gap provides the runner.
- [0025](0025-reproducible-builds-lockfiles-toolchain.md), [0029](0029-generated-artifact-drift.md).
