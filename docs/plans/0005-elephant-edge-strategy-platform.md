# 0005 — Elephant Edge (EE+) Intraday Strategy Platform

**Status**: Proposed
**Target Scope**: `tantra-strategies`, `tantra-core`, `tantra-market`, `tantra-data`,
`tantra-exec`, `tantra-risk`, `tantra-ledger`, `tantra-ui`, `tantra-agent`, `tantra-docs`
**Type**: Cross-repo master plan (collections of the per-repo gaps/plans listed below)
**Research basis**: [`docs/research/elephant-edge-strategy.md`](../research/elephant-edge-strategy.md) (2026-11-13)

---

## 0. Objective

Build the **Elephant Edge (EE+)** intraday strategy platform: a price-action +
smart-money support/resistance system for Indian indices and F&O scrips that

1. builds a **session level map** (two support + two resistance **Elephant
   percentile zones**, previous-day OHLC, option-chain **OI walls**, dealer
   **gamma flip / GEX walls**, **max pain**, round-number **strike zones**, and
   **Order Blocks**),
2. generates **possible buy/sell signals** at high-confluence levels with
   price-action confirmation (marubozu / hammer / engulfing + volume),
3. attaches **stop-loss (SL)** and **trailing stop-loss (TSL)** to every signal,
4. computes **positioning** (risk-based sizing, per-trade and portfolio caps,
   alternate-mode direction), and
5. runs byte-for-byte identical in backtest (`tantra-runtime`) and live
   (dual execution target), clamped by `tantra-risk` before execution.

The strategy lives in `tantra-strategies` (Python SDK); the plumbing is spread
across the ecosystem in the usual Rust-core / Python-wrapper split.

## 1. Verified Current State

Probe-verified 2026-11-13:

- **`tantra-market` gaps 0001 (options-chain reader) and 0002 (OI store +
  buildup) are already closed** (`b1b085e`, 2026-11-13): `ChainReader` port,
  `InstrumentChainReader`, `OpenInterestStore` port + `InMemory`/`Parquet`
  stores, `classify_buildup` four-quadrant. **No new chain/OI plumbing is
  needed upstream** — only the *level* and *indicator* layer.
- **`tantra-strategies` SDK**: `Strategy` has `on_start`/`on_bar`/`on_tick`
  (stub, gap 0001)/`on_order_event`/`on_stop`, `buy()`/`sell()`/`submit()`,
  `Parameter`, `IndicatorRegistry` (SMA/EMA/RSI/ATR/Bollinger). **There is no
  `stop_loss()` helper, no trailing-stop primitive, and no options/level-map
  context surface** — see `tantra-strategies` plan 0001 / gap 0006.
- **`tantra-core`**: canonical Decimal value objects and `Decision` grammar
  exist; **no level-map / option-chain-snapshot / stop-protection / GEX
  domain types** — see `tantra-core` plan 0003 / gap 0002.
- **`tantra-exec`**: `BrokerExecutor` routes orders; **no bracket-order
  (SL/target/trailing) contract** — see gap 0003.
- **`tantra-risk`**: price collar, reduce-only, OTR windows enforced; **no
  stop-protection validation** (mandatory SL distance, SL band) — see gap 0005.
- **`tantra-ledger`**: OMS + context validation wired (plan 0005); **no
  bracket/child-order lifecycle** (SL trigger → TSL modify → square-off) — see
  gap 0012.
- **`tantra-data`**: lakehouse + DuckDB stores exist; **no intraday
  option-chain snapshot persistence** (strike OI/ΔOI/IV/delta/gamma as-of
  series) — see gap 0016.
- **`tantra-agent` plan 0010** (institutional flow detection) already scopes
  OI-buildup chat tools; **EE+ cites it as the AI-observability dependency and
  adds only a `level_map` tool surface** (plan 0011).
- **`tantra-ui`**: feature-state models only, **no view layer** (gap 0004);
  ui-charts is geometry-only, **no level/zone/annotation primitives** (gap 0007).

## 2. Per-Repo Work Items (dependency order)

| Repo | Doc | Work |
| :--- | :--- | :--- |
| `tantra-core` | plan 0003 / gap 0002 | Domain types: `OptionChainSnapshot`, `GammaExposure` (+flip), `Level`/`LevelMap` (+kind, side, band, score), `OrderBlock`, `StopProtection` (SL/TSL), `StrategySignal`, `PositionIntent`. Zero-I/O, Decimal. |
| `tantra-market` | gap 0005 | Streaming indicators: session-range percentile **Elephant zones**, **OI-wall / gamma** level computation over the closed `OpenInterestStore`, **OrderBlock** detection (displacement + last opposing candle). |
| `tantra-data` | gap 0016 | Intraday option-chain snapshot ingestion → Parquet (`option_chain/YYYY-MM-DD-HHMM.parquet`), point-in-time as-of reads for backtest; GEX historical series. |
| `tantra-strategies` | plan 0001 / gap 0006 | **The EE+ strategy**: level-map fusion + confluence scoring, signal generation, SL/TSL management, positioning; SDK additions (stop-protection primitives, options context). |
| `tantra-exec` | gap 0003 | Bracket-order execution: SL/target/TSL in the `BrokerExecutor` contract, stop-market placement, modify/re-arm on trail. |
| `tantra-risk` | gap 0005 | Stop-protection validation: mandatory SL, SL-distance band vs reference, SL-within-price-collar, max-loss-per-strategy. |
| `tantra-ledger` | gap 0012 | OMS lifecycle for bracket orders: fill → SL/TSL child orders, TSL modify events, square-off; position-level P&L trail. |
| `tantra-agent` | plan 0011 | `level_map` / `oi_walls` chat tool surface (ReadOnly, honest `unavailable` until upstream gaps close; cites plan 0010). |
| `tantra-ui` | plan 0006 / gap 0007 | EE+ Strategy Studio: level-map rendering (zones, walls, flip, OB), signal markers with entry/SL/TSL lines, positioning panel. |
| `tantra-docs` | plan 0003 | User guide: strategy setup, level-map legend, parameter reference, worked example. |

