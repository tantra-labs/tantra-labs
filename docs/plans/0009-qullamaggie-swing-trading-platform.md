# 0009 — Qullamaggie Multi-Market Swing Trading Platform (India NSE/BSE & US Equities)

**Status**: Proposed  
**Date**: 2026-11-15  
**Target Scope**: `tantra-core`, `tantra-market`, `tantra-data`, `tantra-strategies`, `tantra-runtime`, `tantra-exec`, `tantra-risk`, `tantra-ledger`, `tantra-adapters`, `tantra-agent`, `tantra-ui`, `tantra-ui-web`, `tantra-docs`  
**Type**: Cross-repo master plan (consolidates primary/secondary Qullamaggie research, codebase capability audit, and phased multi-repo roadmap)  
**Provenance Tags Used Throughout**:
- **P** — Primary source: Kristjan Kullamägi's own blog posts, FAQ, comments (`qullamaggie.com`), or ASR stream transcripts (`peterdmv/qullamaggie-mcp`, `sozai.app`).
- **C** — Community reconstruction or third-party implementation (e.g., Boomerberg thread, CWT notes, `Laws of Swing`, Stonks Capital, `base.report`, `VladPetrariu`, `PatelNicknp/nicks-india-stock-desk`).
- **E** — Engineer-chosen proxy proposed where no source gives an exact number; **all E-tagged thresholds MUST be exposed as bounded TOML manifest parameters**, never hard-coded.

---

## 0. Executive Summary & Objective

Build Tantra's cross-sectional, point-in-time, end-of-day **multi-market swing-trading foundation**, with Kristjan Kullamägi's ("Qullamaggie") three setups (**Breakout**, **Episodic Pivot**, **Parabolic Short**) as its first tenant:

1. **Cross-Sectional Leader Selection & Market Profiles**: Rank the full listed equity universe by 1-, 3-, and 6-month performance (retaining the top 1–2% US / 2–3% India), filtered by **ADR%(20)** and account-scaled liquidity floors, evaluated under explicit **market profiles** (`India NSE/BSE` vs `US Equities`) covering sessions, circuit bands, shortability, currency, and settlement/costs.
2. **Setup Detection & Opening-Range Execution Mechanics**: Detect tight multi-week consolidations above rising 10/20/50 SMAs (Breakout), 10%+ catalyst gaps with surging early volume (Episodic Pivot), and multi-day blow-off extensions (Parabolic Short), entering on 1-/5-/30-minute opening-range breaks with a hard stop at the entry-day extreme capped at $\le 1\times\text{ADR}\%$ and an extension guard ($\le 1\times\text{ATR}$ intraday).
3. **Positioning & Exit Discipline**: Risk 0.25–1% of equity per trade (default 0.5%), cap overnight single-stock exposure (default 25%, ceiling 30%) and participation ($\le 1\%$ of ADV20), prohibit averaging down, support optional day 3–5 partial booking + breakeven move, and trail the remainder on first daily close beyond the 10- or 20-day SMA.
4. **Regime Harness, Back Watchlist & AI/Journal Layer**: Enforce a 4-level index 10/20 SMA regime filter (automated block in worst regime; warn-and-acknowledge with audit log for manual overrides), snapshot every qualifying candidate into an automated **back watchlist** to track forward 5/10/20-day follow-through and a live **"breakouts working" breadth gauge**, grade qualitative catalysts via `tantra-agent` (strictly grounded to ingested data, outputting `"unknown"` when absent), and track per-setup, per-regime $R$-multiples and drawdown statistics in the trade journal.
5. **India-First & Evidence-Gated Rollout**:
   - **Phase 3 deliverable (no execution risk)**: Ship India EOD leader scanning, setup tagging, regime state, and back-watchlist tracking first; US scanning follows as soon as EOD data lands.
   - **Honest automation posture**: Public mechanized breakout backtests show only a thin, bull-regime-dependent edge (+1.76% mean, >50% losers, negative in 2008/2022) because discretionary selection ("passes on ~99% of tracked setups") carries most of the outperformance. Mechanical rules are therefore framed as **candidate generation + hard risk guardrails + checklist/journal**, and automated order routing is gated behind a 6-stage validation ladder (**Stages A–F**).
   - **Parabolic Short restraint**: Ships **last**, disabled by default, alert-only in Phase 3, and restricted in India to the **F&O stock-futures universe**.

---

## 1. Verified & Unverified Current State (Inspection Baseline: 2026-11-14)

> **Inspection caveat**: Facts below come from directory outlines, schema inspection, and targeted searches across all `tantra-labs` submodules ("Present" confirms the module exists, not full completeness). **Phase 0** requires reading implementation bodies for the **9 Unverified items** before filing per-repo `docs/gaps/XXXX-*.md` files.

### Architecture & Platform Context
- Root platform: Rust core workspace (`tantra-core`, `tantra-ledger`, `tantra-risk`, `tantra-market`, `tantra-exec`, `tantra-runtime`, `tantra-agent`, `tantra-ffi`, `tantra-ui`) + Python domain/SDK (`tantra-strategies`, `tantra-adapters`, `tantra-data`, `tantra-examples`) + web/docs (`tantra-ui-web`, `tantra-docs`).
- **Hard invariants**: Zero-I/O domain crates (`tantra-core`, `tantra-ledger`, `tantra-risk`); strict no-floats (`Decimal` everywhere for prices, quantities, balances); SEBI regulatory controls first-class.
- **Structural shift vs. Elephant Edge ([plan 0005](0005-elephant-edge-strategy-platform.md))**: EE+ is intraday index/F&O price-action. Qullamaggie is multi-day/multi-week single-stock swing trading selected via **cross-sectional rank**, stressing universe breadth, corporate-action-adjusted EOD history (including delisted names), pre-open/open liquidity, circuit limits, and overnight risk rather than tick latency.

### Subsystem Audit Summary
- **Screener (`tantra-market/crates/tantra-market-indicators/src/screener.rs`, 434 lines)**:
  - *Present*: `FilterOp`, `ScreenerFilterPredicate`, `ScreenerFilterGroup`, `Timeframe` (`1m`/`5m`/`15m`/Daily/Weekly/Monthly), per-symbol `evaluate_predicate` / `evaluate_group` over `&[Bar]`.
  - *Missing*: Only supports OHLCV, 52-week high/low, `Sma(n)`, and `Rsi14`. No `ADR%`, no `ATR%`, no average traded value, no N-day % gain (21/22, 63/67, 126 bars), no EMA, no gap%, no RVol, no distance from MA, no consecutive-up-day streak, and **no cross-sectional rank/percentile** across a universe. Internally converts `Decimal` to `f64` (needs an explicit architectural decision vs. the no-floats invariant).
- **Indicators (`tantra-market-indicators/src`)**:
  - *Present*: ~40 indicator files (`sma`, `ema`, `rma`, `atr`, `adx`, `bollinger`, `donchian`, `keltner`, `vwap`, `roc`, `rsi`, `macd`, `supertrend`, `obv`, `mfi`, `cpr`, `pivot_points`, etc.).
  - *Missing*: Zero hits for `adr_pct` or `average_daily_range` in Rust or Python.
- **Signal Detectors (`tantra-market/crates/tantra-market-signals/src/detectors`)**:
  - *Present*: `orb.rs` (first $N$ bars opening-range breakout, default 15m), `cpr_breakout`, `levels`, `momentum`, `price_action`, `trend`, `volume`, `vwap_cross`, `Detector` trait, `Firing`.
  - *Missing*: No consolidation/flag tightness, MA-surfing, or higher-lows detector; no episodic-pivot gap detector (zero hits for `gap_up` / `gap_pct`); no parabolic-extension detector; no 1-/5-/30-minute configurable daily-preconditioned ORB variant; no index 10/20 SMA regime gate; breadth indicators exist only inside `tantra-examples/_kernel/indicators/breadth`.
