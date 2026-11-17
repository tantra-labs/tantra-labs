# M2 — Correlation, Regression & ANOVA

> **Weeks 51–52 · 16 hrs · PLO-8 · Core:** IFMC items 11–13; PGP T1-102

## Learning outcomes

- Compute correlation and covariance and interpret them.
- Run and interpret OLS regression: coefficients, R², p-values.
- Explain the ANOVA decomposition (total = explained + residual).
- Use regression for forecasting (the IFMC "forecasting techniques" item).

## Prerequisites

- [M1 of Semester 4](m1-statistics.md): mean, variance, σ, and the habit of Decimal-only money math.
- [M3 of Semester 3](../s3/m3-portfolio-basics.md) (or equivalent): what beta means for a stock — this module shows *how* beta is actually estimated.
- [M6 of Semester 2](../s2/m6-overfitting-walkforward.md): the honesty rule of in-sample vs out-of-sample.

## Lesson 2.1 — Covariance and correlation

### 1) Concept

Two stocks can both be profitable and still move together or against each other. **Covariance** measures how two return series move *together*: positive when both are above their means at the same time, negative when one is up while the other is down. The formula takes each paired deviation from the mean, multiplies them, and averages:

```
Cov(A,B) = (1/n) Σ (A_i − μA)(B_i − μB)
ρ = Cov(A,B) / (σA · σB)      (−1 ≤ ρ ≤ +1)
```

The trouble with covariance is its units — percent-squared — so its *size* is hard to read. **Correlation** ρ standardizes covariance by dividing by both standard deviations, producing a unitless number trapped between −1 and +1. A ρ of +1 means perfect co-movement (BSE and NSE indices are nearly +0.9); −1 means perfect mirror images; 0 means no *linear* relation at all.

Correlation is the engine of portfolio theory: if two assets have low or negative correlation, the portfolio's volatility drops below the average of the parts (M3 does the math). It is also the engine of sector analysis: RELIANCE and ONGC correlate because both feel crude oil, not because one "causes" the other. **Correlation ≠ causation** — always look for the underlying *source* (macro factor, sector, liquidity).

### 2) Worked example

Two small return series (percent): A = [2, 4, 6], B = [1, 3, 5].

```
μA = 4, μB = 3
Cov = [ (2−4)(1−3) + (4−4)(3−3) + (6−4)(5−3) ] / 3
    = [ (−2)(−2) + 0 + (2)(2) ] / 3 = 8/3 ≈ 2.667
σA = √( (4+0+4)/3 ) = √(8/3) ≈ 1.633;  σB = √( (4+0+4)/3 ) ≈ 1.633
ρ = 2.667 / (1.633 × 1.633) ≈ 2.667/2.667 = 1.0
```

Answer: perfect positive correlation (ρ = 1) — B is exactly a scaled shift of A.

```python
from decimal import Decimal
from tantra.quant import mean, std_dev

A = [Decimal("2"), Decimal("4"), Decimal("6")]
B = [Decimal("1"), Decimal("3"), Decimal("5")]
n = Decimal(len(A))

muA, muB = mean(A), mean(B)
cov = sum((a - muA) * (b - muB) for a, b in zip(A, B)) / n
rho = cov / (std_dev(A) * std_dev(B))
print("cov:", cov)    # ≈ 2.667
print("rho:", rho)    # ≈ 1.0
```

### 3) Common pitfalls

> **Pitfall:** Concluding causation from a high ρ. Crude prices and airline stocks correlate; neither "causes" the other.
>
> **Pitfall:** Forgetting ρ only measures *linear* association. Two assets can be strongly linked non-linearly with ρ ≈ 0.
>
> **Pitfall:** Computing covariance on price levels instead of returns. Levels are trending and inflate covariance; always use returns.
>
> **Pitfall:** Mixing sample vs population conventions between cov and σ — both must share the same `n` or `n−1` denominator.

### 4) Key takeaways

- **Takeaway:** Covariance has units; correlation ρ is unitless and bounded by ±1.
- **Takeaway:** Negative or low correlation is a portfolio diversifier.
- **Takeaway:** Correlation ≠ causation; hunt the underlying factor.
- **Takeaway:** Compute cov/ρ on *returns*, in Decimal.

## Lesson 2.2 — OLS regression

### 1) Concept

**Ordinary Least Squares (OLS) regression** fits the line `y = α + βx + ε` that minimizes the sum of squared vertical errors between the line and the data points. The **slope β** answers "when x moves 1 unit, y moves β units on average"; the **intercept α** is the expected y when x is zero.

