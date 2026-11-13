# Workspace Task List — Tracks & Phases

Consolidated, execution-ordered task list for **all open gaps and active/proposed plans across
every Tantra repo**, grouped by **track** (thematic workstream) and **phase** (bottoms-up
execution order). Generated 2026-11-13 from the live per-repo indexes; the per-repo
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
| **2 — Data Lakehouse, Market Feeds & Disclosure** | Data ingestion + Rust bridges; real broker WS feeds & loaders | T5, T3 (feeds) | 11 |
| **3 — Execution & Broker Adapters** | Adapter contract parity, WS streaming, TOTP auth, Angel One executor | T4 | 2 |
| **4 — Agent & Runtime Applications** | MCP ecosystem, persistent memory, smart-money suite; REST/chat tooling | T6, T7 | 20 |
| **5 — Strategies & Python Wheel Surface** | Strategy lifecycle gaps; FFI CLI; example wheel-mirrors | T8, T9 | 14 |
| **6 — Workstations, UI & Docs** | Leptos view layer, TUI panels, CLI reports; docs reference | T10, T11 | 6 |
| **Total** | | | **67** |

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
| **T0.7** | ⏸ Delegate downstream return/vol math to `tantra_core::quant` — **Phase A audit done**: no 1:1 delegation sites (streaming f64 indicators / f64 statistical gates vs Decimal-batch quant); matrix in `tantra-core/docs/design/code-quant.md`; kept open as verify-on-future-work | `tantra-core` | 1 | Audit only | core 0001 (open, refined) |
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

## T4 — Broker Adapters & Execution · Phase 3 — ✅ T4.1–T4.8, T4.11 DONE 2026-11-13; T4.9/T4.10 Proposed

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

### Proposed plans
| Task | Work | Repo / Scope | Phase | Status | Plan |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T4.9** | Cross-Repo Integration: Python adapters ↔ Rust core (`market`/`exec`/`ledger`) | `tantra-adapters` | 3 | Proposed | adapters 0003 |
| **T4.10** | Production Hardening: transport & auth reliability | `tantra-adapters` | 3 | Proposed | adapters 0004 |

### Execution gateway
| Task | Work | Repo / Scope | Phase | Status | Gap |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T4.11** | ✅ Angel One SmartAPI 2.0 execution adapter (real broker ACL, `BrokerExecutor` + SmartStream order feed + `BrokerEnumMap` tables + exact-decimal payloads, 40 tests, clippy-clean) | `tantra-exec-angelone` | 3 | **Done** | exec 0001 = root 0006 (`2258bbb`) |

---

## T5 — Data Lakehouse & Ingestion · Phase 2

**Source**: [`tantra-data/docs/plans/README.md`](../tantra-data/docs/plans/README.md) (plans 0003–0006) ·
[`tantra-data/docs/gaps/README.md`](../tantra-data/docs/gaps/README.md)

### Calendar & reference data — plan 0003 (Open)
| Task | Work | Repo / Scope | Phase | Status | Gap |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T5.1** | Select the real economic-calendar vendor source (reader/port/store already exist) | `tantra-data` | 2 | Open | 0010 |
| **T5.2** | Replace stubbed calendar data with the real ingestion pipeline | `tantra-data` | 2 | Open | 0012 |

### Content & disclosure ingestion — plan 0004 (Open)
| Task | Work | Repo / Scope | Phase | Status | Gap / Blocks |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T5.3** | Block/bulk deal disclosure ingestion (source + port + reader) | `tantra-data` | 2 | Open | 0005 · blocks runtime T7.2, leg 3 of T6.12 |
| **T5.4** | News article ingestion (source + port + reader) | `tantra-data` | 2 | Open | 0006 · blocks chat `news_search` |

