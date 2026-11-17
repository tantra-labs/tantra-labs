# M3 — Portfolio Theory: Markowitz, CAL, SML & CML

> **Weeks 53–54 · 20 hrs · PLO-8 · Core:** IFMC items 26, 29–30; NIFM Ch 37; PGP T2-202

## Learning outcomes

- Compute portfolio expected return and variance for two or more assets.
- Explain diversification and the efficient frontier.
- Derive the CAL, CML, and SML lines and the capital-market line intuition.
- Use the Markowitz mean-variance framework.

## Prerequisites

- [M1](m1-statistics.md) and [M2](m2-correlation-regression.md) of Semester 4: mean, σ, covariance, correlation — portfolio theory is built entirely from those three ingredients.
- [M4 of Semester 3](../s3/m4-valuation-risk-return.md) (or equivalent): the concept of the risk-free asset (T-bills, repo rate) and risk premium.
- Basic algebra comfort: weighted averages and quadratic expressions.

## Lesson 3.1 — Portfolio return and variance

### 1) Concept

A **portfolio** is just a set of assets held in fixed proportions, called **weights** `w`, that sum to 1. If you hold 50% RELIANCE and 50% TCS, `w1 = 0.5`, `w2 = 0.5`. The portfolio's expected return is the weighted average of the assets' expected returns — there is no magic here, only averaging:

```
E(Rp) = w1·E(R1) + w2·E(R2)
Var(Rp) = w1²σ1² + w2²σ2² + 2·w1·w2·Cov(1,2)
```

The second formula is the heart of the whole course. Portfolio *variance* is NOT a weighted average of the asset variances — it also contains a `2·w1·w2·Cov(1,2)` term. When the two assets are less than perfectly correlated (`Cov < σ1σ2`), that term is small enough that the portfolio σ drops below the weighted average of the individual σs. That is **diversification**: risk you can "cancel away" by combining imperfectly-correlated assets.

The arithmetic intuition: RELIANCE (energy, commodity) and TCS (software exports, USD-sensitive) get hit by different news. When one wobbles, the other tends to be calm, so the portfolio wobbles less than either alone. The formula quantifies exactly how much less: it depends on Cov, not on belief.

### 2) Worked example

RELIANCE: E(R1) = 12%, σ1 = 20%. TCS: E(R2) = 10%, σ2 = 15%. Cov = 0.0150 (i.e. ρ = 0.5). Weights 50/50.

```
E(Rp) = 0.5×0.12 + 0.5×0.10 = 0.11 → 11%
Var(Rp) = 0.25×0.04 + 0.25×0.0225 + 2×0.5×0.5×0.015
        = 0.0100 + 0.005625 + 0.0075 = 0.023125
σp = √0.023125 ≈ 0.1521 → 15.2%
```

The weighted-average σ was `0.5×20% + 0.5×15% = 17.5%` — the portfolio σ of 15.2% is lower. Diversification's gift is 2.3 percentage points of risk, for free.

```python
from decimal import Decimal
from tantra.quant import std_dev

w1 = Decimal("0.5"); w2 = Decimal("0.5")
e1 = Decimal("0.12"); e2 = Decimal("0.10")
s1 = Decimal("0.20"); s2 = Decimal("0.15")
cov = Decimal("0.0150")

rp = w1 * e1 + w2 * e2
varp = (w1**2)*(s1**2) + (w2**2)*(s2**2) + 2*w1*w2*cov
print("Rp:", rp)                       # ≈ 0.11
print("σp:", varp.sqrt())              # ≈ 0.1521
print("weighted-avg σ:", w1*s1 + w2*s2)  # ≈ 0.175 — diversified σ is lower
```

### 3) Common pitfalls

