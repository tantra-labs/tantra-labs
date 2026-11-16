# Workspace Task List — Tracks & Phases

Consolidated, execution-ordered task list for **all open gaps and active/proposed plans across
every Tantra repo**, grouped by **track** (thematic workstream) and **phase** (bottoms-up
execution order). Generated 2026-11-14 from the live per-repo indexes; the per-repo
`docs/{plans,gaps}/README.md` tables remain the **source of truth**.

**How to use this file**
- Pick work by **phase** (dependency order) or by **track** (your subsystem).
- Every row links its governing plan/gap; read the doc before starting the task.
- When a gap/plan is implemented and cleaned up per `.agents/rules/gap-tracking.md`, update
  the owning repo's index **and** this file in the same change (move/close the row).

---

## Phase model (master execution order)

Aligned with the umbrella roadmap `docs/plans/0001` (Phases 1–6) plus a topology phase 0, and
with the dependency layering of `docs/future-work-bottoms-up-build-order.md`.

| Phase | Focus | Tracks | Task count |
| :--- | :--- | :--- | :--- |
| **0 — Topology & Hygiene Foundations** ✅ | Remove stub/duplicate crates, pin facade convention, TDD cleanup, kernel call-site consolidation | T0 | 8 — **complete 2026-11-13** |
| **1 — Domain Engines (Risk, Ledger, Market compute)** | Enforce declared risk controls; allocation/performance/settlement engines; options chain & OI | T1, T2, T3 (compute) | 1 |
| **2 — Data Lakehouse, Market Feeds & Disclosure** | Data ingestion + Rust bridges; real broker WS feeds | T5, T3 (feeds) | 2 |
| **3 — Execution & Broker Adapters** | Adapter contract parity, WS streaming, TOTP auth, Angel One executor; **paper exchange matching core (T14 P0)** | T4, T14 (P0) | 0 (+T14.1–T14.4) |
| **4 — Agent & Runtime Applications** | MCP ecosystem, persistent memory, smart-money suite; REST/chat tooling; **paper exchange runtime wiring + backtest unification (T14 P1)** | T6, T7, T14 (P1) | 5 (+T14.5–T14.9) |
| **5 — Strategies & Python Wheel Surface** | Strategy lifecycle gaps; FFI CLI; example wheel-mirrors; **Python SDK `tantra.paper` (T14 P2)**; **data provisioning library (T15.1–T15.4)** | T8, T9, T14 (P2), T15 | 6 (+T14.10–T14.11) |
| **6 — Workstations, UI & Docs** | Leptos view layer, TUI panels, CLI reports; docs reference; **CSR/WASM paper panel + docs (T14 P3/P4)**; **provisioning HTTP service (T15.5–T15.6)** | T10, T11, T14 (P3/P4), T15 | 0 (+T14.12–T14.15) |
| **Total** | | | **26** (+15 proposed T14 tasks) (+6 T15 tasks) |

> Status legend: **Open** (gap filed, no work started) · **Ready** (plan approved for
> implementation) · **In progress** (partially shipped) · **Proposed** (plan written, not
> approved/started) · **Blocked** (waiting on an upstream dependency listed in the row).

---

## T0 — Platform Topology & Codebase Hygiene · Phase 0–1 — ✅ COMPLETE 2026-11-13

**Source**: [`docs/plans/README.md`](plans/README.md) (plan 0003, Implemented) ·
[`docs/gaps/README.md`](gaps/README.md) · `tantra-core` plan 0002 · `tantra-agent` plan 0008 ·
`tantra-ffi` gap 0002

| Task | Work | Repo / Scope | Phase | Status | Gaps / Depends |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T0.1** | ✅ Remove `tantra-market` stub crates (`feed`, `loaders`, `zerodha`, `upstox`, `fyers`, `angelone`, `dhan`); traits stay in `core`, lakehouse in `store` | `tantra-market` | 0 | **Done** | root 0001, 0002 · market 0003, 0004 (now feature trackers for the real feeds, T3.3/T3.4) |
| **T0.2** | ✅ Delete `tantra-runtime/tantra-indicators` duplicate + `runtime-market`/`test-utils` stubs; absorb `runtime-feed` shim into `api-rest::market_feed` | `tantra-runtime` | 0 | **Done** | root 0003, 0004, 0005 (closed) |
| **T0.3** | ✅ `tantra-exec-angelone`: **decision = implement** (kept; real adapter now shipped, task T4.11) | `tantra-exec` | 0 | **Done** | root 0006 (closed 2026-11-13) |
| **T0.4** | ✅ Pin the facade-crate convention (ADR); add facades for market/exec/runtime/ffi/ui | all Rust workspaces | 0 | **Done** | root 0007 (closed) |
| **T0.5** | ✅ Remove legacy honba aliases from runtime `workspace.dependencies`; drop unused `tantra-market-*` deps in ffi | `tantra-runtime`, `tantra-ffi` | 0 | **Done** | root 0008 · ffi 0002 (closed) |
| **T0.6** | ✅ Full-workspace verification: 9 Rust repos `check --profile prod` / `fmt --check` / `clippy -D warnings`; `market` + `exec` full `test --profile prod` green (runtime test-binary compiles still OOM — pre-existing) | all Rust repos | 0 | **Done** | — |
| **T0.7** | ✅ Delegate downstream return/vol math to `tantra_core::quant` — **Phase A audit done (2026-11-13), closed 2026-11-14**: no 1:1 delegation sites (streaming f64 indicators / f64 statistical gates vs Decimal-batch quant); matrix + verdict in `tantra-core/docs/design/code-quant.md`; gap 0001 + plan 0002 closed on the audit decision — delegation revisited only if a new Decimal-bounded quant consumer appears | `tantra-core` | 1 | **Done** | core 0001, plan 0002 (closed 2026-11-14) |
| **T0.8** | ✅ Remove inline `#[cfg(test)]` blocks in agent `ref_store.rs` + `verify/mod.rs` → `tests/` (4 + 10 tests green) | `tantra-agent` | 0 | **Done** | agent 0001 (closed, plan 0008) |

---

## T1 — Regulatory Risk Gate · Phase 1 — ✅ COMPLETE 2026-11-13

**Source**: [`tantra-risk/docs/plans/README.md`](../tantra-risk/docs/plans/README.md) (plan 0002, Implemented) ·
[`tantra-risk/docs/gaps/README.md`](../tantra-risk/docs/gaps/README.md)

| Task | Work | Repo / Scope | Phase | Status | Gap |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T1.1** | ✅ Enforce market-order price collar (`price_collar_bps`) — both check paths refuse when the worst-case band-edge fill exceeds `reference ± collar` (`RiskRefusal::PriceCollarViolation`) | `tantra-risk` | 1 | **Done** | risk 0001 (Med, closed) |
| **T1.2** | ✅ Enforce reduce-only mode (`GlobalState::ReduceOnly`) in every check path — refuse order-opening BUYs / modifies / new sizing; allow reducing SELLs + cancels; `check_decision` + `validate_sizing_request` covered | `tantra-risk` | 1 | **Done** | risk 0002 (**High**, closed) |
| **T1.3** | ✅ `check_order_fast`: per-scrip OTR check, warning zone, and cooldown auto-resume parity with `check_order` (record-and-check before approval) | `tantra-risk` | 1 | **Done** | risk 0003 (Med, closed) |
| **T1.4** | ✅ Consult OTR window config knobs (`window_1min_ms` / `window_5min_ms`) — `window_otr_1min`/`5min` read `OtrConfig`; engine enforces the configured short-term window | `tantra-risk` | 1 | **Done** | risk 0004 (Low, closed) |

---

## T2 — Portfolio, Allocation & Performance · Phase 1 — ✅ COMPLETE (T2.1–T2.11) 2026-11-13

**Source**: [`tantra-ledger/docs/plans/README.md`](../tantra-ledger/docs/plans/README.md) (plans 0003–0005 Implemented) ·
[`tantra-ledger/docs/gaps/README.md`](../tantra-ledger/docs/gaps/README.md)

### Allocation engine — plan 0003 (Implemented)
| Task | Work | Repo / Scope | Phase | Status | Gap |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T2.1** | ✅ Implement `Hrp` allocation objective | `tantra-ledger-allocation` | 1 | **Done** | 0001 (Med, closed) |
| **T2.2** | ✅ Implement `BlackLitterman` allocation objective | `tantra-ledger-allocation` | 1 | **Done** | 0002 (Med, closed) |
| **T2.3** | ✅ Exact bound-constrained solve (replace clip-and-renormalize bound handling) | `tantra-ledger-allocation` | 1 | **Done** | 0003 (Low, closed) |
| **T2.4** | ✅ Discrete / whole-share allocation | `tantra-ledger-allocation` | 1 | **Done** | 0004 (Low, closed) |

### Performance journal — plan 0004 (Implemented)
| Task | Work | Repo / Scope | Phase | Status | Gap |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T2.5** | ✅ Remove `Utc::now()` from `MetricsInput::new` (temporal determinism, zero-clock) | `tantra-ledger-performance` + `tantra-runtime-api-rest` | 1 | **Done** | 0005 (**High**, closed) |
| **T2.6** | ✅ Replace v1 placeholder edge-score formula with the real metric | `tantra-ledger-performance` | 1 | **Done** | 0006 (Low, closed) |

