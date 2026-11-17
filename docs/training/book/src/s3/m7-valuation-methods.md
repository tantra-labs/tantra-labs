# M7 — Valuation Methods

> **Weeks 43–45 · 24 hrs · PLO-7 · Core:** NIFM Ch 23–24, 36; IFMC items 34–35, 50, 55, 59, 66

## Learning outcomes

- Value a stock with the dividend discount model (DDM).
- Run a DCF: project FCFF/FCFE, apply WACC, compute terminal value.
- Use relative valuation: PE/PB/EV/EBITDA, comps, and SOTP.
- Reconcile methods into a price target with a confidence band.
- Compute every value in `Decimal` and state which method fits which company.

## Prerequisites

- [M5 — Time Value of Money & Capital Budgeting](m5-tvm-capital-budgeting.md):
  DCF *is* NPV applied to a company — discounting mechanics come from here.
- [M6 — Cost of Capital, CAPM & WACC](m6-cost-of-capital-capm.md): WACC is the
  DCF discount rate and Ke the FCFE/DDM rate.
- [M3 — Financial Statement Analysis](m3-financial-statement-analysis.md):
  the FCFF components (EBIT, D&A, capex, NWC) come from M3's statements.
- [M4 — Ratio Analysis & DuPont](m4-ratios-dupont.md): the ratios behind
  relative valuation.

## Lesson 7.1 — Dividend Discount Model (DDM)

### 1) Concept

If a stock's entire value to a holder is future dividends, then its value is
the present value of those dividends. The **Gordon growth model** assumes a
dividend that grows forever at a constant rate **g**:

```
P0 = D1 / (Ke − g)      (requires Ke > g)
```

