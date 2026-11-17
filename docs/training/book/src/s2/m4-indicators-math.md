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

## Prerequisites

- [M1 — Dow Theory & Trends](m1-dow-theory.md): the SMA formula and the golden
  cross — this module generalises them.
- [M2 — Candlesticks](m2-candlesticks.md): bar anatomy (`high`, `low`, `close`)
  — ATR and RSI read those exact fields.
- Basic algebra: summation `Σ`, absolute value, square root (`Decimal.sqrt()`).
- The `tantra.indicators` import surface from the cheat sheet — SMA/EMA/RSI use
  the legacy `.add()` API; Macd/Bollinger/Atr use the `.update()` API.

## Lesson 4.1 — Simple moving average (SMA)

### 1) Concept

The **simple moving average** is the arithmetic mean of the last `n` prices. It
smooths away single-bar noise so you can see the trend. Each new bar shifts the
window: the oldest price falls out, the newest joins in. For a window of `n`
closing prices `p_1 … p_n`,

```
SMA_t = (p_t + p_{t-1} + ... + p_{t-n+1}) / n      =  (1/n) Σ p_i
```

Two properties you must internalise:

- **Warm-up:** until `n` prices have been seen, no SMA exists — the wheel
  returns `None`. That is *not* a bug; it is the definition.
- **Equal weights:** every bar in the window weighs `1/n`. That is SMA's flaw:
  the most recent bar is no more important than the bar from `n−1` days ago.
  The EMA (Lesson 4.2) fixes exactly that.

### 2) Worked example

Closes 100, 102, 99, 105, 110 with `n = 3`:

```
SMA_3 = (p_3 + p_2 + p_1) / 3 = (99 + 105 + 110) / 3 = 314 / 3 = 104.666...
```

```python
from decimal import Decimal
series = [Decimal("100"), Decimal("102"), Decimal("99"), Decimal("105"), Decimal("110")]

manual = sum(series[-3:]) / Decimal(3)
ind = SMA(3)
for p in series:
    v = ind.add(p)
print("manual", manual, "wheel", ind.value())
# manual 104.6666666666666666666666667  wheel 104.6666666666666666666666667
```

### 3) Common pitfalls

