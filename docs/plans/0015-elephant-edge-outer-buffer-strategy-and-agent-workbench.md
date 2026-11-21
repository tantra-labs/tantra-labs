# 0015 — Composable Strategy, Optimization-Loop & Interactive Graphical Primitives (EE+ Outer-Buffer Flagship)

**Status**: Implementing (2026-11-20) — Track **T21** (**`T21.1` ✅ Implemented**; **`T21.2` ✅ Implemented**; **`T21.3` ✅ Implemented**; **`T21.4` ✅ Implemented**; **`T21.5` ✅ Implemented**; **`T21.6` ✅ Implemented**)  
**Target Scope**: `tantra-market`, `tantra-strategies`, `tantra-runtime`, `tantra-ui` (`tantra-ui-charts`, `tantra-ui-core`, `tantra-tui`, `tantra-cli`), `tantra-ui-web`, `tantra-agent`, `tantra-docs`  
**Architecture Rule**: **Zero edits to `tantra-core`** (reuse existing `LevelMap`, `LevelKind`, `StopProtection`, `TradePlan`, `PositionIntent`, `OptionChainSnapshot`, `Exchange`, `InstrumentId`, `Money`, `Price`, `Quantity`, `Decimal` read-only).  
**Depends On**: [Plan 0005 (Elephant Edge Strategy Platform)](0005-elephant-edge-strategy-platform.md), [Plan 0008 (Trade Signal Generator)](0008-trade-signal-generator.md), [Plan 0014 (`Experimental-Analysis` Statistical & Event Study Platform)](0014-experimental-analysis-statistical-workbench.md).

---

## 0. Design Philosophy: Generic Primitives First, Interactive & Graphical by Default

Our verified `tantra-ui-web` benchmark ([`elephant-edge-overlay.ts`](../../tantra-ui-web/src/lib/elephant-edge-overlay.ts) + [`stop-hunt-buffer-study.ts`](../../tantra-ui-web/src/lib/stop-hunt-buffer-study.ts)) proved two things on real Lakehouse v3 data (`2018–2026`):
1. Outer-band stop buffers (`+0.25 × ATR`) slash false stop-hunt traps (`12.2%–17.9%` → `1.5%–7.2%` on `1D`; `8.7%–13.0%` → `0%–2.2%` on `5m`) and rescue win rates.
2. Visualizing **bands, equilibrium, outer stop shields, and saved sweep diamonds** directly on candles immediately reveals *why* a trade worked or failed—far better than raw numbers alone.

Rather than building a one-off pipeline hardwired to Elephant Edge, this design factors the system into **five orthogonal, reusable primitive layers** so **any strategy** (`ElephantEdge`, `ORB-15`, `Qullamaggie`, `MeanReversion`, `EMA/RSI`, `Custom`) plugs into **one generic simulation/refinement loop**, renders **all buy/sell signals, bands, stops, indicators, hints, and option hedges graphically** across **Web, TUI, and CLI**, and stays **continuously interactive** for both the trader and the built-in AI Agent.

---

## 1. Primitive Architecture & Modular Factoring

