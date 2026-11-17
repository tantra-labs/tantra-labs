# M4 — Market Microstructure & Participants

> **Weeks 6–8 · 20 hrs · PLO-1 · Mid-term exam (Week 8) covers M1–M4**

## Learning outcomes

- Name every participant in a trade and what each does.
- Trace an order from terminal to ledger and back (order lifecycle).
- Explain clearing, settlement (T+1), and the role of depositories (NSDL/CDSL).
- Describe order types: market, limit, stop-loss; intraday vs delivery.

## Prerequisites

- [M3 — How Capital Markets Work](m3-markets.md): the regulator–exchange–broker–clearing skeleton is now filled in with the people inside it.
- [M1 — Financial Literacy & Business Math](m1-math.md): the percentages in price bands and margins come straight from M1.
- [M2 — Excel for Finance](m2-excel.md) is not required here but helps you log the order lifecycle as a table.

## Lesson 4.1 — Market participants

### 1) Concept

A trade is a relay of specialised roles. At one end sits the investor — **retail** (individuals like you) or **institutional** — and institutions split into **domestic** and **foreign**: **FIIs/FPIs** (foreign institutional/portfolio investors), **DIIs** (domestic institutions such as mutual funds and insurance companies). Institutions dominate traded volume because they manage crores of rupees on behalf of savers.

In the middle sits the **broker** — a SEBI-registered firm that routes your order to the exchange (e.g., Zerodha, HDFC Securities, ICICI Direct) — and under them, **sub-brokers** or authorised persons who act as franchisees. The **stock exchange** (NSE/BSE/MCX) matches buy and sell orders in its matching engine. Behind the exchange, a **clearing corporation** (e.g., ICCL for NSE) becomes the *counterparty to both sides* of every trade — guaranteeing that if the buyer fails to pay, the seller still gets paid. Regulators — **SEBI** at the top, plus exchange self-regulation — write and enforce the rules. Finally, **market makers and liquidity providers** (in derivatives and some segments) stand ready to quote both sides, providing liquidity when no natural buyer/seller is around; their economics connect directly to the Semester 2 indicators and execution material.

### 2) Worked example

The cost side of a trade — retail buyer of 10 INFY shares at ₹1,850:

```
Brokerage (0.03%): 10 x 1,850 x 0.0003 = ₹5.55   (many brokers cap or zero this for delivery)
STT (0.1% on delivery buy, simplified): 18,500 x 0.001 = ₹18.50
Total cost ≈ 5.55 + 18.50 = ₹24.05
```

```python
from decimal import Decimal

qty = Decimal("10"); price = Decimal("1850")
gross = qty * price
brokerage = gross * Decimal("0.0003")
stt = gross * Decimal("0.001")
print("gross:", gross, "| brokerage:", brokerage, "| STT:", stt,
      "| total cost:", (brokerage + stt).quantize(Decimal("0.01")))
```

Output: `gross: 18500 | brokerage: 5.55 | STT: 18.50 | total cost: 24.05`. (SEBI updates these rates; the arithmetic habit is what you are being graded on, not the current table.)

### 3) Common pitfalls

> **Pitfall:** calling a sub-broker a broker — only the SEBI-registered broker deals with the exchange; the sub-broker is its franchisee. **Pitfall:** thinking the exchange guarantees *your* return — the clearing corporation guarantees *trade completion*, not price. **Pitfall:** ignoring costs — a 0.5% round-trip cost can swallow a small intraday profit.

### 4) Key takeaways

- **Takeaway:** the chain is investor → broker → exchange → clearing → depository, regulated by SEBI.
- **Takeaway:** FII/DII, mutual funds, and insurers are the institutional whales; retail trades alongside them.
- **Takeaway:** the clearing corporation is the guarantor that every matched trade completes.
- **Takeaway:** transaction costs are real money — always estimate them in Decimal.

## Lesson 4.2 — The order lifecycle

### 1) Concept

Follow one order end-to-end:

1. **Order entry** — you press "Buy 10 RELIANCE" on the broker's terminal; the order travels to the exchange.
2. **Matching** — the exchange's engine pairs your order against a resting order at the same or better price.
3. **Trade reporting & clearing** — the trade is reported to the clearing corporation, which nets everyone's obligations: on a net basis, you owe or are owed one number.
4. **Settlement** — securities and funds change hands. India settles equity in **T+1**: trade day is T, money and shares settle the *next business day*.
5. **Record-keeping** — the depository (NSDL or CDSL) updates who owns what; your broker's back office reflects it in your ledger.

