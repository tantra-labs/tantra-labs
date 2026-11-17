# M5 — Time Value of Money & Capital Budgeting

> **Weeks 40–41 · 16 hrs · PLO-7 · Core:** NIFM Ch 22; IFMC items 20–21, 48–49

## Learning outcomes

- Compute FV, PV, annuities, and perpetuities.
- Apply the NPV rule and IRR with its pitfalls.
- Compute holding-period return (HPR) and yield (HPY).
- Make an accept/reject capital-budgeting decision.
- Write every cash-flow computation in `Decimal` and state which rate is the
  discount rate and why.

## Prerequisites

- [M4 — Ratio Analysis & DuPont](m4-ratios-dupont.md): profit, cash flow, and
  the idea that a rupee today ≠ a rupee later (the M3 cash work connects).
- [S1-M1 — Math](../s1/m1-math.md): powers, roots, and compounding arithmetic.
- [M1 — Economics for Securities Markets](m1-economics.md): interest rates and
  what the repo rate does — this module's discount rate will be formalised in
  M6.

## Lesson 5.1 — Time value of money

### 1) Concept

A rupee today is worth more than a rupee a year from now: today's rupee can be
invested and earn interest. That is the **time value of money (TVM)**. Two
directions:

```
FV = PV × (1 + r)^n
PV = FV / (1 + r)^n
```

**FV** (future value) answers "what will ₹1,000 grow to in 5 years at 8%?" —
₹1,000 × 1.08⁵. **PV** (present value) answers "how much must I invest today
to have ₹1,000 in 5 years?" — the future amount *discounted* back. **r** is the
rate per period and **n** the number of periods; if the rate is annual and
compounding is quarterly, r = annual/4 and n = years × 4.

**Annuities** are a stream of equal payments each period. The PV of an annuity
is the sum of the PVs of each payment, which has a closed form:

```
PV annuity    = PMT × [1 − (1 + r)^−n] / r
PV perpetuity = PMT / r
```

A **perpetuity** is an annuity that never ends — the formula's neat trick is
that the infinite sum collapses to PMT/r (as long as r > 0). Indian examples:
a bond's coupons form an annuity; the "perpetual" preference shares of Lesson
6.3 are a perpetuity; a dividend stream that grows forever becomes the Gordon
model of M7.

### 2) Worked example

You win ₹1,000,000 today (tax-free) and have two choices: invest at 8% for 5
years, or receive ₹1,400,000 in 5 years instead. Which is worth more?

```python
from decimal import Decimal
PV = Decimal("1_000_000"); r = Decimal("0.08"); n = 5
fv = PV * (Decimal(1) + r) ** n
pv_offer = Decimal("1_400_000") / (Decimal(1) + r) ** n
print("FV of today's prize in 5 yrs:", fv.quantize(Decimal("0.01")))
print("PV of the future offer:", pv_offer.quantize(Decimal("0.01")))
# And a 3-year annuity of ₹100,000 at 8%:
pmt = Decimal("100_000")
pv_annuity = pmt * (Decimal(1) - (Decimal(1) + r) ** -3) / r
print("PV of 3-year annuity:", pv_annuity.quantize(Decimal("0.01")))
```

Answer: FV = ₹1,469,328.08; the future offer's PV = ₹952,768.83 — the ₹1,000,000
today is worth more *at 8%*. The annuity's PV = ₹257,709.79. The lesson: never
compare money at different dates without discounting it to a common date.

### 3) Common pitfalls

> **Pitfall:** Mixing period and rate: 8% annual with quarterly compounding
> means r = 0.02 per quarter and n = 20 quarters, *not* n = 5 with r = 0.08.
> Using `float` for r — Decimal keeps the arithmetic exact. Forgetting that the
> perpetuity formula is only valid for r > 0 (and for growing perpetuity,
> r > g, which reappears in M7).

### 4) Key takeaways

- **Takeaway:** FV = PV(1+r)ⁿ and PV = FV/(1+r)ⁿ are the same equation read
  two ways.
- **Takeaway:** Annuities have a closed-form PV; perpetuities collapse to
  PMT/r.
- **Takeaway:** Always compare money on a common date — discount everything
  to "today".

## Lesson 5.2 — HPR and HPY

### 1) Concept

**Holding-period return (HPR)** measures what an investment actually returned
over the time you held it, including income received:

