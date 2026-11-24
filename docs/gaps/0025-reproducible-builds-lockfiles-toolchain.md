# 0025 — Reproducible builds: untracked lockfiles, no toolchain pin, no Python lockfiles

**Status**: open
**Filed**: 2026-11-23 — workspace design review (root plan 0021) · **Kind**: deployment · **Severity**: high
**Plan**: [0023](../plans/0023-build-ci-release-engineering.md)

## What's stubbed or hardcoded

- `Cargo.lock` is untracked in 8 of 9 Rust workspaces (agent, core, exec, ledger, market, risk, runtime, ui); only
  `tantra-ffi` tracks it. Each workspace resolves independently, so patch versions of tokio, axum, reqwest and
  rustls drift silently.
- No `rust-toolchain(.toml)` anywhere. CI uses floating `stable`; docs mention 1.97.1; `tantra-core/Cargo.toml:5`
  only has `rust-version = "1.85"`.
- All dependencies are loose ranges (`tokio = "1"`, `reqwest = "0.12"`, `sha2 = "0.10"`).
- Python: root `Makefile` `prepare` runs `pip install maturin pytest ruff mypy hypothesis pyarrow pydantic polars duckdb httpx`
  with no versions; no `uv.lock`/poetry lock; only `tantra-docs` has requirements files; CI tests Python 3.12 only while
  `requires-python` is `>=3.10` (ffi) and `>=3.11` (adapters).
- `tantra-ffi/.cargo/config.toml:11` hardcodes `PYO3_PYTHON = "/usr/bin/python3"`.
- `tantra-ui-web`: no `engines`, `.nvmrc` or `.npmrc`.

| Repo tracker / evidence | Severity | What it covers |
|---|---|---|
| [strategies 0017](../../tantra-strategies/docs/gaps/0017-dependency-pins-and-wheel-contract.md) | medium | Unpinned `tantra`, unversioned `tantra-data`, no lock |
| `.gitignore` in each Rust repo | n/a | `Cargo.lock` ignored |
| `Makefile` (root) `prepare` | n/a | Unpinned tool install |

## Why

- `tantra-runtime`, `tantra-exec`, `tantra-ui` and `tantra-agent` produce deployed binaries; two builds a day
  apart can differ, a yanked crate cannot be audited, and a rollback cannot be rebuilt bit for bit.
- "Which code ran on date X" (audit evidence) is unanswerable without a lock and toolchain per release.
- Lint results differ per day when ruff/mypy float; Python lower bounds are never tested.

## How to close it

1. Each Rust repo: remove `Cargo.lock` from `.gitignore`, commit it; CI builds with `--locked`.
2. Add `rust-toolchain.toml` (pinned channel, rustfmt, clippy, wasm32 target) per repo and at root; CI reads it
   instead of floating `stable`.
3. Python: a root `uv` workspace with `uv.lock`, tools pinned in a dependency group; `requirements.lock` for docs;
   CI matrix 3.10/3.12/3.13 for ffi and 3.11/3.12 for the rest; `uv sync --locked`.
4. `tantra-ui-web`: add `engines`, `.nvmrc`, commit `package-lock.json` policy (`npm ci` only).
5. Root release record lists lockfile hashes and exact submodule SHAs (see plan 0023 release sketch).
6. Remove the hardcoded `PYO3_PYTHON` or override it in CI and document it.

**Verification**: CI fails if a lockfile is dirty after build; `cargo build --locked` and `uv sync --locked` are
required steps; a clean checkout builds twice to the same artifact hash on the same runner image.

## Related

- Root plan 0019 P1.7 aligns versions only (sha2, getrandom, tokio-tungstenite, proptest, bytes), not locks or toolchain.
- [0024](0024-no-ci-for-rust-repos.md), [0029](0029-generated-artifact-drift.md).