```
 ┌──────────────────────────────────────────────────────────────────────────────┐
 │ Layer A: Composable Strategy & Market Primitives (tantra-market / strategies)│
 │  [SessionClock] + [SplitAdjuster]                                            │
 │        ├──▶ [ZoneExtractor]       (EE S1/S2/R1/R2, ORB, OB, Pivots, swings)  │
 │        ├──▶ [IndicatorEvaluator]  (ATR, EMA/SMA, VWAP, VolRatio, RSI, IV/RV) │
 │        ├──▶ [SignalPrimitive]     (Touch, RejectionWick, Breakout, Retest)   │
 │        ├──▶ [StopExitPolicy]      (TightLine, OuterEdge, AtrBuffer, Trail,   │
 │        │                           FixedHorizon, TimeStop, 3R/5R Ladder)     │
 │        ├──▶ [HedgeOverlayPolicy]  (PutCollar, CreditSpread, IronCondor, Roll)│
 │        └──▶ [FrictionModel]       (SpreadCostConfig: bid-ask, roll, STT/GST) │
 └───────────────────────────────────┬──────────────────────────────────────────┘
                                     ▼
 ┌──────────────────────────────────────────────────────────────────────────────┐
 │ Layer B: Generic Research & Optimization Loop Primitives                     │
 │  (tantra-market-finance + tantra-agent-research + tantra-runtime)            │
 │  - StrategyLoopKernel::eval(StrategyPipeline, DatasetSlice, ParamSet)        │
 │  - SweepRunner::run(SearchSpace, SplitPolicy{IS/OOS, WalkForward}, DSR)      │
 │  - InteractiveRefinementLoop (RefinementIterationLoop + Diff + PresetPin)    │
 └───────────────────┬───────────────────────────────────────┬──────────────────┘
                     ▼                                       ▼
 ┌──────────────────────────────────────────┐  ┌────────────────────────────────┐
 │ Layer C: Unified Graphical Scene Contract│  │ Layer D: Interactive User &    │
 │  `OverlayScene` (tantra-ui-charts / core)│  │ Agent Control Primitives      │
 │  6 grouped, toggleable primitive layers: │  │  - Layer visibility toggles    │
 │   1. Signals   (Buy/Sell/Sweep/Exit)     │  │  - Bar/Marker Hint Inspector   │
 │   2. Bands     (S1..R2/ORB/OB/FVG boxes) │  │  - Live What-If param sliders  │
 │   3. Stops/Tgt (SL, Outer-SL, BE, 3R/5R) │  │  - Loop stepper (Accept/Tweak) │
 │   4. Indicators(Overlay & Sub-pane lines)│  │  - Agent MCP/Chat loop tools   │
 │   5. Hints     (Annotated rationale pins)│  │    pushing live `OverlayScene` │
 │   6. Hedges    (Strike rays & payoff band│  │    diffs straight to UI/TUI    │
 └──────────┬──────────────────┬────────────┘  └────────────────────────────────┘
            ▼                  ▼
   Web (`vyapaar-bridge.js`   TUI (`ratatui` Canvas/Braille + Sparklines)
    + `ChartCanvas.tsx`)      & CLI (`tantra` ASCII/JSON/SVG reports)
```

---

### Layer A — Composable Strategy & Execution Primitives (Factoring by Concern)

Every strategy is decomposed into 6 swappable primitives (zero `f32`/`f64`, all `Decimal`, `wasm32`-clean in `tantra-market-finance`, mirrored in `tantra-strategies` Python SDK):

| Primitive | Responsibility | Generic Contract / Interface | Flagship Elephant Edge (`EE+`) Impl + Other Consumers |
|---|---|---|---|
| **1. `SessionClock & Hygiene`** | Slice multi-asset bars into regimes & scrub split artifacts | `slice_sessions(bars, asset_class, schedule, corporate_actions)` | NSE `09:15–15:30` (pre/post Sep 3 2025 expiry cutover), MCX `09:00–23:30`, `1D` monthly, `1W`/`1M` quarterly/annual; split-adjusted ATR guard (prevents `67×–82× ATR` jumps) |
| **2. `ZoneExtractor`** | Emit contextual price levels & zones per session/bar | `extract(bars, chain_opt) -> (ZoneBand[], LevelLine[], Hint[])` | **EE+**: `S1/S2/R1/R2` percentiles + `1.618×/2.618×` fallback + Dotted Equilibrium + Polarity Flip + OI/Gamma snap.<br>**Other**: `Orb15Extractor` (Tab 10), `OrderBlockExtractor`, `PdhPdlPivotExtractor`, `SwingConsolidationExtractor` (Qullamaggie) |
| **3. `IndicatorPrimitive`** | Compute named overlays & sub-pane series | `eval_indicators(bars, specs) -> IndicatorSeries[]` | `ATR(14)`, `EMA(10/20/50)`, `VWAP`, `VolumeRatio(20)`, `RSI`, `MarkovStateSeries`, `IV_vs_RV` |
| **4. `EntrySignalPrimitive`** | Evaluate entry triggers & micro-structure confirmation | `detect_signals(bars, zones, indicators) -> SignalEvent[]` | **EE+**: `zone_touch_close`, `rejection_wick` (hammer/pinbar/engulfing — fixes `INFY 1D` `1R` dilution), `breakout_plus_two`, `mid_month_cycle_gate`.<br>**Other**: `OrbBreakout`, `EmaCross`, `EpisodicPivot` |
| **5. `StopExitPolicy`** | Generic stop placement, trailing, runner & horizon rules | `simulate_exits(entry, bars, atr, zones) -> TradeOutcome` | `TightCenterLine`, `BandOuterEdge(+0.00 ATR)`, `OuterAtrBuffer(+k ATR)`, `PercentileShield(P75/P90)`, `PartialAndTrail(3R partial + BE + 5R)`, `TimeStop(n)`, `FixedHorizon(n)` |
| **6. `HedgeOverlayPolicy` & `FrictionModel`** | Pair directional/zone signals with F&O hedges net of real costs | `synthesize_hedges(signal, spot, zones, study_probs, chain_opt, expiry, friction)` | `Unhedged`, `ProtectivePutCollar`, `BullPutCreditSpread`, `BearCallCreditSpread`, `IronCondor` (outside `S1/R1 ± ATR` & `85%` move), `CalendarRoll`; applies `SpreadCostConfig` (bid-ask, futures roll basis, STT, GST, SEBI, stamp) |

