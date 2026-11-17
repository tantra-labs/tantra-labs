# M4 — Market Microstructure & Participants

> **Weeks 6–8 · 20 hrs · PLO-1 · Mid-term exam (Week 8) covers M1–M4**

## Learning outcomes

- Name every participant in a trade and what each does.
- Trace an order from terminal to ledger and back (order lifecycle).
- Explain clearing, settlement (T+1), and the role of depositories (NSDL/CDSL).
- Describe order types: market, limit, stop-loss; intraday vs delivery.

## Lesson 4.1 — Market participants

- Retail investor, institutional investor (FII/DII, mutual funds, insurance).
- Brokers and sub-brokers; stock exchanges; clearing corporations.
- Regulators: SEBI (India), exchange self-regulation.
- Market makers and liquidity providers (why they exist, link to S2).

## Lesson 4.2 — The order lifecycle

1. Investor → broker terminal (order).
2. Broker → exchange matching engine (order match).
3. Trade reported → clearing corporation (net obligations).
4. Settlement: securities vs funds (T+1 in India).
5. Depository records updated (NSDL/CDSL).

## Lesson 4.3 — Order types and price limits

- Market, limit, stop-loss, stop-limit; IOC/Auction.
- Price bands / circuit breakers (SEBI): daily price bands and market-wide
  circuit breakers. (The `tantra-risk` engine enforces price bands — see S2/S4.)

## Lesson 4.4 — Margin basics

- Why brokers ask for margin; cash vs derivatives margin.
- Mark-to-market and margin calls (foreshadows S4-M5 futures).

## Tantra Lab 4 — A paper order lifecycle

```python
from decimal import Decimal
from tantra.paper import PaperSession
from tantra.instrument import InstrumentId

session = PaperSession(cash=Decimal("1000000"), seed=7)
reliance = InstrumentId("RELIANCE", "NSE")
session.set_market_price(reliance, Decimal("100"))

buy_id  = session.place_order(reliance, "BUY",  Decimal("10"), order_type="LIMIT",  limit_price=Decimal("100"))
sell_id = session.place_order(reliance, "SELL", Decimal("10"), order_type="MARKET")
session.advance_to("2023-11-14T22:14:00Z")

print("fills:", session.fills())
print("cash :", session.cash(), "equity:", session.equity())
```

This mirrors `tantra-examples/examples/basic/06_paper_trading.py`. Observe how
a resting limit buy and a crossing market sell fill — the **order lifecycle**
made real. Then `session.positions()` and `session.events()` show the state
transitions.

## Assessment

- **Mid-term exam #1** (covers M1–M4).
- Order-lifecycle diagram assignment.

**Next:** [M5 — Securities & Instruments](m5-instruments.md)