### Rust data bridge — plan 0005 (Open)
| Task | Work | Repo / Scope | Phase | Status | Gap / Blocks |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T5.5** | Filings `tantra-data` → Rust consumer bridge | `tantra-data` + `tantra-runtime`/`tantra-ffi` | 2 | Open | 0007 · blocks chat `filings_search` |
| **T5.6** | Corporate actions `tantra-data` → Rust consumer bridge | `tantra-data` + `tantra-runtime`/`tantra-ffi` | 2 | Open | 0008 · blocks chat `corporate_actions` |

### Lakehouse ingestion completeness — plan 0006 (Open)
| Task | Work | Repo / Scope | Phase | Status | Gap |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T5.7** | Seed `data/catalog/` via tantra-data's own ingestion pipeline (not ad-hoc copy) | `tantra-data` | 2 | Open | 0004 |
| **T5.8** | Corporate-actions DuckDB store automatic ingestion (not manual/test-seeded) | `tantra-data` | 2 | Open | 0009 |

### Ungrouped (needed by the smart-money suite)
| Task | Work | Repo / Scope | Phase | Status | Gap |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T5.9** | FII/DII daily institutional net-flow ingestion (no plan yet) | `tantra-data` | 2 | Open | 0013 · leg of T6.12 |
| **T5.10** | Delivery percentage / delivery-adjusted volume ingestion (no plan yet) | `tantra-data` | 2 | Open | 0014 · leg of T6.12 |

---

## T6 — Agent & MCP Ecosystem · Phase 4

**Source**: [`tantra-agent/docs/plans/README.md`](../tantra-agent/docs/plans/README.md) (plans 0007, 0009, 0010) ·
[`tantra-agent/docs/gaps/README.md`](../tantra-agent/docs/gaps/README.md)

### Plan 0009 — Persistent Memory, MCP Client Bridge & Phase E (Open)
| Task | Work | Repo / Scope | Phase | Status | Gap |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T6.1** | Persistent `UserMemory` with per-profile budgeters + recall renderers (Phase C) | `tantra-agent-core`, `tantra-agent-prompt` | 4 | Open | 0003 (Med) |
| **T6.2** | Prompt cache-hit/cache-miss regression tests (Phase C) | `tantra-agent-core`, `tantra-agent-prompt` | 4 | Open | 0007 (Low) |
| **T6.3** | Runtime↔agent monitor scheduler bridge via inverted ports (Phase D) | `tantra-runtime` + `tantra-agent` | 4 | Open | 0006 (Low) |
| **T6.4** | MCP stdio client bridge to external MCP servers (Phase E; = plan 0007 Ph 17) | `tantra-agent-mcp` | 4 | Open | 0004 (Med) |
| **T6.5** | `ResearchNote` in `tantra-agent-report` + research-loop integration + Typst/Markdown rendering (Phase E) | `tantra-agent-report`, `tantra-agent-research` | 4 | Open | 0005 (Low) |

### Plan 0007 — Comprehensive MCP Ecosystem Guide (Active; SSE/HTTP transport shipped)
| Task | Work | Repo / Scope | Phase | Status | Notes |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T6.6** | Track 1, Ph 1–3: MCP gateway quant engines (Monte Carlo, cointegration, walk-forward, factor; portfolio optimize; Black-Scholes/Greeks, GARCH) | `tantra-agent-mcp` | 4 | Open | Ph 2 uses T2.x; Ph 3 uses `tantra-market-pricing` |
| **T6.7** | Track 2, Ph 4–5: market depth / L2 & FII-DII flows; economic-calendar tool | `tantra-agent-chat-tools` | 4 | Open | Ph 4 flows ← T5.9; Ph 5 ← T5.1/5.2 |
| **T6.8** | Track 3, Ph 6–8: fundamentals & financial statements, mutual-fund analytics, IPO tracker | `tantra-agent-chat-tools` + `tantra-data` | 4 | Open | needs new data ingestion |
| **T6.9** | Track 4, Ph 9–11: HMM regimes, change points, copulas + permutation tests, MPO | `tantra-agent-analytics` + `tantra-ledger-allocation` | 4 | Open | — |
| **T6.10** | Track 5, Ph 12–14: safe trade-intent bridge + paper sandbox, strategy CRUD/community, tax reporting & ledger statements | agent + `tantra-runtime` + `tantra-strategies` + `tantra-ledger-journal` | 4 | Open | NoFX approval-queue pattern |
| **T6.11** | Track 6, Ph 15–17: `_jq` response filter (Ph 15), SSE/HTTP transport (Ph 16 **shipped**), stdio client (Ph 17 = T6.4) | `tantra-agent-core`, `tantra-agent-mcp` | 4 | Open | — |