**Why this factoring pays off immediately:**
- Swapping **`StopExitPolicy`** alone lets ANY strategy (`ORB-15`, `Qullamaggie`, `EMA Cross`, `EE+`) run the exact same **Tight SL vs. Outer-Buffer SL** stop-hunt benchmark!
- Swapping **`SessionClock`** runs the exact same strategy pipeline on **`NSE:NIFTY50`, `NSE:BANKNIFTY`, `NSE:RELIANCE-EQ`, `MCX:GOLD`, `MCX:CRUDEOIL`, `CDS:USDINR`** across **`intraday (5m/15m/1H)`, `weekly_expiry`, `monthly_expiry`, or `commodity_cycle`**.

---

### Layer B — Generic Evaluation, Parameter-Sweep & Interactive Refinement Loop

Build directly on existing [`tantra-agent-research`](../../tantra-agent/crates/tantra-agent-research/src/lib.rs) (`RefinementIterationLoop`, `ParameterSearchSpace`, `HypothesisJournal`, `StatisticalVerifier`) and `tantra-market-finance::studies`:

1. **`LoopStep` State Machine (Generic for User UI OR AI Agent)**:
   ```
   [Configure Pipeline & SearchSpace]
          │
          ▼
   [1. Evaluate Baseline] ──▶ Backtest KPIs + MAE/Penetration P50..P95 + OverlayScene
          │
          ▼
   [2. Sweep / Mutate Params] ──▶ Bounded Grid / Adaptive Search (IS 70% / OOS 30% + DSR + PBO)
          │
          ▼
   [3. Diff & Synthesize Hedges] ──▶ Side-by-side Delta KPIs + OverlayScene Diff + Expiry Hedge Plan
          │
          ▼
   [4. User Interactive Checkpoint] ──▶ Inspect Chart Hints ─▶ Tweak Slider ─▶ Re-run Step ─▶ Pin Preset / Stage TradePlan
   ```
2. **Stateful `LoopSession` (`tantra-runtime`)**:
   - Every run (whether triggered by a human slider in Web/TUI or an AI agent tool call) produces a deterministic `LoopRunSnapshot`:
     - `pipeline_spec` (which `ZoneExtractor`, `EntrySignal`, `StopExitPolicy`, `HedgeOverlay`, `FrictionModel`)
     - `param_values` & `search_bounds` (`StrategyParameterSpec[]`)
     - `baseline_vs_candidate` (Gross & Net `AvgR`, `Profit Factor`, `Win %`, `False-Sweep Trap %`, `SL Hit %`, `Sharpe`, `MaxDD`, `IS/OOS WFE`, `DSR`)
     - `penetration_stats` (`P50/P75/P90/P95/Max` excursion beyond band outer edge + `% Recovering`)
     - `expiry_recommendations` (`Day / Weekly / Monthly / Commodity Cycle` hedge structures)
     - **`scene: OverlayScene`** (ready to draw on Web Canvas, TUI `ratatui`, or CLI!)

---

### Layer C — Unified Graphical Scene Primitives (`OverlayScene`)

Extend [`tantra-ui-charts`](../../tantra-ui/crates/tantra-ui-charts/src/lib.rs) (which already has [`ZoneBand`](../../tantra-ui/crates/tantra-ui-charts/src/zones.rs), [`LevelLine`](../../tantra-ui/crates/tantra-ui-charts/src/levels.rs), [`SignalMarker`](../../tantra-ui/crates/tantra-ui-charts/src/markers.rs), [`StopLine`](../../tantra-ui/crates/tantra-ui-charts/src/stops.rs), [`ChartSeries`](../../tantra-ui/crates/tantra-ui-charts/src/series.rs)) and [`vyapaar-bridge.js`](../../tantra-ui-web/public/charts/vendor/vyapaar-bridge.js) from a single EE-only plugin into a **generic 6-layer `OverlayScene` primitive renderer**:

