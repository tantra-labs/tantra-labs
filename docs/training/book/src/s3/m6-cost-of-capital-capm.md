# M6 — Cost of Capital, CAPM & WACC

> **Weeks 41–42 · 16 hrs · PLO-7, PLO-8 · Core:** IFMC items 40, 42, 57–58; PGP T2-202

## Learning outcomes

- Decode the cost of debt (Kd), equity (Ke), and preference (Kp).
- Explain CAPM: `E(R) = Rf + β · (E(Rm) − Rf)`.
- Build a WACC with stated assumptions and sanity checks.
- State the three forms of market efficiency and their implications.
- Compute Ke, Kd, Kp, and WACC in `Decimal` with every assumption written
  down.

## Prerequisites

- [M5 — Time Value of Money & Capital Budgeting](m5-tvm-capital-budgeting.md):
  discounting mechanics — this module supplies the *rate* those mechanics need.
- [M4 — Ratio Analysis & DuPont](m4-ratios-dupont.md): the firm's capital
  structure (D/E) that sets WACC's weights.
- [M1 — Economics for Securities Markets](m1-economics.md): the repo rate and
  G-sec yield — the risk-free anchor for CAPM.
- [S2-M4 — Indicators math](../s2/m4-indicators-math.md): not needed for the
  math, but the *beta as sensitivity* idea will recur in S4-M2 regression.

## Lesson 6.1 — Cost of debt (Kd)

### 1) Concept

The **cost of debt** is what the firm pays to borrow. **Pre-tax Kd** is best
read as the **yield to maturity** on the firm's outstanding bonds — the rate
that makes the bond's promised coupons and principal equal its market price
(an M5 PV computation). Risky firms pay more: the **credit spread** over the
government bond rate is the market's price for default risk.

The tax twist: interest is **tax-deductible** — a rupee of interest reduces
taxable profit by a rupee, saving `t` rupees of tax. So the *effective* cost
of debt to the firm is lower than the coupon:

```
After-tax Kd = Pre-tax Kd × (1 − tax rate)
```

Example: borrow at 9% with a 25% tax rate — after-tax cost 9% × 0.75 = 6.75%.
That is the rate that enters WACC. Note the asymmetry: equity dividends are
*not* tax-deductible, which is one structural reason debt is cheaper than
equity for a healthy firm.

### 2) Worked example

A ₹1,000 bond pays ₹90 a year for 5 years and matures at ₹1,000. If it sells at
par today, pre-tax Kd ≈ 9%. Compute after-tax at 25%:

```python
from decimal import Decimal
pre_tax_kd = Decimal("0.09"); tax = Decimal("0.25")
after_tax_kd = pre_tax_kd * (Decimal(1) - tax)
print("After-tax Kd:", (after_tax_kd * 100).quantize(Decimal("0.01")), "%")
# A riskier firm pays a 2% credit spread over a 7% government rate:
g_sec = Decimal("0.07"); spread = Decimal("0.02")
risky_kd = g_sec + spread
print("Pre-tax Kd (risky):", (risky_kd * 100).quantize(Decimal("0.01")), "%")
```

Answer: after-tax Kd = 6.75%. A firm with a 2% credit spread over a 7% G-sec
has pre-tax Kd = 9%, after-tax 6.75% at the same 25% tax rate. The state
effectively subsidises 25% of every interest rupee.

### 3) Common pitfalls

> **Pitfall:** Using the *coupon* as Kd when the bond trades away from par —
> the yield to maturity is the market's rate. Using after-tax Kd in WACC but
> pre-tax in the decision memo without saying which. Forgetting that a firm
> with no bonds must *estimate* Kd (peer spreads), and stating that estimate as
> an assumption.

### 4) Key takeaways

- **Takeaway:** Pre-tax Kd = yield to maturity on the firm's debt.
- **Takeaway:** After-tax Kd = pre-tax × (1 − t) — the tax shield is real.
- **Takeaway:** Credit spreads price default risk; risky debt costs more.

## Lesson 6.2 — Cost of equity via CAPM

### 1) Concept

Equity has no promised coupon, so its cost must be *estimated*. The standard
model is **CAPM (Capital Asset Pricing Model)**:

```
Ke = Rf + β · (Rm − Rf)
```

- **Rf (risk-free rate)** — what you earn with zero default risk; India's
  10-year G-sec yield (≈7%) is the usual anchor.