> **Pitfall:** Averaging σs and calling it portfolio risk. The Cov term is the whole point; drop it and you overstate risk.
>
> **Pitfall:** Using correlation where the formula needs covariance. `Cov = ρ·σ1·σ2` — convert before plugging in.
>
> **Pitfall:** Forgetting weights must sum to 1. With two assets, `w2 = 1 − w1`.
>
> **Pitfall:** Mixing percent and decimal: 12% is `Decimal("0.12")`, not 12, or every term is off by 100×.

### 4) Key takeaways

- **Takeaway:** Portfolio return is a weighted average; portfolio variance is not.
- **Takeaway:** The `2·w1·w2·Cov` term is where diversification lives.
- **Takeaway:** Lower correlation → bigger diversification benefit.
- **Takeaway:** All math in Decimal; `σp = √Var(Rp)`.

## Lesson 3.2 — The efficient frontier (Markowitz)

### 1) Concept

Now sweep every possible weight combo of the two assets: (100/0), (90/10), ..., (0/100). Each combo gives one (σp, E(Rp)) point. Plot all of them and you get a curved arc — the **feasible set**. The upper half of that arc is the **efficient frontier** (Markowitz, 1952): for any given level of risk, the frontier portfolio has the highest return; for any given return, the lowest σ.

The **minimum-variance portfolio** sits at the leftmost tip of the frontier — the single mix with the smallest possible σ. Every portfolio *below* the frontier is **dominated**: there is some other mix with the same risk and more return, or the same return and less risk. A rational investor never holds a dominated portfolio — yet most real-world portfolios are dominated because people hold too few assets or too much of their own company's stock.

Diversification across many assets pushes the frontier further left. With all of NIFTY's 50 stocks, idiosyncratic (company-specific) risk nearly disappears and only **systematic risk** (the market's own swings) remains. That residue is what CAPM prices — it is the bridge to Lesson 3.3.

### 2) Worked example

Reuse Lesson 3.1 numbers and compute the frontier point at w1 = 0.3.

```
E(Rp) = 0.3×0.12 + 0.7×0.10 = 0.106 → 10.6%
Var(Rp) = 0.09×0.04 + 0.49×0.0225 + 2×0.3×0.7×0.015
        = 0.0036 + 0.011025 + 0.0063 = 0.020925
σp = √0.020925 ≈ 0.1447 → 14.5%
```

Compare to the 50/50 point (11% / 15.2%): moving weight toward TCS lowered both return and σ. Different investors pick different frontier points — the frontier ranks choices, but your risk tolerance chooses.

```python
from decimal import Decimal

w1 = Decimal("0.3"); w2 = Decimal("0.7")
e1 = Decimal("0.12"); e2 = Decimal("0.10")
s1 = Decimal("0.20"); s2 = Decimal("0.15")
cov = Decimal("0.0150")

rp = w1 * e1 + w2 * e2
varp = (w1**2)*(s1**2) + (w2**2)*(s2**2) + 2*w1*w2*cov
print("Rp:", rp)              # ≈ 0.106
print("σp:", varp.sqrt())     # ≈ 0.1447
```

### 3) Common pitfalls

> **Pitfall:** Confusing "feasible set" (all combos) with "efficient frontier" (the top-left envelope).
>
> **Pitfall:** Forgetting the frontier is drawn in (σ, E(R)) space, not (time, price).
>
> **Pitfall:** Calling the minimum-variance portfolio "the best" — it is the *least risky*, not the best for a risk-taker.
>
> **Pitfall:** Believing the frontier requires perfect forecasts. The *math* is exact; the *inputs* (E(R), σ, Cov) are estimates.

### 4) Key takeaways

- **Takeaway:** The efficient frontier = best (σ, E(R)) trade-offs among all weightings.
- **Takeaway:** Dominated portfolios (below the frontier) are never rational.
- **Takeaway:** The minimum-variance portfolio is the leftmost tip.
- **Takeaway:** With many assets, idiosyncratic risk washes out; systematic risk remains.

## Lesson 3.3 — CAL, CML and SML

### 1) Concept

