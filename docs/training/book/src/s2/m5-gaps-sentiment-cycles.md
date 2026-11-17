# M5 — Gaps, Sentiment & Time Cycles

> **Weeks 25–26 · 16 hrs · PLO-3 · Core reading:** Edwards & Magee ch. 12; Murphy ch. 14; Pring ch. 20, 26; IFTA App B, C

## Learning outcomes

- Classify common, breakaway, runaway, and exhaustion gaps.
- Explain why each gap type has a different implication.
- Read sentiment indicators (put/call, VIX intuition, breadth).
- Use the concept of time cycles and seasonality.
- Compute gap size relative to ATR and classify gaps mechanically.

## Prerequisites

- [M1 — Dow Theory & Trends](m1-dow-theory.md): trend phases, support/resistance
  — gaps mean different things depending on *where* in the trend they open.
- [M2 — Candlesticks](m2-candlesticks.md): reversal candles confirm gap
  exhaustion.
- [M4 — Technical Indicators: The Math](m4-indicators-math.md): the ATR formula
  and its `Atr.update(high, low, close)` API — gap size is measured *in ATRs*.

## Lesson 5.1 — Gap mechanics

### 1) Concept

A **gap** is a price range with **no trades**. On an up-gap the market opens
above the previous high and never trades the space between:

```
up gap:   low_t  > high_{t−1}
down gap: high_t < low_{t−1}
```

Gaps happen when overnight news (results, policy announcements, global cues)
moves the *opening auction* in one stroke. The Indian market's T+1 settlement
and the closing-price-based circuit filters do not prevent gaps — they simply
make the opening auction a fairer, more transparent place for them to print.

### 2) Worked example

NIFTY closes Wednesday at 24,100/24,180 (low/high); Thursday opens at 24,250 and
trades 24,220–24,340. The band 24,180–24,220 had no trades — an up-gap.

```python
from decimal import Decimal
from tantra_examples import SampleInstruments, synthetic_bars

bars = synthetic_bars(SampleInstruments.NIFTY50, days=200, seed=7, base_price_paise=24_000)

up_gaps = down_gaps = 0
for a, b in zip(bars, bars[1:]):
    if b.low > a.high: up_gaps += 1
    if b.high < a.low: down_gaps += 1
print("up gaps:", up_gaps, "down gaps:", down_gaps)
```

### 3) Common pitfalls

> **Pitfall:** counting a *range expansion* as a gap. A gap is specifically an
> empty price zone between two consecutive bars — compare `low_t` to
> `high_{t−1}`.
> **Pitfall:** treating gap size as an absolute. Size only matters relative to
> the instrument's own volatility (ATR).
> **Pitfall:** ignoring the opening auction's role — a gap is *where the market
> re-priced overnight information in one move*.

### 4) Key takeaways

- **Takeaway:** up-gap `low_t > high_{t−1}`; down-gap `high_t < low_{t−1}`.
- **Takeaway:** a gap is empty *price*, not empty volume.
- **Takeaway:** measure gaps in ATRs, not points.

## Lesson 5.2 — Four gap types

### 1) Concept

The same mechanical gap means four different things depending on its position in
the trend:

| Type | Where it appears | Implication |
|---|---|---|
| **Common** | Trading range, thin volume | Usually filled quickly; noise |
| **Breakaway** | Out of a range/pattern, high volume | Start of a new move; trend confirmation |
| **Runaway** (measuring) | Middle of a strong trend | Trend continuation; "measuring gap" |
| **Exhaustion** | End of a trend, high volume | Possible final thrust; reversal risk |

Volume is the differentiator: breakaway/runaway gaps are usually high-volume;
exhaustion gaps often print *climax* volume (the largest of the move) as the
last crowd piles in. A runaway gap is called a **measuring gap** because the
move often extends by roughly the same distance again after the gap.

### 2) Worked example

A breakaway from a consolidation: NIFTY range-bound 23,900–24,100 for 12 days,
then a 200-point up-gap on 3× average volume. Runaway: mid-trend, another
150-point gap on 2× volume. Exhaustion: at the top, a final 120-point gap on 5×
climax volume followed by a doji.

