# Research — Trendlyne screeners, DVM, Alpha Alerts & MCP → what Tantra should adopt

**Date**: 2026-11-15 · **Scope**: idea source only (native implementation; no Trendlyne data
dependency, no adapter to its paid MCP) · **Roadmap**: [`docs/plans/0010`](../plans/0010-screener-taxonomy-and-alerts.md)

Trendlyne is an Indian equity research platform (NSE/BSE). Its value for Tantra is not its data
(proprietary, subscription-gated, no public API) but its **organizing taxonomy**: how a retail/pro
investor's screening, scoring, and alerting needs decompose into reusable categories. This note
records that taxonomy and maps every piece onto existing or missing Tantra capability.

---

## 1. Screener taxonomy ("by type")

Source: `trendlyne.com/stock-screeners/` by-type listing. 1,500+ filterable parameters underpin
custom screens; prebuilt screens are grouped as follows.

| Category | Sub-types | Data needed | Tantra today |
|---|---|---|---|
| **Expert** | Bullish, Bearish, Guru (backtested curated screens) | composite of all below | `tantra-examples/pipeline/screeners.py` (Multibagger/Value/Dividend) — ad-hoc |
| **DVM** | High / Mid / Low DVM score | composite score (§2) | **missing** |
| **Price & Volume** | Price/Volume, Delivery % | bars, NSE delivery | bars ✅, delivery store ✅ (`tantra-data` delivery reader) |
| **Intraday** | ±Technicals, ±Price/Volume, ±Candlesticks | intraday bars + indicators | indicators ✅ (`tantra-market-indicators`), candlestick patterns partial |
| **Swing** | ±Relative Returns, ±Price, Price/Volume, ±Technical, ±Candlesticks | daily bars, benchmark returns | partial (`screening/swing*.py`) |
| **Relative Value** | PE, P/BV, ROCE, ROE, ROA, PEG, Dividend, NP growth, Revenue growth | fundamentals + **sector/industry peers** | ratios store ✅ (`fundamental_ratios`); peer grouping **missing** |
| **Relative Returns** | vs Sector, Industry, Nifty50, Sensex, Nifty500 (out/under-performers) | classification + **index membership** + benchmark series | **missing** (no classification, no constituents beyond Nifty50/Alpha30 mirror) |
| **Financials** | Key metrics, Result filters, Analyst calls, Dividend, FCF, Red Flags | statements, estimates | statements ✅ (yfinance, gap 0020 closed); estimates **missing** |
| **Technicals × timeframe** | 15m / 30m / 1H / 2H / Day / Week / Month × {RSI/MFI/MACD, Bollinger/Supertrend, ADX/Williams %R, ROC/CCI, Stochastic, Support/Resistance, Momentum score} | multi-TF bars + indicators | indicators ✅; Rust `MetricKeySpec{metric, period: Timeframe}` ✅; Python `ScreenQuery` has **no timeframe** |
| **Moving Averages** | Golden/Death cross, LTP above/below SMA/EMA, bullish/bearish SMA/EMA crossovers | bars | `ComparisonOp.crosses_above/below` ✅ (Python) — not in Rust `FilterOp` |
| **Shareholding** | Promoter, Pledges, FII, DII+MF, Public/Retail, Insider/SAST | quarterly shareholding, SAST filings | institutional flow (aggregate) ✅; per-stock shareholding **missing** |
| **Candlesticks** | Bullish/Bearish × 1-day / 2-day / 3+-day patterns | OHLC | partial |
| **Red Flags** | Financial, Business | statements, pledges, auditor/regulatory events | **missing** |
| **PE Buy/Sell Zone** | Buy zone, Sell zone (PE vs own 3/5/10-yr history) | PE time series | ratios store has point-in-time PE ✅; history band **missing** |
| **Other** | Penny, F&O, Family groups, Themes (e.g. PLI), Forecaster (analyst estimates), Live results, Growth/Value/Delivery | themes, F&O list, estimates | F&O list partial; themes/estimates **missing** |

**Named recipes** worth shipping as catalog presets: Piotroski F-score, Greenblatt Magic Formula,
Darvas box, "PE below 3/5/10-yr average", "debt-free + positive FCF + low PE", "promoters
increasing stake QoQ", "relative outperformance vs sector over the quarter", "PE < sector PE".

