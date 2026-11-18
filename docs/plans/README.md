# Plans Index — `tantra-labs`

Master architecture and cross-subsystem plans for the Tantra platform.
Per workspace rule `.agents/rules/gap-tracking.md`:
- Gaps are individual features (`docs/gaps/XXXX-*.md`).
- Plans are collections of gaps (`docs/plans/XXXX-*.md`).
- When implemented, plan documents are cleaned up from `docs/plans/` and recorded in this index.

## Active Plans

| # | Title | Target Scope | Status |
|---|---|---|---|
| [0001](0001-fincept-quantcepts-gap-closure-and-feature-roadmap.md) | Fincept & Quantcepts Feature Parity, Gap Closure, and Platform Expansion Master Plan | Platform-wide | Approved Architecture & Implementation Roadmap |
| [0005](0005-elephant-edge-strategy-platform.md) | Elephant Edge (EE+) Intraday Strategy Platform — level map, buy/sell signals, SL/TSL, positioning (with Order Blocks & OI/gamma confluence) | `tantra-strategies`, `tantra-core`, `tantra-market`, `tantra-data`, `tantra-exec`, `tantra-risk`, `tantra-ledger`, `tantra-ui`, `tantra-agent`, `tantra-docs` | **Active — Phases 1–5 mostly shipped 2026-11-17 (T12.1–T12.8 ✅, T12.9 partial)**: kernel types (core 0003), EE+ indicators (market 0005), option-chain lakehouse (data 0016), EE+ strategy (strategies 0001), bracket execution (exec 0003), stop-protection gate (risk 0005), bracket OMS (ledger 0012), `level_map`/`oi_walls` chat tools (agent 0011), chart primitives (ui 0007). **Remaining**: ui plan 0006 Strategy Studio view layer, runtime synthetic-OCO wiring, `portfolio.apply_fill` FIFO bracket P&L; research basis `docs/research/elephant-edge-strategy.md` |
| [0009](0009-qullamaggie-swing-trading-platform.md) | Qullamaggie Multi-Market Swing Trading Platform (India NSE/BSE & US Equities) — cross-sectional leader rank, ADR%(20), Breakout/EP/Parabolic setups, 10/20 regime harness, back watchlist & journal | `tantra-core`, `tantra-market`, `tantra-data`, `tantra-strategies`, `tantra-runtime`, `tantra-exec`, `tantra-risk`, `tantra-ledger`, `tantra-adapters`, `tantra-agent`, `tantra-ui`, `tantra-ui-web`, `tantra-docs` | Proposed — consolidates Qullamaggie research, 34-capability gap audit, Strategy Contract (`P`/`C`/`E`), market profiles, Phases 0–6 roadmap, and Validation Ladder (`Stages A–F`) |
| [0010](0010-screener-taxonomy-and-alerts.md) | Screener Taxonomy, QVM Score, Alpha-Style Group Alerts & Screener MCP (Trendlyne-inspired, native) | `tantra-core`, `tantra-data`, `tantra-strategies`, `tantra-runtime`, `tantra-agent`, `tantra-examples`, `tantra-ui-web` | **P1 Implemented 2026-11-17** (`tantra-core` 0004 slim classification VOs + converged recursive `Decimal` Screener DSL + `tantra-ffi` codegen/Python + `tantra-market`/`tantra-runtime`/`tantra-ui` migrations); P2–P9 proposed — research basis `docs/research/trendlyne-screener-alerts-mcp.md`; per-repo plans in §1 |
| [0008](0008-trade-signal-generator.md) | Trade Signal Generator — TradePlanner + TradeManager: entry, SL, TSL, profit-booking ladder, position sizing; presets `qullamaggie`/`ee_plus`/`atr_swing` | `tantra-core`, `tantra-market`, `tantra-ffi`, `tantra-strategies`, `tantra-runtime`, `tantra-agent` | Proposed — per-repo plans in §1; replaces the `strategy_suggest` stub |
| [0011](0011-unified-data-catalog-lakehouse-v3.md) | Unified Data Catalog & Git-Style Content-Addressed Lakehouse (v3) — canonical `domain/dataset/exchange` taxonomy, right-sized IST partitions, `(instrument_uid, ts)` row-group pruning, `objects/sha256` CAS, `catalog.duckdb` manifest + `refs/{heads,tags}`, and deterministic backtest commit pinning | `tantra-data`, `tantra-market`, `tantra-runtime` | **Phases 1–3 Implemented 2026-11-18** (Phases 1–2 `tantra-data` plan `0009` A–C: `ee802e9`/`398eeb7`/`d64c877`, gap `0025` closed, + atomic `trees/` export; **Phase 3 Rust & `tantra serve`**: `tantra-market` gap `0008` + `tantra-runtime` gap `0011` closed 2026-11-18) — ADR [`docs/design/0004-data-catalog-lakehouse-layout.md`](../design/0004-data-catalog-lakehouse-layout.md); Phase 4 (legacy fallback removal) remains |
| [0012](0012-remaining-gap-closure-and-independent-fixes.md) | Remaining Open Gaps: Consolidated Inventory & Independent-Fixes Track (T18) — scrape of all 15 open gap docs (2026-11-16); new **T18 track** for the unclaimed fixes (NSE holiday provider, `/ws/chat` model+multimodal, `QuoteTick` session fields, MF store surface, shareholding/SAST, runnable catalog strategies) | `tantra-data`, `tantra-market`, `tantra-runtime`, `tantra-strategies` (+ cross-references to T12/T16/TSG/Screener tracks) | **T18.1–T18.6 Implemented 2026-11-17** (data 0015/0023/0024, runtime 0009/0010, strategies 0007 closed) — inventory & plan retained as the consolidated record; T18 rows in `docs/task-list-tracks-and-phases.md` |
| [0013](0013-fire-planning-and-cashflow-platform.md) | FIRE Planning, Cashflow & Retirement Simulation Platform (`Elicherla01/fireapp` Full-Stack Incorporation) — L1 (`tantra-ledger`) `Decimal` engine, 5 archetypes, 3-bucket paycheck, SoRR stress, Finance Act 2025 tax drag, `Profile.fire_plans` CAS persistence & portfolio hydration, REST/MCP/chat/Python FFI/CLI/TUI/WASM/Web UI, strategy templates | `tantra-ledger`, `tantra-runtime`, `tantra-agent`, `tantra-ffi`, `tantra-ui-web`, `tantra-ui`, `tantra-strategies` | **Active — P0 (`T19.1` `tantra-ledger` `a735aa3`) Implemented 2026-11-18**; P1–P6 (`T19.2–T19.7`) proposed; zero `tantra-core` changes; per-repo plans in §2 |

