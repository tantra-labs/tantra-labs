# M5 — Derivatives: Forwards & Futures

> **Weeks 55–57 · 20 hrs · PLO-9 · Core:** NIFM Ch 2; IFMC items 60–62

## Learning outcomes

- Explain what a derivative is and why it exists.
- Price a forward and a futures contract; explain basis and convergence.
- Compute margin, leverage, and mark-to-market.
- Explain open interest and rollover.

## Prerequisites

- [M3 of Semester 4](m3-portfolio-theory.md): the risk-free rate and why money has a time value.
- [M1 of Semester 3](../s3/m1-financial-statements.md) (or S1 markets): the concept of spot price, cash markets, and NSE lot sizes.
- Comfort with exponent arithmetic: `x ** y` in Decimal (used for `(1 + r)^T`).

## Lesson 5.1 — What derivatives are

### 1) Concept

A **derivative** is a financial contract whose value *derives from* — depends on — an underlying asset: a stock (RELIANCE), an index (NIFTY), a currency (USD/INR), a commodity (gold, crude), or an interest rate. You are not buying the asset; you are buying a *promise* about its future price.

Derivatives exist for three reasons. **Hedging**: an exporter who will receive USD in three months locks the rate today to remove FX risk. **Speculation**: a trader who believes NIFTY will rise buys a futures contract to profit with small capital. **Arbitrage**: a trader spots a mispricing between the future and its underlying and locks a risk-free profit.

There are two families. **Exchange-traded** derivatives (NSE futures and options) are standardised contracts — fixed lot sizes, standard expiries — with the exchange's clearing house guaranteeing both sides. **OTC** (over-the-counter) contracts like *forwards* are private agreements between two parties, customised but carrying **counterparty risk** (the other side might not pay). That single difference — clearing-house guarantee vs private promise — drives everything in Lessons 5.3 and 5.4.

### 2) Worked example

A trader buys one NIFTY futures lot (lot size 75) at 24,000 index points. What is the notional exposure?

```
Notional = Futures price × lot size = 24,000 × 75 = ₹1,800,000
```

Answer: one lot controls ₹18 lakh of index exposure. The trader put up only the margin (Lesson 5.3) — that is leverage.

```python
from decimal import Decimal
price = Decimal("24000")
lot   = Decimal("75")
notional = price * lot
print("notional:", notional)   # ₹1,800,000
```

### 3) Common pitfalls

> **Pitfall:** Confusing the derivative with the underlying — holding a NIFTY future is not holding the 50 stocks.
>
> **Pitfall:** Ignoring lot size. Prices are quoted per unit; the actual exposure is `price × lot`.
>
> **Pitfall:** Assuming OTC and exchange-traded carry the same risk — the clearing house is the difference.
>
> **Pitfall:** Forgetting derivatives are zero-sum contracts in aggregate: one side's gain is the other side's loss (before fees).

### 4) Key takeaways

- **Takeaway:** A derivative's value derives from an underlying.
- **Takeaway:** Uses: hedging, speculation, arbitrage.
- **Takeaway:** Exchange-traded = standardised + clearing house; OTC = custom + counterparty risk.
- **Takeaway:** Exposure = price × lot size; margin supplies the leverage.

## Lesson 5.2 — Forward pricing

### 1) Concept

Why is a future not simply "the spot price today"? Because of **cost of carry**: to be long the asset until expiry, the seller must finance the purchase (interest), and benefits like dividends or storage savings offset that. The no-arbitrage forward price is the spot price carried forward at the net carry cost:

```
F = S0 · (1 + r)^T      (for a non-dividend asset, discrete)
F = S0 · e^(rT)         (continuous compounding)
F = S0·(1 + (r − y)T)   (with yield y, approx)
```

The logic: if `F` were *higher* than `S0·(1+r)^T`, an arbitrageur could borrow to buy the spot, sell the forward, and pocket the difference at expiry — a risk-free profit. Selling pressure pushes the future down. If `F` were lower, the reverse arbitrage (sell spot, buy forward) pushes it up. The only price with no free lunch is `S0·(1+r)^T`. Hence `F ≠ S` is normal: for a non-dividend stock, `F > S` (contango) because of interest; with high dividends `F < S` is possible. Commodities add storage cost and "convenience yield" to the same story.

### 2) Worked example

Spot NIFTY = 24,000, r = 7% per year, T = 1 year, no dividends.

