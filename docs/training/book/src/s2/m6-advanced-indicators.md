# M6 — Advanced Indicators & Systems

> **Weeks 26–28 · 20 hrs · PLO-3 · Core reading:** Nison, *Beyond Candlesticks*; Higashino
> *Primer on Ichimoku* (IFTA App E); Du Plessis, *Point and Figure*; Le Beau & Lucas;
> Kirkpatrick & Dahlquist ch. 22

## Learning outcomes

- Compute and interpret ADX/DMI, Ichimoku components, and Fibonacci retracements.
- Construct Point & Figure and understand Market Profile (preview).
- Build, test, and honestly evaluate a simple trading system.
- Understand why systems fail (overfitting) before you build one.

## Prerequisites

- [M4 — Technical Indicators: The Math](m4-indicators-math.md): Wilder
  smoothing, ATR (`Atr.update`), SMA/EMA — ADX and Ichimoku reuse those exact
  mechanics.
- [M3 — Chart Patterns](m3-chart-patterns.md): breakouts, measured moves, the
  entry/stop/target habit — the Donchian Turtle system is that habit as a rule.
- `Decimal` `sqrt()` for the golden ratio `φ`.

## Lesson 6.1 — ADX / DMI (trend strength)

### 1) Concept

**ADX** answers one question: *how strong is the trend?* — not *which way*. It
is built from **directional movement** (DM): did today's high extend above
yesterday's high (+DM) or did today's low extend below yesterday's low (−DM)?

```
+DM_t = max(H_t − H_{t−1}, 0)      (only if it exceeds −DM)
−DM_t = max(L_{t−1} − L_t, 0)      (only if it exceeds +DM)

+DI = 100 · WilderSmoothed(+DM) / ATR
−DI = 100 · WilderSmoothed(−DM) / ATR
DX  = 100 · |+DI − −DI| / (+DI + −DI)
ADX = WilderSmoothing(DX)
```

`+DI` and `−DI` show *which side* has momentum; `DX` converts their gap into a
0–100 reading; ADX is the `(n−1)/n` Wilder smoothing of DX (the same recursion
as RSI/ATR). Rules of thumb: ADX > 20–25 = trending (use trend tools); ADX <
20 = ranging (use oscillators instead).

### 2) Worked example

Two bars: bar 1 high 24,000, low 23,900; bar 2 high 24,060, low 23,940.

```
+DM = max(24060 − 24000, 0) = 60        −DM = max(23900 − 23940, 0) = 0
```

Smoothing (for `n = 14`) with ATR 120 and previous smoothed +DM 40:

```
Sm(+DM) = 40·13/14 + 60/14 = 37.14 + 4.29 = 41.43
+DI = 100 · 41.43 / 120 = 34.5     −DI = 100 · 40·13/14 / 120 = 30.95
DX  = 100 · |34.5 − 30.95| / (34.5 + 30.95) = 100 · 3.55 / 65.45 ≈ 5.4
```

```python
from decimal import Decimal
from tantra.indicators import Adx
from tantra_examples import SampleInstruments, synthetic_bars

adx = Adx(di_length=14, adx_smoothing=14)
bars = synthetic_bars(SampleInstruments.NIFTY50, days=120, seed=7, base_price_paise=24_000)
last = None
for b in bars:
    last = adx.update(b.high, b.low, b.close)
if last is not None:
    print("ADX:", last.adx, "+DI:", last.plus_di, "-DI:", last.minus_di)
```

The wheel returns an **`AdxValue(adx, plus_di, minus_di)`** — one object with
the three numbers the formulas produce.

### 3) Common pitfalls

> **Pitfall:** reading high ADX as *bullish*. ADX measures strength only — a
> violent crash has a high ADX too.
> **Pitfall:** using ADX < 20 as a *bearish* signal. It means *no trend* —
> trade the range, not a direction.
> **Pitfall:** forgetting warm-up: the wheel needs `di_length + adx_smoothing`
> bars (≈ 28) before ADX prints.

### 4) Key takeaways

