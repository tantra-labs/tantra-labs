# M1 — Statistics for Markets

> **Weeks 49–51 · 24 hrs · PLO-8 · Core:** IFMC items 22, 27–28, 31; CFTe II App G; PGP T1-102

## Learning outcomes

- Compute mean, median, mode, range, variance, and standard deviation.
- Interpret skewness and kurtosis as risk information.
- Describe the normal distribution and why returns are not normal.
- Summarize a return series with a stats deck.

## Lesson 1.1 — Descriptive statistics

```
Mean   μ = Σx / n
Variance (population)  σ² = Σ(x − μ)² / n
Std dev               σ = √σ²
```

- Median, mode, range, percentiles, quartiles.
- Population vs sample (`n−1` denominator) — know which you are using.

## Lesson 1.2 — Returns as the unit of analysis

- Simple returns: `R_t = P_t / P_{t−1} − 1` (see `tantra.quant.returns`).
- Log returns: `ln(P_t / P_{t−1})` — time-additive, used in quantitative work.
- Annualization: `σ_annual ≈ σ_daily × √252`.

## Lesson 1.3 — Skewness and kurtosis

```
Skewness = (1/n) Σ ((x − μ)/σ)³
Kurtosis = (1/n) Σ ((x − μ)/σ)⁴
```

- **Negative skew** = fat left tail: occasional large losses — bad for
  long-only holders.
- **High kurtosis** = fat tails: more extreme moves than the normal predicts.
- These are *risk* statistics, not just decoration.

## Lesson 1.4 — Distributions

- The normal distribution: `N(μ, σ)`, z-scores, the 68-95-99.7 rule.
- Why stock returns are **leptokurtic** (fat-tailed) — volatility clustering.
- Lognormal prices: `P_T = P_0·exp(...)` — the bridge to Black-Scholes (M6).

## Tantra Lab 1 — Stats deck from the wheel

```python
from decimal import Decimal
from tantra.quant import returns, mean, std_dev
from tantra_examples import SampleInstruments, synthetic_bars

bars = synthetic_bars(SampleInstruments.NIFTY50, days=500, seed=42, base_price_paise=24_000)
rets = returns([b.close for b in bars])

print("mean:", mean(rets))
print("std :", std_dev(rets))
```

**Task:** extend the script to compute skewness and kurtosis by hand in
`Decimal`, then write the one-page "statistical character of this index" memo:
mean, σ, skew, kurtosis, and what the tails say about risk. Annualize σ.

## Assessment

- Statistics lab: return-series analysis of an index (Excel + Decimal script).
- Quiz: statistics definitions.

**Next:** [M2 — Correlation, Regression & ANOVA](m2-correlation-regression.md)