| Scene Group Key | Primitive Type | Visual Representation (Web Canvas & TUI `ratatui`) |
|---|---|---|
| **`signals`** | `SignalMarker` (extended) | ▲ Green Buy / ▼ Red Sell arrows, ◆ Cyan/Amber Sweep Diamonds (filled ring = tight SL hunted, outer SL survived), ✕ Stop/Target Exit badges, subtle trade-connector ray from entry to exit |
| **`bands`** | `ZoneBand` + `LevelLine` | Translucent shaded boxes (`S1/S2` teal, `R1/R2` amber, `ORB` slate, `OrderBlock` purple) with polarity auto-coloring + dotted Equilibrium / VWAP / Pivot lines |
| **`stops`** | `StopLine` (extended) | Dashed red `Tight SL`, dashed emerald/amber `Outer-Buffer Shield SL`, gold `Breakeven`, stepped `Trailing SL` staircase, and `2R/3R/5R Target` rays |
| **`indicators`** | `IndicatorSeries` | Overlay lines (`EMA`, `SuperTrend`, `ATR Envelope`) on main pane + synchronized sub-panes (`RSI`, `Volume Ratio`, `Rolling Expectancy / Drawdown`) |
| **`hints`** *(NEW)* | `HintAnnotation` | Clickable/hoverable micro-badges `(bar_idx, price, severity, title, detail, metrics)` — e.g., `"🛡 Sweep Saved (+2.4R)"`, `"⚠ Tight SL Hunted (-1R)"`, `"📅 Mid-Month Reversal Gate"`, `"🧱 OI Call Wall 24,500"` |
| **`hedges`** *(NEW)* | `HedgeLevelOverlay` | Distinct purple/indigo dashed strike lines (`Short PE 24,100`, `Wing PE 23,900`, `Short CE 24,600`), breakeven band shading, and mini payoff summary pill at right axis |

#### Graphical Parity Across All 3 Surfaces
1. **Web (`vyapaar-bridge.js` + `ChartCanvas.tsx`)**:
   - Replace the bespoke `ElephantZonesPrimitive` inside [vyapaar-bridge.js](../../tantra-ui-web/public/charts/vendor/vyapaar-bridge.js) with generic `window.vyapaarCharts.setOverlayScene(id, scene)` / `setSceneLayerVisibility(id, mask)` rendering all 6 primitive groups cleanly at 60fps in a single coordinate pass (`timeToCoordinate` / `priceToCoordinate`).
   - Synchronize sub-pane indicators (`RSI`, `ATR%`, `Rolling OOS R`) + Equity/Expectancy curve cleanly beneath the main candlestick chart.
2. **TUI (`tantra-tui` + `ratatui`)**:
   - Upgrade `tantra-tui` with an interactive **`Chart & Loop` / `Strategy Lab`** view using `ratatui::widgets::Canvas` (Braille high-res candlesticks, shaded ASCII/Braille `ZoneBand` regions, `▲`/`▼`/`◆` Buy/Sell/Sweep glyphs, horizontal `─SL─` / `─3R─` / `─Eq─` lines, sub-pane sparklines, and a bottom Hint/Inspector status strip).
   - Paired side-by-side with the **Benchmark / Sweep Frontier / Hedge Table** so terminal users get full graphical + numerical interactivity over SSH/headless machines.
3. **CLI (`tantra-cli`)**:
   - `tantra elephant` / `tantra study` renders Unicode tables, ASCII penetration histograms (`P50..P95`), inline signal/hint logs, and optional `--scene-json` / `--svg` export.

---

### Layer D — User Interactivity & AI-Human Co-Pilot Loop

Graphical output alone is passive; **user interactivity** is baked in as core primitives across Web and TUI:

1. **Interactive Layer Pill Bar** *(Web toolbar & TUI `[1..6]` hotkeys)*:
   - Individual toggles for `[Signals] [Bands] [Stops/Targets] [Indicators] [Hints] [Hedges]` + `"Compare Tight vs Buffered"` split toggle (shows *both* which trades got stopped on tight SL in red `✕` and which survived with outer SL in emerald `✓`!).