### Settlement, corporate actions & fees — plan 0005 (Implemented)
| Task | Work | Repo / Scope | Phase | Status | Gap |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T2.7** | ✅ External clearing-calendar source — `ClearingCalendar::new()` is an empty weekend-only calendar (hardcoded NSE 2024–26 table removed); real holidays injected via `with_holidays` by `tantra-runtime-backtest::NseTradingCalendar` (data owner `tantra-data`, gap data 0015) | `tantra-ledger-portfolio` | 1 | **Done** | 0007 (Med, closed) |
| **T2.8** | ✅ Per-lot corporate-action cost-basis adjustment — `adjust_lot_for_split/bonus/demerger` + `AccountState::apply_corporate_actions_to_lots` (positions rebuilt as projections over the lot book) | `tantra-ledger-portfolio` | 1 | **Done** | 0008 (Med, closed) |
| **T2.9** | ✅ Per-segment fee tables for NFO/MCX/CDS — Decimal tables in `tantra-market-finance::india::costs::segments`; `compute_charges` looks the segment rate up (NSE fallback removed); STT updated to Finance Act 2026 rates | `tantra-ledger-journal` + `tantra-market-finance` | 1 | **Done** | 0009 (Med, closed) |
| **T2.10** | ✅ Golden contract-note framework on the canonical track — `GoldenTestRunner` switched onto `compute_charges`; fixtures re-based (passes at 1 paise) | `tantra-ledger-journal` | 1 | **Done** | 0010 (Low, closed) |
| **T2.11** | ✅ Wire OMS context types into validation — `validate_order_against_context` (notional / configured qty / price collar / daily loss), `submit_order_with_context`, maintained `OmsSnapshot` | `tantra-ledger-oms` | 1 | **Done** | 0011 (Med, closed) |

---

## T3 — Market Data & Options Infrastructure · Phase 1–2 — 🔶 T3.1/T3.2/T3.4 DONE 2026-11-13; T3.3 2/5

**Source**: [`tantra-market/docs/gaps/README.md`](../tantra-market/docs/gaps/README.md)

| Task | Work | Repo / Scope | Phase | Status | Gap / Blocks |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T3.1** | ✅ Options-chain enumeration/reader — `InstrumentMaster::list_chain` (by underlying, ordered expiry→strike→option type), `ChainReader` + `InstrumentChainReader` joining quotes + OI; wired into `FeedMarketReader::options_chain` | `tantra-market-store` / `-pricing` + runtime | 1 | **Done** | 0001 (closed) — unblocks chat `options_chain` |
| **T3.2** | ✅ OI time-series history & buildup classification — `OpenInterestStore` (in-memory + Parquet `{root}/open_interest/`, exact Decimal128), `classify_buildup` four-quadrant + `BuildupAnalyzer` | `tantra-market-store` | 1 | **Done** | 0002 (closed) — leg 4 of T6.12 |
| **T3.3** | 🔶 Real broker WS feeds — **2 of 5 shipped**: `tantra-market-dhan` (DhanHQ v2, `fb82571`) + `tantra-market-zerodha` (Kite 3, `ad79205`) real & tested; `upstox`/`fyers`/`angelone` re-added as real crates when their wire protocols are implemented | `tantra-market` | 2 | In progress | 0003 = root 0001 (2/5) |
| **T3.4** | ✅ Real `feed` / `loaders` — feed traits in `core`, lakehouse in `store`, real `MarketDataFeed` impls on top of core | `tantra-market` | 2 | **Done** | 0004 = root 0002 (closed) |

---

## T4 — Broker Adapters & Execution · Phase 3 — ✅ COMPLETE 2026-11-14 (T4.1–T4.11)

**Source**: [`tantra-adapters/docs/plans/README.md`](../tantra-adapters/docs/plans/README.md) (plan 0002 Implemented) ·
[`tantra-adapters/docs/gaps/README.md`](../tantra-adapters/docs/gaps/README.md) ·
[`tantra-exec/docs/plans/README.md`](../tantra-exec/docs/plans/README.md)

### Phase A — Contract-test parity
| Task | Work | Repo / Scope | Phase | Status | Gap |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T4.1** | ✅ Broker contract tests for angelone/upstox/fyers/kotak/iifl (mirror `test_dhan.py`; `MockTransport` canned payloads) | `tantra-adapters` | 3 | **Done** | 0001 (**High**, closed) |
| **T4.2** | ✅ `get_bars` returns real OHLCV history honoring `interval`/`days` (all 7 brokers) | `tantra-adapters` | 3 | **Done** | 0002 (**High**, closed) |
| **T4.3** | ✅ `cancel_order` parses the broker response into canonical `Order` (all 7 brokers) | `tantra-adapters` | 3 | **Done** | 0003 (Med, closed) |

### Phase B — Streaming & auth
| Task | Work | Repo / Scope | Phase | Status | Gap |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T4.4** | ✅ `WebSocketTransport` + `subscribe_ticks` per broker (canonical `Tick`, in-memory mock WS contract tests) | `tantra-adapters` | 3 | **Done** | 0004 (**High**, closed) |
| **T4.5** | ✅ TOTP headless auth (`auth.py`, RFC 6238 + per-broker `login()` flows, `SessionState` expiry) | `tantra-adapters` | 3 | **Done** | 0005 (Med, closed) |

### Phase C — Paper broker & configs
| Task | Work | Repo / Scope | Phase | Status | Gap |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T4.6** | ✅ `PaperBroker` order-book depth, partial fills, slippage, latency, rejection realism (defaults stay deterministic) | `tantra-adapters` | 3 | **Done** | 0006 (Low, closed) |
| **T4.7** | ✅ 5 missing `configs/*.toml` templates + `AdapterConfig.from_toml` loader + parse tests | `tantra-adapters` | 3 | **Done** | 0007 (Low, closed) |

### Phase D — Improvements (plan 0002)
| Task | Work | Repo / Scope | Phase | Status | Gap |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T4.8** | ✅ Public-API exports, typed `MockTransportError`, Protocol-typed `inner`, `client_order_id` idempotency, per-broker margin contract tests | `tantra-adapters` | 3 | **Done** | plan 0002 Ph D (implemented) |

### Plans 0003/0004 (Implemented)
| Task | Work | Repo / Scope | Phase | Status | Plan |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T4.9** | ✅ Cross-Repo Integration: Python adapters ↔ Rust core — canonical Python ↔ Rust serde JSON contract mapping (`Tick`/`Bar`/`OrderRequest`/`OrderAck`/`CancelRequest`), `docs/design/code-rust-contract-alignment.md`, deterministic golden canonical replay (`tests/test_canonical_fixture_replay.py`); live routing stays Rust-owned per plan 0001 | `tantra-adapters` | 3 | **Done** | adapters 0003 (Implemented, `4fda74e`) |
| **T4.10** | ✅ Production Hardening: transport & auth reliability — `RetryTransport` 429 backoff + per-URL mock sequences, `PooledHttpTransport` keep-alive + `TCP_NODELAY` (2.40×), `SessionState` refresh-before-expiry + 401-refresh-retry, redacted call-summary logging, fuzz (0 crashes, no float leakage); pytest 134 → 173, mypy strict clean | `tantra-adapters` | 3 | **Done** | adapters 0004 (Implemented) |

### Execution gateway
| Task | Work | Repo / Scope | Phase | Status | Gap |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T4.11** | ✅ Angel One SmartAPI 2.0 execution adapter (real broker ACL, `BrokerExecutor` + SmartStream order feed + `BrokerEnumMap` tables + exact-decimal payloads, 40 tests, clippy-clean) | `tantra-exec-angelone` | 3 | **Done** | exec 0001 = root 0006 (`2258bbb`) |

---

## T5 — Data Lakehouse & Ingestion · Phase 2 — ✅ COMPLETE 2026-11-13

**Source**: [`tantra-data/docs/plans/README.md`](../tantra-data/docs/plans/README.md) (plans 0003–0006, all Implemented) ·
[`tantra-data/docs/gaps/README.md`](../tantra-data/docs/gaps/README.md) (gaps 0004–0010, 0012–0014 closed)

### Calendar & reference data — plan 0003 (Implemented)
| Task | Work | Repo / Scope | Phase | Status | Gap |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T5.1** | ✅ Vendor selected: Forex Factory weekly JSON feed (verified live `nfs.faireconomy.media/ff_calendar_thisweek.json`) | `tantra-data` | 2 | **Done** | 0010 (closed) |
| **T5.2** | ✅ Real calendar ingestion: `providers/forex_factory.py` + `cli/ingest_calendar.py` + `default_calendar_rows()` live-with-stub-fallback | `tantra-data` | 2 | **Done** | 0012 (closed) |

### Content & disclosure ingestion — plan 0004 (Implemented)
| Task | Work | Repo / Scope | Phase | Status | Gap / Blocks |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T5.3** | ✅ Block/bulk deal disclosure ingestion — `BlockDeal` domain, NSE `block.csv`/`bulk.csv` provider + fetcher, `DuckDbBlockDealsStore`, `PythonBlockDealsReader` | `tantra-data` | 2 | **Done** | 0005 (closed) — unblocks runtime T7.2 |
| **T5.4** | ✅ News article ingestion — `NewsArticle` domain, Moneycontrol RSS provider + fetcher, `DuckDbNewsStore`, `PythonNewsReader` | `tantra-data` | 2 | **Done** | 0006 (closed) — unblocks chat `news_search` |

### Rust data bridge — plan 0005 (Implemented)
| Task | Work | Repo / Scope | Phase | Status | Gap / Blocks |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T5.5** | ✅ Filings bridge — `FilingsProjectionReader` (`tantra-market-store` `b040f68`) + `FeedContentReader::with_filings`/`ChatRuntime::from_env(data_root)` (`tantra-runtime` `db60aaa`) | `tantra-data` + `tantra-market-store` + `tantra-runtime` | 2 | **Done** | 0007 (closed) — unblocks chat `filings_search` |
| **T5.6** | ✅ Corporate-actions bridge — `CorporateActionsProjectionReader` + `FeedMarketReader::with_corporate_actions` | `tantra-data` + `tantra-market-store` + `tantra-runtime` | 2 | **Done** | 0008 (closed) — unblocks chat `corporate_actions` |

