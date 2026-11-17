# M7 — Hedging & Risk Management

> **Weeks 59–60 · 16 hrs · PLO-9 · Core:** IFMC item 64; PGP T3-302

## Learning outcomes

- Hedge a portfolio with index futures (beta hedge).
- Use protective puts for tail risk.
- Apply the 1–2% position-size rule and stop discipline.
- Write a risk plan for a recommendation.

## Prerequisites

- [M2](m2-correlation-regression.md): beta is the hedge ratio's core input.
- [M5](m5-forwards-futures.md): futures margins, lot sizes, MTM — a hedge is a futures position.
- [M6](m6-options.md): protective put and collar construction and their premiums.
- [S2-M8](../s2/m8-position-sizing-risk.md) (or equivalent): the position-size rule and stop discipline — this module applies them at portfolio scale.

## Lesson 7.1 — Why hedging matters for analysts

### 1) Concept

A research call — "Buy RELIANCE" — is a **view with risk attached**. The market can move against the view for reasons that have nothing to do with the thesis: a macro shock, a sector rotation, a liquidity crunch. An analyst who only states the upside is writing a story, not a report. **Hedging** is the discipline of stating and then *managing* the "what if the view is wrong" side.

The analyst's hedge logic starts from the **hedge ratio intuition**: if your portfolio is β times as risky as the market, you need β times the notional exposure hedged.

```
Hedge notional ≈ βp × Portfolio value
```

For a diversified long book, the dominant risk is *market risk* — the whole index falling. That risk can be laid off with index futures (Lesson 7.2) or floored with index/stock puts (Lesson 7.3). The residual is **specific risk** (company news) that futures cannot hedge; that is where stops and position sizing (Lesson 7.4) take over. Hedging is not "removing all risk" — it is *choosing which risks to carry* and paying consciously for the ones you remove.

### 2) Worked example

A ₹10 crore portfolio has β = 1.2. How much market exposure should a full hedge target?

```
Hedge notional = 1.2 × 10,000,000 = ₹12,000,000
```

If the index falls 5% tomorrow, the unhedged portfolio falls ≈ 1.2 × 5% = 6% (≈ ₹60 lakh); the hedged portfolio holds its value against the market leg.

```python
from decimal import Decimal
pv = Decimal("10_000_000")
beta = Decimal("1.2")
hedge_notional = beta * pv
print("hedge notional:", hedge_notional)   # ₹12,000,000
```

### 3) Common pitfalls

> **Pitfall:** Hedging *everything*. A 100% hedge converts a stock pick into a cash position — you pay hedge costs to cancel your own view.
>
> **Pitfall:** Ignoring β drift — the hedge ratio must be re-estimated as the portfolio changes.
>
> **Pitfall:** Thinking futures hedge specific risk — they hedge the market leg only.
>
> **Pitfall:** Writing a report with upside and no downside scenario (Lesson 7.5 fixes this).

### 4) Key takeaways

- **Takeaway:** A research call is a view with risk attached — hedging is how you manage it.
- **Takeaway:** Hedge notional ≈ β × portfolio value.
- **Takeaway:** Futures hedge market risk; specific risk needs stops and sizing.
- **Takeaway:** Hedging is choosing which risks to carry, deliberately.

## Lesson 7.2 — Index-futures beta hedge

### 1) Concept

The **beta hedge** sells index futures against a long portfolio so that a market fall is offset by a futures gain. The contract count comes from scaling the hedge notional by the futures contract's size:

```
Number of contracts ≈ (βp × Portfolio Value) / (Futures price × Lot size)
```

`Futures price × Lot size` is the notional each contract controls (M5). For a ₹10 crore, β=1.2 portfolio with NIFTY futures at 24,000 (lot 75, so ₹18 lakh per contract):

```
Contracts ≈ 12,000,000 / 1,800,000 ≈ 6.7 → 7 contracts
```

Why β multiplies the *value*: a β=1.2 book moves 1.2% when the market moves 1%, so it needs 1.2× the notional of protection. Two practical notes. First, **rebalance as β drifts**: as the portfolio's composition changes, recompute the contract count. Second, **basis risk remains**: the hedge removes *market* risk but the futures-spot basis (M5) and the portfolio's imperfect correlation with the index leave a residual. A short futures hedge on a long book is the textbook tail; you also pay the roll cost when you extend it past expiry.

### 2) Worked example

Portfolio ₹10 crore, β = 1.2. NIFTY futures at 24,000, lot 75.

