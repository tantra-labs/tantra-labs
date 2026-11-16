# 0010 — Screener Taxonomy, QVM Score, Alpha-Style Group Alerts & Screener MCP (Trendlyne-inspired, native)

**Status**: Proposed (revised 2026-11-16 after architectural review)

Research basis: [`docs/research/trendlyne-screener-alerts-mcp.md`](../research/trendlyne-screener-alerts-mcp.md).
Decision (2026-11-15): implement **natively**. Trendlyne is an idea source only; no Trendlyne
adapter, no dependency on its paid MCP server.

## 0. Executive Summary & Objective

Give every Tantra consumer (SDK strategies, examples, REST, Web UI, CLI/TUI, agents) one shared way to
**categorize** instruments (sector/industry hierarchy, market-cap bucket, index membership,
themes), **screen** them with a single converged DSL and a versioned preset catalog organized by
Trendlyne-style screen categories, **score** them with an open Quality/Value/Momentum (QVM)
composite, and **alert** with an Alpha-Alerts-grade system combining **multi-universe stateful screen
edges** and **event-driven filing/deal/corporate-action feeds** with **live push + hourly/daily
digest batching** — editable from both MCP/chat and the Web UI. Expose all screening/alerting to
LLM agents as MCP tools that scan the full market, which Trendlyne's MCP cannot do.

## 1. Context & Gaps Covered

The pieces Tantra has today don't fit together:
- **Four divergent screener DSLs** exist across the workspace: [`tantra-core/src/screener.rs`](../../tantra-core/src/screener.rs) (flat `predicates`/`match_all`, no nesting, no crossing ops), [`tantra-runtime-api/src/screener.rs`](../../tantra-runtime/crates/tantra-runtime-api/src/screener.rs) (recursive `operator`/`items`, stringly ops, no `tantra_core::screener` import), [`tantra-ffi/python/tantra/wire/screener.py`](../../tantra-ffi/python/tantra/wire/screener.py) (13 ops with `neq`, different `ScreenerScanRequest`), and [`tantra-market-indicators/src/screener.rs`](../../tantra-market/crates/tantra-market-indicators/src/screener.rs) (uses `f64`).
- Python `ScreenQuery`/`VectorizedScreener` only reads candle columns; `tantra-examples` has its own DuckDB screeners and a mirror that covers only Nifty50 and Alpha30.
- Alerts are single-stock `PriceAlert` records stored in `ProfileStore` (and browser-polled in `tantra-ui-web`); there are no multi-universe group rules, no enter/exit edge detection, no corporate-event/filing/deal triggers, no digest engine, and no Web UI rule builder.
- There is no instrument master and no universe in `StrategyContext`.

### Architectural Boundary Decisions (2026-11-16 Review)

