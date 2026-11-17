# M8 — Introduction to Technical Analysis

> **Weeks 14–15 · 16 hrs · PLO-3 (introduction)**

## Learning outcomes

- Contrast fundamental and technical analysis.
- State the core philosophy of TA: *price discounts everything*.
- Read a basic line/bar/candlestick chart.
- Explain why TA works: crowd psychology and self-reinforcing expectations.

## Prerequisites

- [M1 — Financial Literacy & Business Math](m1-math.md): the moving-average idea in the lab is an M1 arithmetic average.
- [M2 — Excel for Finance](m2-excel.md): you will chart the series and the MA there.
- [M6 — Corporate Actions](m6-corporate-actions.md): charts must use *adjusted* prices — that rule is assumed from here on.
- This is the *introduction* module; the full indicator mathematics arrive in Semester 2, and risk/execution in Semester 4.

## Lesson 8.1 — Fundamental vs technical

### 1) Concept

Two lenses compete for the analyst's attention. **Fundamental analysis** asks *what is the company worth?* — earnings, balance sheet, industry, management, valuation multiples (the whole Semester 3 toolkit). **Technical analysis** asks *what is the market paying, and what does price action tell us?* — it studies the price chart, volume, and derived indicators, ignoring most company news. Fundamentalists read the DRHP and annual report (M7); technicians read the chart.

They are not rivals; they are *different questions*. A fundamental view ("INFY is worth ₹1,900") does not tell you *when* the market will agree; the technician's trend and momentum signals try to time that agreement. The CFTe curriculum (the course's certification track) and NISM XV both demand both skill sets — professional equity research uses fundamentals for *what* and technicals for *when*. Your Semester 1 duty is to know which question each tool answers, not to pick a side.

### 2) Worked example

The same stock, two lenses:

```
Fundamental: INFY EPS = ₹70, P/E vs peers => fair value ≈ ₹1,900
Technical:   price above its 50-day average, making higher lows => uptrend
Both can be true at once; they answer different questions.
```

```python
from decimal import Decimal

eps = Decimal("70")
pe = Decimal("27")
fair_value = eps * pe
print("fundamental fair value:", fair_value)
```

Output: `fundamental fair value: 1890` — a value *estimate*; the technical lens separately asks whether the price action confirms.

### 3) Common pitfalls

> **Pitfall:** declaring one method "better" — they answer different questions and the professional uses both. **Pitfall:** using a fundamental fair value without a technical check of *when* to transact. **Pitfall:** importing fair-value discipline into a short-term technical trade (and vice versa).

### 4) Key takeaways

- **Takeaway:** fundamental = what it's worth (S3); technical = what price says (S2).
- **Takeaway:** both appear in CFTe and NISM XV curricula — professional fluency needs both.
- **Takeaway:** fundamentals for *what*, technicals for *when*.

## Lesson 8.2 — The three TA premises (Murphy)

### 1) Concept

John Murphy's three premises are the founding axioms of technical analysis:

1. **Price discounts everything.** Every known fact — earnings, macro news, sentiment, insider knowledge — is already inside the price by the time you see it. The chart is the aggregate opinion of every market participant. This is why technicians need no news feed: the answer is in the tape.
2. **Price moves in trends.** Markets do not move randomly; they trend — up, down, or sideways — and a trend is more likely to *continue* than to reverse. Trend-following (buy strength, sell weakness) is the discipline built on this premise.
3. **History repeats.** Patterns recur because markets are crowds, and crowds react the same way to the same shapes (fear at breakdowns, greed at breakouts). These recurring shapes are the chart patterns you will catalogue in Semester 2.

Premise 1 is the deepest: it is *why* the approach works even without a theory of what a company is worth — the crowd's expectations are self-reinforcing until they aren't.

### 2) Worked example

Price discounts a surprise — the arithmetic of the reaction:

```
Consensus EPS forecast ₹70; company reports ₹80 (beat by ₹10, +14% vs expectation)
Even "good" news that merely matches expectations is already priced:
a beat beyond expectations moves the price; an in-line print often doesn't.
```

