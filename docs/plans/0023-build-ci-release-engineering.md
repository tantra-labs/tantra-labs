# 0023 — Build, CI and release engineering

**Status**: Proposed (2026-11-23)
**Scope**: workspace root (cross-repo) · **Umbrella**: [0021](0021-workspace-design-review-2026-11.md) · **Sibling**: [0022](0022-future-deployment-architecture.md)

## 0. Executive Summary & Objective

The workspace is nine Cargo workspaces glued by `path = "../x"` dependencies, with nine independent target dirs (about 49 GB), eight untracked `Cargo.lock` files, no pinned toolchain, no Python lockfile, no tags, no licence files and no release pipeline. Seven Rust repos holding the safety-critical code (core, ledger, risk, market, exec, runtime, agent) have no CI at all, and the eight existing pipelines cannot resolve their sibling path dependencies.

This plan makes builds reproducible, gives every repo a CI that actually builds against the right sibling SHAs, adds drift gates for generated artifacts, defines a release pipeline (binaries, wheels, images, SBOM, signing, docs) and settles licence files and attribution. Non-goals: version alignment of `sha2`/`getrandom`/`tokio-tungstenite`/`proptest`/`bytes` (0019 P1.7) and the content of `make verify-architecture` (0019 P4.6); this plan supplies the runner and the lockfiles those depend on.

## 1. Context & Gaps Covered

### 1.1 Inventory

| Area | State |
|---|---|
| CI | `.github/workflows/ci.yml` only in adapters, data, docs, examples, ffi, strategies, ui, ui-web; none in core/ledger/risk/market/exec/runtime/agent; root `.github/workflows/` empty |
| Sibling checkout | ffi uses bare `actions/checkout@v4` against `path = "../tantra-core"` (`tantra-ffi/Cargo.toml:18`); ui uses `submodules: recursive` but its path deps are siblings, not submodules; `.gitmodules` URLs are `git@github.com-dev:...` (SSH alias) |
| Python CI | `pip install tantra>=0.1.0`, which is published nowhere; unpinned ruff/mypy/pytest; Python 3.12 only while `requires-python` is `>=3.10` (ffi) and `>=3.11` (adapters) |
| Lockfiles | `Cargo.lock` untracked in 8 of 9 Rust workspaces (only `tantra-ffi` tracks it); no `uv.lock`; only `tantra-docs` has requirements files |
| Toolchain | no `rust-toolchain(.toml)`; CI uses floating `stable`; docs say 1.97.1; `rust-version = "1.85"` in core only |
| Profiles | root `.cargo/config.toml` sets `[profile.dev]` and `[profile.test]` to opt-level 3 + thin LTO + codegen-units 1; dead/contradicting aliases (`test`, `t` using `release`); no CI job runs `make prod` or `--profile prod` |
| Target dirs | 9 independent dirs, ~49 GB; root `make test`/`check` recompile shared deps 9 times; the runtime-api test link can OOM at 15 GiB |
| Makefiles | 8 identical Rust copies; ui-web has none; `make test` skips Python/web; root loop does not fail on early repo errors |
| Licences | no LICENSE file in any repo; Rust + wheel declare AGPL-3.0, adapters/data/examples/strategies declare MIT, docs and ui-web declare none |
| Versions/tags | all `0.1.0`, zero git tags, no CHANGELOG, no Dockerfile/cargo-dist/SBOM |
| Hygiene tools | no `deny.toml`, dependabot/renovate, `.pre-commit-config.yaml` anywhere |
| Generated artifacts | `domain_schema.json` committed twice and already differing (`tantra-core/schema/domain/` vs `tantra-ffi/schema/`); two OpenAPI copies (`openapi.v2.json` in runtime, `openapi.json` in ffi); `.pyi` stubs; `api-schema.d.ts` (`check:api-contract` not run in CI); the same `.wasm` committed three times in ui-web |

### 1.2 Gaps covered