1. **Keep `tantra-core` (L0) slim and jurisdiction-neutral** (resolving [`docs/ddd-conflict.md`](../ddd-conflict.md) Conflict #1 / Ambiguity #2):
   - **`ScreenCategory` does NOT go in `tantra-core`**: it is a catalog/UI browsing taxonomy owned by `tantra-data` (`catalog_screens/*.toml`) and surfaced as a validated category slug in `tantra-runtime-api` / `tantra-agent` / `tantra-ui` / `tantra-ui-web` (matching `Metric.group: str`).
   - **`AlertRule` / `AlertEvent` / `DeliveryPolicy` / `UniverseSpec` do NOT go in `tantra-core`**: alerts carry user `owner`, `watchlist` references, scheduler cadences, and digest policies — L3 application concerns owned by `tantra-runtime-api` and `tantra-agent-chat-tools` (where `PriceAlert` already lives), not L0 trading/OMS kernel types. `tantra-ui-web` consumes them via generated OpenAPI 3.1 types (`api-schema.d.ts`).
   - **India/NSE-specific rules stay out of L0**: SEBI/AMFI `MarketCapBucket::from_rank` cutoffs (`1–100 / 101–250 / 251+`), NSE 4-level hierarchy validation, and editorial `themes` live in `tantra-market-finance::india` / `tantra-data` plan 0007 (matching `FeeBreakdown` vs `india::costs`). `tantra-core` 0004 holds only thin, market-agnostic value objects (`Sector`, `Industry`, `IndexId`, bare `MarketCapBucket`) and the converged screener wire AST.
2. **DSL convergence before Screener v2**: unify the 4 screener DSLs onto one recursive `AND`/`OR` `Decimal` AST (exported via `tantra-ffi-codegen`) before extending with `CrossesAbove/Below`, `RelativeTo`, and `ClassificationFilter`.
3. **Explicit L3 ↔ L6 evaluation split**: L3 Rust (`tantra-runtime`) evaluates fast bar/MA/breakout/price rules and event-stream triggers natively over `tantra-market-store` + exported Parquet projections (`catalog/{instruments,classification,index_membership,qvm}`), while cross-sectional DuckDB/fundamental/peer-median screens run through an explicit `ScreenerEvaluatorPort` (backed by `tantra-data` or unified Parquet reader) so Rust and Python never drift into two conflicting query engines.
4. **Async MCP ports stay out of pure `tantra-agent-tools`**: `ScreenerPort`, `UniversePort`, `AlertRulePort`, `AlertSubscriptionPort`, and `WatchlistPort` are async ports in `tantra-agent-chat-tools` / `tantra-agent-mcp` (respecting Agent Rules R1–R4), wired by `tantra-runtime`.

| # | Capability | Plan / gap (provider repo) |
|---|---|---|
| F1 | Market-agnostic classification VOs (`Sector`, `Industry`, `IndexId`, bare `MarketCapBucket`) + converged recursive Screener DSL (`CrossesAbove/Below`, `RelativeTo`, `ClassificationFilter`) | [`tantra-core` plan 0004](../../tantra-core/docs/plans/0004-classification-and-alert-wire-types.md) |
| F2 | Instrument master, NSE 4-level classification, point-in-time index membership, SEBI/AMFI cap-bucket history & `from_rank` | [`tantra-data` plan 0007](../../tantra-data/docs/plans/0007-instrument-master-index-membership.md) |
| F3 + F4 + F5 | Unified screen DSL mapping, screener v2 joins, TOML screen catalog (`ScreenCategory` taxonomy), QVM score | [`tantra-data` plan 0008](../../tantra-data/docs/plans/0008-screen-dsl-catalog-qvm.md) |
| F9 | Shareholding / pledge / SAST / analyst estimates (no source yet) | [`tantra-data` gap 0024](../../tantra-data/docs/gaps/0024-shareholding-sast-estimates.md) |
| F6 | SDK `StrategyContext.universe / classification / screen`, `on_rebalance` | [`tantra-strategies` plan 0002](../../tantra-strategies/docs/plans/0002-universe-screen-context.md) |
| F7 | Alpha-Alerts engine (`ScreenEdge` + `EventMatch` rules, multi-universe scoping, live + hourly/daily digests, preset notification packs, `/v1/alerts/*`) & MCP port wiring | [`tantra-runtime` plan 0007](../../tantra-runtime/docs/plans/0007-group-screener-alerts.md) |
| F8 | Screener / universe / QVM / Alpha-Alerts / watchlist MCP & chat tools (async ports in `chat-tools`/`mcp`) | [`tantra-agent` plan 0013](../../tantra-agent/docs/plans/0013-screener-mcp-tools.md) |
| UI (Web) | `/alerts` rule builder & Alpha-Pack subscriptions, "Create Alert from Screen", Watchlist/Portfolio alert drawers, categorized Screener & QVM UI, `AlertsPanel` upgrade | [`tantra-ui-web` plan 0014](../../tantra-ui-web/docs/plans/0014-alpha-alerts-and-screener-ui.md) |
| — | Categorized examples and migration off the examples universe mirror | [`tantra-examples` plan 0005](../../tantra-examples/docs/plans/0005-categorized-examples.md) |

Related: root [plan 0001](0001-fincept-quantcepts-gap-closure-and-feature-roadmap.md) §`screener`
and §`workspace` (watchlists, multi-condition alerts). This plan is the concrete, per-repo
breakdown of those areas. Root [plan 0009](0009-qullamaggie-swing-trading-platform.md) (cross-sectional
leader rank, back watchlist) consumes F2/F3/F6. Examples gaps 0004/0006 (universe mirror) are
superseded for their universe portion by `tantra-data` plan 0007.

## 2. Component Specifications & Phases (bottom-up build order)

| Phase | Tier | Deliverable | Depends on |
|---|---|---|---|
| P1 | L0 | `tantra-core` 0004: slim classification VOs (`Sector`, `Industry`, `IndexId`, `MarketCapBucket`), DSL convergence (recursive `ScreenerFilterGroup`, unified `FilterOp`, `CrossesAbove/Below`, `RelativeTo`, `ClassificationFilter`), schemars, golden JSON, `tantra-ffi-codegen` export | — |
| P2 | L6 | `tantra-data` 0007: instrument master, NSE 4-level hierarchy, SEBI cap-bucket `from_rank`, point-in-time universes (`UniverseReader.resolve(name, as_of)`), Parquet projections | P1 wire strings |
| P3 | L6 | `tantra-data` 0008 A–C: DSL unification onto converged core schema, screener v2, TOML screen catalog (`ScreenCategory` taxonomy) | P1, P2 |
| P4 | L6 | `tantra-data` 0008 D: QVM score (point-in-time, open weights, G/M/B combo labels) | P3 |
| P5 | L6 | `tantra-strategies` 0002: SDK context surface + `SimulatedContext` seeding | P2, P3 (Protocol only; adapter at composition) |
| P6 | L3 | `tantra-runtime` 0007: Alpha-Alerts engine (`ScreenEdge` + `EventMatch`, multi-universe scoping, live + hourly/daily digest batcher, preset packs, SQLx persistence, `/v1/alerts/*`) + MCP port wiring | P1, P2 (projections), P3 (`ScreenerEvaluatorPort`) |
| P7 | L3 | `tantra-agent` 0013: MCP & chat tool definitions over async ports in `tantra-agent-chat-tools` / `tantra-agent-mcp` | P1, P6 DTOs/ports |
| P8 | L6 | `tantra-examples` 0005: categorized examples, rotation strategy, mirror removal | P2–P5 |
| P9 | L5 | `tantra-ui-web` 0014: `/alerts` rule builder + Alpha Packs, `/screener` catalog/QVM + "Create Alert from Screen", Watchlist/Portfolio alert drawers, `AlertsPanel` upgrade over OpenAPI `api-schema.d.ts` | P3, P4, P6 (`/v1/alerts/*`, `/v1/screener/*`) |
| Later | L6 | `tantra-data` gap 0024: shareholding / SAST / estimates, which unlock the Shareholding, Forecaster and Red-flag categories and insider/SAST big-deal alerts | data source |

Invariants across all phases: `Decimal` / `decimal.js` only (no `f32`/`f64`/`float`, including retiring the `f64` fork in `tantra-market-indicators`); parameterized SQL only (including `read_parquet`); point-in-time data in backtests (no look-ahead or survivorship bias); unwired capability raises an explicit `*Unavailable` / `PortError::unavailable` (and explicit offline error in `tantra-ui-web`, no synthetic triggers); tests live in `tests/` (or co-located Vitest suites in `tantra-ui-web`); no upward tier edges (`tantra-core` stays slim and jurisdiction-neutral; `tantra-agent-tools` stays pure/sync per R3; MCP data wiring lives in `tantra-runtime` per R4).
