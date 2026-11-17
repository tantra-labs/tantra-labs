# M1 — Dow Theory, Trends & Chart Construction

> **Weeks 17–19 · 24 hrs · PLO-3 · Core readings:** Edwards & Magee ch. 3–5, 13–14;
> Murphy ch. 2, 4, 7; Pring ch. 18

## Learning outcomes

- State the Dow Theory tenets and its defects.
- Define primary/secondary/minor trends and mark them on a chart.
- Draw valid trendlines and channels; identify support and resistance.
- Construct line, bar, and candlestick charts; interpret volume & open interest.
- Compute trendline slopes, projections, and the SMA cross signal in `Decimal`.

## Prerequisites

- [Semester 1](../s1/overview.md): knowing what an index is (NIFTY 50, SENSEX),
  what a share is, and how a quote is built (open, high, low, close, volume).
  Re-read the S1 module on reading a quote before this module.
- `Decimal` arithmetic: every price and average in this course is a
  `decimal.Decimal`. Python `float` is forbidden for prices.
- A working Python environment with the `tantra` wheel installed
  (`pip install tantra`) — the labs need it.

## Lesson 1.1 — The Dow Theory

### 1) Concept

The Dow Theory is the oldest formal description of how stock-market prices
trend. Charles H. Dow, first editor of *The Wall Street Journal* (and co-founder
of Dow Jones & Co.), never wrote a book; his editorials (1900–1902) were
codified by William P. Hamilton and later Robert Rhea. The six tenets are:

1. **The averages discount everything** — every known and knowable fact (news,
   earnings, government policy, even crowd emotion) is already inside the price.
2. **Three trends exist** — primary (months to years), secondary (weeks to
   months), minor (days).
3. **Primary trends have three phases** — accumulation, public participation,
   distribution.
4. **Indices must confirm each other** — in Dow's day, industrials and rails. On
   NSE today we use the NIFTY 50 and Bank Nifty the same way: a new high in one
   index that the other refuses to confirm is a warning, not a buy signal.
5. **Volume must confirm the trend** — rising prices on rising volume confirm;
   rising prices on falling volume are suspect.
6. **A trend is assumed intact until a definite reversal signal** — you follow
   the trend until it proves broken, not until you "feel" it should turn.

The defects matter as much as the tenets: confirmation comes **late** (you act
after the reversal is well underway), signals can be ambiguous, and the theory
gives **no price target** — direction, not destination.

### 2) Worked example

The one piece of mathematics in this lesson is the trend filter used in the
module lab: the **simple moving average (SMA)**. For a window of `n` closing
prices,

```
SMA_t = (p_t + p_{t-1} + ... + p_{t-n+1}) / n      =  (1/n) Σ p_i
```

Example — the last five NIFTY closes are 24,000; 24,100; 24,050; 24,200;
24,150. The 3-day SMA of the last three closes is
`(24,050 + 24,200 + 24,150) / 3 = 24,133.33`:

```python
from decimal import Decimal
closes = [Decimal("24000"), Decimal("24100"), Decimal("24050"), Decimal("24200"), Decimal("24150")]
sma3 = sum(closes[-3:]) / Decimal(3)
print("SMA(3):", sma3)          # 24133.33333333333333333333333
```

### 3) Common pitfalls

> **Pitfall:** thinking the Dow Theory predicts *when* a trend ends. It
> describes the condition *after* a reversal is confirmed — you are late by
> design, and the discipline is to accept that.
> **Pitfall:** watching only one index. The confirmation tenet exists precisely
> because a single average can fake you out. Check NIFTY 50 against Bank Nifty.
> **Pitfall:** mixing the three trends. A minor-trend buy while the primary
> trend is down is a scalp, not a Dow signal — say which trend you are trading.

### 4) Key takeaways

- **Takeaway:** six tenets, and each one describes the *behaviour of the tape*,
  not the news.
- **Takeaway:** the theory's value is discipline: "trend intact until proven
  reversed".
- **Takeaway:** the SMA is the mechanical stand-in for "the trend"; price above
  a rising SMA says the trend is up.

## Lesson 1.2 — Trends and trendlines

### 1) Concept

A market that makes **higher highs and higher lows** is in an uptrend; one that
makes **lower highs and lower lows** is in a downtrend. A **trendline** is a
straight line drawn through at least two reaction lows (in an uptrend) or two
reaction highs (in a downtrend); the more times price *touches* the line without
breaking it, the stronger the line. A **channel** is the pair of parallel lines:
the trendline plus the return line drawn through the intervening highs or lows.
The trendline's slope quantifies how fast the trend rises or falls per unit of
time — and that slope gives you an exact price projection.

