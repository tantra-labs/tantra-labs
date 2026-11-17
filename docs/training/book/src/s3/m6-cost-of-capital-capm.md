# M6 — Cost of Capital, CAPM & WACC

> **Weeks 41–42 · 16 hrs · PLO-7, PLO-8 · Core:** IFMC items 40, 42, 57–58; PGP T2-202

## Learning outcomes

- Decode the cost of debt (Kd), equity (Ke), and preference (Kp).
- Explain CAPM: `E(R) = Rf + β · (E(Rm) − Rf)`.
- Build a WACC with stated assumptions and sanity checks.
- State the three forms of market efficiency and their implications.

## Lesson 6.1 — Cost of debt (Kd)

- **Pre-tax Kd** = yield to maturity of the firm's debt.
- **After-tax Kd** = pre-tax × (1 − tax rate) — interest is tax-deductible.
- Credit spreads: risky debt costs more.

## Lesson 6.2 — Cost of equity via CAPM

```
Ke = Rf + β · (Rm − Rf)      (Capital Asset Pricing Model)
```

- `Rf` = risk-free rate (e.g., 10-yr G-sec yield).
- `β` = systematic risk sensitivity; `Rm − Rf` = market risk premium.
- **β estimation** (comes back properly in S4-M2 regression):
  `β = Cov(Ri, Rm) / Var(Rm)`.

## Lesson 6.3 — Cost of preference (Kp)

- `Kp = Dp / P0` (fixed dividend over current price) — perpetuities pricing.

## Lesson 6.4 — WACC

```
WACC = (E/V)·Ke + (D/V)·Kd·(1−t) + (P/V)·Kp
```

- `V = E + D + P`; weights at market values, not book values.
- Every assumption must be stated: beta source, risk premium, tax rate, weights.

## Lesson 6.5 — Market efficiency

- **Weak:** prices reflect past prices — technical analysis has no edge *in the
  efficient-market view* (the CFTe premise says otherwise — know both sides).
- **Semi-strong:** prices reflect public information — fundamental analysis has
  no edge without private insight.
- **Strong:** prices reflect everything, including private information.
- Implication: markets are *mostly* efficient; the analyst's job is finding the
  pockets where they are not (M7 valuation is exactly that hunt).

## Tantra Lab 6 — WACC in Decimal

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

## Assessment

- WACC computation assignment (2 companies, assumptions documented).
- Quiz: CAPM terms and efficiency forms.

**Next:** [M7 — Valuation Methods](m7-valuation-methods.md)