| Gap | Title |
|---|---|
| [root 0024](../gaps/0024-no-ci-for-rust-repos.md) | No CI for Rust repos |
| [root 0025](../gaps/0025-reproducible-builds-lockfiles-toolchain.md) | Reproducible builds: lockfiles and toolchain |
| [root 0026](../gaps/0026-licensing-files-and-attribution.md) | Licensing files and attribution |
| [root 0029](../gaps/0029-generated-artifact-drift.md) | Generated-artifact drift |
| core 0004 (closed `tantra-core` `7926c59`) | Wire-schema evolution gate |
| [risk 0015](../../tantra-risk/docs/gaps/0015-latency-sla-ci-gate.md) | Latency SLA CI gate |
| [ffi 0004](../../tantra-ffi/docs/gaps/0004-stub-and-codegen-drift-gate.md) | Stub and codegen drift gate |
| [ffi 0005](../../tantra-ffi/docs/gaps/0005-wheel-release-matrix.md) | Wheel release matrix |
| [ui-web 0084](../../tantra-ui-web/docs/gaps/0084-ci-gate-coverage.md) | CI gate coverage |
| [examples 0009](../../tantra-examples/docs/gaps/0009-ci-installs-wheel-and-siblings.md) | CI installs wheel and siblings |
| [docs 0001](../../tantra-docs/docs/gaps/0001-publish-and-versioning.md) | Publish and versioning |
| [strategies 0016](../../tantra-strategies/docs/gaps/0016-package-data-and-py-typed.md) | Package data and `py.typed` |
| [strategies 0017](../../tantra-strategies/docs/gaps/0017-dependency-pins-and-wheel-contract.md) | Dependency pins and wheel contract |

Plan-only items (no standalone gap doc):

- R1 — Makefile boilerplate x8: shared `mk/rust.mk` and `mk/python.mk`, uniform `fmt lint check test prod audit verify`, a thin ui-web Makefile, loops that fail on the first broken repo.
- R2 — Python environment: a `uv` workspace with `uv.lock`, dev tools pinned in a dependency group, CI matrix 3.10/3.12/3.13 for ffi and 3.11/3.12 for the rest.
- R3 — Submodule wiring: HTTPS URLs, `tantra-ui-web` added as a submodule (currently gitignored at the root), `scripts/bootstrap.sh`, bump-bot PRs per submodule update.
- R4 — Declaration style inside workspaces (`workspace = true`, duplicate `proptest`/`bytes`, `sqlx` without runtime feature, single `thiserror` 2 migration); tracked with 0019 P1.7.
- R5 — CI must run `make prod` and `--profile prod` (build-discipline), with an MSRV 1.85 job for core/ledger/risk.

## 2. Component Specifications & Phases

### Multi-repo build options

| Option | What it does | Pros | Cons / required change |
|---|---|---|---|
| A. Shared `CARGO_TARGET_DIR` + sccache | `[build] target-dir` or env, `RUSTC_WRAPPER=sccache` (remote backend in CI) | No layout change; removes most of the 49 GB and the 9x recompile of shared deps | Differing features/profiles still rebuild; cargo locks the dir (serial builds); lockfiles still diverge; does not fix versioning or CI path deps |
| B. Root superworkspace | One root `Cargo.toml` with all members, one lock, one target | Single resolve; cargo enforces version alignment; DAG checkable via `cargo metadata` | Cargo forbids nested workspaces, so 9 repos lose their `[workspace]` tables and stop building standalone; children's `[profile.*]` ignored; ffi (PyO3) and wasm crates break `--workspace` without excludes |
| C. Private registry + semver | Publish each tier crate from its repo CI; consumers pin versions | Independent cadence; upward edges impossible | Registry to operate (kellnr), ~100 crates to publish, no path-only deps, coordinated breaking changes; heavy for a single-developer non-commercial project |
| D. Pinned superproject SHAs in CI (+ A) | Root commit is the bundle of record; CI checks out root with submodules at that SHA over HTTPS; bump bot runs the full matrix | Zero code change; matches current layout; "this SHA set was tested" provenance; fixes the sibling-checkout failure | 9 resolves (mitigated by committed locks); cross-repo atomic changes need coordinated PRs; no independent crate versioning |

**Recommendation: D + A now.** Commit lockfiles and the toolchain pin, run a reusable root CI workflow against pinned superproject SHAs, share the target dir with sccache. A CI-only "verification workspace" generated by `make verify-architecture` (0019 P4.6) runs `cargo metadata`/`cargo deny` across all 9 and merges results, giving B's alignment checks without nesting. Revisit C only if external contributors or a hosted SDK appear; B is not recommended unless standalone per-repo builds are abandoned.

### Phase B0 — CI exists and builds (root gaps 0024, 0025)