The frontier is built from risky assets only. Now add the **risk-free asset** (a T-bill, or cash at the repo rate). Mixing any risky portfolio P with the risk-free asset sweeps out a straight line — the **Capital Allocation Line (CAL)** — with intercept Rf and slope equal to P's **Sharpe ratio** `(E(Rp) − Rf)/σp`. The slope is the reward per unit of risk; the steeper, the better.

If every investor is rational and well-informed, they all pick the *same* risky portfolio — the market portfolio M — and the CAL for M is the **Capital Market Line (CML)**: `E(R) = Rf + ((E(Rm) − Rf)/σm)·σ`. The CML prices *efficient portfolios*: combinations of the market and the risk-free asset.

The **Security Market Line (SML)** is different: it comes from the **CAPM** (Capital Asset Pricing Model) and prices *individual assets and portfolios* against their **beta**, not their σ:

```
E(Ri) = Rf + βi·(E(Rm) − Rf)
```

Every *fairly priced* asset sits on the SML. An asset plotted *above* the SML gives more return than its beta justifies — it is undervalued, with positive alpha; one below is overvalued. Notice: the CML uses σ (total risk), the SML uses β (systematic risk only). Under CAPM, only systematic risk is rewarded, because idiosyncratic risk can be diversified away (Lesson 3.2).

### 2) Worked example

Rf = 6%, E(Rm) = 14%, σm = 18%. Compute the CML-expected return for σ = 12%, and the SML-expected return for a stock with β = 1.2.

```
CML: E(R) = 0.06 + ((0.14−0.06)/0.18)×0.12 = 0.06 + 0.4444×0.12 ≈ 0.1133 → 11.33%
SML: E(Ri) = 0.06 + 1.2×(0.14−0.06) = 0.06 + 0.096 = 0.156 → 15.6%
```

A stock with β = 1.2 *deserves* 15.6%. If it actually returns 18%, it sits above the SML — positive alpha of 2.4%, a buy candidate. If it returns 13%, it sits below — overpriced.

```python
from decimal import Decimal

Rf = Decimal("0.06"); E_Rm = Decimal("0.14"); sig_m = Decimal("0.18")

sig_p = Decimal("0.12")
cml = Rf + ((E_Rm - Rf) / sig_m) * sig_p
print("CML @ σ=12%:", cml)         # ≈ 0.1133

beta = Decimal("1.2")
sml = Rf + beta * (E_Rm - Rf)
actual = Decimal("0.18")
print("SML:", sml)                 # ≈ 0.156
print("alpha:", actual - sml)      # ≈ +0.024 → above the line, undervalued
```

### 3) Common pitfalls

> **Pitfall:** Confusing CML and SML. CML: σ on the x-axis, efficient portfolios. SML: β on the x-axis, every fairly-priced asset.
>
> **Pitfall:** Saying "the CML prices individual stocks" — it prices portfolios along the market-plus-risk-free line.
>
> **Pitfall:** Treating alpha as guaranteed profit. Alpha is measured against a model; the model's inputs are estimates.
>
> **Pitfall:** Forgetting the market risk premium is `E(Rm) − Rf`, not `E(Rm)`.

### 4) Key takeaways

- **Takeaway:** CAL = risky P mixed with the risk-free asset; its slope is the Sharpe ratio.
- **Takeaway:** CML = the CAL of the market portfolio; prices efficient portfolios.
- **Takeaway:** SML/CAPM prices assets by β; above the line = undervalued (alpha).
- **Takeaway:** CML rewards total risk; SML rewards only systematic risk.

## Lesson 3.4 — Behavioral finance overlay

### 1) Concept

Markowitz assumes investors are rational mean-variance optimisers. Real investors are not. **Loss aversion** (Kahneman & Tversky) makes a ₹10,000 loss hurt about twice as much as a ₹10,000 gain pleases, so investors dump winners too early and cling to losers — the "disposition effect". **Herding** makes fund managers buy whatever is rallying because "nobody got fired for buying NIFTY"; this inflates crowded trades. **Overconfidence** makes retail day-traders churn portfolios that lose to the index after costs.

