# M2 — Correlation, Regression & ANOVA

> **Weeks 51–52 · 16 hrs · PLO-8 · Core:** IFMC items 11–13; PGP T1-102

## Learning outcomes

- Compute correlation and covariance and interpret them.
- Run and interpret OLS regression: coefficients, R², p-values.
- Explain the ANOVA decomposition (total = explained + residual).
- Use regression for forecasting (the IFMC "forecasting techniques" item).

## Lesson 2.1 — Covariance and correlation

```
Cov(A,B) = (1/n) Σ (A_i − μA)(B_i − μB)
ρ = Cov(A,B) / (σA · σB)      (−1 ≤ ρ ≤ +1)
```

- `+1` perfect co-movement, `−1` perfect opposite, `0` no linear relation.
- Correlation ≠ causation; look for *sources* of correlation (factor, sector).

## Lesson 2.2 — OLS regression

For `y = α + βx + ε`:

```
β = Cov(x, y) / Var(x)
α = μy − β·μx
R² = fraction of variance in y explained by x
```

- This is how **beta** is estimated (S3-M6): regress stock returns on market
  returns.
- Interpreting outputs: coefficients, standard errors, t-stats/p-values,
  R², residual plots.

## Lesson 2.3 — ANOVA

```
SSTotal = SSExplained + SSResidual
```

- ANOVA table: degrees of freedom, mean squares, F-statistic.
- Use in the research report to test whether groups/sectors differ
  significantly (e.g., "do high-PE stocks and low-PE stocks have different
  forward returns?").

## Lesson 2.4 — Forecasting with regression

- Single-factor and multi-factor models.
- In-sample vs out-of-sample — the honesty rule from S2-M6 applies here too.
- `tantra-examples/examples/14_timeseries_forecast.py` and
  `15_fama_macbeth_factor_regression.py` are the advanced versions of this.

## Tantra Lab 2 — Beta via OLS

```python
from decimal import Decimal
from tantra.quant import returns, mean, covariance_matrix

stock = returns([b.close for b in synthetic_bars(SampleInstruments.RELIANCE, days=250, seed=1)])
mkt   = returns([b.close for b in synthetic_bars(SampleInstruments.NIFTY50, days=250, seed=1)])

# beta = Cov(stock, mkt) / Var(mkt)
panel = [[s, m] for s, m in zip(stock, mkt)]
cov = covariance_matrix(panel)          # 2x2 covariance matrix
beta = cov[0][1] / cov[1][1]
print("beta ≈", beta)
```

**Task:** run a two-factor regression of a stock on the market and a sector
index using `tantra.quant.ols`; report coefficients and R²; write one paragraph
on whether the stock is more market-driven or sector-driven. Read
`15_fama_macbeth_factor_regression.py` for the full pipeline.

## Assessment

- Regression mini-project: beta estimation + macro-factor model.
- Quiz: correlation, OLS, ANOVA.

**Next:** [M3 — Portfolio Theory: Markowitz, CAL, SML & CML](m3-portfolio-theory.md)