- **β (beta)** — the stock's *systematic* risk sensitivity: how strongly the
  stock moves with the market. β = 1 moves with the market; β = 1.5 amplifies
  (rises/falls 1.5% per 1% market move); β = 0.7 dampens.
- **Rm − Rf (market risk premium)** — the extra return the market demands for
  holding risky equity over safe bonds (historically ~6–8% for India; the
  number is a judgement, not a fact).

**Beta estimation** — the regression of the stock's returns on the market's
returns (formalised in S4-M2):

```
β = Cov(Ri, Rm) / Var(Rm)
```

High-beta stocks (banks, metals, real estate) are "market-enders": they fall
more in a crash and rise more in a rally. Low-beta names (FMCG, utilities)
buffer the market. The CAPM says investors are paid for *beta risk only* —
diversifiable (company-specific) risk earns no premium because it can be
diversified away.

### 2) Worked example

Rf = 7%, market risk premium 7%, β 1.2:

```python
from decimal import Decimal
rf = Decimal("0.07"); mrp = Decimal("0.07"); beta = Decimal("1.2")
ke = rf + beta * mrp
print("Ke:", (ke * 100).quantize(Decimal("0.01")), "%")
# Compare three betas at the same Rf and MRP
for b in (Decimal("0.7"), Decimal("1.0"), Decimal("1.5")):
    print("β", b, "→ Ke", ((rf + b * mrp) * 100).quantize(Decimal("0.01")), "%")
```

Answer: Ke = 14.0% for β 1.2. The family: β 0.7 → 11.9%, β 1.0 → 14.0%, β 1.5 →
17.5%. The market pays more for more systematic risk — that is the whole CAPM
trade: return demanded = risk-free + risk × price-of-risk.

### 3) Common pitfalls

> **Pitfall:** Using a 3-month T-bill and a 10-year G-sec in the same
> equation (mismatched horizons) — pick a consistent Rf and state it. Quoting
> a beta from one website without noting the estimation window and market
> index (Nifty vs BSE500 betas differ). Treating a *historical* beta as a
> fact about the future — betas drift as businesses change.

### 4) Key takeaways

- **Takeaway:** Ke = Rf + β(Rm − Rf); each input is a stated assumption.
- **Takeaway:** β = Cov(Ri,Rm)/Var(Rm); systematic risk earns the premium,
  diversifiable risk does not.
- **Takeaway:** High beta amplifies both directions — risk and reward are the
  same coin.

## Lesson 6.3 — Cost of preference (Kp)

### 1) Concept

**Preference shares** pay a *fixed* dividend, ranked above equity (and below
debt) in a liquidation. Because the dividend is fixed and typically perpetual,
a preference share is priced exactly like a perpetuity (Lesson 5.1) — and
solving for the rate gives:

```
Kp = Dp / P0
```

where **Dp** is the fixed annual preference dividend and **P0** the current
market price. If a ₹100 preference share pays ₹10 a year and trades at ₹125,
Kp = 10/125 = 8%. Unlike debt, preference dividends are *not* tax-deductible,
so there is no (1−t) adjustment. Like debt, it is a fixed obligation: skipped
preference dividends are arrears that must eventually be paid before ordinary
dividends — a real, if junior, claim on cash.

### 2) Worked example

```python
from decimal import Decimal
dp = Decimal("10"); p0 = Decimal("125")
kp = dp / p0
print("Kp:", (kp * 100).quantize(Decimal("0.01")), "%")
# If the same share trades at ₹80 (distressed), the cost to the firm is higher
print("Kp at ₹80:", ((dp / Decimal("80")) * 100).quantize(Decimal("0.01")), "%")
```

Answer: Kp = 8.0% at ₹125; 12.5% at ₹80. Same dividend, different price — the
market is demanding a higher return on the risky preference, and that higher
return is the *cost* to the issuing firm of keeping this capital. This
price-inverse-yield relationship repeats everywhere in finance.

### 3) Common pitfalls

> **Pitfall:** Applying the (1−t) tax shield to preference dividends — only
> interest gets it. Using the *par* value instead of the *market* price —
> Kp is about what the market demands today, not what the paper says.
> Forgetting that cumulative preference arrears are a real claim on future
> cash.

### 4) Key takeaways

- **Takeaway:** Kp = Dp / P0 — a perpetuity rate, no tax shield.
- **Takeaway:** Price falls → market-required return rises → firm's cost
  rises.
- **Takeaway:** Preference sits between debt and equity in risk and claim.

## Lesson 6.4 — WACC

### 1) Concept