```python
from decimal import Decimal

expected, actual = Decimal("70"), Decimal("80")
surprise = (actual - expected) / expected
print("surprise vs expectation:", surprise)
```

Output: `surprise vs expectation: 0.1428571428571428571428571428` (≈ +14.3%) — price moves on the *surprise*, which is "discount everything" in action.

### 3) Common pitfalls

> **Pitfall:** treating "price discounts everything" as "news doesn't matter" — news matters *through* price; the technician just reads the effect, not the cause. **Pitfall:** assuming trends never end — trends persist but they do end; risk management is the other half (Lesson 8.4). **Pitfall:** believing patterns are guarantees — "history repeats" is about *probabilities*, not certainties.

### 4) Key takeaways

- **Takeaway:** price discounts everything — the chart is the crowd's total opinion.
- **Takeaway:** price trends — and trends tend to continue.
- **Takeaway:** history repeats because crowd psychology repeats.
- **Takeaway:** these premises underpin every S2 indicator and pattern.

## Lesson 8.3 — First look at chart types

### 1) Concept

Charts are price *compressed into shapes*. A **line chart** plots one price (usually close) per period — the smoothest, best for seeing the big trend. A **bar chart** shows each period's **OHLC**: the open (the tick to the left), the high and low (the vertical bar's top and bottom), and the close (the tick to the right). A **candlestick** shows the same OHLC as a *body* (between open and close) with **wicks** (the high/low tails beyond the body): a white/green body means close above open (bullish period); a black/red body means close below open (bearish period). Candles are the professional default because one glance shows who won the period — buyers or sellers.

**Timeframes** choose the horizon: 1m/5m/15m for intraday, 1d for daily swing work, 1w/1M for trend context. The rule: *match the timeframe to your holding horizon* — a daily trader reading a monthly chart is trading a different instrument than they think. The same math (M1 averages) builds a **moving average** — the first indicator — which smooths closes and reveals the trend's direction.

### 2) Worked example

Body and range from one bar:

```
Bar: open 120.00, high 125.00, low 118.00, close 124.00
Body  = close - open  = +4.00   (bullish: close above open)
Range = high - low    = 7.00
Upper wick = high - max(open, close) = 125 - 124 = 1.00
Lower wick = min(open, close) - low  = 120 - 118 = 2.00
```

```python
from decimal import Decimal

open_, high, low, close = Decimal("120"), Decimal("125"), Decimal("118"), Decimal("124")
print("body:", close - open_, "| range:", high - low,
      "| upper wick:", high - max(open_, close),
      "| lower wick:", min(open_, close) - low)
```

Output: `body: 4 | range: 7 | upper wick: 1 | lower wick: 2`.

### 3) Common pitfalls

> **Pitfall:** reading the body as the whole move — the wicks (rejections) matter as much. **Pitfall:** mixing timeframes — a daily signal and an hourly signal in one trade need explicit reasoning. **Pitfall:** charting *unadjusted* prices after a split (M6) — the chart lies.

### 4) Key takeaways

- **Takeaway:** line = close only; bar = OHLC; candle = OHLC with bodies and wicks.
- **Takeaway:** a bullish candle closes above its open; a bearish one below.
- **Takeaway:** timeframe must match the holding horizon.
- **Takeaway:** the moving average is the first trend tool — formalised in S2.

## Lesson 8.4 — What TA is *not*

### 1) Concept

Technical analysis is *not* a crystal ball. A **signal** is a mechanical fact (price crossed its 20-day average; RSI crossed 30). A **setup** is a complete, tradeable plan: the signal *plus* entry, exit, stop, position size, and the reason the trade is on. Beginners trade signals; professionals trade setups. The difference is **risk management** — knowing what you will lose and where you will exit *before* you enter. Indicators produce probabilities, not certainties: RSI at 30 says "oversold", not "guaranteed bounce" — the market can stay oversold far longer than your margin can.