- **Takeaway:** +DI/−DI = direction; DX = gap; ADX = smoothed strength.
- **Takeaway:** ADX > 20–25 trending; < 20 ranging.
- **Takeaway:** the wheel returns `AdxValue(adx, plus_di, minus_di)`.

### Tantra Lab 6.1 — ADX from the wheel

#### Lab goal

Run ADX on a range-y and a trending series and confirm ADX is high in the trend
and low in the range — the empirical version of "ADX measures strength, not
direction".

#### Code

```python
from decimal import Decimal
from tantra.indicators import Adx
from tantra_examples import SampleInstruments, synthetic_bars

adx = Adx(di_length=14, adx_smoothing=14)
bars = synthetic_bars(SampleInstruments.NIFTY50, days=120, seed=7, base_price_paise=24_000)
last = None
for b in bars:
    last = adx.update(b.high, b.low, b.close)
if last is not None:
    print("ADX:", last.adx, "+DI:", last.plus_di, "-DI:", last.minus_di)
```

#### Expected output

`ADX: <Decimal>  +DI: <Decimal>  -DI: <Decimal>`. Repeat the identical loop
with `trending_bars(...)` — the trending series must print a materially higher
ADX. If `last` is still `None` (fewer than ~28 bars), the `if last is not None`
guard saves you.

#### Hand-in checklist

- [ ] The two ADX outputs (synthetic vs trending) side by side.
- [ ] A sentence connecting the numbers to the ADX > 20–25 rule.
- [ ] The series on which `+DI > −DI` — and what it implies for trend tools.

#### Common errors

- **Passing fewer than ~28 bars** — ADX needs `di_length + adx_smoothing`
  bars; the loop's guard is not optional.
- **Reading `.adx` on a `None`** — always check `last is not None` first.
- **Using `close` only** — `Adx.update` needs `high, low, close`.

## Lesson 6.2 — Ichimoku Kinko Hyo

### 1) Concept

**Ichimoku** is a *complete charting system* in five lines (Higashino):

```
Conversion (Tenkan) = (HH(9) + LL(9)) / 2
Base       (Kijun)  = (HH(26) + LL(26)) / 2
Span A (Senkou A)   = (Tenkan + Kijun) / 2        plotted 26 bars ahead
Span B (Senkou B)   = (HH(52) + LL(52)) / 2        plotted 26 bars ahead
Lagging  (Chikou)   = close plotted 26 bars back
Cloud = area between Span A and Span B
```

`HH(n)`/`LL(n)` are the highest high / lowest low of the last `n` bars. The
**cloud** (Kumo) is the fill between the two Senkou spans: price above the cloud
= bullish context; below = bearish; inside = choppy. A **Tenkan/Kijun cross** is
the trend-flip signal; the Chikou against price confirms. The wheel returns the
two *current-bar* spans as a tuple — its displacement convention keeps the
computation on the latest bar.

### 2) Worked example

Last 9 highs max 24,300, min 23,900 → Tenkan 24,100. HH(26)/LL(26) → Kijun
23,950. Then `Senkou A = (24,100 + 23,950)/2 = 24,025`; HH(52)/LL(52) → Senkou B
= 23,800.

```python
from decimal import Decimal
from tantra.indicators import Ichimoku
from tantra_examples import SampleInstruments, synthetic_bars

ich = Ichimoku(tenkan=9, kijun=26, senkou_b=52, displacement=26)
bars = synthetic_bars(SampleInstruments.NIFTY50, days=120, seed=7, base_price_paise=24_000)
last = None
for b in bars:
    last = ich.update(b.high, b.low)
print("last spans:", last)  # (span_a, span_b) or None until warm
```

`Ichimoku.update(high, low)` takes **two** arguments (the spans are built from
highs/lows only), and returns `(span_a, span_b)` — or `None` until the 52-bar
window fills.

### 3) Common pitfalls

> **Pitfall:** forgetting the spans are *midpoints of extremes*, not averages —
> a single extreme bar moves them.
> **Pitfall:** ignoring displacement — the cloud you see today is computed from
> bars 26 days ago; the wheel returns today's spans per its convention.
> **Pitfall:** using `update(close)` — Ichimoku spans need `high, low`; only the
> Chikou uses closes.