```
Per-contract notional = 24000 × 75 = 1,800,000
Hedge notional = 1.2 × 100,000,000 = 120,000,000
Contracts = 120,000,000 / 1,800,000 = 66.67 → 67 contracts
```

With 67 short contracts, a 5% market fall (portfolio −6% before hedge ≈ −₹60 lakh) produces a futures gain of `67 × 75 × (24000×0.05)` = 67 × 75 × 1,200 = ₹60.3 lakh — roughly offsetting the market leg.

```python
from decimal import Decimal

def hedge_contracts(portfolio_value, beta, fut_price, lot_size):
    return (beta * portfolio_value) / (fut_price * lot_size)

print("contracts:", hedge_contracts(Decimal("10_000_000"), Decimal("1.2"),
                                    Decimal("24000"), Decimal("75")))
```

Answer: ≈ 66.67 → you would sell 67 contracts (rounding up adds a sliver of over-hedge, rounding down under-hedges).

### 3) Common pitfalls

> **Pitfall:** Forgetting lot size — dividing by futures price alone massively over-counts contracts.
>
> **Pitfall:** Rounding the wrong way — rounding *up* slightly over-hedges (safe), rounding down leaves tail risk.
>
> **Pitfall:** Treating the hedge as permanent — futures expire; rollover costs and basis drift (M5) apply.
>
> **Pitfall:** Expecting a perfect hedge — basis risk and specific risk always remain.

### 4) Key takeaways

- **Takeaway:** Contracts ≈ (β × PV) ÷ (futures price × lot).
- **Takeaway:** β scales the hedge because it scales the portfolio's market exposure.
- **Takeaway:** Rebalance as β drifts; the hedge is a living position.
- **Takeaway:** Basis and specific risk survive the hedge.

## Lesson 7.3 — Options for risk

### 1) Concept

Futures hedge the *market* leg; options are how you floor *specific* risk and tail risk. The **protective put** (M6) — long stock + long put at strike K — sets a hard floor on the position: below K, the put's gain offsets the stock's loss, so maximum loss = `S0 − K + premium`. It is insurance: you pay the premium (and theta, M6) to cap the downside while keeping unlimited upside.

The **collar** is the frugal version: long stock + long put *+ short call at a higher strike*. The short call's premium *pays for* the put. The trade-off: you give up upside above the call strike. A collar converts an open-ended position into a defined band [K_put, K_call] with a small or zero net cost. This is why the collar is the standard structure for a large concentrated holding you cannot sell (a promoter's stake, an ESOP block).

Both structures are priced with M6's machinery: the put's cost comes from `bs_price(..., kind="put")`, and the collar's net cost is `put − call`. For a research report (M7's deliverable), the protective-put premium is the *measurable price of your tail insurance*.

### 2) Worked example

RELIANCE at 3,000. A 2,900-strike put costs 60; a 3,100-strike call pays 40.

```
Protective put: max loss = 3000 − 2900 + 60 = 160
Collar: net cost = 60 − 40 = 20 (put paid for by the call)
Collar payoff band = [2900, 3100]; below 2900 the put floors it,
above 3100 the short call caps it.
```

The collar caps the downside at ~160 for a net premium of only 20 — insurance at 12.5% of the naked-put price, at the cost of surrendering gains above 3,100.

```python
from decimal import Decimal
S0, K_put, K_call = Decimal("3000"), Decimal("2900"), Decimal("3100")
put_p, call_p = Decimal("60"), Decimal("40")

max_loss_put = S0 - K_put + put_p
net_collar   = put_p - call_p
print("protective put max loss:", max_loss_put)   # 160
print("collar net cost:", net_collar)             # 20
```

### 3) Common pitfalls

> **Pitfall:** Treating the put premium as a loss forever — it is the price of *removing* a possible larger loss.
>
> **Pitfall:** Setting the collar band too tight — a 1% band triggers both legs constantly and converts the position to a coin flip.
>
> **Pitfall:** Forgetting the short call in a collar caps upside — clients must accept that trade-off.
>
> **Pitfall:** Pricing the collar legs from memory — use `bs_price` for both legs in Decimal.

### 4) Key takeaways

- **Takeaway:** Protective put = hard floor for a premium; max loss = S0 − K + premium.
- **Takeaway:** Collar = put paid for by a short call; defined band, low net cost.
- **Takeaway:** The collar caps upside in exchange for cheap insurance.
- **Takeaway:** Options price tail risk; futures lay off the market leg.