The lifecycle is why "you bought shares" really means "a chain of systems agreed, cleared, settled, and recorded a transfer". In the paper-trading lab you will watch a resting limit buy and a crossing market sell *fill* — the first two steps made visible.

### 2) Worked example

The ledger after a buy then a sell (both at ₹100):

```
Start cash ₹1,000,000
Buy 10 @ 100 (fills):  cash -1,000, position +10 shares
Sell 10 @ market 100:   cash +1,000, position 0
Net: cash ₹1,000,000, no position — the lifecycle went full circle
```

```python
from decimal import Decimal
from tantra.paper import PaperSession
from tantra.instrument import InstrumentId

session = PaperSession(cash=Decimal("1000000"), seed=7)
r = InstrumentId("RELIANCE", "NSE")
session.set_market_price(r, Decimal("100"))
session.place_order(r, "BUY", Decimal("10"), order_type="LIMIT", limit_price=Decimal("100"))
session.place_order(r, "SELL", Decimal("10"), order_type="MARKET")
session.advance_to("2023-11-14T22:14:00Z")
print("fills:", session.fills())
print("cash :", session.cash(), "| equity:", session.equity(), "| positions:", session.positions())
```

Output: `fills:` two fill records (10 @ 100 each), `cash: 1000000`, `equity: 1000000`, `positions:` empty — the full-circle lifecycle.

### 3) Common pitfalls

> **Pitfall:** believing settlement is instant — India settles T+1, so intraday and delivery have different money flows. **Pitfall:** thinking the depository *is* the exchange — the exchange matches, the depository records ownership. **Pitfall:** ignoring that clearing *nets* — you don't settle every trade individually.

### 4) Key takeaways

- **Takeaway:** order → match → clearing → settlement (T+1) → depository records.
- **Takeaway:** the clearing corporation nets obligations so one number moves.
- **Takeaway:** ownership records live with NSDL/CDSL, not the exchange.
- **Takeaway:** the same lifecycle drives the paper-trading engine in the lab.

## Lesson 4.3 — Order types and price limits

### 1) Concept

The order types you type into the terminal differ in *when* they execute. A **market order** executes immediately at the best available price — speed, but no price guarantee. A **limit order** executes only at your price or better: a *buy* limit at ₹99 fills at ₹99 or less; a *sell* limit at ₹102 fills at ₹102 or more. A **stop-loss order** (stop order) is a trigger: when price crosses your stop level, it fires a market order to cut a loss. A **stop-limit** is a stop that becomes a limit order. **IOC** (immediate-or-cancel) fills what it can now and cancels the rest; auction orders participate in opening/closing price auctions.

Exchanges also *constrain* prices. **Daily price bands** (e.g., ±10% for most NSE cash stocks) reject orders outside the band — a defence against fat fingers and manipulation. **Market-wide circuit breakers** pause the *whole market* if an index falls a threshold (10/15/20%) in a day. Inside this course, `tantra-risk` — the engine you will meet in S2/S4 — enforces price bands pre-trade, which is the same idea in software.

### 2) Worked example

Stop-loss and circuit band arithmetic:

```
RELIANCE at ₹3,000; daily band ±10%:
  upper = 3,000 x 1.10 = 3,300    lower = 3,000 x 0.90 = 2,700
A sell stop at ₹2,900: if the price trades at or below 2,900,
it fires a market sell — but the actual fill can slip below 2,900.
```

```python
from decimal import Decimal

px = Decimal("3000")
print("upper band:", px * Decimal("1.10"), "| lower band:", px * Decimal("0.90"))
print("stop at 2900 -> fills near market, slippage possible:", px * Decimal("0.96"))
```

Output: `upper band: 3300 | lower band: 2700`; and a stop's fill is not guaranteed at the stop level — at a fast fall of 4% the fill would be ≈ ₹2,880.

### 3) Common pitfalls

> **Pitfall:** confusing stop-loss (trigger) with limit (price guarantee) — a stop *can* slip; a limit *cannot* overpay. **Pitfall:** thinking the price band is a recommendation — orders outside the band are *rejected*. **Pitfall:** entering a stop below the lower circuit for a stock already at its low — the order may be rejected, not queued.

