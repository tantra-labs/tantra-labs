# M5 — Gaps, Sentiment & Time Cycles

> **Weeks 25–26 · 16 hrs · PLO-3 · Core reading:** Edwards & Magee ch. 12; Murphy ch. 14; Pring ch. 20, 26; IFTA App B, C

## Learning outcomes

- Classify common, breakaway, runaway, and exhaustion gaps.
- Explain why each gap type has a different implication.
- Read sentiment indicators (put/call, VIX intuition, breadth).
- Use the concept of time cycles and seasonality.

## Lesson 5.1 — Gap mechanics

A gap is a price range with **no trades**: `low_t > high_{t−1}` (up gap) or
`high_t < low_{t−1}` (down gap).

## Lesson 5.2 — Four gap types

| Type | Where it appears | Implication |
|---|---|---|
| **Common** | Trading range, thin volume | Usually filled quickly; noise |
| **Breakaway** | Out of a range/pattern, high volume | Start of a new move; trend confirmation |
| **Runaway** (measuring) | Middle of a strong trend | Trend continuation; "measuring gap" |
| **Exhaustion** | End of a trend, high volume | Possible final thrust; reversal risk |

Volume is the differentiator: breakaway/runaway gaps are usually high-volume,
exhaustion gaps often show climax volume.

## Lesson 5.3 — Gap-based trading rules

- Breakaway gap + close above = trade with the gap (continuation).
- Exhaustion gap + reversal candle (M2!) = watch for reversal.
- **Filling the gap** is not mandatory; it is a bias, not a law.

## Lesson 5.4 — Sentiment indicators

- Breadth: advance/decline, new highs/lows (IFTA App B).
- Put/call ratio; VIX as the "fear gauge" (concept — actual computation in S4).
- Contrarian logic: extremes of sentiment are often near turns.

## Lesson 5.5 — Time cycles & seasonality

- Murphy's time-cycle work: fixed calendar intervals, 20-day trading cycles.
- Seasonal patterns: monthly/quarterly effects, calendar effects in indices.
- Cycle analysis as **timing overlay**, not a standalone signal.

## Tantra Lab 5 — Gap classifier

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

**Task:** extend the classifier to label gaps by size relative to ATR (from M4):
`gap_size / ATR` ≥ 1 is "significant". Mark the largest gaps on a chart, classify
each by position in the trend, and log the result in the journal. Read
`screening/08_swing_ap_setup_screener.py` to see how a real screener encodes
breakout/gap logic.

## Assessment

- Quiz + gap-classification lab (20 labelled gaps).
- Journal: 3 gap trade entries with reasons.

**Next:** [M6 — Advanced Indicators & Systems](m6-advanced-indicators.md)