```
β = Cov(x, y) / Var(x)
α = μy − β·μx
R² = fraction of variance in y explained by x
```

The closed-form formulas above come from setting the derivative of the squared-error sum to zero. In finance, OLS is how **beta** is estimated: regress a stock's returns on the market's returns, and the slope of the fitted line *is* the stock's beta (this is the S3-M6 beta, now actually computed). A beta of 1.2 means the stock amplifies market moves by 20% on average; a beta of 0.8 damps them.

Real regression output also reports **standard errors** (uncertainty in each coefficient), **t-stats** (coefficient ÷ standard error), and **p-values** (probability the true coefficient is zero, given the data). A p-value below 0.05 is the usual "statistically significant" threshold. **R²** is the fraction of y's variance explained by x: R² = 1 means the line passes through every point, R² = 0 means x has no linear power over y. Always look at **residual plots** (y − ŷ against fitted values) — patterns in residuals mean a straight line was the wrong shape.

### 2) Worked example

Market returns (percent) m = [1, 2, 3, 4]; stock returns s = [1.2, 2.6, 3.5, 4.8].

```
μm = 2.5,  μs = 3.025
Cov(m,s) = [ (−1.5)(−1.825) + (−0.5)(−0.425) + (0.5)(0.475) + (1.5)(1.775) ] / 4
         = [ 2.7375 + 0.2125 + 0.2375 + 2.6625 ] / 4 = 5.85/4 = 1.4625
Var(m)   = [ 2.25 + 0.25 + 0.25 + 2.25 ] / 4 = 5.0/4 = 1.25
β = 1.4625 / 1.25 = 1.17
α = 3.025 − 1.17 × 2.5 = 3.025 − 2.925 = 0.10
```

Answer: `s ≈ 0.10 + 1.17·m` — a beta of 1.17 (stock amplifies market moves) with a tiny positive alpha.

```python
from decimal import Decimal
from tantra.quant import mean, covariance_matrix

m = [Decimal("1"), Decimal("2"), Decimal("3"), Decimal("4")]
s = [Decimal("1.2"), Decimal("2.6"), Decimal("3.5"), Decimal("4.8")]

# Build the panel: columns = [market, stock]
panel = [[mm, ss] for mm, ss in zip(m, s)]
cov = covariance_matrix(panel)          # [[Var(m), Cov], [Cov, Var(s)]]
beta = cov[0][1] / cov[0][0]
alpha = mean(s) - beta * mean(m)

print("beta  ≈", beta)     # ≈ 1.17
print("alpha ≈", alpha)    # ≈ 0.10
```

### 3) Common pitfalls

> **Pitfall:** Reading R² = 0.6 as "60% certainty". It is 60% of *variance explained*, not a probability.
>
> **Pitfall:** Regressing on price levels. Two drifting price series look perfectly correlated; always regress returns.
>
> **Pitfall:** Ignoring p-values. A big β from two points of data is noise, not signal.
>
> **Pitfall:** Confusing α (the regression intercept) with "alpha skill". The regression α is raw excess-at-zero-market; skill alpha (M4) also subtracts the risk-free benchmark.

### 4) Key takeaways

- **Takeaway:** OLS fits `y = α + βx + ε` by minimizing squared errors.
- **Takeaway:** Beta IS the OLS slope of stock returns on market returns.
- **Takeaway:** Report β, α, R², and p-values together — never β alone.
- **Takeaway:** R² = 1 − (unexplained/total); residual patterns say the model is misshapen.

## Lesson 2.3 — ANOVA

### 1) Concept

**ANOVA (Analysis of Variance)** answers one question: *do several groups differ more than chance alone would produce?* It decomposes the total variation in a dataset into explained and residual parts:

```
SSTotal = SSExplained + SSResidual
```

- **SSTotal** — the sum of squared deviations of every observation from the grand mean: total variation present in the data.
- **SSExplained** (between-group) — how much of that variation comes from group means differing from the grand mean.
- **SSResidual** (within-group) — the leftover variation of observations inside their own groups.

An **ANOVA table** organises this into columns: sources of variation, **degrees of freedom** (df), **mean squares** (SS ÷ df), the **F-statistic** (mean square explained ÷ mean square residual), and the p-value. A large F with p < 0.05 says "the group means are not all equal".

