# M7 — Valuation Methods

> **Weeks 43–45 · 24 hrs · PLO-7 · Core:** NIFM Ch 23–24, 36; IFMC items 34–35, 50, 55, 59, 66

## Learning outcomes

- Value a stock with the dividend discount model (DDM).
- Run a DCF: project FCFF/FCFE, apply WACC, compute terminal value.
- Use relative valuation: PE/PB/EV/EBITDA, comps, and SOTP.
- Reconcile methods into a price target with a confidence band.

## Lesson 7.1 — Dividend Discount Model (DDM)

Gordon growth:

```
P0 = D1 / (Ke − g)      (requires Ke > g)
```

- DDM works best for mature, stable payers; fails for growth companies that
  pay no dividends.

## Lesson 7.2 — Discounted cash flow (DCF)

Two approaches:

```
FCFF  (free cash flow to firm)  → discount at WACC  → Enterprise Value
FCFE  (free cash flow to equity) → discount at Ke   → Equity Value
```

```
FCFF = EBIT·(1−t) + D&A − Capex − ΔNWC
FCFE = FCFF − Interest·(1−t) + Net Borrowing
```

Terminal value (Gordon): `TV = FCF_T·(1+g) / (r − g)`.

## Lesson 7.3 — Relative valuation & comps

- Multiples: PE, PB, EV/EBITDA, EV/Sales — pick what the industry trades on.
- **Comps:** peer set, median multiple, apply to your company's metric.
- **EV/EBITDA** strips leverage effects — the workhorse for cross-company work.

## Lesson 7.4 — SOTP (sum of the parts)

- Conglomerates: value each business line separately, then sum, then subtract
  holding-company discount.

## Lesson 7.5 — Reconciling to a price target

- Average (or range) across methods; weight by method confidence.
- Output: **target price + range + key sensitivities** (rate up/down, growth
  up/down). This is what a research report's target price actually is.

## Tantra Lab 7 — DDM and DCF in Decimal

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

## Assessment

- Valuation memo (single company: DCF + multiples + SOTP, target with range).
- Quiz: model selection.

**Next:** [M8 — Financial Modeling](m8-financial-modeling.md)