2. **Hover & Click / Cursor-Step Inspector**:
   - Clicking any Buy/Sell marker or Hint pin on the Web canvas (or moving the crosshair cursor `←`/`→`/`n`/`p` in `tantra-tui`) highlights the setup candle, its active zone band, its `Tight SL` vs. `Outer SL`, and opens a compact **Setup & Hint Card** (*Entry, 1R ₹, Tight outcome vs. Buffered outcome, Penetration × ATR, Matched Hedge Structure*).
3. **Live What-If Controls & Instant Scene Re-Plot**:
   - Interactive control strip attached to both the Chart tab and `Experimental-Analysis`:
     - **Strategy Selector** (`EE+ Outer Buffer`, `ORB-15`, `EMA/VWAP`, etc.)
     - **Parameter Tweakers**: `SL Buffer (ATR)` slider (`0.00–0.75`), `Entry Filter` (`Zone Touch` / `Rejection Wick`), `Exit Horizon` (`3 / 5 / 10 bars` / `3R–5R Trail` / `Expiry Close`), `Expiry Mode` (`Day` / `Weekly` / `Monthly` / `MCX Cycle`), `Friction` (`Gross` / `Net of Spread+STT`).
     - Tweaking any control runs `StrategyLoopKernel` and immediately updates **KPI cards + Comparison Table + `OverlayScene` markers/stops/hints** with a visual **"Delta Badge"** (e.g., `Trap %: 14.5% → 1.5%`, `PF: 0.96 → 1.16`).
4. **Bidirectional AI Agent Interactivity (`tantra-agent` + `ChatRail` / `tantra tui`)**:
   - The AI Agent uses the **exact same generic loop tools** (`strategy_loop_eval`, `strategy_loop_sweep`, `strategy_hedge_recommend`, `chart_scene_annotate`):
     - User: *"Test EE+ on MCX:GOLD 15m, tighten entry to rejection wicks, sweep SL buffer 0.15–0.50 ATR for weekly expiry, plot the winning setup + hints on my chart, and suggest a hedged option/futures structure."*
     - Agent runs the bounded sweep (`<= 64` grid combos with IS/OOS + **DSR** verification), returns structured comparison tables + **Day / Weekly / Monthly hedge card**, AND emits a `chart_scene_annotate` envelope so a **"Apply Winner to Chart"** button (in Web `ChatRail` / TUI `AgentChat`) loads the exact bands, buy/sell markers, hints, and hedge strikes directly into the user's chart!

---

## 2. F&O Expiry (`Day` / `Week` / `Month` / `Commodity`) & Hedge Synthesis Matrix

Consumed cleanly by `HedgeOverlayPolicy` from any directional or range strategy's `OverlayScene` + `ExperimentalStudyReport` + `PenetrationDistribution`:

| Regime / Signal Context | Target Expiry | Primary Directional / Range Play | Recommended Hedge Possibility | Strike, Outer-SL & Sizing Anchors |
|---|---|---|---|---|
| **Bullish Sweep at `S1`/`S2` + High Reversal % + Low/Moderate IV** | **Day (`0–1 DTE`)** | Long Future / ATM Call on `rejection_wick` reclaim | **Bull Call Spread** (capped overnight/gamma risk) or **Future + Hard `Outer-SL`** | Long ATM CE + Short `R1` or `80%` intraday move CE; invalidation at `S1_low − P75_ATR` |
| **Bullish Sweep at `S1`/`S2` + Overnight Hold** | **Weekly (`2–5 DTE`)** | Long Future or Synthetic Long | **Bull Put Credit Spread** OR **Collared Future (`+Protective PE`)** | Short PE at `S1_low − 0.25 ATR`, Protective PE wing at `S2_low − P90_ATR`; optional short CE at `R1` when Markov skew is neutral |
| **Bearish Sweep at `R1`/`R2` + Supply Defense (`+ΔOI`)** | **Weekly / Monthly** | Short Future or Bear Put Spread | **Bear Call Credit Spread** OR **Protective Call on Short Future** | Short CE at `R1_high + 0.25 ATR`, Protective CE wing at `R2_high + P90_ATR` |
| **Spot Inside Equilibrium + High Trap Rate (`>14%`) + `IV > RV`** | **Weekly / Monthly** | Range-bound Income | **Zone-Anchored Iron Condor** | Short PE below `min(S1_low − buffer, 85% lower move)`; Short CE above `max(R1_high + buffer, 85% upper move)`; wings past `P95` excursion |
| **Trend Hold across Monthly Expiry / MCX Cycle + Mid-Month (`15th ± 1d`) Extension (`>=2.5 ATR`)** | **Monthly / MCX** | Near-Month Future / Spot | **Protective Collar** or **Calendar / Diagonal Spread** | Long Future + Long Put at `S2 − 0.25 ATR` financed by Short OTM Call at `90%` upper bound (`R2`), capturing roll basis & capping `P95` gap risk |

