# M1 — Dow Theory, Trends & Chart Construction

> **Weeks 17–19 · 24 hrs · PLO-3 · Core readings:** Edwards & Magee ch. 3–5, 13–14;
> Murphy ch. 2, 4, 7; Pring ch. 18

## Learning outcomes

- State the Dow Theory tenets and its defects.
- Define primary/secondary/minor trends and mark them on a chart.
- Draw valid trendlines and channels; identify support and resistance.
- Construct line, bar, and candlestick charts; interpret volume & open interest.

## Lesson 1.1 — The Dow Theory

Tenets (per Edwards & Magee / Murphy):

1. The averages discount everything.
2. The market has three trends: **primary** (major), **secondary** (reaction),
   **minor** (daily).
3. Primary trends have three phases: accumulation, public participation, distribution.
4. Indices must **confirm** each other (Dow's original — industrials & rails).
5. Volume must confirm the trend.
6. A trend is assumed intact until it gives definite reversal signals.

Defects: confirmation lag, ambiguous signals, no precise price targets.

## Lesson 1.2 — Trends and trendlines

- **Uptrend:** higher highs, higher lows. **Downtrend:** lower highs, lower lows.
- A trendline joins two or more reaction lows (up) or highs (down); the more
  touches, the stronger.
- **Channel:** two parallel lines (trendline + return line).
- Touching a trendline ≠ automatic entry: wait for confirmation (close beyond).

## Lesson 1.3 — Support and resistance

- **Support:** a price level where buying has repeatedly overcome selling.
- **Resistance:** a price level where selling has repeatedly overcome buying.
- Roles *swap*: broken resistance becomes support (and vice versa).
- Round numbers and prior pivots attract orders.

## Lesson 1.4 — Chart construction

- Line chart = closes; bar chart = O-H-L-C; candlestick = body + wicks.
- **Candlestick anatomy:** open, high, low, close; bullish vs bearish body;
  upper/lower shadow; session range `H - L`.
- Volume as the companion series; open interest for futures (S4-M5).

## Lesson 1.5 — Timeframes & swing structure

- Higher timeframes define the trade direction; lower timeframes refine entry.
- Swings (pivot highs/lows) as the building blocks of structure.

## Tantra Lab 1 — Trend detection with SMA structure

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

This is `tantra-examples/examples/02_indicators.py` in spirit: the SMA cross is
the most mechanical trend rule. **Task:** mark on a printed chart the primary
uptrend/downtrend, draw trendlines, and label the support/resistance zones.
Compare your hand-drawn zones with the SMA-cross signals — where do they agree?

## Assessment

- Chart-lab practical: 30 annotated charts (trends, trendlines, S/R).
- Quiz: Dow Theory tenets and defects.

**Next:** [M2 — Candlestick Analysis](m2-candlesticks.md)
