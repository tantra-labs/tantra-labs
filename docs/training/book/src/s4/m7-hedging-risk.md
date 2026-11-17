# M7 — Hedging & Risk Management

> **Weeks 59–60 · 16 hrs · PLO-9 · Core:** IFMC item 64; PGP T3-302

## Learning outcomes

- Hedge a portfolio with index futures (beta hedge).
- Use protective puts for tail risk.
- Apply the 1–2% position-size rule and stop discipline.
- Write a risk plan for a recommendation.

## Lesson 7.1 — Why hedging matters for analysts

- A research call is a *view with risk attached*; the report must say what
  happens if the view is wrong.
- Hedge ratio intuition: `Hedge notional = βp × Portfolio value`.

## Lesson 7.2 — Index-futures beta hedge

```
Number of contracts ≈ (βp × Portfolio Value) / (Futures price × Lot size)
```

- Short futures to hedge a long portfolio; rebalance as β drifts.
- Basis risk remains — futures hedge market risk, not stock-specific risk.

## Lesson 7.3 — Options for risk

- Protective put: floors the loss, costs a premium (the S4-M6 view).
- Collar: protective put + covered call to pay for the put.

## Lesson 7.4 — Position sizing and stops (Elder, revisited)

- `Qty = (Equity × Risk%) / (Entry − Stop)` — from S2-M8, now applied at
  portfolio scale.
- Stop placement by structure (S/R, pattern invalidation) or volatility (ATR).

## Lesson 7.5 — The risk plan in a research report

- Scenario table: bull/base/bear with P&L impact.
- Maximum loss if wrong; position size implied; stop if the thesis breaks.

## Tantra Lab 7 — Beta hedge sizing

```python
from decimal import Decimal

def hedge_contracts(portfolio_value, beta, fut_price, lot_size):
    return (beta * portfolio_value) / (fut_price * lot_size)

print("contracts:", hedge_contracts(Decimal("10_000_000"), Decimal("1.2"),
                                    Decimal("24000"), Decimal("75")))
```

**Task:** run a risk-managed paper trade (1% risk, structural stop, journaled).
Then write a one-page risk plan for the company you modelled in S3-M8:
bull/base/bear scenarios, max loss, and stop if the thesis breaks. Read
`tantra-examples/examples/strategies/04_risk_management.py` and
`backtesting/05_monte_carlo.py`.

## Assessment

- Hedging case study (portfolio → hedge design → journal).
- Risk-plan memo (1 page).

**Next:** [M8 — Currency & Fixed Income Markets](m8-currency-fixed-income.md)