These biases deform the frontier in practice: under-diversification (owning only one's employer's stock), home bias (only Indian equities), and reluctance to hold the risk-free asset. The S2-M7 psychology lessons bridge directly: the same loss-aversion engine that drives stop-loss hesitation in trading also pushes a rational frontier pick to the wrong corner.

The professional's defence is *process*: written investment policy, rebalancing on a calendar, pre-committed rebalancing bands, and ignoring your own portfolio's daily P&L noise. Rules beat willpower — which is exactly why the Tantra stack encodes risk limits as code, not as intentions (see M7).

### 2) Worked example

A behavioural benchmark: Investor X holds 80% in a single stock, Investor Y holds a 5-stock equal-weight portfolio. Both stocks have σ = 25% and pairwise ρ = 0.3. Approximate the single-stock σ (25%) vs the portfolio σ:

```
σp² = Σ wᵢ²σᵢ² + 2ΣΣ wᵢwⱼρσᵢσⱼ,  w = 0.2 each
σp² = 5×0.04×0.0625 + 2×10×0.04×0.3×0.0625
    = 0.0125 + 0.015 = 0.0275
σp ≈ 16.6%  vs single-stock 25%
```

X accepts 25% risk; Y gets ~16.6% for the same expected return — the 80/20 home-bias portfolio is *dominated* in the Lesson 3.2 sense. Behavioural biases are real; they are also expensive.

```python
from decimal import Decimal

sig = Decimal("0.25"); rho = Decimal("0.3")
w = Decimal("0.2"); n = Decimal(5)

varp = n * w**2 * sig**2 + 2 * (n * (n-1) / 2) * w**2 * rho * sig**2
print("σp ≈", varp.sqrt())     # ≈ 0.166
```

### 3) Common pitfalls

> **Pitfall:** Believing "I am the exception". Everyone's loss aversion shows up in their P&L; plan for it.
>
> **Pitfall:** Over-weighting the recent winner (herding) and calling it analysis.
>
> **Pitfall:** Confusing diversification with owning 20 *correlated* bank stocks. Correlation, not count, does the work.
>
> **Pitfall:** Letting behavioural rules replace the math — process complements the frontier; it does not replace it.

### 4) Key takeaways

- **Takeaway:** Loss aversion, herding, and overconfidence deform real portfolios away from the frontier.
- **Takeaway:** Behavioural biases are measurable and expensive (the 80/20 example).
- **Takeaway:** Correlation, not count, is what diversifies.
- **Takeaway:** Written process and rules beat willpower.

## Tantra Lab 3 — Two-asset frontier

### Lab goal

Sweep the weight `w` across the full 0→1 range and plot the two-asset frontier, locating the minimum-variance portfolio from real wheel data.

### Code

The verified core snippet is unchanged; the extension wraps the single-point computation in a weight sweep and reports the minimum-variance weight.

```python
from decimal import Decimal
from tantra.quant import returns, mean, std_dev, covariance_matrix
from tantra_examples import SampleInstruments, synthetic_bars

a = returns([b.close for b in synthetic_bars(SampleInstruments.RELIANCE, days=250, seed=1)])
b = returns([b.close for b in synthetic_bars(SampleInstruments.TCS,      days=250, seed=2)])

w = Decimal("0.5")
rp = w * mean(a) + (Decimal(1) - w) * mean(b)
cov = covariance_matrix([[x, y] for x, y in zip(a, b)])[0][1]
varp = (w**2) * (std_dev(a) ** 2) + ((Decimal(1) - w) ** 2) * (std_dev(b) ** 2) + 2 * w * (Decimal(1) - w) * cov
print("Rp:", rp, "σp:", varp.sqrt())

# --- extend: sweep w from 0 to 1 in steps of 0.1, track min-variance mix ---
min_sigma = None
min_w = None
for i in range(11):
    ww = Decimal(i) / Decimal(10)
    rpp = ww * mean(a) + (Decimal(1) - ww) * mean(b)
    varpp = (ww**2) * (std_dev(a) ** 2) + ((Decimal(1) - ww) ** 2) * (std_dev(b) ** 2) + 2 * ww * (Decimal(1) - ww) * cov
    sp = varpp.sqrt()
    print(f"w={ww}: Rp={rpp} σp={sp}")
    if min_sigma is None or sp < min_sigma:
        min_sigma, min_w = sp, ww
print("min-variance w:", min_w, "σp:", min_sigma)
```