### 2) Worked example

A trendline joins two reaction lows: low A at 23,500 on day 5 and low B at
23,900 on day 11.

```
slope = (P_B − P_A) / (T_B − T_A)
      = (23,900 − 23,500) / (11 − 5)   = 400 / 6  ≈ 66.67 points per day

day-20 projection = P_B + slope × (20 − 11) ≈ 23,900 + 600 = 24,500
```

In `Decimal`:

```python
from decimal import Decimal
pa, pb = Decimal("23500"), Decimal("23900")
ta, tb = 5, 11
slope = (pb - pa) / Decimal(tb - ta)
proj = pb + slope * Decimal(20 - tb)
print("slope/day:", slope)        # 66.66666666666666666666666667
print("day-20 projection:", proj) # 24500.00000000000000000000000
```

A touch of the trendline is **not** an entry. Wait for either a confirmed close
beyond the line or a clean bounce off it with a confirming candle.

### 3) Common pitfalls

> **Pitfall:** drawing the trendline through the first two points you see. Use
> *reaction* lows/highs, then validate on later touches.
> **Pitfall:** counting a wick that pierced the line as a "touch". Closes
> validate; wicks only give context.
> **Pitfall:** forcing the line to kiss the latest bar. A trendline must sit
> *behind* price, not be fitted to today.

### 4) Key takeaways

- **Takeaway:** uptrend = HH + HL; downtrend = LH + LL; flat = ranging.
- **Takeaway:** more touches ⇒ stronger line; a two-touch line is a hypothesis.
- **Takeaway:** slope gives a numeric projection — a magnet, not a guarantee.

## Lesson 1.3 — Support and resistance

### 1) Concept

**Support** is a price zone where buying has repeatedly overwhelmed selling —
prices fall into it and bounce. **Resistance** is the mirror: a zone where
selling has repeatedly overwhelmed buying. These zones cluster where humans
leave orders: round numbers (24,000, 25,000), prior pivots, gap edges (M5), and
moving-average lines. The key behavioural rule is **role reversal**: when a
resistance level is broken, it usually becomes support on the retest — and the
same in reverse.

### 2) Worked example

RELIANCE meets resistance at 2,500 three times and is rejected each time. On the
fourth attempt it *closes* at 2,512 — a confirmed break. The trader then marks
the old resistance zone 2,490–2,500 as the new support zone; a retest to 2,495
that bounces confirms the swap.

```python
from decimal import Decimal
resistance = Decimal("2500")
closes = [Decimal("2475"), Decimal("2492"), Decimal("2498"), Decimal("2512")]
breaks = [c for c in closes if c > resistance]
print("confirmed breaks:", breaks)   # [Decimal('2512')]
```

Note the definition: a **close** beyond the level, not an intraday tick.

### 3) Common pitfalls

> **Pitfall:** treating S/R as exact prices. They are *zones* — use a small
> band such as ±0.3%.
> **Pitfall:** forgetting the role swap. Old resistance becomes new support;
> shorts who refuse to cover at the retest are part of the crowd that fuels the
> bounce.
> **Pitfall:** ignoring volume at the level — a break on low volume fails more
> often (Lesson 3.4).

### 4) Key takeaways

- **Takeaway:** S/R zones are where supply and demand have been *proven*.
- **Takeaway:** confirmation means a close beyond the level.
- **Takeaway:** broken levels swap roles — always look for the retest.

## Lesson 1.4 — Chart construction

### 1) Concept

Three classic charts: **line** (closes only), **bar** (O-H-L-C as a vertical
tick with a left/right open/close dash), and **candlestick** (a body between
open and close, wicks to the high and low). A body is bullish when
`close > open` (hollow/green) and bearish when `close < open` (filled/red). In
numbers:

```
body         = |close − open|
upper shadow = high − max(open, close)
lower shadow = min(open, close) − low
range        = high − low
```

Volume is the companion series beneath any chart. For futures, **open interest**
(OI) counts contracts still open at day's end — it is *not* volume (S4-M5).

### 2) Worked example

A NIFTY bar reads open 24,000, high 24,050, low 23,980, close 24,030:

```python
from decimal import Decimal
o, h, l, c = Decimal("24000"), Decimal("24050"), Decimal("23980"), Decimal("24030")
body = abs(c - o)
upper = h - max(o, c)
lower = min(o, c) - l
print("body:", body, "upper shadow:", upper, "lower shadow:", lower, "range:", h - l)
# body: 30  upper shadow: 20  lower shadow: 20  range: 70
```

`close > open`, so the body is bullish; the equal small shadows say both sides
defended their levels, and the 70-point range is the session's volatility.