Every synthesized hedge reports: **Exact Legs (`BUY/SELL FUT/CE/PE`)**, **Lot-Rounded Qty**, **Max Loss (₹ & % Equity)**, **Breakevens**, **`P95` Gap Stress Loss**, **Net Credit/Debit after STT/Exchange/GST/Spread**, and **Honest Chain Status** (`live_quotes` vs `theoretical_model` if chain lacks liquidity).

---

## 3. Phased Implementation Roadmap (Tracks `T21.1` – `T21.6`)

### Phase 1 — Core Quantitative & Scene Primitives (`tantra-market` & `tantra-ui-charts`) · Track `T21.1` ✅ Implemented (2026-11-20)
- **Deliverables**:
  - `tantra-market-finance::studies::pipeline`: Factor generic traits/structs (`ZoneExtractor`, `IndicatorPrimitive`, `EntrySignalPrimitive`, `StopExitPolicy`, `HedgeOverlayPolicy`, `StrategyLoopKernel`, `ParameterSweepRunner`).
  - Implement `ElephantZonesExtractor`, `RejectionWickFilter`, `OuterBufferStopPolicy`, `SplitArtifactGuard`, and `HedgeSynthesizer` in pure `Decimal` (`wasm32`-clean).
  - Add multi-asset `SessionClock` presets (`NSE Equity/F&O`, `NSE Sep 3 2025 Expiry`, `MCX Commodity`, `FX`).
  - Extend [`tantra-ui-charts`](../../tantra-ui/crates/tantra-ui-charts/src/lib.rs) with `HintAnnotation`, `HedgeLevelOverlay`, `TradeConnectorRay`, and unified **`OverlayScene`** container (`signals`, `bands`, `stops`, `indicators`, `hints`, `hedges`).
- **Verification**: `cargo test --workspace --profile prod`, golden-vector parity against our Lakehouse `NIFTYBEES`/`BANKBEES`/`RELIANCE`/`INFY` (`1D` & `5m`) benchmark results, and `wasm32` build green.

### Phase 2 — Strategy SDK Primitives & Generalized `ElephantEdgeV3` (`tantra-strategies`) · Track `T21.2` ✅ Implemented (2026-11-20)
- **Deliverables**:
  - Add Python SDK composition hooks (`ZoneExtractor`, `StopExitPolicy`, `OverlaySceneEmitter`) so strategies emit rich `OverlayScene` annotations (signals, bands, indicators, hints) automatically alongside `OrderRequest` / `StopProtection`.
  - Generalize [`ElephantEdgeStrategy`](../../tantra-strategies/tantra_strategies/strategies/elephant_edge.py) across `horizon_mode` (`intraday` | `weekly_expiry` | `monthly_expiry` | `commodity_cycle`), `entry_trigger_mode` (`zone_touch_close` | `rejection_wick`), `sl_mode`, and `hedge_mode`, plus a runnable `catalog_steps/signal/elephant_edge_v3` entry in [`registry.json`](../../tantra-strategies/registry.json).
  - Add a second strategy consumer (e.g., `Orb15` or `EmaPullback`) wired to the same `OuterBufferStopPolicy` + `OverlayScene` primitives to **prove cross-strategy generality**.
- **Verification**: `ruff check . && ruff format --check .`, `mypy`, `pytest -q` (tests across Index, F&O equity, and MCX commodity fixtures), `tools/validate_catalog.py`.

