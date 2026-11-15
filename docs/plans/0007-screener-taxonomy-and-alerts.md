# 0007 — Screener Taxonomy, QVM Score, Group Alerts & Screener MCP (Trendlyne-inspired, native)

**Status**: Proposed

Research basis: [`docs/research/trendlyne-screener-alerts-mcp.md`](../research/trendlyne-screener-alerts-mcp.md).
Decision (2026-11-15): implement **natively**. Trendlyne is an idea source only; no Trendlyne
adapter, no dependency on its paid MCP server.

## 0. Executive Summary & Objective

Give every Tantra consumer (SDK strategies, examples, REST, CLI/TUI, agents) one shared way to
**categorize** instruments (sector/industry hierarchy, market-cap bucket, index membership,
themes), **screen** them with a single DSL and a versioned preset catalog organized by
Trendlyne-style screen categories, **score** them with an open Quality/Value/Momentum (QVM)
composite, and **alert** on any screen over a whole universe (enter/exit/level edges). Expose all of
it to LLM agents as MCP tools that scan the full market, which Trendlyne's MCP cannot do.

## 1. Context & Gaps Covered

The pieces Tantra has today don't fit together. Python `ScreenQuery`/`VectorizedScreener` only reads candle columns. `tantra-examples` has its own DuckDB screeners and a mirror that covers only Nifty50 and Alpha30. The Rust `ScreenerScanRequest` has no classification or peer-relative filters. Alerts are price-only. There is no instrument master and no universe in `StrategyContext`.

| # | Capability | Plan / gap (provider repo) |
|---|---|---|
| F1 + F7 wire | Classification value objects, `ScreenCategory`, crossing ops, peer-relative predicates, `AlertRule`/`AlertEvent` | [`tantra-core` plan 0004](../../tantra-core/docs/plans/0004-classification-and-alert-wire-types.md) |
| F2 | Instrument master, NSE industry classification, point-in-time index membership, cap-bucket history | [`tantra-data` plan 0007](../../tantra-data/docs/plans/0007-instrument-master-index-membership.md) |
| F3 + F4 + F5 | Unified screen DSL, screener v2 joins, TOML screen catalog, QVM score | [`tantra-data` plan 0008](../../tantra-data/docs/plans/0008-screen-dsl-catalog-qvm.md) |
| F9 | Shareholding / pledge / SAST / analyst estimates (no source yet) | [`tantra-data` gap 0023](../../tantra-data/docs/gaps/0023-shareholding-sast-estimates.md) |
| F6 | SDK `StrategyContext.universe / classification / screen`, `on_rebalance` | [`tantra-strategies` plan 0002](../../tantra-strategies/docs/plans/0002-universe-screen-context.md) |
| F7 engine | AlertRule store, scheduler, edge detection, notification sinks, `/v1/alerts/*`, MCP port wiring | [`tantra-runtime` plan 0005](../../tantra-runtime/docs/plans/0005-group-screener-alerts.md) |
| F8 | Screener / universe / QVM / alert / watchlist MCP tools | [`tantra-agent` plan 0013](../../tantra-agent/docs/plans/0013-screener-mcp-tools.md) |
| — | Categorized examples and migration off the examples universe mirror | [`tantra-examples` plan 0003](../../tantra-examples/docs/plans/0003-categorized-examples.md) |

Related: root [plan 0001](0001-fincept-quantcepts-gap-closure-and-feature-roadmap.md) §`screener`
and §`workspace` (watchlists, multi-condition alerts). This plan is the concrete, per-repo
breakdown of those areas. Root [plan 0006](0006-qullamaggie-swing-trading-platform.md) (cross-sectional
leader rank, back watchlist) consumes F2/F3/F6. Examples gaps 0004/0006 (universe mirror) are
superseded for their universe portion by `tantra-data` plan 0007.

## 2. Component Specifications & Phases (bottom-up build order)

| Phase | Tier | Deliverable | Depends on |
|---|---|---|---|
| P1 | L0 | `tantra-core` 0004: classification types, `ScreenCategory`, `CrossesAbove/Below`, `RelativeTo`, `AlertRule` wire types, schemars, golden JSON | — |
| P2 | L6 | `tantra-data` 0007: instrument master and point-in-time universes (`UniverseReader.resolve(name, as_of)`) | P1 wire strings |
| P3 | L6 | `tantra-data` 0008 A–C: DSL unification, screener v2, screen catalog | P1, P2 |
| P4 | L6 | `tantra-data` 0008 D: QVM score (point-in-time, open weights, G/M/B combo labels) | P3 |
| P5 | L6 | `tantra-strategies` 0002: SDK context surface + `SimulatedContext` seeding | P2, P3 (Protocol only; adapter at composition) |
| P6 | L3 | `tantra-runtime` 0005: alert engine + REST; wires the MCP ports | P1, P3 (via HTTP/FFI schema) |
| P7 | L3 | `tantra-agent` 0013: MCP tool definitions over ports | P1; wired by P6 |
| P8 | L6 | `tantra-examples` 0003: categorized examples, rotation strategy, mirror removal | P2–P5 |
| Later | L6 | `tantra-data` gap 0023: shareholding / SAST / estimates, which unlock the Shareholding, Forecaster and Red-flag categories and insider-deal alerts | data source |

Invariants across all phases: Decimal only (no floats); parameterized SQL only (including
`read_parquet`); point-in-time data in backtests (no look-ahead or survivorship bias); unwired capability raises
an explicit `*Unavailable` / `PortError::unavailable`; tests live in `tests/`; no upward tier edges
(the Python enums mirror `tantra-core` wire strings and don't fork their semantics; MCP data wiring lives in
`tantra-runtime` per agent rule R4).
