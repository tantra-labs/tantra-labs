# HANDOFF — tantra-labs

**Status**: Bottoms-up Fincept/Quantcept gap-closing build order
(`docs/future-work-bottoms-up-build-order.md`) — Layers 0, 1, 2, 2b, 3, 4, 5, 6 GREEN;
Level 7 (`tantra-data/0002`, filings breadth) partially superseded: filings ingestion itself
landed (closed gap `tantra-data/docs/gaps/0003`). Agent-side **plan 0006 (MCP/chat tool
catalog expansion) is complete**; follow-on breadth tracked under agent plan 0007. Upstream
bridges remaining: `tantra-data/docs/gaps/0007-filings-rust-bridge.md` (filings) and
`tantra-data/docs/gaps/0008`/`0009` (corporate actions).
Date: 2026-11-13 · Workspace: `tantra-labs`
Playbook: `docs/future-work-bottoms-up-build-order.md` (execution order, by crate dependency
depth). The repo-migration (`honba-*` → `tantra-*`, Tier 0–6) that used to be this file's whole
subject is complete and long superseded — see "Prior work" below.

## Latest Batch — Elephant Edge (EE+) strategy platform docs (research + plans/gaps)

Date: 2026-11-13. Research + documentation batch (no code changes):
- **Research**: `docs/research/elephant-edge-strategy.md` — Elephant Edge intraday strategy
  (AlgoBing percentile-zone S/R + Velez "elephant bar" institutional footprint), the two-support/
  two-resistance session-open-anchored levels, and the strengthening stack (OI walls, ΔOI
  build-up, PCR, max pain, **gamma exposure / dealer positioning**, IV, futures flows) +
  Order-Blocks fusion model.
- **Master plan**: root `docs/plans/0005-elephant-edge-strategy-platform.md` (proposed) — 6
  phases across 10 repos; strategy contract (level map → buy/sell signals → SL/TSL → positioning,
  zero floats, regime gate, research-live parity).
- **Per-repo filings** (all proposed/open): `tantra-strategies` plan 0001 (the EE+ strategy spec —
  signals, SL/TSL, positioning, Order Blocks, declarative parameters) + gap 0006 (SDK lacks
  stop-protection primitives & options/level-map context); `tantra-core` plan 0003 + gap 0002
  (level-map/options/gamma/stop/signal kernel types); `tantra-market` gap 0005 (Elephant-zone /
  OI-wall / gamma / Order-Block indicators — chain+OI plumbing gaps 0001/0002 already closed);
  `tantra-data` gap 0016 (intraday option-chain snapshot lakehouse + point-in-time GEX);
  `tantra-exec` gap 0003 (bracket-order SL/TSL execution — note: **exec gap 0001 Angel One is
  CLOSED** per `2258bbb`, summary row updated); `tantra-risk` gap 0005 (stop-protection
  validation, mandatory SL + no-widening TSL); `tantra-ledger` gap 0012 (bracket OMS lifecycle);
  `tantra-agent` plan 0011 (`level_map`/`oi_walls` chat tools, cites plan 0010);
  `tantra-ui` plan 0006 (EE+ Strategy Studio) + gap 0007 (chart level/zone/annotation
  primitives); `tantra-docs` plan 0003 (user guide).
- **Indexes updated in the same change**: per-repo `docs/{plans,gaps}/README.md` tables (root
  plans 0001 + 0005 active; core 0002+0003; strategies 0001; agent 0011; ui 0006; docs 0003;
  gaps core 0002, market 0005, data 0016, exec 0003, risk 0005, ledger 0012, ui 0007,
  strategies 0006) and the derived `docs/task-list-tracks-and-phases.md` (**new T12 track**,
  T12.1–T12.10 + per-repo summary refresh).
- **No build needed** (docs-only batch; no Rust/Python code touched).

## Immediate Next Step (EE+)

## Latest Batch — T4.1–T4.8 + T4.11 (broker adapters & execution)

