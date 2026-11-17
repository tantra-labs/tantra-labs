# M8 — Trading Terminal & Paper Trading Lab

> **Weeks 29–31 · 24 hrs lab · PLO-4 · Core reading:** Elder ch. 10; E&M ch. 40–42 (capital use, risk)

## Learning outcomes

- Operate a trading terminal (ODIN/NEST and modern web platforms): market watch,
  order entry, positions, P&L, alerts (per NIFM Ch 5).
- Place market/limit/SL orders on the **Tantra `PaperSession`**.
- Manage a **paper-trading journal** with rules, reasons, and lessons.
- Apply money-management rules: position sizing, stop placement, drawdown control.

## Prerequisites

- [M1–M7](../s2/overview.md): you need a *rule* to paper-trade — trends (M1),
  candles (M2), patterns (M3), indicators (M4/M6), gaps (M5), waves (M7).
- [S1 — order types](../s1/overview.md): market/limit/SL order mechanics.
- `Decimal` division and `to_integral_value()` for the sizing formula.

## Lesson 8.1 — Terminal basics

### 1) Concept

A trading terminal is your cockpit. Every serious terminal (ODIN, NEST, and the
modern web/mobile platforms used by Indian brokers) has five panels:

1. **Market watch** — live quotes for your instruments.
2. **Order ticket** — choose instrument, side, quantity, and order type
   (market/limit/SL — see S1-M4).
3. **Positions & P&L panel** — open positions with mark-to-market P&L.
4. **Order/trade blotter** — every order and fill, timestamped.
5. **Alerts** — price/indicator alerts.

The discipline of the terminal: *every* action — a buy, a cancel, a move of a
stop — is an entry in the blotter, and the blotter is your data.

### 2) Worked example

Reading the blotter: an order placed as `BUY 100 RELIANCE @ LIMIT 2500` shows
status `Open` → `Partially Filled` → `Filled` (or `Rejected`). The P&L panel
computes `(current − entry) × qty`:

```python
from decimal import Decimal
entry, current, qty = Decimal("2500"), Decimal("2540"), Decimal("100")
pnl = (current - entry) * qty
print("unrealised P&L:", pnl)   # 4000
```

### 3) Common pitfalls

> **Pitfall:** confusing the order blotter with positions. The blotter is what
> you *did*; positions is what you *hold*.
> **Pitfall:** typing quantity without the sizing formula — every ticket starts
> from risk, not from "how much I want to make".
> **Pitfall:** ignoring alerts. A good alert fires when *your* rule fires, not
> when the market "feels" ready.

### 4) Key takeaways

- **Takeaway:** five panels: watch, ticket, positions/P&L, blotter, alerts.
- **Takeaway:** P&L = `(current − entry) × qty`, in `Decimal`.
- **Takeaway:** the blotter is the audit trail of your discipline.

## Lesson 8.2 — The Tantra paper terminal

### 1) Concept

`PaperSession` is a deterministic, seeded, exact-decimal **paper exchange**. It
simulates fills, positions, cash, and equity without risking a rupee. Its
greatest teaching property: a given seed **reproduces the identical tape** —
mistakes are reproducible and debuggable. You `set_market_price`, `place_order`,
then `advance_to` a timestamp and inspect `fills()`, `positions()`, `equity()`,
`cash()`, and `events()`.

### 2) Worked example

Seed a session with ₹10,00,000 cash, set RELIANCE at 2,500, buy 400 shares at a
limit of 2,500, and advance the clock:

```python
from decimal import Decimal
from tantra.paper import PaperSession
from tantra.instrument import InstrumentId

session = PaperSession(cash=Decimal("1000000"), seed=7)
reliance = InstrumentId("RELIANCE", "NSE")
session.set_market_price(reliance, Decimal("2500"))
session.place_order(reliance, "BUY", Decimal("400"), order_type="LIMIT", limit_price=Decimal("2500"))
session.advance_to("2023-11-14T22:14:00Z")
print("fills:", session.fills())
print("cash:", session.cash())
```

### 3) Common pitfalls

> **Pitfall:** skipping `set_market_price` — a paper exchange needs a price to
> fill against, exactly like a live one.
> **Pitfall:** forgetting `advance_to` — orders stay open until the clock
> moves; the fill book only updates at the advance.
> **Pitfall:** reading `cash()` as equity — equity includes open-position
> mark-to-market; cash is what is left unspent.

### 4) Key takeaways

- **Takeaway:** `PaperSession(cash, seed)` is deterministic and reproducible.
- **Takeaway:** set price → place order → advance clock → inspect fills.
- **Takeaway:** paper P&L behaviour mirrors live P&L — the safest classroom
  there is.

## Lesson 8.3 — Position sizing (Elder's risk rule)

### 1) Concept

The single most important money-management formula in the course: risk **≤
1–2% of equity per trade**.