```
F = 24000 × (1.07)^1 = 25,680
```

If the future traded at 26,000, an arbitrageur borrows ₹24,000 at 7%, buys the index (or a replicating basket), shorts the future at 26,000, and locks `26,000 − 25,680 = ₹320` risk-free per unit.

```python
from decimal import Decimal

def forward(spot: Decimal, rate: Decimal, years: Decimal) -> Decimal:
    return spot * (Decimal(1) + rate) ** years

print(forward(Decimal("24000"), Decimal("0.07"), Decimal("1")))   # ≈ 25,680
```

Answer: fair 1-year forward ≈ 25,680 vs spot 24,000 — the difference (1,680) is exactly one year of 7% carry.

### 3) Common pitfalls

> **Pitfall:** Treating F = S. Interest (and dividends, storage) always shift the fair price.
>
> **Pitfall:** Forgetting `(1+r)^T` compounds. For T < 1 the exponent is a fraction — `Decimal(3)/Decimal(12)` for three months — not a multiplication by T (except in the *approx* form).
>
> **Pitfall:** Ignoring dividends: for an underlying paying yield y, use `F = S0·(1 + (r − y)T)` or the exact dividend-adjusted form `F = (S0 − PV(Div))·(1+r)^T`.
>
> **Pitfall:** Using float for rate or spot — Decimal only.

### 4) Key takeaways

- **Takeaway:** Forward price = spot carried at the net cost of carry.
- **Takeaway:** Arbitrage pins F to `S0(1+r)^T` — any deviation is a free lunch.
- **Takeaway:** Contango (F > S) is normal for non-dividend assets; dividends can flip it.
- **Takeaway:** Discrete and continuous forms are the same idea: `e^(rT)` ≈ `(1+r)^T` for small r.

## Lesson 5.3 — Futures: margins & MTM

### 1) Concept

Futures are settled daily through **margin**. The **initial margin** is a deposit (typically 5–12% of notional for NIFTY) collected when you open. The **maintenance margin** is a floor — if your balance falls below it you get a **margin call** and must top up to the initial level; if you do not, the exchange closes your position. **Variation margin** is the daily transfer that enforces this: gains are credited, losses debited, every single day.

**Mark-to-market (MTM)** is the engine: at each day's close, the exchange reprices your position at the settlement price and transfers the day's profit or loss in cash. Because the exchange (via the clearing house) stands between every buyer and seller and settles daily, **counterparty risk is removed** — you never wait until expiry to find out the other side defaulted. This is the crucial difference from OTC forwards.

**Leverage** = Notional ÷ initial margin. With a 10% margin on ₹18 lakh of NIFTY exposure, you control ₹18 lakh by depositing ₹1.8 lakh — a 10× lever. Leverage amplifies both directions: a 1% adverse move on the notional is a 10% loss on your margin.

### 2) Worked example

Buy 1 lot of NIFTY futures at 24,000 (lot 75), initial margin 10%, maintenance 8%.

```
Notional = 24000 × 75 = 1,800,000
Initial margin = 0.10 × 1,800,000 = 180,000
Day 1 settle 24,100: MTM gain = (24100 − 24000) × 75 = +7,500
Balance = 187,500
Day 2 settle 23,900: MTM loss = (23900 − 24100) × 75 = −15,000
Balance = 172,500  (still above 144,000 maintenance → no call)
Day 3 settle 23,700: MTM loss = (23700 − 23900) × 75 = −15,000
Balance = 157,500  (still above maintenance 144,000)
Day 4 settle 23,500: loss −15,000 → balance 142,500 < 144,000 → MARGIN CALL
```

The call asks for a top-up back to 180,000: +37,500. Note the loss total after four days: (24000 − 23500)×75 = 37,500 — exactly the top-up.

```python
from decimal import Decimal
price, lot = Decimal("24000"), Decimal("75")
initial = Decimal("0.10") * price * lot        # 180,000
maintain = Decimal("0.08") * price * lot       # 144,000
balance = initial
for settle in [Decimal("24100"), Decimal("23900"), Decimal("23700"), Decimal("23500")]:
    balance += (settle - price) * lot
    price = settle
    call = (Decimal("180000") - balance) if balance < maintain else Decimal("0")
    print("balance:", balance, "margin call:", call)
```

Answer: margin call on day 4 for ₹37,500; leverage = 1,800,000/180,000 = 10×.

### 3) Common pitfalls