TA works *because* of self-reinforcing crowd expectations (premise 3): many traders watching the same breakout buy together, pushing price further — until the crowd reverses. The professional stance is probabilistic: plan the trade, define the risk, log the result, repeat. Execution and risk are Semester 2/4 topics; this module's job is to install the humility.

### 2) Worked example

A signal vs a setup:

```
Signal: price closed above its 5-day average.  (a fact, not a trade)
Setup:  IF close > 5-day average AND stop-loss 2% below entry AND risk = 1%
        of capital, THEN buy. (a plan: entry, stop, size, reason)
```

```python
from decimal import Decimal

capital = Decimal("100000")
risk_per_trade = Decimal("0.01")
print("max loss budget per trade:", capital * risk_per_trade)
```

Output: `max loss budget per trade: 1000` — ₹1,000 is the most this trade may lose, decided *before* entry.

### 3) Common pitfalls

> **Pitfall:** trading every signal mechanically — RSI 30 is not an automatic buy. **Pitfall:** skipping the stop "this time" — that is how small losses become account disasters. **Pitfall:** judging TA by one trade — judge the *method* across many trades, probabilistically.

### 4) Key takeaways

- **Takeaway:** signal = fact; setup = tradeable plan with risk defined.
- **Takeaway:** TA is probabilistic, not prophetic — risk management is the other half.
- **Takeaway:** self-reinforcing expectations are why patterns persist — and why they end.
- **Takeaway:** define the loss before the entry; S2/S4 formalise the rest.

## Tantra Lab 8 — First chart series

### Lab goal

Hand-compute a 5-day moving average over synthetic closes and produce your first trend-following signal — then see how `trending_bars` differs from `synthetic_bars`.

### Code

```python
from decimal import Decimal
from tantra_examples import SampleInstruments, synthetic_bars, trending_bars

bars = synthetic_bars(SampleInstruments.NIFTY50, days=120, seed=7, base_price_paise=24_000)
closes = [b.close for b in bars]

# A crude 5-day moving average by hand — the *idea* before the indicator module
def sma(series: list[Decimal], period: int) -> list[Decimal | None]:
    out: list[Decimal | None] = []
    for i in range(len(series)):
        if i + 1 < period:
            out.append(None)
        else:
            window = series[i + 1 - period : i + 1]
            out.append(sum(window, Decimal(0)) / Decimal(period))
    return out

ma5 = sma(closes, 5)
print("last close", closes[-1], "last ma5", ma5[-1])
```

**Task:** plot closes vs the hand-computed MA in Excel (reusing S1-M2 skills).
Note where the price crosses the MA — you have just performed the *simplest
trend-following signal*. Compare `synthetic_bars` vs `trending_bars` (the latter
trends — run `from tantra_examples import trending_bars` and print both).

### Expected output

`last close <a Decimal near ₹24,000>` and `last ma5 <a Decimal, the mean of the final five closes>` — for example `last close 24105.5 last ma5 24098.7` (exact values depend on the seeded series; both are Decimals). The first four `ma5` entries are `None` (warm-up).

### Hand-in checklist

- [ ] Lab script printing both series' last values; the MA function saved to `labs/lab8.py`.
- [ ] Excel chart: closes (line) with the MA overlay (S1-M2 skills), crossing points marked.
- [ ] Journal: at the final cross, would the signal have said "up" or "down"? State the rule you used.
- [ ] `synthetic_bars` vs `trending_bars` comparison printed and a 2-sentence difference noted (which trends?).
- [ ] 1-page "why trends persist" essay (assessment item).

### Common errors

- **`None` in the first four values** — that is the warm-up window, not a bug; don't delete the `None` logic.
- **Plotting the MA before it has values** — start the MA series at index 4 in the chart.
- **Treating the seeded numbers as live Nifty** — the synthetic series is for learning; `base_price_paise=24_000` merely sets the starting level.

## Practice problems