```
HPR = (Ending Value − Beginning Value + Income) / Beginning Value
HPY = HPR × 100   (as a percentage)
```

The numerator separates **capital gain** (ending − beginning) from **income**
(dividends/interest). HPR is the *total* return per rupee invested — the number
that tells you whether the investment beat the alternatives. Example: buy a
share at ₹100, collect ₹4 in dividends, sell at ₹112: HPR = (112 − 100 + 4)/100
= 0.16, HPY = 16%.

HPR is defined **per holding period**. To compare investments with different
holding periods, annualise. For one year, HPR is already annual. For multi-year
holdings, annualise with *compounding*: if an investment returned 44% over 2
years, the annual equivalent is (1.44)^(1/2) − 1 ≈ 19.8% — the **CAGR**. The
arithmetic average of yearly returns overstates the outcome (a 50% gain
followed by a 50% loss is a 25% loss, average 0%) — compounding is the honest
annualiser.

### 2) Worked example

A one-year investment and a multi-year comparison:

```python
from decimal import Decimal
beg = Decimal("200"); end = Decimal("216"); dividend = Decimal("8")
hpr = (end - beg + dividend) / beg
print("HPR:", hpr, "| HPY:", (hpr * 100).quantize(Decimal("0.01")), "%")
# 3-year holding, 60% total return -> annualise
total = Decimal("0.60")
cagr = (Decimal(1) + total) ** (Decimal(1) / Decimal(3)) - Decimal(1)
print("3-yr CAGR:", (cagr * 100).quantize(Decimal("0.01")), "%")
# versus the naive average 60/3 = 20% -> which is right?
print("Naive average:", (total / Decimal(3) * 100).quantize(Decimal("0.01")), "%")
```

Answer: HPR = 0.12 (HPY 12%). CAGR = 16.96% vs the naive 20% — the naive
average ignores compounding. For returns that are ±varied, the arithmetic
average *overstates*; the CAGR is what your wallet actually saw.

### 3) Common pitfalls

> **Pitfall:** Forgetting income in HPR — dividends are part of the return.
> Annualising a multi-year HPR by dividing (60/3 = 20%) instead of compounding
> ((1.6)^(1/3) − 1). Treating HPR as annual when the holding period is not a
> year.

### 4) Key takeaways

- **Takeaway:** HPR = (End − Beg + Income) / Beg; HPY is it in percent.
- **Takeaway:** Annualise multi-period returns with compounding (CAGR), never
  by dividing.
- **Takeaway:** The arithmetic average overstates results; compounding is the
  truth.

## Lesson 5.3 — NPV and IRR

### 1) Concept

A project is a series of cash flows: an **initial investment** (cash out) then
future **cash inflows**. To judge it, discount every future inflow to today and
compare with the initial outlay:

```
NPV = Σ CF_t / (1 + r)^t − Initial Investment
```

The **NPV rule:** accept if NPV ≥ 0, discounting at the firm's **cost of
capital** (the return the project must beat — formalised in M6). NPV ≥ 0 means
the project earns at least the required rate after paying everyone.

**IRR (internal rate of return)** is the rate that makes NPV = 0 — the
project's own breakeven rate. Accept if IRR ≥ cost of capital. The two rules
agree for conventional projects, but IRR has four famous pitfalls:

1. **Multiple IRRs** — cash flows that go out-in-out (a mine needing
   remediation, a project with deferred costs) can have *two* rates where
   NPV = 0. Which is "the" IRR? Unanswerable.
2. **Scale blindness** — a project with IRR 90% on ₹1 lakh adds less value
   than one with IRR 25% on ₹10 crore; IRR ignores *how much* money earns it.
3. **Reinvestment-rate assumption** — IRR implicitly assumes interim cash
   flows are reinvested at the IRR itself; the NPV rule assumes they are
   reinvested at the cost of capital (more realistic).
4. **Timing** — IRR prefers early cash; NPV weights by present value properly.

Rule of thumb: **when NPV and IRR conflict, trust NPV.** NPV is in rupees
(value added); IRR is a percentage (a rate), and rates are easily fooled.

### 2) Worked example

A ₹900,000 project yields ₹300,000, ₹400,000, ₹500,000 over three years. Cost of
capital 12%. NPV, then a scale comparison:

