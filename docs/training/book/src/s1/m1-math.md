# M1 — Financial Literacy & Business Math Bootcamp

> **Weeks 1–2 · 24 hrs · PLO-1, PLO-7 prerequisites**

## Learning outcomes

- Compute percentages, ratios, growth rates, CAGR, and compounding without error.
- Use exponents and logarithms for finance problems.
- Explain demand, supply, and elasticity at an intuitive level.
- Operate a financial calculator for TVM-style inputs.

## Lesson 1.1 — Money, savings, and interest

- What money is; savings vs investment; the risk-return trade-off.
- Simple interest vs compound interest.
- **CAGR**: with an investment that grows from `P0` to `Pn` over `n` years,

  ```
  CAGR = (Pn / P0) ** (1 / n) - 1
  ```

- The "Rule of 72" for doubling time.

## Lesson 1.2 — Percentages, ratios, and growth

- Percentage change, percentage points (inflation jargon), base effects.
- Ratios: margin, debt-equity intuition, proportions.
- Index numbers: how Sensex/Nifty-style indices aggregate many prices into one
  number (weighted average intuition; the exact index formulas come in M3).
- Growth rates: YoY vs QoQ, annualization of quarterly figures.

## Lesson 1.3 — Exponents, logs, and financial formulas

- `e`, natural log, and why continuous compounding appears in option pricing
  (foreshadowing Semester 4).
- Discounting: `PV = FV / (1 + r)^n`.
- Estimating doubling/halving times with logs.

## Lesson 1.4 — Demand, supply, and elasticity

- Demand/supply curves, equilibrium price.
- Elasticity as `% change in quantity / % change in price`.
- Elastic vs inelastic goods; why some industries are cyclical (foreshadows
  S3-M1 economics and S3-M2 industry analysis).

## Lesson 1.5 — Financial calculators

- `N, I/Y, PV, PMT, FV` conventions on a standard financial calculator.
- Practice problems: mortgage payments, SIP future value, bond yields.

## Tantra Lab 1 — Compound growth in Decimal

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

## Assessment

- Week-2 re-test of the diagnostic math sections (must clear 70%).
- Daily drill tracker (10 problems/night).
- Lab 1.5 worksheet: 10 calculator problems, both hand and calculator.

**Next:** [M2 — Excel for Finance](m2-excel.md)