### 3) Common pitfalls

> **Pitfall:** computing the upper shadow as `high − close`. It must be
> `high − max(open, close)`.
> **Pitfall:** reading volume and OI as the same thing — they answer different
> questions (who traded today vs who holds open contracts).
> **Pitfall:** ignoring the range. Two bars with the same close but very
> different ranges have very different volatility stories.

### 4) Key takeaways

- **Takeaway:** one bar summarises four prices; the wicks tell who was in
  control at the extremes.
- **Takeaway:** volume confirms the story; OI belongs to futures.
- **Takeaway:** always note the range — it is the raw volatility input.

## Lesson 1.5 — Timeframes & swing structure

### 1) Concept

**Timeframes** nest: a weekly bar is five daily bars, a daily bar is 75-minute
bars. The rule of structure trading: *the higher timeframe sets the direction,
the lower timeframe refines the entry*. A **swing high** (pivot high) is a bar
whose high exceeds the `k` bars on either side; a **swing low** is the mirror.
Swings are the building blocks of structure — every pattern in M3 and M7 is
defined over swings.

### 2) Worked example

Pivot-high detection with `k = 2`: bar `i` is a pivot high if `high[i]` exceeds
the highs of bars `i−2 … i+2`.

```python
from decimal import Decimal
from tantra_examples import SampleInstruments, synthetic_bars

bars = synthetic_bars(SampleInstruments.NIFTY50, days=60, seed=7, base_price_paise=24_000)
k = 2
for i in range(k, len(bars) - k):
    window = [bars[j].high for j in range(i - k, i + k + 1)]
    if bars[i].high == max(window):
        print("pivot high:", bars[i].ts.date(), bars[i].high)
        break   # first pivot only
```

### 3) Common pitfalls

> **Pitfall:** trading the daily direction on an intraday signal. State your
> timeframe before drawing anything.
> **Pitfall:** using `k = 1` — two-bar pivots are noise. `k = 2` or `3` gives
> structure that survives scrutiny.
> **Pitfall:** mixing pivot levels from different timeframes in one stop
> calculation.

### 4) Key takeaways

- **Takeaway:** direction from the higher timeframe, entry from the lower.
- **Takeaway:** swings are the vocabulary every later pattern uses.
- **Takeaway:** an unstated timeframe is a trade without a plan.

## Tantra Lab 1 — Trend detection with SMA structure

### Lab goal

Prove that a mechanical SMA cross (the "golden cross") can count trend changes,
and compare its dates with the trendlines and S/R zones you draw by hand.

### Code

```python
from decimal import Decimal
from tantra.indicators import SMA
from tantra_examples import SampleInstruments, synthetic_bars

bars = synthetic_bars(SampleInstruments.NIFTY50, days=250, seed=7, base_price_paise=24_000)

fast, slow = SMA(10), SMA(20)
crosses = 0
prev_fast = prev_slow = None
for bar in bars:
    f = fast.add(bar.close); s = slow.add(bar.close)
    if prev_fast is not None and prev_slow is not None and f is not None and s is not None:
        if prev_fast <= prev_slow and f > s:
            crosses += 1  # golden cross
    prev_fast, prev_slow = f, s

print("golden crosses:", crosses)
```

### Expected output

A single line such as `golden crosses: N`, where `N` is a small integer (2–6 on
a 250-bar synthetic series for this seed). `fast.add()` returns `None` for the
first 9 bars and `slow.add()` for the first 19 — the detector silently skips the
warm-up region, which is exactly why the `is not None` guards exist.

### Hand-in checklist

- [ ] 30 annotated charts: primary/secondary/minor trends marked on each.
- [ ] At least 10 valid trendlines (≥3 touches, slope recorded, projection).
- [ ] S/R zones labelled with the *reason* (round number, prior pivot, gap).
- [ ] A comparison table: SMA golden-cross dates vs your hand-drawn trend
      changes — where do they agree, and where not, and why?
- [ ] The lab output line `golden crosses: N` pasted into the journal.

### Common errors

- **Comparing `f`/`s` before warm-up** — both can be `None`; the `is not None`
  guards are mandatory.
- **Converting `bar.close` to float** — it is already `Decimal`; leave it.
- **Skipping the previous values** — a cross needs *two* consecutive readings of
  the pair; `prev_fast`/`prev_slow` are the entire point of the loop.

## Practice problems

1. A stock closes at 248, 250, 249, 253, 256 over five days. Compute SMA(3) for
   the last three days by hand, then in `Decimal`.
2. Two reaction lows: 22,800 on day 4 and 23,100 on day 10. What is the
   trendline slope per day, and the projected value on day 18?