```
Qty = (equity × risk%) / (entry − stop)
```

The numerator is *how much you allow yourself to lose*; the denominator is *how
much one share loses if the stop is hit*; the quotient is the share count. This
is why M3's stop placement matters: a tighter stop means a larger position for
the same risk; a stop beyond a sane invalidation means a position you cannot
defend.

### 2) Worked example

Equity ₹10,00,000, risk 1%, entry 2,500, stop 5% below at 2,375:

```
risk_amount = 10,00,000 × 0.01 = ₹10,000
risk/share  = 2,500 − 2,375 = ₹125
qty         = 10,000 / 125 = 80 shares
```

```python
from decimal import Decimal
equity, risk_pct, stop_pct = Decimal("1_000_000"), Decimal("0.01"), Decimal("0.05")
risk_amount = equity * risk_pct
entry, stop = Decimal("2500"), Decimal("2500") * (1 - stop_pct)
qty = risk_amount / (entry - stop)
print("position qty:", qty)   # 80.0
print("risk check:", qty * (entry - stop), "==", risk_amount)   # 10000 == 10000
```

`qty` is fractional at 80.0 — a live ticket needs whole shares:
`qty.to_integral_value()` (the lab uses exactly this).

### 3) Common pitfalls

> **Pitfall:** sizing off "how much I can afford to invest" — the formula sizes
> off *what you can afford to lose*.
> **Pitfall:** using a stop closer than the structure allows (inside M3's
> invalidation) just to make the position bigger.
> **Pitfall:** forgetting the risk% stays at 1–2% even after a drawdown — the
> position *shrinks* as equity falls, which is the point.

### 4) Key takeaways

- **Takeaway:** `Qty = (equity × risk%) / (entry − stop)`.
- **Takeaway:** risk 1–2%, always, in `Decimal`.
- **Takeaway:** this formula returns in S4-M7 (risk) and S5-PM (portfolio).

## Lesson 8.4 — The journal discipline

### 1) Concept

The journal turns experience into learning. Every entry records:

1. **Instrument** and setup — with the pattern/indicator from M1–M7.
2. **Entry/stop/target with why** — the exact rule that justified each.
3. **Outcome** — fill price, exit, P&L.
4. **One lesson** — what changed in *you*.

The two rules of the journal: **no loss-blame language** (a loss with a followed
plan is a well-run trade that lost), and **the journal is a plan-checker** — if
your rule said buy at 2,500 and you bought at 2,510, that is the event to study.

### 2) Worked example

A journal row as a small data structure:

```python
from decimal import Decimal
entry = {"inst": "RELIANCE", "rule": "M4 MACD cross + M3 invalidation",
         "entry": Decimal("2500"), "stop": Decimal("2375"), "target": Decimal("2650"),
         "outcome": "stop hit", "lesson": "waited for close beyond trigger"}
print("rule followed:", entry["entry"] == Decimal("2500"))   # True — plan kept
```

### 3) Common pitfalls

> **Pitfall:** journaling only winners — the losers are where the lessons are.
> **Pitfall:** writing "I think it will go up" instead of the *rule* that fired.
> **Pitfall:** blaming the market ("bad luck") — blame the process, then fix
> the process.

### 4) Key takeaways

- **Takeaway:** instrument, rule, entry/stop/target + why, outcome, one lesson.
- **Takeaway:** a followed plan that loses is a good trade.
- **Takeaway:** no loss-blame language — ever.

## Tantra Lab 8 — A week of paper trading

### Lab goal

Place a correctly sized (1% risk) paper order on `PaperSession`, watch it fill
after `advance_to`, and start the 3-week paper-trading journal.

### Code

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

### Expected output

`position qty: 80.0` then `fills: [...]` — one fill of 80 RELIANCE shares at
2,500 (the limit price matched the market price at advance). `session.cash()`
would read ₹10,00,000 − 80×2,500 = ₹8,00,000; equity equals cash plus the
position's mark-to-market.

### Hand-in checklist

- [ ] The `position qty: 80.0` and `fills:` lines in the journal.
- [ ] A rerun with `seed=8` — and a note on whether fills changed (determinism
      check).
- [ ] 10+ journaled trades over the 3-week plan, each with rule, why,
      outcome, lesson.
- [ ] A sizing audit: every trade's qty equals `risk_amount / (entry − stop)`.
- [ ] Drawdown control: the largest drawdown in the journal and the position
      size that followed it.

### Common errors

- **Forgetting `set_market_price`** — a missing price means no fill.
- **Placing a fractional qty** — `qty.to_integral_value()` before
  `place_order`; `Decimal("80.0")` is not a valid share count.
- **Calling `fills()` before `advance_to`** — fills happen on the clock move,
  not at placement.

## Practice problems