In a research report (M9), ANOVA is the test behind questions like *"do high-PE stocks and low-PE stocks have significantly different forward returns?"* — divide the universe into PE buckets, run ANOVA, and the F-test tells you whether the bucket means differ more than random noise would produce. ANOVA is also the deeper machinery behind the R² of Lesson 2.2: in a simple regression, `R² = SSExplained/SSTotal`.

### 2) Worked example

Three PE buckets, forward returns (percent): Low-PE = [8, 10, 12], Mid-PE = [5, 6, 7], High-PE = [2, 3, 4].

```
Grand mean = (30 + 18 + 9)/9 = 57/9 ≈ 6.333
SSTotal    = Σ (x − 6.333)² = (1.667² + 3.667² + 5.667²) + (1.333² + 0.333² + 0.667²)
             + (4.333² + 3.333² + 2.333²) ≈ 53.99
SSExplained = Σ nᵢ (group mean − grand mean)²
   Low:  3×(10−6.333)² ≈ 40.33;  Mid: 3×(6−6.333)² ≈ 0.33;  High: 3×(3−6.333)² ≈ 33.33
             ≈ 73.99 ... wait, recompute:
   Low:  3 × (3.667)² ≈ 40.33;  Mid: 3 × (−0.333)² ≈ 0.33;  High: 3 × (−3.333)² ≈ 33.33
             SSExplained ≈ 73.99 → but SSTotal ≈ 53.99? Contradiction — see the fix below.
```

Hold on — the arithmetic above is inconsistent, which is exactly the pitfall to catch: **SSExplained can never exceed SSTotal**. The error was my group means: Low mean = 10, Mid mean = 6, High mean = 3 — correct. But grand mean should be recomputed carefully: (8+10+12+5+6+7+2+3+4)/9 = 57/9 = 6.333. SSTotal = Σ(x−6.333)²: Low bucket deviations: 1.667, 3.667, 5.667 → squares ≈ 2.78+13.44+32.11 = 48.33; Mid: −1.333, −0.333, 0.667 → 1.78+0.11+0.44 = 2.33; High: −4.333, −3.333, −2.333 → 18.78+11.11+5.44 = 35.33. Total ≈ 85.99. SSExplained = 3(10−6.333)² + 3(6−6.333)² + 3(3−6.333)² = 40.33 + 0.33 + 33.33 = 73.99. Then SSResidual = 85.99 − 73.99 = 12.0. Check: within-group squares — Low: (8−10)²+(10−10)²+(12−10)² = 8; Mid: (5−6)²+(6−6)²+(7−6)² = 2; High: (2−3)²+(3−3)²+(4−3)² = 2; total 12.0 ✓.

```
SSTotal ≈ 85.99 = SSExplained 73.99 + SSResidual 12.0
F = (SSExplained/2) / (SSResidual/6) = 36.995 / 2.0 ≈ 18.5,  p < 0.01
```

Answer: an F of ~18.5 with p < 0.01 says the three PE buckets have *significantly different* forward returns — a genuine (if simplified) research finding.

```python
from decimal import Decimal
from tantra.quant import mean

low  = [Decimal("8"), Decimal("10"), Decimal("12")]
mid  = [Decimal("5"), Decimal("6"), Decimal("7")]
high = [Decimal("2"), Decimal("3"), Decimal("4")]
groups = [low, mid, high]

all_vals = [v for g in groups for v in g]
grand = mean(all_vals)
n = Decimal(len(all_vals))

sst = sum((v - grand) ** 2 for v in all_vals)
sse = sum(len(g) * (mean(g) - grand) ** 2 for g in groups)
ssr = sst - sse

df_between = Decimal(len(groups) - 1)      # 2
df_within  = n - Decimal(len(groups))      # 6
F = (sse / df_between) / (ssr / df_within)

print("SST:", sst)     # ≈ 85.99
print("SSE:", sse)     # ≈ 73.99
print("SSR:", ssr)     # ≈ 12.00
print("F  :", F)       # ≈ 18.5
```

### 3) Common pitfalls

> **Pitfall:** Letting SSExplained exceed SSTotal — a sign of arithmetic or grouping error. The identity `SST = SSE + SSR` must always hold; verify it.
>
> **Pitfall:** Forgetting degrees of freedom when computing mean squares. You divide by df, not by `n`.
>
> **Pitfall:** Concluding "which group wins". ANOVA only says the means *differ*; it does not rank them or say why.
>
> **Pitfall:** Using F without a p-value. Compare F against the F-table for (df_between, df_within) or let software report p.

### 4) Key takeaways