## Lesson 7.4 — Position sizing and stops (Elder, revisited)

### 1) Concept

Futures and puts manage *existing* exposure; **position sizing and stops** prevent a single bet from ever becoming a blow-up. The rule (from S2-M8, now at portfolio scale):

```
Qty = (Equity × Risk%) / (Entry − Stop)
```

Risk no more than **1–2% of equity per trade**. `Risk%` is the fraction of equity you accept losing if the stop is hit; `Entry − Stop` is the per-share loss at the stop. The formula derives the *quantity* such that the trade's worst case equals exactly `Equity × Risk%`. Example: ₹10 lakh equity, risk 1% (₹10,000), entry 100, stop 90 → per-share loss 10 → Qty = 10,000/10 = 1,000 shares.

**Stop placement** is structural or volatility-based: below a support/level that invalidates the thesis (structural), or at `Entry − k×ATR` using the wheel's `Atr` indicator (volatility-based). The stop is *pre-committed*: once placed, emotion (M3's loss aversion) must not move it. The discipline converts "I think it will rise" into "I risk exactly 1% to test that thought."

### 2) Worked example

Equity ₹10,00,000; risk 1%; entry 100; stop 90.

```
Qty = (1,000,000 × 0.01) / (100 − 90) = 10,000 / 10 = 1,000 shares
```

At the stop, the loss is 1,000 × 10 = ₹10,000 = exactly 1% of equity. If the stop were at 95, the per-share risk doubles to 5 → Qty = 2,000 shares and the *same* 1% loss — the tighter stop buys a bigger position, not a bigger risk.

```python
from decimal import Decimal
equity, risk_pct = Decimal("10_00_000"), Decimal("0.01")
entry, stop = Decimal("100"), Decimal("90")

qty = (equity * risk_pct) / (entry - stop)
print("quantity:", qty)               # 1,000 shares
print("loss at stop:", qty * (entry - stop))   # ₹10,000
```

### 3) Common pitfalls

> **Pitfall:** Sizing by "how much I like the stock" instead of the formula — the 1–2% cap exists exactly because conviction is cheap and losses are expensive.
>
> **Pitfall:** Moving the stop to avoid a loss (the disposition effect). Pre-commit; do not re-negotiate with the market.
>
> **Pitfall:** Risking 1% *per share* instead of per trade — `Risk%` applies to total equity.
>
> **Pitfall:** Placing stops inside the daily noise — a stop at 99.5 when ATR is 2 will trigger on noise; use structure or `k×ATR`.

### 4) Key takeaways

- **Takeaway:** `Qty = (Equity × Risk%)/(Entry − Stop)` — risk per trade is fixed at 1–2%.
- **Takeaway:** The stop is pre-committed; loss aversion must not move it.
- **Takeaway:** Tighter stops fund bigger positions without bigger risk.
- **Takeaway:** Place stops by structure (thesis invalidation) or volatility (ATR).

## Lesson 7.5 — The risk plan in a research report

### 1) Concept

Every recommendation in this course ends with a **risk plan** — the section that answers "what happens if the view is wrong, and what did I pre-decide to do about it?" A one-page risk plan has three parts.

First, a **scenario table**: bull / base / bear cases, each with a price target and the P&L impact on the portfolio. Second, the **maximum loss if wrong**: computed with the position-size rule (Lesson 7.4) — the number the client can check. Third, the **stop if the thesis breaks**: the structural or volatility level at which the recommendation is objectively wrong, and the pre-committed action (exit, or roll into the hedge).

The plan's discipline is that the *bear case is written first, before conviction sets in* — the analyst writes the exit criteria at the same moment as the buy case. Hedges (Lesson 7.2–7.3) may appear in the plan as the *contingent* structure: "if the index breaks support, we short 67 futures contracts" — a pre-written trade, not a panicked one. This is the professional translation of "hope for the best, plan for the worst."

### 2) Worked example

A buy recommendation on a stock at 100, equity ₹10 lakh, risk 1%, stop 90 (structural, below support).

```
Bull (target 120): P&L = 1000 shares × 20 = +20,000 (+2% of equity)
Base (target 110): P&L = 1000 × 10 = +10,000 (+1%)
Bear (stop 90):    P&L = 1000 × −10 = −10,000 (−1%, the pre-decided max)
Thesis-break action: exit at 90; if a market crash is the driver, the S4-M7
contingency is 67 short NIFTY futures against the book.
```