Firms fund with a mix of debt (D), preference (P), and equity (E). **WACC
(weighted average cost of capital)** is the blended rate:

```
WACC = (E/V)·Ke + (D/V)·Kd·(1−t) + (P/V)·Kp
```

with **V = E + D + P**. Two disciplines:

1. **Weights at market values, not book values** — what the capital *costs* to
   replace, not what the balance sheet says it cost historically. Equity market
   cap = price × shares; debt at market where observable.
2. **Every assumption stated** — beta source and window, risk-free rate,
   market risk premium, tax rate, weights and their dates. A WACC without its
   assumptions sheet is a number, not an analysis.

**Sanity checks:** WACC must sit *between* Kd (cheapest, tax-shielded) and Ke
(most expensive) — a WACC below Kd or above Ke means a weights error. For a
typical Indian large cap: Kd ≈ 6.75% after tax, Ke ≈ 13–14%, WACC ≈ 11–12%.
WACC is the discount rate for M5's NPV and M7's FCFF/DCF — the single most
sensitive input in equity valuation.

### 2) Worked example

Equity ₹700 crore, debt ₹250 crore, preference ₹50 crore; Ke 13%, pre-tax Kd
9%, Kp 10%, tax 25%:

```python
from decimal import Decimal
def wacc(ke, kd, kp, e, d, p, tax):
    v = e + d + p
    return (e / v) * ke + (d / v) * kd * (Decimal(1) - tax) + (p / v) * kp
print("WACC:", (wacc(ke=Decimal("0.13"), kd=Decimal("0.09"), kp=Decimal("0.10"),
                     e=Decimal("700"), d=Decimal("250"), p=Decimal("50"),
                     tax=Decimal("0.25")) * 100).quantize(Decimal("0.01")), "%")
```

Answer: WACC = (0.70 × 13) + (0.25 × 6.75) + (0.05 × 10) = 9.1 + 1.6875 + 0.5 =
**11.29%**. Sanity check: 6.75% < 11.29% < 13% — inside the corridor. The
weights (70/25/5) are market values; if the same weights used book equity, the
answer could differ by over a point — which is why the assumptions sheet
matters.

### 3) Common pitfalls

> **Pitfall:** Using book-value weights — WACC becomes historical, not
> economic. Forgetting the (1−t) on the debt leg only. Forgetting preference
> entirely when it exists (the P/V term). Never stating the assumptions —
> a WACC is only as good as its stated inputs.

### 4) Key takeaways

- **Takeaway:** WACC = (E/V)Ke + (D/V)Kd(1−t) + (P/V)Kp, V = E + D + P.
- **Takeaway:** Market-value weights; state every input on an assumptions
  sheet.
- **Takeaway:** Sanity-check: Kd < WACC < Ke always.

## Lesson 6.5 — Market efficiency

### 1) Concept

The **efficient market hypothesis (EMH)** asks: what information is already in
the price? Three forms:

