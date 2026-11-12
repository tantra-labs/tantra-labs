# 0004 — Rename the entire platform from `Vyapaar`/`vyapaar` to `Tantra`/`tantra`

**Status**: Proposed

## 0. Executive Summary & Objective

Rename every occurrence of the platform name from `VYAPAAR` / `Vyapaar` / `vyapaar` to
`TANTRA` / `Tantra` / `tantra` across the whole `vyapaar-labs` workspace. This covers:

- the GitHub organization (`vyapaar-labs` → `tantra-labs`) and every repository name;
- every checked-out submodule path and `.gitmodules` entry;
- every Rust crate directory, package `name`, lib name, bin name, and `vyapaar_*::` path;
- every Python distribution/package name (`vyapaar` wheel, `vyapaar-strategies`, etc.),
  `import vyapaar` / `from vyapaar import` sites, and the PyO3 module name;
- every Markdown doc, `docs/{design,gaps,plans}`, `AGENTS.md`, `HANDOFF.md` reference;
- every `Makefile` target/repo list, CI workflow, script (`create-remote-repos.sh`),
  `opencode.jsonc`, README, and cross-repo citation comment.

The rename is **purely nominal**: no behavior, wire format, or API semantics change. It must
be executed in a deterministic, verifiable order (bottom-up by dependency depth) so that every
intermediate step still compiles and tests green.

## 1. Context & Scope

### 1.1 Verified inventory (2026-11-12, direct inspection)

| Category | Count | Notes |
|:---|:---|:---|
| GitHub submodules in `.gitmodules` | 14 | `vyapaar-{core,ledger,risk,market,exec,runtime,agent,ffi,ui,strategies,adapters,data,examples,docs}` |
| Additional GitHub repos | 1 | `.github` (org health files; currently has **no commits on `main`** — push fails `refs/heads/main does not match any`) |
| Referenced-but-not-checked-out repos | 2 | `vyapaar-fe`, `vyapaar-ui-web` (appear in `scripts/create-remote-repos.sh` and `docs/plans/README.md` tables) |
| Rust crate directories | 70 | `crates/vyapaar-*` across 9 workspaces |
| `Cargo.toml` `name = "vyapaar-*"` entries | 74 | includes extra bin names: `vyapaar-audit-export` (exec-audit), `vyapaar-codegen` (ffi-codegen) |
| Python distributions | 5 | `vyapaar` (FFI wheel), `vyapaar-{examples,strategies,data,adapters}` |
| Python import sites | ~499 files | `import vyapaar` / `from vyapaar ... import ...` |
| Files containing `vyapaar` | ~1,700 | 686 `.rs`, 514 `.py`, 381 `.md`, 97 `.toml`, 10 `.json`, 3 `.sh`, 2 `.pyi`, 1 `.yml`, plus Makefiles/`css`/`lock` |
| Total case-insensitive occurrences | ~14,459 | `rg -i 'vyapaar'` excluding `target/`, `.git/`, `node_modules/`, `.venv/` |
| Organization name | 1 | `vyapaar-labs` (scripts, `.gitmodules`, docs, `Makefile` comments) |

### 1.2 Case-variant mapping (exact, order-independent)

| From | To |
|:---|:---|
| `VYAPAAR` | `TANTRA` |
| `Vyapaar` | `Tantra` |
| `vyapaar` | `tantra` |

No other name strings (`honba`, `fincept`, `quantcept`) are in scope for this rename.

### 1.3 Gaps covered

This plan collects the rename as a single workspace-wide architectural change; per
`.agents/rules/gap-tracking.md` it is filed in the root provider repo (`vyapaar-labs`) because
it spans every bounded context. Individual repos do **not** get their own gap docs for the
rename — the root plan is the single source of truth and its completion (verified per-phase)
will be recorded in `docs/plans/README.md` and each repo's `.agents/HANDOFF.md`.

## 2. Phased Execution Plan

Execution is **bottom-up by dependency depth** so each layer stays buildable and test-green:

### Phase 0 — Freeze & baseline (root)

1. Verify all working trees clean; snapshot `git submodule status`.
2. Baseline gate per Rust workspace: `make check` / `make prod` (canonical `prod` profile only —
   never bare `cargo build`/`cargo test`, per `.agents/rules/build-discipline.md`); Python:
   `pytest -q`, `ruff check .`.