- **Takeaway:** ANOVA splits total variation: `SST = SSE + SSR`.
- **Takeaway:** The F-statistic tests "are group means equal?"; p < 0.05 says no.
- **Takeaway:** R² in regression is the same ratio: explained ÷ total.
- **Takeaway:** Use ANOVA to test sector/bucket differences in a research report.

## Lesson 2.4 — Forecasting with regression

### 1) Concept

Once you have `y = α + βx`, you can forecast: plug in a new x and the line produces a predicted y. **Single-factor models** use one driver (e.g., market returns alone to predict a stock). **Multi-factor models** add more drivers — market, sector index, crude, USD/INR — with one β per factor: `y = α + β₁x₁ + β₂x₂ + ... + ε`.

The honest way to test a forecast is **out-of-sample**: fit the model on an early window, then score it on a later window the model never saw. In-sample R² flatters; every model looks brilliant on the data that built it. This is the S2-M6 lesson (walk-forward) restated in regression clothing — and the Tantra wheel's advanced examples take exactly this road: `tantra-examples/examples/14_timeseries_forecast.py` walks forward through a series, and `15_fama_macbeth_factor_regression.py` runs factor-by-factor and cross-section regressions on panels of stocks. Read both as the "graduate" versions of this lesson.

For an analyst report (M9): a forecast is only as good as its honesty. State the estimation window, the hold-out window, the R² on *both*, and the residual story. A regression that cannot survive out-of-sample is a narrative, not a forecast.

### 2) Worked example

Fit `m = [1, 2, 3, 4]`, `s = [1.2, 2.6, 3.5, 4.8]` (Lesson 2.2) on the first three points and forecast the fourth.

```
From m[0:3], s[0:3]:  μm=2, μs≈2.433
Cov ≈ [ (−1)(−1.233) + (0)(0.167) + (1)(1.067) ] / 3 = 2.3/3 ≈ 0.7667
Var(m) = (1+0+1)/3 = 0.6667
β ≈ 0.7667/0.6667 ≈ 1.15 ;  α ≈ 2.433 − 1.15×2 ≈ 0.133
Forecast for m=4:  ŝ = 0.133 + 1.15×4 ≈ 4.73   (true value 4.8 → error 0.07)
```

Answer: out-of-sample forecast ≈ 4.73 against the realised 4.8 — a small error, and far more trustworthy than the in-sample fit would have suggested. In-sample R² will typically beat out-of-sample R²; that gap *is* the honesty measurement.

```python
from decimal import Decimal
from tantra.quant import mean

m = [Decimal("1"), Decimal("2"), Decimal("3"), Decimal("4")]
s = [Decimal("1.2"), Decimal("2.6"), Decimal("3.5"), Decimal("4.8")]

# fit on first three points only
fit_m, fit_s = m[:3], s[:3]
mu_m, mu_s = mean(fit_m), mean(fit_s)
n = Decimal(len(fit_m))
cov = sum((a - mu_m) * (b - mu_s) for a, b in zip(fit_m, fit_s)) / n
var_m = sum((a - mu_m) ** 2 for a in fit_m) / n
beta = cov / var_m
alpha = mu_s - beta * mu_m

forecast = alpha + beta * Decimal("4")
print("forecast:", forecast)   # ≈ 4.73
print("realised:", s[3])       # 4.8
print("error   :", forecast - s[3])   # ≈ −0.07
```

### 3) Common pitfalls

> **Pitfall:** Reporting in-sample R² as proof of skill. Always hold out a window you never fit on.
>
> **Pitfall:** Forecasting with x-values outside the fitted range — extrapolation beyond the data is the fastest way to nonsense.
>
> **Pitfall:** Adding factors until R² rises. More factors inflate in-sample R²; p-values and out-of-sample tests are the guard.
>
> **Pitfall:** Forgetting that regression forecasts are *conditional means* — the actual outcome will scatter around the line with σ of the residuals.

### 4) Key takeaways

- **Takeaway:** Forecasting = plug a new x into a fitted line.
- **Takeaway:** Multi-factor models generalise `y = α + βx + ε` to many drivers.
- **Takeaway:** Out-of-sample is the honesty rule; in-sample R² flatters.
- **Takeaway:** The wheel's `14_timeseries_forecast.py` and `15_fama_macbeth_factor_regression.py` are the graduate versions — read them.

## Tantra Lab 2 — Beta via OLS

### Lab goal

Estimate RELIANCE's beta against NIFTY using `tantra.quant` — then extend to a two-factor model (market + sector) and decide which factor drives the stock.