```python
from decimal import Decimal
def npv(cash_flows, rate, initial):
    total = Decimal(0)
    for t, cf in enumerate(cash_flows, start=1):
        total += cf / (Decimal(1) + rate) ** t
    return total - initial
cf = [Decimal("300_000"), Decimal("400_000"), Decimal("500_000")]
print("NPV:", npv(cf, Decimal("0.12"), Decimal("900_000")))
# Scale: Project X 90% IRR on 1 lakh; Project Y 25% IRR on 10 crore, at r=12%
x_irr, y_irr = Decimal("0.90"), Decimal("0.25")
x_pv = Decimal("200_000") / (Decimal(1) + Decimal("0.12"))   # one-year project
y_pv = Decimal("125_000_000") / (Decimal(1) + Decimal("0.12"))
print("X adds:", (x_pv - Decimal("100_000")).quantize(Decimal("0.01")),
      "| Y adds:", (y_pv - Decimal("100_000_000")).quantize(Decimal("0.01")))
```

Answer: NPV ≈ ₹99,539.95 ≥ 0 → **accept**. The scale check: X's IRR (90%) is
dazzling but adds ~₹78,571; Y's IRR (25%) adds ~₹11,607,143 — Y adds 148× the
value. IRR was right about *rate* and wrong about *value*; NPV decides.

### 3) Common pitfalls

> **Pitfall:** Choosing between mutually exclusive projects by IRR — scale
> and timing break it; use NPV. Trusting a project with multiple sign changes
> to have "an IRR". Using a nominal discount rate with real (inflation-
> stripped) cash flows — the two must match.

### 4) Key takeaways

- **Takeaway:** NPV = Σ CF_t/(1+r)ᵗ − I; accept if NPV ≥ 0 at the cost of
  capital.
- **Takeaway:** IRR is the rate that makes NPV = 0; it has four classic
  pitfalls (multiple roots, scale, reinvestment, timing).
- **Takeaway:** In any conflict, NPV wins — value in rupees beats a rate.

## Lesson 5.4 — Capital budgeting & cost of capital

### 1) Concept

The full capital-budgeting toolkit adds screening methods to NPV/IRR:

**Payback period** — how many years until cumulative inflows recover the
investment. Simple, intuitive, but ignores (a) the time value of money and
(b) all cash flows after payback. **Discounted payback** fixes (a) by
discounting inflows first. **Profitability index (PI)** = PV of inflows /
initial investment — a benefit-per-rupee ratio, useful when capital is
rationed: take the highest-PI projects first until the budget runs out.

The **discount rate is the cost of capital** (M6): the weighted average of what
the firm pays for debt and equity. Every M5 project's NPV is only as good as
that rate — a 1% error in the rate can flip an accept/reject. That is why this
module ends by pointing at M6: NPV is a *mechanical* computation; the discount
rate is a *judgement*.

### 2) Worked example

Payback, discounted payback, and PI on the Lesson 5.3 project:

```python
from decimal import Decimal
initial = Decimal("900_000")
cfs = [Decimal("300_000"), Decimal("400_000"), Decimal("500_000")]
r = Decimal("0.12")
cum = Decimal(0); payback_years = None
for i, cf in enumerate(cfs, start=1):
    cum += cf
    if cum >= initial and payback_years is None:
        payback_years = i
disc = [cf / (Decimal(1) + r) ** t for t, cf in enumerate(cfs, start=1)]
pv_in = sum(disc, Decimal(0))
pi = pv_in / initial
print("Simple payback:", payback_years, "years | PI:", pi.quantize(Decimal("0.001")))
```

Answer: cumulative cash hits ₹900,000 in year 3 → simple payback = 3 years.
PV of inflows = 999,539.95, so PI = 1.111 — every ₹1 of outlay returns ₹1.111
in present value. Under capital rationing, rank projects by PI and fund the
highest first.

### 3) Common pitfalls

> **Pitfall:** Using simple payback as the deciding rule — it ignores the
> cost of capital and post-payback cash. Computing PI with undiscounted
> inflows. Forgetting that "cost of capital" is a judgement the company must
> *state*, not a number that appears by itself.

### 4) Key takeaways

- **Takeaway:** Payback (and discounted payback) are screening tools; PI ranks
  projects under rationing.