- **Universe, Reference Data & Lakehouse (`tantra-market-finance`, `tantra-data`)**:
  - *Present*: `tantra-market-finance` exposes `StaticUniverse { as_of, symbols }`, `calendar.rs`, `costs.rs`, `expiry.rs`, `settlement.rs`, `rules.rs`, `profile.rs`, `india/`. `tantra-data` has DuckDB/Parquet lakehouse, corporate actions, earnings calendar modules, and Rust projection bridges for institutional flows, news/filings, corporate actions, delivery, fundamentals, mutual funds, and IPOs (per T5/T6/T7 progress).
  - *Missing / Gaps*: No `DynamicUniverse` trait with point-in-time historical membership; breadth of NSE/BSE EOD coverage & delisted-stock retention unverified; per-symbol circuit band and historical F&O membership exposure as screener columns unverified; fundamentals/EPS-surprise **real ingestion** depth vs. projections remains constrained (`tantra-data` NSE holiday provider `0015` open; verify fundamentals `0020` ingestion completeness vs. schema); **zero US market support** (zero hits for Polygon, Alpaca, IBKR, FMP, NASDAQ, NYSE).
- **Strategy SDK & Catalog (`tantra-strategies`)**:
  - *Present*: `Strategy` lifecycle (`on_start`/`on_bar`/`on_tick`/`on_order_event`/`on_stop`), `IndicatorRegistry` (SMA/EMA/RSI/ATR/Bollinger), `size/fixed_fractional`, TOML manifest parameterization (`turtle_breakout` etc.), plus recently added stop-protection/level interfaces (`sdk/stop_protection.py`, `sdk/levels.py` from EE+ SDK prep).
  - *Missing*: Multi-symbol **universe/scan-driven** strategy loop, account `equity()` access on `StrategyContext` for risk-% sizing, native **partial-exit** & EOD close-based **SMA trailing-stop** execution semantics in production, mixed **daily setup + intraday ORB bar** access, and Qullamaggie manifests (`swing/qm_breakout`, `swing/qm_episodic_pivot`, `swing/qm_parabolic_short`).
- **Backtest, Jobs & Enhancer (`tantra-runtime`)**:
  - *Present*: Event-driven `tantra-runtime-backtest`, `tantra-runtime-enhancer` (GA/WFO off bounded TOML params), `tantra-runtime-jobs` (cron/pool), `tantra-runtime-api-rest`.
  - *Missing / Unverified*: Universe backtesting mode (daily cross-sectional re-ranking, survivorship-free membership, mixed daily+intraday resolution, circuit-locked zero-fill modeling) is unverified; no scheduled scan jobs or back-watchlist persistence/forward-outcome jobs exist.
- **Execution, Risk, Ledger (`tantra-exec`, `tantra-risk`, `tantra-ledger`, `tantra-adapters`)**:
  - *Present*: Dhan + Zerodha feeds real (root gap `0001` for remaining feeds); 7 Indian broker SDKs; SEBI pre-trade risk gate (`price bands`, `kill-switch`, `OTR`); `tantra-ledger` OMS + FIFO tax lots + journal.
  - *Missing / Unverified*: Overnight delivery handling, persistent stop-market & breakeven/trail modifications, gap-through-stop fills, F&O single-stock-futures short routing, risk rules for per-trade equity risk / overnight weight / 1% ADV participation / no averaging down / earnings proximity / circuit headroom, and whether `tantra-ledger` journal supports R-multiples, setup tags, and drawdown duration analytics.
- **AI Agent & UI (`tantra-agent`, `tantra-ui`, `tantra-ui-web`)**:
  - *Present*: `tantra-agent` trader loop, calendar/fundamental ports, Typst/Markdown reports; `tantra-ui` CLI/TUI/WASM studio screener (T10 shipped `LiveData` TUI panels & `scan --server` CLI); `tantra-ui-web` workstation.
  - *Missing*: Method-specific catalyst grading/focus-list narration/checklist/journal review tools in `tantra-agent`; chart level/trendline alert primitives (`tantra-ui` gap `0007`), dynamic back-watchlist & theme-board views, and resolved choice of unified UI home (`tantra-ui` vs `tantra-ui-web`).

### The 9 Unverified Code Checks (Required in Phase 0)
Before filing granular gaps under `docs/gaps/XXXX-*.md`, inspect source implementations for Gap Table rows **7, 8, 11, 12, 25, 26, 27, 28, 32** (especially rows 25, 26, 28, 32, which could turn from "new build" into "extend existing"):
1. **Row 7**: Extent of NSE/BSE EOD coverage and delisted-ticker retention in `tantra-data`.
2. **Row 8**: Whether `tantra-data` / `tantra-market-finance` (`rules.rs`, `india/`) expose per-symbol price-band % and F&O list membership as queryable reference columns.
3. **Row 11**: News / earnings-catalyst text feed coverage in `tantra-data` (Moneycontrol/filings bridges) and consumption in `tantra-agent`.
4. **Row 12**: Exact contents of `tantra-market-finance/src/profile.rs` vs needed multi-market profile fields.
5. **Row 25**: Which pre-trade/portfolio risk checks already exist in `tantra-risk` vs missing swing rules (risk cap, overnight single-name weight, 1% ADV participation, no-averaging-down, earnings proximity, circuit headroom).
6. **Row 26**: Overnight delivery product tags (`CNC`), persistent broker stop-market orders, and gap-through-stop simulation in `tantra-exec` / `tantra-adapters` / `tantra-runtime-backtest`.
7. **Row 27**: Single-stock futures short routing in `tantra-exec` / `tantra-market-finance/src/expiry.rs`.
8. **Row 28**: Multi-symbol daily re-ranking, survivorship-free membership, and mixed daily+intraday bars in `tantra-runtime-backtest`.
9. **Row 32**: Capabilities of `tantra-ledger` journal and `tantra-agent` report models for setup tags, $R$-multiples, expectancy-by-setup/regime, and drawdown-recovery curves.

---

## 2. Capability Gap Audit (34 Capabilities)

> Rows marked **`Blocked`** / **`Gating`** (`#2`, `#4`, `#6`, `#21`, `#22`, `#28`) gate downstream strategy and backtest work. Each `Missing`, `Partial`, or `Extend` row yields one gap doc in the owning repo's `docs/gaps/` once Phase 0 closes the unverified items.

