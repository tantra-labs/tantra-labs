# M5 — Time Value of Money & Capital Budgeting

> **Weeks 40–41 · 16 hrs · PLO-7 · Core:** NIFM Ch 22; IFMC items 20–21, 48–49

## Learning outcomes

- Compute FV, PV, annuities, and perpetuities.
- Apply the NPV rule and IRR with its pitfalls.
- Compute holding-period return (HPR) and yield (HPY).
- Make an accept/reject capital-budgeting decision.

## Lesson 5.1 — Time value of money

- `FV = PV × (1 + r)^n`; `PV = FV / (1 + r)^n`.
- Annuities and perpetuities:

```
PV annuity     = PMT × [1 − (1+r)^−n] / r
PV perpetuity  = PMT / r
```

## Lesson 5.2 — HPR and HPY

```
HPR = (Ending Value − Beginning Value + Income) / Beginning Value
HPY = HPR × 100   (as a percentage)
```

- HPY for a single period; annualize with compounding for multi-period returns.

## Lesson 5.3 — NPV and IRR

```
NPV = Σ CF_t / (1 + r)^t − Initial Investment
```

- **NPV rule:** accept if NPV ≥ 0 (at the firm's cost of capital).
- **IRR:** the rate that makes NPV = 0.
- IRR pitfalls: multiple IRRs for non-conventional cash flows; IRR vs scale;
  reinvestment-rate assumption. Prefer NPV in conflicts.

## Lesson 5.4 — Capital budgeting & cost of capital

- Payback (and discounted payback), profitability index.
- The discount rate is the **cost of capital** (M6) — the two lessons connect.

## Tantra Lab 5 — NPV in Decimal

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

## Assessment

- 10-problem TVM/capital-budgeting worksheet.
- Quiz: NPV vs IRR.

**Next:** [M6 — Cost of Capital, CAPM & WACC](m6-cost-of-capital-capm.md)
