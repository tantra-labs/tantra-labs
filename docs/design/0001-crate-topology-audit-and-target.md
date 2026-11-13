# 0001 — Crate Topology Audit & Target Arrangement (tantra-labs)

**Status**: Proposed (design / audit) — filed 2026-11-12
**Scope**: All 9 Rust workspaces and their crate inventories (72 crates); Python repos out of scope
  except where their broker adapters overlap Rust broker crates.
**Inputs**: Verified by direct inspection of each workspace `Cargo.toml` and every crate's `src/`
  (line counts, imports, workspace.dependencies entries). See `docs/plans/0003-*.md` for the
  consolidation plan that operationalizes this doc, and `docs/gaps/0001-*.md` … for the individual
  items.

---

## 0. Executive Summary

The question asked was: *"there are too many crates — check if this is the best logical way of
arranging."*

**Verdict**: The **repo-level** arrangement (one Git submodule per DDD bounded context, per
`docs/design/architecture.md`) is sound and should be kept. The **crate-level** arrangement inside
several repos is **not** optimal: 12 of the 72 Rust crates (17%) are empty stubs, re-export shims,
or exact duplicates of a crate in another workspace, and the facade-crate convention is
inconsistent across repos. This inflates workspace member lists, `workspace.dependencies` bloat,
compile surface, and CI time for no functionality.

Target: **72 → ~60 crates** (delete/absorb 12 stub or duplicate crates) and a single documented
facade convention, without touching any real implementation.

---

## 1. Current Inventory (verified)

| Workspace (repo) | Crates | Real (≥~100 lines of logic) | Stub / shim / duplicate |
| :--- | :---: | :---: | :---: |
| `tantra-core` | 1 | `tantra-core` | — |
| `tantra-risk` | 1 | `tantra-risk` | — |
| `tantra-ledger` | 6 | `ledger`, `oms`, `portfolio`, `journal`, `allocation`, `performance` | — |
| `tantra-market` | 14 | `core`, `normalizer`, `indicators`, `signals`, `store`, `finance`, `pricing` | **7**: `feed`, `loaders`, `zerodha`, `upstox`, `fyers`, `angelone`, `dhan` |
| `tantra-exec` | 8 | `core`, `auth`, `router`, `slicer`, `audit`, `zerodha`, `upstox` | **1**: `angelone` |
| `tantra-runtime` | 14 | `actors`, `api`, `api-rest`, `backtest`, `config`, `enhancer`, `jobs`, `persistence`, `strategy`, `testing` | **4**: `feed` (shim), `indicators` (dup), `market` (stub), `test-utils` (stub) |
| `tantra-agent` | 17 | `agent`, `core`, `llm`, `prompt`, `replay`, `trader-loop`, `research`, `analytics`, `genetic`, `mcp`, `tools`, `plugins`, `report`, `chat`, `chat-tools`, `forecast`, `panel` | — (all real, several thin) |
| `tantra-ffi` | 2 | `codegen`, `py` | — |
| `tantra-ui` | 9 | all 9 | — |
| **Total** | **72** | **~60** | **12** |

### 1.1 Verified stub / shim / duplicate crates