The plan's worst case is known, bounded, and pre-decided — that is what separates a recommendation from a tip.

```python
from decimal import Decimal
qty = Decimal("1000")
bull = qty * (Decimal("120") - Decimal("100"))
base = qty * (Decimal("110") - Decimal("100"))
bear = qty * (Decimal("90")  - Decimal("100"))
print("bull:", bull, "base:", base, "bear:", bear)   # +20,000 / +10,000 / −10,000
```

### 3) Common pitfalls

> **Pitfall:** Writing the risk plan last — by then conviction has already edited the bear case. Write it with the thesis.
>
> **Pitfall:** Vague bear cases ("could go down") — a scenario needs a *number* and a *trigger*.
>
> **Pitfall:** Recommending without a pre-committed stop — an exit criterion decided during a loss is an emotional trade.
>
> **Pitfall:** Omitted hedge contingency — state what you will do if the market, not just the stock, turns.

### 4) Key takeaways

- **Takeaway:** A recommendation carries a one-page risk plan: scenarios, max loss, stop.
- **Takeaway:** Write the bear case before conviction edits it.
- **Takeaway:** Every loss number must trace to the position-size rule.
- **Takeaway:** Pre-committed hedges and stops replace panicked decisions.

## Tantra Lab 7 — Beta hedge sizing

### Lab goal

Size an index-futures beta hedge in Decimal, then run a risk-managed paper trade and write the one-page risk plan.

### Code

The verified core snippet is unchanged; the extension adds a position-size computation alongside the hedge.

```python
from decimal import Decimal

def hedge_contracts(portfolio_value, beta, fut_price, lot_size):
    return (beta * portfolio_value) / (fut_price * lot_size)

print("contracts:", hedge_contracts(Decimal("10_000_000"), Decimal("1.2"),
                                    Decimal("24000"), Decimal("75")))

# --- extend: 1% position-size rule at portfolio scale -----------------------
def position_size(equity, risk_pct, entry, stop):
    return (equity * risk_pct) / (entry - stop)

equity = Decimal("10_00_000")
qty = position_size(equity, Decimal("0.01"), Decimal("100"), Decimal("90"))
print("qty at 1% risk:", qty)                       # 1,000 shares
print("worst-case loss:", qty * (Decimal("100") - Decimal("90")))  # ₹10,000
```

**Task:** run a risk-managed paper trade (1% risk, structural stop, journaled). Then write a one-page risk plan for the company you modelled in S3-M8: bull/base/bear scenarios, max loss, and stop if the thesis breaks. Read `tantra-examples/examples/strategies/04_risk_management.py` and `backtesting/05_monte_carlo.py`.

### Expected output

The script prints a hedge of ≈ 66.67 contracts (round to 67 for a short hedge) for the ₹10 crore, β=1.2 book against NIFTY at 24,000, then a position size of 1,000 shares whose worst-case loss is exactly ₹10,000 (1% of the ₹10 lakh equity).

### Hand-in checklist

- [ ] Hedge contract count computed and rounding direction justified.
- [ ] Position size computed from the 1–2% rule and cross-checked to equity × risk%.
- [ ] Risk-managed paper trade journaled: entry, stop, qty, exit, P&L.
- [ ] One-page risk plan for the S3-M8 company: bull/base/bear with numbers.
- [ ] Notes on `strategies/04_risk_management.py` and `backtesting/05_monte_carlo.py`.

### Common errors

- **Lot-size omission** — `hedge_contracts` divides by `fut_price * lot_size`; dropping `lot_size` over-counts by 75×.
- **Rounding down the hedge** — rounding *down* leaves tail risk; justify rounding up.
- **Risk% applied to position instead of equity** — the numerator is `Equity × Risk%`, not `position × Risk%`.
- **Stop inside noise** — if the stop sits inside the daily ATR range, expect a stop-out; widen to structural or `k×ATR` level.

## Practice problems

1. A ₹5 crore portfolio has β = 0.8. What hedge notional is required? If NIFTY futures are at 24,000 (lot 75), how many contracts (to the nearest whole)?
2. Explain the difference between hedging market risk (futures) and flooring specific risk (puts) in two sentences.
3. Equity ₹20 lakh, risk 1.5%, entry 200, stop 180. Compute the quantity and the worst-case rupee loss.
4. A protective put at K = 4,000 costs 80 on a stock at 4,200. What is the maximum loss? What does the stock need to do for the put to pay off?
5. Construct a collar on the same stock: sell a 4,400 call for 50. Net cost and payoff band?
6. Why should a research report's risk plan be written *before* conviction settles? Answer in two sentences.
7. Beta drifts from 1.2 to 1.0. Should the hedge be increased or decreased, and why?
8. (Short code) For equity ₹50 lakh, risk 2%, entry 150, stop 140, compute qty and loss at stop.

