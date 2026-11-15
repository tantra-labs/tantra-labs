# 0008 — Trade Signal Generator: entry, SL, TSL, profit booking & position sizing (TradePlanner + TradeManager)

**Status**: Proposed

## 0. Executive Summary & Objective

Turn any signal (a strategy's `StrategySignal`, a screener hit, an agent idea) into a complete,
risk-checked **trade plan** produced automatically:

- the entry rule
- the initial stop-loss
- the trailing-stop rule
- a profit-booking ladder (scale-outs at R-multiples, a move to breakeven, a runner)
- the position size

A pure **TradeManager** then manages that plan bar by bar. The same code drives the backtest,
the Python SDK, live trading (runtime-managed synthetic brackets) and the chat/MCP tools.

Behaviour is defined by **configurable, versioned presets**, and every field can be overridden:

| Preset | Entry | SL | Profit booking | TSL |
|---|---|---|---|---|
| `qullamaggie` | opening-range high break; chase guard (skip if > 1×ATR up on the day) | day low; reject if wider than 1×ADR%(20) | ⅓ on day 3–5, then stop → breakeven | first daily close below SMA10 (or SMA20) |
| `ee_plus` | confirmed trigger candle at a level scoring ≥ 3 | beyond the level-band zone cluster (= 1R) | partial at 3R, runner to 4R–5R | ATR trail activating after N R; 6-candle stagnation time-stop |
| `atr_swing` | stop-above trigger / market | 2×ATR | ⅓ at 2R, ⅓ at 3R | Chandelier on the runner |

Sizing everywhere reuses `tantra_core::sizing::calculate_position_size`. Fixed-fractional is the
default. Results are capped by a per-name weight limit and a percentage of 20-day average daily volume (ADV), then validated by
`tantra-risk` `validate_sizing_request`.

## 1. Context & Gaps Covered

The pieces exist but are not connected:

| Capability | Today | Status |
|---|---|---|
| Position sizing | `tantra-core/src/sizing.rs` (FixedFractional / VolTarget / Kelly / ERC / FixedNotional), `tantra-risk/src/sizing_gate.rs`, `tantra-ledger` `evaluate_risk_budget` | exists |
| Signal DTO | `tantra-core/src/signal.rs` `Signal` (single TP); SDK `PositionIntent` (single target) | partial |
| SL | SDK `Strategy.stop_loss` (level-band only); broker SL / SL-M mapping in `tantra-exec` | partial |
| TSL | SDK `trail_stop` (ATR/swing; `activation_after_r` not enforced); Python-only `TRAILING_STOP` in ffi | partial |
| Profit booking | none (no scale-out, no R ladder, no breakeven) | missing |
| Backtest | `tantra-runtime-backtest` stops only; no intrabar high/low, trailing or partials | partial |
| Live brackets | `tantra-exec` gap 0003, `tantra-ledger` gap 0012 open | missing |
| Chat/MCP | `strategy_suggest` is a **stub** (hardcoded prices, SL = entry × 0.988, always BUY) | stub |
| Indicators | ATR, Supertrend, PSAR, Keltner, Donchian, pivots exist; **ADR%(20) and Chandelier missing** | partial |

Per-repo documents:

| # | Deliverable | Plan / gap |
|---|---|---|
| P1 | `TradePlanSpec` / `EntryRule` / `StopRule` / `TrailRule` / `TargetLadder` / `TradePlan`, `TradePlanner::plan`, typed `PlanError` | [`tantra-core` plan 0005](../../tantra-core/docs/plans/0005-trade-planner-and-manager.md) |
| P2 | `TradeManager` pure state machine (`on_bar` → `MoveStop` / `PartialExit` / `ExitAll`), intrabar policy, presets plus golden vectors | same |
| P3 | ADR%(20) and Chandelier exit indicators | [`tantra-market` gap 0007](../../tantra-market/docs/gaps/0007-adr-pct-and-chandelier-exit.md) |
| P4 | PyO3 `tantra.trade_plan` bindings; reconcile `declarative.py` OCO and `TRAILING_STOP` | [`tantra-ffi` plan 0002](../../tantra-ffi/docs/plans/0002-trade-planner-bindings.md) |
| P5 | SDK `ctx.equity()`, `Strategy.plan_trade(signal, preset, **overrides)`, `on_trade_action`, `partial_exit`, preset catalog | [`tantra-strategies` plan 0003](../../tantra-strategies/docs/plans/0003-trade-plan-sdk.md) |
| P6 | Backtest via TradeManager (intrabar, trailing, partials, breakeven, time stops); live synthetic brackets; `POST /v1/trade-plan`; R-multiple journal | [`tantra-runtime` plan 0006](../../tantra-runtime/docs/plans/0006-trade-manager-backtest-and-synthetic-brackets.md) |
| P3b | Chart pattern analyzer: flag/triangle/rectangle/Darvas/double/H&S/wedge/cup-and-handle/VCP plus multi-bar candlesticks, emitting breakout, invalidation and measured-target geometry; per-pattern edge stats | [`tantra-market` plan 0002](../../tantra-market/docs/plans/0002-chart-pattern-analyzer.md) (+ `ChartPattern` in core plan 0005 §2a) |
| P7 | Real `strategy_suggest` over a `TradePlanPort`; MCP `trade_plan` and `trade_plan_presets` | [`tantra-agent` plan 0014](../../tantra-agent/docs/plans/0014-real-trade-suggestion-and-trade-plan-mcp.md) |

Plans and gaps this work unblocks or partly closes:

- Root [plan 0005](0005-elephant-edge-strategy-platform.md) (EE+ SL/TSL/partials/sizing)
- Root [plan 0006](0006-qullamaggie-swing-trading-platform.md) (ADR% gate, partial exits, close-based trail, `equity()`: its gap row 22)
- `tantra-risk` gap 0005 (SL validation should consume `TradePlan`)
- `tantra-exec` gap 0003 and `tantra-ledger` gap 0012 (real brackets replace the synthetic ones later)

## 2. Component Specifications & Phases (build order)

1. **P1–P2, L0 `tantra-core`.** Pure, Decimal-only, wasm-compatible, clock-injected.
   - Indicator values arrive as `PlannerInputs`, because core cannot depend on `tantra-market`.
   - Proptests:
     - `risk_at_stake ≤ equity × risk_pct`
     - quantity is a lot multiple
     - the stop is monotone and never loosens
     - ladder quantities sum to at most the position
     - no look-ahead
2. **P3, L2 `tantra-market`.** ADR% and Chandelier. These can run in parallel with P1.
3. **P4, L4 `tantra-ffi`.** Bindings, with Rust ↔ Python parity golden vectors.
4. **P5, L6 `tantra-strategies`.** SDK surface plus the presets `catalog/plan/{qullamaggie,ee_plus,atr_swing}.toml`.
5. **P6, L3 `tantra-runtime`.** The backtest and live managers share the single `TradeManager` implementation.
   - Persisted, restart-safe, bounded channels.
6. **P7, L3 `tantra-agent`.** Agent tools defined against ports and wired in `tantra-runtime` (R4).
   - LLM-proposed plans remain untrusted and always pass `RiskEngine`.
7. **Follow-up: `tantra-examples`.** Preset-driven examples (screen → plan → backtest), filed when P5 lands.
   - These can chain off the root [plan 0007](0007-screener-taxonomy-and-alerts.md) screener.

## 3. Pattern-driven trade plans

A chart pattern supplies the three prices a plan needs from the price structure itself:
- **Entry:** the breakout level (`EntryRule::PatternBreakout`).
- **SL:** the invalidation point (`StopRule::PatternInvalidation`). This is usually a better stop than an ATR multiple, because it sits where the setup is disproved.
- **Target:** the measured move (`TargetLeg::MeasuredMove`). This also lets the planner reject setups below `min_reward_risk` before entry.

Preset `pattern_breakout`: ½ booked at the measured move, with the runner on a Chandelier trail.

Guardrails:
- Patterns are anchored at their **confirmation** bar, so the analyzer does not repaint and backtests see no look-ahead.
- Pattern quality may scale risk only after `tantra-market` plan 0002 Phase D publishes per-pattern edge statistics.
- The detectors also feed the plan 0007 Candlestick/Pattern screen presets and an agent `chart_patterns` tool.