**Key insight**: ~70% of Trendlyne's categories are *combinations* of three primitives Tantra
largely lacks — (a) a **classification taxonomy** (sector/industry/cap bucket/index/theme),
(b) **point-in-time universes**, and (c) **peer-relative metrics** (value or return relative to
sector/industry/index). Indicators and fundamentals Tantra mostly has.

## 2. DVM score mechanics

| Score | Measures | Inputs (published) | Good | Mid | Bad | Refresh |
|---|---|---|---|---|---|---|
| **Durability** | financial health | revenue/profit stability & growth, cash flow, debt, earnings quality, regulatory warnings | > 55 | 35–55 | < 35 | on new results/filings |
| **Valuation** | affordability | PE, PB, price vs own history and vs industry | > 50 | 30–50 | < 30 | intraday on new data |
| **Momentum** | bullishness | price, volume, MAs, RSI, 30+ technicals | > 59 | 30–59 | < 30 | end of day |

- Each is a **0–100 universe-relative rank**; weights are **not published** (a black box).
- Ineligible when financials can't be validated (e.g. market cap < ₹50 cr).
- Combo labels (`D V M` as G/M/B): GGG *Strong Performer*, GGB *Value-oriented*, GBG *Expensive
  quality*, BGG *Turnaround potential*, BGB *Value trap*, BBG *Momentum-driven*, BBB *Weak*.
- Alert transitions built on it: *momentum trap*, *falling comet*, *rising momentum*, *high
  durability crossover*, *strong performer getting expensive*.

**Tantra adaptation — QVM**: ship an open **Quality / Value / Momentum** composite (distinct name,
no imitation of a trademark). Differences that are deliberate improvements:
1. **Transparent weights** declared in a versioned TOML spec; score explains itself per factor.
2. **Point-in-time** (filing date, not period end) to avoid look-ahead bias in backtests — the
   `fundamentals` table already stores `filing_date`.
3. **`Decimal` percentile ranks** within a configurable universe (all-NSE, Nifty500, a sector).
4. Same G/M/B band + combo-label idea, thresholds configurable, defaults documented.

## 3. Alpha Alerts catalog

One alert = **one rule over a group** (up to 5 universes: portfolios, watchlists, indices).
Frequencies 15m / 30m / 1H / Daily. Delivery: push, email (live or digest), WhatsApp.

| Family | Conditions |
|---|---|
| Price | daily change > ±5% / ±10%; week / 52-wk / 10-yr high/low crossing; near 52-wk high/low |
| Moving averages | Golden / Death cross; price crossing above/below SMA (5,10,20,30,50,100,150,200) / EMA (5,10,12,20,26,50,100,200) |
| Volume & delivery | volume shockers, high volume + top gainers/losers; rising / high delivery % (daily) |
| Breakouts | LTP > R1/R2/R3, LTP < S1/S2/S3 (pivot levels) |
| Results | declared today (rising/falling revenue, profit YoY/QoQ), post-result outperformance, upcoming results with rising price/delivery |
| Corporate actions | upcoming dividend, bonus, split |
| Big deals | insider/SAST buy/sell > 1% of shares (today / yesterday / week / month) |
| DVM | strong DVM select, high durability crossover, getting expensive; momentum trap, falling comet, weak; rising / high momentum |
| Screener | stock **enters** / **exits** a saved screener |
| Email digests | results, research reports, earnings calls, events, announcements |

**Tantra today**: `PriceAlert{instrument_id, price, status}` (`tantra-agent-chat-tools/src/ports/alert.rs`),
stored per-user via `ProfileStore` (`tantra-runtime-api-rest/src/chat_alerts.rs`). There is **no
evaluator** for group rules and no edge-triggered (enter/exit) semantics.

**Tantra adaptation**: every alert family above is expressible as
`AlertRule { universe, condition: ScreenerFilterGroup, frequency, trigger: Enter | Exit | Level }`
evaluated by a runtime scheduler that diffs consecutive screen results — i.e. **alerts are saved
screens with edge detection**. One engine replaces N bespoke alert types.

## 4. Trendlyne MCP inventory

13 tools (subscription-gated; separate product from the web subscription):