## 3. Phases

### Phase 1 — Domain contracts (`tantra-core`, `tantra-market` indicators)
- `tantra-core` gap 0002/plan 0003: land the level-map & stop-protection value
  objects (TDD in `tests/`, golden vectors, `wasm32` clean).
- `tantra-market` gap 0005: streaming Elephant-zone, OI-wall/gamma, and
  OrderBlock indicators over bars + the closed `OpenInterestStore`. No new
  data plumbing.

### Phase 2 — Data backfill (`tantra-data` gap 0016)
- Ingest intraday option-chain snapshots into the lakehouse; point-in-time
  as-of series so backtests see only what was known at each bar.

### Phase 3 — Strategy (`tantra-strategies` plan 0001)
- EE+ strategy class + SDK stop-protection/context additions; unit tests
  against seeded `SimulatedContext` + mock chain/level feeds. This phase does
  **not** wait for Phases 1–2 — it consumes the *ports* and degrades honestly
  (see the strategy plan's dependency note).

### Phase 4 — Execution & risk (`tantra-exec` 0003, `tantra-risk` 0005, `tantra-ledger` 0012)
- Bracket/SL-TSL execution contract, risk validation, OMS lifecycle; golden
  contract-note parity for SL/TSL exits.

### Phase 5 — AI & UI (`tantra-agent` 0011, `tantra-ui` 0006)
- `level_map` chat tool; EE+ Strategy Studio in the web workstation (depends
  on ui gap 0004 view-layer work) + TUI/CLI surfacing.

### Phase 6 — Documentation (`tantra-docs` 0003)
- User guide + strategy reference; examples in `tantra-examples` (mirror, per
  the T9 convention).

## 4. Strategy Contract (binding across repos)

The EE+ strategy MUST, for every valid setup:

1. **Level map**: emit `LevelMap` with kinds
   `{ElephantSupport1..2, ElephantResistance1..2, PreviousDayOHLC, OiWallCall/Put,
   GammaFlip, MaxPain, StrikeRound, OrderBlock}`; each `Level` carries a band
   and a 0–4 **confluence score** (alignment with OI wall / PDH-PDL / gamma
   wall / building ΔOI / PCR-skew tilt / OB).
2. **Signal**: emit `StrategySignal { side: Buy|Sell, kind: Breakout|Reversal|Retest,
   ref_levels, confidence }` only on a confirmed trigger candle with volume at a
   score ≥ 3 level, inside the entry window, max-trades/day respected.
3. **Stop protection**: attach `StopProtection { initial_stop, trail: AtrTrail |
   SwingTrail | Off, trail_distance, activation_after_r }` — `Decimal` only.
4. **Positioning**: `PositionIntent` from risk-per-trade %, ATR-based stop
   distance, and `max_position_fraction`/`max_loss` risk budget; alternate-mode
   direction; mandatory intraday square-off.
5. **Zero floats**: every price, stop, band, and quantity is `Decimal`; no
   `f32/f64/float` in financial paths.
6. **Regime gate**: the dealer-gamma regime (long-gamma → prefer Reversal at
   walls; short-gamma → prefer Breakout through walls) and PCR tilt modulate
   which signal kinds are allowed.

## 5. Quality Gates

- Rust repos: `cargo fmt --check`, `cargo clippy --workspace --all-targets
  --profile prod -- -D warnings`, `cargo test --workspace --profile prod`, and
  `make prod` end-of-turn (build-discipline rule).
- Python repos (`tantra-strategies`, `tantra-data`): `ruff check . && ruff
  format --check .`, `pytest -q`, type check via `pyright`.
- Docs: `mkdocs build --strict`.
- Golden-vector parity: level-map/signal/stop math identical across backtest
  and live (same research-live parity invariant as the rest of the platform).

## 6. Cleanup

Each sub-plan/gap closes independently; on closure the doc is removed from
active `docs/{plans,gaps}/`, recorded in the repo index, and this root plan is
trimmed. When all phases are done, this plan is retired to the root
`docs/plans/README.md` Implemented table and `docs/task-list-tracks-and-phases.md`
T12 rows are marked done.

## 7. Related

- Research: [`docs/research/elephant-edge-strategy.md`](../research/elephant-edge-strategy.md)
- Strategy spec: [`tantra-strategies/docs/plans/0001-elephant-edge-strategy.md`](../../tantra-strategies/docs/plans/0001-elephant-edge-strategy.md)
- Agent overlap (OI buildup legs): [`tantra-agent/docs/plans/0010-institutional-smart-money-detection-suite.md`](../../tantra-agent/docs/plans/0010-institutional-smart-money-detection-suite.md)
- Task list: [`docs/task-list-tracks-and-phases.md`](../task-list-tracks-and-phases.md) — track **T12**.
