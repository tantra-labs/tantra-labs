# Course Content Expansion Spec (for subagents)

This file is the **binding spec** for expanding the mdBook module chapters in
`docs/training/book/src/`. Every subagent must follow it exactly. It lives
outside `src/` so it is never compiled into the book.

## 1. Goals

Expand each module chapter from its current outline (learning outcomes +
lesson topics + a Tantra lab) into **detailed, self-study course material**
suitable for a Class 12 passout with no finance background. The final book must
remain buildable with `mdbook build` and every lab must use **verified, real
Tantra wheel APIs**.

## 2. Non-negotiables

1. **Do not rename or remove existing files.** Keep the exact `SUMMARY.md`
   chapter paths and the module's `# Title` heading.
2. **Do not delete existing lesson headings, lab headings, or "Next:" links.**
   Expand them; preserve `**Next:** [M…](m…-….md)` links at the bottom.
3. **Zero-Floats policy:** every price, quantity, fee, balance, and return in
   code must be `decimal.Decimal`. Never use Python `float` for money/prices.
4. **Verified APIs only** — use the API cheat sheet in §7. Do NOT invent
   function names. If an example script is referenced, only reference scripts
   listed in §7.
5. **mdBook-safe markdown:** no KaTeX preprocessor is installed, so **write all
   formulas as ASCII/Unicode math in code fences or inline plain text** (the
   book's existing convention), never `$...$` or `$$...$$`.
6. Keep fenced code blocks labelled ` ```python ` where code is Python.

## 3. Section template (in order) for each module chapter

Keep and expand the existing structure. A fully-expanded module chapter contains,
in this order:

```
# <existing title>            (keep verbatim)

> <keep the existing > blockquote: weeks/hours/PLO/core-reading line>

## Learning outcomes          (keep, polish wording if needed)
- ... (keep existing bullets; add 1–2 if useful)

## Prerequisites              (NEW — add after learning outcomes)
- Which earlier modules/skills this module assumes (link to the chapter).

## Lectures                   (each existing "## Lesson x.y —" becomes a lecture)
For EVERY existing lesson heading, expand it to include:

### 1) Concept (prose)
3–6 plain-language paragraphs explaining the concept. Define every technical
term the first time it appears. Use Indian market examples (NSE/BSE/MCX, Nifty,
Sensex, RELIANCE, INFY, TCS, USD/INR, repo rate, T+1 settlement, etc.).

### 2) Worked example
A concrete numeric example with the formula written out in a code fence (or
inline ASCII), then a short `python` code block showing the same computation in
Decimal. Show the answer.

### 3) Common pitfalls
A "> **Pitfall:**" callout (or bullet list) with 2–4 typical mistakes a
beginner makes (mixing decimal/float, ignoring warm-up `None`, using RSI 30/70
mechanically, misreading ex-date prices, off-by-one in windows, etc.).

### 4) Key takeaways
2–4 bullets starting "**Takeaway:**".

## Tantra Lab <n>            (expand every existing "## Tantra Lab n —" section)
For every existing Tantra Lab heading, expand to:

### Lab goal
One sentence: what the learner proves by running this lab.

### Code
Keep the existing verified snippet as the core. You may add a small helper,
but DO NOT change the verified calls. Wrap in ` ```python `.

### Expected output
What the script prints (state it in words; for Decimal outputs you may show
approximate expected values with "≈"). If the lab already shows output, keep it.

### Hand-in checklist
3–6 checkboxes (what the learner submits/records in the journal).

### Common errors
2–3 likely runtime/mental errors and their fixes.

## Practice problems            (NEW — add after the last lab, before glossary)
5–8 numbered problems (compute, explain, classify, or short-code). Provide a
**Solutions** subsection at the end (or a `<details>` block per problem).

## Quiz bank                    (NEW)
5–10 MCQs in a markdown table (Question | A | B | C | D | Answer). Answers
single letters.

## Glossary                     (NEW)
5–12 terms from the module, each: **term** — one-line definition.

## Reading assignment           (NEW)
Reference the relevant chapters/books from
`../appendices/reading-list.md` (relative link `../appendices/reading-list.md`
for s1/s2/... files; adjust depth for nested dirs — all module files are one
level below src, so use `../appendices/reading-list.md`).

## Assessment reminder          (NEW)
1–2 sentences: which graded components this module feeds
(mid-term/end-term/lab/journal), cross-referencing
`../front/assessment.md`.
```

## 4. Depth guidance per semester

- **Semester 1 (s1/):** heavily pedagogical, plain-language, slow pacing,
  many hand-computed worked examples. Keep math to arithmetic-level.
- **Semester 2 (s2/):** the mathematical core. Every indicator formula must
  be written out, derived step-by-step where cheap, and demonstrated in code.
  This is the module set the reader explicitly asked for "the mathematics
  behind technical analysis".
- **Semester 3 (s3/):** statement-level worked examples, ratio walkthroughs,
  DCF/DDM/WACC numeric examples.
- **Semester 4 (s4/):** statistics/portfolio math with formulas + Decimal
  code; options pricing worked examples via `tantra.options`.
- **Semester 5 (s5/):** expand each track into a syllabus of the capstone
  (tasks, grading rubric, deliverables), plus a study plan.

## 5. Verification of source coverage

Keep the module's coverage accurate relative to `../appendices/coverage-matrix.md`.
When expanding lessons, make sure every topic currently listed for that module
in the coverage matrix appears in the expanded text (it already does in the
outline — do not drop any).

## 6. What NOT to do

- Do not add new chapter files, do not edit `SUMMARY.md`.
- Do not change `book.toml`.
- Do not move the build directory.
- Do not add `$` LaTeX.
- Do not import Tantra names other than those in §7.
- Do not invent example-script filenames.
- Do not run `mdbook build` or install anything (heavy); write valid markdown
  instead. The orchestrator builds and verifies.

## 7. Verified API cheat sheet (the ONLY surface you may reference)

```python
# --- data (tantra-examples) -------------------------------------------------
from tantra_examples import SampleInstruments, synthetic_bars, trending_bars
bars = synthetic_bars(SampleInstruments.NIFTY50, days=250, seed=42, base_price_paise=24_000)
# bar fields: .instrument, .ts, .open, .high, .low, .close, .volume  (Decimal)

# --- legacy indicators: .add(p) -> Decimal | None; .value(); .previous_value -----
from tantra.indicators import SMA, EMA, RSI
sma = SMA(20); sma.add(price); sma.value(); sma.crosses_above(other); sma.crosses_below(other)
ema = EMA(10); ema.add(price)
rsi = RSI(14); rsi.add(price)

# --- family indicators: .update(...) -> value object | None until warm-up --------
from tantra.indicators import Macd, Bollinger, Atr, Ichimoku, Adx, Donchian
Macd(fast=12, slow=26, signal=9).update(price)      -> MacdValue(macd, signal, histogram) | None
Bollinger(period=20, mult=Decimal("2")).update(price) -> BollingerValue(upper, middle, lower) | None
Atr(period=14).update(high, low, close)             -> Decimal | None
Ichimoku(tenkan=9, kijun=26, senkou_b=52, displacement=26).update(high, low)
                                                   -> (span_a, span_b) | None
Adx(di_length=14, adx_smoothing=14).update(high, low, close) -> AdxValue(adx, plus_di, minus_di) | None
Donchian(period=20).update(high, low)               -> DonchianValue(upper, lower) | None

# --- paper trading ---------------------------------------------------------
from tantra.paper import PaperSession
from tantra.instrument import InstrumentId
session = PaperSession(cash=Decimal("1000000"), seed=7)
session.set_market_price(InstrumentId("RELIANCE", "NSE"), Decimal("100"))
session.place_order(inst, "BUY", Decimal("10"), order_type="LIMIT", limit_price=Decimal("100"))
session.advance_to("2023-11-14T22:14:00Z")
session.fills(); session.positions(); session.equity(); session.cash(); session.events()
session.run(strategy, bars)  -> PaperResult(strategy_name, fills, equity_curve)

# --- strategy + backtest ---------------------------------------------------
from tantra import Strategy, Parameter, run
class MyStrategy(Strategy):
    def on_start(self): ...
    def on_bar(self, bar): self.buy("NSE:RELIANCE-EQ", 10)
run(MyStrategy(), bars) -> BacktestResult(bars_processed, orders_filled, events, refusals)

# --- quant -----------------------------------------------------------------
from tantra.quant import returns, mean, std_dev, covariance_matrix, ols, solve_linear_system

# --- options ---------------------------------------------------------------
from tantra.options import bs_price, bs_greeks, implied_volatility, OptionChain, OptionContract, OptionKind, OptionStyle
bs_price(spot=..., strike=..., expiry=..., rate=..., vol=..., kind="call", style="european")
bs_greeks(spot=..., strike=..., expiry=..., rate=..., vol=..., kind="call")
implied_volatility(price, spot=..., strike=..., expiry=..., rate=..., kind="call")

# --- portfolio strategy ----------------------------------------------------
from tantra.portfolio_strategy import (build_portfolio_strategy, EqualWeight,
    TopN, momentum, low_volatility, MonthlyFirstSession, NamedUniverse,
    InverseVolatility, DriftBand)

# --- screener --------------------------------------------------------------
from tantra.screener import load_catalog, MetricCatalog

# --- runnable example scripts (reference by exact path, do not invent more) --
# tantra-examples/examples/01_loading_data.py, 02_indicators.py,
# 07_turtle_breakout_backtest.py, 10_walkforward_optimization.py,
# 14_timeseries_forecast.py, 15_fama_macbeth_factor_regression.py,
# basic/06_paper_trading.py, backtesting/01_first_backtest.py, 04_walk_forward.py,
# 05_monte_carlo.py, options/01_option_chain.py, 02_greeks_calculation.py,
# 03_backtest_straddle.py, screening/01_multibagger_screener.py,
# 03_dividend_yield_screener.py, 04_intelligent_investor_screener.py,
# 05_net_net_screener.py, strategies/02_with_indicators.py, 04_risk_management.py,
# mutual_funds/01_fetch_nav.py, 02_sip_backtest.py, 03_category_analysis.py,
# 04_portfolio_optimization.py, storage/03_import_amfi_nav.py,
# optimizer/03_deflated_sharpe_analysis.py
```

## 8. Reporting back

Return: the list of files you wrote/expanded, a one-paragraph summary per file
of what you added, and any content you could not cover (with a precise question
if a fact was missing — per the zero-recon rule, ask rather than guess).
