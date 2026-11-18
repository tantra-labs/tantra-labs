# 0014 — `Experimental-Analysis` Multi-Asset Statistical & Event Study Platform (Track T20)

**Status**: Proposed (2026-11-18) — Track **T20** (`T20.1–T20.5`)

**Architecture Rule**: **Zero edits to `tantra-core`**. Reuses existing `tantra_core::{Exchange, InstrumentId, InstrumentKind, Money, Price, Quantity}` and `tantra_runtime_api::wire::InstrumentKind` read-only.

---

## 0. Executive Summary & Objective

Build a full-stack multi-asset **Statistical & Event Study Workbench** (temporarily named **`Experimental-Analysis`** in `tantra-ui-web`, replacing the earlier FIRE direction) inspired by quantitative F&O/event-study workflows and generalized cleanly across **F&O, Indices, ETFs, Equities, Forex, and Commodities**.

The platform unifies:
1. **Multi-Asset Data & Events (`tantra-data`)**: Lakehouse v3 `1d` + `5m` OHLCV series across Equities, Indices, ETFs, continuous F&O, Forex, and Commodities, plus structured Buyback, Earnings, and F&O Inclusion/Exclusion event projections.
2. **Regime-Aware Period & `Decimal` Statistical Kernel (`tantra-market`)**: Pre/post Sep 3, 2025 NSE expiry regime slicing (`Fri→Thu` → `Wed→Tue`), universal calendar/session schedules, exact `Decimal` summary KPIs (Mean, Std, Sharpe, Sortino, Profit Factor), Streak & `6×6` Markov transitions, Empirical Distributions (`16-bucket`, `10-bps`, `Probability-Based Levels`, `Green vs Red`), Conditional Forward Moves, Abraham Wald Survivability Outliers, `5m` Intraday/Gap/ORB-15 Backtest, Cycle Progress (`0–100%`), Cross-Asset Correlation, Covered Call / Option Premium Lab, Forecasting, and Event Study CAR.
3. **Versioned REST & OpenAPI Contracts (`tantra-runtime`)**: `/api/v2/experimental-analysis/*` endpoints (`schemars` OpenAPI 3.1) + live `tantra-adapters` option-chain/quote feed wiring.
4. **Copilot & Outlier Event News (`tantra-agent`)**: `experimental_study_summary` & `historical_outlier_news` tools for interactive Q&A and dated global news retrieval on extreme outlier periods.
5. **Interactive Workbench UI (`tantra-ui-web`)**: `Experimental-Analysis` workspace tab (`WorkspaceShell` + `WorkspaceTabBar` + `?open=experimental-analysis`) with asset-class-adaptive left control rail, 3 study modes, 13 horizontal study tabs, interactive SVG charts (`Lollipop+Bubble/Bar+MA`, `Survivability Scatter`, `Markov Heatmap`, `Streak & Empirical PDF Charts`), `ChartCanvas` OHLC reuse, and `decimal.js` zero-float parsing.

---

## 1. Per-Repository Plan Breakdown

| Task | Layer / Repo | Deliverable | Plan Document |
| :--- | :--- | :--- | :--- |
| **T20.1** | `tantra-data` | ETF/F&O/FX/Commodity Lakehouse v3 continuity + Buyback/Earnings/F&O-Exclusion event tables | [`tantra-data` plan 0010](../../tantra-data/docs/plans/0010-experimental-analysis-multi-asset-and-events.md) |
| **T20.2** | `tantra-market` | Regime-aware `PeriodSchedule` + `tantra-market-finance::studies` pure `Decimal` statistical, Markov, ORB & option/event evaluators | [`tantra-market` plan 0003](../../tantra-market/docs/plans/0003-experimental-analysis-period-and-markov-engine.md) |
| **T20.3** | `tantra-runtime` | `tantra-runtime-api::experimental_analysis` OpenAPI DTOs + `/api/v2/experimental-analysis/*` REST handlers | [`tantra-runtime` plan 0009](../../tantra-runtime/docs/plans/0009-experimental-analysis-statistical-rest-api.md) |
| **T20.4** | `tantra-agent` | `experimental_study_summary` & `historical_outlier_news` read-only chat/MCP tools | [`tantra-agent` plan 0016](../../tantra-agent/docs/plans/0016-experimental-analysis-copilot-and-event-news.md) |
| **T20.5** | `tantra-ui-web` | `Experimental-Analysis` workspace tab, adaptive control rail, 13 study tabs, SVG statistical charts & `ChartCanvas` OHLC | [`tantra-ui-web` plan 0016](../../tantra-ui-web/docs/plans/0016-experimental-analysis-workbench-ui.md) |

---

## 2. Cross-Phase Rollout

- **Phase 1 (Backend Foundation + Core Frontend Workbench)**: `T20.2` core returns/streaks/Markov/distributions/outliers + `T20.3` `/catalog` & `/returns` + `T20.5` `Experimental-Analysis` tab (`ControlRail` + Tab 1 `Returns Analysis` + Tab 2 `Outliers` + `OHLC` view).
- **Phase 2 (Intraday `5m`, Progress, Correlation & FX/Commodity Breadth)**: `T20.1` FX/Commodity Lakehouse partitions + `T20.2`/`T20.3`/`T20.5` Tabs 3 (`Intraday Movement`), 4 (`Gap Up/Down`), 5 (`5-Day Move`), 6 (`Cycle Progress 0–100%`), 7 (`Cross-Asset Correlation`), and 10 (`15m ORB Flip Backtest`).
- **Phase 3 (Options Overlays, Forecasting, Event Reactions & AI News)**: `T20.4` agent tools + live `tantra-adapters` option chains for Tabs 8 (`Covered Call`), 9 (`Expiry Premium & Strike Lab`), 11 (`Forecasting`), 12 (`F&O Inclusion/Exclusion`), `Buyback` / `Earnings & Macro` modes, and Tab 13 (`AI Study Assistant`).