> **Pitfall:** Confusing initial and maintenance margin — the call triggers at *maintenance*, the top-up target is *initial*.
>
> **Pitfall:** Computing MTM against your entry price every day. MTM is daily: gain = (today's settle − *yesterday's* settle) × lot.
>
> **Pitfall:** Underestimating leverage damage — a 10% margin is 10× lever, and losses compound with MTM.
>
> **Pitfall:** Treating MTM as unrealised paper P&L — futures P&L is *realised daily in cash*.

### 4) Key takeaways

- **Takeaway:** Initial margin opens; maintenance margin triggers calls; variation margin settles daily.
- **Takeaway:** MTM + clearing house = no counterparty risk on exchange futures.
- **Takeaway:** Leverage = notional ÷ margin; it cuts both ways.
- **Takeaway:** A margin call tops you *back up to initial*, not to maintenance.

## Lesson 5.4 — Basis and convergence

### 1) Concept

**Basis** is the gap between the spot price and the futures price:

```
Basis = Spot − Futures
```

At expiry, a futures contract settles against the spot (cash settlement for index futures), so **basis converges to zero**: as expiry approaches, the future and the spot must meet. Arbitrage enforces this — if the gap persisted, traders would take the other side risk-free.

**Rollover** is the practical consequence: near expiry, traders who still want exposure close the near-month future and open the next-month one. The **roll cost** is the basis difference between the two contracts (roughly the carry for the extra month). In Indian markets, most NIFTY rollover happens on the last Thursday (expiry day); the rollover percentage (fraction of open positions carried to the next series) is a widely watched positioning signal. A market in **backwardation** (futures below spot → basis positive) is often read as nervousness or a dividend-heavy window; **contango** (futures above spot → basis negative) is the normal carry state.

### 2) Worked example

Spot NIFTY 24,300; near-month future 24,400; next-month future 24,560.

```
Basis_near = 24300 − 24400 = −100   (contango: futures above spot)
Roll cost  = 24560 − 24400 = +160   (approx carry of one month)
```

Rolling costs ₹160 per unit of index — the price of keeping exposure another month. Over one lot (75), the roll costs 160 × 75 = ₹12,000.

```python
from decimal import Decimal
spot = Decimal("24300")
near = Decimal("24400")
nxt  = Decimal("24560")
print("basis near:", spot - near)     # −100
print("roll cost :", nxt - near)      # +160
print("roll cost per lot:", (nxt - near) * Decimal("75"))   # 12,000
```

### 3) Common pitfalls

> **Pitfall:** Sign confusion. Basis = Spot − Futures (with *this* sign convention); state the convention you use.
>
> **Pitfall:** Expecting the basis to stay constant — it converges to zero by expiry.
>
> **Pitfall:** Ignoring roll cost when journaling a "held through expiry" futures position — the P&L must net out the roll.
>
> **Pitfall:** Reading basis as pure sentiment — dividends and carry mechanically widen it.

### 4) Key takeaways

- **Takeaway:** Basis = Spot − Futures; it converges to zero at expiry.
- **Takeaway:** Arbitrage is the enforcement mechanism behind convergence.
- **Takeaway:** Rollover = close near + open next; its cost is the basis difference.
- **Takeaway:** Contango/backwardation carry information but also mechanical carry.

## Lesson 5.5 — Open interest

### 1) Concept

**Open interest (OI)** is the number of futures contracts *currently open* — outstanding obligations, not cumulative volume. A new buyer and a new seller *create* OI (+1); a closing buyer and a closing seller *destroy* it (−1); a new buyer hitting a closing seller just transfers it (0). OI is therefore a measure of how much money is *committed* to the position, not how much has traded.

OI is a **positioning and liquidity signal**. Rising price with rising OI = the trend is backed by *new* longs — a healthier trend. Rising price with *falling* OI = short covering, not new conviction — the move may be exhausting. Falling price with rising OI = new shorts pressing. The classic rule of thumb: price and OI moving together confirm; price and OI diverging warn of a reversal. OI also measures liquidity — a contract with thin OI is expensive to trade (wide spreads).

### 2) Worked example

Series A: 1,000 contracts exist; a new buyer and new seller trade 100. OI = 1,100. Series B: a new buyer and *closing* seller trade 100. OI stays 1,100? No — recompute:

```
Start OI = 1000
New buyer + new seller (both open): OI = 1100
New buyer (opens) vs closing seller (closes): one side opens, one closes → OI unchanged = 1000
```

