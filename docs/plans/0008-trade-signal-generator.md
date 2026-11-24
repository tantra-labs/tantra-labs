# 0008 — Trade Signal Generator: entry, SL, TSL, profit booking & position sizing (TradePlanner + TradeManager)

**Status**: Proposed

## 0. Executive Summary & Objective

Turn any signal (a strategy's `StrategySignal`, a `tantra-core::Signal`, a `ChartPattern`, a screener hit, an agent idea) into a complete,
risk-checked **trade plan** produced automatically:

- the entry rule
- the initial stop-loss
- the trailing-stop rule
- a profit-booking ladder (scale-outs at R-multiples / measured moves, a move to breakeven, a runner)
- the position size

A pure **TradeManager** then manages that plan bar by bar. The same Rust implementation drives the backtest,
the Python SDK (via `tantra-ffi`), live trading (runtime-managed synthetic brackets), REST, and chat/MCP tools.

Behaviour is defined by **configurable, versioned presets** (single source of truth in `tantra-core`, exported via `tantra-ffi`), and every field can be overridden:

| Preset | Entry | SL | Profit booking | TSL |
|---|---|---|---|---|
| `qullamaggie` | opening-range high break (symmetric low break for short); chase guard (skip if > 1×ATR extended on the day) | day low/high; reject if `\|entry - sl\| / entry × 100 > 1×ADR%(20)` | ⅓ on session 3–5, then stop → breakeven | first daily close below SMA10/SMA20 (above for short) |
| `ee_plus` | confirmed trigger candle at a level scoring ≥ 3 | beyond the level-band zone cluster (= 1R) | partial at 3R, runner to 4R–5R | ATR trail activating after N R; 6-candle stagnation time-stop |
| `atr_swing` | stop-above trigger / market | 2×ATR | ⅓ at 2R, ⅓ at 3R | Chandelier on the runner |
| `pattern_breakout` | pattern breakout level + `buffer_ticks` (`StopAbove`/`Below` for `FormingArmed`, market/pullback for `BreakoutConfirmed`) | pattern invalidation level (+ optional ATR buffer) | ½ at `MeasuredMove(1.0)` (falls back to `AtR(2.0)` / runner-only when `measured_target` is `None`, e.g. VCP) | Chandelier on the runner |

Sizing everywhere reuses `tantra_core::sizing::calculate_position_size`. Fixed-fractional is the
default. Results are capped by a per-name weight limit (`max_weight_pct`) and a percentage of 20-day average daily volume (`max_adv_pct` over `adv20`), then validated by
`tantra-risk` `validate_sizing_request` and `RiskEngine` stop-protection checks.

## 1. Context & Gaps Covered

The pieces exist but are not connected cleanly:

| Capability | Today | Status |
|---|---|---|
| Position sizing | `tantra-core/src/sizing.rs` (`FixedFractional` / `VolTarget` / `Kelly` / `ERC` / `FixedNotional`), `tantra-risk/src/sizing_gate.rs`, `tantra-ledger` `evaluate_risk_budget`; missing weight/ADV caps and fail-closed zero-dist guard | partial |
| Signal DTO | `tantra-core/src/signal.rs` `Signal` (single TP); core plan 0003 `StrategySignal`; market signals `engine::Signal` (`f64`); SDK `PositionIntent` | fragmented |
| SL | SDK `Strategy.stop_loss` (level-band only); core plan 0003 `StopProtection` vs plan 0005 `StopRule`; broker SL / SL-M mapping in `tantra-exec` | partial |
| TSL | SDK `trail_stop` (`activation_after_r` not enforced); Python-only `TRAILING_STOP` in `tantra-ffi`; `declarative.py` sim-only OCO | partial |
| Profit booking | none (no scale-out, no R ladder, no breakeven) | missing |
| Chart patterns | `tantra-market-signals` has `Candlestick` (1-2 bar), `BreakOfStructure`, `FractalPivot` in `f64` `Series`; no geometric patterns, no `Decimal` geometry | missing |
| Backtest | `tantra-runtime-backtest` (`engine.rs`) sizes using cash-only `INR` equity, overwrites order quantities pre-exec, and lacks intrabar H/L trailing/partials | partial |
| Live brackets | `tantra-exec` gap 0003, `tantra-ledger` gap 0012 open (1-to-1 bracket assumption incompatible with multi-leg partial exits) | missing |
| Chat/MCP | `strategy_suggest` is a **stub** (hardcoded prices, SL = entry × 0.988, always BUY); `TradeSuggestionTool` mislabels output `"strategy_run"` | stub |
| Indicators | ATR, Supertrend, PSAR, Keltner, Donchian, pivots, **ADR%(20) and Chandelier Exit** (`AdrPct`, `ChandelierExit`) | done |

Per-repo documents:

| # | Deliverable | Plan / gap |
|---|---|---|
| P1 | Canonical `TradePlanSpec` / `EntryRule` / `StopRule` / `TrailRule` / `TargetLadder` / `TradePlan` / `ChartPattern`, `TradePlanner::plan`, typed `PlanError`; unify with plan 0003 stop/signal types; extend `RiskBudget` caps | [`tantra-core` plan 0005](../../tantra-core/docs/plans/0005-trade-planner-and-manager.md) — **P1 shipped 2026-11-17** (T12 prerequisite); plan 0003 (level-map types) **implemented** (see [`tantra-core` plans index](../../tantra-core/docs/plans/README.md)) |
| P2 | `TradeManager` pure state machine (`on_entry_fill`, `on_bar`, `on_session_close` → `MoveStop` / `PartialExit` / `ExitAll`), tick-snapping, intrabar policy, canonical preset TOMLs + golden vectors | same |
| P3 | ADR%(20) and Chandelier exit indicators | **Closed 2026-11-24** ([`tantra-market` closed gap `0007`](../../tantra-market/docs/gaps/README.md#closed-gaps)): `AdrPct` + `ChandelierExit` (`tantra-market-indicators`, `tantra-ffi`, `tantra-strategies` SDK) |
| P3b | Chart pattern analyzer: geometric + multi-bar candlesticks over `&[Bar]` (`Decimal` geometry + `DateTime<Utc>`, `PatternStage { FormingArmed, BreakoutConfirmed }`, no look-ahead), per-pattern edge stats | [`tantra-market` plan 0002](../../tantra-market/docs/plans/0002-chart-pattern-analyzer.md) (+ `ChartPattern` in core plan 0005 §2a) |
| P4 | PyO3 `tantra.trade_plan` bindings (`TradePlanner`, `TradeManager`, `ChartPattern`, canonical presets); reconcile `declarative.py` OCO and `TRAILING_STOP` | [`tantra-ffi` plan 0004](../../tantra-ffi/docs/plans/0004-trade-planner-bindings.md) |
| P5 | SDK `ctx.equity()`, `Strategy.plan_trade(signal, preset, **overrides)`, `on_trade_action`, `partial_exit`; read canonical presets from FFI; drive `SimulatedContext` via Rust `TradeManager` | [`tantra-strategies` plan 0003](../../tantra-strategies/docs/plans/0003-trade-plan-sdk.md) |
| P6 | Backtest via `TradeManager` (MTM equity, no sizer overwrite, `on_entry_fill` R-anchoring, intrabar H/L, trailing, partials, breakeven, time stops); live synthetic OCO state machine; `POST /v1/trade-plan`; R-multiple journal; pattern scan wiring | [`tantra-runtime` plan 0006](../../tantra-runtime/docs/plans/0006-trade-manager-backtest-and-synthetic-brackets.md) |
| P7 | Real `strategy_suggest` over `TradePlanPort`; MCP `trade_plan`, `trade_plan_presets`, and `chart_patterns` | [`tantra-agent` plan 0014](../../tantra-agent/docs/plans/0014-real-trade-suggestion-and-trade-plan-mcp.md) |

Plans and gaps this work unblocks or partly closes:

- Root [plan 0005](0005-elephant-edge-strategy-platform.md) (EE+ SL/TSL/partials/sizing)
- Root [plan 0009](0009-qullamaggie-swing-trading-platform.md) (ADR% gate, partial exits, close-based trail, `equity()`: gap row 22; flag/VCP/Darvas detection)
- Root [plan 0010](0010-screener-taxonomy-and-alerts.md) & [`tantra-data` plan 0008](../../tantra-data/docs/plans/0008-screen-dsl-catalog-qvm.md) (Candlestick/Darvas/Pattern screen presets aligned to `tantra-market-signals` codes)
- [`tantra-risk` gap 0005](../../tantra-risk/docs/gaps/README.md) — **closed 2026-11-17** (T12.6): SL/TSL validation over `TradePlan` + weight/ADV sizing refusals in `trade_plan_gate`
- [`tantra-exec` gap 0003](../../tantra-exec/docs/gaps/README.md) and [`tantra-ledger` gap 0012](../../tantra-ledger/docs/gaps/README.md) — **closed 2026-11-17** (T12.5/T12.7): multi-leg bracket contract & OMS lifecycle (`BracketTracker` / `BracketOrder`); runtime synthetic-OCO wiring remains a follow-on

## 2. Component Specifications & Phases (build order)

1. **P1–P2, L0 `tantra-core`.** Pure, `Decimal`-only, WASM-compatible, clock-injected; bump `SCHEMA_VERSION` when `TradePlan`/`ChartPattern` wire contracts land.
   - Indicator and pattern values arrive via `PlannerInputs` (core cannot depend on `tantra-market`).
   - Reconcile plan `0003`'s `StopProtection`/`TrailMode` and `StrategySignal` into `TradePlan` / `PlanSubject` so core has one canonical stop/trail/signal model.
   - Proptests:
     - `risk_at_stake ≤ equity × risk_pct` and zero-distance stops fail closed (`PlanError::ZeroRisk`)
     - quantity is a lot multiple and respects `max_weight_pct` + `max_adv_pct`
     - every computed price (`entry`, `initial_stop`, targets) snaps conservatively to `tick_size`
     - the stop is monotone and never loosens
     - ladder quantities sum to at most the position
     - no look-ahead (`confirmed_at` respected; close-only exits act on the next bar)
2. **P3 & P3b, L2 `tantra-market` (parallel with P1 once `ChartPattern` lands in core).**
   - P3: ADR%(20) and Chandelier indicators (`tantra-market` gap `0007` — closed 2026-11-24).
   - P3b: `PatternAnalyzer` over `&[Bar]` (exact `Decimal` OHLC + `DateTime<Utc>` timestamps; distinct from `f64`-only `Detector::detect(&Series)`), emitting `ChartPattern` with explicit `PatternStage { FormingArmed, BreakoutConfirmed }`.
3. **Cross-cutting L1 alignment (`tantra-risk` gap 0005 & `tantra-ledger` gap 0012).**
   - `RiskBudget` / `validate_sizing_request` enforce `max_weight_pct` and `max_adv_pct`; `SizingRiskRefusal::fmt` uses `Money.currency` instead of hardcoded `"INR"`.
   - `BracketOrder` in `tantra-ledger` supports N-leg partial exits (`remaining_qty`) rather than closing on the first child fill.
4. **P4, L4 `tantra-ffi`.** `tantra.trade_plan` + `ChartPattern` bindings, Rust ↔ Python parity golden vectors, and canonical preset exposure; reconcile `declarative.py` OCO/`TRAILING_STOP` with `tantra_strategies.sdk`.
5. **P5, L6 `tantra-strategies`.** SDK surface consuming canonical presets from `tantra-ffi` (no duplicate preset rules) and driving `SimulatedContext` via Rust `TradeManager`.
6. **P6, L3 `tantra-runtime`.** Backtest and live synthetic OCO share the single `TradeManager`:
   - Fix `backtest/engine.rs` cash-only `INR` equity and order-quantity overwrite; call `TradeManager::on_entry_fill` after actual entry fill (re-anchoring `1R`/targets/breakeven under slippage/gaps).
   - Live `TradeManagerActor`: persisted state, bounded channels, atomic SL qty resize on partial-exit fills (preventing short-flip), and restart reconciliation against open broker orders.
   - Stateless `POST /v1/trade-plan` preview endpoint; wire `PatternAnalyzer` in scan/backtest.
7. **P7, L3 `tantra-agent`.** `TradePlanPort` + `PatternPort` wired in `tantra-runtime` (R1/R4 — never add `tantra-market`/`tantra-ledger` deps to `tantra-agent-mcp`).
   - LLM-proposed presets/overrides deserialize with `#[serde(deny_unknown_fields)]` and remain advisory; any order conversion passes `RiskEngine`.
8. **Follow-up: `tantra-examples`.** Preset-driven examples (screen → pattern/signal → plan → backtest), chained off root [plan 0010](0010-screener-taxonomy-and-alerts.md).

## 3. Pattern-driven trade plans

A chart pattern supplies the three structural prices a plan needs directly from price action:
- **Entry (`EntryRule::PatternBreakout { buffer_ticks }`)**: `breakout_level ± buffer_ticks × tick_size` (using `StopAbove`/`StopBelow` when `stage == FormingArmed`, or market/pullback entry when `stage == BreakoutConfirmed`).
- **SL (`StopRule::PatternInvalidation { buffer_atr }`)**: `invalidation_level` (± optional ATR buffer), anchored where the pattern geometry is disproved.
- **Target (`TargetLeg::MeasuredMove { fraction_of_height }`)**: `measured_target` projected along `direction` when present, with explicit `min_reward_risk` gating (`PlanError::InsufficientReward`) before entry. For patterns with `measured_target == None` (e.g. VCP, candles), `TargetLadder` uses its declared fallback leg or runs trail-only.

Preset `pattern_breakout`: ½ booked at `MeasuredMove(1.0)` (fallback `AtR(2.0)` / trail-only if targetless), with the runner on a Chandelier trail.

Guardrails:
- Patterns are strictly causal: all constituent pivots must have `confirmed_at <= armed_at`, and `BreakoutConfirmed` patterns anchor at the breakout bar close (never backdated to pivot bars) so backtests cannot look ahead.
- `ChartPattern` carries `timeframe` and `stage` explicitly so multi-timeframe setups (e.g. D1 pattern with M5 entry) remain unambiguous.
- Pattern `quality` may scale `risk_pct` only after [`tantra-market` plan 0002](../../tantra-market/docs/plans/0002-chart-pattern-analyzer.md) Phase D publishes point-in-time edge statistics.
- Pattern detectors also feed [plan 0010](0010-screener-taxonomy-and-alerts.md) Candlestick/Pattern screens, `tantra-ui` chart annotations (`LevelLine`/`ZoneBand`/`StopLine`), and the agent `chart_patterns` tool.

## 4. Cross-Cutting Architectural Invariants

1. **Single source of truth for presets**: Canonical TOML specs live in `tantra-core` (embedded/schema-validated), exported through `tantra-ffi` and REST; `tantra-strategies` loads from FFI rather than maintaining a second independent copy.
2. **Timeframe separation in `TradeManager`**: Intrabar price triggers (`StopLoss`, `AtR`/`MeasuredMove` targets) evaluate on intrabar bars (`on_bar`, conservative stop-first), whereas close-only rules (`CloseBelowMa`, session-based `AfterBars`, `time_stop`) evaluate only on matching `on_session_close` / matching `Timeframe` closes and emit exits for the next open.
3. **Live synthetic-OCO safety**: Resting broker SL child quantity MUST always match open `remaining_qty`; partial exits never leave an oversized SL resting on the book, and SL modifications never leave an unprotected gap without explicit `StopAmendPending` tracking.
4. **Canonical `Decimal` precision**: `ChartPattern` boundary/target prices and `TradePlan` prices/sizes are `Decimal` only, extracted directly from `&[Bar]` and snapped to `tick_size`.