**Task:** run the sweep, plot the frontier curve (σp on x, Rp on y), and mark the minimum-variance portfolio. Read `tantra-examples/examples/12_portfolio_allocation.py` for the full machinery.

### Expected output

The script prints 11 rows of (w, Rp, σp). The frontier arcs left and up as w moves; the minimum-variance portfolio sits near the leftmost point (typically a weight between 0.2 and 0.5 for seeded RELIANCE/TCS data, where the diversified mix beats either stock alone on σ). The final lines report the winning w and its σp.

### Hand-in checklist

- [ ] Frontier table (11 rows) with Rp and σp in Decimal.
- [ ] Frontier chart drawn, axes labelled (σp, Rp).
- [ ] Minimum-variance portfolio identified and marked.
- [ ] One paragraph: which weight dominates 100% RELIANCE and 100% TCS, and why.
- [ ] Notes on what `12_portfolio_allocation.py` does differently.

### Common errors

- **`float` in the loop** — `Decimal(i)/Decimal(10)`; do not write `i/10` which yields a float and breaks the Decimal chain.
- **Indexing the covariance matrix** — `covariance_matrix(panel)[0][1]` is Cov(a,b); `[1][0]` is the same value but `[0][0]` is Var(a).
- **Zip length mismatch** — both return series come from `days=250`, so both have 249 entries; changing one `days=` breaks the zip.
- **Reading the plot backwards** — the frontier's x-axis is risk; lower is left, and left is better at a given return.

## Practice problems

1. A: E(R) = 10%, σ = 20%. B: E(R) = 8%, σ = 10%. Cov = 0.005. Compute E(Rp) and σp for wA = 0.6. Compare σp to the weighted-average σ.
2. What weight on A minimises variance in problem 1? (Hint: differentiate `Var(Rp)` with respect to wA, or sweep.)
3. Rf = 5%, E(Rm) = 13%. What is the SML-required return for β = 1.5? If the stock returns 15%, is it above or below the SML — and what is its alpha?
4. Explain in two sentences why CML uses σ while SML uses β.
5. A "diversified" portfolio holds 10 bank stocks with pairwise ρ = 0.85. Does it diversify well? Justify with one line of math intuition.
6. The CAL for a portfolio with E(Rp) = 12%, σp = 15%, Rf = 5%: what is the slope? What is that slope called?
7. Give one behavioural bias and one process rule that counters it in portfolio construction.
8. (Short code) Reproduce the Lesson 3.1 two-asset example for w = 0.4 and print both Rp and σp.

### Solutions