### Plan 0010 — Institutional / Smart-Money Detection Suite (Proposed)
| Task | Work | Repo / Scope | Phase | Status | Depends on |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T6.12** | Composite signal (delivery-adjusted volume, shareholding/insider filings, block deals, OI buildup + FII/DII regime) over 3 new chat tools | `tantra-agent-chat-tools`, `tantra-runtime`, `tantra-strategies` | 4 | Proposed | T3.2, T5.3, T5.5, T5.9, T5.10 |

---

## T7 — Runtime REST API & Chat Tools · Phase 4

**Source**: [`tantra-runtime/docs/plans/0004`](../tantra-runtime/docs/plans/0004-block-bulk-deal-chat-tool-and-rest-endpoint.md) ·
[`tantra-runtime/docs/gaps/README.md`](../tantra-runtime/docs/gaps/README.md)

| Task | Work | Repo / Scope | Phase | Status | Gap / Depends |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T7.1** | Plan 0004 Ph 1–3: `block_deals` chat tool + wiring with honest `unavailable` stub — **done** | `tantra-runtime-api-rest` | 4 | In progress | — |
| **T7.2** | Plan 0004 Ph 4: wire block/bulk deals to real data | `tantra-runtime-api-rest` | 4 | Blocked | T5.3 (data 0005) |
| **T7.3** | Plan 0004 Ph 5 (optional): direct block/bulk-deal REST endpoint | `tantra-runtime-api-rest` | 4 | Open (optional) | T5.3 |
| **T7.4** | Profile schema: room for watchlists, portfolios, risk profiles, workspaces | `tantra-runtime-api::profile` | 4 | Open | 0004 |
| **T7.5** | OpenAPI 3.1 spec completeness, schema coverage, static artifact export | `tantra-runtime-api-rest::openapi` | 4 | Open | 0005 |
| **T7.6** | Chat agent session persistence + portfolio-backed tools (drop in-memory/store stubs) | `tantra-runtime-api-rest::chat` / `::state` | 4 | Open | 0006 |
| **T7.7** | Chat market/content readers: real last-price, volume, indicator/macro/news/filings/options-chain/corporate-actions sources | `tantra-runtime-api-rest::chat_market` / `::chat_content` | 4 | Open | 0007 (partly upstream T3.x/T5.x) |
| **T7.8** | Broker-adapter boundary: keep-or-lift `BrokerAdapter` sync sim port vs `BrokerExecutor` async wire port | `tantra-runtime-strategy::dispatch` | 4 | Open (documented decision) | 0008 |

---

## T8 — Strategies · Phase 5

**Source**: [`tantra-strategies/docs/gaps/README.md`](../tantra-strategies/docs/gaps/README.md) (intentionally ungrouped)

| Task | Work | Repo / Scope | Phase | Status | Gap |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T8.1** | Dispatch `Strategy.on_tick` (declared, never called) | `tantra-strategies` | 5 | Open | 0001 (Med) |
| **T8.2** | Live/feed-backed `StrategyContext` (only `SimulatedContext` exists) | `tantra-strategies` | 5 | Open | 0002 (**High**) |
| **T8.3** | In-repo executor for catalog `step.toml` (declarative-only today) | `tantra-strategies` | 5 | Open | 0003 (Med) |
| **T8.4** | `BasketManifest`-driven run loop | `tantra-strategies` (+ `tantra-runtime-backtest`) | 5 | Open | 0004 (Med) |
| **T8.5** | `RiskBudget` allocation optimizer (replace Phase-1 simple cap) | `tantra-strategies` | 5 | Open | 0005 (Low) |