| # | Capability Required | Owning Repo / Module | Status | Evidence & Note |
|---|---|---|---|---|
| 1 | SMA, EMA, ATR, VWAP, ROC, RSI | `tantra-market-indicators` | **Present** | ~40 indicator files present |
| 2 | **ADR%(20)** indicator *(Gating)* | `tantra-market-indicators` | **Missing** | No `adr_pct` / `average_daily_range` in Rust or Python; must implement FAQ avg-of-ratios formula |
| 3 | Screener metrics: N-day % gain (21/22, 63/67, 126), gain from N-day low, avg traded value, gap%, RVol, dist-from-MA, streak, EMA | `tantra-market-indicators/src/screener.rs` | **Missing** | Currently only OHLCV, 52w H/L, `Sma(n)`, `Rsi14` |
| 4 | **Cross-sectional rank / percentile** across universe *(Gating)* | `tantra-market-indicators` (universe-scan evaluator) | **Missing** | Evaluates single-symbol `&[Bar]`; "top 1–2%" unexpressible |
| 5 | Decimal-safe scan maths | `tantra-market-indicators/src/screener.rs` | **Partial** | Converts `Decimal` to `f64` internally; needs explicit exemption or Decimal rewrite |
| 6 | **Dynamic, point-in-time, liquidity-filtered universe** *(Gating)* | `tantra-market-finance/src/universes.rs`, `tantra-data` | **Missing** | Only `StaticUniverse { as_of, symbols }` exists |
| 7 | CA-adjusted daily history for full listed universe + delisted names | `tantra-data` | **Partial / Unverified** | Point-in-time corporate actions exist; NSE/BSE breadth & delisted retention unverified |
| 8 | Per-symbol circuit band & F&O-membership reference columns | `tantra-data`, `tantra-market-finance` (`rules.rs`, `india/`) | **Unverified** | Used inside `tantra-risk` gate; screener/reference-column exposure unverified |
| 9 | Results / earnings-date calendar bridged to Rust | `tantra-data` (`domain/calendar.py`), `tantra-runtime-api-rest` | **Partial** | Exists in some form; depth unverified; NSE holiday provider (`data 0015`) open |
| 10 | Fundamentals: EPS & revenue YoY growth, surprise/beat, estimates | `tantra-data` | **Partial / Missing** | Chat schema/bridge (`data 0020`) landed; verify real historical point-in-time EPS/sales surprise ingestion |
| 11 | News / catalyst text feed (earnings/guidance headlines) | `tantra-data` → `tantra-agent` | **Unverified** | Moneycontrol RSS / filings bridges landed in T5; verify catalyst-grading suitability |
| 12 | Market profile contract (sessions, pre-open, bands, shortability, currency, liquidity, regime index) | `tantra-core`, `tantra-market-finance` (`profile.rs`) | **Unverified** | `profile.rs` exists; current rules/calendars/costs are India-only |
| 13 | Parameterized Opening-Range detector (1m/5m/30m + daily precondition) | `tantra-market-signals/detectors/orb.rs` | **Partial** | Present with first-N-bars (default 15m); add 1m/5m/30m + setup precondition |
| 14 | Consolidation / flag tightness, MA-surf & higher-lows detector | `tantra-market-signals/detectors` | **Missing** | No multi-week base / VCP / flag detector |
| 15 | Episodic-pivot (EP) gap + opening-volume detector | `tantra-market-signals/detectors` | **Missing** | Zero hits for `gap_up` / `gap_pct` |
| 16 | Parabolic-extension detector | `tantra-market-signals/detectors` | **Missing** | Zero hits |
| 17 | Index SMA10/SMA20 4-level regime state | `tantra-market-signals` | **Missing / Unverified** | Generic `regime` exists across files; no Qullamaggie 10/20 order+slope state |
| 18 | Breadth & "breakouts working" gauge | `tantra-market` (promote from `tantra-examples`), `tantra-runtime-jobs` | **Missing** | Breadth indicators sit only in `tantra-examples/_kernel` |
| 19 | Scheduled scan jobs (weekly/nightly/pre-open/hourly) & persisted outputs | `tantra-runtime-jobs`, `tantra-data` | **Missing** | Job pool exists; no scan scheduler or result tables |
| 20 | **Back watchlist**: candidate snapshot + forward 5/10/20d outcome tracking | `tantra-runtime-jobs`, `tantra-data` | **Missing** | New capability |
| 21 | **Strategy SDK**: multi-symbol universe loop, `equity()`, daily+intraday access *(Gating)* | `tantra-strategies` SDK | **Missing** | `StrategyContext` lacks `universe()`, `equity()`, mixed-TF history (stop/level prep shipped in `53bd2e0`) |
| 22 | **Production stop, trailing-stop (SMA close) & partial-exit primitives** *(Gating)* | `tantra-strategies`, `tantra-exec`, `tantra-ledger` | **Missing** | EE+ SDK stubs exist; production OMS/exec SL/partial/EOD-SMA-trail not wired end to end |
| 23 | Risk-fraction stop-distance sizing with weight & 1% ADV caps | `tantra-strategies` (`size/`) | **Partial** | `fixed_fractional` exists; stop-distance + ADV/weight cap sizer needs `equity()` (row 21) |
| 24 | Swing strategy manifests (`swing/qm_breakout`, `qm_episodic_pivot`, `qm_parabolic_short`) | `tantra-strategies` catalog | **Missing** | Nearest is `trend/turtle_breakout` (single instrument, fixed qty) |
| 25 | Risk-gate swing rules: per-trade risk, overnight weight, ADV cap, no-avg-down, earnings guard, circuit headroom, regime gate | `tantra-risk` | **Unverified** | SEBI bands/kill-switch present; verify which swing/portfolio rules exist |
| 26 | Overnight delivery handling (`CNC`), persistent market stops, gap-through-stop fills | `tantra-exec`, `tantra-adapters` | **Unverified** | Not inspected for swing multi-day order lifecycle |
| 27 | Single-stock futures as overnight short vehicle | `tantra-exec`, `tantra-market-finance` (`expiry.rs`) | **Unverified** | Platform is F&O-aware; stock-futures short leg routing unverified |
| 28 | **Survivorship-free universe backtest**: daily re-rank, daily+intraday bars, circuit lockouts *(Gating)* | `tantra-runtime-backtest` | **Unverified** | Event engine exists; cross-sectional universe mode unverified |
| 29 | Walk-forward / GA parameter validation | `tantra-runtime-enhancer` | **Present** | Works off bounded TOML manifest params |
| 30 | Pre-open call-auction data & 1m/5m ORB bars for leader pool | `tantra-market` feeds | **Partial / Unverified** | Dhan & Zerodha real (`root gap 0001`); pre-open equilibrium capture unverified |
| 31 | AI layer: catalyst grader, focus-list narration, pre-trade checklist, journal review | `tantra-agent` | **Partial** | Trader loop, calendar/fundamental ports & reports exist; method-specific prompts/tools absent |
| 32 | Trade journal: setup tags, $R$-multiples, per-setup/regime expectancy, time-in-drawdown & recovery curve | `tantra-ledger`, `tantra-runtime-api-rest`, `tantra-agent` | **Unverified** | Ledger journal exists; swing telemetry depth unverified |
| 33 | Scanner UI, dynamic watchlists, chart levels + trendline-attached alerts, theme board | `tantra-ui`, `tantra-ui-web` | **Partial** | T10 shipped TUI panels/CLI scan; `tantra-ui 0007` (chart annotations) open; `tantra-ui-web` separate |
| 34 | **US Equities track**: data vendor, broker adapter, calendar, costs, SEC/FINRA/PDT risk rules | `tantra-data`, `tantra-adapters`, `tantra-market-finance`, `tantra-risk`, `tantra-exec` | **Missing** | Zero source hits for any US exchange, vendor, or broker |

---

## 3. Binding Strategy Contract & Parameter Provenance

Every **E**-tagged value below MUST live in bounded strategy/profile configuration (`TOML`), never as an unconfigurable constant. Conflicting community reconstructions are preserved explicitly for ablation testing rather than averaged.

### 3.1 Shared Universe & Trade Skeleton