1. State Murphy's three premises in one sentence each.
2. Convert a bar into candle terms: open 300, high 312, low 298, close 305. Compute body, range, upper and lower wicks, and state the candle colour.
3. Which timeframe (1m, 1d, 1w) suits a trader planning to hold for several weeks, and why?
4. Why does price move on the *surprise* rather than on "good news"?
5. Give one example of a signal and one of a setup, and the difference in one sentence.
6. After a 1:1 split at ₹2,000, why would a raw chart of the old price series mislead a technician, and what fixes it?

### Solutions

1. Price discounts everything; price moves in trends; history repeats (crowd psychology).
2. Body = `305 - 300 = +5` (bullish, white/green); range = `312 - 298 = 14`; upper wick = `312 - 305 = 7`; lower wick = `300 - 298 = 2`.
3. 1d (daily) or 1w — the weekly horizon needs weekly context; 1m charts are noise for a multi-week hold.
4. Expectations are already in the price ("price discounts everything"); only the difference between outcome and expectation is new information.
5. Signal: "close above the 5-day average" (a fact). Setup: that signal + a 2% stop + 1% risk sizing + a reason (a tradeable plan). The setup adds entry, exit, size, and risk.
6. The raw chart shows ₹2,000 → ₹1,000 — a fake "crash". Adjusting historical prices (divide by the factor) keeps the series continuous so trend lines and indicators are meaningful.

## Quiz bank

| Question | A | B | C | D | Answer |
|---|---|---|---|---|---|
| Fundamental analysis asks: | what is the company worth? | what is the price doing? | when is the IPO? | who is the promoter? | A |
| "Price discounts everything" means: | news is irrelevant forever | the chart holds the crowd's total opinion | prices are random | only insiders matter | B |
| Murphy's premises number: | two | three | four | five | B |
| A bullish candle: | closes below its open | closes above its open | has no wick | is always green only in India | B |
| The upper wick of a bar is: | high − max(open, close) | open − low | close − open | high − low | A |
| A 1m chart suits: | a multi-week hold | an intraday trader | a long-term investor | an auditor | B |
| A signal differs from a setup by: | having a risk plan | needing no reason | being just a fact | being a chart | C |
| RSI at 30 mechanically means: | guaranteed bounce | oversold, not a guarantee | a buy signal always | a crash | B |
| TA is best judged: | one trade at a time | across many trades, probabilistically | by one pattern | by news | B |
| After a 1:1 split at ₹2,000 the adjusted pre-split prices are: | unchanged | halved | doubled | zeroed | B |

## Glossary

- **Fundamental analysis** — estimating what a company is worth (S3).
- **Technical analysis** — reading what the market pays via price and volume (S2).
- **Price discounts everything** — all known information is already reflected in price.
- **Trend** — the persistent direction of price (up, down, sideways).
- **Line / bar / candlestick** — close-only / OHLC / OHLC-with-bodies-and-wicks charts.
- **Body / wick** — the open-to-close block / the high-low tails of a candle.
- **Timeframe** — the bar period (1m, 5m, 1d, 1w) matched to the holding horizon.
- **Moving average** — the rolling mean of closes; a trend smoother.
- **Signal** — a mechanical price/indicator fact.
- **Setup** — a complete plan: signal + entry + exit + stop + size + reason.
- **Warm-up** — the first `period − 1` bars where an indicator has no value (`None`).

## Reading assignment

From the [Reading & Resource List](../appendices/reading-list.md), start Murphy's *Technical Analysis of the Financial Markets* (chapters 1–2: the premises and the basics of chart construction) and Nison's *Candlestick Charting Techniques* introduction. The CFTe syllabus appendices describe the same premises in exam language. The platform reference `tantra-examples/examples/02_indicators.py` shows the real indicator APIs that Semester 2 formalises.

## Assessment reminder

M8 is graded by the **TA premises and chart-types quiz**, the **1-page "why trends persist" essay**, and the **Lab 8 journal entry**, all continuous assessment. The premises and candle anatomy are guaranteed S1 end-term questions and the entry gate to Semester 2's indicator mathematics. See [Assessment & Grading Scheme](../front/assessment.md).

**Next:** [M9 — Professional Skills & Markets Lab](m9-professional-skills.md)