## Related

- [`docs/task-list-tracks-and-phases.md`](../task-list-tracks-and-phases.md) — consolidated,
  track/phase-ordered task list generated from the per-repo `docs/{plans,gaps}` indexes
  (update it in the same change as any index cleanup).

## Implemented Plans

| # | Title | Target Scope | Implemented In |
|---|---|---|---|
| 0007 | Standalone Paper Trading Exchange (real-exchange mimic) — one `tantra-exec-paper` matching engine serving strategies, REST, backtest, Python SDK (`tantra.paper`), and CSR/WASM + web, plus a `paper serve` daemon | `tantra-exec`, `tantra-runtime`, `tantra-ffi`, `tantra-ui`, `tantra-examples`, `tantra-strategies`, `tantra-docs` | Complete 2026-11-16 (T14.1–T14.16). P0 `tantra-exec-paper` (`tantra-exec` 2fa2fe3; order lifecycle, account isolation, `BrokerExecutor`+`SimExecutionPort`, E9 parity). P1 runtime wiring (`tantra-runtime` 027ebac/a9d1d96/18be257/a1cbeda/f70e0e2: REST `/orders`, strategy dispatch, `/ws/live`, backtest unification, `paper serve`; runtime gap 0008 closed). P2 Python wheel `tantra.paper` (`tantra-ffi` c7e90a5; examples 8189fb1; strategies 13cbae0). P3 CSR/WASM (`tantra-ui` fad62c3/768b375/4b2a207/b54d2b6). P4 golden-vector parity (`tantra-exec` 5714ee2, `tantra-ui` 5bbd743, `tantra-ffi` 898f61c — one `paper_golden.json` byte-identical across backtest/paper/Python/WASM) + docs (`tantra-docs` 1157674 `docs/paper-trading/`). |
| 0003 | Crate Topology Consolidation: remove stub/duplicate crates, absorb the feed shim, pin the facade convention, prune legacy aliases | `tantra-market` (14→8 crates), `tantra-runtime` (14→11), `tantra-exec` (+facade), `tantra-ffi` (+facade, deps pruned), `tantra-ui` (+facade) | Complete 2026-11-13. Ph 1: 7 market stub crates removed. Ph 2: `tantra-indicators` dup + `runtime-market`/`test-utils` stubs deleted; `tantra-runtime-feed` shim absorbed into `tantra-runtime-api-rest::market_feed` (25 files re-pointed). Ph 3: **decision — implement** `tantra-exec-angelone` (tracked by `tantra-exec` plan 0002). Ph 4: facade convention pinned (ADR, design doc §4.2) + facades added for market/exec/runtime/ffi/ui; legacy honba aliases + ffi unused `tantra-market-*` deps removed. Ph 5: all 9 Rust workspaces `check --profile prod` + `fmt --check` + `clippy -D warnings` green; `market`/`exec` full `test --profile prod` green. Gaps 0003/0004/0005/0007/0008 closed; 0001/0002 stay open as feature trackers (real feeds); 0006 stays open (implement decision). |
| 0006 | Dismantle the `_kernel` shared harness — lift domain/math modules into the wheel (`tantra.portfolio`/`risk`/`options`/`metrics`/`calendar`) and rename the remaining examples harness out of `_kernel` | `tantra-ffi` (wheel), `tantra-examples` (harness) | Complete 2026-11-16 (T13.1–T13.7). Thrust A: wheel surfaces + tests in `tantra-ffi` `9b354d5`/`3d5a1ac`/`f210c8a`/`119061a`; domain consumers retargeted + `_kernel/{portfolio,risk,greeks,option,evaluator,calendar}.py` deleted in `tantra-examples` `25cb5df`. Thrust B: harness rename `_kernel/` → `tantra_examples/harness/` + repo-wide `_kernel` deletion + docs sweep in `1acabfb`/`3c2e5ae`/`80134a8`. Gate: wheel 480 passed; examples `tests/unit` 909 passed / 51 skipped, zero new failures (6 pre-existing `test_06_multi_broker_dispatch` env failures — installed `tantra_adapters` entry points bypass the example's paper fallback; reproduce on pre-T13 `1d89fd9`); ruff clean; follow-on candidates recorded (runner→wheel session, service→tantra_data, testing→wheel helper, fills_equity_curve Decimal end-to-end). |
| 0004 | Rename the entire platform to Tantra (org, repos, crates, Python packages, docs) | Platform-wide (all repos + org `tantra-labs`) | Complete 2026-11-12; per-repo commits `65c50a4`–`08a01c9` + root `docs(plans)` commit; identity rewrite to `dev-pmallapp` (`dev.prem.mallappa@gmail.com`) applied across history |
| 0002 | Strategy Execution, Hyperparameter Tuning, and Optimal Trade Suggestion Engine for CLI & TUI | `tantra-agent`, `tantra-ui`, `tantra-runtime` | Phases 1–5 Complete (`tantra-agent` 85d3c07, `tantra-ui` 1beb69f + 0694c05, `tantra-runtime` 60a5bd9) |

### 1. Updated `.agents` Rules
Updated [`.agents/rules/gap-tracking.md`](../../.agents/rules/gap-tracking.md) and [`.agents/AGENTS.md`](../../.agents/AGENTS.md) (§9) with the binding **Plan & Gap Tracking Rule**:
- **Definitions**:
  - **Gaps** (`docs/gaps/XXXX-*.md`): Individual features, endpoints, or stubs.
  - **Plans** (`docs/plans/XXXX-*.md`): Collections of gaps or multi-phase architectural features.
- **Upstream Provider Filing**:
  - When implementing a plan/gap, if any hardcoded, stubbed, mock, or sample data is used, a `docs/{plans,gaps}/XXXX-*.md` document must be added to the **respective repository that is supposed to provide the functionality** (the upstream owning repo).
  - In the consuming repo, the stub/workaround must cite the dependency with a code comment (e.g., `// stand-in for tantra-core/docs/gaps/0001-*.md`) and in the commit message.
- **Cleanup of Implemented Items**:
  - Once a plan or gap is implemented and verified, the document is cleaned up (removed from active `docs/{plans,gaps}/`).
  - The repository's index table (`docs/plans/README.md` or `docs/gaps/README.md`) and any referencing indices (such as [`docs/future-work-bottoms-up-build-order.md`](../../docs/future-work-bottoms-up-build-order.md)) are updated to record completion details and closing commits without broken file links.
- Synced the rule across submodules (symlinked `.agents/rules` in `tantra-examples` and updated `tantra-ui-web/.agents`).

---

### 2. Workspace-Wide Repository Cleanup and Index Updates

Across all repositories, cleaned up completed plan/gap markdown documents from `docs/{plans,gaps}/` and established or updated the respective `README.md` index files:

| Repository | Active / Open | Implemented / Closed Cleaned Up | Index File |
| :--- | :--- | :--- | :--- |
| **`tantra-labs` (root)** | Plan `0001` (Master Roadmap) | Plan `0002` (Strategy Execution, Tuning & Suggestions) | [`docs/plans/README.md`](../../docs/plans/README.md) |
| **`tantra-core`** | Plan `0001` (Phase 2 call-site consolidation open) | Plan `0001` Phase 1 landed in `9ce4880` + `43a11f0` | [`tantra-core/docs/plans/README.md`](../../tantra-core/docs/plans/README.md) |
| **`tantra-ledger`** | Plan `0001` (Phases 2–4 open) | Plan `0001` Phase 1 landed in `b35a314` | [`tantra-ledger/docs/plans/README.md`](../../tantra-ledger/docs/plans/README.md) |
| **`tantra-market`** | Plan `0001` (Phase 4 open) | Plan `0001` Phases 1–3 landed in `ddb5c3f` + `602a710` | [`tantra-market/docs/plans/README.md`](../../tantra-market/docs/plans/README.md) |
| **`tantra-exec`** | *(None)* | Plan `0001` (Wire-mapping in `2675c07`, crypto resolved NO-GO in `d529bc9`) | [`tantra-exec/docs/plans/README.md`](../../tantra-exec/docs/plans/README.md) |
| **`tantra-adapters`** | *(None)* | Plan `0001` (Python/Rust adapter boundary resolved in `4f497aa`) | [`tantra-adapters/docs/plans/README.md`](../../tantra-adapters/docs/plans/README.md) |
| **`tantra-ffi`** | *(None)* | Plan `0001` (Python bridge policy adopted in `c7bc420`) | [`tantra-ffi/docs/plans/README.md`](../../tantra-ffi/docs/plans/README.md) |
| **`tantra-strategies`**| *(None)* | Plan `0001` (Versioned manifests & baskets landed in `207a70c`) | [`tantra-strategies/docs/plans/README.md`](../../tantra-strategies/docs/plans/README.md) |
| **`tantra-risk`** | *(None)* | Plan `0001` (Tool annotation hooks landed in `5b00cda`) | [`tantra-risk/docs/plans/README.md`](../../tantra-risk/docs/plans/README.md) |
| **`tantra-examples`** | Gaps `0001`–`0008` (wheel mirrors) | Plans `0001` (in `552c873`) and `0002` (in `bbfa692`) | [`tantra-examples/docs/plans/README.md`](../../tantra-examples/docs/plans/README.md) |
| **`tantra-agent`** | Plans `0001`, `0002`, `0004` (P4 deferred), `0005` | Plan `0003` (Forecast, panel, report engines in `51b024d` + `236f8eb`) | [`tantra-agent/docs/plans/README.md`](../../tantra-agent/docs/plans/README.md) |
| **`tantra-ui`** | Plans `0001`–`0003`, Gap `0001` (scan open) | Plans `0004` (CLI/TUI ref) and `0005` (Screen inventory in `2cda245` + `acdc137`) | [`tantra-ui/docs/plans/README.md`](../../tantra-ui/docs/plans/README.md) |
| **`tantra-docs`** | Plan `0001` | Plan `0002` (Fincept/Quantcept mapping & OmniRoute setup in `1267490`) | [`tantra-docs/docs/plans/README.md`](../../tantra-docs/docs/plans/README.md) |
| **`tantra-data`** | Plans `0001`, `0002` | Gap `0001` (Catalog coverage verified in `56d8ba1`) | [`tantra-data/docs/plans/README.md`](../../tantra-data/docs/plans/README.md) |
| **`tantra-runtime`** | Plans `0001`–`0002`, Gaps `0001`–`0002` | *(Active development in progress)* | [`tantra-runtime/docs/plans/README.md`](../../tantra-runtime/docs/plans/README.md), [`tantra-runtime/docs/gaps/README.md`](../../tantra-runtime/docs/gaps/README.md) |
| **`tantra-ui-web`** | Plans `0001`–`0008`, 41 Open Gaps | Plans `0009` (Chart library choice) and `0010` (Unified workspace shell); recorded 17 closed gaps (`0003`, `0008`, `0011`, `0019`, `0025`, `0026`, `0031`, `0032`, `0034`, `0035`, `0036`, `0037`, `0041`, `0050`, `0052`, `0056`, `0058`) in Closed Gaps index | [`tantra-ui-web/docs/plans/README.md`](../../tantra-ui-web/docs/plans/README.md), [`tantra-ui-web/docs/gaps/README.md`](../../tantra-ui-web/docs/gaps/README.md) |