| Element | Rule / Formula | Value / Default | Tag | Source & Conflicts |
|---|---|---|---|---|
| **ADR%(20)** | $100 \times \left(\frac{1}{20}\sum_{i=0}^{19}\frac{H_i}{L_i} - 1\right)$ (average of ratios, NOT ratio of averages; intraday range only) | 20 sessions | **P** | [FAQ](https://qullamaggie.com/faq/). Conflict: 14-day rolling / ratio-of-averages variants are **C** (`Tikam Alma`, `Laws of Swing`). |
| **Leader Rank** | Cross-sectional percentile of gain over 1m, 3m, and 6m windows | Top 1–2% (percentile $\ge 98\text{--}99$; looser 90–95%) | **P** | [Setups post](https://qullamaggie.com/my-3-timeless-setups-that-have-made-me-tens-of-millions/). Stream also cites top 7% / ~50 names (`STS transcript`). Optional 12m/18m CWT variant is **C**. |
| **Window Combination** | Pass percentile cutoff on **any** of the 3 windows (union) vs all (intersection) | Default: union (`any of 3`) | **E** | He runs 3 separate scans; union vs intersection unspecified. |
| **Gain Measure & Windows** | Selectable: from-low ($C / \min(L, N) - 1$ over 22/67/126d) vs point-to-point ($C / C_N - 1$ over 21/63/126d) | Implement both as selectable scan columns | **P/C** | From-low `22/67/126` (`STS transcript`); `c/minl63` (`Boomerberg`); point-to-point `21/63/126` (`Laws of Swing`). |
| **Rank Timing** | Rank universe before or after liquidity/ADR filters | Default: **after** liquidity filter (configurable) | **E** | Unspecified in primary sources. |
| **ADR Floor** | Minimum `ADR%(20)` | 3.5–4% (large acct), 5–6% (smaller accts); see §3.3 | **P** | `STS transcript` / `Boomerberg` / `FWTV`. |
| **Liquidity Floor** | $\text{AvgDailyTradedValue}_{20} \ge \text{Equity} \times K$, $K \in [20, 50]$ | Account-scaled (approx. `pos_size / participation_cap`) | **P/E** | `STS transcript`. Community fixed cutoffs conflict heavily: `$1.5M`, `$3M`, `$10M`, `$100M` (**C**). |
| **Participation Cap** | Max order/position shares $\le 1\%$ of `ADV20` | `1.0%` hard cap | **P** | [Stream 2021-02-12](https://www.youtube.com/watch?v=siYpCaiuPKg). |
| **Risk Per Trade** | Equity fraction at initial stop distance | `0.25%–1.0%`, default `0.5%` | **P** | [FAQ](https://qullamaggie.com/faq/) (`0.3–0.5%` typical, `<1%` ceiling; `0.5–1.5%` when account < few $M). |
| **Position Sizing Formula** | $\text{qty} = \min\left(\left\lfloor\frac{\text{Equity} \times r\%}{|P_{\text{entry}} - P_{\text{stop}}|}\right\rfloor, \left\lfloor\frac{\text{Equity} \times w_{\max}}{P_{\text{entry}}}\right\rfloor, 0.01 \times \text{ADV}_{20}\right)$ | Typical result `10–20%` weight | **P/E** | Formula implied by `0.5%` risk + `2.5–5%` stop = `10–20%` weight. |
| **Overnight Position Cap** | Max single-stock / single-ETF overnight equity weight | Default `25%`, hard ceiling `30%` | **P** | Blog (`30%` overnight), transcript (`25%` ever), stream (`20–25%`). Intraday may exceed (`30%` blog). |
| **No Averaging Down** | Reject any add to an existing position below entry price (pyramid up only on new setup) | Hard block | **P** | [Stream 2020-03-16](https://www.youtube.com/watch?v=kmSFnqIL6Hk). |
| **Stop Order Type** | Always **stop-market** (never stop-limit) | Hard | **P** | [FAQ](https://qullamaggie.com/faq/). |
| **Max Positions & Heat** | Target max concurrent positions | `15–20` names; heat limit exposed as **E** param | **C/E** | Max positions from `CWT`; portfolio heat unspecified anywhere. |
| **Index Regime Filter** | 4-level state over profile benchmark `SMA10` vs `SMA20`: (1) $10>20$, both rising (`Favorable`); (2) $10<20$ or 1 flat/down (`Caution`); (3) $10$ sloping down (`High Caution`); (4) $10<20$, both sloping down (`No Breakouts`) | Default slope lookback `5` bars (**E**) | **P/E** | [Stream 2020-10-30](https://www.youtube.com/watch?v=1gmFq2IsTYY). Secondary `EMA10/20` (`FWTV`) or `SPY > EMA140` (`Stonks`) are **C**. |

### 3.2 Setup Rules (Breakout, Episodic Pivot, Parabolic Short)

#### Setup A — Breakout (High-Tight-Flag Continuation)
| Element | Rule | Value / Range | Tag | Note |
|---|---|---|---|---|
| **Prior Move** | Explosive advance in recent 1–3 months | $\ge 30\%$ low-to-high within $\le 63$ sessions (prior leg $\le 40$d) | **P/E** | [Setups post](https://qullamaggie.com/my-3-timeless-setups-that-have-made-me-tens-of-millions/) (`30–100%+`); exact bars **E/C**. |
| **Base Length** | Orderly sideways / shallow pullback | `10–40` sessions (2 weeks–2 months) | **P/C** | Note: `base.report` shows $\ge 10\text{d}$ (+2.27%) clears `5d` (+1.24%). |
| **Tightness & Higher Lows** | Higher lows & contracting range; narrow prior-day candle ideal | Bounded proxies: base range $\le 2\times\text{ADR}\%$ or second half tighter than first | **E/C** | Strictly qualitative in primary sources; expose all proxies as bounded manifest params. |
| **MA Surfing & Floor** | Rides rising 10/20 SMA (sometimes 50); rarely buys below 50 SMA | $\ge 70\%$ base closes $> \text{SMA}_{20}$; $\text{SMA}_{10} > \text{SMA}_{20}$ rising; $\text{Close} > \text{SMA}_{50}$ | **P/C** | `STS transcript`, `India desk PR 13`. Brief reclaimed undercuts permitted. |
| **ORB Entry Trigger** | High of first `1m`, `5m`, or `30m` ("60m" = half-hour opening bar) candle, or daily range break later if risk valid | Configurable order (`5m` default in India; `1m→5m→30m` option) | **P/E** | Earliest timeframe gets better fill, higher stop-out rate; `CWT` time mapping is **C**. |
| **Daily Extension Guard** | Skip if already up $> 1\times\text{ATR}$ on the day (prefer $1/3\text{--}2/3\times\text{ATR}$) | Hard at $1.0\times\text{ATR}$ (reference: prior close default **E**) | **P/E** | [Stream 2020-03-16](https://www.youtube.com/watch?v=kmSFnqIL6Hk) / `STS`. |
| **Breakout Volume** | Above-average breakout volume ("big big volume") | $\ge 1.5\times \text{Vol}_{20}$ as **grade**, not hard gate | **P/C** | `base.report` found no clean monotonic volume edge for hard-gating. |
| **Initial Stop & ADR Cap** | Entry-day low (`LOD`); **reject trade** if $(P_{\text{entry}} - P_{\text{stop}})/P_{\text{entry}} > 1\times\text{ADR}\%$ | Hard rejection $> 1\times\text{ADR}\%$; $\le 0.5\times\text{ADR}$ graded `A+` | **P/C** | `STS transcript`; "always skip too-wide stops". |
| **Partial Profit** | Day 3–5: sell `1/3–1/2`, raise hard stop to breakeven | Default `33%` on Day 3–5 (toggleable: `0%`..`50%`) | **P** | Preserve toggle: `CWT` says `20–25%`; `base.report` & `Stonks` report partial hurt mechanized returns. |
| **Trailing Exit** | First daily close below `SMA10` (or `SMA20` for slower / `SMA20`-surfing stocks) | Evaluated near market close (`SMA10`/`SMA20` matched to base) | **P/E** | Intraday hard stop remains active at breakeven until MA passes entry. |
| **Earnings Guard & Re-entry** | No entry within `3` sessions of earnings; exit pre-earnings unless profit cushion $\ge 10\text{--}15\%$; max re-entries per symbol/day | `3` sessions; `10–15%` cushion (**E**); max `2` re-entries/day (**E**) | **P/E** | Primary: `~3d` avoid, cushion examples; max re-entries is **E**. |

#### Setup B — Episodic Pivot (EP)
| Element | Rule | Value / Range | Tag | Note |
|---|---|---|---|---|
| **Gap Threshold** | Overnight open vs prior close | $\ge 10.0\%$ | **P** | Vendor `7.5%`/`8%` close-to-close presets measure day move, not gap (**C**). Avoid chasing $>30\%$ open gap (**P** example). |
| **Early Volume Pace** | Pre-market activity + opening surge | $\text{CumVol}(15\text{--}30\text{ min}) / \text{ADV}_{20} \ge 1.0$ = top grade | **P** | [EP post](https://qullamaggie.com/how-to-master-a-setup-episodic-pivots/) (`15–20m` in EP post, `15–30m` in setups post). Any premarket cutoff is **E**. |
| **Catalyst & Growth Fuel** | Real catalyst (earnings/guidance surprise ideal), ideally triple-digit or strong double-digit YoY EPS & sales growth + estimate beat | AI-graded (`unknown` if missing fundamentals); earnings-calendar matched | **P** | Excludes: recent 2nd EP, biotech (flagged high-risk), illiquid names. Seasonally concentrated in 3–4w earnings windows. |
| **Prior Base Condition** | Best if no prior rally over 3–6 months (extended sideways/neglected base) | `63d`/`126d` prior ROC scored as continuous grade | **P/E** | Confirmed beneficial in `Stonks Capital` EP test (**C**). |
| **Entry, Stop & Trail** | Same ORH (`1m`/`5m`/`30m`), `LOD` stop ($\le 1\times\text{ADR}\%$ cap as **E** option), `SMA10`/`SMA20` daily-close trail once price clears initial stop | Same skeleton as Setup A | **P/E** | Note: Qullamägi used tighter-than-LOD stops discretionarily on wide-gap EPs (`CWT` IOT example). |

#### Setup C — Parabolic Short *(Ships Last · Disabled by Default · Alert-Only in Phase 3 · F&O Only in India)*
| Element | Rule | Value / Range | Tag | Note |
|---|---|---|---|---|
| **Run-Up & Streak** | Sharp multi-day blow-off: $\ge 50\text{--}100\%$ (large cap) or $\ge 300\text{--}1000\%$ (small cap) with $\ge 3$ (`3–5+`) consecutive green closes | Lookback window $N \in \{3, 5, 10, 15\}$ sessions (**E**); cap cutoff market-param (**E**) | **P/E** | Community `3d`-only test (`Stonks`) misses multi-week runs; optional `RSI >= 75` grade (**C**). |
| **Trigger & Stop** | Opening-range low (`1m`/`5m`), first red `5m` bar, or failed bounce into `VWAP`; hard stop at `HOD` (or `VWAP` reclaim) | Hard stop; no primary `1x ADR` cap stated | **P** | Short-side ORL / red-5m / VWAP fail. No shorting while stock holds rising `SMA10/20`. |
| **Target & Regime** | Cover at `SMA10`/`SMA20` bounce zone (`~5–10R` typical; community alt: cover on `20–30%` 2-day flush); regime-indifferent; requires shortable/borrow/futures leg | Mandatory short-eligibility check from Market Profile | **P/C/E** | Secondary **Parabolic Long** bounce (`50–60%+` crash over a few days) uses mirror ORH / green `5m` bar entry (**P**). |

### 3.3 Market Profiles: One Rule Set, Two Configurations

Every market-specific constant lives in a `MarketProfile` record (`tantra-core` contract, populated in `tantra-market-finance`). Exchange items marked *Verify Circular* MUST be checked against current NSE/BSE circulars before coding production gates.

| Parameter | US Profile (`US_EQUITIES`) | India Profile (`INDIA_NSE_BSE`) | Tag & Implementation Rule |
|---|---|---|---|
| **Regime Benchmark** | `NASDAQ` / `QQQ` (+ `IWM` / Russell 2000 secondary check) | `NIFTY 500` or `NIFTY 50` + `NIFTY SMALLCAP 250` | **P** (US) / **C/E** (India PR 13). Parameterized benchmark pair. |
| **Liquidity Floor** | $\text{Equity}\times[20,50]$ USD (his floor `$15–20M`/d; comm. `$3–10M`) | $\text{Equity}\times[20,50]$ INR; ref points `₹1 Cr/d` (permissive 20d median) to `₹10 Cr/d` (strict) | **P** formula / **C** INR points. Dynamic function of account equity. |
| **Share Price Floor** | `$5.00` (**C**) | `₹20.00` (**C**, `India desk PR 13`) | Configurable floor to strip micro-price distortions. |
| **ADR%(20) Floor** | `4.0%–5.0%` | Start `3.0%–4.0%` and calibrate | **P** (US) / **E** (India: price bands cap daily range; `TradeINski` notes lower ADR needed). |
| **Leader Percentile** | Top `1%–2%` (~6,000–7,000 stocks) | Top `2%–3%` across liquid NSE/BSE universe | **P** (US) / **C** (India). Configurable target candidate count (~50). |
| **Circuit / Price Bands** | None per symbol (LULD halts only) | Per-symbol historical/live price-band % (`2%`/`5%`/`10%`/`20%`/No-Band F&O) as **data column** | *Verify Circular* — **Never hardcode** band%; store as reference series. |
| **EP Gap Handling** | Pre-market `>= 10%` gap vs prior close | `>= 10%` gap only if symbol band permits; exclude `5%`-band stocks; open at upper circuit = **untradeable (no fill)** | **E** — Prevents phantom paper/backtest EP fills on locked-limit India stocks. |
| **Parabolic Guard** | Momentum streak + volume | Discount limit-up streaks on thin/locked volume as **unconfirmed / non-actionable** | **E** — Circuit locks mimic parabolic streaks without liquidity. |
| **Gap Discovery Window** | Extended hours pre-market (`~2h` pre-open) | NSE/BSE **pre-open call auction (`09:00–09:15 IST`)** equilibrium / first print vs prior close | **P** (US) / India exchange rules. |
| **Opening-Range Bar** | `1m` / `5m` / `30m` from `09:30 ET` | `1m` / `5m` / `30m` from `09:15 IST` (**default `5m`**) | **E** — `TradeINski` reports high failure rate on 1m ORB in India (**C**). |
| **Shorting & Eligibility** | Margin + broker borrow/locate across borrowable stocks | Cash-segment overnight shorting prohibited; overnight shorts via **NSE F&O stock futures only** (otherwise intraday MIS) | India market rules — `can_short_overnight` derived from F&O membership. |
| **Settlement & Margin** | Reg-T / Portfolio Margin | `T+1` delivery settlement + upfront delivery/VaR+ELM margins; no 130–140% net long cash assumption | India market rules; **P** warns against blind margin use. |
| **Adapter & Feed Readiness** | Zero support today (`Missing`) | Dhan + Zerodha feeds real; 7 broker SDKs in `tantra-adapters` | See Row 34 & `root gap 0001`. |

### 3.4 Separation of Concerns: Hard Rules vs. AI vs. Journal vs. Human Discretion

| Layer | Assigned Responsibilities | Design Rationale |
|---|---|---|
| **Deterministic Hard Rules** *(Scan / Strategy / Risk Gate)* | `ADR%` & liquidity floors; leader percentile; `LOD/HOD` stop with hard $\le 1\times\text{ADR}\%$ rejection; `0.25–1%` risk cap; overnight single-name `25–30%` cap; `1% ADV` cap; no averaging down; stop-market orders only; $>1\times\text{ATR}$ extension guard; circuit-headroom & band/shortability checks; block automated breakouts in **Regime Level 4** ($10<20$ both falling). | Numerically unambiguous in primary sources or market structure; every rule fails safe. |
| **Soft Automation / Logged Override** *(Manual Orders)* | **Regime Levels 2–3** reduced-size prompt & Level 4 manual override requiring explicit user acknowledgement + reason; earnings-within-3d guard (auto-bypassable only with profit cushion); max open positions (`15–20`); margin permission only when aggregate open P&L > 0 ("earned margin"). | Qullamägi both correctly overrode lagging MAs (`Nov 2020`) and suffered `~$60M` drawdown ignoring them (`2022`). Logging overrides produces auditable outcome data. |
| **AI Assistant Checklist** *(Graded, Never Blocking Alone)* | Catalyst classification & surprise magnitude; YoY EPS/sales growth trajectory; "no prior 3–6m rally" check; base quality rating; first vs. later flag; theme membership + `primary / secondary / tertiary` mover tag; negative news scan; mandatory pre-trade setup tag prompt. | Qualitative by nature; **MUST cite ingested data and emit `"unknown"` when fundamentals/news are absent** (zero hallucination). |
| **Journal & Behavioral Analytics** | Per-trade $R$-multiples; win rate & expectancy split by setup and regime level; `% time in drawdown` and days-to-recover curve; **back-watchlist follow-through rate**; revenge/boredom pattern flags (rapid re-entry after stop, rising entry count in unfavorable regime, post-hot-streak risk reminder, expected 5-loss streak context). | Exceeds Kullamägi's own manual journaling (he admitted neglecting his journal and not tracking average winner/loser). |
| **Human Discretion** | Final focus-list selection (`top 3–4` names watched at open from ~50 candidates); ORB timeframe selection on the day; index price-action structure ahead of lagging MAs; holding through earnings with cushion; selling into extreme euphoria; stepping back after huge runs. | Requires pattern-study judgment he spent 1,000+ hours building and noted cannot be naively replaced. |

---

## 4. Per-Repo Work Items & Phased Implementation Roadmap

Dependency order mirrors Master Plan [`0005`](0005-elephant-edge-strategy-platform.md). After Phase 0 closes the 9 unverified checks, each row below becomes one gap/plan entry in its owning repo's `docs/{gaps,plans}/`.

| Phase | Owning Repo / Scope | Work Item Summary | Depends On |
|---|---|---|---|
| **0. Verify & Research Baseline** | `tantra-labs` (root) + code read across `data`, `market`, `risk`, `exec`, `runtime`, `ledger` | Inspect source implementations for the **9 unverified rows (`7, 8, 11, 12, 25, 26, 27, 28, 32`)**; verify NSE/BSE circuit-band & F&O circulars; update §1 & §2 with exact file evidence; file confirmed `docs/gaps/XXXX-*.md` in each owning repo. *(Note: Plan `0009` itself preserves the consolidated research baseline until retired or split if needed.)* | — |
| **1. Domain Contracts** | `tantra-core` | Add zero-I/O `Decimal` domain types: `MarketProfile` (id, currency, sessions, pre-open window, price-band model, shortability model, settlement/lot rules), `SwingSetupKind`, `CandidateGrade`, `ScanCandidate` (pivot, stop, `adr_pct`, `rvol`, `regime_label`), `RegimeState` (4 levels), `JournalEntry` extensions (`setup_tag`, `r_multiple`, `regime_at_entry`, `override_reason`). | Phase 0 |
| **1. Finance Profiles & Dynamic Universe** | `tantra-market-finance` | Populate `INDIA_NSE_BSE` profile + `US_EQUITIES` profile (calendar/sessions/costs); add `DynamicUniverse` trait supporting point-in-time historical membership & liquidity filtering alongside `StaticUniverse`. | `tantra-core` contract |
| **1. Strategy SDK Interfaces** | `tantra-strategies` | Extend `StrategyContext` & `Strategy` contracts for multi-symbol `universe()`, account `equity()`, mixed **daily + intraday bar** lookup, and `partial_exit` / `close_based_trailing_stop` intents (`stop_protection.py` foundation already landed). | `tantra-core` contract |
| **2. India Data Lakehouse** | `tantra-data`, `tantra-market` feeds | Full-universe CA-adjusted EOD history for NSE/BSE retaining delisted symbols; historical per-symbol price-band % & F&O-membership series; `ADV20` traded-value series; harden results calendar + `gap 0015` holidays; complete real historical EPS/sales surprise ingestion (`gap 0020`); add `scan_results` and `back_watchlist` tables; capture `09:00–09:15 IST` pre-open equilibrium + 1m/5m ORB bars for leader pool (`root gap 0001` for non-Dhan/Zerodha). | Phase 1 |
| **2. US Data Lakehouse** | `tantra-data` | Choose US EOD + corporate actions + delisted history + earnings/fundamentals vendor (Polygon / FMP / Alpaca / IBKR evaluation) and build ingestion pipeline parameterized under `US_EQUITIES`. | Phase 1 + Owner Vendor Decision |
| **3. Indicators & Universe Screener** | `tantra-market-indicators` | Implement exact `ADR%(20)` (average of $H/L - 1$); add screener columns (`gain_from_low(N)`, `roc(N)`, `adv_value(20)`, `gap_pct`, `rvol`, `dist_from_sma`, `streak_up`, `ema(n)`); build **cross-sectional percentile evaluator** beside `screener.rs`; resolve `f64`-vs-`Decimal` ADR decision. | Phase 2 |
| **3. Detectors, Regime & Breadth** | `tantra-market-signals` | Add `FlagConsolidationDetector` (tightness, higher lows, SMA10/20 surfing, SMA50 floor), `EpisodicPivotDetector` (gap $\ge 10\%$ + early-session `CumVol/ADV`), `ParabolicExtensionDetector`, parameterizable 1m/5m/30m `OrbDetector` with daily precondition, 4-level `IndexRegimeDetector`, and promote breadth metrics out of `tantra-examples`. | Indicators |
| **3. Scan Jobs & Back Watchlist** | `tantra-runtime-jobs`, `tantra-data` | Scheduled **India EOD** weekly leader-refresh job, nightly setup-tagging job, pre-open EP gap scan, hourly intraday rotation scan; automated **Back Watchlist** snapshot & 5/10/20-day forward-outcome job + **"breakouts working" breadth gauge**. *(First deployable India scanner milestone.)* | Detectors + Tables |
| **3. Universe Backtester** | `tantra-runtime-backtest` | Point-in-time multi-symbol universe mode: daily cross-sectional re-ranking, survivorship-free membership, daily setup + 1m/5m intraday ORB entry + close-based SMA trail, market-profile costs/slippage, and circuit-locked zero-fill modeling. | Phase 2 + Detectors |
| **3. Strategy Manifests & Sizer** | `tantra-strategies` | Implement `swing/qm_breakout`, `swing/qm_episodic_pivot`, and *(last, disabled by default)* `swing/qm_parabolic_short` TOML manifests exposing every **E**-tagged param; build stop-distance sizer with single-name weight (`25%/30%`) and `1% ADV` caps. | SDK Contract + Backtest |
| **4. Execution, Risk & OMS** | `tantra-exec`, `tantra-risk`, `tantra-ledger`, `tantra-adapters` | Support `CNC`/delivery overnight holdings, persistent stop-market orders, breakeven move + close-evaluated SMA10/SMA20 trailing exits, partial exits, gap-through-stop handling, and F&O stock-futures short leg. Enforce swing risk rules (per-trade risk%, overnight concentration, 1% ADV, no averaging down, 3d earnings guard, circuit headroom, regime gate with logged manual overrides). | Phase 3 |
| **4. US Execution & Risk** *(Gated)* | `tantra-adapters`, `tantra-exec`, `tantra-risk` | Implement chosen US broker adapter + US regulatory rules (Reg-T/PDT/locate/short-sale) **only after US forward paper trial clears Stage E**. | Phase 2 (US Data) + Phase 4 Risk + Stage E |
| **5. AI Copilots & Workstation UI** | `tantra-agent`, `tantra-ui`, `tantra-ui-web` | Agent: grounded catalyst/EPS-surprise grader (`"unknown"` fallback), nightly focus-list brief, pre-trade checklist, weekly $R$-expectancy & override review report. UI: dynamic leader watchlists, setup & regime banner, chart `LOD`/entry/MA levels + trendline-attached price alerts (`ui gap 0007`), sector theme board (`primary`/`secondary`/`tertiary`), back-watchlist forward tracker, and drawdown-recovery analytics. | Phases 3–4 + UI Home Choice |
| **6. Documentation & Index Cleanup** | `tantra-docs`, all repos | Publish canonical Strategy Contract & operator runbooks (India vs. US profile behavior, backtest limitations, regime overrides); close per-repo gap docs cleanly per `.agents/rules/gap-tracking.md`. | All preceding phases |

### Early-Value Sequencing Note
- **End of Phase 3 (India Scanner Release)**: Tantra produces a daily NSE/BSE top-momentum leader pool, tagged breakout/EP setups, circuit-band & F&O columns, 4-level index regime state, and a self-updating **Back Watchlist** — delivering full screening & forward-validation telemetry with **zero execution risk**.
- **Parabolic Shorts Last**: Held to the end of every phase (`Phase 3` alert-only after Breakout & EP pass; `F&O`-only and disabled by default in execution).

---

## 5. Quality Gates & Validation Ladder (Stages A–F)

### Platform Engineering Gates (Binding)
- **Rust repos**: `cargo fmt --check`, `cargo clippy --workspace --all-targets --profile prod -- -D warnings`, `cargo test --workspace --profile prod`, and end-of-turn `make prod`.
- **Python repos (`tantra-strategies`, `tantra-data`)**: `ruff check . && ruff format --check .`, `pytest -q`, type check (`pyright` / `mypy` strict).
- **Docs**: `mkdocs build --strict`.
- **Numeric / No-Floats Gate**: Require explicit architectural decision on `screener.rs` (`f64` ranking/ratio exemption vs. `Decimal` rewrite); **all order prices, stops, quantities, position sizes, and equity balances MUST remain `Decimal`**.

### Empirical Validation Ladder (Stages A–F)
No capital or live automation proceeds without clearing each preceding gate per market (`India` and `US` validated separately):

| Stage | Verification Method | Binding Acceptance Gate |
|---|---|---|
| **A. Unit & Fixture Conformance** | Verify `ADR%(20)` against FAQ formula (`avg of H/L - 1`); verify cross-sectional percentile rank on synthetic universes; test setup detectors against curated textbook **winners AND non-examples / failed setups** per market. | 100% deterministic fixture pass; both positive and negative (trap) fixtures included. |
| **B. Scan Event Study** | Track forward 5/10/20-session excess returns of every scan candidate vs. a **matched random-entry control** (same date, liquidity, and ADR bucket) on survivorship-free point-in-time data (incl. delisted names), split by regime level, year, ADR bucket, and market. | Candidate pool outperforms matched control out-of-sample in a majority of years per market; regime-split metrics published transparently. |
| **C. Rule Backtest** | Universe backtest pairing daily setups with intraday 1m/5m ORB entries, market-profile costs/slippage, upper-circuit locked-day zero-fills, and stock-futures basis / borrow costs for shorts. Ablate stop width (`0.5×`/`1×`/`wider`), day 3–5 partial (`on`/`off`), and `SMA10` vs `SMA20` trail. | Out-of-sample positive mean expectancy in $R$ after costs with confidence interval $> 0$; worst drawdown & losing-streak distributions recorded; **zero winner-selected bias**. |
| **D. Walk-Forward Optimization** | `tantra-runtime-enhancer` restricted strictly to **E**-tagged parameters, hard cap on simultaneously tuned params, across rolling out-of-sample windows including choppy/bear regimes. | Selected defaults sit on a **parameter plateau** (not an isolated spike) and avoid catastrophic collapse in unfavorable regimes. |
| **E. Forward Paper Season** | Run live scanner + Back Watchlist + paper execution with stored regime labels across **at least one full quarterly results season per market**. | $\ge 100$ completed paper trades per setup per market before live capital; realized slippage aligns with Stage C assumptions. |
| **F. Controlled Live Rollout** | Risk-per-trade fixed at floor (`0.25%`), **long-only**, automation permitted **only for symbols manually promoted by the user onto the Focus List**. | Formal review every `50` live trades benchmarking realized $R$ and slippage against Stages C & E. |

**Calibration benchmarks for Stage C–E reviews**: At a `27%` win rate, a `3.0R` average winner produces only `+0.08R` trade expectancy (`4.0R` yields `+0.35R`), meaning expectancy relies heavily on right-tail outliers (naive winsorizing/trimming distorts truth in either direction). Furthermore, **five consecutive `-1R` stop-outs** occur routinely at a 25–30% win rate (**P**, [Stream 2020-12-28](https://www.youtube.com/watch?v=gP7vW-NTQBQ)); the journal UI MUST display expected streak probabilities so normal variance is not misdiagnosed as system failure.

---

## 6. Research Synthesis, Empirical Evidence & Citation Reference

### 6.1 Summary of Public Quantified Studies & Caveats
No public study reports win rate, mean $R$, expectancy, drawdown, and regime breakdown together over disclosed rules on survivorship-free data, and none isolates Episodic Pivots with full costs:
- **`base.report` (Apr 2023 — 27,500 mechanized US breakouts)**: Mean gain `+1.76%` (`+1.08%` with day 3–5 partial), `52.69%` losers, `5.95%` winners $\ge 20\%$; **2008 & 2022 negative**; `ADR 16%+` averaged `+5.10%` vs `ADR 3–4%` at `+0.71%`; `10+` day bases (`+2.27%`) outperformed `5d` (`+1.24%`); no clear volume cutoff edge. Caveats: admits survivorship bias, daily close entry proxy, excludes 4 extreme outliers, omits $R$-expectancy. ([Study](https://base.report/studies/systematic-backtesting-analysis-breakout-setups))
- **Stonks Capital / Niv Goren (Feb 2025)**: Reports `19% CAGR / -21% max DD` on breakouts (`2,382` trades since 2007, `SPY > 140 EMA` filter) and `27.7% CAGR / -20.9% max DD` on parabolic shorts (`1,869` trades). Notably found that both a tight `1 ATR` stop and the `3-day` partial exit *hurt* mechanized daily performance. Caveats: final rules withheld, daily OHLC only, omits costs/slippage/borrow/survivorship handling. ([Breakouts](https://stonkscapital.substack.com/p/modeling-kullamagi-part-2-momentum) | [Parabolic](https://stonkscapital.substack.com/p/systemizing-kullamagis-parabolic))
- **VladPetrariu Open-Source Scanner (Walk-Forward)**: Across `4,840` ranked picks, 10-day win rate `56.1%` (`+0.80%` median, `top 5 > top 20`), positive in 5/6 three-year windows, edge vanishes in choppy/mixed regimes. Exit study (`13,500` picks): every stop tighter than `3×ATR` turned median return negative; overall mechanized expectancy `+0.081R`. ([Repo](https://github.com/VladPetrariu/Qullamaggie-breakout-scanner))
- **TradingView `vishnuv` v6.5 / v7.1 (Protected Source)**: Claims on 125 documented Kullamägi trades that `<0.5 ADR` stops had `13.9R` median vs `4.6R` wider; claims out-of-sample edge on `4,500 US` and `1,800 NSE` stocks (2021–2026) vs random control, relaxing hard spoken filters into optional grades. Cannot be independently audited (closed source). ([TV Page](https://in.tradingview.com/script/iQtlXxO8-Qullamaggie-Trading-System-Pro/))
- **India Reference Implementations & Skepticism**:
  - `Chartink "Kristjan Qullamaggie"` omits `ADR%`, liquidity, and momentum rank (leaving only MA stacking).
  - `PatelNicknp/nicks-india-stock-desk` ([PR 13](https://github.com/PatelNicknp/nicks-india-stock-desk/pull/13)) encodes top 3% (21/63/126d), `Close >= ₹20`, `₹1 Cr`–`₹10 Cr` 20d median turnover, inferred `5%/10%` band column, Nifty 50 + Smallcap 250 regime, `0.5%` risk capped at `25%`.
  - [TradeINski (Apr 2025)](https://tradeinski.substack.com/p/6-main-reasons-why-qullamaggie-style) flags India friction: breakouts work only partially; EPs and parabolics fail due to circuit bands and overnight cash short bans; ORB entries suffer low hit rates; high-ADR microcaps lack liquidity depth.

### 6.2 Behavioral, Routine & Product-Copy Insights
- **The 2022 Regime Counterfactual & Process Loops**: Kullamägi's primary stream corpus (Oct 2019–Dec 2021, ~2.29M words in `peterdmv/qullamaggie-mcp`) spans an unusually strong bull cycle. A secondary account of the *Market Wizards* chapter ([Complete Trader's Edge](https://completetradersedge.com/kristjan-kullamagi-qullamaggie/)) reports his account fell from a `~$105M` peak (Nov 2021, `~$150M` long) to `~$45M` by mid-2022 by slow accumulation of losses over ~9 months while ignoring his own 10/20 SMA filter (~90% avoidable by his counterfactual). He explicitly highlights chronic overtrading, boredom/revenge trades, spending 50–80% of good years in drawdown, stopping screenshot-library reviews reducing conviction, and sector **theme hierarchy (`primary` leader → `secondary` → `tertiary` laggard as late-cycle topping tell)**.
- **Back Watchlist & Theme Board Priority**: Daily snapshot-and-review of every qualifying setup regardless of whether traded ("back watchlists" kept rolling for 1 month) builds conviction and feeds the live *"breakouts working?"* breadth signal directly. Grouping leaders by theme ranks hot sectors while flagging tertiary laggards.
- **Historical Lineage (for `tantra-docs` & `tantra-agent` copy)**:
  - **Episodic Pivot & Study Archive**: Pradeep Bonde (`Stockbee`).
  - **Parabolic Short**: Tim Sykes (`Supernova`).
  - **High-Growth Momentum Breakouts & Sitting Power**: Dan Zanger (also his explicit cautionary example against `4–5`-stock margin concentration), William O'Neil (`CAN SLIM`, price + earnings momentum), Mark Minervini.
  - **Market Philosophy**: Jesse Livermore, Nicolas Darvas, Jack Schwager (*Market Wizards*).
  - **Explicit non-influence**: Stan Weinstein ("haven't read it"; *do not market or label this as Stage 2 Weinstein analysis*).
  - **ORB source**: Uncertain (attributed by Qullamägi possibly to Toby Crabel, explicitly not Zanger).

### 6.3 Primary & Secondary Source Index
- Primary Blog & FAQ: [My 3 Timeless Setups](https://qullamaggie.com/my-3-timeless-setups-that-have-made-me-tens-of-millions/) · [How to Master Episodic Pivots](https://qullamaggie.com/how-to-master-a-setup-episodic-pivots/) · [FAQ](https://qullamaggie.com/faq/)
- Primary Stream Transcripts & Corpus: [Swing Trading School Transcript](https://sozai.app/transcript/qullamaggie-swing-trading-school/index.md) · [`peterdmv/qullamaggie-mcp`](https://github.com/peterdmv/qullamaggie-mcp) (437 sessions; `rules.json` excluded as LLM paraphrase) · [`Akaifist/Qullamaggie-transcripts`](https://github.com/Akaifist/Qullamaggie-transcripts) (2017 recap baseline)
- Specific Stream Citations Embedded Above: [2019-10-01](https://www.youtube.com/watch?v=e49j7sjdMFE) · [2020-02-25](https://www.youtube.com/watch?v=iuzNFGgMu_0) · [2020-03-16](https://www.youtube.com/watch?v=kmSFnqIL6Hk) · [2020-06-08](https://www.youtube.com/watch?v=BaOesIGPVUo) · [2020-07-08](https://www.youtube.com/watch?v=hgrjw6IxFGY) · [2020-07-13](https://www.youtube.com/watch?v=YwMoUTd4naQ) · [2020-08-05](https://www.youtube.com/watch?v=YYFwzNZkRDI) · [2020-08-17](https://www.youtube.com/watch?v=0TtPc372p1Q) · [2020-08-19](https://www.youtube.com/watch?v=4pNRHwHAJgw) · [2020-09-16](https://www.youtube.com/watch?v=IhSrnZXH8s4) · [2020-09-23](https://www.youtube.com/watch?v=_JvCQKA9xXU) · [2020-10-12](https://www.youtube.com/watch?v=iobRxNCyEk0) · [2020-10-19](https://www.youtube.com/watch?v=4jBFYGMGOH0) · [2020-10-30](https://www.youtube.com/watch?v=1gmFq2IsTYY) · [2020-11-05](https://www.youtube.com/watch?v=JTtOJdc5EKc) · [2020-11-23](https://www.youtube.com/watch?v=AXgAZwbMscQ) · [2020-12-07](https://www.youtube.com/watch?v=uTMK9uhQZCc) · [2020-12-21](https://www.youtube.com/watch?v=l4lpLA7vvbg) · [2020-12-22](https://www.youtube.com/watch?v=wLYBzP4qRjY) · [2020-12-28](https://www.youtube.com/watch?v=gP7vW-NTQBQ) · [2021-01-04](https://www.youtube.com/watch?v=MiEYFeBV8jM) · [2021-01-06](https://www.youtube.com/watch?v=9o5_4iZ0zjI) · [2021-02-12](https://www.youtube.com/watch?v=siYpCaiuPKg) · [2021-02-22](https://www.youtube.com/watch?v=XFPV6n-kBnk) · [2021-03-31](https://www.youtube.com/watch?v=i-FvQ9bD9S8) · [Aug 2020 est.](https://www.youtube.com/watch?v=aTIADs82W_k)
- Community Reconstructions & Reference Implementations: [Boomerberg Thread](https://threadreaderapp.com/thread/1517432275318841345.html) · [CWT Notes](https://tradingresourcehub.substack.com/i/132995655/introduction) · [Streams 1–5 Summary](https://retailtradersrepository.substack.com/p/kristjan-kullamagi-qullamaggie-stream) · [Tikam Alma](https://tikamalma.substack.com/p/qullamaggie-swing-trading-setups) · [Laws of Swing](https://pdfcoffee.com/qullamaggiex27s-laws-of-swing-pdf-free.html) · [SnapPChart](https://www.snappchart.app/blog/beginner-playbook/qullamaggie-trading-strategy) · [FWTV EP](https://www.financialwisdomtv.com/post/the-episodic-pivot-strategy-qullamaggie-s-high-momentum-setup-explained) · [Deepvue](https://deepvue.com/screener/qullamaggie-screens/) · [ZenScans](https://guide.zenscans.com/2026/07/27/qullamaggie-scans/) · [axidzz/Qullamaggie-Setups](https://github.com/axidzz/Qullamaggie-Setups) · [udaydivvela/qullamaggie-strategies](https://github.com/udaydivvela/qullamaggie-strategies) · [troyfol/Qullamaggie-Scanner](https://github.com/troyfol/Qullamaggie-Scanner)
- Known Source Gaps: Exact saved TC2000 PCF scan formulas (link target & Boomerberg condition images unread); primary post-Dec-2021 logs; numerical "tightness" / "dry-up" / "cap-cutoff" / "portfolio-heat" definitions.

---

## 7. Open Owner Decisions, Risks & Cleanup

### 7.1 Open Decisions for Owner Sign-Off
1. **US Data Vendor & Broker**: Select vendor (Polygon / FMP / Alpaca / IBKR) and broker (`IBKR` / `Alpaca`), none yet evaluated.
2. **US Track Scope**: Scan + paper research only vs. full live US execution (adds broker adapter, US regulatory ruleset, and settlement/locate handling).
3. **Screener Arithmetic Invariant**: Explicit exemption for internal `f64` ranking/ratio math in `screener.rs` vs. pure `Decimal` rewrite.
4. **4 Unresolved Scan Contract Defaults**:
   - Rank before vs. after liquidity filter;
   - Union vs. intersection across 1m/3m/6m windows;
   - Gain from N-day low vs. point-to-point ROC;
   - Window lengths `21/63/126` vs. `22/67/126`.
5. **Regime Gate Strictness on Manual Orders**: Hard lockout vs. acknowledge-and-log override in Regime Level 4.
6. **Day 3–5 Partial Exit Default**: Enable (`33%` default) vs. disabled (`0%` default given `base.report` / `Stonks` evidence).
7. **India Operational Calls**:
   - Whether India **Episodic Pivots** defer entirely until `tantra-data` fundamentals (`gap 0020`) real history lands;
   - Whether **Parabolic Shorts** remain permanently alert-only or graduate to F&O futures;
   - Exact India regime benchmark (`NIFTY 500` vs `NIFTY 50 + NIFTY SMALLCAP 250`).
8. **Unified UI Home & Corpus Licensing**: Pick primary Phase 5 UI target (`tantra-ui` vs `tantra-ui-web`) and verify license compatibility of `peterdmv/qullamaggie-mcp` (~2.29M words) before using it to ground `tantra-agent` checklists.

### 7.2 Key Program Risks
1. **Bull-Regime Corpus Bias**: The 2019–2021 public stream dataset under-samples prolonged bear/chop regimes; every public backtest shows edge disappearing outside bull markets.
2. **Discretionary Edge Dominance**: Passing on ~99% of tracked setups leaves systematic automation structurally weaker than discretionary execution; positioning the tool honestly as a **screener + risk harness** avoids mis-expectation.
3. **Unproven India Transfer**: Locked upper/lower circuit bands break gap fills, cap ADR, fake parabolic streaks, and degrade ORB breakouts (`TradeINski`); circular verification is mandatory before production encoding.
4. **Upstream Scope Uncertainty**: 9 unverified code checks (especially rows `25`, `26`, `28`, `32`) plus `tantra-data 0020` and `root 0001` can expand Phase 4 effort significantly.
5. **Overfitting Trap**: With dozens of **E**-tagged thresholds across tightness, MA surf, and ORB timing, `tantra-runtime-enhancer` GA tuning risks severe curve-fitting unless constrained strictly by **Stage C/D** plateau and sample-size gates.
6. **LLM Catalyst Hallucination**: When quarterly earnings or estimate-surprise history is absent, `tantra-agent` must never extrapolate or invent numbers; `"unknown"` is a mandatory valid output.
7. **Thin Secondary Evidence**: Post-2021 drawdown figures (`Complete Trader's Edge`), `STS` ASR transcripts, and NSE-only backtest claims (`vishnuv`) carry non-trivial transcription/reporting caveats.

### 7.3 Cleanup & Maintenance
Per `.agents/rules/gap-tracking.md`:
- Phase 0 updates §1–§2 with verified file-level findings and files individual per-repo gap docs under owning `docs/gaps/XXXX-*.md` repositories.
- As each capability ships and passes its quality & validation gates, its gap document is removed from active `docs/gaps/` and recorded in the repo's index.
- Once all phases are closed or explicitly scoped out, move **Plan `0009`** to the `Implemented Plans` table in [`docs/plans/README.md`](README.md) and mark **Track T13** complete in [`docs/task-list-tracks-and-phases.md`](../task-list-tracks-and-phases.md).

## 8. Related
- Plans Index: [`docs/plans/README.md`](README.md)
- Precedent Strategy Platform Plan: [`docs/plans/0005-elephant-edge-strategy-platform.md`](0005-elephant-edge-strategy-platform.md)
- Workspace Task List: [`docs/task-list-tracks-and-phases.md`](../task-list-tracks-and-phases.md) — **Track T16**
- Gap Tracking Policy: [`.agents/rules/gap-tracking.md`](../../.agents/rules/gap-tracking.md)