### 4) Key takeaways

- **Takeaway:** market = speed, limit = price control, stop = loss trigger.
- **Takeaway:** daily price bands and market-wide circuit breakers are SEBI's crash dampers.
- **Takeaway:** a stop-loss is not a guarantee — slippage is real.
- **Takeaway:** order-type discipline is risk management, not cleverness.

## Lesson 4.4 — Margin basics

### 1) Concept

**Margin** is the deposit a broker demands so it can trust you to complete a trade. In the **cash** segment, delivery buying needs full payment; **intraday** trading lets you lever up with broker-provided margin (with the position squared off by market close). In **derivatives**, margin is the norm: you post a fraction of the contract value (say 20%) to control the full position, because futures and options settle daily through **mark-to-market (MTM)** — every day your position's gain or loss is credited or debited to your account. When losses eat the margin below the broker's **maintenance margin**, you get a **margin call**: deposit more money *today* or the broker squares off your position.

Margin is leverage — it multiplies both gains and losses. The 20% margin example below shows a 5% price fall costing you 25% of your margin. That asymmetry is why this course's risk modules (S2/S4) treat margin as danger, not as free money.

### 2) Worked example

Leverage and MTM:

```
Position: 100 shares of TCS @ ₹4,000 = ₹4,00,000 notional
Margin at 20%: ₹80,000 posted
If TCS falls 5% to ₹3,800: MTM loss = 100 x 200 = ₹20,000
Loss on margin = 20,000 / 80,000 = 25% — one day wiped a quarter of the margin
```

```python
from decimal import Decimal

qty = Decimal("100"); px = Decimal("4000"); margin_rate = Decimal("0.20")
notional = qty * px
margin = notional * margin_rate
new_px = px * Decimal("0.95")
mtm_loss = qty * (px - new_px)
print("notional:", notional, "| margin posted:", margin)
print("MTM loss:", mtm_loss, "| as % of margin:", (mtm_loss / margin * 100))
```

Output: `notional: 400000 | margin posted: 80000`, `MTM loss: 20000 | as % of margin: 25`.

### 3) Common pitfalls

> **Pitfall:** confusing cash-segment delivery (pay full) with intraday/derivatives margin (pay a fraction). **Pitfall:** ignoring maintenance margin — a margin call is a *demand*, not a suggestion. **Pitfall:** thinking a 5% adverse move costs 5% — on 20% margin it costs 25% of your capital.

### 4) Key takeaways

- **Takeaway:** margin = leverage = multiplied gains *and* losses.
- **Takeaway:** MTM prices positions daily and triggers margin calls.
- **Takeaway:** margin calls must be met the same day or the broker squares off.
- **Takeaway:** futures margin (S4-M5) is the same idea, formalised.

## Tantra Lab 4 — A paper order lifecycle

### Lab goal

Watch a complete order lifecycle — a resting limit buy and a crossing market sell — fill in a simulated market, and read the resulting cash, equity, positions, and events.

### Code

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

### Expected output

`fills:` two fill records (the BUY 10 @ ₹100 and the SELL 10 @ ₹100), `cash: 1000000`, `equity: 1000000`, with `positions()` showing zero and `events()` listing the order/lifecycle transitions in order.

### Hand-in checklist

- [ ] Lab output pasted into the journal with the lifecycle labelled: entry → match → fill → position/ledger update.
- [ ] `session.positions()` and `session.events()` printed and explained (which event fired first?).
- [ ] Order-lifecycle diagram assignment (hand-drawn or tool): boxes for investor, broker, exchange, clearing, depository with arrows.
- [ ] One paragraph connecting the lab to Lesson 4.2's five steps.
- [ ] All cash/equity values recorded as printed (Decimal) — no rounding to ints in the journal.

### Common errors

- **"No fills"** — the limit buy rests above/at market; if `limit_price` were below market it would still fill *at* market for a buy limit at/below; a buy limit *above* market fills immediately. Set the market price before placing orders.
- **Cash/equity look unchanged** — that's the correct full-circle outcome: buy then sell at the same price nets to the starting cash.
- **Forgetting `advance_to`** — without advancing time, resting orders may not fill; keep the call.