where **D1** is the *next* dividend (this year's dividend × (1+g)) and **Ke**
the cost of equity from M6. The condition Ke > g is mathematically mandatory —
if g ≥ Ke the denominator is zero or negative and the formula explodes.

The DDM is at its best for **mature, stable payers**: utilities, banks, FMCG
with decades of steady dividend growth. It fails for **growth companies that
pay no dividend** — a zero dividend gives a zero price, which is obviously
wrong. Two fixes for a no-dividend company: use FCFE (Lesson 7.2) or a
two-stage DDM where the first stage grows fast and the second is Gordon — but
for Semester 3, remember the *fit rule*: **DDM for dividend payers, DCF for
everyone else**. The model also teaches a deep point: the *growth rate of
dividends* is ultimately bounded by how much profit the company can retain and
reinvest at a good return (the M4 DuPont logic).

### 2) Worked example

A bank pays ₹20 next year and has grown its dividend ~6% for a decade; Ke is
12%:

```python
from decimal import Decimal
def gordon(d1, ke, g):
    return d1 / (ke - g)
print("DDM P0:", gordon(Decimal("20"), Decimal("0.12"), Decimal("0.06")).quantize(Decimal("0.01")))
# Sensitivity: growth estimate 5% vs 7%
print("P0 at g=5%:", gordon(Decimal("20"), Decimal("0.12"), Decimal("0.05")).quantize(Decimal("0.01")))
print("P0 at g=7%:", gordon(Decimal("20"), Decimal("0.12"), Decimal("0.07")).quantize(Decimal("0.01")))
```

Answer: P0 = 20/(0.12−0.06) = ₹333.33. The sensitivities: at g=5% the price is
₹285.71; at g=7% it is ₹400.00. A ±1% growth-forecast change swings the value
±20% — this is why every valuation in this module must end with a **range and
sensitivities**, never a single price.

### 3) Common pitfalls

> **Pitfall:** Using last year's dividend instead of D1 = D0 × (1+g). Plugging
> g ≥ Ke into the formula (the price goes negative — the model has *broken*,
> not "found" a negative price). Using the DDM on a non-dividend payer.

### 4) Key takeaways

- **Takeaway:** P0 = D1/(Ke − g), valid only when Ke > g.
- **Takeaway:** DDM fits mature dividend payers; DCF handles everyone else.
- **Takeaway:** Growth-estimate sensitivity is huge — always report the range.

## Lesson 7.2 — Discounted cash flow (DCF)

### 1) Concept

The DCF values a company by its **free cash flow** rather than its dividends —
cash the business can actually pay out. Two routes:

```
FCFF  (free cash flow to firm)   → discount at WACC → Enterprise Value
FCFE  (free cash flow to equity) → discount at Ke   → Equity Value
```

The building blocks:

```
FCFF = EBIT·(1−t) + D&A − Capex − ΔNWC
FCFE = FCFF − Interest·(1−t) + Net Borrowing
```

**FCFF** starts from operating profit, adds back the non-cash D&A, and subtracts
the cash the business must reinvest (capex) and the cash tied up in growing
working capital (ΔNWC). It is the cash available to *everyone* who funded the
firm — lenders and shareholders — so it is discounted at WACC. **FCFE** is what
is left for shareholders after paying the lenders (interest, after tax) and
net borrowings (new loans in, repayments out); it is discounted at Ke.

**Terminal value** handles the fact that you cannot forecast forever. After an
explicit forecast period (say 5 years), assume steady growth at **g** forever:

```
TV = FCF_T·(1+g) / (r − g)
```

where FCF_T is the last forecast FCF and r the discount rate (WACC for FCFF, Ke
for FCFE). For most companies the terminal value is 60–80% of the DCF value —
which is why the *growth and margin you assume in steady state* dominate the
answer. The DCF answer is a disciplined opinion, not a fact.

### 2) Worked example

FCFF for a company with EBIT ₹1,000, D&A ₹120, capex ₹200, ΔNWC ₹60, tax 25%;
then a one-year DCF with TV:

```python
from decimal import Decimal
ebit = Decimal("1000"); tax = Decimal("0.25"); d_and_a = Decimal("120")
capex = Decimal("200"); d_nwc = Decimal("60")
fcff = ebit * (Decimal(1) - tax) + d_and_a - capex - d_nwc
print("FCFF:", fcff)
wacc = Decimal("0.11"); g = Decimal("0.05")
tv = fcff * (Decimal(1) + g) / (wacc - g)
print("TV (Gordon):", tv.quantize(Decimal("0.01")))
```

Answer: FCFF = 750 + 120 − 200 − 60 = **₹610**. If that were the final forecast
year, TV = 610 × 1.05 / (0.11 − 0.05) = ₹10,675.00. The EV = PV(FCFF years) +
PV(TV); with a single year and one TV: EV = 610/1.11 + 10,675/1.11 ≈ 549.55 +
9,617.12 ≈ ₹10,166.67 — and over 80% of that is the terminal value, so the g and
WACC assumptions *are* the valuation.

### 3) Common pitfalls

> **Pitfall:** Discounting FCFF at Ke (or FCFE at WACC) — the mismatch quietly
> double-counts or under-charges risk. Forgetting ΔNWC (a growing business
> consumes cash into working capital). Treating the terminal value as
> "just an assumption" when it is most of the value — stress-test it.

### 4) Key takeaways

- **Takeaway:** FCFF → WACC → EV; FCFE → Ke → equity value. Match the cash
  flow to its rate.
- **Takeaway:** FCFF = EBIT(1−t) + D&A − Capex − ΔNWC; FCFE = FCFF −
  Interest(1−t) + Net Borrowing.
- **Takeaway:** TV = FCF(1+g)/(r−g) usually dominates — test g and r hard.

## Lesson 7.3 — Relative valuation & comps

### 1) Concept

**Relative valuation** answers "what do *similar* companies trade at?" instead
of "what is the cash worth?". Pick the multiple the industry actually trades on
— **PE** (consumer, IT), **PB** (banks — book value drives price), **EV/EBITDA**
(capital-heavy, leveraged industries — cement, telecom, auto), **EV/Sales**
(loss-makers). The workhorse is **EV/EBITDA** because it strips capital
structure: two companies with the same operating earnings have the same EBITDA,
so comparing them on EV/EBITDA ignores who borrows more.

The **comps** procedure:

1. Pick a **peer set** — comparable businesses, similar size and growth.
2. Compute each peer's multiple (median, to resist outliers).
3. Apply the median multiple to *your* company's metric.

```
Target value = Median peer multiple × your metric
```

The hidden assumption: *the market is right about the peers*. Comps are a
consistency check on the DCF and a way to value what a DCF cannot see (young,
loss-making, or asset-rich firms). They are only as good as the peer set — an
unrepresentative peer list produces a nonsense "fair value".

### 2) Worked example

Your company: EBITDA ₹500 crore. Three peers: EBITDA 400/600/800 with EV 6,400/
9,600/14,400 (EV/EBITDA 16, 16, 18). Apply the median multiple:

```python
from decimal import Decimal
your_ebitda = Decimal("500")          # crore
peers_ev_ebitda = [Decimal("16"), Decimal("16"), Decimal("18")]
sorted_m = sorted(peers_ev_ebitda)
median = sorted_m[len(sorted_m) // 2]
target_ev = median * your_ebitda
print("Median EV/EBITDA:", median, "| Target EV:", target_ev, "crore")
```

Answer: median multiple 16×, target EV = ₹8,000 crore. If the DCF (Lesson 7.2)
says ₹9,000 crore, the two methods disagree by 12.5% — that gap is exactly what
Lesson 7.5 reconciles into a range.

### 3) Common pitfalls

> **Pitfall:** Using the *average* multiple when a peer's outlier distorts it —
> median is safer. Mixing EV/EBITDA and PE answers without converting properly
> (EV → equity value = EV − debt + cash). Comparing a growth company to a
> stagnant peer set on PE without adjusting for growth.

### 4) Key takeaways

- **Takeaway:** Multiples: PE, PB, EV/EBITDA, EV/Sales — pick what the
  industry trades on.
- **Takeaway:** Comps = peer set → median multiple → apply to your metric.
- **Takeaway:** EV/EBITDA is leverage-neutral — the cross-company workhorse.

## Lesson 7.4 — SOTP (sum of the parts)

### 1) Concept

**Conglomerates** (multi-business companies) defeat single-multiple valuation:
a 12× PE on consolidated profit misprices a company whose pharma arm deserves
30× and whose commodity arm deserves 6×. **SOTP** values each business line
separately — each at its *own* appropriate multiple or DCF — then sums:

```
SOTP value = Σ (value of each business segment)
```

Then two adjustments: (a) **net debt** (debt − cash) or net cash is added or
subtracted to move from operating value to equity value; (b) a **holding-company
discount** is applied when the market systematically prices conglomerates below
their SOTP sum — because the parts cannot be accessed individually, because of
cross-holdings, or because of governance discounts. Indian examples: the
Reliance group (retail + Jio + refining/chemicals + oil & gas), the Tata
holding structure, and ITC (FMCG + hotels + agri + paper). SOTP is how research
houses build target prices for these names, and why the same group can trade
"cheap" versus the sum of its parts.

### 2) Worked example

Three segments, two multiples, plus net debt and a holding discount:

```python
from decimal import Decimal
seg = {"pharma_ebitda": Decimal("300"), "commodity_ebitda": Decimal("700")}
mult = {"pharma": Decimal("18"), "commodity": Decimal("6")}
parts = seg["pharma_ebitda"] * mult["pharma"] + seg["commodity_ebitda"] * mult["commodity"]
net_debt = Decimal("400")          # debt − cash
sotp_equity = parts - net_debt
discount = Decimal("0.15")         # holding-company discount
final = sotp_equity * (Decimal(1) - discount)
print("Parts value:", parts, "| Equity (net of debt):", sotp_equity)
print("After 15% holding discount:", final)
```

Answer: parts = 5,400 + 4,200 = ₹9,600; equity = 9,200 after net debt; after a
15% holding discount → ₹7,820. The *discount* is the analyst's judgement —
state its size and reason explicitly, because it can halve the premium a
conglomerate's parts otherwise suggest.

### 3) Common pitfalls

> **Pitfall:** Summing segments valued on different bases (one on EBITDA, one
> on net asset value) without converting to a common currency. Forgetting net
> debt when going from operating value to equity value. Applying the holding
> discount as a reflexive default rather than a reasoned judgement.

### 4) Key takeaways

- **Takeaway:** Value each segment at its own multiple/DCF, then sum.
- **Takeaway:** Adjust for net debt and state any holding-company discount.
- **Takeaway:** SOTP is the only honest method for conglomerates.

## Lesson 7.5 — Reconciling to a price target

### 1) Concept

Methods disagree, and that is the point: each method is a *different lens*, so
the analyst **averages (or ranges) across methods, weighting by confidence**. A
DCF with clean assumptions and stable cash flows outranks a comps average with a
sloppy peer set. The output is:

```
Target price = a central number + a confidence range
             + key sensitivities (rate up/down, growth up/down)
```

This is what a research report's target price actually is: a central estimate,
a band, and the *inputs that move it*. The sensitivities are not decoration —
Lesson 7.1 showed a ±1% growth change moving a DDM ±20%; every target must say
"if WACC rises 50 bps, the target falls X%". Finally, the **margin of safety**:
buy only below the *low end* of the range, because the range is where the
forecast error actually lives. Valuation is not finding the exact price — it is
finding the *range* and the price at which the risk is worth taking.

### 2) Worked example

Two methods for the same stock: DCF says ₹120, comps say ₹100. Weight DCF 0.6,
comps 0.4 (cleaner cash flows):

```python
from decimal import Decimal
dcf = Decimal("120"); comps = Decimal("100")
w_dcf, w_comps = Decimal("0.6"), Decimal("0.4")
target = w_dcf * dcf + w_comps * comps
lo, hi = target - Decimal("15"), target + Decimal("15")   # ±12.5% band
print("Weighted target:", target, "| Range:", lo, "–", hi)
```

Answer: target = ₹112; range ₹97–127. The buy discipline: demand a price
*below* ₹97 (margin of safety) or at least acknowledge the risk inside the
band. The range, not the middle number, is what survives contact with a
changing WACC and growth rate.

### 3) Common pitfalls

> **Pitfall:** Publishing a single target without the range or the
> sensitivities — it pretends to a precision the model does not have. Weighting
> a sloppy comps result as heavily as a clean DCF. Forgetting the margin of
> safety — a "target" is a hypothesis, not a floor.

### 4) Key takeaways

- **Takeaway:** Target = weighted central value + range + sensitivities.
- **Takeaway:** Weight methods by confidence; state the weighting.
- **Takeaway:** Buy below the low end (margin of safety), not at the middle.

## Tantra Lab 7 — DDM and DCF in Decimal

### Lab goal

Prove both core valuation formulas run exactly in `Decimal` — the Gordon price
and the Gordon terminal value — and that the *outputs are rate-sensitive*: the
same inputs with a 1% different rate produce a meaningfully different value,
which is why every valuation ends in a range.

### Code

```python
from decimal import Decimal

def gordon(d1: Decimal, ke: Decimal, g: Decimal) -> Decimal:
    return d1 / (ke - g)

def dcf_terminal(fcf: Decimal, wacc: Decimal, g: Decimal) -> Decimal:
    return fcf * (Decimal(1) + g) / (wacc - g)

print("DDM P0:", gordon(Decimal("20"), Decimal("0.12"), Decimal("0.06")))
print("TV:", dcf_terminal(Decimal("1000"), Decimal("0.11"), Decimal("0.05")))
```

**Task:** value your shortlist company two ways (DCF + a multiple), reconcile
into a target price and range, and list three sensitivities. Check the screening
examples (`screening/03_dividend_yield_screener.py`, `05_net_net_screener.py`)
to see valuation screens in code.

### Expected output

```
DDM P0: 333.3333...
TV: 17500
```

DDM P0 = 20/(0.12−0.06) = **₹333.33**; TV = 1000 × 1.05/(0.11−0.05) = **₹17,500**.
Both `Decimal`. The output is just the start: your memo must show what happens
when `ke` is 13% (P0 → ₹285.71) or `g` is 6% (TV → ₹21,200) — the three
sensitivities the task demands.

### Hand-in checklist

- [ ] Script output pasted (both values as `Decimal`).
- [ ] Shortlist company valued two ways: a DCF (FCFF → WACC → EV → equity
      value) and one multiple, with every input sourced from M3/M6 worksheets.
- [ ] Reconciliation: weighted target + range, with the weighting stated.
- [ ] Three sensitivities computed (e.g., WACC ±50 bps, growth ±1%) with the
      resulting target changes.
- [ ] The valuation screens (`screening/03_dividend_yield_screener.py`,
      `05_net_net_screener.py`) run, with a one-line reading of what each
      encodes.

### Common errors

- **Error:** passing `g ≥ ke` to `gordon` — the denominator is zero/negative;
  the model is invalid, not "negative priced". Check before you run.
- **Error:** mixing FCFF discounted at Ke — the M7 classic; keep FCFF→WACC and
  FCFE→Ke.
- **Error:** reporting a target without the range — the memo will be marked
  down; the range is the deliverable.

## Practice problems

1. A utility pays D1 = ₹25, Ke = 11%, g = 5%. Compute P0. Recompute at g = 6%
   and explain the jump.
2. FCFF for: EBIT ₹2,000, D&A ₹300, capex ₹500, ΔNWC ₹200, tax 25%.
3. FCFE for the company in problem 2 given interest ₹200 (pre-tax) and net
   borrowing +₹150.
4. TV for FCF = 1,500, WACC = 10%, g = 4%. What if g = 6%? Comment on the
   terminal-value sensitivity.
5. Three peers trade at EV/EBITDA 9, 10, 14. Your company's EBITDA is 800.
   Compute the median-multiple target EV and say why median beats average here.
6. A conglomerate: pharma EBITDA 400 (×14), infra EBITDA 600 (×8), net debt
   500, holding discount 12%. Compute SOTP equity value.
7. DCF says ₹150, comps say ₹120, weights 0.5/0.5. Give the target and a ±10%
   range. Would you buy at ₹118?
8. Why does EV/EBITDA strip capital structure, and why is that useful when
   comparing a leveraged and an unleveraged peer?

### Solutions

1. P0 = 25/0.06 = ₹416.67; at g = 6%: 25/0.05 = ₹500.00. The denominator is
   shrinking, so the same ₹25 dividend is worth much more — small growth
   errors, big price errors.
2. FCFF = 2000 × 0.75 + 300 − 500 − 200 = 1500 + 300 − 700 = ₹1,100.
3. FCFE = 1,100 − 200 × 0.75 + 150 = 1,100 − 150 + 150 = ₹1,100 (here the
   borrowing exactly offsets the after-tax interest).
4. TV = 1,500 × 1.04/0.06 = ₹26,000; at g = 6%: 1,500 × 1.06/0.04 = ₹39,750 —
   a 2-point growth change swings the TV ~53%; terminal assumptions dominate.
5. Median 10× (9,10,14 sorted) → target EV = 8,000. Median resists the 14×
   outlier that would pull the average up.
6. Parts = 400 × 14 + 600 × 8 = 5,600 + 4,800 = 10,400; equity = 10,400 − 500 =
   9,900; after 12% discount = 9,900 × 0.88 = ₹8,712.
7. Target = 0.5 × 150 + 0.5 × 120 = ₹135; range ₹121.5–148.5. At ₹118 you are
   *below* the low end — within the margin of safety, so the buy is supported.
8. EV removes debt and cash from the equation, leaving only the operating
   value: the leveraged and unleveraged peers have the same EBITDA, so their
   EV/EBITDA is directly comparable without capital-structure noise.

## Quiz bank

| Question | A | B | C | D | Answer |
|---|---|---|---|---|---|
| Gordon growth requires… | Ke > g | Ke = g | g > Ke | Ke < 0 | A |
| D1 means… | Last year's dividend | Next year's dividend | D0 × (1−g) | Current EPS | B |
| FCFF is discounted at… | Ke | WACC | Kd | Rf | B |
| FCFE is discounted at… | Ke | WACC | Kd | Repo | A |
| FCFF = … | EBIT(1−t) + D&A − Capex − ΔNWC | PAT + D&A | Revenue − costs | OCF − Capex | A |
| TV = … | FCF(1+g)/(r−g) | FCF/(g) | FCF × r | FCF/(1+r) | A |
| EV/EBITDA strips… | Capital structure | Inflation | Tax | Dividends | A |
| Comps use the… | Median multiple | Average multiple | Highest multiple | Lowest multiple | A |
| SOTP is for… | Single-business firms | Conglomerates | Banks only | Startups | B |
| A target price should include… | Range + sensitivities | A single number | Only the multiple | The broker's name | A |

## Glossary

- **DDM / Gordon model** — P0 = D1/(Ke − g); dividend-driven value for mature
  payers.
- **DCF** — discounted cash flow; value from forecast free cash flows.
- **FCFF** — free cash flow to the firm; EBIT(1−t) + D&A − Capex − ΔNWC.
- **FCFE** — free cash flow to equity; FCFF − Interest(1−t) + Net Borrowing.
- **Enterprise value (EV)** — market cap + debt − cash; the value of the
  operating business.
- **Terminal value (TV)** — FCF_T(1+g)/(r−g); the post-forecast value.
- **Comps** — relative valuation against a peer set's median multiple.
- **EV/EBITDA** — leverage-neutral operating multiple.
- **SOTP** — sum-of-the-parts valuation for conglomerates.
- **Holding-company discount** — the market's markdown on conglomerate sums.
- **Net debt** — debt − cash; the bridge from operating to equity value.
- **Target price** — a weighted central value plus range and sensitivities.
- **Margin of safety** — buying below the low end of the value range.

## Reading assignment

Read the valuation chapters in [the reading list](../appendices/reading-list.md):
NIFM Ch 23–24, 36 (DDM, DCF, multiples), IFMC items 34–35, 50, 55, 59, 66.
Then read one published brokerage initiations/valuation report on an NSE-listed
company and check *every number in it* against the formulas of this module —
that cross-check is the fastest way to internalise how professionals reconcile
DDM, DCF, and comps into a target.

## Assessment

- Valuation memo (single company: DCF + multiples + SOTP, target with range).
- Quiz: model selection.

## Assessment reminder

The valuation memo is a **graded lab deliverable** and is the analytic heart of
the **M8 modeled-company capstone** — the programme gate. Model-selection
questions (when DDM, when DCF, when comps) are regular end-term exam items, and
the range-plus-sensitivity habit you build here is exactly what S4's research
report will be graded on. See [Assessment](../front/assessment.md) for the
grading map.

**Next:** [M8 — Financial Modeling](m8-financial-modeling.md)