> **Pitfall:** reading the SMA before warm-up — the first `n−1` calls return
> `None`; any math on `None` crashes. Always guard with `is not None`.
> **Pitfall:** using `sum()` on `float` closes. The wheel's bars are `Decimal`;
> keep them `Decimal` end to end.
> **Pitfall:** believing a rising SMA predicts price. It *describes* the past;
> the crossover (M1's golden cross) is the trading rule, the line itself is a
> report.

### 4) Key takeaways

- **Takeaway:** `SMA_t = (1/n) Σ p_i` — arithmetic mean of the last `n` bars.
- **Takeaway:** warm-up: first value appears at bar `n`, `None` before.
- **Takeaway:** equal weights are SMA's simplicity *and* its weakness.

### Tantra Lab 4.1 — SMA by hand vs wheel

#### Lab goal

Prove that your hand-computed SMA and the wheel's `SMA(3)` agree to the last
decimal.

#### Code

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

#### Expected output

`manual 104.6666666666666666666666667  wheel 104.6666666666666666666666667` —
two identical values. The wheel used the *same* `(1/n)Σp` formula over the last
three closes.

#### Hand-in checklist

- [ ] Both printed values (must match exactly).
- [ ] `ind.previous_value` recorded for the bar before — and a sentence on why
      the cross detector in M1 needs it.
- [ ] The first two `.add()` returns: `None, None` for `SMA(3)` — confirmed in
      the journal.

#### Common errors

- **Using integer division** `//` for the mean — `Decimal` division `/` is
  exact; `//` truncates.
- **Slicing the wrong window** — `series[-3:]` is the last three; `series[:3]`
  is the first three.
- **Recreating the SMA per bar** — the wheel keeps state; re-adding the same
  prices to a fresh `SMA` restarts warm-up.

## Lesson 4.2 — Exponential moving average (EMA)

### 1) Concept

The **EMA** fixes SMA's equal-weights flaw by making recent prices count more.
Define the smoothing constant

```
α = 2 / (n + 1)
```

and the recursion

```
EMA_t = α · p_t + (1 − α) · EMA_{t−1}        with  EMA_0 = p_0 (seed)
```

Each new bar contributes `α` of itself and keeps `(1 − α)` of everything that
came before. Unroll the recursion to see the weighting:

```
EMA_t = α·p_t + α(1−α)·p_{t−1} + α(1−α)²·p_{t−2} + ...  + (1−α)^t·p_0
```

The weights `α, α(1−α), α(1−α)², …` fall geometrically — a price from `k` bars
ago weighs `(1−α)^k` times today's price. The EMA *never fully forgets*; the
seed `p_0` echoes forever, but its influence decays to nothing. The wheel seeds
with the first price (verified in `_legacy.py`).

### 2) Worked example

For `n = 10`, `α = 2/11 ≈ 0.1818`. Prices 100, 101, 102, …, 111:

```
EMA_0 = 100                       (seed)
EMA_1 = (2/11)·101 + (9/11)·100  = 18.36 + 81.82 ≈ 100.18
EMA_2 = (2/11)·102 + (9/11)·100.18 ≈ 100.51
```

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

### 3) Common pitfalls

> **Pitfall:** using α = 1/n. The standard EMA constant is `α = 2/(n+1)` —
> two different traditions exist, and the wheel follows `2/(n+1)`.
> **Pitfall:** forgetting the seed. `EMA_0 = p_0` is a *choice*; the first
> EMA output equals the first price, not the mean.
> **Pitfall:** expecting the EMA to "settle" after `n` bars. It converges
> gradually; `None` appears only for the very first bar.

### 4) Key takeaways

- **Takeaway:** `α = 2/(n+1)`; `EMA_t = α·p_t + (1−α)·EMA_{t−1}`; seed = first
  price.
- **Takeaway:** weights decay geometrically — recent bars dominate.
- **Takeaway:** EMA responds faster than SMA of the same `n`.

### Tantra Lab 4.2 — EMA weighting

#### Lab goal

Show the α constant for `EMA(10)` and confirm the wheel's EMA after 12 bars is
weighted toward the newest prices.

#### Code

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

#### Expected output

`alpha 0.1818181818181818181818181818`, and `EMA(10) after 12 bars: …` — a value
*above* the seed (≈ 108–109 for this rising series) because the newest bars,
which are the highest, carry the largest weights.

#### Hand-in checklist

- [ ] The two printed lines in the journal.
- [ ] A sentence: what EMA value would you get if weights were equal (SMA
      answer for comparison)?
- [ ] The weight of the price from 5 bars ago: `(9/11)**5` computed in `Decimal`
      and stated as a fraction of today's weight.

#### Common errors

- **Hard-coding α instead of deriving it** — always `Decimal(2) / Decimal(n+1)`.
- **Confusing seed and warm-up** — EMA(10) prints a value from bar 1 (the
  seed); SMA(10) prints `None` until bar 10.
- **Using `float(2/11)`** — the wheel stores `Decimal`; compute in `Decimal`.

## Lesson 4.3 — Relative Strength Index (RSI, Wilder)

### 1) Concept

The **RSI** measures the *internal strength* of recent moves: how much of the
recent price action was up-moves versus down-moves, normalised to a 0–100 scale.
J. Welles Wilder's recipe, for period `n`:

1. Per-bar change `Δ = p_t − p_{t−1}`; split into gain `g_t = max(Δ, 0)` and
   loss `l_t = max(−Δ, 0)`.
2. **Initial averages** over the first `n` changes:
   `AvgGain = (Σ g)/n`, `AvgLoss = (Σ l)/n`.
3. **Smoothing** from then on (this is the famous Wilder recursion):

```
AvgGain_t = AvgGain_{t-1} · (n−1)/n  +  g_t / n
AvgLoss_t = AvgLoss_{t-1} · (n−1)/n  +  l_t / n
```

4. `RS = AvgGain / AvgLoss` and

```
RSI = 100 − 100 / (1 + RS) = 100 · AvgGain / (AvgGain + AvgLoss)
```

The second form shows the limit case cleanly: when `AvgLoss = 0`, the fraction
is `AvgGain / AvgGain = 1`, so `RSI = 100`. (The wheel handles division by zero
explicitly.) RSI is a **normalized momentum oscillator**: price falling is not
needed for a low RSI — only *losses dominating gains*.

### 2) Worked example

Hand-solve `n = 3` on prices 100, 101, 102, 101, 103, 100. Changes: `+1, +1,
−1, +2, −3`, so gains `1, 1, 0, 2, 0` and losses `0, 0, 1, 0, 3`.

```
Initial (first 3 changes):
  AvgGain = (1 + 1 + 0) / 3 = 2/3 ≈ 0.6667
  AvgLoss = (0 + 0 + 1) / 3 = 1/3 ≈ 0.3333
  RS = (2/3)/(1/3) = 2   →   RSI = 100 − 100/3 = 66.67

Next change Δ = +2 (gain 2, loss 0):
  AvgGain = (2/3)·(2/3) + 2/3 = 4/9 + 6/9 = 10/9 ≈ 1.1111
  AvgLoss = (1/3)·(2/3) + 0   = 2/9 ≈ 0.2222
  RS = 5   →   RSI = 100 − 100/6 = 83.33
```

```python
from decimal import Decimal
from tantra.indicators import RSI

rsi = RSI(14)
prices = [Decimal("100")] + [Decimal("100") + Decimal(i % 5) - Decimal(i % 3) for i in range(1, 40)]
for p in prices:
    rsi.add(p)
print("RSI(14):", rsi.value())
```

**CFTe II note (Brown):** in strong uptrends RSI tends to travel in the 40–80
band; in downtrends in the 20–70 band. Read the *range shift*, not just the
30/70 thresholds — an RSI that refuses to fall below 40 is telling you the bulls
are still in charge.

### 3) Common pitfalls

> **Pitfall:** trading 30/70 mechanically. RSI can sit above 70 for weeks in a
> strong trend — the *range* (40–80 vs 20–70) matters more (Brown).
> **Pitfall:** forgetting warm-up: `n` changes are needed before the first
> average, so the first `n` prices return `None`.
> **Pitfall:** calling RSI "oversold" at 30 and buying. RSI is momentum, not
> price; 30 means *recent losses dominate*, which can persist.

### 4) Key takeaways

- **Takeaway:** RSI = `100 − 100/(1+RS)` with Wilder `(n−1)/n` smoothing.
- **Takeaway:** loss = 0 ⇒ RSI = 100 (limit case handled by the wheel).
- **Takeaway:** read the RSI *range* for the trend, then the 30/70 zones.

### Tantra Lab 4.3 — RSI by formula

#### Lab goal

Reproduce Wilder's RSI by hand for the first 16 prices and confirm the wheel's
`RSI(14)` matches the recursion.

#### Code

```python
from decimal import Decimal
from tantra.indicators import RSI

rsi = RSI(14)
prices = [Decimal("100")] + [Decimal("100") + Decimal(i % 5) - Decimal(i % 3) for i in range(1, 40)]
for p in prices:
    rsi.add(p)
print("RSI(14):", rsi.value())
```

#### Expected output

A single value between 0 and 100, e.g. `RSI(14): 55.3…`. Hand-check: compute
the 14 first changes, average the gains and losses, then apply one smoothing
step and compare to the wheel's value at bar 16.

#### Hand-in checklist

- [ ] The wheel's `RSI(14)` value.
- [ ] The hand-computed initial `AvgGain`, `AvgLoss`, and RSI after 15 bars.
- [ ] One smoothing step performed on paper and compared to the wheel.

#### Common errors

- **Counting the seed price as a "change"** — RSI needs *differences*; with 16
  prices there are 15 changes, of which the first 14 seed the averages.
- **Using `max(Δ, 0)` where Δ is `Decimal`** — fine; do not convert to `float`
  to use Python's `max` with negatives.
- **Expecting RSI to reach exactly 100/0** — those are limit cases, not normal
  outputs.

## Lesson 4.4 — MACD (Moving Average Convergence Divergence)

### 1) Concept

**MACD** is a *trend-following momentum* tool built from two EMAs. The "fast"
EMA tracks price closely; the "slow" EMA lags. Their gap is the MACD line:

```
MACD line   = EMA_fast − EMA_slow        (defaults 12, 26)
Signal line = EMA_signal(MACD line)      (default 9)
Histogram   = MACD line − Signal line
```

The MACD line crosses zero when the fast EMA crosses the slow EMA — a trend
change. The signal line is a *third* EMA (of the MACD line, period 9). When the
MACD line crosses above the signal line the histogram turns positive and grows
while momentum accelerates; it shrinks as momentum fades. **Divergence** is the
key advanced use: price makes a new high but the MACD line does not — momentum
is not confirming price, a warning of a possible turn.

### 2) Worked example

Fast EMA 12 = 24,120; slow EMA 26 = 24,116.6; signal EMA 9 of the MACD line =
2.80:

```
MACD     = 24,120.0 − 24,116.6 = 3.40
Histogram = 3.40 − 3.00 = 0.40   (signal lags, so histogram > 0 after a cross)
```

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

`last` is a **`MacdValue`** with exactly three fields: `macd`, `signal`,
`histogram` — and it is `None` until the slow EMA's warm-up clears (bar 26+).
The histogram tells you *acceleration*: growing → momentum building; shrinking →
momentum fading even if price still moves.

### 3) Common pitfalls

> **Pitfall:** waiting for MACD to cross *zero* before acting. The classic
> signal is the MACD-vs-signal cross, which fires earlier.
> **Pitfall:** reading the histogram's sign as a trend. The histogram measures
> *acceleration*; a shrinking positive histogram means momentum is dying, not
> that price has reversed.
> **Pitfall:** drawing divergences on the histogram instead of the MACD line.
> The classic divergence is price vs the MACD *line*.

### 4) Key takeaways

- **Takeaway:** MACD = EMA12 − EMA26; Signal = EMA9(MACD); Histogram =
  MACD − Signal.
- **Takeaway:** the wheel returns `MacdValue(macd, signal, histogram)`.
- **Takeaway:** divergence (price new high, MACD not) = momentum not confirming.

### Tantra Lab 4.4 — MACD value object

#### Lab goal

Confirm that `Macd.update(price)` returns a `MacdValue` (or `None` during warm-up)
and that the three fields behave as the formulas say.

#### Code

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

#### Expected output

A line such as `MacdValue(macd=…, signal=…, histogram=…)` with three `Decimal`
fields, plus `None` for the first ≈ 34 bars (`26` bars for the slow EMA plus `9`
for the signal EMA). The `macd` field equals `EMA12 − EMA26` on the final bar.

#### Hand-in checklist

- [ ] The printed `MacdValue` recorded.
- [ ] A check: `histogram == macd − signal` on the final bar.
- [ ] The bar index where output first became non-`None`, with an explanation.

#### Common errors

- **Forgetting the double warm-up** — the signal line itself is an EMA(9) of a
  series that starts at bar 26.
- **Accessing `.histogram` on a `None`** — guard `last is not None` first.
- **Confusing `MacdValue` field names** — they are `macd`, `signal`,
  `histogram`; the same trio as the formulas.

## Lesson 4.5 — Bollinger Bands

### 1) Concept

**Bollinger Bands** wrap an SMA with a volatility envelope. The band width
*adapts*: when volatility rises the bands widen, when it calms they contract.
For window `n` and multiplier `k` (John Bollinger's default `20, 2`):

```
Middle = SMA_n
Std    = population σ of the window:   σ = sqrt( Σ (p_i − SMA)² / n )
Upper  = Middle + k·σ
Lower  = Middle − k·σ
```

Two derived measures complete the toolkit:

- **%B** normalises price inside the bands: `%B = (Price − Lower) / (Upper −
  Lower)` — 0 at the lower band, 1 at the upper band, negative/above-1 when
  price runs beyond.
- **Bandwidth** measures the volatility regime: `Bandwidth = (Upper − Lower) /
  Middle`.

### 2) Worked example

Prices 100, 102, 99, 105, 110, `n = 5`, `k = 2`:

```
Middle = 103.2
σ² = [(100−103.2)² + (102−103.2)² + (99−103.2)² + (105−103.2)² + (110−103.2)²] / 5
   = [10.24 + 1.44 + 17.64 + 3.24 + 46.24] / 5 = 78.8 / 5 = 15.76
σ = √15.76 ≈ 3.9699
Upper = 103.2 + 2(3.9699) ≈ 111.14     Lower = 103.2 − 2(3.9699) ≈ 95.26
```

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

The wheel returns a **`BollingerValue(upper, middle, lower)`**, `None` until bar
20. Price touching or exceeding a band is *not* a signal by itself — bands drift
inside trends and prices can ride the upper band for weeks.

### 3) Common pitfalls

> **Pitfall:** using sample σ (`/ (n−1)`) — Bollinger's formula uses the
> *population* σ (`/ n`).
> **Pitfall:** trading every upper-band touch as a sell. In a strong uptrend
> price lives above the upper band; bands are volatility *shells*, not reversal
> triggers.
> **Pitfall:** forgetting warm-up — `None` for the first `n−1` bars.

### 4) Key takeaways

- **Takeaway:** `Middle ± k·σ`, with population σ over the window.
- **Takeaway:** `%B` and `Bandwidth` turn the bands into numbers you can screen.
- **Takeaway:** bands adapt to volatility; touches are context, not signals.

### Tantra Lab 4.5 — Bollinger from the wheel

#### Lab goal

Compute the bands on a 30-bar series and explain where the final bar sits (its
%B) and why that alone is not a trade.

#### Code

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

#### Expected output

`BollingerValue(upper=…, middle=…, lower=…)` with `upper = middle + 2σ` and
`lower = middle − 2σ` exactly. Before bar 20 the output is `None`.

#### Hand-in checklist

- [ ] The `BollingerValue` fields recorded.
- [ ] `%B` computed for the final bar by hand from `(p − lower)/(upper − lower)`.
- [ ] A one-paragraph note: is the final price at/beyond a band, and why is that
      *not* a sell signal here?

#### Common errors

- **Mixing population and sample σ** — the wheel uses population σ (`/n`).
- **Using `mult` as an int** — `mult=2` works but `Decimal("2")` matches the
  wheel's type; keep `Decimal`.
- **Reading `last.lower` before warm-up** — `None` until bar 20.

## Lesson 4.6 — Average True Range (ATR)

### 1) Concept

The **True Range** measures a bar's *full* volatility, including gaps between
sessions. A bar whose close is far from the prior close has a wide TR even if
its own high-low range is small:

```
TR_t = max( H_t − L_t ,  |H_t − C_{t−1}| ,  |L_t − C_{t−1}| )
```

The **ATR** is the Wilder-smoothing of TR — the same `(n−1)/n` recursion RSI
uses:

```
ATR_t = ATR_{t-1} · (n−1)/n + TR_t / n        (initial: mean of first n TRs)
```

ATR is a *volatility measure in price units*. If ATR(14) = 320 on NIFTY, the
"typical" 14-day move is about 320 points. That number becomes your stop
distance, your position-size input (S4-M7), and your filter distance.

### 2) Worked example

Bar 1: high 100, low 96, prior close 97:

```
TR = max(100 − 96, |100 − 97|, |96 − 97|) = max(4, 3, 1) = 4
```

Bar 2 gaps: prior close 100, high 105, low 101:

```
TR = max(105 − 101, |105 − 100|, |101 − 100|) = max(4, 5, 1) = 5   ← the gap wins
```

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

`Atr.update(high, low, close)` takes three arguments — it cannot be fed a single
price, because TR needs the session range *and* the prior close.

### 3) Common pitfalls

> **Pitfall:** computing TR as `high − low` only. Gaps blow through that: TR's
> second and third terms exist precisely for gap days.
> **Pitfall:** forgetting the *prior close* on the first bar — the wheel uses
> the first TR as the seed average.
> **Pitfall:** reading ATR as direction. It is pure volatility: 320 points up or
> down are the same ATR.

### 4) Key takeaways

- **Takeaway:** `TR = max(H−L, |H−C_prev|, |L−C_prev|)`; ATR = Wilder(TR).
- **Takeaway:** `Atr.update(high, low, close)` — three arguments, never one.
- **Takeaway:** ATR is volatility in price units — the raw material of stops and
  sizing.

### Tantra Lab 4.6 — ATR needs high/low/close

#### Lab goal

Compute ATR(14) on real synthetic NIFTY bars and confirm it tracks the series'
typical daily range (gaps included).

#### Code

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

#### Expected output

`ATR(14): <Decimal>` — a value comparable to the average of
`high − low` over the series, but *larger* whenever gaps exist, because TR
absorbs gap ranges too.

#### Hand-in checklist

- [ ] The printed ATR(14) value.
- [ ] A manual TR computation for one bar with a gap, showing which of the three
      terms dominated.
- [ ] A sentence: if you set a stop at 1.5 × ATR below entry, what is it in
      points for this series?

#### Common errors

- **Passing `b.close` only** — `update()` needs `high, low, close`; the value
      object shape is `Decimal` for all three.
- **Feeding `float` high/low/close** — the synthetic bars are `Decimal`.
- **Expecting output from bar 1** — first value appears after the first 14 TRs.

## Lesson 4.7 — Choosing tools by regime

### 1) Concept

No indicator works everywhere. The professional habit is to *classify the
regime first*, then pick the tool family:

| Regime | Tool family | Examples |
|---|---|---|
| Trending | Trend following | SMA/EMA cross, MACD, ADX (M6) |
| Ranging | Oscillators, mean-reversion | RSI, Stochastics (M6), %B |
| High volatility | Volatility bands/stops | Bollinger, ATR, Keltner (M6) |
| Any | Momentum confirmation | ROC, MFI (M6) |

### 2) Worked example

A quick regime check: compare the fraction of bars where price closed above its
20-SMA. Above ≈ 70% of the time → trending (use MACD); hovering near 50% →
ranging (use RSI):

```python
from decimal import Decimal
from tantra.indicators import SMA
from tantra_examples import SampleInstruments, synthetic_bars

bars = synthetic_bars(SampleInstruments.NIFTY50, days=250, seed=7, base_price_paise=24_000)
sma = SMA(20); above = total = 0
for b in bars:
    v = sma.add(b.close)
    if v is not None:
        total += 1
        if b.close > v: above += 1
print("above-SMA fraction:", Decimal(above) / Decimal(total))
```

### 3) Common pitfalls

> **Pitfall:** running RSI mean-reversion signals inside a strong trend — the
> classic "buy every dip into the abyss".
> **Pitfall:** measuring trend with a single bar's cross. Use the *fraction
> above SMA* or ADX (M6) instead of one candle.
> **Pitfall:** ignoring the regime when sizing — volatility (ATR) should widen
> stops, not fake precision.

### 4) Key takeaways

- **Takeaway:** regime first, indicator second — trend, range, or volatility.
- **Takeaway:** trend tools in trends, oscillators in ranges, bands in both.
- **Takeaway:** the fraction-above-SMA check is a 5-line regime classifier.

## Practice problems

1. SMA(4) of closes 101, 103, 99, 105, 108 — write the formula and compute the
   last value. At which bar does the first value appear?
2. For an EMA(4), write α as a fraction and a decimal. Starting from seed 100
   with prices 100, 101, 102, 103, compute the first two EMA outputs to two
   decimals.
3. Wilder RSI, `n = 3`, prices 50, 51, 52, 50, 53, 51. Hand-compute the initial
   AvgGain/AvgLoss, RS, and RSI after 4 prices, then one smoothing step.
4. MACD histogram: MACD line 6.2, signal 5.6. What is the histogram and what
   does its sign tell you about the cross?
5. Bollinger, `n = 4`, prices 10, 12, 11, 13, `k = 2`. Compute middle, σ, upper,
   lower (2 decimals).
6. ATR: prior close 200; current bar high 208, low 199. Compute TR and name the
   winning term.
7. Why does the wheel return `None` for the first 26 bars of `Macd(12, 26, 9)`?
8. A trader buys every time NIFTY touches the lower Bollinger band. Explain in
   two sentences why this fails in a downtrend, referencing %B and regime.

### Solutions

1. `SMA_4 = (99 + 105 + 108)/4 = 312/4 = 78` — wait, window is the last 4:
   `(103 + 99 + 105 + 108)/4 = 415/4 = 103.75`. First value appears at bar 4.
2. `α = 2/5 = 0.4`. `EMA_0 = 100`; `EMA_1 = 0.4·101 + 0.6·100 = 100.40`;
   `EMA_2 = 0.4·102 + 0.6·100.40 = 101.04`.
3. Changes: `+1, +1, −2, +3, −2`. Initial (first 3): gains `1,1,0` → AvgGain
   `= 2/3`; losses `0,0,2` → AvgLoss `= 2/3`; RS `= 1`; RSI `= 50`. Next change
   `+3`: AvgGain `= (2/3)(2/3) + 3/3 = 4/9 + 1 = 13/9`; AvgLoss `= (2/3)(2/3)
   = 4/9`; RS `= 13/4`; RSI `= 100 − 100/(1 + 3.25) = 100 − 23.53 = 76.47`.
4. `histogram = 6.2 − 5.6 = 0.6` — positive, so MACD is above signal: recent
   cross was up.
5. Mean `= (10+12+11+13)/4 = 11.5`. σ² `= [(−1.5)² + 0.5² + (−0.5)² + 1.5²]/4
   = 5/4 = 1.25`; σ `≈ 1.118`; Upper `= 11.5 + 2.236 = 13.74`; Lower `= 11.5 −
   2.236 = 9.26`.
6. `TR = max(208−199, |208−200|, |199−200|) = max(9, 8, 1) = 9` — the session
   range wins; the gap terms do not.
7. `Macd(12, 26, 9)` needs the slow EMA(26) (warm-up to bar 26) *and* the
   signal EMA(9) over the MACD line (≈ bar 34) before a value exists.
8. %B only says *where* price is inside the band envelope. In a downtrend the
   lower band keeps being repainted lower (bands drift with the falling SMA), so
   "touching the band" is not a bottom — that is a range-tool used in a trend.

## Quiz bank

| Question | A | B | C | D | Answer |
|---|---|---|---|---|---|
| SMA(20)'s first value appears at bar | 1 | 19 | 20 | 21 | C |
| EMA's smoothing constant is | 1/n | 2/(n+1) | (n−1)/n | n/2 | B |
| The EMA seed is | 0 | The first price | The SMA | The median | B |
| RSI = 100 when | AvgGain = 0 | AvgLoss = 0 | RS = 1 | Price = 0 | B |
| MACD line equals | EMA12 − EMA26 | SMA12 − SMA26 | EMA9 − EMA12 | Price − EMA26 | A |
| The MACD histogram equals | MACD − signal | Signal − price | EMA12 − price | %B | A |
| Bollinger σ uses | Sample / (n−1) | Population / n | Max deviation | Median | B |
| A bar with prior close 100, H 105, L 101 has TR | 4 | 5 | 1 | 6 | B |
| ATR measures | Trend direction | Volatility in price units | Momentum | Volume | B |
| In a strong uptrend RSI often stays in | 0–20 | 20–40 | 40–80 | 80–100 | C |

## Glossary

- **SMA** — arithmetic mean of the last `n` closes; equal weights.
- **EMA** — exponentially weighted mean with `α = 2/(n+1)`, seeded at the first
  price.
- **Warm-up** — the `n−1` (or deeper) bars before an indicator can print; the
  wheel returns `None`.
- **Wilder smoothing** — the `(n−1)/n` recursion used by RSI and ATR.
- **RSI** — `100 − 100/(1+RS)`; normalised 0–100 momentum from gains vs losses.
- **MACD** — `EMA12 − EMA26`; its own EMA(9) is the signal; the difference is
  the histogram.
- **MacdValue / BollingerValue** — the value objects the wheel returns, `None`
  until warm-up.
- **σ (population standard deviation)** — `sqrt(Σ(p_i − mean)² / n)`; the
  Bollinger band width.
- **%B** — `(Price − Lower) / (Upper − Lower)`; position inside the bands.
- **TR / ATR** — True Range `max(H−L, |H−C_prev|, |L−C_prev|)` and its Wilder
  average.
- **Divergence** — price makes a new high/low that an oscillator does not
  confirm.
- **Regime** — trending, ranging, or high-volatility; it picks the tool family.

## Reading assignment

- Murphy, *Technical Analysis of the Financial Markets*, ch. 7 (trend
  indicators).
- Pring, *Technical Analysis Explained*, ch. 12, 16 (oscillators, RSI range
  rules).
- Edwards & Magee, *Technical Analysis of Stock Trends*, ch. 36 (moving
  averages).
- IFTA *CFTe Syllabus & Study Guide*, App B (breadth), and the Brown material
  on RSI bands.
- Platform: run `tantra-examples/examples/02_indicators.py` — every indicator in
  this module on one script.
- Full list: [Reading & Resource List](../appendices/reading-list.md).

## Assessment reminder

This module feeds the **indicator lab** (10 live setups, each with formula +
wheel output + entry/stop/target) and the **written derivation quiz** — you must
hand-solve SMA/EMA/RSI/MACD/Bollinger/ATR from a 15-bar series under exam
conditions. See [Assessment](../front/assessment.md).

## Module assessment

- Indicator lab: 10 live setups, each with the **formula**, the wheel output,
  and the trade logic (entry/stop/target).
- Written derivation quiz: compute SMA/EMA/RSI/MACD/Bollinger/ATR from a 15-bar
  hand-solved series.

**Next:** [M5 — Gaps, Sentiment & Time Cycles](m5-gaps-sentiment-cycles.md)