So the same 100-contract trade tells you completely different things about commitment — OI's informational value is in the *direction* of the change, not the volume.

```python
from decimal import Decimal
oi = Decimal("1000")
oi_new_open   = oi + Decimal("100")   # both open → +100
oi_new_close  = oi                    # open vs close → unchanged
print("both open :", oi_new_open)     # 1100
print("open-close:", oi_new_close)    # 1000
```

### 3) Common pitfalls

> **Pitfall:** Confusing OI with volume. Volume is today's trades; OI is the standing stock of open contracts.
>
> **Pitfall:** Reading a single day's OI change — compare across several sessions and with price direction.
>
> **Pitfall:** Ignoring expiry — OI collapses as contracts close or roll, which is mechanical, not bearish.
>
> **Pitfall:** Forgetting OI ≠ trader count. One institution can hold thousands of contracts.

### 4) Key takeaways

- **Takeaway:** OI = open contracts outstanding; created and destroyed by opening/closing pairs.
- **Takeaway:** Price + OI together confirm trends; divergence warns of reversal.
- **Takeaway:** OI collapse near expiry is mechanical rollover, not a signal.
- **Takeaway:** OI is also a liquidity gauge.

## Tantra Lab 5 — Forward price in Decimal

### Lab goal

Price a forward with and without dividends in Decimal, compute basis for a near-expiry contract, and journal a paper-traded futures-style margin + MTM position.

### Code

The verified core snippet is unchanged; the extension adds the dividend-adjusted form and a basis calculation.

```python
from decimal import Decimal

def forward(spot: Decimal, rate: Decimal, years: Decimal) -> Decimal:
    return spot * (Decimal(1) + rate) ** years

print(forward(Decimal("24000"), Decimal("0.07"), Decimal("1")))   # ≈ 25,680

# --- extend: dividend-adjusted forward F = (S0 − PV(Div))·(1+r)^T ----------
def forward_with_dividend(spot: Decimal, pv_div: Decimal, rate: Decimal, years: Decimal) -> Decimal:
    return (spot - pv_div) * (Decimal(1) + rate) ** years

# RELIANCE spot 3000, present value of expected dividend 30, r = 7%, 6 months
spot, pv_div = Decimal("3000"), Decimal("30")
F = forward_with_dividend(spot, pv_div, Decimal("0.07"), Decimal(6)/Decimal(12))
print("forward with dividend ≈", F)     # ≈ 3067.45

# --- basis for a near-expiry contract --------------------------------------
spot_n, fut_n = Decimal("24300"), Decimal("24400")
print("basis near:", spot_n - fut_n)    # −100 (contango)
```