---

## T9 — Python Wheel, FFI & Examples · Phase 0, 5

**Source**: [`tantra-ffi/docs/gaps/README.md`](../tantra-ffi/docs/gaps/README.md) ·
[`tantra-examples/docs/gaps/README.md`](../tantra-examples/docs/gaps/README.md)

| Task | Work | Repo / Scope | Phase | Status | Gap |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T9.1** | Implement `tantra` CLI `backtest`; make `serve`/`stub` real subcommands | `tantra-ffi` (`python/tantra/cli.py`) | 5 | Open | ffi 0001 |
| **T9.2** | ✅ Remove unused `tantra-market-{finance,feed,store}` workspace deps | `tantra-ffi` | 0 | **Done** | ffi 0002 (closed, part of T0.5) |
| **T9.3** | Wheel `algo_analytics` surface — mirror, delete once runtime enhancer / ffi ships it | `tantra-examples` → `tantra-runtime` / `tantra-ffi` | 5 | Open | ex 0001 |
| **T9.4** | Wheel AI-provider surface — mirror, delete once `tantra-agent` / ffi ships it | `tantra-examples` → `tantra-agent` / `tantra-ffi` | 5 | Open | ex 0002 |
| **T9.5** | `tantra-data` nav/loaders surface — mirror, delete once data ships it | `tantra-examples` → `tantra-data` | 5 | Open | ex 0003 |
| **T9.6** | Wheel display/universes/client surface — mirror, delete once ffi ships it | `tantra-examples` → `tantra-ffi` | 5 | Open | ex 0004 |
| **T9.7** | Freeze-slicer wheel surface — mirror, delete once exec / ffi ships it | `tantra-examples` → `tantra-exec` / `tantra-ffi` | 5 | Open | ex 0005 |
| **T9.8** | Wheel kernel-domain surface (166-file `_kernel/` mirror) — delete once ffi ships it | `tantra-examples` → `tantra-ffi` | 5 | Open | ex 0006 |
| **T9.9** | Adapters framework surface — mirror, delete once adapters / ffi ships it | `tantra-examples` → `tantra-adapters` / `tantra-ffi` | 5 | Open | ex 0007 |
| **T9.10** | Runtime session surface (`Tantra.backtest` raises `NotImplementedError`) — delete once runtime / ffi ships it | `tantra-examples` → `tantra-runtime` / `tantra-ffi` | 5 | Open | ex 0008 |

---

## T10 — UI / TUI / CLI · Phase 6

**Source**: [`tantra-ui/docs/gaps/README.md`](../tantra-ui/docs/gaps/README.md) ·
[`tantra-ui/docs/plans/README.md`](../tantra-ui/docs/plans/README.md)

| Task | Work | Repo / Scope | Phase | Status | Gap / Plan |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T10.1** | CLI `memory`/`plugin`/`skills`/`mcp`/`doctor`/`purge`/`health` — real reports, not canned strings | `tantra-cli` | 6 | Open | ui 0003 |
| **T10.2** | Leptos/CSR view layer for `tantra-ui-app` (feature-state models exist, no views) | `tantra-ui-app` | 6 | Open | ui 0004 |
| **T10.3** | TUI Watchlist real rows; Screener/Portfolio/Orders real panels (drop placeholders) | `tantra-tui` | 6 | Open | ui 0005 |
| **T10.4** | CLI `scan` against live `GET /screener/scan` (drop the 4-scrip fixture universe) | `tantra-cli` | 6 | Open | ui 0006 |
| **T10.5** | MCP gateway result-block rendering + client configs | `tantra-cli`, `tantra-tui` | 6 | Ready | ui plan 0003 |