### Lakehouse ingestion completeness — plan 0006 (Implemented)
| Task | Work | Repo / Scope | Phase | Status | Gap |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T5.7** | ✅ Catalog seeded via own pipeline — `cli/ingest_catalog.py` bhavcopy backfill; `providers/bhavcopy.py` tolerates the live NSE header | `tantra-data` | 2 | **Done** | 0004 (closed) |
| **T5.8** | ✅ Corporate-actions ingestion — NSE `corporates-corporateActions` JSON provider → `Split`/`Bonus`/`Dividend`/`Rights` through `DuckDbCorporateActionsStore` | `tantra-data` | 2 | **Done** | 0009 (closed) |

### Ungrouped (needed by the smart-money suite)
| Task | Work | Repo / Scope | Phase | Status | Gap |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T5.9** | ✅ FII/DII daily institutional net-flow ingestion — `InstitutionalFlow` domain, NSE `fiidiiTradeReact` provider, `DuckDbInstitutionalFlowStore`, `PythonInstitutionalFlowReader` | `tantra-data` | 2 | **Done** | 0013 (closed) · leg of T6.12 |
| **T5.10** | ✅ Delivery % / delivery-adjusted volume ingestion — `DeliveryRecord` domain, bhavcopy delivery-column provider (live + legacy headers), `DuckDbDeliveryStore`, `PythonDeliveryReader` | `tantra-data` | 2 | **Done** | 0014 (closed) · leg of T6.12 |

---

## T6 — Agent & MCP Ecosystem · Phase 4 — ✅ T6.1–T6.12 COMPLETE 2026-11-14

**Source**: [`tantra-agent/docs/plans/README.md`](../tantra-agent/docs/plans/README.md) (plans 0007, 0010 Implemented; **plan 0009 Implemented**) ·
[`tantra-agent/docs/gaps/README.md`](../tantra-agent/docs/gaps/README.md) (**gaps 0003–0008 closed, none open**)

### Plan 0009 — Persistent Memory, MCP Client Bridge & Phase E (Implemented)
| Task | Work | Repo / Scope | Phase | Status | Gap |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T6.1** | ✅ Persistent `UserMemory` with per-profile budgeters + recall renderers — `tantra-agent::memory::user::UserMemory` (per-profile `ProfileBudget` map, recall `profile_section`/`recall_section`/`assemble` via `tantra-agent-prompt` renderers) | `tantra-agent`, `tantra-agent-prompt` | 4 | **Done** | 0003 (Med, closed) |
| **T6.2** | ✅ Prompt cache-hit/cache-miss regression tests — `prompt_cache_tests.rs` (agent-core, KV-prefix stability) + `renderer_cache_tests.rs` (agent-prompt, section placement/stability) | `tantra-agent-core`, `tantra-agent-prompt` | 4 | **Done** | 0007 (Low, closed) |
| **T6.3** | ✅ Runtime↔agent monitor scheduler bridge via inverted ports — `tantra-runtime-persistence::monitor::MonitorSchedulerBridge` over the agent `JobScheduler`/`JobStore` ports (6 tests) | `tantra-runtime` + `tantra-agent` | 4 | **Done** | 0006 (Low, closed) |
| **T6.4** | ✅ MCP stdio client bridge — `tantra-agent-mcp::client::{McpClient, McpClientError}` + `mcp_stdio_server` bin; process-spawned `tests/client_tests.rs` (initialize/list_tools/call_tool/RPC-error/shutdown) | `tantra-agent-mcp` | 4 | **Done** | 0004 (Med, closed) |
| **T6.5** | ✅ `ResearchNote` in `tantra-agent-report` (`NoteVerdict` + Typst/Markdown rendering) + research-loop integration (`research_note_from_verification`) | `tantra-agent-report`, `tantra-agent-research` | 4 | **Done** | 0005 (Low, closed) |

### Plan 0007 — Comprehensive MCP Ecosystem Guide (Active; Tracks 1/2/4 + Ph 15–17 shipped)
| Task | Work | Repo / Scope | Phase | Status | Notes |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T6.6** | ✅ Track 1, Ph 1–3: MCP gateway quant engines — `tantra_monte_carlo`/`tantra_cointegration`/`tantra_walk_forward`/`tantra_factor_attribution`/`tantra_portfolio_optimize`/`tantra_price_derivatives`/`tantra_garch_volatility` registered + dispatched (verified shipped, commit `28629d0`) | `tantra-agent-mcp` | 4 | **Done** | Ph 2 uses T2.x; Ph 3 uses `tantra-market-pricing` |
| **T6.7** | ✅ Track 2, Ph 4–5: market depth / L2 & FII-DII flows; economic-calendar tool — `market_depth`/`institutional_flows` (MarketReader port methods) + `economic_calendar` (new `CalendarReader` port), catalogue 19→22; honest `PortError::unavailable` stubs citing market 0006 / data 0017 / data 0018; `FeedCalendarReader` + `FeedMarketReader` wired | `tantra-agent-chat-tools` + `tantra-runtime` | 4 | **Done** | Ph 4 flows ← T5.9; Ph 5 ← T5.1/5.2 |
| **T6.8** | ✅ Track 3, Ph 6–8 tool surface: fundamentals & financial statements (`FundamentalReader` port + `fundamental_ratios`/`financial_statements` tools), mutual-fund analytics (`FundReader` + `fund_search`/`fund_holdings`), IPO tracker (`IpoReader` + `ipo_calendar`/`ipo_subscription`) — catalogue 22→30, honest `PortError::unavailable` stubs citing new `tantra-data` gaps 0020–0022; runtime `FeedFundamentalReader`/`FeedFundReader`/`FeedIpoReader` adapters; **data ingestion tracked by gaps 0020–0022** | `tantra-agent-chat-tools` + `tantra-data` | 4 | **Done** (tool surface) | needs new data ingestion (gaps 0020–0022) |
| **T6.9** | ✅ Track 4, Ph 9–11: HMM regimes, change points, copulas + permutation tests, MPO — `regime/hmm.rs` (Baum-Welch + Viterbi), `changepoint.rs` (CUSUM + structural break), `copula.rs` (Clayton/Gumbel + seeded joint VaR), `validation::permutation_test_*`; MPO in `tantra-ledger-allocation`; MCP tools `tantra_detect_regimes`/`tantra_change_point`/`tantra_copula_tail_risk`/`tantra_permutation_test`/`tantra_multi_period_optimize` (49 analytics + 56 mcp tests green) | `tantra-agent-analytics` + `tantra-agent-mcp` + `tantra-ledger-allocation` | 4 | **Done** | — |
| **T6.10** | ✅ Track 5, Ph 12–14 tool surface: safe trade-intent bridge (`TradeIntentSink` port + `propose_trade` LocalWrite tool formulating a closed `Decision::PlaceOrder`, NoFX approval-queue pattern), strategy CRUD (`StrategyStore` port + `strategy_manage` LocalWrite tool), tax reporting & ledger statements (`TaxReportReader` port + pure `compute_capital_gains` STCG 20% / LTCG 12.5% over ₹1.25L exemption + `tax_report`/`ledger_statement` tools with markdown statements) — catalogue 30→32 + 2 LocalWrite trade tools, honest `PortError::unavailable` stubs citing runtime gap 0007 items 17–19; **deep wiring tracked by runtime gap 0007 items 17–19** (FileJobRegistry approval queue, strategy store, matched-lot bridge) | agent + `tantra-runtime` + `tantra-strategies` + `tantra-ledger-journal` | 4 | **Done** (tool surface + tax math) | NoFX approval-queue pattern |
| **T6.11** | ✅ Track 6, Ph 15–17: `_jq` response filter (`serde_json_path`, Ph 15) + stdio client (Ph 17 = T6.4); Ph 16 SSE/HTTP transport shipped earlier | `tantra-agent-core`, `tantra-agent-mcp` | 4 | **Done** | — |

### Plan 0010 — Institutional / Smart-Money Detection Suite (Implemented)
| Task | Work | Repo / Scope | Phase | Status | Depends on |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T6.12** | ✅ All 5 phases — `institutional_flows` (shipped T6.7); `delivery_analysis` + `oi_buildup` chat tools (`DeliveryBar`/`OiBuildupSnapshot` DTOs + `MarketReader::delivery_stats`/`oi_buildup`, catalogue 22→24, honest `PortError::unavailable` stubs citing new `tantra-data` gap 0019 + runtime gap 0007 item 12); runtime wiring (`FeedMarketReader` stubs + seedable `RuntimeMarketReader` setters/reads + tests); composite-signal strategy `CompositeSignalStrategy` + pure `compute_composite_signal` in `tantra-strategies` (14 tests). Real-data wiring remains tracked by `tantra-data` 0017/0019, `tantra-market` 0006, runtime gap 0007 item 13 | `tantra-agent-chat-tools`, `tantra-runtime`, `tantra-strategies` | 4 | **Done** | T3.2, T5.3, T5.5, T5.9, T5.10 (all done) |

---

## T7 — Runtime REST API & Chat Tools · Phase 4 — ✅ T7.1–T7.8 + gap 0007 (all 19 items) DONE 2026-11-14