3. Confirm the `.github` repo state: it has no commits on `main`; decide whether to initialize a
   first commit **before** renaming (so the org rename doesn't strand an empty repo) or rename it
   first. Default: leave `.github` untouched this round unless a commit is needed.

**Deliverable**: baseline gate log recorded in the root `HANDOFF.md`; all trees clean.

### Phase 1 — Rust crates (bottom-up, one workspace at a time)

Order by dependency depth: `vyapaar-core` → `vyapaar-ledger` → `vyapaar-risk` →
`vyapaar-market` → `vyapaar-exec` → `vyapaar-runtime` → `vyapaar-agent` → `vyapaar-ffi` →
`vyapaar-ui`. Per workspace:

1. Rename **crate directories** `crates/vyapaar-*` → `crates/tantra-*` (`git mv`).
2. Rename **`Cargo.toml`** package/lib/bin names (`name = "vyapaar-*"` → `"tantra-*"`,
   `[[bin]] name`, extra bins `vyapaar-audit-export`/`vyapaar-codegen`).
3. Rewrite **`vyapaar_*::`** → `tantra_*::` path references in every `use`/`extern crate`/
   `path = "crates/vyapaar-*"` workspace member entry, plus any `[workspace.dependencies]`
   keys.
4. Rename **binary target names** used by scripts/CI/`Makefile` (e.g. `vyapaar-cli`, `vyapaar-tui`).
5. Rewrite **doc comments / `//!` crate docs** mentioning the name.
6. Update this repo's `docs/`, `AGENTS.md`, `.agents/HANDOFF.md`, and `.github/workflows/ci.yml`.
7. Gate: `make check` → `make test` (or `make prod` for end-of-turn) green; zero
   `vyapaar` occurrences in `crates/*/src` and `crates/*/Cargo.toml`.
8. Commit per-workspace: `refactor(<repo>): rename vyapaar-* crates to tantra-*`.

### Phase 2 — Python packages (bottom-up: `vyapaar-ffi` first, then consumers)

1. `vyapaar-ffi`: PyPI distribution `name = "vyapaar"` → `"tantra"`; `[tool.maturin]`
   `module-name = "vyapaar._vyapaar"` → `"tantra._tantra"`; rename `python/vyapaar` →
   `python/tantra`; regenerate stubs (`make codegen`); rebuild wheel (`maturin develop`);
   `pytest -q`.
2. Consumers: `vyapaar-strategies`, `vyapaar-examples`, `vyapaar-data`, `vyapaar-adapters` —
   rename package dirs (`vyapaar_strategies/` → `tantra_strategies/`, etc.), `pyproject.toml`
   `name`, and every `import vyapaar` / `from vyapaar` site; update `pyproject.toml` dependency
   pins on the wheel (`vyapaar` → `tantra`).
3. Rewrite any in-repo references in docs, `tools/*.py`, `schema/` descriptions, `tests/`.
4. Gate per package: `pytest -q`, `ruff check .`, `ruff format --check .`, `mypy` (where used);
   commit per package: `refactor(<pkg>): rename vyapaar_* to tantra_*`.

### Phase 3 — Repositories, submodules, and org (root-level, LAST)

1. Rename **GitHub repos** (via `gh repo rename`), order-independent; update `.gitmodules`
   `url = git@github.com-dev:vyapaar-labs/vyapaar-*` → `...tantra-labs/tantra-*`, and the
   submodule `path = vyapaar-*` → `path = tantra-*` (`git mv` each submodule directory at root).
2. Rename the **GitHub organization** `vyapaar-labs` → `tantra-labs` (web/`gh api`; this is a
   one-shot, all repos move). Update `scripts/create-remote-repos.sh` (`ORG`, `REPOS` list,
   descriptions), the root `Makefile` (`REPOS`/`ALL_REPOS` comments and names), and every
   root-level doc (`README.md`, `docs/design/architecture.md`, `docs/plans/*.md`,
   `docs/future-work-bottoms-up-build-order.md`, `.agents/AGENTS.md`, `.agents/HANDOFF.md`,
   `docs/design/0001-crate-topology-audit-and-target.md`).
3. Update **SSH remotes** on every checkout: `git remote set-url origin
   git@github.com-dev:tantra-labs/tantra-*`.
4. Gate: `git submodule sync && git submodule update --init --recursive`; `make check`/`make prod`
   from a fresh clone path; `make push` succeeds for every repo with a `main`.
5. Commit at root: `docs(plans): rename vyapaar to tantra across repos and org`.

### Phase 4 — Sweep & close-out

1. **Case-sensitive sweep** for leftovers:
   `rg -i 'vyapaar' -l` (excluding `target/`, `.git/`, `.venv/`, `node_modules/`) must return
   zero; verify both `VYAPAAR`, `Vyapaar`, `vyapaar` forms.
2. Re-run all workspace gates (Rust `make check`/`make test`/`make prod`, Python
   `pytest`/`ruff`/`mypy`).
3. **No cross-repo `// stand-in for vyapaar-*/docs/gaps/...` citation comments may remain** —
   every one must be rewritten to `tantra-*` in the same change that renames the owning repo.
4. Close the plan: mark this document Implemented in `docs/plans/README.md` (record closing
   commit), remove this plan doc from active `docs/plans/`, and update every repo's
   `.agents/HANDOFF.md` + the root `HANDOFF.md`.

## 3. Operating Invariants (binding throughout)

- **Build/profile discipline**: only `--profile prod` builds/tests (`make prod`, `make check`,
  `make test`); bare `cargo build`/`--release` forbidden (`.agents/rules/build-discipline.md`).
- **Parallel test directory rule**: tests stay in `tests/`; no in-file `#[cfg(test)]`.
- **Zero-floats / zero-I/O domain purity**: unchanged by a nominal rename — do not touch
  financial math while renaming; `git mv` + string rewrites only.
- **Case order**: apply `VYAPAAR`/`Vyapaar`/`vyapaar` replacements so `Vyapaar` (title) is
  handled before/independently of lowercase to avoid partial `Tantra`/`tantra` collisions.
- **No mixed-commit state**: each per-workspace/per-package commit is self-contained and gated;
  never commit a half-renamed crate that fails its own build.
- **Naming precedence**: `tantra` wins over any hypothetical clash; if a crate name collides with
  an existing unrelated name during the rename, keep the repo's `-<subsystem>` suffix
  (`tantra-core`, `tantra-ledger`, …) exactly mirroring today's `vyapaar-*` shape.
- **HANDOFF hygiene**: update the root and per-repo `HANDOFF.md` in the same change as each
  phase; trim superseded slices.

## 4. Verification Matrix

| Phase | Gate | Pass criteria |
|:---|:---|:---|
| 0 | `git submodule status`, `make check` (per workspace), `pytest`/`ruff` (per py pkg) | All green; baseline logged |
| 1 | `make check`/`make test`/`make prod` per Rust workspace | Green; `rg 'vyapaar' crates/*/{src,Cargo.toml}` = 0 |
| 2 | `maturin develop` + `pytest -q`; per-pkg `pytest`/`ruff`/`mypy` | Green; `rg 'vyapaar' pyproject.toml python/` = 0 |
| 3 | `git submodule sync --recursive`, fresh-clone `make check`/`make prod`, `make push` | All repos push to `tantra-labs/tantra-*` |
| 4 | `rg -i 'vyapaar'` (all files, excluding build/vendor dirs) | **Zero** matches; all gates green |

## 5. Risks & Open Decisions

1. **`.github` repo** has no commits on `main`; a rename leaves an empty orphan. Decide before
   Phase 3 whether to seed an initial commit (org profile README) first.
2. **`vyapaar-fe` / `vyapaar-ui-web`** are referenced in scripts/docs but not checked out;
   rename their remote names in `create-remote-repos.sh` and doc tables regardless.
3. **Published artifacts**: the `vyapaar` PyPI wheel and any pinned versions in downstream
   `pyproject.toml` change name; update all pins in the same phase to avoid broken installs.
4. **External consumers** (anything outside this workspace referencing `vyapaar-labs` URLs, the
   `vyapaar` wheel, or `vyapaar_*` crates) will break; the org/repo rename is the highest-blast
   radius step and is therefore last.
5. **Opencode/session state** referencing repo paths by name: update `opencode.jsonc` and any
   absolute-path references in docs (`docs/design/*`, per-repo `HANDOFF.md`) in the same commit.