1. Reusable workflow at root (`workflow_call`, input `repo`) that checks out the superproject at a pinned SHA with `submodules: recursive` over HTTPS and a deploy token, then runs `make -C <repo> check test`.
2. Thin `ci.yml` in each of the 7 Rust repos without CI; fix ffi/ui/ui-web to use the reusable workflow instead of bare checkouts (R3).
3. Track `Cargo.lock` everywhere (remove from `.gitignore`); add `rust-toolchain.toml` pinned to 1.97.1 (rustfmt, clippy, `wasm32-unknown-unknown`) at each repo and the root; CI reads it and builds with `--locked`.
4. Python: `uv.lock` for the shared venv and a pinned lock for docs (R2); Python jobs build the wheel first (`maturin build`) and install it, so `tantra>=0.1.0` resolves ([examples 0009](../../tantra-examples/docs/gaps/0009-ci-installs-wheel-and-siblings.md)).

**Gate**: a no-op PR in every repo goes green and all checks are required; `cargo build --locked` fails on a dirty lock; `cargo fmt --check`, `cargo clippy --all-targets -- -D warnings`, `make check`, `make prod`.

### Phase B1 — Cost and supply-chain hygiene (root gap 0025, R1, R4, R5)

1. Move LTO to `prod` only; `dev`/`test` get `opt-level=1, lto=false, debug=1`; delete dead aliases; set the shared `target-dir` and `RUSTC_WRAPPER=sccache`; add an lld/mold linker config and a documented low-memory test recipe.
2. Root `deny.toml` (advisories, licences, duplicate-version bans, sources crates.io only) used by every repo; `cargo audit`, `pip-audit`, `npm audit --omit=dev` jobs; Dependabot or Renovate (cargo, pip, npm, github-actions) with grouped updates; `pre-commit` with fmt, ruff, clippy-fast and the `#[cfg(test)]` hygiene check.
3. Shared `mk/*.mk` includes (R1); root `make verify` aggregates per-repo verification and fails fast.
4. Add the MSRV 1.85 job and `--profile prod` verification (R5); risk latency gate per [risk 0015](../../tantra-risk/docs/gaps/0015-latency-sla-ci-gate.md).

**Gate**: `cargo test -p tantra-runtime-api-rest --no-run` inside a 7 GB runner; a seeded vulnerable crate on a throwaway branch fails `cargo deny`; `make check`, `make prod`.

### Phase B2 — Drift gates (root gap 0029, ffi 0004, ui-web 0084, core 0004)

1. `make verify-generated`: regenerate and `git diff --exit-code` for `tantra-core/schema/domain/domain_schema.json` (single source; the ffi copy is generated or dropped), `openapi.v2.json` (runtime dump, ffi copy dropped or generated), `_tantra.pyi`/`__init__.pyi`, `api-schema.d.ts` (`codegen:api --check`, wired into CI), and the ui-web `.wasm`.
2. Stop committing three copies of the `.wasm`: build in CI and ship via release artifact, or keep one canonical copy with a hash check.
3. `cargo check --target wasm32-unknown-unknown --profile prod` for core, indicators, ledger-portfolio, ui-core, run through `make verify-architecture` (0019 P4.6).
4. Each consumer carries a golden test `schema hash == pinned hash`; wire corpora per released version (core 0004, closed: `tantra-core/schema/golden/v{N}/`).

**Gate**: CI fails when any generated artifact is stale; `npx tsc --noEmit`, `npm run lint`, `npx vitest run`; `ruff check .`, `ruff format --check .`, `mypy --strict`, `pytest -q`.

### Phase B3 — Release pipeline (ffi 0005, docs 0001, strategies 0016/0017)