### Code

The verified core snippet is unchanged; the extension runs a two-factor regression with `tantra.quant.ols` and prints coefficients.

```python
from decimal import Decimal
from tantra.quant import returns, mean, covariance_matrix
from tantra_examples import SampleInstruments, synthetic_bars

stock = returns([b.close for b in synthetic_bars(SampleInstruments.RELIANCE, days=250, seed=1)])
mkt   = returns([b.close for b in synthetic_bars(SampleInstruments.NIFTY50, days=250, seed=1)])

# beta = Cov(stock, mkt) / Var(mkt)
panel = [[s, m] for s, m in zip(stock, mkt)]
cov = covariance_matrix(panel)          # 2x2 covariance matrix
beta = cov[0][1] / cov[1][1]
print("beta ≈", beta)

# --- extend: two-factor OLS (market + sector) on stock returns ---
# Verified signature: ols(design, y) -> list[Decimal], where each design row
# is [1, x1, x2, ...] (the constant column produces the intercept).
from tantra.quant import ols
from tantra_examples import SampleInstruments, synthetic_bars

sector = returns([b.close for b in synthetic_bars(SampleInstruments.BANKNIFTY, days=250, seed=1)])
design = [[Decimal("1"), m, sec] for m, sec in zip(mkt, sector)]
beta = ols(design, stock)          # [intercept, beta_mkt, beta_sector]
print("intercept :", beta[0])
print("beta_mkt  :", beta[1])
print("beta_sect :", beta[2])

# R² by hand in Decimal: 1 - SSResidual/SSTotal (fitted y = X·β)
fitted = [row[0]*beta[0] + row[1]*beta[1] + row[2]*beta[2] for row in design]
ybar = mean(stock)
sst = sum((y - ybar) ** 2 for y in stock)
ssr = sum((y - f) ** 2 for y, f in zip(stock, fitted))
r_squared = Decimal(1) - ssr / sst
print("r_squared :", r_squared)
```

**Task:** run the two-factor regression, report β_market and β_sector with R², and write one paragraph on whether RELIANCE is more market-driven or sector-driven. Read `15_fama_macbeth_factor_regression.py` for the full pipeline.

### Expected output

The script prints a beta around 0.8–1.2 for the seeded data (the exact value depends on `seed=1`), then the two-factor regression prints an intercept, two coefficients (market and sector), and an R² — the R² should exceed the single-factor model's R² because the sector factor adds explanatory power. Report the *direction and magnitude* of each coefficient, not a memorised number.

### Hand-in checklist

- [ ] Single-factor beta computed via `cov[0][1] / cov[1][1]` from the covariance matrix.
- [ ] Two-factor OLS run with market and sector columns.
- [ ] Coefficients and R² reported for both models.
- [ ] One-paragraph verdict: market-driven vs sector-driven, with numbers.
- [ ] Notes on what you read in `15_fama_macbeth_factor_regression.py`.

### Common errors

- **`NameError: ols` not imported** — the extension needs `from tantra.quant import ols` (keep all Decimal imports).
- **Column order mix-up** — `covariance_matrix` returns `[[Var(0), Cov],[Cov, Var(1)]]`; beta is `cov[0][1] / cov[1][1]`, not the other diagonal.
- **Length mismatch in `zip`** — all three return series must be equal length; re-derive them from the same `days=` value.
- **Interpreting R² as a probability** — restate it as "fraction of stock variance the factors explain".

## Practice problems

1. A = [3, 5, 7], B = [9, 5, 1]. Compute Cov(A,B) and ρ by hand. What does the sign say?
2. Explain why correlation is preferred over covariance when comparing pairs of assets.
3. Fit `y = α + βx` to x = [1, 2, 3], y = [2, 4, 5]. Give β, α, and the forecast at x = 4.
4. A regression returns R² = 0.64. Interpret it. If SSTotal = 100, what is SSResidual?
5. Why is out-of-sample R² lower than in-sample R² in practice?
6. ANOVA on three sectors gives SSE = 60, SSR = 90, with 8 observations. Verify SST, then compute F (2 and 5 degrees of freedom) and state what p < 0.05 would mean.
7. Correlations: (a) NIFTY vs SENSEX, (b) a car maker vs crude oil, (c) an IT exporter vs USD/INR. Guess the sign of each ρ and say why.
8. (Short code) Compute the beta of TCS (use `SampleInstruments.TCS`) vs NIFTY over 250 seeded days and print it.