## Practice problems

1. List the five roles in the order lifecycle and name the Indian institution for each.
2. A retail investor buys 100 shares of INFY at ₹1,800 with 0.03% brokerage and 0.1% STT (simplified). Compute the total cost in Decimal.
3. What is the difference between a clearing corporation and a depository?
4. RELIANCE is at ₹3,050 with a ±10% band. Compute the upper and lower band prices, and say what happens to an order placed at ₹3,400.
5. Explain, with numbers, why a 5% adverse move hurts a 20%-margin position by 25%.
6. Why is a stop-loss order *not* a price guarantee?

### Solutions

1. Investor → broker (SEBI-registered broker) → exchange (NSE/BSE) → clearing corporation (ICCL) → depository (NSDL/CDSL).
2. Gross = `100 x 1800 = 1,80,000`; brokerage = `180000 x 0.0003 = 54.00`; STT = `180000 x 0.001 = 180.00`; total cost = `₹234.00`.
3. The clearing corporation guarantees and nets trade settlement; the depository holds and updates ownership records.
4. Upper = `3050 x 1.10 = 3,355`, lower = `3050 x 0.90 = 2,745`; an order at ₹3,400 is outside the band and rejected.
5. Notional `100 x 4000 = 4,00,000`; margin `80,000`; 5% fall = `20,000` MTM loss; `20000/80000 = 25%` of margin.
6. A stop *triggers* a market order; in a fast fall the fill price can be worse than the stop level (slippage). A limit order guarantees the price; a stop does not.

## Quiz bank

| Question | A | B | C | D | Answer |
|---|---|---|---|---|---|
| The guarantor of trade completion is the: | broker | clearing corporation | depository | regulator | B |
| India's equity settlement cycle is: | T+0 | T+1 | T+2 | T+5 | B |
| Ownership records are kept by: | NSE | SEBI | NSDL/CDSL | MCX | C |
| A buy order that fills only at or below ₹99 is a: | market order | stop order | limit order | auction order | C |
| A stop-loss order: | guarantees the exit price | triggers on a price breach | never fills | is a mutual fund | B |
| Daily price bands cause out-of-band orders to be: | queued | executed at best effort | rejected | auctioned | C |
| A 10% index fall triggers: | nothing | a market-wide circuit breaker | a margin call | a split | B |
| On 20% margin, a 5% adverse move costs about: | 5% | 10% | 25% | 40% | C |
| A margin call requires you to: | sell immediately always | deposit more margin | switch brokers | pay interest only | B |
| Market-wide circuit breakers are designed for: | normal days | extreme index moves | IPO days | budget days | B |

## Glossary

- **Retail / institutional investor** — individual vs professional/large investor (FII, DII, mutual fund, insurer).
- **Broker / sub-broker** — SEBI-registered firm routing orders / its franchisee.
- **Clearing corporation** — the central counterparty that guarantees trade settlement.
- **Depository** — NSDL/CDSL; the registry of who owns what.
- **Market maker** — a participant quoting both sides to provide liquidity.
- **Order lifecycle** — entry → matching → clearing → settlement (T+1) → depository record.
- **Market / limit / stop order** — immediate at best price / at a price or better / triggered market order.
- **Price band** — the daily ±% limit on a stock's price movement.
- **Circuit breaker** — a market-wide pause on extreme index moves.
- **Margin** — the deposit required to control a leveraged position.
- **Mark-to-market (MTM)** — daily marking of position gains/losses against the account.
- **Margin call** — the demand to top up margin or be squared off.

## Reading assignment

From the [Reading & Resource List](../appendices/reading-list.md), browse the NSE/BSE educational material on trading, clearing, and settlement, and the SEBI regulations on brokers and market infrastructure institutions. The platform script `tantra-examples/examples/basic/06_paper_trading.py` mirrors this lab if you want a longer lifecycle walk.

## Assessment reminder

M4 sits inside the **S1 mid-term exam (Week 8, covers M1–M4)** and carries the **order-lifecycle diagram assignment** and the **lab 4 journal entry** as continuous assessment. Settlement (T+1), margin, and order types are guaranteed mid-term questions. See [Assessment & Grading Scheme](../front/assessment.md) for weights and the pass gate.

**Next:** [M5 — Securities & Instruments](m5-instruments.md)