| Group | Tool | Args |
|---|---|---|
| Market data | `search_entities` | `query`, `entity_type`=stock, `limit`=10 |
| | `search_financial_parameters` | `query` |
| | `get_stock_parameter_values` | `stock_codes[1..10]`, `parameters[1..50]` |
| | `get_parameter_values_multi_stock` | `query`, `type` ∈ stock/etf/index |
| | `get_stock_eod_ohlc` | `stock_code`, `period` ∈ weekly/monthly |
| Research | `get_overview_news_corp_events` | `stock_code`, `type` ∈ overview/technical/news/events |
| | `get_ownership_deals_insider_sast` | `stock_code`, `type` ∈ shareholding/sast/bulkblockdeal |
| | `get_document_search_results` | `query` (semantic search: annual reports, results, transcripts, presentations) |
| Watchlists | `watchlist_creation`, `watchlist_listing`, `watchlist_stocks`, `watchlist_add_stock`, `watchlist_remove_stock` | ids / titles |

**Observations**: (1) parameter discovery is a tool (`search_financial_parameters`) — the LLM
looks up metric keys before querying; (2) **no full-market screen tool** — the agent can only
pull ≤10 named stocks per call; (3) watchlists are first-class agent-writable objects;
(4) qualitative research is semantic document search.

**Tantra adaptation** (`tantra-agent-mcp`, hand-written `list_tool_definitions` + `call_tool`
match arm): `screen_catalog` (browse presets by category), `metric_search` (parameter discovery),
`screen_run` (full-universe scan → `$tantra/ref` handle for large results), `universe_resolve`,
`classification_lookup`, `qvm_score`, `alert_rule_{create,list,delete}`, `watchlist_{create,list,add,remove}`.
Tantra already has `FilingsSearch` / `NewsSearch` chat tools for the document-search role.

## 5. Gap matrix — Trendlyne → Tantra

| # | Capability | Provider repo (tier) | Status in Tantra |
|---|---|---|---|
| F1 | Classification value objects (`Sector`/`Industry` 4-level NSE hierarchy, `MarketCapBucket`, `IndexId`, `ScreenCategory`) + `crosses_*` in `FilterOp` | `tantra-core` (L0) | missing |
| F2 | Instrument master + point-in-time index membership + SEBI cap-bucket list | `tantra-data` (L6) | missing (examples mirror only) |
| F3 | Unified screen DSL (timeframe, between, AND/OR groups, classification & peer-relative filters) aligned to `tantra-core/src/screener.rs` | `tantra-data` (L6) | partial |
| F4 | Declarative screen catalog (TOML presets per category, named recipes) | `tantra-data` (L6) | partial (`examples/screening/chains/*.toml`) |
| F5 | QVM composite score | `tantra-data` (L6) | missing |
| F6 | SDK `StrategyContext.universe / classification / screen` | `tantra-strategies` (L6) | missing |
| F7 | Group/screener alert rules + evaluator + persistence | `tantra-core` (wire), `tantra-runtime` (L3) | price-only |
| F8 | MCP screener/universe/alert/watchlist tools | `tantra-agent` (L3) | missing |
| F9 | Shareholding / pledge / SAST / analyst-estimate ingestion | `tantra-data` (L6) | missing (filed as gap) |

Tier note: Python packages (L6) consume Rust (L0–L4) via the `tantra` FFI wheel or HTTP; the
Python classification enums must mirror `tantra-core` wire strings, not fork semantics.

## Sources

- [Trendlyne stock screeners (by type)](https://trendlyne.com/stock-screeners/)
- [Trendlyne score details (DVM thresholds & labels)](https://trendlyne.com/score-details/)
- [What is the Trendlyne DVM score](https://help.trendlyne.com/support/solutions/articles/84000347982-what-is-the-trendlyne-dvm-score-and-how-does-it-work-)
- [Alpha Alerts](https://trendlyne.com/alerts/portfolio-real-time-alerts)
- [Trendlyne MCP documentation](https://trendlyne.com/subscription/mcp/documentation/)
- [Trendlyne MCP capabilities (help)](https://help.trendlyne.com/support/solutions/articles/84000399411-what-capabilities-are-currently-available-in-the-trendlyne-mcp-server-)
