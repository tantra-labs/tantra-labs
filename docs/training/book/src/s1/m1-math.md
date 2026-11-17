# M1 — Financial Literacy & Business Math Bootcamp

> **Weeks 1–2 · 24 hrs · PLO-1, PLO-7 prerequisites**

## Learning outcomes

- Compute percentages, ratios, growth rates, CAGR, and compounding without error.
- Use exponents and logarithms for finance problems.
- Explain demand, supply, and elasticity at an intuitive level.
- Operate a financial calculator for TVM-style inputs.
- Write every money/price/return calculation as `decimal.Decimal` (the course-wide Zero-Floats rule).

## Prerequisites

- No finance background is assumed — this is the on-ramp module.
- Comfortable with Class 12 arithmetic: fractions, decimals, percentages, powers, and simple algebra.
- You should have Python 3.11+ with the `tantra` wheel and `tantra-examples` installed (the harness verifies this).
- This module feeds directly into [M2 — Excel for Finance](m2-excel.md) (your spreadsheet formulas will use this module's interest and growth math) and into every later module that computes returns.

## Lesson 1.1 — Money, savings, and interest

### 1) Concept

Money is anything that stores value and acts as a medium of exchange. **Savings** is setting aside money without much risk (a bank deposit, a savings account). **Investment** is putting money to work in assets like shares of RELIANCE or a Nifty 50 index fund, accepting higher risk for the chance of higher return. That trade-off — *higher expected return comes with higher risk* — is the **risk-return trade-off**, and it is the single most important idea in this course.

When you lend or invest money, you are paid **interest**: the price of using money over time. **Simple interest** is paid only on the original amount (the *principal*), so it grows linearly. **Compound interest** pays interest on the principal *plus* interest already earned, so it grows exponentially. Compounding is why a Nifty-style index can go from 10,000 to 24,000 in a decade while the companies inside it are only growing "linearly" in isolation.

The **CAGR** (compound annual growth rate) is the single rate that would turn `P0` into `Pn` over `n` years if growth happened smoothly every year. It smooths out all the ups and downs — Nifty did not go up steadily from 10,000 to 24,000; it fell, crashed, and recovered, but its CAGR is one number.

### 2) Worked example

Simple vs compound interest on ₹10,000 at 10% per year for 2 years:

```
Simple interest = P x r x n   = 10,000 x 0.10 x 2 = 2,000  (total 12,000)
Compound amount = P x (1 + r)^n = 10,000 x 1.10^2  = 12,100  (interest 2,100)
```

```python
from decimal import Decimal

p = Decimal("10000"); r = Decimal("0.10"); n = 2

simple = p * r * n
compound = p * (Decimal(1) + r) ** n
print("simple interest:", simple, "-> total", p + simple)
print("compound amount:", compound, "-> extra vs simple", compound - (p + simple))
```

Output: `simple interest: 2000 -> total 12000`; `compound amount: 12100 -> extra vs simple 100`. The extra ₹100 is interest earned on the first year's ₹1,000 of interest.

### 3) Common pitfalls

> **Pitfall:** mixing `float` and `Decimal` in one calculation. Python silently converts, and money math then carries binary rounding errors. Use `Decimal` for every input in a money calculation. Also watch for **rate mismatch**: a 1% *monthly* rate is not the same as 12% yearly — compound it: `1.01**12 - 1 = 0.1268`, i.e. 12.68%.

### 4) Key takeaways

- **Takeaway:** savings preserves capital; investment grows it — at the price of risk.
- **Takeaway:** compounding rewards time: the longer money stays invested, the more the growth feeds on itself.
- **Takeaway:** CAGR is the "smooth" growth rate; real markets are not smooth.
- **Takeaway:** in this course all money math is `decimal.Decimal`, never `float`.

## Lesson 1.2 — Percentages, ratios, and growth

### 1) Concept

A **percentage change** is `(new - old) / old`, expressed in hundredths. In financial news you must separate **percentage change** from **percentage points**: if the repo rate moves from 6.5% to 6.0%, that is a fall of **0.5 percentage points** but a *relative* fall of `0.5 / 6.5 = 7.69%`. Inflation reporters love to blur this line — don't let them.

The **base effect** matters when comparing growth: a company that grew 50% from a tiny base last year may grow only 10% from a huge base this year — the 10% may be the better business. **Ratios** compare two numbers: a margin is profit divided by revenue; a debt-equity ratio is borrowed money divided by owners' money. An **index number** is one number that summarizes many prices — Nifty 50 and Sensex are index numbers, built by weighting each stock's price by how much of the market it represents (the exact free-float formula is a Semester 4 topic). **Growth rates** are always paired with a horizon: *YoY* (year over year, same quarter last year) vs *QoQ* (quarter over quarter, the previous quarter).

### 2) Worked example

RELIANCE rises from ₹3,000 to ₹3,250:

```
Change % = (3,250 - 3,000) / 3,000 = 250 / 3,000 = 8.33%
```

Annualize a quarterly growth number: if a company's revenue grows 2% in one quarter, the annualized rate is `(1.02)^4 - 1`:

```python
from decimal import Decimal

old = Decimal("3000"); new = Decimal("3250")
print("change %:", (new - old) / old * 100)

q_growth = Decimal("0.02")
annualized = (Decimal(1) + q_growth) ** 4 - 1
print("quarterly 2% annualized:", annualized)
```

Output: `change %: 8.33333333333333333333333333`; `quarterly 2% annualized: 0.08243216` (≈ 8.24%).

### 3) Common pitfalls

> **Pitfall:** calling a move from 6.5% to 6.0% a "0.5% cut" — it is a **0.5 percentage-point** cut and a 7.69% relative cut. **Pitfall:** comparing a company's growth to last year's base without noticing the base changed. **Pitfall:** quoting a raw `Decimal * 100` printout with all 28 digits as if it were a clean 8.3% — round for presentation (`(Decimal("3250") - Decimal("3000")) / Decimal("3000")` is 0.0833…, say "≈ 8.33%").

### 4) Key takeaways

- **Takeaway:** percentage points ≠ percent change; always name which you mean.
- **Takeaway:** ratios (margins, D/E) are the analyst's vocabulary for comparing companies of different sizes.
- **Takeaway:** index numbers compress hundreds of prices into one readable figure.
- **Takeaway:** always attach a horizon to a growth rate: YoY or QoQ.

## Lesson 1.3 — Exponents, logs, and financial formulas

### 1) Concept

**Exponents** are repeated multiplication: `1.10^5` means multiplying 1.10 by itself 5 times. Every compounding formula is an exponent. The number `e` (≈ 2.71828) is the natural base of growth, and its exponent `e^(r·t)` describes **continuous compounding** — growth that compounds at every instant. This looks academic, but option pricing (Semester 4) is built on `e`, so meet it now.

**Logarithms** are the inverse of exponents: if `y = 10^x`, then `log(y) = x`. The **natural log** (`ln`) is the log to base `e`. Logs turn "how long to double?" into a division problem: doubling at rate `r` takes `ln(2) / ln(1 + r)` years. The **Rule of 72** is the short-cut: doubling time ≈ `72 / (r in %)` years.

**Discounting** reverses compounding. If ₹1,21,000 is owed in 2 years and money earns 10%, that future amount is worth `121000 / 1.10^2 = ₹1,00,000` today. That today-value is the **present value (PV)**; the formula `PV = FV / (1 + r)^n` is the engine of every bond price and every discounted-cash-flow model later in the course.

### 2) Worked example

Present value and doubling time:

```
PV = FV / (1 + r)^n = 121,000 / (1.10)^2 = 100,000
Doubling time at 10%: t = ln(2) / ln(1.10) = 0.69315 / 0.09531 = 7.27 years
Rule of 72 says: 72 / 10 = 7.2 years  (close, and fast!)
```

```python
from decimal import Decimal

fv = Decimal("121000"); r = Decimal("0.10"); n = 2
pv = fv / (Decimal(1) + r) ** n
print("PV:", pv)

t_log = Decimal(2).ln() / (Decimal(1) + r).ln()
print("doubling time (logs):", t_log)
print("Rule of 72 estimate  :", Decimal(72) / Decimal(10))
```

Output: `PV: 100000`, `doubling time (logs): 7.27254…`, `Rule of 72 estimate: 7.2`.

### 3) Common pitfalls

> **Pitfall:** computing `Decimal(1) + r` with `r` written as `10` instead of `0.10` — the whole formula silently becomes nonsense. **Pitfall:** using the Rule of 72 for rates above ~25% (the rule drifts; the log formula is exact). **Pitfall:** forgetting that `ln(1 + r)` is *not* `1 + ln(r)`.

### 4) Key takeaways

- **Takeaway:** exponents model compounding; `e` powers model continuous growth.
- **Takeaway:** logs answer time questions (`ln(2)/ln(1+r)`) — they are division problems in disguise.
- **Takeaway:** `PV = FV / (1 + r)^n` prices any future cash flow today.
- **Takeaway:** the Rule of 72 is a mental-math approximation; use logs when precision matters.

## Lesson 1.4 — Demand, supply, and elasticity

### 1) Concept

A **demand curve** shows how much buyers want at each price: as price rises, quantity demanded falls. A **supply curve** shows how much sellers will provide at each price: as price rises, quantity supplied rises. The **equilibrium price** is where the two curves cross — the price at which buyers and sellers agree, and where a stock like INFY actually trades on the NSE order book (this is *price discovery*, revisited in M3 and M4).

**Elasticity** measures how *responsive* buyers are to a price change:

```
Elasticity = % change in quantity demanded / % change in price
```

If a 10% price rise cuts quantity demanded by 2%, elasticity is `-2 / 10 = -0.2` — **inelastic** (people buy anyway; think of medicines or electricity). If it cuts demand by 20%, elasticity is `-2` — **elastic** (think of holidays or new phones). Necessities are inelastic; discretionary goods are elastic. That is why some industries are **cyclical** — in a downturn their demand collapses because spending is postponable — which is exactly the economics you will formalise in Semester 3.

### 2) Worked example

Onion prices rise from ₹60/kg to ₹90/kg and household monthly demand falls from 10 kg to 7 kg:

```
% change in price    = (90 - 60) / 60        = +50%
% change in quantity = (7 - 10) / 10         = -30%
Elasticity           = -30 / 50              = -0.6   (inelastic, |value| < 1)
```

```python
from decimal import Decimal

p_old, p_new = Decimal("60"), Decimal("90")
q_old, q_new = Decimal("10"), Decimal("7")
d_p = (p_new - p_old) / p_old
d_q = (q_new - q_old) / q_old
e = d_q / d_p
print("elasticity:", e, "-> inelastic" if abs(e) < 1 else "-> elastic")
```

Output: `elasticity: -0.6 -> inelastic`.

### 3) Common pitfalls

> **Pitfall:** dropping the minus sign and then misclassifying — elasticity is normally negative for demand; judge by the *magnitude*. **Pitfall:** computing elasticity across a huge price jump where the % change depends on the base you chose (the "base effect" again). **Pitfall:** assuming every industry responds to the same price changes — elasticity is specific to the good.

### 4) Key takeaways

- **Takeaway:** price is set where demand and supply meet — the equilibrium.
- **Takeaway:** elasticity = `%ΔQ / %ΔP`; magnitude < 1 means inelastic.
- **Takeaway:** elasticity explains why some businesses are cyclical and others are not.

## Lesson 1.5 — Financial calculators

### 1) Concept

A financial calculator (or Excel's `PV`, `FV`, `PMT` — you will meet them properly in M2) works with five variables: **N** (number of periods), **I/Y** (interest per period, in %), **PV** (present value), **PMT** (payment per period), and **FV** (future value). You enter any four and solve for the fifth. The one rule that trips everyone: **money in and money out have opposite signs** — a loan you receive is +PV, and the EMIs you pay are negative PMTs.

A **time value of money (TVM)** problem asks "what is money now worth later?" A **SIP** (systematic investment plan) is an annuity: you pay a fixed amount each month and the fund compounds it. A **bond yield** problem gives you coupon payments plus a final face-value payment, and asks what rate makes their present value equal today's price.

### 2) Worked example

SIP: you invest ₹5,000 at the end of each month for 12 months; the fund earns 12% p.a. (1% per month). Future value of an ordinary annuity:

```
FV = PMT x [ ((1 + r)^n - 1) / r ]
   = 5,000 x [ (1.01^12 - 1) / 0.01 ] = 5,000 x 12.6825 = ₹63,412.55
```

```python
from decimal import Decimal

pmt = Decimal("5000"); r = Decimal("0.01"); n = 12
fv = pmt * (((Decimal(1) + r) ** n - 1) / r)
print("SIP FV after 12 months:", fv.quantize(Decimal("0.01")))

# EMI on a ₹25,00,000 home loan, 8.5% p.a., 20 years (240 months)
loan = Decimal("2500000"); r_m = Decimal("0.085") / Decimal(12); n_m = 240
factor = (Decimal(1) + r_m) ** n_m
emi = loan * r_m * factor / (factor - 1)
print("monthly EMI:", emi.quantize(Decimal("0.01")))
```

Output: `SIP FV after 12 months: 63412.55`; `monthly EMI: 21696.93` (you will get the same `PMT` answer in Excel in M2).

### 3) Common pitfalls

> **Pitfall:** entering 12% instead of 1% per month (or forgetting to divide the annual rate by 12). **Pitfall:** sign errors — keying PMT and PV with the same sign returns nonsense. **Pitfall:** forgetting whether payments occur at period end (ordinary annuity) or period start (annuity due).

### 4) Key takeaways

- **Takeaway:** TVM has five variables; give four, solve the fifth.
- **Takeaway:** period rate = annual rate ÷ periods per year.
- **Takeaway:** signs encode direction of cash flow — in (+) and out (−).
- **Takeaway:** the same logic runs your Excel functions in M2 and your bond math in Semester 4.

## Tantra Lab 1 — Compound growth in Decimal

### Lab goal

Prove to yourself that a 10-year index journey from 10,000 to 24,000 compounds at ≈ 9.15% a year, and connect that to future value and the Rule of 72.

### Code

```python
from decimal import Decimal, getcontext

getcontext().prec = 28

def cagr(p0: Decimal, pn: Decimal, years: int) -> Decimal:
    return (pn / p0) ** (Decimal(1) / Decimal(years)) - Decimal(1)

# NIFTY-style index from 10,000 to 24,000 over 10 years
print(cagr(Decimal("10000"), Decimal("24000"), 10))  # ≈ 0.0915
```

**Task:** extend the script to compute future value of a lump sum at that CAGR,
and the doubling time. Compare with the Rule of 72. Run
`tantra-examples/examples/01_loading_data.py` to see the real bar data you will
use all semester.

### Expected output

`≈ 0.0915` (about 9.15% per year). The Rule of 72 says `72 / 9.15 ≈ 7.9` years to double; the log formula `ln(2)/ln(1.0915)` gives `≈ 7.93` years — the two agree within 0.1 year.

### Hand-in checklist

- [ ] Lab script saved as `lab1.py` in your `labs/` folder with the extension (lump-sum future value + doubling time) completed.
- [ ] Journal entry: the CAGR result in your own words, with the Decimal output pasted.
- [ ] Rule of 72 vs log-formula doubling time compared and written up (2 sentences).
- [ ] One screenshot/note from running `01_loading_data.py` (what fields does a bar have?).
- [ ] All money values typed as `Decimal` — reviewer checks for `float` and will fail the run.

### Common errors

- **"`TypeError: unsupported operand`"** — you divided a `Decimal` by an `int` from `years` before converting: wrap with `Decimal(years)`.
- **Rule-of-72 mismatch panics** — remember the rule is an approximation; a 0.1-year gap is expected, not a bug.
- **Reading 0.0915 as 0.09%** — multiply by 100 to speak "percent" (9.15%).

## Practice problems

1. You invest ₹20,000 at 8% p.a. compounded annually for 3 years. Compute the amount and the total interest earned.
2. RELIANCE moves from ₹2,800 to ₹3,150. What is the percentage change?
3. The repo rate falls from 6.5% to 5.5%. Express the change in percentage points and in relative (percent) terms.
4. A fund grows at 9% p.a. Estimate doubling time with the Rule of 72 and with logs. Which is more precise, and by how much?
5. You will receive ₹1,21,000 in 2 years. At a 10% discount rate, what is its present value today?
6. A 20% price rise reduces quantity demanded by 10%. Compute elasticity and classify the good as elastic or inelastic.

### Solutions

1. `A = 20000 x 1.08^3 = 20000 x 1.259712 = 25194.24`; interest = `25194.24 - 20000 = 3194.24`.
2. `(3150 - 2800) / 2800 = 350 / 2800 = 0.125 = 12.5%`.
3. 1.0 percentage point; relative fall `1.0 / 6.5 = 0.1538 = 15.38%`.
4. Rule of 72: `72/9 = 8` years; logs: `ln(2)/ln(1.09) = 0.69315/0.08618 = 8.04` years. The log result is precise; the rule is 0.04 years off.
5. `PV = 121000 / 1.10^2 = 100000` — exactly ₹1,00,000.
6. `Elasticity = -10 / 20 = -0.5`; magnitude < 1, so inelastic.

## Quiz bank

| Question | A | B | C | D | Answer |
|---|---|---|---|---|---|
| An investment of ₹1,00,000 at 10% simple interest for 2 years earns: | ₹10,000 | ₹20,000 | ₹21,000 | ₹2,000 | B |
| Compound interest on ₹10,000 at 10% for 2 years is: | ₹2,000 | ₹2,100 | ₹1,000 | ₹21,000 | B |
| A move from 6.5% to 6.0% in a rate is: | a 0.5% cut | a 0.5 percentage-point cut | a 7.69 percentage-point cut | no change | B |
| `PV = FV / (1 + r)^n` for FV = 1,21,000, r = 10%, n = 2 gives: | ₹1,21,000 | ₹1,00,000 | ₹1,10,000 | ₹98,000 | B |
| Doubling time at 10% by the Rule of 72 is: | 6.2 yrs | 7.2 yrs | 8.2 yrs | 10 yrs | B |
| Elasticity = −0.3 means demand is: | elastic | unit elastic | inelastic | infinite | C |
| The natural base of continuous compounding is: | π | e | 2.718 | 1.414 | B |
| The CAGR of an index going 10,000 → 24,000 in 10 years is about: | 24.0% | 14.0% | 9.15% | 2.4% | C |

## Glossary

- **Interest** — the price paid for using money over time.
- **Simple interest** — interest on the original principal only.
- **Compound interest** — interest on principal plus previously earned interest.
- **CAGR** — compound annual growth rate: the smooth annual rate that turns P0 into Pn over n years.
- **Percentage point** — the arithmetic difference between two percentages.
- **Base effect** — the influence of last period's base value on this period's growth %.
- **Index number** — one summary number built from many prices (Sensex, Nifty).
- **Discounting** — finding today's value (PV) of a future amount.
- **Elasticity** — `%ΔQ / %ΔP`; how responsive demand is to price.
- **Rule of 72** — `72 / rate%` approximates doubling time in years.
- **TVM** — time value of money: money today is worth more than the same money later.

## Reading assignment

Read the fundamentals & valuation section of the
[Reading & Resource List](../appendices/reading-list.md) and skim Benninga's
*Financial Modeling* introduction for the Excel habit that begins in M2. Keep
the NSE/BSE educational material list handy — the markets vocabulary you learn
here recurs daily.

## Assessment reminder

This module feeds the **Week-2 re-test of the diagnostic math sections** (you must clear 70%), your **daily drill tracker**, the **Lab 1.5 worksheet**, and the graded **Tantra Lab 1** journal entry — all part of continuous assessment and the S1 mid-term. See [Assessment & Grading Scheme](../front/assessment.md) for the pass gate that applies to every component.

**Next:** [M2 — Excel for Finance](m2-excel.md)