### 4) Key takeaways

- **Takeaway:** Tenkan/Kijun = `(HH(n)+LL(n))/2` for n = 9/26; spans average
  them; Senkou B over 52.
- **Takeaway:** price vs cloud = context; Tenkan/Kijun cross = signal.
- **Takeaway:** `update(high, low)` returns `(span_a, span_b)` or `None`.

### Tantra Lab 6.2 — Ichimoku spans

#### Lab goal

Confirm the wheel computes the five-line system's spans (with the 26-bar
displacement) on real bars, returning `(span_a, span_b)`.

#### Code

```python
from decimal import Decimal
from tantra.indicators import Ichimoku
from tantra_examples import SampleInstruments, synthetic_bars

ich = Ichimoku(tenkan=9, kijun=26, senkou_b=52, displacement=26)
bars = synthetic_bars(SampleInstruments.NIFTY50, days=120, seed=7, base_price_paise=24_000)
last = None
for b in bars:
    last = ich.update(b.high, b.low)
print("last spans:", last)  # (span_a, span_b) or None until warm
```

#### Expected output

`last spans: (Decimal, Decimal)` after ~52 bars of warm-up; `None` before. The
two values bracket the price's recent range — with `span_a` above `span_b` in a
bullish stretch and below in a bearish one.

#### Hand-in checklist

- [ ] The printed `(span_a, span_b)` recorded.
- [ ] A hand computation of Tenkan for the final bar from `(HH9 + LL9)/2`,
      compared to `(span_a + ... )` reasoning.
- [ ] A sentence: is the final price above, below, or inside the cloud — and
      what context does that give a trend trader?

#### Common errors

- **Passing closes instead of highs/lows** — `update(high, low)`; the Chikou is
  the only close-based component.
- **Calling `.value()`** — Ichimoku has no `.value()`; it returns the tuple.
- **Expecting spans before 52 bars** — `senkou_b=52` is the longest window.

## Lesson 6.3 — Fibonacci retracements

### 1) Concept

The Fibonacci sequence `F(n) = F(n−1) + F(n−2)` (1, 1, 2, 3, 5, 8, 13, …) yields
the **golden ratio** `φ = (1 + √5)/2 ≈ 1.618`, and the retracement ratios
0.236, 0.382, 0.5, 0.618, 0.786. They are applied to a prior swing: draw from a
swing low to a swing high; retracement levels are:

```
retracement level = high − ratio · (high − low)
```

So after a rally from 23,000 to 25,000, the 0.618 retracement is
`25,000 − 0.618·2,000 = 23,764` — a natural place for buyers to appear if the
uptrend is intact.

### 2) Worked example

```python
from decimal import Decimal

def fib_levels(low: Decimal, high: Decimal) -> dict[str, Decimal]:
    swing = high - low
    return {r: high - Decimal(r) * swing for r in ("0.236", "0.382", "0.5", "0.618", "0.786")}

print(fib_levels(Decimal("23000"), Decimal("25000")))
```

Output: `0.236 → 24,528 · 0.382 → 24,236 · 0.5 → 24,000 · 0.618 → 23,764 ·
0.786 → 23,428`. The golden ratio itself:

```
φ = (1 + √5)/2 ≈ 1.618  (appears again in Elliott Wave, M7)
```

### 3) Common pitfalls