- **Weak form:** prices reflect *past prices and volume*. If true, technical
  analysis cannot earn abnormal returns from charts alone. (The CFTe/TA
  tradition you studied in S2 holds the opposite premise — know both sides and
  test, don't assume.)
- **Semi-strong form:** prices reflect *all public information* — results,
  announcements, news. If true, reading the annual report cannot beat the
  market unless you find what others missed.
- **Strong form:** prices reflect *everything*, including private/insider
  information. Almost nobody claims this; insider-trading law exists precisely
  because private information is not in the price.

**Implications:** markets are *mostly* efficient — information moves into
prices quickly — but pockets of inefficiency exist: small caps with thin
coverage, event-driven dislocations, behavioural overreactions, and companies
the market has simply not looked at. **The analyst's job is finding the pockets
where prices are wrong** — that is exactly what M7's valuation methods are
*for*: a DCF says "the price is X but my value is Y" and the gap is the edge.
If you believe in perfect efficiency, you believe in no edge; the entire
profession of fundamental analysis is a bet against *perfect* efficiency.

### 2) Worked example

A quick price-reaction study in `Decimal`: on a public result announcement, the
market adjusted *before* the news day (information leaked/anticipated) or
*after* (slow):

```python
from decimal import Decimal
pre_announce = Decimal("100")
# Case 1: price already 108 the day before (information was in)
day_minus1 = Decimal("108")
# Case 2: price still 100 on the day, 106 after (slow reaction)
announce_day = Decimal("100"); post = Decimal("106")
print("Case 1 — moved before:", ((day_minus1 - pre_announce) / pre_announce * 100).quantize(Decimal("0.01")), "%")
print("Case 2 — moved after:", ((post - announce_day) / announce_day * 100).quantize(Decimal("0.01")), "%")
```

Answer: Case 1 shows a 8% pre-news move (semi-strong efficiency working /
information leaking), Case 2 a 6% post-news drift (inefficiency — a window an
analyst could exploit). These are *opposite* readings of market efficiency, and
an analyst's job is to recognise which regime a stock is in.

### 3) Common pitfalls

> **Pitfall:** Declaring "the market is efficient, so analysis is pointless"
> — that is the strong form, which even EMH proponents rarely hold. Or the
> mirror error: "I found a cheap stock, so the market is wrong" — sometimes
> the stock is cheap for a reason (the M3/M4 red flags). Confusing *fast*
> price adjustment with *correct* adjustment.

### 4) Key takeaways

- **Takeaway:** Weak = past prices; semi-strong = public info; strong =
  everything (a strawman nobody invests by).
- **Takeaway:** Markets are mostly efficient; the analyst hunts the pockets
  that are not.
- **Takeaway:** A valuation gap is a hypothesis, not a conclusion — check the
  red flags first.

## Tantra Lab 6 — WACC in Decimal

### Lab goal

Prove the WACC arithmetic is exact and *self-checking*: the computed WACC must
lie strictly between after-tax Kd and Ke, and the weights must sum to one —
the two sanity checks that catch errors before the number ever reaches a DCF.

### Code

```python
from decimal import Decimal

def wacc(ke, kd, kp, e, d, p, tax):
    v = e + d + p
    return (e / v) * ke + (d / v) * kd * (Decimal(1) - tax) + (p / v) * kp

print(wacc(ke=Decimal("0.13"), kd=Decimal("0.09"), kp=Decimal("0.10"),
          e=Decimal("700"), d=Decimal("250"), p=Decimal("50"), tax=Decimal("0.25")))
```

**Task:** estimate WACC for your S3-M2 shortlist company. State every assumption
in a "WACC assumptions" sheet. Cross-check the result against a peer's WACC.

### Expected output

```
0.112875
```

WACC = **11.2875%**. Sanity checks: after-tax Kd = 9% × 0.75 = 6.75% < 11.29% <
Ke = 13% ✓, and weights 0.70 + 0.25 + 0.05 = 1.00 ✓. The output is a `Decimal` —
no rounding noise to excuse.

### Hand-in checklist

- [ ] Script output pasted (WACC as `Decimal`).
- [ ] "WACC assumptions" sheet: Rf (and source/date), MRP (and why), beta
      (source + window), tax rate, weights (market values) — every box filled.
- [ ] WACC for the shortlist company, cross-checked against at least one peer's
      WACC (same assumptions) in a comparison row.
- [ ] Sanity-check line recorded: Kd < WACC < Ke with all three numbers.

### Common errors

- **Error:** passing the pre-tax Kd into the formula (forgetting the tax
  shield is applied *inside* the function) — WACC comes out too high.
- **Error:** using book-value equity in `e` — the memo's WACC no longer
  matches the market; use market cap.
- **Error:** an "assumptions sheet" that lists numbers without sources — the
  memo's beta and MRP must be defensible, or the whole WACC is.

## Practice problems

1. Pre-tax Kd 10%, tax 30%. Compute after-tax Kd.
2. A ₹100 preference share pays ₹9 and trades at ₹112.50. Compute Kp.
3. Rf 7%, MRP 6.5%, beta 1.3. Compute Ke. Recompute with beta 0.85 and explain
   the difference in one sentence.
4. Equity ₹800 cr, debt ₹200 cr, preference ₹0; Ke 14%, pre-tax Kd 8%, tax 25%.
   Compute WACC and verify it lies between Kd and Ke.
5. Why does the after-tax treatment make debt cheaper than equity? Give the
   numbers for a 10% coupon and 25% tax.
6. State which EMH form each statement belongs to: (a) "charts can't work";
   (b) "even insiders can't beat the market"; (c) "public results are already
   in the price".
7. Beta is 0.9 for a utility and 1.6 for a metal stock. Which falls more in a
   market crash? Which would you expect to have the higher Ke, and why?
8. A WACC of 8% is computed with Ke 14% and after-tax Kd 6%. What is wrong,
   and what do you check first?

### Solutions

1. 10% × 0.70 = 7%.
2. Kp = 9/112.50 = 8%.
3. Ke = 7 + 1.3 × 6.5 = 15.45%. At β 0.85: 7 + 0.85 × 6.5 = 12.525%. Lower
   systematic risk → lower required return.
4. Weights: E/V = 0.8, D/V = 0.2. WACC = 0.8 × 14 + 0.2 × 8 × 0.75 = 11.2 +
   1.2 = 12.4%. Check: 6% < 12.4% < 14% ✓.
5. Interest is tax-deductible: after-tax cost = 10% × 0.75 = 7.5% vs equity's
   14%; dividends carry no tax shield, so equity is structurally dearer.
6. (a) weak, (c) semi-strong, (b) strong.
7. The metal stock (β 1.6) falls more — high beta amplifies both directions —
   and carries the higher Ke, because CAPM pays more for more systematic risk.
8. WACC below after-tax Kd (8% < 6%? — impossible with positive weights) or
   above Ke — the check fails; first re-verify the weights (do they sum to
   1?) and that after-tax Kd is on the debt leg.

## Quiz bank

| Question | A | B | C | D | Answer |
|---|---|---|---|---|---|
| After-tax Kd = … | Pre-tax × (1−t) | Pre-tax / t | Pre-tax + t | Pre-tax × t | A |
| CAPM formula is… | Rf + β(Rm − Rf) | Rf × β | Rm − βRf | β(Rf + Rm) | A |
| β > 1 means… | Moves less than market | Amplifies market moves | No risk | β is a tax | B |
| Kp is computed as… | Dp / P0 | P0 / Dp | Dp × P0 | (1−t)Dp/P0 | A |
| Preference dividends are… | Tax-deductible | Not tax-deductible | Taxable income | Free | B |
| WACC weights should use… | Book values | Market values | Par values | Average cost | B |
| V in WACC equals… | E + D + P | E × D | E − D | Assets | A |
| A WACC sanity check requires… | Kd < WACC < Ke | WACC > Ke | WACC = Kd | WACC < 0 | A |
| "Public info is in the price" describes… | Weak form | Semi-strong | Strong form | None | B |
| The analyst's edge under mostly-efficient markets is… | None possible | Finding mispriced pockets | Insider tips | Buying index funds only | B |

## Glossary

- **Cost of debt (Kd)** — the yield to maturity on the firm's debt; after-tax
  = pre-tax × (1−t).
- **Tax shield** — the tax saving from deductible interest.
- **Credit spread** — the extra yield risky debt pays over the risk-free rate.
- **CAPM** — Ke = Rf + β(Rm − Rf); the standard cost-of-equity model.
- **Risk-free rate (Rf)** — the default-risk-free return, usually the 10-yr
  G-sec yield.
- **Beta (β)** — systematic risk sensitivity; Cov(Ri,Rm)/Var(Rm).
- **Market risk premium (Rm − Rf)** — the extra return the market demands for
  equity over bonds.
- **Cost of preference (Kp)** — Dp/P0; the fixed-dividend perpetuity rate.
- **WACC** — (E/V)Ke + (D/V)Kd(1−t) + (P/V)Kp; the blended cost of capital.
- **Market value weights** — WACC weights from market prices, not books.
- **EMH weak form** — prices reflect past prices and volume.
- **EMH semi-strong form** — prices reflect all public information.
- **EMH strong form** — prices reflect even private information.
- **Systematic risk** — market-wide risk, priced by CAPM; diversifiable
  (firm-specific) risk is not priced.

## Reading assignment

Read the cost-of-capital chapters in [the reading list](../appendices/reading-list.md):
IFMC items 40, 42, 57–58, PGP T2-202, and any CAPM chapter in your NIFM text.
Then download two Indian companies' 10-year daily returns and a Nifty index
series, compute each beta in a spreadsheet, and note how much the beta (and
hence Ke) changes with the window — the single best way to internalise why WACC
is a range, not a point.

## Assessment

- WACC computation assignment (2 companies, assumptions documented).
- Quiz: CAPM terms and efficiency forms.

## Assessment reminder

The WACC assignment (2 companies with documented assumptions) is a **graded lab
deliverable**, and WACC is the discount rate that the **M7 DCF** and the **M8
capstone** consume — a wrong WACC silently corrupts both. CAPM terms and the
three efficiency forms are standard end-term exam questions. See
[Assessment](../front/assessment.md) for the grading map.

**Next:** [M7 — Valuation Methods](m7-valuation-methods.md)