- **Versioning**: lockstep release train at the superproject (`vX.Y.Z` tag on root, same tag on each submodule); wire contracts (`/api/v2`, domain schema) versioned independently and recorded in a git-cliff CHANGELOG; conventional commits enforced by hook. Inter-repo Rust crates stay path-linked inside a release.
- **Trigger**: tag on root runs `release.yml` against pinned submodule SHAs and `make verify` (fmt, clippy, `make prod`, tests, drift gates, cargo-deny/pip-audit/npm audit).
- **Binaries**: cargo-dist (`dist-workspace.toml`) for the `tantra` CLI/TUI and server on x86_64/aarch64 Linux and macOS, with shell installer and checksums.
- **Wheels**: maturin-action or cibuildwheel for the `tantra` wheel, `manylinux_2_28`, x86_64 + aarch64 plus sdist; install-and-test in a clean venv; publish via trusted publishing (PyPI or private index). Decision to record here: keep abi3-py310 (one wheel per platform) versus per-version wheels for free-threaded builds; default is abi3-py310 and a separate free-threaded build only if a measured need appears. Downstream pins follow [strategies 0017](../../tantra-strategies/docs/gaps/0017-dependency-pins-and-wheel-contract.md) and package data per [strategies 0016](../../tantra-strategies/docs/gaps/0016-package-data-and-py-typed.md).
- **Containers**: multi-stage Dockerfiles from plan [0022](0022-future-deployment-architecture.md) D1 (distroless, non-root, WASM built in the image), pushed to GHCR with provenance.
- **Supply chain**: CycloneDX SBOMs (`cargo cyclonedx`, `cyclonedx-py`, `@cyclonedx/cyclonedx-npm`) on each release; `actions/attest-build-provenance` for binaries, wheels and images; cosign keyless signing for images and sigstore for wheels; release notes list lockfile hashes and exact submodule SHAs ("which code ran on date X").
- **Docs**: `mkdocs build --strict` on tag, published versioned with `mike` ([docs 0001](../../tantra-docs/docs/gaps/0001-publish-and-versioning.md)).
- **Retention**: release artifacts and SBOMs kept for the audit horizon, mirrored to object storage.

**Gate**: a dry-run tag on a fork produces all artifacts; the installed wheel passes `pytest -q python/tests`; SBOM and attestation verify; `make prod`.

### Phase B4 — Licences and attribution (root gap 0026)

1. Add a LICENSE file and SPDX identifiers (`license-files`, Cargo `license`, `package.json` `license`) to every repo; pick one outbound licence per artifact class and label it consistently (Rust crates and wheel are AGPL-3.0 today; the MIT-declared Python packages that import the wheel must be reconciled).
2. `THIRD_PARTY_NOTICES.md` and a root `NOTICE` for third-party components. Framing: this is a non-commercial project, so non-commercial third-party licences (for example CC BY-NC-SA indicator ideas) are acceptable with attribution; the work is accurate labelling and attribution, not avoidance. Keep such components identifiable (a clearly labelled package or module) so the labelling stays truthful.
3. `cargo-deny` licence allow-list and `pip-licenses`/`license-checker` in CI with the non-commercial allowances explicit.

**Gate**: CI fails on a dependency licence outside the allow-list; every repo has a LICENSE file; `make check`.

## 3. Relationship to Other Plans

- 0019 P1.7 (dependency version alignment) and P4.6 (`make verify-architecture`): not duplicated; B0/B2 give them a runner and lockfiles. 0019 P0 (`.gitmodules` for ui-web) overlaps R3.
- Plan [0022](0022-future-deployment-architecture.md): D1 images, D3 health smoke tests and D5 wasm32 targets are built and verified by B1–B3.
- Root gaps [0024](../gaps/0024-no-ci-for-rust-repos.md), [0025](../gaps/0025-reproducible-builds-lockfiles-toolchain.md), [0026](../gaps/0026-licensing-files-and-attribution.md), [0029](../gaps/0029-generated-artifact-drift.md) are the trackers; per-repo gaps in section 1.2 own repo-local work.
- Umbrella: [0021](0021-workspace-design-review-2026-11.md).

## 4. Exit Criteria

1. All 9 Rust workspaces track `Cargo.lock` and a pinned `rust-toolchain.toml`; CI builds with `--locked`.
2. Every repo has a green CI that checks out sibling repos at pinned superproject SHAs over HTTPS and runs `make check` and `make prod`.
3. Shared target dir plus sccache is in place; dev/test profiles no longer use LTO; the runtime-api test binary links on a 7 GB runner.
4. `cargo deny`, `pip-audit`, `npm audit` and Dependabot/Renovate run on every repo.
5. `make verify-generated` is a required check; one domain schema, one OpenAPI document, one WASM source of truth.
6. A root tag produces binaries, an installable `tantra` wheel, container images, SBOMs, signatures and provenance, plus versioned docs.
7. Every repo carries a LICENSE file, SPDX metadata and attribution notices consistent with the non-commercial framing.