**Source**: [`tantra-runtime/docs/plans/0004`](../tantra-runtime/docs/plans/0004-block-bulk-deal-chat-tool-and-rest-endpoint.md) (Implement 2026-11-14 — plan 0004 **Implemented**) ·
[`tantra-runtime/docs/gaps/README.md`](../tantra-runtime/docs/gaps/README.md)

| Task | Work | Repo / Scope | Phase | Status | Gap / Depends |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T7.1** | ✅ Plan 0004 Ph 1–3: `block_deals` chat tool + wiring with honest `unavailable` stub | `tantra-runtime-api-rest` | 4 | **Done** | — |
| **T7.2** | ✅ Plan 0004 Ph 4: block/bulk deals wired to real data — `tantra-data` `export_block_deals` + CLI, `tantra-market-store::BlockDealsProjectionReader`, `FeedMarketReader::with_block_deals` real read | `tantra-runtime-api-rest` + `tantra-market-store` + `tantra-data` | 4 | **Done** | T5.3 (data 0005) — unblocked 2026-11-14 |
| **T7.3** | ✅ Plan 0004 Ph 5: direct `GET /market-data/block-deals` REST endpoint | `tantra-runtime-api-rest` | 4 | **Done** | T5.3 |
| **T7.4** | ✅ Profile schema: `watchlists` → `Watchlist {name, instrument_ids}` + `portfolios`/`risk_profiles`/`workspaces` + limits | `tantra-runtime-api::profile` | 4 | **Done** | 0004 (closed) |
| **T7.5** | ✅ OpenAPI 3.1 spec completeness (all v1 routes), schema coverage, static artifact export, conformance test | `tantra-runtime-api-rest::openapi` | 4 | **Done** | 0005 (closed) |
| **T7.6** | ✅ Chat session persistence via `SqlxSessionStore` (`933c53a`); portfolio-backed tools wired — `SharedLedger` handle in `AppState` (design decision recorded in `docs/design/code-shared-ledger.md`), `LedgerPortfolioReader` from the real order/fill flow, `StubPortfolioReader` removed | `tantra-runtime-api-rest::chat` / `::state` | 4 | **Done** | 0006 (closed) |
| **T7.7** | ✅ Chat market/content readers — **all items closed** (1–5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19: last-price/volume plumbing, indicators, macro_series, display-name, regime+risk-metrics, block_deals/news/options_chain/corporate_actions/L2 market_depth/institutional_flows/delivery_stats/oi_buildup/fundamentals/mutual-funds/IPO/trade-intent/strategy-store/tax); gap 0007 closed 2026-11-14 (fund *holdings* stay unsourced — documented, never fabricated) | `tantra-runtime-api-rest::chat_market` / `::chat_content` | 4 | **Done** | 0007 (closed) |
| **T7.8** | ✅ Broker-adapter boundary: option 1 "keep `BrokerAdapter` as sim port" recorded in gap 0008 + code-strategy.md §8.2 | `tantra-runtime-strategy::dispatch` | 4 | **Done** (documented decision; closes when option 2 lands) | 0008 |

---

## T8 — Strategies · Phase 5 — ✅ COMPLETE 2026-11-14

**Source**: [`tantra-strategies/docs/gaps/README.md`](../tantra-strategies/docs/gaps/README.md) (intentionally ungrouped)

| Task | Work | Repo / Scope | Phase | Status | Gap |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T8.1** | ✅ Dispatch `Strategy.on_tick` — canonical `Tick` model, `Strategy.run_ticks` / `SimulatedContext.run_ticks` (feed_tick + outbox drain, same deterministic clock as bars), duck-typed drive loop | `tantra-strategies` | 5 | **Done** | 0001 (Med, closed) |
| **T8.2** | ✅ Live/feed-backed `StrategyContext` — `LiveContext` in `sdk/live.py` over `MarketDataFeed`/`ExecutionGateway` protocol seams (Rust canonical traits owned by `tantra-market`/`tantra-exec`), sim/live parity tests | `tantra-strategies` | 5 | **Done** | 0002 (**High**, closed) |
| **T8.3** | ✅ In-repo executor for catalog `step.toml` — `tools/run_step.py` runs every step through `SimulatedContext` on a deterministic bar series (runnable + deterministic), CLI smoke tests | `tantra-strategies` | 5 | **Done** | 0003 (Med, closed) |
| **T8.4** | ✅ `BasketManifest`-driven run loop — `basket_run.run_basket`: `resolve_manifest` → `instantiate()` → `SimulatedContext` under the optimized capital slice, `RiskBudgetViolation` on breach | `tantra-strategies` (+ `tantra-runtime-backtest`) | 5 | **Done** | 0004 (Med, closed) |
| **T8.5** | ✅ `RiskBudget` allocation optimizer — `optimize_allocations` cap math (`max_position_fraction` total + per-member, `max_loss` bounds deployment); full `tantra-ledger-allocation` objective remains cross-repo | `tantra-strategies` | 5 | **Done** | 0005 (Low, closed) |

---

## T9 — Python Wheel, FFI & Examples · Phase 0, 5

**Source**: [`tantra-ffi/docs/gaps/README.md`](../tantra-ffi/docs/gaps/README.md) ·
[`tantra-examples/docs/gaps/README.md`](../tantra-examples/docs/gaps/README.md)

| Task | Work | Repo / Scope | Phase | Status | Gap |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T9.1** | ✅ Real `tantra` CLI `backtest` — bars-JSON fixture → `tantra.strategy.run(...)`, optional `--strategy MODULE:CLASS` + built-in SMA-cross default, `--algo-id`; `serve`/`stub` placeholders **removed** (no serving surface exists; gap-tracking §4); 7 CLI tests | `tantra-ffi` (`python/tantra/cli.py`) | 5 | **Done** | ffi 0001 (closed) |
| **T9.2** | ✅ Remove unused `tantra-market-{finance,feed,store}` workspace deps | `tantra-ffi` | 0 | **Done** | ffi 0002 (closed, part of T0.5) |
| **T9.3** | ✅ Wheel `algo_analytics` surface — `tantra.algo_analytics` + `tantra.quant` + `tantra.optimizer` shipped in the wheel; `optimizer/algo_analytics/` + `quant.py` mirrors **deleted**, all consumers retargeted | `tantra-examples` → `tantra-ffi` | 5 | **Done** | ex 0001 (closed) |
| **T9.4** | ✅ Wheel AI-provider surface — `tantra.ai` (ask/decision/knowledge/llm.provider) shipped; `_kernel/ai/` + `fake_llm.py` + `decision_guard.py` mirrors **deleted**, consumers retargeted; 4 design-only scripts un-skipped; `nl_support.py` retained as screener harness | `tantra-examples` → `tantra-ffi` | 5 | **Done** | ex 0002 (closed) |
| **T9.5** | ✅ `tantra-data` nav/loaders surface — `tantra_data.loaders.{amfi,nse,yfinance}` + `domain.quantity` shipped; wheel `tantra.screener` (catalog/coverage) shipped; `_kernel/data/`+`_kernel/screener/`+`amfi.py`+`bhavcopy.py` mirrors **deleted**, consumers retargeted (offline `VYAAPAAR_DATA_DIR` seam kept — real catalog absent from CI) | `tantra-examples` → `tantra-data` / `tantra-ffi` | 5 | **Done** | ex 0003 (closed) |
| **T9.6** | ✅ Wheel display/universes/client surface — `tantra.display` + `tantra.markets.india` (costs/settlement) + `tantra.markets.india.universes` + `tantra.cli.data` shipped; `display_style.py`/`universe_lists.py`/`pipeline/io.py` + `_kernel/markets/india/` + `_kernel/cli/` mirrors **deleted**, consumers retargeted; `tantra.client` (REST) deferred as a separate future surface | `tantra-examples` → `tantra-ffi` | 5 | **Done** | ex 0004 (closed) |
| **T9.7** | ✅ Freeze-slicer wheel surface — `tantra.sizing` freeze-slicing (`freeze_limit_qty`/`slice_order`/`verify_slices`); `options/__init__.py` mirror **removed**, consumers retargeted | `tantra-examples` → `tantra-ffi` | 5 | **Done** | ex 0005 (closed) |
| **T9.8** | ✅ Wheel kernel-domain surface (166-file `_kernel/` mirror) — **CLOSED**: Decimal-canonical domain core (`tantra.{money,position,trade,instrument,entities}`) + `bar`/`tick`/`order`/`order_state`/`execution`/`indicators` (74)/`declarative`/`portfolio_strategy`/`wire`/`store`/`coverage`/`backtest` sims + `base`/`context` shipped in the wheel; every `_kernel.*` consumer retargeted, mirror deleted | `tantra-examples` → `tantra-ffi` | 5 | **Done** | ex 0006 (closed) |
| **T9.9** | ✅ Adapters framework surface — wheel `tantra.adapters` shipped (registry/capabilities/contract/`FakeAdapter`/session/rate-limit/secrets); `_kernel/adapters/` (13 modules) **deleted**, 18 consumers retargeted | `tantra-examples` → `tantra-ffi` | 5 | **Done** | ex 0007 (closed) |
| **T9.10** | ✅ Runtime session surface — wheel `tantra.backtest.session` (`Tantra.backtest`: next-open fills, NSE delivery costs, T+1 settlement); `algo_analytics` (walk-forward/Monte-Carlo/plateau) retargeted + default wheel-session runner; `_kernel/session.py` stub **deleted** (the `NotImplementedError` branch is gone) | `tantra-examples` → `tantra-ffi` | 5 | **Done** | ex 0008 (closed) |

---

## T10 — UI / TUI / CLI · Phase 6 — ✅ COMPLETE 2026-11-15