- **Takeaway:** The discount rate is the cost of capital — M6 formalises it.
- **Takeaway:** NPV/IRR decide; payback/PI screen and rank.

## Tantra Lab 5 — NPV in Decimal

### Lab goal

Prove that NPV in `Decimal` is exact, that the accept/reject decision follows
mechanically from the sign, and that IRR's pitfalls are *structural* (multiple
roots, scale) — not arithmetic mistakes.

### Code

```python
from decimal import Decimal

def npv(cash_flows: list[Decimal], rate: Decimal, initial: Decimal) -> Decimal:
    total = Decimal(0)
    for t, cf in enumerate(cash_flows, start=1):
        total += cf / (Decimal(1) + rate) ** t
    return total - initial

cf = [Decimal("300_000"), Decimal("400_000"), Decimal("500_000")]
print("NPV:", npv(cf, Decimal("0.12"), Decimal("900_000")))
```

**Task:** build the NPV/IRR worksheet in Excel for a 5-year project; compute
NPV and IRR by hand and with Excel functions; write the accept/reject decision
with reasoning. Also compute HPR/HPY for a 1-year investment with dividends.

### Expected output

```
NPV: 99539.9463...
```

NPV ≈ **₹99,539.95** — positive, so the project clears the 12% cost of capital
and should be **accepted**. The decision line in your worksheet must state: the
NPV rule says accept because NPV ≥ 0; the IRR (≈16.6% for this cash-flow
pattern, by hand or Excel `IRR`) exceeds 12% — both rules agree, which is the
normal case to practise.

### Hand-in checklist

- [ ] Script output (NPV as `Decimal`) pasted.
- [ ] Excel worksheet: 5-year project with a cash-flow row, discount-rate row,
      NPV cell (formula, not hard-coded), and IRR cell.
- [ ] Hand computation of NPV for at least one year and the final decision line
      ("Accept because NPV ≥ 0 at 12%").
- [ ] HPR/HPY computation for a 1-year investment with dividends (e.g., buy
      ₹200, dividend ₹8, sell ₹216 → HPR 12%).
- [ ] One sentence on which method would win if NPV and IRR conflicted, and
      why.

### Common errors

- **Error:** writing `rate` as a percentage integer (12) instead of a Decimal
  rate (0.12) — the discount collapses. Keep `Decimal("0.12")`.
- **Error:** using Excel's IRR on a cash-flow row with a wrong sign convention
  (outflow positive) — Excel returns a nonsense rate or `#NUM!`; keep outflows
  negative.
- **Error:** skipping the hand check and trusting the spreadsheet — a stale
  discount-rate cell silently flips the decision; verify one year by hand.

## Practice problems

1. ₹250,000 invested at 9% for 6 years. Compute FV. Then compute the PV of
   ₹250,000 received in 6 years at 9%.
2. A bond pays ₹10,000 per year for 8 years plus ₹200,000 at maturity.
   At a 7% discount rate, compute the PV of the coupon stream and of the
   principal.
3. What is the PV of a perpetuity paying ₹5,000 a year at 10%? At 5%? Explain
   why the lower rate gives a higher PV.
4. Buy a share at ₹150, receive ₹6 dividend, sell at ₹162. Compute HPR and HPY.
   If the holding period was 6 months, is the HPR annual? Explain.
5. An investment returns +40% in year 1 and −30% in year 2. Compute the
   arithmetic average and the true two-year CAGR. Which is right for your
   wallet?
6. Project: initial ₹1,200,000, inflows ₹400,000 for 4 years, cost of capital
   11%. Compute NPV and decide. Then compute PI.
7. A project has cash flows −100, +300, −220 (out-in-out). Why can this project
   have two IRRs? In one sentence, which rule do you trust instead?
8. Project A: IRR 80%, NPV ₹50,000. Project B: IRR 18%, NPV ₹4,000,000. You
   can fund only one. Which do you pick and why?

### Solutions

1. FV = 250,000 × 1.09⁶ ≈ ₹419,305.09. PV = 250,000 / 1.09⁶ ≈ ₹149,048.05.
2. Coupons: 10,000 × [1 − 1.07⁻⁸]/0.07 ≈ ₹59,712.78. Principal: 200,000/1.07⁸
   ≈ ₹116,401.15. Total ≈ ₹176,113.93.