```python
from decimal import Decimal
# gap size in ATR units
atr = Decimal("180")          # from M4 lab
for name, gap in [("breakaway", Decimal("200")), ("runaway", Decimal("150")), ("exhaustion", Decimal("120"))]:
    print(name, "gap/ATR:", gap / atr)
# breakaway gap/ATR: 1.11  runaway gap/ATR: 0.83  exhaustion gap/ATR: 0.67
```

### 3) Common pitfalls

> **Pitfall:** classifying by size alone. A 200-point gap is a breakaway at the
> start of a move and an exhaustion gap at the top — *position* in the trend
> decides, not size.
> **Pitfall:** ignoring volume. The same gap with low volume is a common gap;
> with climax volume it is an exhaustion warning.
> **Pitfall:** assuming the classification before the follow-through — a
> "breakaway" is only confirmed if the new trend actually starts.

### 4) Key takeaways

- **Takeaway:** four types — common, breakaway, runaway, exhaustion.
- **Takeaway:** volume separates noise from news and news from climax.
- **Takeaway:** position in the trend is the classification key.

## Lesson 5.3 — Gap-based trading rules

### 1) Concept

Gaps give two practical trading rules:

1. **Breakaway gap + close above the gap** = trade with the gap (continuation).
   The gap is the market *repricing* — do not fight it.
2. **Exhaustion gap + reversal candle** (M2!) = watch for reversal. The climax
   volume plus a doji/shooting star at the top is the classic end-of-move
   signature.