1. Equity ₹5,00,000, risk 2%, entry 1,000, stop 950. Compute qty (whole shares).
2. Same trade, but the stop moves to 975. What happens to qty, and what is the
   lesson for stop placement?
3. After a losing streak equity falls to ₹4,00,000. What is the *new* qty for
   the same 1,000/950 setup at 1% risk — and why must it be smaller?
4. A paper order is placed but `fills()` stays empty. Name the three things to
   check, in order.
5. P&L: bought 100 at 2,500, price now 2,540. Compute unrealised P&L. Now price
   falls to 2,470 — what is the P&L?
6. List the five terminal panels and what each is *for*, in one line each.
7. Write one journal row (rule, entry, stop, target, outcome, lesson) for a
   trade you would like to have taken this week.
8. Why is "a followed plan that loses" a good trade? Connect to the honesty
   checklist of M6.

### Solutions

1. `qty = (5,00,000 × 0.02) / 50 = 10,000 / 50 = 200` shares.
2. `qty = 10,000 / 25 = 400` — the tighter stop doubles size. Lesson: stops are
   set by *structure* (M3 invalidation), and size follows; never tighten a stop
   to force a bigger position.
3. `qty = (4,00,000 × 0.01) / 50 = 4,000 / 50 = 80` — smaller equity caps the
   risk in rupees, so fewer shares; that is survival by design.
4. (1) Was `set_market_price` called? (2) Was `advance_to` called? (3) Did the
   limit price match the market price at advance?
5. `(2540 − 2500) × 100 = 4,000`; then `(2470 − 2500) × 100 = −3,000`.
6. Watch = quotes; ticket = orders; positions/P&L = what you hold and its
   value; blotter = audit trail; alerts = rule triggers.
7. Example: RELIANCE, "M4 MACD cross + 3-bar close above trigger", entry 2,500,
   stop 2,375, target 2,650, outcome "open", lesson "rule was clear; sizing
   followed plan".
8. Because the *process* is what you control and what repeats: a followed plan
   produces a measurable, reviewable, reproducible edge (the honesty checklist);
   an unfollowed winner teaches nothing and cannot be repeated.

## Quiz bank

| Question | A | B | C | D | Answer |
|---|---|---|---|---|---|
| Position qty = | (equity × risk%) / (entry − stop) | equity / entry | risk / stop | entry − stop | A |
| The recommended per-trade risk is | 5–10% | 1–2% | 25% | 50% | B |
| `PaperSession` is best described as | A live broker | A seeded paper exchange | A charting tool | A screener | B |
| Fills appear when | The order is placed | `advance_to` is called | The seed changes | `cash()` is read | B |
| Unrealised P&L equals | (current − entry) × qty | entry × qty | current × qty | stop × qty | A |
| `qty.to_integral_value()` | Rounds to whole shares | Adds a stop | Sets the price | Clears the session | A |
| The journal's first rule is | Win every trade | No loss-blame language | Trade daily | Bigger after losses | B |
| After a drawdown, position size should | Stay the same | Grow | Shrink | Double | C |
| A trade whose plan was followed but lost is | Bad | A good trade | Random | To hide | B |
| Sizing must be anchored to | Affordability | Risk per trade | Brokerage | Hope | B |

## Glossary

- **Terminal** — the trading platform: watch, ticket, positions, blotter,
  alerts.
- **Market watch** — live quotes panel.
- **Blotter** — the timestamped record of orders and fills.
- **Paper trading** — trading simulated markets with no real money.
- **PaperSession** — the wheel's seeded, deterministic paper exchange.
- **Position sizing** — computing share count from risk and stop distance.
- **Risk per trade** — the fraction of equity at risk (1–2%).
- **Stop** — the invalidation price that closes a losing trade.
- **Unrealised P&L** — `(current − entry) × qty` on an open position.
- **Drawdown** — the peak-to-trough fall in equity.
- **Journal** — the record of rules, reasons, outcomes, and lessons.
- **Revenge trading** — oversized re-entry after a loss; forbidden.

## Reading assignment

- Elder, *Trading for a Living*, ch. 10 (risk and money management).
- Edwards & Magee, *Technical Analysis of Stock Trends*, ch. 40–42 (capital
  use, risk).
- Platform: run `tantra-examples/examples/basic/06_paper_trading.py` for the
  full paper-session walkthrough.
- Full list: [Reading & Resource List](../appendices/reading-list.md).

## Assessment reminder

This module feeds the **terminal certification checklist** (place, monitor,
cancel, report — a graded practical) and the **3-week paper-trading journal**
(graded on completeness and honesty, as evidence of PLO-4). See
[Assessment](../front/assessment.md).

## Assessment

- Terminal certification checklist (place, monitor, cancel, report).
- 3-week paper-trading journal (graded on completeness and honesty).

**Next:** [M9 — CFTe I Mock Sprint](m9-cfte-sprint.md)