**Source**: [`tantra-ui/docs/gaps/README.md`](../tantra-ui/docs/gaps/README.md) ·
[`tantra-ui/docs/plans/README.md`](../tantra-ui/docs/plans/README.md) (plan 0003 **Implemented**)

| Task | Work | Repo / Scope | Phase | Status | Gap / Plan |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T10.1** | ✅ Real reports for CLI `memory`/`plugin`/`skills`/`mcp`/`doctor`/`purge`/`health` — real on-disk `~/.tantra` stores (`memory_store.rs` JSONL journal, plugin/skills/mcp dirs), doctor env checks, purge real-path listing, factual health report; hermetic `*_with_home` variants + 13 tests | `tantra-cli` | 6 | **Done** | ui 0003 (closed) |
| **T10.2** | ✅ Leptos 0.8 CSR view layer — `tantra-ui-app/src/web.rs` renders all 8 `AppRoute` views from feature-state models (pure `view_model` helpers, `mount_app`); WASM invariant green (pre-existing `tantra-ui-core` wasm `std::fs` break fixed); 12 view tests | `tantra-ui-app` | 6 | **Done** | ui 0004 (closed) |
| **T10.3** | ✅ TUI real panels — `LiveData` + pure `ClientEvent` fold (`live_data.rs`), real Watchlist/Screener/Portfolio/Orders rendering over `TuiApp.live` with honest empty-states + `TuiApp::publish` feed seam; 10 tests | `tantra-tui` | 6 | **Done** | ui 0005 (closed) |
| **T10.4** | ✅ CLI `scan --server` against live `GET /screener/scan` — `ScreenerQuery`/`ScreenerResponse` wire types, canonical filter serialization, `reqwest`; fixture = offline fallback only; integration test boots an in-memory `tantra-runtime-api-rest` router | `tantra-cli` | 6 | **Done** | ui 0006 (closed) |
| **T10.5** | ✅ MCP gateway result-block rendering + client configs (plan 0003, all 4 phases) — `block_render.rs` ANSI Table/MetricGrid/Chart/Alert renderer, `tantra tools search\|describe\|call` (wired to `tantra-agent-mcp` `McpServer`), `tantra mcp config --client <claude-code\|cursor\|vscode\|gemini>` (via `ManifestGenerator`), `ResultBlockWidget` ratatui widget; 8 new tests | `tantra-cli`, `tantra-tui` | 6 | **Done** | ui plan 0003 (Implemented) |

---

## T11 — Documentation · Phase 6 — ✅ COMPLETE 2026-11-15 (T11.1, T11.2)

**Source**: [`tantra-docs/docs/plans/README.md`](../tantra-docs/docs/plans/README.md) (plans 0001 + 0003 Implemented)

| Task | Work | Repo / Scope | Phase | Status | Plan |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T11.1** | ✅ MCP quantitative gateway & 15-engine reference — `docs/ai/mcp_gateway.md` overhauled into the complete 22-tool gateway reference (stdio + SSE/HTTP transports, Two-Tier Gateway Discovery `tantra_search_tools`/`tantra_describe_tool`/`tantra_read_result`, `_jq` filter, corrected: no `tantra_call_tool`); 16 toolset pages (`docs/ai/toolsets/` — all 15 engines: market/technicals/scanner/analytics/validation/allocation/risk/regimes/volatility/ledger/calc/research/backtest/forecast/derivatives); 4 client guides (`docs/ai/clients/{claude_code,cursor,vs_code,gemini}.md`); `docs/ai/result_protocol.md` (`tantra/result/v1` envelope + `DisplayBlock`); `docs/ai/personas.md` (9 personas); `docs/getting-started/mcp.md` quickstart; `docs/llms.txt`; nav + indexes wired; `mkdocs build --strict` green | `tantra-docs` | 6 | **Done** | docs 0001 (Implemented) |
| **T11.2** | ✅ EE+ strategy user guide — `docs/strategies/elephant-edge/` (index + overview/level-map/signals/stops-positioning/studio) grounded in the research basis + shipped SDK (`Level`/`LevelMap`/`OptionsSnapshot`/`StrategySignal`/`StopProtection`/`StopUpdate`, gap 0006), with honest status banners: strategy engine / Studio / `level_map`+`oi_walls` chat tools documented as **planned** citing strategies 0001 / ui 0006 / agent 0011; snippets use only shipped tested SDK models | `tantra-docs` | 6 | **Done** | docs 0003 (Implemented) |

---

## T12 — Elephant Edge (EE+) Intraday Strategy Platform · Phase 5–6

**Source**: [`docs/plans/0005-elephant-edge-strategy-platform.md`](plans/0005-elephant-edge-strategy-platform.md) (master plan) · research basis [`docs/research/elephant-edge-strategy.md`](research/elephant-edge-strategy.md)

| Task | Work | Repo / Scope | Phase | Status | Gap / Plan |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T12.1** | Kernel domain types — level map, options positioning, gamma, stop protection, signals (zero-I/O, Decimal) | `tantra-core` | 5 | Proposed | core plan 0003 / gap 0002 |
| **T12.2** | Elephant-zone / OI-wall / gamma / Order-Block streaming indicators | `tantra-market` | 5 | Proposed | market 0005 |
| **T12.3** | Intraday option-chain snapshot lakehouse + point-in-time GEX series | `tantra-data` | 5 | Proposed | data 0016 |
| **T12.4** | EE+ strategy: level-map fusion, confluence scoring, signals, SL/TSL, positioning — **SDK prerequisite shipped (gap 0006)**: `stop_loss`/`trail_stop`/`on_stop_update` + `level_map()`/`options_snapshot()` context surface; the strategy itself remains (needs core 0003 / market 0005 / data 0016) | `tantra-strategies` | 5 | Proposed | strategies plan 0001 (gap 0006 closed 2026-11-14) |
| **T12.5** | Bracket-order (SL/target/TSL) execution contract + trailing runner | `tantra-exec` | 5 | Proposed | exec 0003 |
| **T12.6** | Stop-protection risk validation (mandatory SL, SL band, no-widening TSL) | `tantra-risk` | 5 | Proposed | risk 0005 |
| **T12.7** | Bracket-order OMS lifecycle (SL/TSL child orders, stop-trigger close) | `tantra-ledger` | 5 | Proposed | ledger 0012 |
| **T12.8** | `level_map` / `oi_walls` ReadOnly chat tools | `tantra-agent` | 4–5 | Proposed | agent plan 0011 |
| **T12.9** | EE+ Strategy Studio — level map, signal/SL/TSL lines, positioning (web/TUI/CLI) | `tantra-ui` | 6 | Proposed | ui plan 0006 / gap 0007 |
| **T12.10** | ✅ EE+ user guide + worked example — `docs/strategies/elephant-edge/` guide completed with `reference.md` (full parameter reference, declarative `Parameter` + catalog-style `config.toml` configuration example, illustrative worked session walk-through using only the shipped gap-0006 SDK models); nav + index + cross-links wired; `mkdocs build --strict` green. The guide's "planned" banners for the strategy engine (T12.4), Studio (T12.9), and `level_map`/`oi_walls` chat tools (T12.8) remain until those land in their own repos | `tantra-docs` | 6 | **Done** | docs 0003 (Implemented) |

---

## T13 — Dismantle the `_kernel` shared harness · Phase 5 — ✅ COMPLETE 2026-11-16 (T13.1–T13.7)

**Source**: [root plan 0006](plans/0006-dismantle-kernel-harness.md) (master, **Implemented**) ·
[`tantra-ffi/docs/plans/0002-*.md`](../tantra-ffi/docs/plans/0002-tantra-wheel-domain-harness-surface.md)
(Thrust A, **Implemented**) · [`tantra-examples/docs/plans/0003-*.md`](../tantra-examples/docs/plans/0003-tantra-examples-harness-dismantle.md)
(Thrust B, **Implemented**)

Clean-architecture + tantra-philosophy cleanup: with all 8 `_kernel` mirror gaps closed, the
`_kernel/` package is pure residue. The 6 domain/math modules were lifted into the wheel
(consolidation over duplication, AGENTS §4.1), then the remaining app-harness was renamed out of
`_kernel`. **Implemented 2026-11-16.**

