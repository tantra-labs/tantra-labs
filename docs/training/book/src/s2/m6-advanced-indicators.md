# M6 — Advanced Indicators & Systems

> **Weeks 26–28 · 20 hrs · PLO-3 · Core reading:** Nison, *Beyond Candlesticks*; Higashino
> *Primer on Ichimoku* (IFTA App E); Du Plessis, *Point and Figure*; Le Beau & Lucas;
> Kirkpatrick & Dahlquist ch. 22

## Learning outcomes

- Compute and interpret ADX/DMI, Ichimoku components, and Fibonacci retracements.
- Construct Point & Figure and understand Market Profile (preview).
- Build, test, and honestly evaluate a simple trading system.
- Understand why systems fail (overfitting) before you build one.

## Lesson 6.1 — ADX / DMI (trend strength)

True Range and directional movement:

```
+DM_t = max(H_t − H_{t−1}, 0)      (when > −DM)
−DM_t = max(L_{t−1} − L_t, 0)      (when > +DM)

+DI = 100 · Smoothed(+DM) / ATR        −DI = 100 · Smoothed(−DM) / ATR
DX  = 100 · |+DI − −DI| / (+DI + −DI)
ADX = Wilder-smoothing of DX
```

- ADX **measures trend strength, not direction**.
- Rule of thumb: ADX > 20–25 = trending; < 20 = ranging (use oscillators instead).

### Tantra Lab 6.1 — ADX from the wheel

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

**Task:** run the ADX lab on both `synthetic_bars` (range-y) and `trending_bars`
(trending); confirm ADX is high in the trending series and low in the range-y
series. That empirical contrast *is* the "ADX measures trend strength, not
direction" rule.

## Lesson 6.2 — Ichimoku Kinko Hyo

Five lines (Higashino):

```
Conversion (Tenkan) = (HH(9) + LL(9)) / 2
Base       (Kijun)  = (HH(26) + LL(26)) / 2
Span A (Senkou A)   = (Tenkan + Kijun) / 2        plotted 26 bars ahead
Span B (Senkou B)   = (HH(52) + LL(52)) / 2        plotted 26 bars ahead
Lagging  (Chikou)   = close plotted 26 bars back
Cloud = area between Span A and Span B
```

- Price above cloud = bullish context; below = bearish; inside = choppy.
- Tenkan/Kijun cross ≈ trend-flip signal; Chikou vs price = confirmation.
- The wheel returns `(span_a, span_b)` on the current bar (displacement convention).

### Tantra Lab 6.2 — Ichimoku spans

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

## Lesson 6.3 — Fibonacci retracements

Key ratios from the Fibonacci sequence `F(n) = F(n−1) + F(n−2)`:

- 0.236, 0.382, 0.5, 0.618, 0.786 (retracements of a prior move).
- **Golden ratio** `φ = (1 + √5)/2 ≈ 1.618` — appears in Elliott Wave (M7).
- Application: draw a swing `low → high`; retracement levels are `high − k·(high − low)`.

### Tantra Lab 6.3 — Fibonacci retracement levels

```python
from decimal import Decimal

def fib_levels(low: Decimal, high: Decimal) -> dict[str, Decimal]:
    swing = high - low
    return {r: high - Decimal(r) * swing for r in ("0.236", "0.382", "0.5", "0.618", "0.786")}

print(fib_levels(Decimal("23000"), Decimal("25000")))
```

Compare with the wheel's `support_resistance.fibonacci_retracement`.

## Lesson 6.4 — Point & Figure and Market Profile

- **Point & Figure (P&F):** price only, box size + reversal; ignores time/volume.
  - Construction: X columns (up), O columns (down); box = fixed price step.
  - Projects price targets via horizontal/vertical counts.
- **Market Profile / TPO:** time-price opportunity — where the market spent time;
  value area concept (CFTe II depth; detailed in S5-TA).

## Lesson 6.5 — System building & testing (Le Beau/Lucas, Kirkpatrick)

1. **Define the edge in words:** e.g., "buy when price closes above the 20-day
   Donchian high" (this is the Turtle rule).
2. **Code the rule** (deterministic, in `Decimal`).
3. **Test on out-of-sample data** — never tune on the same data twice.
4. **Walk-forward analysis:** rolling train/test windows.
5. **Honesty checklist:** sample size, costs, slippage, survivorship, overfitting.

Tantra example: `tantra-examples/examples/10_walkforward_optimization.py` and
`backtesting/04_walk_forward.py` are exactly this discipline.

### Tantra Lab 6.4 — Turtle-style Donchian breakout

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

Run the real backtest: `python tantra-examples/examples/07_turtle_breakout_backtest.py`.

## Assessment

- Mini-system backtest project (Excel/Python): rule, test, walk-forward, honesty notes.
- Quiz: ADX, Ichimoku, Fibonacci.

**Next:** [M7 — Elliott Wave & Market Psychology](m7-elliott-wave-psychology.md)
