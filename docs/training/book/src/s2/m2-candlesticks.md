# M2 — Candlestick Analysis

> **Weeks 19–21 · 24 hrs · PLO-3 · Core reading:** Nison, *Candlestick Charting Techniques*, ch. 1–9

## Learning outcomes

- Construct a candlestick from OHLC data.
- Recognize single-, double-, and multi-bar reversal patterns.
- Distinguish reversal from continuation patterns; know when context matters.
- Use candlesticks with trend context and volume.

## Lesson 2.1 — Candlestick construction

- Body = |close − open|; real body vs shadows.
- Bullish (close > open) vs bearish (close < open).
- Range components: `upper_shadow = high − max(open, close)`,
  `lower_shadow = min(open, close) − low`.

## Lesson 2.2 — Single-bar patterns

- **Doji** (open ≈ close): indecision — especially at extremes.
- **Hammer / Hanging man**: small body, long lower shadow, in downtrend vs uptrend.
- **Shooting star / Inverted hammer**: long upper shadow.
- The pattern's *meaning depends on where it appears*.

## Lesson 2.3 — Two-bar and multi-bar patterns

- **Engulfing** (bullish/bearish); **harami** (inside bar).
- **Piercing line** and **dark cloud cover**.
- **Stars:** morning star, evening star (3 bars).
- **Continuation patterns:** rising/falling three methods, gaps in context (M5).

## Lesson 2.4 — The "magic doji" & context rules

- Doji after a strong trend = possible exhaustion.
- A doji alone proves nothing: trend context + volume + nearby support/resistance.
- Nison's rule: candlesticks signal *where*, other tools confirm *when*.

## Lesson 2.5 — Japanese charts beyond candles

- Preview of renko, kagi, three-line-break (needed for CFTe II; detailed in S5-TA).

## Tantra Lab 2 — Classify every bar of a series

```python
from decimal import Decimal
from tantra_examples import SampleInstruments, synthetic_bars

bars = synthetic_bars(SampleInstruments.NIFTY50, days=120, seed=7, base_price_paise=24_000)

def body(b): return b.close - b.open
def upper_wick(b): return b.high - max(b.open, b.close)
def lower_wick(b): return min(b.open, b.close) - b.low

def classify(b):
    if body(b) == Decimal(0): return "doji"
    if upper_wick(b) >= 2 * abs(body(b)) and lower_wick(b) <= abs(body(b)) // 2:
        return "shooting_star" if body(b) < 0 else "inverted_hammer"
    if lower_wick(b) >= 2 * abs(body(b)) and upper_wick(b) <= abs(body(b)) // 2:
        return "hammer" if body(b) > 0 else "hanging_man"
    return "bullish" if body(b) > 0 else "bearish"

for b in bars[:10]:
    print(b.ts.date(), classify(b))
```

**Task:** extend the classifier to detect two-bar bullish/bearish engulfing
(compare `body[i]` vs `body[i-1]` with opposite signs and larger range). Then do
the **100-pattern timed drill** and add 10 annotated chart screenshots with
context notes to your journal.

## Assessment

- 100-pattern timed recognition drill.
- Pattern journal (10 patterns × chart + reason).

**Next:** [M3 — Chart Patterns & Reversals](m3-chart-patterns.md)
