# M8 — Introduction to Technical Analysis

> **Weeks 14–15 · 16 hrs · PLO-3 (introduction)**

## Learning outcomes

- Contrast fundamental and technical analysis.
- State the core philosophy of TA: *price discounts everything*.
- Read a basic line/bar/candlestick chart.
- Explain why TA works: crowd psychology and self-reinforcing expectations.

## Lesson 8.1 — Fundamental vs technical

- Fundamental: what is a company *worth* (Semester 3).
- Technical: what is the market *paying* and what does price action say
  (Semester 2).
- Both matter — the CFTe curriculum and NISM XV both demand both.

## Lesson 8.2 — The three TA premises (Murphy)

1. Price discounts everything.
2. Price moves in trends.
3. History repeats (crowd psychology).

## Lesson 8.3 — First look at chart types

- Line (close), bar (OHLC), candlestick (OHLC with bodies/wicks).
- Timeframes: 1m/5m/15m/1d/1w/1M; which suits which horizon.

## Lesson 8.4 — What TA is *not*

- Not a crystal ball; probabilities and risk management.
- The difference between a signal and a setup (execution + risk are S2/S4 topics).

## Tantra Lab 8 — First chart series

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

## Assessment

- Quiz: TA premises and chart types.
- 1-page "why trends persist" essay.

**Next:** [M9 — Professional Skills & Markets Lab](m9-professional-skills.md)