### Phase 3 — Stateful Loop Service, OpenAPI v2 & Live Chain Wiring (`tantra-runtime`) · Track `T21.3` ✅ Implemented (2026-11-20)
- **Deliverables**:
  - OpenAPI v2 DTOs in `tantra-runtime-api` for generic `StrategyLoopRequest/Response`, `StrategySweepRequest/Response` (IS/OOS + DSR), `ExpiryHedgeRequest/Response`, and serialized `OverlayScene`.
  - REST endpoints in `tantra-runtime-api-rest` :
    - `POST /api/v2/studies/strategy-loop/evaluate` (runs any registered strategy + buffer benchmark + returns `OverlayScene`)
    - `POST /api/v2/studies/strategy-loop/sweep` (runs parameter sweep + OOS/DSR + baseline-vs-winner scene diff)
    - `POST /api/v2/studies/strategy-loop/recommend-hedge` (synthesizes Day/Weekly/Monthly F&O & Commodity hedges with live `ChainReader` quotes or honest theoretical fallback)
  - Replace hardcoded `DefaultStrategyRunner` stubs by wiring real `StrategyRunner` + `StudyReader` + `ChainReader` at runtime composition root.
- **Verification**: `cargo test --workspace --profile prod`, `openapi.v2.json` schema parity, honest unavailable/partial tests when chains or bars are absent.

### Phase 4 — Unified Graphical Canvas & Interactive Controls in CLI & TUI (`tantra-ui`) · Track `T21.4` ✅ Implemented (2026-11-20)
- **Deliverables**:
  - Pure `Decimal` formatting & ASCII/Braille scene projector in `tantra-ui-core` (`OverlayScene` → TUI Canvas primitives, KPI tables, Sweep Delta rows, Hedge cards).
  - **TUI (`tantra-tui`)**: Interactive **`Strategy Lab / Chart`** view using `ratatui::widgets::Canvas` + `Sparkline` displaying candlesticks, shaded bands (`S1/S2/R1/R2`), `▲`/`▼`/`◆` Buy/Sell/Sweep signals, `─SL─`/`─Outer SL─`/`─3R─` lines, sub-pane indicators, cursor-steppable **Hint Inspector**, `[1..6]` layer toggles, interactive parameter tweaks, and `/ee-study`, `/loop-eval`, `/loop-sweep`, `/hedge` slash commands.
  - **CLI (`tantra-cli`)**: Live `tantra elephant` & `tantra study-loop` commands supporting `--strategy`, `--symbol`, `--tf`, `--horizon`, `--sweep`, `--hedge`, `--json`, `--export-scene`.
- **Verification**: `cargo test --workspace --profile prod`, deterministic TUI layout & CLI snapshot tests across Index/F&O/Commodity.

### Phase 5 — Interactive Multi-Layer Canvas & What-If Workbench in Web (`tantra-ui-web`) · Track `T21.5` ✅ Implemented (2026-11-21)
- **Deliverables**:
  - Refactor `ElephantZonesPrimitive` in [vyapaar-bridge.js](../../tantra-ui-web/public/charts/vendor/vyapaar-bridge.js) into a generic **`OverlayScenePrimitive` engine** rendering all 6 primitive groups (`signals`, `bands`, `stops`, `indicators`, `hints`, `hedges`) + hover hit-testing + sub-pane indicator sync.
  - Add **Interactive Layer Pill Bar** (`Signals | Bands | Stops | Indicators | Hints | Hedges | Tight-vs-Buffered Diff`) and **Setup/Hint Inspector Drawer** to [`ChartCanvas.tsx`](../../tantra-ui-web/src/components/organisms/ChartCanvas.tsx) & [`ChartToolbar.tsx`](../../tantra-ui-web/src/components/organisms/ChartToolbar.tsx).
  - Upgrade [`StopHuntBufferPanel.tsx`](../../tantra-ui-web/src/components/organisms/experimental-analysis/StopHuntBufferPanel.tsx) into an interactive **Strategy Loop & Hedge Workbench**: strategy selector (`EE+`, `ORB-15`, etc.), live parameter sliders (`SL Buffer ATR`, `Entry Filter`, `Expiry Horizon`), IS/OOS + DSR sweep leaderboard, hedge legs card, and **"Plot Scenario on Chart"** action.
- **Verification**: `npx tsc --noEmit && npm run lint && npm test` + live Playwright visual & interaction tests (toggling each of the 6 layers, clicking a signal hint, adjusting slider & verifying live scene + table update).