---

## T11 — Documentation · Phase 6

**Source**: [`tantra-docs/docs/plans/README.md`](../tantra-docs/docs/plans/README.md)

| Task | Work | Repo / Scope | Phase | Status | Plan |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T11.1** | MCP quantitative gateway & 15-engine reference (`docs/mcp/`) | `tantra-docs` | 6 | Ready | docs 0001 |

---

## Per-repo summary

| Repo | Open gaps | Active / proposed plans | Tasks in this list |
| :--- | :---: | :--- | :--- |
| `tantra-labs` (root) | 3 (0001, 0002, 0006 — 0001/0002 feature trackers) | 0001 (umbrella) | T0.1–T0.6 ✅ |
| `tantra-core` | 1 (0001, audit done) | 0002 (Phase A done) | T0.7 ⏸ |
| `tantra-ledger` | 0 | — | T2.1–T2.11 ✅ |
| `tantra-risk` | 0 | 0002 (Implemented) | T1.1–T1.4 ✅ |
| `tantra-market` | 1 (0003, 2/5 broker feeds) | — | T3.1–T3.4 🔶 |
| `tantra-exec` | 0 (0001 closed) | 0002 (Phase 1 done) | T0.3 ✅, T4.11 ✅ |
| `tantra-runtime` | 5 (0004–0008) | 0004 | T0.2/T0.5 ✅, T7.1–T7.8 |
| `tantra-agent` | 5 (0003–0007) | 0007, 0009, 0010 | T0.8 ✅, T6.1–T6.12 |
| `tantra-ui` | 4 (0003–0006) | 0003 | T10.1–T10.5 |
| `tantra-adapters` | 0 | 0002 (Implemented), 0003, 0004 (Proposed) | T4.1–T4.10 ✅ |
| `tantra-data` | 10 (0004–0010, 0012–0014) | 0003, 0004, 0005, 0006 | T5.1–T5.10 |
| `tantra-strategies` | 5 (0001–0005) | — | T8.1–T8.5 |
| `tantra-examples` | 8 (0001–0008) | — | T9.3–T9.10 |
| `tantra-ffi` | 1 (0001) | — | T9.1, T9.2 ✅ |
| `tantra-docs` | — | 0001 | T11.1 |

> T0 track complete 2026-11-13 (plan 0003 Implemented): 11 crates removed/absorbed, 5 facades
> added, convention pinned, aliases pruned, TDD cleanup done, all workspaces verified. T0.7
> remains as an audit-recorded verify-on-future-work item (no 1:1 delegation sites exist).
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
> T4 track 2026-11-13: T4.1–T4.8 complete in `tantra-adapters` (`fcd94bc`, plan 0002
> Implemented — gaps 0001–0007 closed; 134 tests, ruff + mypy strict clean); T4.11 complete
> in `tantra-exec` (`2258bbb` — SmartAPI 2.0 `BrokerExecutor` + SmartStream order feed, 40
> tests, clippy-clean; gap 0001 closed). T4.9/T4.10 remain Proposed (adapters plans
> 0003/0004). `tantra-adapters` open gaps 7 → 0.

## Related

- [`docs/plans/README.md`](plans/README.md) — workspace plans index (source of truth for plans).
- [`docs/gaps/README.md`](gaps/README.md) — workspace gaps index (cross-repo stubs).
- [`docs/plans/0001-fincept-quantcepts-gap-closure-and-feature-roadmap.md`](plans/0001-fincept-quantcepts-gap-closure-and-feature-roadmap.md) — umbrella roadmap (Phases 1–6 vocabulary reused here).
- [`docs/future-work-bottoms-up-build-order.md`](future-work-bottoms-up-build-order.md) — historical bottoms-up build order for the Fincept/Quantcept batch (Layers 0–6 complete).
- `.agents/rules/gap-tracking.md` — binding filing/cleanup discipline.