3. Perpetuity PV = 5,000/0.10 = ₹50,000; at 5% = ₹100,000. A lower rate means
   the future payments are discounted less, so they are worth more today.
4. HPR = (162 − 150 + 6)/150 = 0.12; HPY = 12%. No — the HPR is for the holding
   period; for a 6-month hold the annual equivalent must compound (1.12² − 1
   ≈ 25.4%).
5. Arithmetic = +5%; CAGR = (1.4 × 0.7)^(1/2) − 1 ≈ −1.0%. The CAGR is right —
   your capital actually shrank.
6. NPV = 400,000 × [1 − 1.11⁻⁴]/0.11 − 1,200,000 ≈ 400,000 × 3.1024 − 1,200,000
   ≈ 40,980 ≥ 0 → accept. PI = (1,240,980)/1,200,000 ≈ 1.034.
7. The sign pattern out-in-out crosses the NPV curve twice, so two rates solve
   NPV = 0. Trust NPV (or MIRR), not the ambiguous IRR.
8. Project B — IRR says A is "better" but B adds ₹4,000,000 of value; scale
   wins. NPV decides conflicts.

## Quiz bank

| Question | A | B | C | D | Answer |
|---|---|---|---|---|---|
| FV = PV × … | (1+r)ⁿ | (1+r)/n | rⁿ | n(1+r) | A |
| PV of a ₹1,000 perpetuity at 10% is… | ₹10,000 | ₹100,000 | ₹1,100 | ₹9,090 | A |
| HPR ignores… | Income | Nothing (it includes income) | Beginning value | Ending value | B |
| NPV ≥ 0 at the cost of capital means… | Reject | Accept | Breakeven only | Depends on IRR | B |
| IRR is the rate where… | NPV = 0 | PV = 0 | Cash flows are equal | HPR = 0 | A |
| A project with out-in-out cash flows can have… | No cash flows | Two IRRs | Negative cost of capital | No NPV | B |
| The arithmetic average vs CAGR overstates… | Both same | Arithmetic overstates | CAGR overstates | Neither | B |
| PI = … | PV inflows / initial | Initial / PV inflows | NPV × initial | Cash / debt | A |
| When NPV and IRR conflict… | Trust IRR | Trust NPV | Average them | Trust payback | B |
| Payback period ignores… | Time value & post-payback cash | The initial cost | All inflows | Interest | A |

## Glossary

- **Time value of money** — a rupee today is worth more than a rupee later.
- **Future value (FV)** — PV × (1+r)ⁿ; what money grows to.
- **Present value (PV)** — FV / (1+r)ⁿ; what a future amount is worth today.
- **Annuity** — equal periodic payments for a fixed term.
- **Perpetuity** — equal periodic payments forever; PV = PMT/r.
- **HPR (holding-period return)** — (End − Beg + Income) / Beg for the holding
  period.
- **HPY** — HPR expressed as a percentage.
- **CAGR** — compound annual growth rate; (1+total)^(1/years) − 1.
- **NPV (net present value)** — Σ CF_t/(1+r)ᵗ − I; accept if ≥ 0.
- **IRR (internal rate of return)** — the rate that makes NPV = 0.
- **Payback period** — years until cumulative inflows recover the outlay.
- **Discounted payback** — payback computed on discounted inflows.
- **Profitability index (PI)** — PV of inflows / initial investment.
- **Cost of capital** — the required return a project must beat; the discount
  rate (formalised in M6).

## Reading assignment

Read the TVM and capital-budgeting chapters in [the reading list](../appendices/reading-list.md):
NIFM Ch 22 (time value, NPV, IRR), IFMC items 20–21 and 48–49. Work every
problem in the NIFM chapter by hand before touching a calculator — the hand
discipline is what the end-term exam will test under time pressure.

## Assessment

- 10-problem TVM/capital-budgeting worksheet.
- Quiz: NPV vs IRR.

## Assessment reminder

The 10-problem worksheet is a **graded lab deliverable**, and NPV/IRR
mechanics recur in the end-term exam and throughout M7 (the DCF is NPV applied
to a whole company). Keep your TVM formula sheet in the journal — you will
reopen it in S4's portfolio math. See [Assessment](../front/assessment.md) for
how graded components map to your final grade.

**Next:** [M6 — Cost of Capital, CAPM & WACC](m6-cost-of-capital-capm.md)