**Task:** extend for dividends (`F = (S − PV(Div))·(1+r)^T`), compute basis for a near-expiry future, and place a futures-style paper trade on a `PaperSession`, journaling the margin and MTM effect. Run `tantra-examples/examples/options/01_option_chain.py` to see real NIFTY option chain data structures (the next module's foundation).

### Expected output

The script prints ≈ 25,680 for the plain 1-year forward, ≈ 3,067.45 for the dividend-adjusted RELIANCE 6-month forward (spot 3,000 minus PV dividend 30, carried 6 months at 7% — the dividend *lowers* the fair forward), and a negative basis (−100) for the contango example.

### Hand-in checklist

- [ ] Plain and dividend-adjusted forward prices computed in Decimal.
- [ ] Basis computed with the `Spot − Futures` convention stated.
- [ ] Paper-trade journal entry: initial margin, a margin call scenario, one MTM daily settlement.
- [ ] Notes from running `options/01_option_chain.py` (structure of the chain data).
- [ ] One paragraph: why F ≠ S, using your own numbers.

### Common errors

- **Wrong exponent for part-years** — six months is `Decimal(6)/Decimal(12)`, not `0.5` written as a float and not 6.
- **Dividend sign** — a dividend *reduces* the fair forward; forgetting the `(S − PV(Div))` bracket misprices it upward.
- **Basis sign flip** — state `Spot − Futures` and keep it consistent with the prose.
- **PaperSession in Decimal** — pass `Decimal` cash and limit prices; a float price violates the Zero-Floats rule.

## Practice problems

1. Spot 10,000, r = 8%, T = 0.5. Compute the no-arbitrage forward `F = S0(1+r)^T`.
2. If the market future is 10,600 when fair is 10,400, describe the arbitrage and its risk-free profit per unit.
3. Explain in two sentences why exchange-traded futures have no counterparty risk but OTC forwards do.
4. NIFTY lot 75, future at 25,000, initial margin 12%. What is the notional, the initial margin, and the leverage?
5. You buy at 25,000; day 1 settles 25,080; day 2 settles 25,020. Compute each day's MTM and your balance (start at initial margin from Q4).
6. What is basis when spot = 18,500 and near-month future = 18,450? Is the market in contango or backwardation?
7. Rollover: near-month 18,450, next-month 18,580. What is the roll cost per unit and per lot (lot 75)?
8. Rising NIFTY with rising OI — what does the classic rule of thumb conclude about trend quality?

### Solutions

1. F = 10000 × (1.08)^0.5 = 10000 × 1.03923 ≈ 10,392.3.
2. The future is overpriced: borrow to buy spot, short the future, and at expiry deliver for a locked (10,600 − 10,400) = 200 per unit risk-free (minus carry details).
3. Exchange futures are settled daily through margins by a clearing house that stands between buyer and seller; OTC forwards are private promises settled at maturity, so default by one party is a real risk.
4. Notional = 25000×75 = 1,875,000; initial = 0.12×1,875,000 = 225,000; leverage = 8.33×.
5. Day 1 gain = (25080−25000)×75 = 6,000 → balance 231,000. Day 2 loss = (25020−25080)×75 = −4,500 → balance 226,500.
6. Basis = 18500 − 18450 = +50 → futures below spot → backwardation.
7. Roll cost = 18580 − 18450 = 130 per unit; 130×75 = ₹9,750 per lot.
8. Rising price with rising OI = trend backed by new longs — healthier, more durable trend.

## Quiz bank

| Question | A | B | C | D | Answer |
|---|---|---|---|---|---|
| A derivative's value derives from | the exchange | an underlying asset | the broker | luck | B |
| Hedging uses derivatives to | speculate | remove risk | create leverage | pay fees | B |
| OTC forwards differ from exchange futures in | lot size only | counterparty risk | price level | expiry dates | B |
| Fair forward (no dividend) = | S0(1+r)^T | S0/(1+r)^T | S0×r×T | S0/T | A |
| Arbitrage enforces | margin calls | F = S0(1+r)^T | basis = 0 always | OI growth | B |
| Initial margin is a | profit target | deposit to open | exit price | tax | B |
| A margin call triggers when balance falls below | initial | maintenance | zero | notional | B |
| MTM settles futures | at expiry | daily | monthly | never | B |
| Leverage = | notional × margin | notional ÷ margin | margin ÷ notional | price × lot | B |
| Basis = | Futures − Spot | Spot − Futures | Spot × Futures | Spot + Futures | B |
| At expiry, basis | diverges | converges to zero | equals margin | doubles | B |
| OI increases when | old positions close | a new buyer and new seller open | prices fall | volume spikes | B |
| Rising price + rising OI signals | short covering | new-long-backed trend | distribution | margin call | B |

## Glossary

- **Derivative** — a contract whose value derives from an underlying asset.
- **Underlying** — the asset (stock, index, FX, commodity) a derivative references.
- **Forward** — a customised OTC contract to buy/sell at a future date and price.
- **Future** — a standardised, exchange-traded, daily-settled contract.
- **Cost of carry** — net cost (interest − dividends/storage) of holding the underlying.
- **Contango** — futures above spot.
- **Backwardation** — futures below spot.
- **Initial margin** — deposit required to open a futures position.
- **Maintenance margin** — floor below which a margin call triggers.
- **Mark-to-market** — daily cash settlement of futures gains/losses.
- **Basis** — `Spot − Futures`; converges to zero at expiry.
- **Rollover** — closing the near-month contract and opening the next-month one.
- **Open interest** — number of open contracts outstanding.

## Reading assignment

Study NIFM Chapter 2 (derivatives) and IFMC items 60–62 (futures and forwards) in the [reading list](../appendices/reading-list.md). Run `tantra-examples/examples/options/01_option_chain.py` to see the option-chain data structures that M6 builds on.

## Assessment reminder

This module feeds the futures pricing worksheet and the quiz, plus a paper-trade journal entry (futures margin + MTM); see the [assessment plan](../front/assessment.md) for journal and lab-note requirements.

**Next:** [M6 — Options: Pricing & Strategies](m6-options.md)