Date: 2026-11-13. Executed the T4 track from `docs/task-list-tracks-and-phases.md`:
- **T4.1–T4.8 (plan 0002, Implemented)** in `tantra-adapters` (`fcd94bc`):
  - Phase A (gaps 0001–0003): contract tests for all 7 brokers (5 new test
    files mirroring `test_dhan.py`); real `get_bars` returning `list[Bar]`
    honoring `interval`/`days` for all 7 (per-broker historical endpoints);
    `cancel_order` parses the broker response into canonical `Order`.
  - Phase B (gaps 0004–0005): `WebSocketTransport` protocol +
    `MockWebSocketTransport` in-memory mock + per-broker
    `subscribe_ticks(instruments, callback)` → new canonical `Tick` model;
    `common/auth.py` with stdlib RFC 6238 TOTP + `login_zerodha`/
    `login_angelone`/`login_upstox` + `SessionState` expiry.
  - Phase C (gaps 0006–0007): `PaperBroker` order-book depth / partial fills /
    slippage / latency / seeded risk-limit rejection (defaults stay
    deterministic); `AdapterConfig.from_toml` (tomllib) + 5 missing
    `configs/*.toml` templates + parse tests.
  - Phase D: public exports from `common/__init__.py`, typed
    `MockTransportError`, fully-typed `Adapter` protocol + Protocol-typed
    `RecordingAdapter.inner`, `client_order_id` idempotency echo on
    `Order.meta`.
  - Verification: 44 → 134 tests green, `ruff check` + `ruff format --check`
    clean (incl. pre-existing `code-public-api.md`), `mypy --strict` clean.
- **T4.11 (gap 0001, closed)** in `tantra-exec` (`2258bbb`): SmartAPI 2.0
  `BrokerExecutor` adapter — REST place/modify/cancel/order book/positions/
  margins/health, SmartStream order feed → `ExecutionStream`, `BrokerEnumMap`
  wire tables, error mapping, `rate_limited()` (10/s), `SessionTokens` expiry;
  40 new tests, clippy `-D warnings` clean; gap/plan docs closed per repo
  (`e36f64c`).
- T4.9/T4.10 remain **Proposed** (adapters plans 0003/0004 — not approved).
- Cleanup per gap-tracking §4: adapters gaps 0001–0007 + plan 0002 closed
  (docs removed, indexes + task list updated); exec gap 0001 + plan 0002
  retired. Workspace total 71 → 67, phase-3 open 11 → 2 (both Proposed).

## Previous Batch — T3.1–T3.4 (market data & options infrastructure)

Date: 2026-11-13. Executed the T3 track from `docs/task-list-tracks-and-phases.md`:
- **T3.1 (gap 0001, closed)** options-chain enumeration/reader: `InstrumentMaster::list_chain`
  (by underlying, ordered expiry→strike→option type) on `CatalogInstrumentMaster`/`DatasetReader`,
  `ChainReader` port + `InstrumentChainReader` joining quotes + optional OI, exact-Decimal
  `ChainContract` (never f64). Wired into `tantra-runtime-api-rest::FeedMarketReader`:
  `options_chain` now reads the real chain (midpoint last-price, calendar-day expiry filter,
  500 cap); a master that cannot enumerate still maps to `PortError::unavailable`. Commits:
  `tantra-market` `b1b085e`, `tantra-runtime` `39ff389`.
- **T3.2 (gap 0002, closed)** OI time-series + four-quadrant buildup: `OpenInterestStore`
  port, `InMemoryOpenInterestStore` + `ParquetOpenInterestStore` (`{root}/open_interest/YYYY-MM-DD.parquet`,
  exact Decimal128 `Quantity`), `classify_buildup` (long/short buildup, short covering, long
  unwinding) + `BuildupAnalyzer` over OI store + daily bars. Commit `b1b085e`.