| Crate | `src` size | Problem | Provider repo |
| :--- | :---: | :--- | :--- |
| `tantra-market-zerodha` | 1 line | empty stub (`//! doc only`) | `tantra-market` |
| `tantra-market-upstox` | 1 line | empty stub | `tantra-market` |
| `tantra-market-fyers` | 1 line | empty stub | `tantra-market` |
| `tantra-market-angelone` | 1 line | empty stub | `tantra-market` |
| `tantra-market-dhan` | 70 | skeleton `DhanFeed` returning empty streams, no wire protocol | `tantra-market` |
| `tantra-market-feed` | 1 line | empty stub; the actual `MarketDataFeed` trait + `CoalescingTickBuffer`/`ReconnectionManager`/`WsClient` live in `tantra-market-core` | `tantra-market` |
| `tantra-market-loaders` | 1 line | empty stub | `tantra-market` |
| `tantra-exec-angelone` | 9 | near-empty stub (only `tantra-core`+`serde` deps) | `tantra-exec` |
| `tantra-runtime/tantra-indicators` | 1 | **exact duplicate** of real `tantra-market-indicators` (4635 lines); nothing imports it | `tantra-runtime` (delete) |
| `tantra-runtime/tantra-runtime-market` | 1 | empty stub ("Stub crate: tantra-me-market" — honba legacy); nothing imports it | `tantra-runtime` |
| `tantra-runtime/tantra-runtime-test-utils` | 1 | empty stub; nothing imports it | `tantra-runtime` |
| `tantra-runtime/tantra-runtime-feed` | 30 | re-export shim over `tantra-market-store` (consumed by `tantra-runtime-api-rest`, which already depends on `tantra-market-store` directly) | `tantra-runtime` |

### 1.2 Cross-cutting inconsistencies (verified)

1. **Facade-crate convention is inconsistent.** `tantra-ledger` and `tantra-agent` each expose a
   repo-named facade crate (`tantra-ledger`, `tantra-agent`) that re-exports the member crates.
   `tantra-market`, `tantra-exec`, `tantra-runtime`, `tantra-ffi`, `tantra-ui` have **no**
   repo-named facade — consumers must import the `-core` or specific member crate directly.
2. **`tantra-runtime` workspace.dependencies still carries legacy honba aliases** that nothing
   consumes: `tantra-api-rest`, `tantra-api`, `tantra-backtest`, `tantra-actors` (aliases onto
   `tantra-runtime-api-rest`, `tantra-runtime-api`, `tantra-runtime-backtest`,
   `tantra-runtime-actors`).
3. **Cross-repo path-dependency sprawl**: `tantra-runtime/Cargo.toml` declares path deps into 5
   sibling repos (ledger, market, exec, agent, ffi) — ~40 path entries. Normal for a monorepo
   superproject, but worth pruning whenever a stub is removed.

---

## 2. Why the repo-level split is right (keep it)

- Each repo is a single DDD bounded context (Kernel / Heart / Gate / Eye / Hand / House / Brain /
  Soul / Face), matching `docs/design/architecture.md` and `.agents/AGENTS.md` §2.1.
- Zero-I/O domain purity (`core`, `risk`, `ledger-*`) is enforced at the workspace-dependency
  level: `tantra-ledger` bans `tokio`; `tantra-core`/`tantra-risk` are single zero-I/O crates.
- Independent CI per repo (§7 of AGENTS.md) and per-repo `docs/{plans,gaps}` discipline.
- WASM portability: `tantra-ui` isolates native (`tokio`/`ratatui`/`crossterm`) crates from WASM
  crates; `tantra-market` compute crates compile to `wasm32-unknown-unknown`.

## 3. Why the intra-repo inventory is not optimal (fix it)

1. **12 stub/duplicate crates add ~17% pure overhead**: workspace member list bloat, `cargo
   metadata`/lock churn, compile+CI surface, and — worst — *fake architecture*: a reader cannot tell
   an empty `tantra-market-zerodha` from a real one without opening the crate.
2. **The real market-feed trait lives in `tantra-market-core`, while `tantra-market-feed` is an
   empty crate** that appears to own it. That is an active trap for implementers.
3. **`tantra-runtime/tantra-indicators` is an exact duplicate name of the real
   `tantra-market-indicators`** — a future implementer will very likely populate the wrong crate.
4. **Facade inconsistency**: with facades in ledger/agent but not market/exec/runtime/ffi, there is
   no single "import this to get the context" rule, so consumers pick member crates ad hoc.

---

## 4. Target arrangement (what "best logical" looks like)

1. **Every crate registered in a workspace must have real, owned functionality.** Empty stubs are
   removed from `members` (the *capability* stays tracked as a gap in the provider repo; it can be
   re-added when actually implemented).
