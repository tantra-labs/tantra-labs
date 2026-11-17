# M4 — Technical Indicators: The Math

> **Weeks 23–25 · 24 hrs · PLO-3 · Core reading:** Murphy ch. 7; Pring ch. 12, 16;
> E&M ch. 36; Brown (CFTe II) for RSI range rules; IFTA App B for breadth

> This is the mathematical heart of the technical-analysis track. Every formula
> below is exactly what the Tantra wheel computes, in `Decimal`.

## Learning outcomes

- Derive and compute SMA, EMA (with α), Wilder RSI, MACD, Bollinger Bands, ATR.
- Explain warm-up and why `None` appears until a window fills.
- Use divergences correctly; avoid the classic RSI misuse.
- Choose trend vs oscillator vs volatility tools for the current regime.

## Lesson 4.1 — Simple moving average (SMA)

For a window of `n` closing prices `p_1 … p_n`,

```
SMA_t = (p_t + p_{t-1} + ... + p_{t-n+1}) / n      =  (1/n) Σ p_i
```

- Warm-up: first value at bar `n`; `None` before.
- `previous_value` matters for cross detection (as seen in M1's lab).

### Tantra Lab 4.1 — SMA by hand vs wheel

```python
from decimal import Decimal
from tantra.indicators import SMA

series = [Decimal("100"), Decimal("102"), Decimal("99"), Decimal("105"), Decimal("110")]

manual = sum(series[-3:]) / Decimal(3)
ind = SMA(3)
for p in series:
    v = ind.add(p)
print("manual", manual, "wheel", ind.value())
```

## Lesson 4.2 — Exponential moving average (EMA)

Define smoothing constant `α = 2 / (n + 1)`. Then

```
EMA_t = α · p_t + (1 − α) · EMA_{t−1}
```

with `EMA_0 = p_0` (seed). EMA reacts faster than SMA and never fully forgets
old data. The wheel seeds with the first price (verified in `_legacy.py`).

### Tantra Lab 4.2 — EMA weighting

```python
from decimal import Decimal
from tantra.indicators import EMA

ema = EMA(10)                     # α = 2/11
vals = [Decimal("100") + Decimal(i) for i in range(12)]
for v in vals:
    r = ema.add(v)
print("EMA(10) after 12 bars:", ema.value())

alpha = Decimal(2) / Decimal(11)
print("alpha", alpha)             # ≈ 0.1818
```

## Lesson 4.3 — Relative Strength Index (RSI, Wilder)

For period `n`:

1. Compute per-bar change `Δ = p_t − p_{t−1}`; split into gain `g_t = max(Δ, 0)`
   and loss `l_t = max(−Δ, 0)`.
2. **Initial** averages: `AvgGain = Σ g / n`, `AvgLoss = Σ l / n` over the first
   `n` changes.
3. **Smoothing** (Wilder):

```
AvgGain_t = AvgGain_{t-1} · (n−1)/n  +  g_t / n
AvgLoss_t = AvgLoss_{t-1} · (n−1)/n  +  l_t / n
```

4. `RS = AvgGain / AvgLoss` and

```
RSI = 100 − 100 / (1 + RS) = 100 · AvgGain / (AvgGain + AvgLoss)
```

- `AvgLoss = 0` → RSI = 100 (limit case, handled in the wheel).
- RSI is a **normalized momentum oscillator** bounded to [0, 100].
- CFTe II note (Brown): in strong uptrends RSI tends to travel 40–80; in
  downtrends 20–70. Read the range, not just 30/70.

### Tantra Lab 4.3 — RSI by formula

```python
from decimal import Decimal
from tantra.indicators import RSI

rsi = RSI(14)
prices = [Decimal("100")] + [Decimal("100") + Decimal(i % 5) - Decimal(i % 3) for i in range(1, 40)]
for p in prices:
    rsi.add(p)
print("RSI(14):", rsi.value())
```

**Task:** reproduce RSI by hand for the first 16 prices using Wilder's initial
average then the smoothing step; compare to the wheel.

## Lesson 4.4 — MACD (Moving Average Convergence Divergence)

```
MACD line  = EMA_fast − EMA_slow        (defaults 12, 26)
Signal line = EMA_signal(MACD line)     (default 9)
Histogram   = MACD line − Signal line
```

- Cross of MACD through signal = classic signal; histogram grows/shrinks as
  momentum accelerates/decelerates.
- Divergence: price makes a new high, MACD does not → weakening momentum.

### Tantra Lab 4.4 — MACD value object

```python
from decimal import Decimal
from tantra.indicators import Macd

macd = Macd(fast=12, slow=26, signal=9)
prices = [Decimal("100") + Decimal(i * i) for i in range(60)]
last = None
for p in prices:
    last = macd.update(p)
print(last)   # MacdValue(macd=…, signal=…, histogram=…)
```

## Lesson 4.5 — Bollinger Bands

For window `n` and multiplier `k`:

```
Middle = SMA_n
Std    = population σ of the window   σ = sqrt( Σ(p_i − SMA)^2 / n )
Upper  = Middle + k·σ
Lower  = Middle − k·σ
```

- Bands are **volatility-adaptive**; they widen when σ rises.
- `%B = (Price − Lower) / (Upper − Lower)` normalizes position within the bands.
- Bandwidth `= (Upper − Lower) / Middle` measures volatility regime.

### Tantra Lab 4.5 — Bollinger from the wheel

```python
from decimal import Decimal
from tantra.indicators import Bollinger

bb = Bollinger(period=20, mult=Decimal("2"))
prices = [Decimal("100") + Decimal(i % 7) for i in range(30)]
last = None
for p in prices:
    last = bb.update(p)
print(last)   # BollingerValue(upper, middle, lower)
```

**Task:** add a 30-bar synthetic series, compute bands, and mark the %B for the
final bar; explain whether the price is "at" or "beyond" a band and why that
alone is *not* a sell signal (bands drift with trends).

## Lesson 4.6 — Average True Range (ATR)

True Range captures the full intra-bar range, gapping included:

```
TR_t = max( H_t − L_t ,  |H_t − C_{t−1}| ,  |L_t − C_{t−1}| )
ATR = Wilder-smoothing of TR   (same (n−1)/n recursion as RSI)
```

- ATR is a **volatility measure in price units** — used for stops, position
  sizing, and filter distances (comes back in S4-M7 risk).

### Tantra Lab 4.6 — ATR needs high/low/close

```python
from decimal import Decimal
from tantra.indicators import Atr
from tantra_examples import SampleInstruments, synthetic_bars

atr = Atr(period=14)
bars = synthetic_bars(SampleInstruments.NIFTY50, days=60, seed=7, base_price_paise=24_000)
last = None
for b in bars:
    last = atr.update(b.high, b.low, b.close)
print("ATR(14):", last)
```

## Lesson 4.7 — Choosing tools by regime

| Regime | Tool family | Examples |
|---|---|---|
| Trending | Trend following | SMA/EMA cross, MACD, ADX (M6) |
| Ranging | Oscillators, mean-reversion | RSI, Stochastics (M6), %B |
| High volatility | Volatility bands/stops | Bollinger, ATR, Keltner (M6) |
| Any | Momentum confirmation | ROC, MFI (M6) |

## Module assessment

- Indicator lab: 10 live setups, each with the **formula**, the wheel output,
  and the trade logic (entry/stop/target).
- Written derivation quiz: compute SMA/EMA/RSI/MACD/Bollinger/ATR from a 15-bar
  hand-solved series.

**Next:** [M5 — Gaps, Sentiment & Time Cycles](m5-gaps-sentiment-cycles.md)
