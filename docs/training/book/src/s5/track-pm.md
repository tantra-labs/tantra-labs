# Track PM — Portfolio Management

> **Mirrors PGP T4(PM)-401/402/403 · Capstone: model portfolio + mandate-compliance memo**

## Modules

1. **Portfolio strategy** — equity/fixed income/alternatives across the
   efficient frontier; strategic vs tactical allocation (S4-M3 built up).
2. **Quantitative tools & techniques** — factor selection, risk models,
   performance attribution, rebalancing schedules.
3. **Operational & regulatory aspects of PM** — SEBI PM regulations, mandate
   compliance, reporting, client segregation.

## Capstone

Build a **model portfolio** with an explicit mandate:

- Universe + selection rule + weighting scheme + rebalance schedule.
- Mandate-compliance memo: how every position satisfies the mandate.
- Performance report: Sharpe, alpha, attribution vs benchmark.

## Lab surface

```python
from decimal import Decimal
from tantra.portfolio_strategy import (
    build_portfolio_strategy, EqualWeight, TopN, momentum,
    MonthlyFirstSession, NamedUniverse,
)

strategy = build_portfolio_strategy(
    universe=NamedUniverse("NIFTY50"),
    selector=TopN(10, momentum),
    weighting=EqualWeight(),
    schedule=MonthlyFirstSession(),
)
print(strategy)   # the whole construction, declaratively
```

Read `tantra-examples/examples/12_portfolio_allocation.py`,
`mutual_funds/04_portfolio_optimization.py`, and
`portfolio_strategy/*` in the wheel for the complete API.

## Out the other side

- NISM exams passed → complete the degree requirement → PM registration path.
- Immediate support roles: portfolio operations, fund accounting, research support.