- **T3.3 (gap 0003, 2 of 5 shipped)** real broker WS feeds on `tantra-market-core`'s
  `WsClient`/`SymbolMapper`/`ReconnectionManager`: `tantra-market-dhan` (DhanHQ v2: JSON
  requests, LE binary ticker/quote/OI/prev-close/full/disconnect packets; REST LTP snapshot)
  `fb82571`; `tantra-market-zerodha` (Kite Connect 3: binary frames, ltp 8/quote 44/full 184,
  index 28/32; mode-per-token dispatch; REST LTP snapshot) `ad79205`. Both golden-byte tested
  (18 tests across the two crates), prices rounded to exact Decimal at the adapter boundary.
  **Remaining**: upstox, fyers, angelone re-added only when their wire protocols are real
  (fyers' raw subscribe request must be captured from the official SDK).
- **T3.4 (gap 0004 = root 0002, closed)**: feed traits in core, lakehouse/loaders in store,
  real `MarketDataFeed` impls now exist on top of core.
- Verification: market workspace check/fmt/clippy green; store 10 + dhan 10 + zerodha 8 new
  tests green; runtime api-rest chat_market_reader_tests 12 green. Live verification against
  Dhan credentials is the manual follow-on.
- Cleanup per gap-tracking §4: market gaps 0001/0002/0004 + root 0002 closed (docs removed,
  indexes + task list updated; total 74 → 71, market open gaps 4 → 1).

## Previous Batch — T2.7–T2.11 complete (tantra-ledger plan 0005)

Date: 2026-11-13. Executed the remaining T2 rows from `docs/task-list-tracks-and-phases.md`
(`tantra-ledger` settlement & statutory-fee consolidation; approved at the start of this
session, plan 0005 → Ready → Implemented):
- **T2.7** `ClearingCalendar::new()` is an empty weekend-only calendar — the hardcoded NSE
  2024–26 holiday table is gone (gap 0007). Decision recorded: `tantra-data` **owns** the
  NSE trading-holiday data (new upstream gap `tantra-data/docs/gaps/0015-*`, filed `5e873fe`);
  `tantra-runtime-backtest::NseTradingCalendar` is the **consumer & provider of
  `ClearingCalendar`** (injects via `with_holidays`).
- **T2.8** Per-lot corporate actions: `adjust_lot_for_split/bonus/demerger` +
  `reduce_lot_for_demerger` + `AccountState::apply_corporate_actions_to_lots` — positions are
  rebuilt as projections over the lot book, so FIFO `match_lots` realizes the correct per-lot
  cost basis after split/bonus/demerger (gap 0008).
- **T2.9** Per-segment (NFO/MCX/CDS) exchange turnover tables in
  `tantra-market-finance::india::costs::segments` (exact Decimal, from the researched
  circulars: NSE/FA/73061 eff. 2026-03-01, MCX/F&A/631/2024, NSE/FA/64232). `compute_charges`
  looks the segment rate up; the NSE cash-segment fallback is gone (gap 0009). `stt_charge`
  updated to the Finance Act 2026 rates (futures sell 0.05%, options sell 0.15% of premium).
  **Cross-repo dep added**: `tantra-ledger-journal` → `tantra-market-finance` (workspace dep).
- **T2.10** Golden contract-note framework now validates the **canonical** track:
  `GoldenTestRunner::compare_trade` calls `compute_charges`; the five sample fixtures were
  re-based onto the canonical track and the report passes at the 1-paise tolerance (gap 0010).
- **T2.11** OMS context canvas wired: `validate_order_against_context` (notional /
  configured qty / price collar vs `MarketData` / daily loss vs `PortfolioRiskState`),
  `OrderStateMachine::submit_order_with_context`, and a maintained `snapshot()` feeding
  `OmsSnapshot` (gap 0011).
- **Researched tariff data** (exchanges + top-5 discount-broker brokerage) captured in the
  plan appendix; the ledger's per-segment implementation pulls the exchange rates from
  `tantra-market-finance` instead of hardcoding them.
- Verification: ledger workspace **250+ tests green** (portfolio 47, journal 50, oms 38,
  allocation 32, performance 45, facade 4); `fmt --check` + `clippy -D warnings` clean on
  ledger + market; runtime-backtest + agent workspaces re-checked green; `grep Utc::now
  crates/*/src/` returns nothing; no production `src/` code calls the legacy fee track; no
  hardcoded holiday table remains in the domain crate. Commits: `tantra-ledger` `437e6af`,
  `tantra-market` `cbeb045`, `tantra-data` `5e873fe`. Gaps 0007–0011 + plan 0005 closed;
  indexes + task list updated (phase-1 open 8 → 3, total 79 → 74).

## Previous Batch — T2.1–T2.6 complete (tantra-ledger plans 0003–0004, gaps 0001–0006)

Collapsed per `.agents/rules/handoff-hygiene.md` (full detail in git history):
Date: 2026-11-13. HRP + Black-Litterman allocation objectives, exact bounded-simplex
projection, discrete whole-lot allocation, zero-clock `MetricsInput`, edge-score v2. Ledger
200 → 250 tests green; commits `tantra-ledger` `9f8ec22` + `f90f192`, `tantra-runtime`
`eee9d21`.

## Latest Batch — T1 track complete (tantra-risk plan 0002, gaps 0001–0004)

Date: 2026-11-13. Executed the full T1 track from `docs/task-list-tracks-and-phases.md`
(risk 0001–0004 → `tantra-risk/docs/plans/0002`):
- **T1.2 (High)** reduce-only now enforced on **every** check path: order-opening BUYs refused
  on `evaluate_core_checks` + `check_order_fast_checks` (`ReduceOnlyViolation`), modifies and
  new position sizing refused, reducing SELLs + cancels pass. `check_decision` +
  `validate_sizing_request` covered.
- **T1.1** `price_collar_bps` enforced on both paths (new `RiskRefusal::PriceCollarViolation`):
  market orders whose worst-case band-edge fill exceeds `reference ± collar` are refused.
- **T1.3** `check_order_fast` brought to parity: per-scrip OTR record-and-check before approval,
  warning-zone logging, cooldown auto-resume.
- **T1.4** `window_otr_1min/5min` now read `OtrConfig::{window_1min_ms, window_5min_ms}`; the
  engine enforces the configured short-term window (5-min stays analysis-only).
- **API change**: `check_order_fast` gains required `side: OrderSide` — FFI updated in lockstep
  (pyclass, codegen stub, `_tantra.pyi`, `test_risk.py` + new reduce-only test; `cargo check` green).
- **Decision recorded**: the reduce-only position-free approximation (SELL=reduce) and the
  two-layer contract with the runtime REST layer (ADR 0018 `state_refusal`) are documented in
  `docs/design/0002-reduce-only-contract.md` (root) and
  `tantra-risk/docs/design/code-reduce-only.md` — not just HANDOFF.
- TDD: 15 new tests in `tantra-risk/tests/plan0002_tests.rs`; all 80 tests green, clippy `-D warnings`
  clean, fmt clean. Commits: `tantra-risk` `9a0bc59` (impl), docs+indexes follow in the same repo.
  Gap docs 0001–0004 + plan 0002 retired to Closed/Implemented; workspace task list updated
  (phase-1 open count 18 → 14, total 89 → 85).

## Latest Batch — T0 track complete (crate-topology consolidation, plan 0003)

Date: 2026-11-13. Executed the full T0 track from `docs/task-list-tracks-and-phases.md`
(= root plan 0003 + agent plan 0008 + ffi gap 0002 + core plan 0002 Phase A):
- **T0.1** `tantra-market` 14→8 crates: deleted 7 stub crates (feed, loaders, zerodha, upstox,
  fyers, angelone, dhan); pruned market/runtime/agent/ffi `workspace.dependencies`. Gaps 0001/0002
  stay open as **feature trackers** for the real feeds (T3.3/T3.4).
- **T0.2** `tantra-runtime` 14→11 crates: deleted `tantra-indicators` dup + `runtime-market` +
  `test-utils` stubs; absorbed `tantra-runtime-feed` shim into new
  `tantra-runtime-api-rest::market_feed` module (25 src+test files re-pointed; `tantra-market-store`
  is now a direct dep of api-rest). `tantra-runtime-strategy` dev-deps pruned (unused).
- **T0.3** `tantra-exec-angelone` **decision: implement** (kept; real SmartAPI adapter tracked by
  exec plan 0002 / T4.11).
- **T0.4** Pinned the facade-crate convention (ADR in `docs/design/0001` §4.2); added facades
  `tantra-market`, `tantra-exec`, `tantra-runtime`, `tantra-ffi`, `tantra-ui` (thin re-export
  crates; added to each workspace members + deps).
- **T0.5** Removed runtime legacy honba aliases (`tantra-api(-rest)`, `tantra-backtest`,
  `tantra-actors`) + ffi unused `tantra-market-*` deps.
- **T0.6** All 9 Rust workspaces: `cargo check --workspace --profile prod` + `fmt --check` +
  `clippy -- -D warnings` green; `market` (243 tests + doctests) and `exec` (200+ tests) full
  `test --profile prod` green; agent `ref_store_tests` (4) + `verify_tests` (10) green; runtime
  api-rest `market_data` test binary compiles. **Known env limits (pre-existing):** runtime
  api-rest test-bin compile OOMs (SIGKILL) under the prod-LTO profile on this 15 GiB box —
  `check` + one test binary is the practical verification; `tantra-ffi-py` cdylib **link** fails
  with `rust-lld: unable to find library -lpython3.12` (only `libpython3.12.so.1.0` exists on
  this box, no dev symlink) — untouched by this batch, `cargo check` for the workspace is green.
- **T0.7** Phase A audit (plan 0002): **no 1:1 delegation sites** — `market-indicators` is
  streaming f64, `agent-analytics` f64 statistical; quant is Decimal-batch. Delegation matrix +
  verdict recorded in `tantra-core/docs/design/code-quant.md`; gap 0001 stays open as
  verify-on-future-work.
- **T0.8** Moved inline tests out of `ref_store.rs` + `verify/mod.rs` into
  `tests/ref_store_tests.rs` (new) + `tests/verify_tests.rs` (existing) — plan 0008 implemented.
- Cleanup per gap-tracking §4: deleted closed gap docs (root 0003/0004/0005/0007/0008,
  ffi 0002, agent 0001) + plan docs (root 0003, agent 0008); updated all indexes + the task list.
  Plan 0003 recorded in root `docs/plans/README.md` Implemented. No Python changes.

## Previous Batch — consolidated track/phase task list

Date: 2026-11-13. Created `docs/task-list-tracks-and-phases.md`: a single execution-ordered
task list derived from the live per-repo `docs/{plans,gaps}/README.md` indexes — **89 open tasks
across 15 repos**, organized into 12 tracks (T0 topology/hygiene → T11 docs) and 7 phases
(Phase 0 topology → Phase 6 UI/docs), with per-row links to the governing plan/gap, statuses,
and dependency/blocking edges. Source of truth remains the per-repo indexes; the task list is a
derived view that must be updated in the same change as any index cleanup. Linked from
`docs/plans/README.md` (Related). No code changes.

## Previous Batch — re-write `tantra-runtime`/`tantra-ui` docs (dismantle roadmap into design/gaps/plans)

Date: 2026-11-13. Dismantled `docs/roadmap/` in both repos and re-wrote
`docs/{design,gaps,plans}` to reflect the source code (same pattern as the
`tantra-risk`/`tantra-strategies`/`tantra-ledger`/`tantra-market`/`tantra-ffi` batches):
- `tantra-runtime`: `roadmap.md` + `migration-verification.md` removed → new
  `docs/design/implementation-record.md` (migration M1–M3 + subsequent landings table).
  `architecture.md` §5 gaps/plans snapshot corrected to source: plan 0003 (trade-journal +
  market-reference REST endpoints) is **implemented** (all routes registered in `v1.rs`;
  market-reference handlers serve sample stores pending the `tantra-data` → Rust FFI bridge) —
  moved to Implemented, doc removed per gap-tracking rule §4; gaps index gained previously-missing
  gap 0005; gap 0007 item 7 corrected to `ContentReader::filings` method name (chat tool is
  `filings_search`); gap 0005 corrected 10→9 report routes. No code changes.
- `tantra-ui`: `roadmap.md` removed → `docs/design/implementation-record.md`; stale 20-line
  `architecture.md` rewritten source-verified (9-crate map; corrected the false "Leptos 0.8
  CSR app" / "REST+WS client" / "canvas rendering engine" claims — ui-app is feature-state
  models only, ui-client is an in-memory push bus, ui-charts is geometry-only); new per-crate
  `code-{cli,tui,highlight,ui-core,ui-app,ui-api-wasm,ui-charts,ui-client,ui-assets}.md` +
  `code-migration-map.md`. First four open gaps filed (0003 canned CLI reports, 0004 no view
  layer, 0005 TUI placeholder tabs/hardcoded watchlist, 0006 scan fixture universe). Plans
  README corrected (plan 0005 SHAs `2cda245`/`acdc137` no longer exist after the rename history
  rewrite; plan 0001 stale "blocked upstream" claim removed — Ask/Chat/Tui wired). No code
  changes. Committed per-repo. All gap claims source-verified at filing time.

## Previous Batch — platform rename to Tantra (plan 0004)

Date: 2026-11-12. Completed the full platform rename to `tantra` (org/repos/crates/
Python packages/docs) per plan 0004 (now closed, recorded Implemented in
`docs/plans/README.md`):
- All 14 submodules renamed (`crates/*`, package dirs, docs) and committed
  (`tantra-core` 54da11d → `tantra-examples` 792e4b8); root submodule paths, `.gitmodules`
  (URLs → `tantra-labs/tantra-*`), Makefile `REPOS`, and `scripts/create-remote-repos.sh`
  updated. `origin` remotes point at `tantra-labs` (root included).
- History identity rewritten: every commit authored/committed with the former AMD corporate
  email (`Premachandra.Mallappa@amd.com`) is now `Prem Mallappa <dev.prem.mallappa@gmail.com>`;
  root cause fixed — the `~/.config/git/config.amd` include previously overrode `user.email`
  (its `[user]` block was removed); global git `user.email` is `dev.prem.mallappa@gmail.com`.
- Gates: `make check` green on all 9 Rust workspaces; Rust/Python test suites NOT re-run to
  completion (env: `prod`-profile LTO test compiles OOM on 15 GiB box).
- Pre-existing, non-rename failures observed: agent `test_architectural_dependency_rules` R4
  (`tantra-agent-mcp` → `tantra-ledger-allocation`, from agent `28629d0`); runtime test-bin
  compiles OOM (SIGKILL). Both predate the rename.

## Previous Batch — re-write `tantra-risk`/`tantra-strategies` docs (dismantle roadmap into design/gaps/plans)

Date: 2026-11-12. Dismantled `docs/roadmap/` in both repos and re-wrote
`docs/{design,gaps,plans}` to reflect the source code (same pattern as the earlier
`tantra-ledger`/`tantra-ffi`/`tantra-market` batches):
- `tantra-risk`: rewritten `architecture.md` + all `code-*.md` design docs to match actual
  source (removed fake `algo_id` regex, fake `risk_refusals`/`risk_approvals`/`algo_halted`/
  `kill_switch_activated` metrics, non-existent `global_kill_switch()` method, and the
  `Emergency` tool hint). Created first-ever `docs/gaps/` (0001 `price_collar_bps` unenforced,
  0002 reduce-only not enforced, 0003 `check_order_fast` scrip-OTR/warning/cooldown divergence,
  0004 `OtrConfig` window knobs never read) + `docs/plans/0002-close-declared-unenforced-risk-controls.md`
  collecting them; `implementation-record.md` added; `roadmap/` removed.
- `tantra-strategies`: rewritten `architecture.md` + `code-{sdk,strategies,manifest,migration-map}.md`
  (dropped nonexistent `stop_loss()` helper, documented `on_tick` as an undispatched stub).
  Created first-ever `docs/gaps/` (0001 `on_tick` never dispatched, 0002 no live `StrategyContext`
  in-repo, 0003 catalog step.toml is declarative-only, 0004 no `BasketManifest` run loop, 0005
  `RiskBudget` is a Phase-1 simple cap) + `implementation-record.md`; `roadmap/` removed.
- `tantra-ledger`: already dismantled (commit `06df5ad`, 2026-11-12) — verified current, no changes.
- No code changes; committed per-repo. All gap claims source-verified (grep) at filing time.

## Prior batches (collapsed per `.agents/rules/handoff-hygiene.md`)

- **Resolve rebase conflicts (tantra-agent, tantra-data, tantra-adapters, tantra-market, 2026-11-12)**:
  agent plan renumbering to 0008/0009/0010 + data gaps 0013/0014; adapters rebased to `8d7c440` (plan 0002
  folded, gaps 0001–0007 refreshed); market `87ed5aa`; `pytest` green (adapters 44, data 86).
- **`tantra-ffi`/`tantra-market` docs (dismantle roadmap, 2026-11-12)**: per-module `code-*.md`
  design docs + first-ever `docs/gaps/` (market 0003/0004 cross-ref root gaps 0001/0002; ffi 0001 CLI
  subcommand stubs, 0002 unused `tantra-market-*` deps); `roadmap/` removed in both; committed per-repo.
- **Crate topology audit & consolidation docs (2026-11-12)**: root `docs/design/0001-crate-topology-audit-and-target.md`
  (72 → ~60 target), `docs/plans/0003-crate-topology-consolidation.md` (5-phase plan), `docs/gaps/0001`–`0008`
  (market broker WS stubs, feed/loaders stubs, runtime indicator duplicate, runtime-feed shim, runtime
  market/test-utils stubs, exec-angelone stub, facade-convention inconsistency, runtime legacy honba aliases).
- **Adapters documentation sync (tantra-adapters + tantra-docs, 2026-11-12)**:
  per-module design docs, gaps 0001–0007 refreshed; `tantra-docs` updated.

- **Plan 0006 Phase 4 (2026-11-12)** — `options_chain`/`corporate_actions` chat
  tools; research re-verified upstream first (`tantra-market` had no chain
  reader; `tantra-data` corporate-actions reader exists Python-side). Gaps
  filed before tool code: `tantra-market/docs/gaps/0001-options-chain-reader.md`,
  `tantra-data/docs/gaps/0008-corporate-actions-rust-bridge.md` + `0009`.
  Landed: `OptionContract`/`OptionsChain`/`CorporateAction` DTOs,
  `MarketReader::options_chain`/`corporate_actions`, 2 ReadOnly tools
  (catalogue **17 → 19**), honest `FeedMarketReader` stubs + seedable
  `RuntimeMarketReader` stores. **Plan 0006 complete (Phases 1–4)**, doc
  retired to agent `docs/plans/README.md` Implemented table; follow-on breadth
  under agent plan 0007. Commits: agent `127597d`+`a0817a6`, runtime `bcd1c76`,
  market `d4e3c76`, data `0bc5edd`. All gates re-verified 2026-11-12 (fmt /
  clippy `-D warnings` / `cargo test --workspace --profile prod` 0 failed /
  fresh `make prod` each).
- **Plan 0006 Phase 3 (2026-11-12)** — `news_search`/`filings_search` via new
  `ContentReader` port (catalogue 15 → 17); gaps `tantra-data/docs/gaps/0006`+`0007`
  filed. Commits: agent `98c66c2`, runtime `96e878f`, data `3ee4005`.
- **Plan 0006 Phases 1–2 (2026-11-11)** — `BlockDealsTool` (`MarketReader::block_deals`,
  honest runtime stub citing `tantra-data` gap 0005, runtime plan 0004 Phases 1–3)
  and `PriceAlertTool` CRUD (`AlertReader`/`AlertWriter`, `price_alert_list`/`price_alert`,
  `Profile.alerts` storage). Catalogue 14 → 15 read-only + 2 alert tools
  (agent `a72689c`, runtime `d54f140`).
- **Fincept/Quantcept gap-closure batch (2026-11-06)** — Layers 0–6 GREEN
  (per-layer table with commits in this file's git history; `tantra-core` 9ce4880,
  `tantra-ledger` b35a314, `tantra-risk` 5b00cda, `tantra-market` ddb5c3f+1983512,
  `tantra-exec` 2675c07+ed3a6b3, `tantra-strategies` 207a70c, `tantra-agent` 36b0d53/1f9fb13/
  51b024d/236f8eb/5470e7b, `tantra-ui` 2cda245+acdc137, `tantra-examples` 552c873,
  `tantra-docs` 1267490). Key decisions preserved: core enables rust_decimal `maths`;
  `BrokerEnumMap<T>` table-driven wire mapping (Layer 2); **crypto execution NO-GO** (fresh
  scope review required to revisit); Python adapters dev/research-only; forecast/panel compute
  f64-internal with exact-Decimal boundaries; duplicate `LlmProvider` in agent-core deleted in
  favor of `tantra-agent-llm`; 0004 Phase 4 local SLM deferred by design. Session also landed
  `tantra-ledger` plan 0002 (`tantra-ledger-performance`, 2a3a04e), `tantra-data` gaps
  0001+0002 (261d646), `tantra-runtime` plan 0003 (trade-journal + market-reference endpoints;
  sample stores pending the `tantra-data` → Rust FFI bridge).

## Prior work (collapsed per `.agents/rules/handoff-hygiene.md`)

- **Tier 0–6 repo migration** (`honba-*` → `tantra-*` submodules, incl. Tier 4 `tantra-ffi`'s
  codegen/PyO3/Arrow bridge/Python SDK): complete. Full per-tier detail (gate reports, slice
  tables, Tier-0-specific design notes) lived here until 2026-11-06; trimmed now that it's long
  superseded by Tiers 5–6 and this file's current "Latest Batch" above. See commits
  `feat(tier-0)` through `feat(tier-6)` in this repo's git log for the full record; the migration
  guide that used to be this file's "Playbook" pointer was retired in `4b5d9f9`.
- **Submodule updates (2026-11-09)**:
  - `tantra-examples`: All 9 stages (0–8) of `honba-examples` staged port landed (`docs/plans/0002` Implemented); full test suite (922 passed, 70 skipped), master index `examples/README.md`, and docs completed.
  - `tantra-runtime`: **PLAN-0001 complete (Stages 1–4)** — RunId/`FileJournalWriter`/recovery (`60a5bd9`), bounded worker pool with 429 backpressure + `FileJobRegistry` (approvals queue, fencing leases, budgets) + Vixie cron scheduler + broker dispatch behind the SEBI risk gate (`46817a0`); plan/gap docs retired (`4bd4ef5`). Remaining open: GAP-0003 (broker wire transports), PLAN-0002 (statistical gates).
  - `tantra-ui`: **PLAN-0001 Stage 4 CLI half landed** — `tantra jobs run/tick/logs` on the runtime pool + per-run journals (`tantra jobs add ... -> tick -> journal verified` acceptance suite, 11 e2e tests) + agent tool-call journals + approvals gating (`0b9241d`); clippy-driven fixups (breach-first refusal for PendingApproval jobs) follow-up. Open: ui-core trade rows (`tantra-ui/docs/gaps/0002`).

## Immediate Next Step
0. **EE+ (root plan 0005, proposed)** — implement in dependency order: T12.1 kernel domain
   types (`tantra-core` plan 0003) → T12.2 indicators (`tantra-market` gap 0005) → T12.3
   chain-snapshot lakehouse (`tantra-data` gap 0016) → T12.4 strategy + SDK
   (`tantra-strategies` plan 0001/gap 0006) → T12.5–T12.7 execution/risk/OMS (exec 0003,
   risk 0005, ledger 0012) → T12.8–T12.10 agent/UI/docs (agent 0011, ui 0006/gap 0007,
   docs 0003). See the T12 track in `docs/task-list-tracks-and-phases.md`.
1. Plan 0006 is complete (Phases 1–4); agent plan 0007 is the active follow-on master guide for
   future chat-tool/MCP-gateway breadth. The `options_chain` chat tool now reads real data via
   the wired `FeedMarketReader` chain reader (T3.1). Still open: `tantra-data/docs/gaps/0007`
   (filings Rust bridge) and `tantra-data/docs/gaps/0008`/`0009` (corporate actions) block the
   `filings_search`/`corporate_actions` tools from returning real data (honest
   `PortError::unavailable` today); `oi_buildup` (agent plan 0010) now has its data source
   (T3.2's `OpenInterestStore`/`BuildupAnalyzer`) but needs the chat tool itself.
2. T3.3 remaining: capture the Fyers v3 subscribe request from the official SDK and implement
   the `upstox`/`fyers`/`angelone` feed crates mirroring `dhan`/`zerodha`; live-verify the Dhan
   (and Kite) feeds against the Dhan credentials.
3. `tantra-data/docs/gaps/0015-nse-trading-holiday-provider.md` — wire the runtime
   `NseTradingCalendar` to tantra-data's holiday ingestion once it ships (the ledger's
   calendar is already data-driven).
4. T4 follow-ons (both Proposed, not approved): `tantra-adapters` plan 0003 (cross-repo
   integration Python ↔ Rust core) and plan 0004 (production hardening: rate limits, pooling,
   token refresh). The Python `Tick`/`subscribe_ticks` surface is ready to align with the Rust
   `tantra-market` feed contracts when 0003 is taken up.
5. Remaining per-repo follow-ups (non-blocking, tracked in each repo's HANDOFF / `docs/gaps/`):
   - **4B Phase 4 (local SLM)** — deferred by design; prerequisite is the Phase-3 golden fixture set accumulating via live OmniRoute runs (`TANTRA_WRITE_FIXTURES=1`), then model licensing/fine-tuning/quantization per `0005`.
   - **0001 Phase 1** (`tantra_search_tools`/`tantra_describe_tool` two-tier gateway) — the forecast engine is currently discoverable via `tools/list` only; once the gateway lands, add the `forecast` category to its category enum.
   - **`tantra-ui`** — Leptos view layer for `tantra-ui-app`, wire CLI `ask`/`scan` (gap `tantra-ui/docs/gaps/0001`), TUI `run()` event loop.
5. Layer 3's `BasketManifest` consumption lands in `tantra-runtime-backtest` (catalog.rs/engine.rs) as a separate future slice, per the plan's scope note.

## Operating Invariants
- Toolchain: `cargo 1.97.1` / `rustc 1.97.1`; edition 2024, `rust-version = "1.85"`.
- Zero inline `#[test]` / `#[cfg(test)]` in `src/**/*.rs` (Parallel Test Directory Rule, AGENTS.md §3.2).
- Wire compatibility: `Price`/`Quantity` remain string-encoded decimals (`serde-with-str`); `-0.00` parses to `Decimal::ZERO` semantics (not negative-strict), matching upstream rust_decimal behavior.
- `.agents/rules/subagent-discipline.md`, `.agents/rules/no-recon.md`, `.agents/rules/gap-tracking.md`, `.agents/rules/handoff-hygiene.md` are binding workspace-wide — see `AGENTS.md` §8–§10.
- Plan & Gap discipline: when implementing a plan or gap, any hardcoded/stubbed/sample data used requires filing a `docs/{plans,gaps}/XXXX-*.md` in the respective provider repo (gaps = individual features, plans = collections of gaps). When implemented, the document is cleaned up from active `docs/{plans,gaps}/` and recorded in the repo's index.
