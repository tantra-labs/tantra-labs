# M4 — Performance Measurement

> **Weeks 54–55 · 12 hrs · PLO-8 · Core:** IFMC item 38; PGP T4(PM)-401/402

## Learning outcomes

- Compute Sharpe, Treynor, and Jensen's alpha.
- Choose the right measure for the right context.
- Read a fund/strategy scorecard and explain it to a client.

## Prerequisites

- [M3](m3-portfolio-theory.md): the CAPM/SML line, β, the risk-free asset Rf — performance measures are CAPM's *report card*.
- [M2](m2-correlation-regression.md): computing β from the covariance matrix; alpha's CAPM intercept.
- [M1](m1-statistics.md): mean and σ of a return series in Decimal.

## Lesson 4.1 — Sharpe ratio

### 1) Concept

The **Sharpe ratio** answers "how much reward did the portfolio earn per unit of *total* risk it took?" It subtracts the risk-free return (what you could have earned risklessly in a T-bill) from the portfolio return, then divides by the portfolio's standard deviation:

```
Sharpe = (Rp − Rf) / σp
```

Because the numerator is a risk *premium* and the denominator is total risk (σ), a Sharpe of 1.0 is good and 2.0 is excellent at the annual horizon. The Sharpe ratio is the right measure for **well-diversified portfolios**, where total risk ≈ systematic risk anyway, so punishing the manager for total σ is fair. It is also exactly the *slope* of the CAL/CML you met in M3: the steeper the line from Rf to the portfolio, the higher the Sharpe.

Important house rule for this course: compute Sharpe *yourself* in Decimal. The wheel's `optimizer.sharpe_sortino_dd` is a **fitness aggregator** for genetic optimisation — it takes four fitness scalars (Sharpe, Sortino, profit factor, max drawdown) and blends them into one number for the search loop. It does *not* compute Sharpe from a return series. So the verified lab snippet defines its own tiny `sharpe()` helper on `mean`/`std_dev`.

### 2) Worked example

A strategy returns 0.06%/day on average with σ = 0.9%/day; T-bills pay 0.004%/day (annual 1%).

```
Sharpe_daily = (0.0006 − 0.00004) / 0.009 = 0.00056/0.009 ≈ 0.0622
Sharpe_annual ≈ 0.0622 × √252 ≈ 0.987
```