### Phase 6 — Generic AI Agent Loop Tools, Visual Push & Docs (`tantra-agent` & `tantra-docs`) · Track `T21.6` ✅ Implemented (2026-11-21)
- **Deliverables**:
  - Register 4 generic `ToolRisk::ReadOnly` tools in `tantra-agent-chat-tools` & `tantra-agent-mcp`:
    1. `strategy_loop_eval`: Evaluate any strategy (`elephant_edge`, `orb_15`, etc.) on any symbol/TF/horizon + return KPIs + `OverlayScene` summary.
    2. `strategy_loop_sweep`: Tweak parameter search spaces (`sl_buffer_atr`, `entry_trigger_mode`, `percentiles`, `targets`) with bounded grid + IS/OOS + DSR audit.
    3. `strategy_hedge_recommend`: Generate Day / Weekly / Monthly F&O & Commodity hedge structures anchored on zones, outer buffers, Markov states, and option chains.
    4. `chart_scene_annotate`: Package a tested candidate's Buy/Sell signals, bands, stops, indicators, **Hints**, and hedge strikes into a structured `TantraResultEnvelope` action so **ChatRail (Web)** and **AgentChat (TUI)** render both the numerical summary AND a one-click **"Render on Chart"** action.
  - Connect existing `strategy_run` / `strategy_tune` / `strategy_suggest` tools to the real runtime loop engine.
  - Update [`tantra-docs/docs/strategies/elephant-edge/`](../../tantra-docs/docs/strategies/elephant-edge/index.md) and user guides with generic loop, graphical layer, and Day/Week/Month expiry hedge workflows.
- **Verification**: `tantra-agent` dependency-rules tests, `tantra-agent-mcp` tool count pins, E2E agent loop integration tests (`research` + `chat-tools`), and `mkdocs build --strict`.

---

## 4. Per-Repo Child Plan Mapping

| Track | Owning Repo | Child Plan Target |
|---|---|---|
| `T21.1` | `tantra-market`, `tantra-ui` (`charts`) | ✅ Implemented — recorded in [`tantra-market/docs/plans/README.md`](../../tantra-market/docs/plans/README.md) (`0004`) & `tantra-ui-charts::scene` |
| `T21.2` | `tantra-strategies` | ✅ Implemented — recorded in [`tantra-strategies/docs/plans/README.md`](../../tantra-strategies/docs/plans/README.md) (`0004`) |
| `T21.3` | `tantra-runtime` | ✅ Implemented — recorded in [`tantra-runtime/docs/plans/README.md`](../../tantra-runtime/docs/plans/README.md) (`0011`) |
| `T21.4` | `tantra-ui` (`core`, `tui`, `cli`) | ✅ Implemented — recorded in [`tantra-ui/docs/plans/README.md`](../../tantra-ui/docs/plans/README.md) (`0009`) |
| `T21.5` | `tantra-ui-web` | ✅ Implemented — ui-web `73ecd1e` (sub-pane strip), `4b5618b` (workbench, layer pills, hint inspector, scene bus), `8a1c7c9` (ChatRail Render on Chart + main-chart scene bar); Playwright tests not added (no Playwright in repo) |
| `T21.6` | `tantra-agent`, `tantra-runtime`, `tantra-ui`, `tantra-docs` | ✅ Implemented — [`tantra-agent/docs/plans/0018`](../../tantra-agent/docs/plans/0018-generic-loop-sweep-hedge-and-scene-tools.md) (agent `9925588`, runtime `9d69b8c`, ui `b85eba1`, docs `cb81295`) |

---

## 5. Acceptance Criteria

1. **Multi-strategy reuse**: At least two distinct strategies (`ElephantEdgeV3` + `ORB-15`) execute through the exact same `StrategyLoopKernel` + `StopExitPolicy` + `ParameterSweepRunner` + `OverlayScene` pipeline without strategy-specific UI code.
2. **Full graphical coverage across Web & TUI**: Users can visually see and interactively toggle **Buy/Sell signals, Zones/Bands, Tight vs Outer-Buffer Stops & Targets, Indicators, Rationale Hints, and Option Hedge Strikes** on both `ChartCanvas` (Web) and `tantra-tui` (`ratatui` Canvas).
3. **Interactive human + AI loop**: Adjusting a slider in UI/TUI or asking the AI agent to tweak parameters runs IS/OOS + DSR verification, highlights exact KPI deltas, and updates the live graphical `OverlayScene` + F&O Expiry Hedge card without mutating `tantra-core` or placing unapproved orders.