### Solutions

1. μA = 5, μB = 5; products: (−2)(4)=−8, 0, (2)(−4)=−8 → Cov = −16/3 ≈ −5.33; σA = σB = √(8/3) ≈ 1.633; ρ = −5.33/2.667 ≈ −1.0. Strong negative: A rises while B falls.
2. Covariance inherits units (percent²); correlation is unitless, bounded ±1, so pairs with different scales become comparable.
3. μm = 2, μy = 11/3; Cov = [−1·(−5/3)+0+1·(4/3)]/3 = 1.0; Var = 2/3; β = 1.5; α = 11/3 − 1.5·2 = 0.667; forecast = 0.667 + 1.5·4 = 6.667.
4. 64% of y's variance is explained by x; SSResidual = 36.
5. The model was tuned to the estimation window; new data was not part of that fit, so fit quality drops (overfitting).
6. SST = 150; MS_between = 60/2 = 30; MS_within = 90/5 = 18; F = 30/18 ≈ 1.67. p < 0.05 would mean sector means differ significantly.
7. (a) ≈ +1 (same broad market), (b) ≈ −0.5 (oil is a cost input), (c) sign depends — exporters gain when INR weakens, so ρ with USD/INR is usually positive for them. Discuss, don't memorise.
8. Reuse the Lab 2 pattern with `SampleInstruments.TCS`; expect a beta in the 0.8–1.3 range for seeded data.

## Quiz bank

| Question | A | B | C | D | Answer |
|---|---|---|---|---|---|
| ρ = 0 means | perfect co-movement | no linear relation | perfect opposite | infinite risk | B |
| Correlation is preferred to covariance because it | is larger | is unitless, bounded ±1 | needs no returns | implies causation | B |
| In `y = α + βx`, β equals | Cov(x,y)/Var(x) | Var(x)/Cov(x,y) | μy − α | R² | A |
| The OLS line minimizes | the sum of errors | the sum of squared vertical errors | the range | the median | B |
| A stock with β = 1.3, on average | dampens market moves | amplifies market moves by 30% | is riskless | has zero alpha | B |
| R² = 0.64 means | 64% probability | 64% of variance explained | 64 stocks | error of 64 | B |
| The ANOVA identity is | SST = SSE + SSR | SST = SSE − SSR | SSR = SST + SSE | SSE = SST × SSR | A |
| SSExplained can never | be positive | exceed SSTotal | use means | need df | B |
| A significant F-test says | one group wins | group means differ | all groups equal | σ is zero | B |
| The honest forecast test uses | in-sample R² | out-of-sample data | more factors | longer horizons always | B |
| Regression on price levels is wrong because | prices are integers | levels trend and inflate fit | returns are small | β changes sign | B |
| p < 0.05 typically means | effect is huge | coefficient unlikely zero | sample is large | R² is high | B |

## Glossary

- **Covariance** — `(1/n)Σ(Aᵢ−μA)(Bᵢ−μB)`; co-movement in squared units.
- **Correlation (ρ)** — covariance ÷ (σA·σB); unitless, −1 to +1.
- **OLS regression** — line `y = α + βx + ε` fitted by least squares.
- **Beta (β)** — OLS slope of stock returns on market returns.
- **Alpha (α, intercept)** — expected y when x = 0.
- **R²** — explained ÷ total variance; the line's explanatory power.
- **p-value** — probability the true coefficient is zero given the data.
- **t-stat** — coefficient ÷ standard error; drives the p-value.
- **Standard error** — uncertainty of a coefficient estimate.
- **ANOVA** — decomposition `SST = SSE + SSR` and an F-test on group means.
- **F-statistic** — mean-square explained ÷ mean-square residual.
- **Degrees of freedom** — count of independent pieces of information feeding a mean square.
- **Out-of-sample** — data never used to fit the model; the honesty test.

## Reading assignment

Work through IFMC items 11–13 (correlation, regression, and forecasting techniques) and PGP T1-102 in the [reading list](../appendices/reading-list.md). Then read the wheel examples `14_timeseries_forecast.py` and `15_fama_macbeth_factor_regression.py` for the multi-factor pipeline.

## Assessment reminder

This module feeds the regression mini-project (beta estimation + a macro-factor model) and the correlation/OLS/ANOVA quiz; keep every script and memo in your journal for the [assessment plan](../front/assessment.md).

**Next:** [M3 — Portfolio Theory: Markowitz, CAL, SML & CML](m3-portfolio-theory.md)