The daily scale is tiny because returns are daily; practitioners annualise by ×√252 (M1's rule) to get an interpretable number ≈ 0.99 — roughly one unit of reward per unit of risk per year.

```python
from decimal import Decimal
from tantra.quant import mean, std_dev

rets = [Decimal("0.0006"), Decimal("-0.0003"), Decimal("0.0010"),
        Decimal("0.0001"), Decimal("-0.0002")]
rf = Decimal("0.00004")

sharpe_d = (mean(rets) - rf) / std_dev(rets)
sharpe_a = sharpe_d * Decimal("252").sqrt()
print("Sharpe daily  :", sharpe_d)
print("Sharpe annual ≈", sharpe_a)
```

### 3) Common pitfalls

> **Pitfall:** Calling `optimizer.sharpe_sortino_dd` a Sharpe calculator. It is a fitness aggregator over four scalars — compute the ratio yourself.
>
> **Pitfall:** Mixing daily and annual scales — daily Sharpe ≈ 0.06 looks terrible until you annualise ×√252.
>
> **Pitfall:** Subtracting Rf in the wrong scale (annual Rf against daily returns).
>
> **Pitfall:** Using σ that mixes return units — σ must be in the same period as Rp.

### 4) Key takeaways

- **Takeaway:** Sharpe = reward per unit of total risk; the CAL slope.
- **Takeaway:** Best for well-diversified portfolios.
- **Takeaway:** Annualise with ×√252 before comparing to other managers.
- **Takeaway:** Compute it in Decimal; the aggregator is for optimisation, not scoring.

## Lesson 4.2 — Treynor ratio

### 1) Concept

The **Treynor ratio** answers "reward per unit of *systematic* risk" by dividing the risk premium by the portfolio's beta instead of its σ:

```
Treynor = (Rp − Rf) / βp
```

Why would you drop total risk? For a **concentrated or undiversified book** — a single-sector fund, a high-conviction portfolio — σ is high partly from idiosyncratic bets the manager *deliberately* took. Punishing those bets (as Sharpe does) is unfair if the mandate is to take them. Treynor asks only: given the market exposure you carry, did you get paid? The units of Treynor are return per unit of beta — so the market portfolio itself has Treynor = `E(Rm) − Rf`.

Treynor and Sharpe can disagree: a fund can have a worse Sharpe (high total risk) yet a better Treynor (efficient use of market exposure). Both are "right" for their question; the analyst's job is choosing the question (Lesson 4.4). In India, a sectoral fund (banking, IT) is the classic Treynor case — nobody should score a banking fund purely on total risk.

### 2) Worked example

Fund A: Rp = 14%, β = 1.1, σ = 22%. Fund B: Rp = 12%, β = 0.9, σ = 15%. Rf = 6%.

```
Treynor_A = (0.14 − 0.06)/1.1 ≈ 0.0727
Treynor_B = (0.12 − 0.06)/0.9 ≈ 0.0667
Sharpe_A  = (0.14 − 0.06)/0.22 ≈ 0.3636
Sharpe_B  = (0.12 − 0.06)/0.15 = 0.40
```

Fund B wins on Sharpe (less total risk per unit of reward); Fund A wins on Treynor (better pay per unit of market risk). The "better" fund depends on the mandate — diversified investor? B. Concentrated-mandate manager? A.

```python
from decimal import Decimal

Rf = Decimal("0.06")
R_A, b_A, s_A = Decimal("0.14"), Decimal("1.1"), Decimal("0.22")
R_B, b_B, s_B = Decimal("0.12"), Decimal("0.9"), Decimal("0.15")

treynor_A = (R_A - Rf) / b_A
treynor_B = (R_B - Rf) / b_B
sharpe_A  = (R_A - Rf) / s_A
sharpe_B  = (R_B - Rf) / s_B

print("Treynor A/B:", treynor_A, treynor_B)   # ≈ 0.0727 / 0.0667
print("Sharpe  A/B:", sharpe_A, sharpe_B)     # ≈ 0.3636 / 0.4000
```

### 3) Common pitfalls

> **Pitfall:** Computing Treynor with a wrong β — β must come from the same measurement period as Rp (M2's regression on returns).
>
> **Pitfall:** Applying Treynor to a diversified fund when Sharpe is the question — the two ask different things.
>
> **Pitfall:** Forgetting β ≤ 0 flips the interpretation; short or inverse funds need care.
>
> **Pitfall:** Reporting Treynor without stating the β source and window.

### 4) Key takeaways

- **Takeaway:** Treynor = reward per unit of systematic (beta) risk.
- **Takeaway:** The right tool for concentrated/undiversified mandates.
- **Takeaway:** Sharpe and Treynor can disagree — the mandate decides which matters.
- **Takeaway:** Always state the β window and how β was estimated.

## Lesson 4.3 — Jensen's alpha & beta

### 1) Concept

**Jensen's alpha** asks the CAPM question directly: "after paying for the risk the manager's beta says they took, did they earn anything extra?" CAPM says an asset with beta β should earn `Rf + β(Rm − Rf)` (the SML of M3). Jensen's alpha is the *realised* return minus that fair compensation:

```
α = Rp − [Rf + βp·(Rm − Rf)]
```

If `α > 0`, the manager beat CAPM: they earned more than their beta justifies — genuine skill (or luck). If `α < 0`, they underdelivered for the risk they ran. Note the bracket is the SML expected return, so Jensen's alpha is literally "distance above/below the SML".

**Beta** here is the SML coordinate — the slope from M2's regression of fund returns on market returns. A fund with β = 1.2 is 20% riskier than the market; it must earn `Rf + 1.2(Rm − Rf)` just to break even on the SML. Alpha is the residual after that hurdle. Beware: alpha is measured against a *model* with *estimated* inputs — the CAPM benchmark is only as good as the estimated market portfolio and risk-free rate.

### 2) Worked example

Fund: Rp = 16%, β = 1.2. Market: Rm = 13%. Rf = 6%.

```
Fair return = Rf + β(Rm − Rf) = 0.06 + 1.2×(0.13 − 0.06) = 0.06 + 0.084 = 0.144
Jensen's α  = 0.16 − 0.144 = 0.016 → +1.6% per year
```

Positive alpha of +1.6%: the fund earned 1.6 points more than CAPM allowed for its beta — a stock-selection skill signal, though small relative to market noise.

```python
from decimal import Decimal

Rp = Decimal("0.16"); Rm = Decimal("0.13"); Rf = Decimal("0.06"); beta = Decimal("1.2")
fair = Rf + beta * (Rm - Rf)
alpha = Rp - fair
print("fair return:", fair)   # ≈ 0.144
print("Jensen alpha:", alpha) # ≈ 0.016
```

### 3) Common pitfalls

> **Pitfall:** Confusing regression-intercept alpha (M2) with Jensen's alpha. Jensen's subtracts the CAPM hurdle; the plain intercept does not.
>
> **Pitfall:** Using a beta estimated on a different window than the returns in Rp.
>
> **Pitfall:** Calling one year of positive alpha "skill" — test over longer windows and multiple regimes.
>
> **Pitfall:** Forgetting alpha inherits the CAPM's assumptions; it is a *benchmark*, not a fact.

### 4) Key takeaways

- **Takeaway:** Jensen's α = Rp − [Rf + β(Rm − Rf)] = distance above the SML.
- **Takeaway:** α > 0 → beat CAPM for the beta carried.
- **Takeaway:** β is the SML coordinate from M2's OLS regression.
- **Takeaway:** Alpha is benchmark-relative; report β, Rm, Rf, and the window.

## Lesson 4.4 — Choosing measures

### 1) Concept

Performance measurement is a *question-matching* exercise. Every ratio punishes or forgives a different kind of risk, so the correct tool depends on the portfolio's construction and the client's question:

| Question | Measure |
|---|---|
| Is the portfolio diversified? | Sharpe |
| Is it a focused/concentrated book? | Treynor |
| Did the manager beat CAPM? | Jensen's α |
| Total return vs index? | Information ratio (extension) |

The **information ratio** extends the family: `IR = (Rp − Rb)/TE` where Rb is a benchmark index and TE is *tracking error* (σ of the return *differences*). It measures "excess return over the benchmark per unit of deviation from it" — the standard tool for index funds and ETFs where the mandate is to hug an index, not beat it.

A professional **scorecard** reports all of these together with the raw numbers underneath: Rf source, β window, σ, benchmark, and the frequency (daily/annual). When you present to a client (M9), you do not dump ratios; you tell the client which ratio answers *their* question, why the others are not the deciding one, and what the numbers imply for forward expectations. A single ratio in isolation is how bad sales pitches are built; a ratio *with its assumptions* is how good analysis is built.

### 2) Worked example

A complete one-row scorecard for a mid-cap fund: Rp = 15%, Rf = 6%, β = 1.3, σ = 20%, Rm = 13%.

```
Sharpe   = (0.15 − 0.06)/0.20 = 0.45
Treynor  = (0.15 − 0.06)/1.3  ≈ 0.0692
Alpha    = 0.15 − [0.06 + 1.3×(0.13 − 0.06)] = 0.15 − 0.151 = −0.001 → −0.1%
```

Verdict: decent Sharpe (0.45) but *negative* alpha — the fund earned its keep via high beta (1.3) rather than stock skill. A client told only the Sharpe would miss the story; the alpha reveals the source of return was market risk, not selection.

```python
from decimal import Decimal

Rp, Rf, Rm, beta, sigma = Decimal("0.15"), Decimal("0.06"), Decimal("0.13"), Decimal("1.3"), Decimal("0.20")
sharpe  = (Rp - Rf) / sigma
treynor = (Rp - Rf) / beta
alpha   = Rp - (Rf + beta * (Rm - Rf))
print("Sharpe :", sharpe)    # 0.45
print("Treynor:", treynor)   # ≈ 0.0692
print("Alpha  :", alpha)     # ≈ −0.001
```

### 3) Common pitfalls

> **Pitfall:** Using one ratio for every question. Match the measure to the mandate (table above).
>
> **Pitfall:** Reporting the Sharpe without the α — Sharpe hides the *source* of return.
>
> **Pitfall:** Mixing benchmarks: Rm for CAPM vs a custom benchmark for IR must be stated explicitly.
>
> **Pitfall:** Presenting ratios without their inputs — a scorecard without Rf, β, and window is marketing, not analysis.

### 4) Key takeaways

- **Takeaway:** Sharpe → diversified; Treynor → concentrated; Jensen's α → CAPM skill; IR → benchmark tracking.
- **Takeaway:** Always publish the inputs (Rf, β, σ, window) with the ratios.
- **Takeaway:** A single ratio tells a partial story; a scorecard tells the truth.
- **Takeaway:** Explain to clients in terms of their question, not the Greek letters.

## Tantra Lab 4 — Sharpe & Treynor from the wheel

### Lab goal

Compute Sharpe, Treynor, and Jensen's alpha for a synthetic index strategy in Decimal, then score three funds and build the comparison table.

### Code

The verified core snippet is unchanged; the extension adds Treynor and Jensen's alpha on top of the same `sharpe()` helper.

```python
from decimal import Decimal
from tantra.quant import returns, mean, std_dev
from tantra_examples import SampleInstruments, synthetic_bars

# Compute Sharpe = (Rp - Rf) / σp exactly in Decimal.
# (The wheel's optimizer.sharpe_sortino_dd is a *fitness aggregator*, not a
#  Sharpe-from-returns function — do the ratio yourself.)
def sharpe(rets: list[Decimal], rf: Decimal) -> Decimal:
    return (mean(rets) - rf) / std_dev(rets)

rets = returns([b.close for b in synthetic_bars(SampleInstruments.NIFTY50, days=250, seed=42)])
print("Sharpe (daily):", sharpe(rets, Decimal("0.0001")))

# --- extend: Treynor and Jensen's alpha -------------------------------------
# Beta from M2's covariance recipe: Cov(strategy, market) / Var(market).
from tantra.quant import covariance_matrix

strategy = returns([b.close for b in synthetic_bars(SampleInstruments.NIFTY50, days=250, seed=42)])
market   = returns([b.close for b in synthetic_bars(SampleInstruments.NIFTY50, days=250, seed=7)])
panel = [[s, m] for s, m in zip(strategy, market)]
cov = covariance_matrix(panel)
beta = cov[0][1] / cov[1][1]

rf = Decimal("0.0001")
rm = mean(market)
rp = mean(strategy)

treynor = (rp - rf) / beta
alpha   = rp - (rf + beta * (rm - rf))

print("beta   :", beta)
print("Treynor:", treynor)
print("Alpha  :", alpha)
```

**Task:** extend the script to score three mutual funds (or three synthetic strategies) with Sharpe, Treynor, and alpha; build a comparison table in Excel; write which fund you'd recommend and why. Read `mutual_funds/04_portfolio_optimization.py` for the full scoring pipeline.

### Expected output

The script prints a daily Sharpe (a small Decimal, roughly 0.05–0.15 for seeded daily index data), then beta (near 1.0 when strategy and market are the same instrument — use distinct instruments for a more interesting beta), a Treynor, and a Jensen alpha in daily units. In the three-fund extension the table should rank funds differently by Sharpe vs Treynor in at least one case — that disagreement is the learning outcome.

### Hand-in checklist

- [ ] Sharpe, Treynor, alpha computed by hand-rolled Decimal helpers (no `sharpe_sortino_dd` misuse).
- [ ] Beta computed from the covariance matrix with the M2 recipe.
- [ ] Three-fund comparison table in Excel, all figures Decimal.
- [ ] One-paragraph recommendation naming the decisive measure.
- [ ] Notes on what `mutual_funds/04_portfolio_optimization.py` computes.

### Common errors

- **Using the aggregator as a Sharpe** — `optimizer.sharpe_sortino_dd(sharpe, sortino, pf, mdd)` blends four fitness floats; it is for the genetic loop, not for scoring. Keep the `sharpe()` helper.
- **Daily vs annual confusion** — report the frequency on every figure; annualise with ×√252 only where the label says so.
- **Wrong beta** — `cov[0][1]/cov[1][1]` needs the strategy in column 0 and the market in column 1, or beta comes out inverted.
- **Zip mismatch** — strategy and market series must have equal length.

## Practice problems

1. A fund returns 12% with σ = 18%, Rf = 5%. Compute the Sharpe ratio.
2. Same fund has β = 0.9; compute Treynor. If the market fund earns 10%, what is Jensen's alpha?
3. Why might a concentrated banking fund have a worse Sharpe but better Treynor than a diversified fund? Answer in two sentences.
4. A manager claims "Sharpe 1.1" without saying daily or annual. What must you ask before believing it?
5. The information ratio uses tracking error. What is tracking error, and for what kind of mandate is IR the decisive measure?
6. For a fund with Rp = 8%, Rf = 5%, β = 0.5, Rm = 11%: compute alpha and interpret the sign.
7. (Short code) Reproduce the Lab 4 snippet for RELIANCE (use `SampleInstruments.RELIANCE`, `seed=1`) and print its daily Sharpe.

### Solutions

1. Sharpe = (0.12 − 0.05)/0.18 ≈ 0.3889.
2. Treynor = (0.12 − 0.05)/0.9 ≈ 0.0778. Alpha = 0.12 − [0.05 + 0.9×(0.10 − 0.05)] = 0.12 − 0.095 = 0.025 (+2.5%).
3. The banking fund carries large idiosyncratic (sector) risk, so its σ is high and Sharpe suffers; its beta-driven systematic risk may still be paid well, so Treynor can beat the diversified fund. Different questions, different winners.
4. Ask whether it is daily, monthly, or annual — and what Rf was used and over what window.
5. Tracking error is the σ of the return differences versus a benchmark (Rp − Rb); IR is decisive for index-hugging mandates (index funds, ETFs).
6. Alpha = 0.08 − [0.05 + 0.5×(0.11 − 0.05)] = 0.08 − 0.08 = 0 — exactly fairly priced per CAPM.
7. Reuse the snippet with RELIANCE/seed=1; expect a small positive daily Sharpe in the 0.03–0.10 range depending on the seed.

## Quiz bank

| Question | A | B | C | D | Answer |
|---|---|---|---|---|---|
| Sharpe = | (Rp−Rf)/β | (Rp−Rf)/σp | Rp/σp | (Rp−Rm)/σp | B |
| Sharpe is the measure for | concentrated books | well-diversified portfolios | options | debt | B |
| Treynor = | (Rp−Rf)/σp | (Rp−Rf)/β | (Rp−Rf)·β | α/β | B |
| Treynor is preferred when the book is | diversified | concentrated | leveraged | cash | B |
| Jensen's alpha measures | total return | beat-CAPM skill | volatility | drawdown | B |
| A positive alpha means | above the SML | below the SML | beta > 1 | zero risk | A |
| Jensen's α is computed against | the CML | the SML/CAPM hurdle | the CAL | historical peak | B |
| The wheel's `sharpe_sortino_dd` is | a Sharpe calculator | a fitness aggregator | a beta estimator | a backtester | B |
| Daily Sharpe is annualised by | ×12 | ×√252 | ×252 | no change | B |
| The information ratio divides excess return by | σp | tracking error | beta | alpha | B |
| A beta of 1.2 means the fund is | safer than market | 20% riskier than market | riskless | short | B |
| Which input belongs in every scorecard? | the Rf and window | only the Sharpe | the fund's name | the logo | A |

## Glossary

- **Sharpe ratio** — `(Rp − Rf)/σp`; reward per unit of total risk.
- **Treynor ratio** — `(Rp − Rf)/β`; reward per unit of systematic risk.
- **Jensen's alpha** — `Rp − [Rf + β(Rm − Rf)]`; distance above/below the SML.
- **Beta** — OLS slope of fund returns on market returns; the SML coordinate.
- **Risk-free rate (Rf)** — T-bill/cash yield; the CAPM intercept.
- **Information ratio** — `(Rp − Rb)/TE`; excess return per unit of tracking error.
- **Tracking error** — σ of return differences versus a benchmark.
- **Fitness aggregator** — `sharpe_sortino_dd`: blends four fitness scalars for optimisation; not a Sharpe calculator.
- **Scorecard** — a table of performance measures plus their inputs (Rf, β, window, frequency).
- **CAPM** — the model `E(R) = Rf + β(Rm − Rf)` that alpha is measured against.

## Reading assignment

Work through IFMC item 38 (performance evaluation) and PGP T4(PM)-401/402 in the [reading list](../appendices/reading-list.md). Run `mutual_funds/04_portfolio_optimization.py` and compare its scoring to your hand-built table.

## Assessment reminder

This module feeds the fund-scorecard assignment (three funds, Excel + Decimal script) and the measure-selection quiz; keep the scorecard and recommendation memo in your journal for the [assessment plan](../front/assessment.md).

**Next:** [M5 — Derivatives: Forwards & Futures](m5-forwards-futures.md)