### Solutions

1. Hedge notional = 0.8 × 5,00,00,000 = ₹4,00,00,000. Per-contract = 24000×75 = 18,00,000. Contracts = 4,00,00,000/18,00,000 ≈ 22.2 → 23 contracts (round up).
2. Futures hedge lay off the market's systematic leg of a portfolio's risk; puts set an absolute floor under a specific position, at the cost of a premium, regardless of what causes the fall.
3. Qty = (20,00,000 × 0.015)/(200−180) = 30,000/20 = 1,500 shares; worst-case loss = 1,500 × 20 = ₹30,000 = 1.5% of equity.
4. Max loss = 4200 − 4000 + 80 = 280. The put pays off when the stock falls below 4,000; at any price below K the floor holds.
5. Net cost = 80 − 50 = 30; band [4,000, 4,400] — floor at 4,000, cap at 4,400.
6. Before conviction, the analyst still imagines failure honestly; after committing to a thesis, loss aversion (M3) edits the bear case into unreality. Pre-written exits are the only reliable ones.
7. Decrease — a β of 1.0 means less market sensitivity, so fewer contracts protect the same portfolio; a stale 1.2 hedge over-hedges.
8. Qty = (50,00,000 × 0.02)/10 = 1,00,000/10 = 10,000 shares; loss at stop = 10,000 × 10 = ₹1,00,000.

## Quiz bank

| Question | A | B | C | D | Answer |
|---|---|---|---|---|---|
| Hedge notional for a long book is | β × portfolio value | portfolio ÷ β | spot × lot | premium × qty | A |
| Contracts = | (β×PV)/(F×lot) | (F×lot)/(β×PV) | β×PV×lot | PV/(β×F) | A |
| A short futures hedge removes | specific risk | market risk | basis risk | all risk | B |
| The protective put's max loss is | S0 − K | S0 − K + premium | premium | K − S0 | B |
| A collar is | put + short call | two puts | futures + put | covered call | A |
| Collar's short call leg | pays for the put | doubles the cost | is riskless | is OTM only | A |
| Position size = | (Equity×Risk%)/(E−S) | (E−S)/Equity | Risk%×entry | Equity/price | A |
| The 1–2% rule caps loss per | year | trade | month | position total | B |
| A pre-committed stop should be | moved daily | at structure or k×ATR | at breakeven only | at the high | B |
| Basis risk remains after hedging because | futures ≠ stock perfectly | stocks are riskless | lot size is wrong | margin is low | A |
| β drift means the hedge | needs rebalancing | is permanent | is riskless | doubles | A |
| A research risk plan must include | a bear case | only upside | the logo | marketing | A |

## Glossary

- **Hedging** — taking an offsetting position to manage a specific risk.
- **Beta hedge** — short index futures scaled by the portfolio's β.
- **Hedge ratio** — fraction of the portfolio's exposure offset (β × value).
- **Hedge notional** — `β × portfolio value`, the exposure to lay off.
- **Protective put** — long stock + long put; floors the downside.
- **Collar** — protective put + short call; defined payoff band, low net cost.
- **Position size rule** — `Qty = (Equity × Risk%)/(Entry − Stop)`.
- **1–2% rule** — cap the loss per trade at 1–2% of equity.
- **Structural stop** — a level where the investment thesis is invalidated.
- **ATR stop** — `entry − k×ATR`, a volatility-scaled stop.
- **Basis risk** — residual risk from futures tracking the index imperfectly.
- **Risk plan** — scenarios (bull/base/bear), max loss, and the pre-committed stop.

## Reading assignment

Study IFMC item 64 (hedging) and PGP T3-302 in the [reading list](../appendices/reading-list.md). Run `tantra-examples/examples/strategies/04_risk_management.py` and `backtesting/05_monte_carlo.py` and relate their risk machinery to this module's rules.

## Assessment reminder

This module feeds the hedging case study (portfolio → hedge design → journal) and the one-page risk-plan memo; both are graded components, so keep drafts and the paper-trade journal per the [assessment plan](../front/assessment.md).

**Next:** [M8 — Currency & Fixed Income Markets](m8-currency-fixed-income.md)