3. A bar has open 1,500, high 1,535, low 1,490, close 1,520. Compute body, both
   shadows, and range. Is the body bullish?
4. Support at 5,000 is broken with a close of 5,012. Where is the *new* support
   zone likely to be, and why?
5. List the six Dow tenets from memory, then say which one would have warned you
   *earliest* when a bull market is ending — and why.
6. In one sentence each: what does volume measure and what does open interest
   measure? Give a NIFTY futures example of each.
7. On a 250-bar synthetic series, count pivot highs with `k = 2`. Would `k = 5`
   give more or fewer pivots, and why?
8. The Dow Theory gives no price targets. Which tool in this module *can* give a
   numeric projection, and what invalidates it?

### Solutions

1. `(249 + 253 + 256) / 3 = 758 / 3 = 252.67`.
2. `slope = (23100 − 22800) / (10 − 4) = 300 / 6 = 50/day`; day 18 projection =
   `23100 + 50 × (18 − 10) = 23,500`.
3. body `= |1520−1500| = 20`; upper shadow `= 1535 − 1520 = 15`; lower shadow
   `= 1500 − 1490 = 10`; range `= 45`. Bullish, because close 1,520 > open 1,500.
4. The zone 5,000–5,010: broken support swaps roles and becomes resistance.
5. Confirmation would warn earliest — one index refusing to confirm a new high
   is the first crack in the story.
6. Volume counts shares traded today; open interest counts futures contracts
   still open at day's end. Example: heavy volume with falling OI means shorts
   are covering, not new longs entering.
7. Fewer — a 5-bar window is stricter; only the largest swings qualify.
8. The trendline projection (slope × time), and it is invalidated by a confirmed
   close through the trendline.

## Quiz bank

| Question | A | B | C | D | Answer |
|---|---|---|---|---|---|
| Which Dow tenet says prices already contain all known information? | Three trends | Averages discount everything | Volume confirms trend | Three phases | B |
| A primary trend typically lasts | Days | Weeks | Months to years | One session | C |
| An uptrend is defined by | Higher highs, higher lows | Lower highs, lower lows | A flat range | Rising volume only | A |
| A resistance break is *confirmed* when | Price ticks above | Price closes above | Volume halves | News says so | B |
| After resistance breaks, it usually becomes | Stronger resistance | Support | A gap | Irrelevant | B |
| A trendline is stronger when it has | A steep slope | More touches | A bright colour | Two points only | B |
| The upper shadow of a candle equals | high − low | high − max(open, close) | min(open, close) − low | close − open | B |
| SMA(3) of closes 100, 102, 104 equals | 100 | 102 | 103 | 104 | B |

## Glossary

- **Dow Theory** — the six-tenet framework describing how prices trend, discount
  information, and confirm each other.
- **Primary trend** — the months-to-years dominant direction of the market.
- **Secondary trend** — a weeks-to-months reaction against the primary trend.
- **Minor trend** — the days-scale noise within the larger trends.
- **Trendline** — a straight line through two or more reaction lows (up) or
  highs (down) that marks trend direction.
- **Channel** — a trendline plus its parallel return line.
- **Support** — a price zone where buying has repeatedly overcome selling.
- **Resistance** — a price zone where selling has repeatedly overcome buying.
- **Role reversal** — the tendency of broken resistance to become support, and
  vice versa.
- **Golden cross** — a fast SMA crossing above a slow SMA; a bullish filter.
- **Swing (pivot) high/low** — a bar whose high/low exceeds its neighbours
  within a `k`-bar window.
- **Open interest** — the number of futures contracts still open at day's end.

## Reading assignment

- Edwards & Magee, *Technical Analysis of Stock Trends*, ch. 3–5, 13–14.
- Murphy, *Technical Analysis of the Financial Markets*, ch. 2, 4, 7.
- Pring, *Technical Analysis Explained*, ch. 18.
- Platform: run `tantra-examples/examples/01_loading_data.py` and
  `02_indicators.py` to see the SMA/EMA surface you will use all semester.
- Full list: [Reading & Resource List](../appendices/reading-list.md).

## Assessment reminder

This module feeds the **mid-term quiz** (Dow Theory tenets and defects), the
**chart-lab practical** (30 annotated charts with trends, trendlines and S/R),
and your **trading journal** (the SMA-cross comparison table). Grading detail is
in [Assessment](../front/assessment.md).

## Assessment

- Chart-lab practical: 30 annotated charts (trends, trendlines, S/R).
- Quiz: Dow Theory tenets and defects.

**Next:** [M2 — Candlestick Analysis](m2-candlesticks.md)