Two facts discipline both rules: **filling the gap is not mandatory** — gap-fill
is a bias, not a law; and the *gap edge* (the empty zone's boundary) becomes a
support/resistance level (M1's role-reversal idea applied to gaps).

### 2) Worked example

Breakaway-gap continuation test: gap up with `low_t > high_{t−1}` and the close
above `high_{t−1}`:

```python
from decimal import Decimal
prev_high, cur_low, cur_close = Decimal("24100"), Decimal("24200"), Decimal("24350")
gap_up = cur_low > prev_high
close_above = cur_close > prev_high
print("gap up + close above = trade with gap:", gap_up and close_above)   # True
```

### 3) Common pitfalls

> **Pitfall:** shorting an exhaustion gap before the reversal candle prints —
> exhaustion is *only* exhaustion in hindsight; wait for the M2 confirmation.
> **Pitfall:** buying every gap on the assumption it will fill upward. Gap-fill
> is a *bias*, strongest for common gaps, weakest for breakaway gaps.
> **Pitfall:** forgetting the gap edge becomes S/R — the level you should
> actually watch is the edge, not the gap's midpoint.

### 4) Key takeaways

- **Takeaway:** trade *with* confirmed breakaway gaps, *against* confirmed
  exhaustion.
- **Takeaway:** gap-fill is a bias, not a law.
- **Takeaway:** gap edges become support/resistance.

## Lesson 5.4 — Sentiment indicators

### 1) Concept

Sentiment indicators measure *what the crowd is doing*, not what price does.
Three classic families:

- **Breadth** — how many stocks participate in the move. The advance/decline
  line (cumulative `advancers − decliners`), new highs vs new lows (IFTA App B).
  A rising index with falling breadth is a warning (only a few stocks carry it).
- **Put/call ratio** — options traders buying puts vs calls. High ratio = heavy
  bearish positioning = contrarian bullish signal at extremes (and vice versa).
- **VIX** — the "fear gauge": implied volatility of NIFTY options. High VIX =
  expensive hedging = fear; the *concept* here — the actual computation is S4.

The contrarian logic: at extremes, the crowd is usually *fully* positioned, so
there is little buying/selling left to push price further.

### 2) Worked example

Breadth line for three days: advancers minus decliners `+800, −200, +600`. The
cumulative line goes `800 → 600 → 1200`. If the index made new highs each day
while the line flattened, breadth is diverging.

```python
from decimal import Decimal
a_d = [Decimal("800"), Decimal("-200"), Decimal("600")]
line = Decimal("0")
for d in a_d:
    line += d
    print("cumulative breadth:", line)
# 800, 600, 1200
```

### 3) Common pitfalls

> **Pitfall:** reading put/call *levels* without their historical range — a
> ratio of 1.2 is only "extreme" if it is extreme for that market.
> **Pitfall:** treating high VIX as a buy signal by itself. Fear is *context*,
> not a trigger — it needs price structure to mean anything.
> **Pitfall:** ignoring breadth in index trades — an index can grind higher on
> three stocks while the advance/decline line rolls over.

### 4) Key takeaways

- **Takeaway:** breadth = participation; VIX = hedging cost/fear; put/call =
  positioning.
- **Takeaway:** extremes of sentiment are contrarian *context*.
- **Takeaway:** divergence between index and breadth is a warning.

## Lesson 5.5 — Time cycles & seasonality

### 1) Concept

**Time cycles** are the calendar sibling of price patterns: Murphy's work on
cycles found that markets often rotate through *fixed calendar intervals*
(20-day trading cycles, quarterly cycles). **Seasonality** is the cruder cousin:
calendar effects such as the January effect, quarterly index rolls, and the
pre-budget and post-monsoon patterns observed in Indian indices. Cycle analysis
is a **timing overlay**, not a standalone signal — a cycle "due for a turn"
means nothing without price structure confirming it.

### 2) Worked example

A 20-day cycle: mark every 20th trading day from a start date and check how
often a swing high/low falls within ±2 days of the marker. A quick count of
swings near cycle markers:

```python
from decimal import Decimal
from tantra_examples import SampleInstruments, synthetic_bars

bars = synthetic_bars(SampleInstruments.NIFTY50, days=200, seed=7, base_price_paise=24_000)
cycle, tol, hits, checks = 20, 2, 0, 0
for i in range(cycle, len(bars), cycle):
    checks += 1
    window = bars[max(0, i - tol): i + tol + 1]
    if any(b.close == max(x.close for x in window) or b.close == min(x.close for x in window) for b in window):
        hits += 1
print("cycle hits:", hits, "of", checks)
```

### 3) Common pitfalls

> **Pitfall:** trading cycles as a primary signal. They are a *timing overlay*:
> a cycle "turn date" without price confirmation is a coin flip.
> **Pitfall:** curve-fitting cycle lengths — with enough freedom you can find a
> "cycle" in any noise. Fix the length *before* looking at the chart.
> **Pitfall:** confusing calendar seasonality (dates) with trading-day cycles.

### 4) Key takeaways

- **Takeaway:** cycles are calendar intervals that repeat; seasonality is the
  dated cousin.
- **Takeaway:** use cycles to time, price structure to decide.
- **Takeaway:** fix the cycle length first — then test, never the reverse.

## Tantra Lab 5 — Gap classifier

### Lab goal

Count every up/down gap in a synthetic series, then rank gaps by size relative
to ATR to separate significant gaps from noise.

### Code

```python
from decimal import Decimal
from tantra_examples import SampleInstruments, synthetic_bars

bars = synthetic_bars(SampleInstruments.NIFTY50, days=200, seed=7, base_price_paise=24_000)

up_gaps = down_gaps = 0
for a, b in zip(bars, bars[1:]):
    if b.low > a.high: up_gaps += 1
    if b.high < a.low: down_gaps += 1
print("up gaps:", up_gaps, "down gaps:", down_gaps)
```

### Expected output

Two lines of the form `up gaps: U  down gaps: D` where `U` and `D` are small
integers (synthetic bars gap rarely). Extend the loop with an `Atr(14)` (from
M4) and print only gaps with `gap_size / ATR ≥ 1` labelled "significant".

### Hand-in checklist

- [ ] The `up gaps / down gaps` counts in the journal.
- [ ] The ATR extension output: every significant gap with its `gap/ATR` ratio.
- [ ] 20 labelled gaps on a chart, each classified (common/breakaway/runaway/
      exhaustion) with the reason (position in trend + volume).
- [ ] Three journaled gap trades: setup, rule used, outcome.

### Common errors

- **Missing the gap direction edge case** — `b.low > a.high` and `b.high <
  a.low` cannot both be true; no double counting.
- **Using points instead of ATR** — the "significant" test must be
  `gap / ATR ≥ 1`, not `gap ≥ 200`.
- **Forgetting warm-up** — `Atr.update()` returns `None` for the first 14 bars;
  skip gap comparisons until it prints.

## Practice problems

1. Bar A: high 24,000, low 23,900. Bar B: high 24,120, low 24,050. Is there a
   gap? Which kind (up/down), and how big in points?
2. Why is a gap mid-trend called a "measuring gap"? What would it measure for a
   move from 23,000 to 24,500 with a runaway gap at 24,000?
3. Classify: a 150-point gap out of a 12-day range on 3× volume.
4. VIX prints 30 (high) while NIFTY makes new highs and breadth diverges. What
   does the contrarian toolkit say, and what is missing before you act?
5. The cumulative advance/decline line falls while the index rises. What is the
   term, and why is it a warning?
6. A cycle marker falls on day 41. Explain in two sentences how you would use it
   as a timing overlay without making it a standalone signal.
7. Gap-fill: is it a law or a bias? Where is it strongest, and where weakest?
8. An exhaustion gap prints climax volume and the next bar is a shooting star.
   What does the M5 + M2 combo say about the trend?

### Solutions

1. Up-gap: `24,050 > 24,000`, size `= 24,050 − 24,000 = 50` points.
2. The move after the gap often repeats the move before it: 23,000 → 24,000
   (1,000) then 24,000 → 25,000 expected.
3. Breakaway — it exits a range on high volume.
4. High VIX = fear, breadth divergence = weak participation — contrarian
   context says be cautious/look for a turn, but the *price* confirmation
   (break of structure, reversal candle) is still missing before trading.
5. **Breadth divergence** — the index is carried by few stocks; the advance is
   fragile.
6. A cycle date is a *window to watch*: wait for a swing pivot or a candle
   signal near the marker before acting; never trade the date alone.
7. A bias. Strongest for common gaps in ranges; weakest for breakaway gaps that
   begin new trends.
8. The likely top signature: the crowd's last buy was absorbed (climax volume)
   and the shooting star rejected the highs — a reversal watch, short only on
   confirmation.

## Quiz bank

| Question | A | B | C | D | Answer |
|---|---|---|---|---|---|
| An up-gap means | high_t < low_{t−1} | low_t > high_{t−1} | close_t > close_{t−1} | Volume dropped | B |
| A gap out of a range on high volume is | Common | Breakaway | Runaway | Exhaustion | B |
| The measuring gap is another name for | Breakaway | Runaway | Exhaustion | Common | B |
| An exhaustion gap often prints | Climax volume | No volume | Falling volume | Zero volume | A |
| Gap-fill is best described as | A law | A bias | A guarantee | An entry | B |
| The advance/decline line measures | Index level | Breadth | VIX | Put/call | B |
| A high put/call ratio at extremes is contrarian | Bullish | Bearish | Neutral | Noise | A |
| The VIX is often called | The price gauge | The fear gauge | The volume gauge | The trend gauge | B |
| Time cycles are best used as | A standalone signal | A timing overlay | A volume tool | An entry trigger | B |
| Gap size should be measured | In points | In ATRs | In rupees | In ticks | B |

## Glossary

- **Gap** — a price zone with no trades between two consecutive bars.
- **Common gap** — a range-bound gap, usually filled quickly.
- **Breakaway gap** — a high-volume gap leaving a range/pattern.
- **Runaway (measuring) gap** — a mid-trend continuation gap.
- **Exhaustion gap** — a climax-volume gap near a trend's end.
- **Gap edge** — the boundary of the empty zone; becomes S/R.
- **Breadth** — the degree of participation in an index move.
- **Advance/decline line** — cumulative (advancers − decliners).
- **Put/call ratio** — bearish vs bullish options positioning.
- **VIX** — the implied-volatility "fear gauge" (computation in S4).
- **Time cycle** — a repeating calendar interval in price turning points.
- **Seasonality** — calendar-dated market tendencies.

## Reading assignment

- Edwards & Magee, *Technical Analysis of Stock Trends*, ch. 12 (gaps).
- Murphy, *Technical Analysis of the Financial Markets*, ch. 14 (cycles).
- Pring, *Technical Analysis Explained*, ch. 20, 26 (cycles, sentiment).
- IFTA *CFTe Syllabus & Study Guide*, Appendices B (breadth) and C (cycles).
- Platform: read `screening/08_swing_ap_setup_screener.py` to see breakout/gap
  logic encoded in a real screener.
- Full list: [Reading & Resource List](../appendices/reading-list.md).

## Assessment reminder

This module feeds the **gap-classification quiz** and the **journal** — 20
labelled gaps plus 3 gap-trade entries with reasons, graded as part of your
journal. See [Assessment](../front/assessment.md).

## Assessment

- Quiz + gap-classification lab (20 labelled gaps).
- Journal: 3 gap trade entries with reasons.

**Next:** [M6 — Advanced Indicators & Systems](m6-advanced-indicators.md)