2. **One owner per concept.** Indicators live only in `tantra-market-indicators`. Market-data
   feed/store/lakehouse live only in `tantra-market-core` + `tantra-market-store`. Broker WS
   connectors either exist as real crates or do not exist at all.
3. **One facade convention** (recommended: *"repo-named facade crate re-exports the context's
   public API"* — matching ledger/agent). Applied uniformly to `tantra-market`,
   `tantra-exec`, `tantra-runtime`, `tantra-ffi`; facade crates contain only re-exports.
4. **No legacy alias entries** in any `workspace.dependencies`.
5. **Keep the layering**: zero-I/O domain crates stay in `core`/`risk`/`ledger-*`; async I/O stays
   in market-feed/store, exec-*, runtime-*, agent-*; WASM stays in `tantra-ui` web crates.

### 4.1 Per-repo target counts

| Repo | Current | Target | Action |
| :--- | :---: | :---: | :--- |
| `tantra-market` | 14 | **7** | remove stubs: `feed`, `loaders`, `zerodha`, `upstox`, `fyers`, `angelone`, `dhan` (gaps 0001–0002); add facade `tantra-market` later (gap 0007) |
| `tantra-exec` | 8 | **7** | remove or complete `angelone` (gap 0006); add facade `tantra-exec` (gap 0007) |
| `tantra-runtime` | 14 | **10** | remove `indicators` (gap 0003), `market` + `test-utils` (gap 0005); absorb `feed` shim into `api-rest` (gap 0004); prune legacy aliases (gap 0008) |
| others | — | unchanged | — |
| **Total** | **72** | **~60** | **−12 crates** |

### 4.2 Pinned facade-crate convention (ADR, 2026-11-13 — plan 0003 Phase 4)

Every multi-crate Rust workspace exposes a **repo-named facade crate** that contains only
re-exports of the context's public API (member crates re-exported as short-named modules),
matching the pre-existing `tantra-ledger` / `tantra-agent` facades. Facade crates land in
`crates/<repo-name>` with `description = "Facade of the tantra-<context> bounded context…"`.

- Conforming since plan 0001: `tantra-ledger`, `tantra-agent`.
- Added by plan 0003 Phase 4 (2026-11-13): `tantra-market`, `tantra-exec`, `tantra-runtime`,
  `tantra-ffi`, `tantra-ui`.
- Consumers may keep importing member crates directly; the facade is the recommended
  "import the whole context" path. A reverse decision (retire facades) would remove the
  facades, not add member-crate imports.

---

## 5. Risks & guardrails

- **Risk: deleting a stub that is actually depended upon.** Guard: before any removal, grep all
  `Cargo.toml` + `src/` for the crate name. (Verified for every stub above: only `tantra-runtime-feed`
  and `tantra-runtime-market` appear in a dependent `Cargo.toml`; `runtime-feed` is re-exported to
  `api-rest`, `runtime-market` is declared-but-unused in `api-rest`.)
- **Risk: breaking `workspace.dependencies` path entries.** Guard: remove the corresponding entry in
  the owning workspace's `Cargo.toml` in the same commit as the member removal.
- **Zero-I/O / WASM / zero-floats invariants are unaffected** — this plan touches crate topology,
  not domain logic.
- **Python `tantra-adapters` broker SDKs are unaffected** (they are dev/research-only per
  `tantra-adapters/docs/plans/0001` decision; the Rust broker stubs being removed do not back them).

---

## 6. Referenced docs

- `docs/plans/README.md` — plan 0003 (the phased plan, this audit's execution arm) is
  **implemented 2026-11-13** and recorded in the Implemented table; §4.2 pins the facade
  convention it delivered.
- `docs/gaps/README.md` — the gap index; stub/duplicate items 0003–0008 are **closed** (plan
  0003, 2026-11-13) and 0001/0002 remain open as feature trackers.
- `docs/design/architecture.md` — the bounded-context architecture this doc preserves.
- `.agents/rules/gap-tracking.md` — the filing/cleanup discipline applied here.