1. E(Rp) = 0.6×0.10 + 0.4×0.08 = 0.092 (9.2%). Var = 0.36×0.04 + 0.16×0.01 + 2×0.6×0.4×0.005 = 0.0144+0.0016+0.0024 = 0.0184 → σp ≈ 0.1356 (13.6%) vs weighted-avg 0.6×20+0.4×10 = 16% — diversification saved ~2.4 pts.
2. Set d/dw [w²σA² + (1−w)²σB² + 2w(1−w)Cov] = 0 → 2w·0.04 − 2(1−w)·0.01 + 2(1−2w)·0.005 = 0 → 0.08w − 0.02 + 0.02w + 0.01 − 0.02w = 0 → 0.08w = 0.01 → w = 0.125. Sweeping in code should agree.
3. SML = 0.05 + 1.5×0.08 = 0.17 (17%). Stock returns 15% < 17% → below the line, alpha = −2% (overvalued).
4. The CML prices efficient portfolios whose total risk matters to holders; the SML prices individual assets where only systematic (undiversifiable) risk is rewarded because idiosyncratic risk can be diversified away.
5. Poorly. With ρ ≈ 0.85 the covariance term dominates; the portfolio σ stays close to a single bank stock's σ. Count is no substitute for low correlation.
6. Slope = (0.12−0.05)/0.15 = 0.4667 — that slope is the Sharpe ratio of the risky portfolio.
7. Example: loss aversion → counter with a written rebalancing schedule and stop rules executed by code, not mood. (Any consistent bias + counter-process pair is acceptable.)
8. wA = 0.4 → E(Rp) = 0.088, Var = 0.16×0.04+0.36×0.01+2×0.4×0.6×0.005 = 0.0064+0.0036+0.0024 = 0.0124 → σp ≈ 0.1114.

## Quiz bank

| Question | A | B | C | D | Answer |
|---|---|---|---|---|---|
| Portfolio variance always contains the term | w1w2Cov | w1²w2² | Rf | β | A |
| Diversification works because Cov is | larger than σ1σ2 | below σ1σ2 | zero always | equal to β | B |
| The efficient frontier is the | bottom envelope | top-left envelope | line from Rf | regression line | B |
| A dominated portfolio | beats the frontier | is below the frontier | has zero risk | is on the SML | B |
| The minimum-variance portfolio has | highest return | smallest σ | beta = 1 | zero alpha | B |
| The CAL's slope is the | SML beta | Sharpe ratio | Treynor ratio | p-value | B |
| The CML mixes the market with | any stock | the risk-free asset | gold | the sector index | B |
| The SML plots expected return against | σ | β | weight | skewness | B |
| CAPM's market risk premium is | E(Rm) | E(Rm) − Rf | Rf × β | α | B |
| An asset above the SML is | overvalued | undervalued (positive alpha) | riskless | correlated | B |
| CML uses σ because it prices | individual stocks | efficient portfolios | derivatives | debt | B |
| Loss aversion means losses hurt | less than gains | about twice as much as gains | zero | the same as gains | B |

## Glossary

- **Weight (w)** — fraction of capital in an asset; weights sum to 1.
- **Portfolio variance** — `w1²σ1² + w2²σ2² + 2w1w2Cov`; includes the co-movement term.
- **Diversification** — risk reduction from combining less-than-perfectly-correlated assets.
- **Efficient frontier** — the best (σ, E(R)) trade-offs over all weightings.
- **Minimum-variance portfolio** — the mix with the smallest possible σ.
- **Dominance** — a portfolio is dominated if another has ≥ return at ≤ risk.
- **CAL** — straight line mixing a risky portfolio with the risk-free asset.
- **Sharpe ratio** — `(E(Rp) − Rf)/σp`; the CAL's slope.
- **CML** — the CAL for the market portfolio.
- **SML** — CAPM line `E(R) = Rf + β(E(Rm) − Rf)` pricing assets by beta.
- **CAPM** — the model that only systematic risk is rewarded.
- **Alpha** — distance above the SML; positive = undervalued.
- **Loss aversion** — losses hurt ~2× more than equal gains please.

## Reading assignment

Study IFMC items 26, 29–30 (portfolio theory and CAPM), NIFM Chapter 37, and PGP T2-202 in the [reading list](../appendices/reading-list.md). Then run `tantra-examples/examples/12_portfolio_allocation.py` and compare its full machinery to this module's two-asset sweep.

## Assessment reminder

This module feeds the portfolio-theory worksheet (including your frontier chart) and the CAL/CML/SML quiz; file the chart and the sweep output in your journal for the [assessment plan](../front/assessment.md).

**Next:** [M4 — Performance Measurement](m4-performance-measurement.md)