| Task | Work | Repo / Scope | Phase | Status | Gap / Plan |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T13.1** | ✅ Wheel `tantra.portfolio` — `Account`/`Portfolio` promoted (verbatim, Decimal); `_kernel/portfolio.py` deleted; facade re-export dropped (zero external consumers) | `tantra-ffi` → `tantra-examples` | 5 | **Done** | ffi plan 0002 (A1) |
| **T13.2** | ✅ Wheel `tantra.risk` — pure-Python pre-trade checks (`check_state`/`check_order`/`limits_from_config` + audit records + `_native_attr` probe, same lazy-native contract); `_kernel/risk.py` deleted; `runner.py` retargeted | `tantra-ffi` → `tantra-examples` | 5 | **Done** | ffi plan 0002 (A2) |
| **T13.3** | ✅ Wheel `tantra.options` — `bs_greeks`/`bs_price` + `OptionKind`/`OptionStyle`/`OptionChain`/`OptionContract`/`Greeks`/`implied_volatility` (greeks+option merged); `_kernel/{greeks,option}.py` deleted; options examples 01–08 retargeted | `tantra-ffi` → `tantra-examples` | 5 | **Done** | ffi plan 0002 (A3) |
| **T13.4** | ✅ Wheel `tantra.metrics` — `extract_metrics_from_bars` (+ screener predicate evaluation); `_kernel/evaluator.py` deleted; `screening/nl_support.py` retargeted | `tantra-ffi` → `tantra-examples` | 5 | **Done** | ffi plan 0002 (A4) |
| **T13.5** | ✅ Wheel `tantra.calendar` — `ist_midnight_ns` + IST helpers (`IST`/`SessionWindow`/`MarketCalendar`/`NseCalendar`); `_kernel/calendar.py` deleted; `ports.py` retargeted | `tantra-ffi` → `tantra-examples` | 5 | **Done** | ffi plan 0002 (A5) |
| **T13.6** | ✅ Harness rename — `tantra_examples/_kernel/` → `tantra_examples/harness/` (config/loader/log/manifest/ports/runner/service/testing + rewritten facade exposing only harness names); all `_kernel.*` import sites retargeted (~60); `_kernel/` deleted; docs sweep (architecture/code-migration-map/cascade/READMEs/HANDOFF) | `tantra-examples` | 5 | **Done** | ex plan 0003 (B) |
| **T13.7** | ✅ Gate + follow-on — wheel 480 passed; examples `tests/unit` 909 passed / 51 skipped, **zero new failures** (6 `test_06_multi_broker_dispatch` failures pre-existing/environmental — installed `tantra_adapters` entry points bypass the example's paper fallback; reproduce on pre-T13 `1d89fd9`); ruff check + format clean; 6 example import-smokes pass; follow-on candidates recorded (`runner`→wheel session, `service`→tantra_data, `testing.replay`→wheel helper, `fills_equity_curve` Decimal end-to-end) | `tantra-ffi` + `tantra-examples` | 5 | **Done** | ex plan 0003 (C) |

---

## T14 — Paper Trading Exchange (real-exchange mimic) · Phase 3–6

**Source**: [root plan 0007](plans/0007-paper-trading-exchange.md) (master) ·
[`tantra-exec/docs/plans/0003-*.md`](../tantra-exec/docs/plans/0003-paper-exchange-matching-core.md)
(P0) · [`tantra-runtime/docs/plans/0005-*.md`](../tantra-runtime/docs/plans/0005-paper-exchange-runtime-wiring.md)
(P1/P2) · [`tantra-ffi/docs/plans/0003-*.md`](../tantra-ffi/docs/plans/0003-python-sdk-paper-exchange-embedding.md)
(P2 SDK) · [`tantra-ui/docs/plans/0008-*.md`](../tantra-ui/docs/plans/0008-paper-exchange-csr-web-embedding.md)
(P3)

One exchange engine that mimics a real exchange (price-time priority book, order lifecycle,
partial fills, stop/IOC/GTD, both sides) and is the single fill engine behind strategies, REST,
backtest, the Python SDK, and CSR/WASM + web. Replaces the three divergent simulators
(`PaperAdapter` / `NextOpenSim` / backtest's private L2 book) with one `tantra-exec-paper`
engine (zero-I/O, Decimal, `wasm32`). **P0 (T14.1–T14.4) shipped 2026-11-16**; P1+ pending.

| Task | Work | Repo / Scope | Phase | Status | Gap / Plan |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T14.1** | ✅ Extract `sim/l2_book` + `sim/{latency,slippage,mis}` into new `tantra-exec-paper` (pure matching crate, `wasm32`), behavior-identical | `tantra-exec` | 3 | **Done 2026-11-16** | exec plan 0003 (E1) — `crates/tantra-exec-paper` (book/latency/slippage/mis ported verbatim; `ready_ts` made pub for parity) |
| **T14.2** | ✅ Order lifecycle + events: Working/Partial/Filled/Cancelled/Rejected/StopTriggered, submit/cancel/amend, both sides, Day/IOC/GTD, Market/Limit/StopLimit/StopMarket | `tantra-exec-paper` | 3 | **Done 2026-11-16** | exec plan 0003 (E2–E7) — `lifecycle.rs` (`OrderState`, `WorkingOrder`, `ExchangeEvent`, `ExchangeError`) + `PaperExchange::submit/cancel/amend`, IOC, GTD (`submit_order_gtd`), stop trigger |
| **T14.3** | ✅ Account isolation (cash/positions/orders per `AccountId`) + statutory fees + FIFO settlement | `tantra-exec-paper` | 3 | **Done 2026-11-16** | exec plan 0003 — `AccountState` per `AccountId`; fees via pluggable `FillCostFn` (default `ZeroFillCost`); real fee/FIFO tables injected by runtime wiring (P1, plan 0005 D1/D2 — recorded scoping decision) |
| **T14.4** | ✅ `PaperExchangeExecutor` implements `BrokerExecutor`; lift sync `BrokerAdapter` port into `tantra-exec-core` (**closes runtime gap 0008, option 2**); `test_identical_fills_paper_vs_backtest` | `tantra-exec` + `tantra-runtime` | 3 | **Done 2026-11-16** | runtime gap 0008 (closed), exec plan 0003 (E9) — `tantra-exec-core::sim::SimExecutionPort` lifted; `dispatch.rs::BrokerAdapter` is a re-export; `PaperExchangeExecutor` implements both ports; E9 parity test `tests/paper_parity_tests.rs` (4 tests, byte-identical fills) |
| **T14.5** | REST `/orders` on the exchange — replace `NextOpenSim`; limit/stop/short support; fills on market advance | `tantra-runtime-api-rest` | 4 | Proposed | runtime plan 0005 (R1–R3, R7) |
| **T14.6** | Strategy dispatch — `PaperAdapter` becomes a thin driver over the exchange; zerodha/angelone sim-scaffolds delegate to the exchange | `tantra-runtime-strategy::dispatch` | 4 | Proposed | runtime plan 0005 (D2) |
| **T14.7** | `/ws/live` bidirectional push (orders/fills/depth/positions) | `tantra-runtime-api-rest::ws` | 4 | Proposed | runtime plan 0005 (R4) |
| **T14.8** | Backtest unification — backtester drives the exchange on historical bars; byte-identical fills vs paper (golden) | `tantra-runtime-backtest` | 4 | Proposed | runtime plan 0005 (R5) |
| **T14.9** | Standalone `paper serve` daemon (replay tape or live broker feed; NSE calendar + MIS 15:20) | `tantra-runtime-api-rest` / new bin | 4 | Proposed | runtime plan 0005 (R6) |
| **T14.10** | Python wheel `tantra.paper` — PyO3 `PaperExchange` binding, Arrow zero-copy, GIL released; `l2_sim` native backend replaces `NotImplementedError` | `tantra-ffi` | 5 | Proposed | ffi plan 0003 (P1–P5) |
| **T14.11** | Deterministic seeded `PaperSession` for examples; `tantra-examples` + `tantra-strategies` paper examples | `tantra-ffi` + `tantra-examples` + `tantra-strategies` | 5 | Proposed | ffi plan 0003 (P3) |
| **T14.12** | WASM bindings — `tantra-ui-api-wasm::paper` single-user in-browser session (same engine → same fills); `wasm32` check | `tantra-ui-api-wasm` | 6 | Proposed | ui plan 0008 (U1–U2) |
| **T14.13** | CSR `PaperPanel` in `tantra-ui-app` (embedded + server modes) + TUI paper panel on `/ws/live` + CLI `paper` session | `tantra-ui-app`, `tantra-tui`, `tantra-cli` | 6 | Proposed | ui plan 0008 (U3–U5) |
| **T14.14** | Golden-vector parity suite across backtest / paper / Python / WASM; prod-profile + clippy/fmt/ruff/mypy gates | all | 3–6 | Proposed | root plan 0007 (P4) |
| **T14.15** | Docs: paper-trading guide (CLI / REST / Python / web) | `tantra-docs` | 6 | Proposed | root plan 0007 (P4) |

---

## T15 — Data Provisioning Microservice (download / dummy / Monte-Carlo) · Phase 5–6

**Source**: [`tantra-examples/docs/plans/0004-*.md`](../tantra-examples/docs/plans/0004-data-provisioning-microservice-scope.md)
(master plan, **In progress — T15.1 shipped 2026-11-16**)

One provisioning path for the canonical data root (`$VYAAPAAR_DATA_DIR` layout) serving every
consumer — sim (`tantra.backtest.session`), analyser (`algo_analytics.walk_forward`), UI
(`tantra serve <data_dir>`), screeners, and the wheel store — with an interactive
download / dummy / Monte-Carlo choice (microservice, not a new CLI). Download delegates to the
owning tantra-data ingest CLIs; dummy is the fold of `synthetic_lakehouse.py` (one canonical
synthetic source); Monte-Carlo is seeded-reproducible or truly random.

| Task | Work | Repo / Scope | Phase | Status | Gap / Plan |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T15.1** | ✅ Milestone 1 — contract + layout + `provision` library: `tantra_examples/provision/` (layout constants + `Dataset`/`Mode`, `ProvisionRequest`/`ProvisionJob`, DECIMAL-canonical dummy generator, `openapi.json`); `tests/unit/synthetic_lakehouse.py` folded to a re-export shim; 23 new tests | `tantra-examples` | 5 | **Done 2026-11-16** | ex plan 0004 (M1) — suite 990 passed / 1 skipped, ruff + mypy clean |
| **T15.2** | Milestone 2 — dummy mode complete: fold conftest ad-hoc writers onto the provisioner; thin example seam prompting download/dummy/Monte-Carlo when a data root is absent | `tantra-examples` | 5 | In progress | ex plan 0004 (M2) |
| **T15.3** | Milestone 3 — Monte-Carlo mode: seeded (or truly-random) GBM/regime generator + fundamentals randomizer; golden/seed vectors for determinism | `tantra-examples` | 5 | Proposed | ex plan 0004 (M3) |
| **T15.4** | Milestone 4 — download mode: background job runner over `tantra_data.cli.ingest_*`; provider failures surface as terminal errors | `tantra-examples` + `tantra-data` | 5 | Proposed | ex plan 0004 (M4) |
| **T15.5** | Milestone 5 — HTTP microservice: background job store, progress, cancellation; thin client | `tantra-examples` | 6 | Proposed | ex plan 0004 (M5) |
| **T15.6** | Milestone 6 — example seam + redundant-generator cleanup | `tantra-examples` | 6 | Proposed | ex plan 0004 (M6) |

---

## Per-repo summary

| Repo | Open gaps | Active / proposed plans | Tasks in this list |
| :--- | :---: | :--- | :--- |
| `tantra-labs` (root) | 3 (0001, 0002, 0006 — 0001/0002 feature trackers) | 0001 (umbrella), **0005 (EE+ platform, proposed)**, **0006 (dismantle `_kernel` harness, Implemented 2026-11-16 — T13)**, **0007 (paper exchange, proposed — T14)** | T0.1–T0.6 ✅, T12.1–T12.10, T13.1–T13.7 ✅, T14.1–T14.15 |
| `tantra-core` | 1 (0002 EE+) | 0003 (EE+, proposed) | T0.7 ✅ (audit decision), T12.1 |
| `tantra-ledger` | 1 (0012 EE+) | — | T2.1–T2.11 ✅, T12.7 |
| `tantra-risk` | 1 (0005 EE+) | 0002 (Implemented) | T1.1–T1.4 ✅, T12.6 |
| `tantra-market` | 2 (0003, 0005 EE+) | — | T3.1–T3.4 🔶, T12.2 |
| `tantra-exec` | 1 (0003 EE+ bracket orders) | 0002 (Phase 1 done), **0003 (paper exchange core — P0 shipped 2026-11-16, T14)** | T0.3 ✅, T4.11 ✅, T12.5, T14.1–T14.4 ✅ |
| `tantra-runtime` | 0 (**0008 closed 2026-11-16** — sync port lifted) | 0004 (Implemented), **0005 (paper wiring + backtest unification, proposed — T14)** | T0.2/T0.5 ✅, T6.3 ✅, T7.1–T7.8 ✅, T14.5–T14.9 |
| `tantra-agent` | **0** (gaps 0003–0008 closed 2026-11-14) | 0007 (Active — all 6 tracks' tool surfaces shipped), 0010 (Implemented), 0011 (EE+, proposed) | T0.8 ✅, T6.1–T6.12 ✅, T12.8 |
| `tantra-ui` | 1 (0007 EE+) | 0003 (Implemented), 0006 (EE+, proposed), **0008 (paper exchange CSR/WASM, proposed — T14)** | T10.1–T10.5 ✅, T12.9, T14.12–T14.13 |
| `tantra-adapters` | 0 | 0002, 0003, 0004 (all Implemented) | T4.1–T4.10 ✅ |
| `tantra-data` | 2 (0015 holiday provider, 0016 EE+ option-chain snapshot) | 0003–0006, 0017–0019, 0020–0022 (Implemented) | T5.1–T5.10 ✅, T12.3 |
| `tantra-strategies` | **0** | 0001 (EE+, proposed) | T8.1–T8.5 ✅, T12.4 (SDK surface ✅), T14.11 |
| `tantra-examples` | **0** (all 8 closed: 0001–0008) | **0003 (harness dismantle, Implemented 2026-11-16 — T13)**, **0004 (data provisioning, In progress 2026-11-16 — T15)** | T9.1–T9.10 all ✅ (T9.4 ✅, T9.5 ✅, T9.6 ✅, T9.10 ✅), T13.6–T13.7 ✅, T14.11, T15.1 ✅ |
| `tantra-ffi` | **0** | **0002 (wheel domain-harness surfaces, Implemented 2026-11-16 — T13)**, **0003 (paper exchange Python SDK, proposed — T14)** | T9.1 ✅, T9.2 ✅, T13.1–T13.5 ✅, T14.10–T14.11 |
| `tantra-docs` | — | 0001, 0003 (both Implemented) | T11.1 ✅, T11.2 ✅, T12.10 ✅, T14.15 |

> T0 track complete 2026-11-13 (plan 0003 Implemented): 11 crates removed/absorbed, 5 facades
> added, convention pinned, aliases pruned, TDD cleanup done, all workspaces verified. T0.7
> closed 2026-11-14 on the audit decision — no 1:1 delegation sites exist (gap 0001 + plan
> 0002 closed; verdict in `tantra-core/docs/design/code-quant.md`).
>
> T2 track complete 2026-11-13 (`tantra-ledger` plans 0003–0005 Implemented): T2.1–T2.6
> (allocation + performance, commits `9f8ec22`/`f90f192`; runtime `eee9d21`) and T2.7–T2.11
> (settlement & statutory-fee consolidation, ledger `437e6af`, market-finance `cbeb045`,
> tantra-data gap 0015 filed `5e873fe`). `tantra-ledger` now has no open gaps or plans;
> phase-1 open count is 1 (T0.7-audit).
>
> T3 track 2026-11-13: T3.1 (options-chain reader) + T3.2 (OI stores & buildup) closed in
> `tantra-market` `b1b085e`, wired into the runtime chat adapter (`tantra-runtime` `39ff389`);
> T3.3 2 of 5 broker feeds real (`dhan` `fb82571`, `zerodha` `ad79205`); T3.4 (feed/loaders)
> closed. `tantra-market` open gaps 4 → 1 (0003).
>
> T4 track complete 2026-11-13/14: T4.1–T4.8 complete in `tantra-adapters` (`fcd94bc`, plan 0002
> Implemented — gaps 0001–0007 closed; 134 tests, ruff + mypy strict clean); T4.11 complete
> in `tantra-exec` (`2258bbb` — SmartAPI 2.0 `BrokerExecutor` + SmartStream order feed, 40
> tests, clippy-clean; gap 0001 closed). **T4.9/T4.10 landed 2026-11-14** (`4fda74e` + `0b9636e`;
> adapters plans 0003/0004 Implemented — cross-repo contract alignment + canonical replay,
> and production hardening: RetryTransport/pooling/token-refresh/observability/fuzz; pytest
> → 173, mypy strict clean). `tantra-adapters` open gaps 7 → 0; **T4 track complete.**
>
> T5 track complete 2026-11-13 (`tantra-data` plans 0003–0006 all Implemented; gaps
> 0004–0010 + 0012–0014 closed; commits `3a6b247`, `7af9a81`, `cd9fea6`, `3245b3b`;
> `tantra-market-store` `b040f68`; `tantra-runtime` `db60aaa`): T5.1/T5.2 calendar real
> ingestion (Forex Factory weekly JSON vendor, verified live), T5.3 block/bulk deals, T5.4
> news (Moneycontrol RSS), T5.5/T5.6 filings + corporate-actions → Rust bridge (parquet
> projection readers + runtime chat-adapter wiring, chat `filings_search`/
> `corporate_actions` unblocked), T5.7 catalog bhavcopy backfill, T5.8 corporate-actions
> ingestion, T5.9 FII/DII, T5.10 delivery %. 134 Python tests green; runtime
> check/fmt/clippy clean + 4 new projection tests; `tantra-data` open gaps 11 → 2.
>
> T6 track 2026-11-14 (agent plan 0009 **Implemented**, gaps 0003–0008 closed; ledger gap
> 0013 closed): T6.1/2 `UserMemory` + prompt cache-hit/miss tests (agent `7f9d480`); T6.3
> monitor scheduler bridge (runtime `634de2c`); T6.4 MCP stdio client + `mcp_stdio_server`
> bin; T6.11 Ph 15 `_jq` filter (`serde_json_path`); T6.5 `ResearchNote` + Typst/Markdown
> rendering (all in agent `7f9d480`); T6.9 Track-4 engines (HMM/changepoint/copula/
> permutation + MPO in `tantra-ledger-allocation` `126087f`; 5 MCP gateway tools, agent
> `95ec800`); T6.6 verified shipped; T6.7 Track-2 chat tools (`market_depth`/
> `institutional_flows`/`economic_calendar`, catalogue 19→22, `CalendarReader` port; agent
> `150bcae` + runtime `c0e3a27`) with honest `PortError::unavailable` stubs citing new
> upstream gaps market 0006 + data 0017/0018; **T6.12 (plan 0010 Implemented)**: `delivery_analysis`
> + `oi_buildup` tools (catalogue 22→24, DTOs + port methods, exact Decimal), runtime wiring
> + seedable adapter tests, composite-signal strategy in `tantra-strategies` (14 tests); new
> `tantra-data` gap 0019 (delivery Rust bridge). **T6.8 (Track 3 tool surface)**: fundamentals /
> mutual funds / IPO chat tools (catalogue 24→30) + runtime `FeedFundamentalReader`/
> `FeedFundReader`/`FeedIpoReader` stubs citing new `tantra-data` gaps 0020–0022; the data
> ingestion itself is tracked by those gaps. **T6.10 (Track 5 tool surface)**: trade-intent
> bridge + strategy CRUD + tax/statements tools (catalogue 30→32 + 2 LocalWrite trade tools),
> pure STCG/LTCG tax math, honest stubs citing runtime gap 0007 items 17–19; the deep wiring
> (FileJobRegistry approval queue, strategy store, matched-lot bridge) is tracked by those
> items. **T6 track complete.** Agent gaps open 5 → 0; phase-4 open 20 → 10 → 9 → 8 → 7;
> total 56 → 47 → 46 → 45 → 44.
>
> T7 track 2026-11-14 (runtime REST API & chat tools): T7.2/T7.3 block/bulk deals real data +
> `GET /market-data/block-deals` (plan 0004 Ph 4–5, Implemented); T7.4 profile schema (gap
> 0004 closed); T7.5 OpenAPI completeness + static artifact + conformance test (gap 0005
> closed); T7.6 chat session persistence via `SqlxSessionStore` (gap 0006 half-closed;
> portfolio tools remain); T7.7 items 6/7/13 closed (block_deals/news/oi_buildup); T7.8
> broker-boundary decision documented (gap 0008). `tantra-runtime` open gaps 5 → 3; phase-4
> open 7 → 5; total 44 → 42.
>
> T8 track 2026-11-14 (strategies; gaps 0001–0005 closed in `tantra-strategies` `5c2049d` +
> `a7dd055`): T8.1 tick dispatch (`Tick` + `Strategy.run_ticks`/`SimulatedContext.run_ticks`,
> duck-typed drive loop); T8.2 `LiveContext` over `MarketDataFeed`/`ExecutionGateway` seams
> (canonical Rust traits remain `tantra-market`/`tantra-exec`), sim/live parity tests; T8.3
> `tools/run_step.py` proves every catalog step runnable + deterministic; T8.4 basket run
> loop (`basket_run.run_basket` + `RiskBudgetViolation`); T8.5 `optimize_allocations`
> `RiskBudget` cap math (full `tantra-ledger-allocation` objective stays cross-repo). 31 new
> tests (164 total), ruff check + format clean, validate_catalog 10/10 + validate_manifests
> 3/3. `tantra-strategies` open gaps 6 → 1 (0006 EE+ SDK surface); phase-5 open 14 → 9;
> total 42 → 37.
>
> T9/T12-SDK batch 2026-11-14: **T9.1 closed** in `tantra-ffi` (`a9204a1` — real `backtest`
> CLI delegating to `tantra.strategy.run` with bars-JSON + optional `--strategy`/built-in
> SMA-cross default; `serve`/`stub` placeholders removed per gap-tracking §4; 7 CLI tests,
> 10 green with test_strategy). **`tantra-strategies` gap 0006 closed** (`53bd2e0`, plan 0001
> §7 — the EE+ SDK prerequisite): `sdk/stop_protection.py` (`StopProtection`/`TrailMode`/
> `StopUpdate`) + `sdk/levels.py` (`Level`/`LevelMap`/`StrategySignal`/`PositionIntent`/
> `OptionLeg`/`OptionsSnapshot`), `Strategy.stop_loss`/`trail_stop`/`on_stop_update`,
> `StrategyContext.level_map()`/`options_snapshot()` with seedable `SimulatedContext` stores
> and honest `LevelsUnavailable`/`OptionsUnavailable` degradation citing market 0005 /
> data 0016; 17 new tests (181 total), ruff clean, mypy at baseline. T9.3–T9.10
> (`tantra-examples` gaps 0001–0008) remain **open — blocked**: each "delete mirror once X
> ships" depends on an upstream wheel surface (`tantra-runtime` enhancer, `tantra-agent`,
> `tantra-data`, `tantra-exec` freeze slicer, `tantra-adapters`, `tantra-ffi` session
> orchestrator) that has not shipped. Phase-5 open 9 → 8; total 37 → 36.
>
> T9.3/T9.7 + T12-SDK-root batch 2026-11-15 ("all 8 starting at the root"; local commits,
> not pushed): **T9.3 + T9.7 closed** — the wheel shipped `tantra.algo_analytics` +
> `tantra.quant` + `tantra.optimizer` (ex 0001) and `tantra.sizing` freeze-slicing
> (ex 0005) in `tantra-ffi` `d79d31b` + `6ac14dd`; `tantra-examples` `4bc6c4f` **deleted the
> mirrors** (`optimizer/algo_analytics/` + `quant.py` + the `options/__init__.py` freeze
> block) and retargeted all consumers (04/05/10/12 walk-forward/monte-carlo/dsr, optimizer
> 01/02/03, options 06/07, stocksharp 02, flat 12/14/15, tests + docs); suite green except
> the pre-existing catalog-dependent `test_mutual_fund_screener_execution`; ruff clean.
> **T9.8 (ex 0006, the kernel-domain root) started**: Decimal-canonical domain-core slice
> (`tantra.{money,position,trade,instrument,entities}`) shipped in the wheel; the float
> kernel `bar`/`indicators`/`execution`/`portfolio_strategy`/`session`/`wire` remain as the
> next slices — the `_kernel` mirror is a dependency cascade (verified map in
> `tantra-examples/docs/design/gap-cascade-kernel-mirror.md`). ex 0002/0003/0004/0007/0008
> verified-blocked with per-doc blocker analysis. `tantra-examples` open gaps 8 → 6;
> phase-5 open 8 → 6; total 36 → 34.

> T10 track complete 2026-11-15 (tantra-ui commits `19b8acd` + `d60d840`): **T10.1** CLI
> `memory`/`plugin`/`skills`/`mcp`/`doctor`/`purge`/`health` real reports over on-disk
> `~/.tantra` stores (gaps 0003–0006 closed, plan 0003 Implemented); **T10.2** Leptos 0.8 CSR
> view layer for `tantra-ui-app` (8 `AppRoute` views; pre-existing wasm `std::fs` break in
> `tantra-ui-core` fixed — WASM check green); **T10.3** TUI real Watchlist/Screener/Portfolio/
> Orders panels via `LiveData` + pure `ClientEvent` fold; **T10.4** CLI `scan --server` live
> `GET /screener/scan` (fixture = offline fallback only); **T10.5** plan 0003 — `block_render.rs`
> ANSI result blocks, `tantra tools search|describe|call` (via `tantra-agent-mcp` `McpServer`),
> `tantra mcp config --client ...`, `ResultBlockWidget`. Verification: fmt + clippy `-D
> warnings` clean, all crate suites green (cli 79, tui 33, app 59, core 44, api-wasm 37,
> charts 33, assets 17, highlight 13, client 7), WASM check green, `make prod` green.
> `tantra-ui` open gaps 5 → 1 (0007 EE+ charts); phase-6 open 6 → 2; total 34 → 30.
> Known limitation: `cargo test --workspace` OOMs linking the `tantra-ui` facade's test
> binary under prod LTO (facade has no tests; run per-crate or `--workspace --exclude
> tantra-ui`).

> T13 track complete 2026-11-16 (root plan 0006 **Implemented**; `tantra-ffi` plan 0002 +
> `tantra-examples` plan 0003 Implemented): **Thrust A (T13.1–T13.5)** — wheel
> `tantra.portfolio`/`risk`/`options`/`metrics`/`calendar` shipped (ffi `9b354d5`/`3d5a1ac`/
> `f210c8a`/`119061a`; 52 new wheel tests, 480 suite passed); the six `_kernel` domain modules
> deleted and all consumers retargeted to the wheel (examples `25cb5df`). **Thrust B (T13.6)** —
> harness renamed `_kernel/` → `tantra_examples/harness/` (`1acabfb`), facade rewritten to expose
> only harness names, all ~60 `_kernel.*` import sites retargeted, `_kernel/` deleted repo-wide,
> docs swept (`3c2e5ae` + `80134a8`). **Gate (T13.7)** — wheel 480 passed; examples `tests/unit`
> 909 passed / 51 skipped with **zero new failures** (6 `test_06_multi_broker_dispatch` failures
> pre-existing/environmental — the installed `tantra_adapters` entry points bypass the example's
> paper-adapter fallback; reproduce identically on pre-T13 `1d89fd9`); ruff check + format clean;
> 6 example import-smokes pass. Follow-on consolidation candidates recorded in the plan
> (runner→wheel session, service→tantra_data, testing→wheel replay helper,
> `fills_equity_curve` Decimal end-to-end). `tantra-examples` + `tantra-ffi` open plans → 0/1
> (only ffi 0003 T14 remains); phase-5 open → 6 (all T14).
>
> T15 track started 2026-11-16 (tantra-examples plan 0004, data provisioning): **T15.1 shipped** —
> `tantra_examples/provision/` (canonical layout constants, `ProvisionRequest`/`ProvisionJob`
> contract, DECIMAL-canonical dummy lakehouse — the fold of `tests/unit/synthetic_lakehouse.py`,
> `openapi.json`); the old synthetic fixture is a re-export shim (one canonical synthetic source);
> consumer-coverage analysis recorded in the plan (sim/analyser/UI/screeners/wheel all read the
> same canonical root — zero consumer changes); 23 new tests; examples suite 990 passed / 1 skipped
> (967 baseline + 23; the skip is honest — `tantra_data.store.mutual_funds` gap 0023), ruff clean,
> mypy clean on the new package. T15.2–T15.6 pending (dummy seam → Monte-Carlo → download →
> HTTP service → example seam).

## Related

- [`docs/plans/README.md`](plans/README.md) — workspace plans index (source of truth for plans).
- [`docs/gaps/README.md`](gaps/README.md) — workspace gaps index (cross-repo stubs).
- [`docs/plans/0001-fincept-quantcepts-gap-closure-and-feature-roadmap.md`](plans/0001-fincept-quantcepts-gap-closure-and-feature-roadmap.md) — umbrella roadmap (Phases 1–6 vocabulary reused here).
- [`docs/future-work-bottoms-up-build-order.md`](future-work-bottoms-up-build-order.md) — historical bottoms-up build order for the Fincept/Quantcept batch (Layers 0–6 complete).
- `.agents/rules/gap-tracking.md` — binding filing/cleanup discipline.
