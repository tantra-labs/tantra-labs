# M8 — Trading Terminal & Paper Trading Lab

> **Weeks 29–31 · 24 hrs lab · PLO-4 · Core reading:** Elder ch. 10; E&M ch. 40–42 (capital use, risk)

## Learning outcomes

- Operate a trading terminal (ODIN/NEST and modern web platforms): market watch,
  order entry, positions, P&L, alerts (per NIFM Ch 5).
- Place market/limit/SL orders on the **Tantra `PaperSession`**.
- Manage a **paper-trading journal** with rules, reasons, and lessons.
- Apply money-management rules: position sizing, stop placement, drawdown control.

## Lesson 8.1 — Terminal basics

- Market watch, order ticket, positions & P&L panels, alerts.
- Placing a trade; order types on the terminal (mirror M4 of S1).
- Reading the trade blotter.

## Lesson 8.2 — The Tantra paper terminal

`PaperSession` is a deterministic, seeded, exact-decimal paper exchange. It is
the safest possible place to learn order mechanics because a given seed
reproduces the identical tape — mistakes are reproducible and debuggable.

## Lesson 8.3 — Position sizing (Elder's risk rule)

Risk **≤ 1–2% of equity per trade**:

```
Qty = (equity × risk%) / (entry − stop)
```

This is the single most important money-management formula in the course — it
returns in S4-M7 risk management and S5-PM.

## Lesson 8.4 — The journal discipline

Every journal entry records: instrument, setup (with the pattern/indicator from
M1–M7), entry/stop/target with **why**, the rule that justifies it, outcome, and
one lesson. No loss-blame language.

## Tantra Lab 8 — A week of paper trading

```python
from decimal import Decimal
from tantra.paper import PaperSession
from tantra.instrument import InstrumentId

session = PaperSession(cash=Decimal("1_000_000"), seed=7)

reliance = InstrumentId("RELIANCE", "NSE")
session.set_market_price(reliance, Decimal("2500"))

# Risk 1% of equity with a 5% stop: qty = 10,000 / (2500 - 2375)
equity, risk_pct, stop_pct = Decimal("1_000_000"), Decimal("0.01"), Decimal("0.05")
risk_amount = equity * risk_pct
entry, stop = Decimal("2500"), Decimal("2500") * (1 - stop_pct)
qty = risk_amount / (entry - stop)
print("position qty:", qty)

session.place_order(reliance, "BUY", qty.to_integral_value(), order_type="LIMIT", limit_price=entry)
session.advance_to("2023-11-14T22:14:00Z")
print("fills:", session.fills())
```

**Task:** run the 3-week paper-trading plan: 10+ trades, every entry journaled
with the rules you learned in M1–M7, using the 1–2% sizing rule. Keep the
journal for the rest of the course — it is evidence of PLO-4.

## Assessment

- Terminal certification checklist (place, monitor, cancel, report).
- 3-week paper-trading journal (graded on completeness and honesty).

**Next:** [M9 — CFTe I Mock Sprint](m9-cfte-sprint.md)