> **Pitfall:** using arbitrary swing points — the retracement levels are only
> meaningful on *reaction swings* (M1's pivots).
> **Pitfall:** treating a level as a floor. 0.618 is a *zone* where buyers
> *tend* to appear; it needs candle/volume confirmation.
> **Pitfall:** mixing retracement (of a move) with extension (beyond a move) —
> M7 uses extensions of 1.272/1.618 for wave targets.

### 4) Key takeaways

- **Takeaway:** ratios 0.236/0.382/0.5/0.618/0.786 of the swing.
- **Takeaway:** `level = high − ratio·(high − low)`.
- **Takeaway:** `φ = (1+√5)/2 ≈ 1.618` — the whole family's source.

### Tantra Lab 6.3 — Fibonacci retracement levels

#### Lab goal

Compute all five retracement levels for a swing in `Decimal` and cross-check
against the wheel's `support_resistance.fibonacci_retracement`.

#### Code

```python
from decimal import Decimal

def fib_levels(low: Decimal, high: Decimal) -> dict[str, Decimal]:
    swing = high - low
    return {r: high - Decimal(r) * swing for r in ("0.236", "0.382", "0.5", "0.618", "0.786")}

print(fib_levels(Decimal("23000"), Decimal("25000")))
```

#### Expected output

A dict with five keys and five `Decimal` values: `0.236 → 24528`, `0.382 →
24236`, `0.5 → 24000`, `0.618 → 23764`, `0.786 → 23428`.

#### Hand-in checklist

- [ ] The printed levels in the journal.
- [ ] The wheel's `fibonacci_retracement` output for the same swing, compared.
- [ ] A chart: the swing drawn, levels marked, and the two levels nearest the
      current price noted as zones.

#### Common errors

- **Using float ratios** — `Decimal("0.618")`, never `0.618`.
- **Reversing the swing** — for a downtrend retracement use
  `low + ratio·(high − low)`; label which direction you measured.
- **Rounding to two places mid-calc** — keep full `Decimal` precision and round
  only for display.

## Lesson 6.4 — Point & Figure and Market Profile

### 1) Concept

**Point & Figure (P&F)** strips time and volume: only price matters, drawn as
X-columns (up) and O-columns (down) in a fixed **box size**, with a **reversal**
amount (commonly 3 boxes) to switch columns. P&F *projects targets* via two
counts: the **horizontal count** (width of a base × box size) and the
**vertical count** (height of a column projected). **Market Profile / TPO**
(trade-price opportunity) is the opposite idea: it charts *where price spent
time* during the session — the **value area** (where ~70% of volume traded)
becomes the market's equilibrium. Both are CFTe II depth, detailed in S5-TA.

### 2) Worked example

P&F box 50 points, 3-box reversal (150). An O-column drops 3 boxes from a
column high of 24,000 → column low 23,850. Vertical target: `24,000 − (height
in boxes × box)`. For a 5-box column: `24,000 − 250 = 23,750`.

```python
from decimal import Decimal
box, reversal = Decimal("50"), 3
drop_boxes = 5
column_high = Decimal("24000")
target = column_high - box * drop_boxes
print("P&F vertical target:", target)      # 23750
```

### 3) Common pitfalls

> **Pitfall:** including time/volume in P&F — the entire point is to remove
> them; the box size and reversal do all the filtering.
> **Pitfall:** forgetting the reversal convention — 3-box reversal is the
> standard; changing it changes every column.
> **Pitfall:** treating the value area as a price *prediction* — it describes
> *where the market has traded most*, a context, not a forecast.

### 4) Key takeaways

- **Takeaway:** P&F = price only, box + reversal; targets via horizontal/
  vertical counts.
- **Takeaway:** Market Profile/TPO = where time and volume were spent; the
  value area is the equilibrium.
- **Takeaway:** CFTe II depth — preview here, full treatment in S5-TA.

## Lesson 6.5 — System building & testing (Le Beau/Lucas, Kirkpatrick)

### 1) Concept

A **trading system** is a pattern (M3) or indicator rule (M4) reduced to
deterministic code. The five-step discipline (Le Beau/Lucas, Kirkpatrick):

1. **Define the edge in words** — e.g. "buy when price closes above the 20-day
   Donchian high" (this is the Turtle rule).
2. **Code the rule** — deterministic, in `Decimal`.
3. **Test on out-of-sample data** — never tune on the same data twice.
4. **Walk-forward analysis** — rolling train/test windows so every signal is
   genuinely out-of-sample.
5. **Honesty checklist** — sample size, costs, slippage, survivorship,
   overfitting.

The Turtle system is a Donchian-channel breakout: **Donchian** channels are
just rolling extremes:

```
upper = HH(n)   lower = LL(n)     DonchianValue(upper, lower)
```

When price closes above `upper`, buy (new 20-day high); below `lower`, sell.

### 2) Worked example

A one-line system check on the wheel:

```python
from decimal import Decimal
from tantra.indicators import Donchian
from tantra_examples import SampleInstruments, synthetic_bars

dc = Donchian(period=20)
bars = synthetic_bars(SampleInstruments.NIFTY50, days=250, seed=7, base_price_paise=24_000)
last = None
for b in bars:
    last = dc.update(b.high, b.low)
print("Donchian channels:", last)  # DonchianValue(upper, lower) or None until warm
```

`Donchian.update(high, low)` returns a **`DonchianValue(upper, lower)`** after
20 bars — the breakout rule compares each close to `upper`.

### 3) Common pitfalls

> **Pitfall:** overfitting — a rule tuned until the *same* data looks perfect is
> a curve drawn through noise; it fails live.
> **Pitfall:** testing on in-sample data only. Walk-forward exists so every
> decision is made on data the system has not seen.
> **Pitfall:** omitting costs/slippage — a profitable gross rule can be a
> losing net rule after brokerage, STT, and slippage.

### 4) Key takeaways

- **Takeaway:** a system is an edge, a rule, a test, and an honesty checklist.
- **Takeaway:** Donchian `upper = HH(n)`, `lower = LL(n)` — the Turtle breakout.
- **Takeaway:** out-of-sample testing is non-negotiable; walk-forward enforces
  it.

### Tantra Lab 6.4 — Turtle-style Donchian breakout

#### Lab goal

Compute the Donchian channels on a 250-bar series, then run the real Turtle
backtest to see the breakout rule trade end to end.

#### Code

```python
from decimal import Decimal
from tantra.indicators import Donchian
from tantra_examples import SampleInstruments, synthetic_bars

dc = Donchian(period=20)
bars = synthetic_bars(SampleInstruments.NIFTY50, days=250, seed=7, base_price_paise=24_000)
last = None
for b in bars:
    last = dc.update(b.high, b.low)
print("Donchian channels:", last)  # DonchianValue(upper, lower) or None until warm
```

#### Expected output

`Donchian channels: DonchianValue(upper=…, lower=…)` with two `Decimal` fields —
`upper` is the highest high of the last 20 bars and `lower` the lowest low.
Before bar 20 the output is `None`. Then run
`python tantra-examples/examples/07_turtle_breakout_backtest.py` and note its
fills and equity curve.

#### Hand-in checklist

- [ ] The `DonchianValue` fields recorded.
- [ ] The Turtle backtest's output: `bars_processed`, `orders_filled`,
      `events`, `refusals`.
- [ ] A three-line system spec for the Turtle rule: entry, stop (e.g. `lower`),
      target (e.g. 2× ATR from M4).

#### Common errors

- **Using the Donchian `upper` as a target** — it is the *trigger*; the stop and
  target are separate rules.
- **Passing closes to `Donchian.update`** — it needs `high, low`.
- **Judging the system on gross profit only** — the honesty checklist requires
  costs/slippage before believing the curve.

## Practice problems

1. Bars: bar 1 high 100, low 90; bar 2 high 106, low 92. Compute +DM and −DM.
2. With +DI = 30 and −DI = 20, compute DX.
3. Tenkan needs HH(9) and LL(9). If the last 9 highs max at 24,300 and the lows
   min at 23,900, what is the Tenkan?
4. `φ = (1 + √5)/2` — compute it in `Decimal` to 6 places and name two
   retracement ratios derived from it.
5. A swing 20,000 → 21,000: what is the 0.618 retracement level?
6. Why must a system's walk-forward windows be disjoint (non-overlapping)?
7. P&F box 25, reversal 3, an X-column rises 6 boxes from 23,900. What is the
   column high? What does the vertical count target if the column reverses?
8. Give one honest reason a backtested system can still lose money live — and
   one control against it.

### Solutions

1. `+DM = max(106−100, 0) = 6`; `−DM = max(90−92, 0) = 0`.
2. `DX = 100·|30−20|/(30+20) = 1000/50 = 20`.
3. `Tenkan = (24300 + 23900)/2 = 24,100`.
4. `φ ≈ 1.618034`; 0.618 = `1/φ` and 0.236 ≈ `1/φ³` derive from it.
5. `21000 − 0.618·1000 = 20,382`.
6. Overlapping windows leak test information into training — the "out-of-sample"
   claim becomes false and the walk-forward looks better than it is.
7. Column high `= 23,900 + 6·25 = 24,050`; on a 3-box reversal the count begins
   from the reversal column — targets are counts × box projected from the
   column.
8. Survivorship bias (the system was found because it worked on the past) or
   costs/slippage; controls: walk-forward testing, honesty checklist items, and
   never tuning on the same data twice.

## Quiz bank

| Question | A | B | C | D | Answer |
|---|---|---|---|---|---|
| ADX measures | Direction | Trend strength | Volume | Momentum speed | B |
| ADX below ~20 signals | A strong trend | A ranging market | A crash | A bull market | B |
| +DM_t equals | max(H_t−H_{t−1}, 0) | max(L_{t−1}−L_t, 0) | H_t−L_t | Close−open | A |
| The Ichimoku Tenkan is | (HH9+LL9)/2 | (HH26+LL26)/2 | SMA9 | EMA9 | A |
| Senkou A is plotted how far ahead | 9 | 26 | 52 | 0 | B |
| The golden ratio φ equals | (1+√5)/2 | √2 | π | 1.5 | A |
| 0.618 retracement of a 20,000→21,000 swing is | 20,382 | 20,618 | 20,500 | 20,236 | A |
| The Donchian upper equals | HH(n) | LL(n) | SMA(n) | EMA(n) | A |
| P&F charts include | Time | Volume | Both | Neither | D |
| Walk-forward testing prevents | Costs | Overfitting | Slippage | Gaps | B |

## Glossary

- **DM / +DI / −DI** — directional movement and its normalised indicators.
- **DX / ADX** — directional index and its Wilder average; trend *strength*.
- **Ichimoku** — the five-line Japanese system; the cloud is its centrepiece.
- **Tenkan / Kijun** — conversion and base lines: `(HH+LL)/2` over 9 and 26.
- **Senkou A / B** — cloud spans; A averages Tenkan+Kijun, B spans 52.
- **Kumo (cloud)** — the area between the spans; price above/below = context.
- **Fibonacci retracement** — `high − ratio·(high − low)` for the key ratios.
- **φ (golden ratio)** — `(1+√5)/2 ≈ 1.618`; the ratio family's source.
- **Point & Figure** — time/volume-free price chart of X and O columns.
- **Box size / reversal** — P&F's two parameters.
- **Market Profile / TPO** — where price spent time; value area = equilibrium.
- **Walk-forward** — rolling train/test windows for honest backtesting.

## Reading assignment

- Nison, *Beyond Candlesticks* (Ichimoku context).
- Higashino, *Primer on Ichimoku* (IFTA App E).
- Du Plessis, *The Definitive Guide to Point and Figure*.
- Le Beau & Lucas, *Technical Trader's Guide...* and Kirkpatrick & Dahlquist
  ch. 22 (system testing).
- Platform: `tantra-examples/examples/07_turtle_breakout_backtest.py`,
  `10_walkforward_optimization.py`, and `backtesting/04_walk_forward.py`.
- Full list: [Reading & Resource List](../appendices/reading-list.md).

## Assessment reminder

This module feeds the **mini-system backtest project** (rule, test,
walk-forward, honesty notes) and the **ADX/Ichimoku/Fibonacci quiz**. Both are
graded components — see [Assessment](../front/assessment.md).

## Assessment

- Mini-system backtest project (Excel/Python): rule, test, walk-forward, honesty notes.
- Quiz: ADX, Ichimoku, Fibonacci.

**Next:** [M7 — Elliott Wave & Market Psychology](m7-elliott-wave-psychology.md)
