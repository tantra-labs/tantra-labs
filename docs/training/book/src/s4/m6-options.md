# M6 — Options: Pricing & Strategies

> **Weeks 57–59 · 24 hrs · PLO-9 · Core:** NIFM Ch 3; IFMC item 63; CFTe App G (statistics bridge)

## Learning outcomes

- Explain call/put payoff, intrinsic vs time value, and moneyness.
- State put-call parity and the Black-Scholes formula *intuition*.
- Compute option greeks and read an option chain.
- Construct basic strategies: covered call, protective put, spreads, straddles.

## Prerequisites

- [M5](m5-forwards-futures.md): the idea that derivative prices derive from an underlying and that arbitrage pins prices.
- [M1](m1-statistics.md): the lognormal distribution bridge — Black-Scholes assumes lognormal prices.
- [M3](m3-portfolio-theory.md): the risk-free rate `r` used in option pricing.
- The wheel's `tantra.options` module (verified surface: `bs_price`, `bs_greeks`, `implied_volatility`, `OptionChain`, `OptionContract`, `OptionKind`, `OptionStyle`).

## Lesson 6.1 — Payoffs and moneyness

### 1) Concept

An **option** is the *right, not the obligation*, to buy (a **call**) or sell (a **put**) the underlying at a fixed **strike price K** on or before **expiry T**. The **payoff** at expiry is brutally simple — it is the payoff you would exercise:

```
Call payoff = max(S − K, 0)      Put payoff = max(K − S, 0)
```

A call with S = 24,100 and K = 24,000 is worth 100 (you can buy at 24,000 and sell at 24,100). If S < K it is worth 0 — you simply do not exercise. `max(...)` captures that asymmetry. But *before* expiry an option trades for more than its payoff floor. That premium splits into two parts:

```
Intrinsic value = payoff if exercised now = max(S − K, 0)
Time value = Option price − Intrinsic value
```

The **time value** is what you pay for the *possibility* that S moves in your favour before expiry. **Moneyness** classifies by strike vs spot: **ITM** (in-the-money: call with S > K, put with S < K), **ATM** (at-the-money: S ≈ K), **OTM** (out-of-the-money: call with S < K). Indian option chains (NSE NIFTY) quote all strikes for each expiry with their premiums, open interest, and IV — the table you read on any broker screen.

### 2) Worked example

NIFTY spot 24,000. A 24,100 strike call trades at 120; a 24,000 strike put trades at 95.

```
Call 24,100: intrinsic = max(24000 − 24100, 0) = 0 → OTM; time value = 120 − 0 = 120
Put  24,000: intrinsic = max(24000 − 24000, 0) = 0 → ATM;  time value = 95 − 0 = 95
```

Both options are pure time value at this moment — the entire premium is the bet on future movement.

```python
from decimal import Decimal
def call_payoff(S, K): return max(S - K, Decimal(0))
def put_payoff(S, K):  return max(K - S, Decimal(0))

S = Decimal("24000")
print("call payoff @24100:", call_payoff(S, Decimal("24100")))   # 0 (OTM)
print("put  payoff @24000:", put_payoff(S, Decimal("24000")))    # 0 (ATM)
print("call intrinsic @25000:", call_payoff(Decimal("25000"), Decimal("24100")))  # 900
```

### 3) Common pitfalls

> **Pitfall:** Forgetting the `max(..., 0)` floor — a call below strike is worth 0, not a negative number.
>
> **Pitfall:** Confusing premium (price today) with payoff (value at expiry) — premium includes time value.
>
> **Pitfall:** Moneyness flips between calls and puts: S > K is ITM for a call but OTM for a put.
>
> **Pitfall:** Using float in `max()` — both sides must be Decimal for the result to stay Decimal.

### 4) Key takeaways

- **Takeaway:** Call payoff = max(S−K, 0); put payoff = max(K−S, 0).
- **Takeaway:** Premium = intrinsic + time value.
- **Takeaway:** Moneyness = ITM/ATM/OTM from the *option holder's* perspective.
- **Takeaway:** An option's value is the right, not the obligation — hence max.

## Lesson 6.2 — Put-call parity

### 1) Concept

**Put-call parity** is the cleanest no-arbitrage identity in options. Two portfolios have *identical* payoffs at expiry in every state of the world, so they must have identical prices today or an arbitrageur prints free money:

```
C + K·e^(−rT) = P + S0
```

- Left: a **call** C plus cash equal to the present value of the strike `K·e^(−rT)`.
- Right: a **put** P plus the **stock** S0.

At expiry, if S > K the left's call pays (S−K) and the cash is K → total S; the right's put is worthless and the stock is S → total S. If S < K the left's call is worthless, cash = K; the right's put pays (K−S), stock = S → total K. Identical in every state — so the prices must match today. This identity lets you *manufacture* any option from the other three pieces (synthetic positions) and, critically, **check option-chain prices for mispricing**. If you see a chain where `C + PV(K) ≠ P + S` beyond tiny transaction costs, either the data is stale or someone is giving away free money (they are not).

### 2) Worked example

S0 = 24,000, K = 24,000, r = 7%, T = 30/365. Call C = 250. What should the put be?

```
PV(K) = 24000 × e^(−0.07×30/365) ≈ 24000 × 0.99426 ≈ 23,862.3
C + PV(K) = 250 + 23862.3 = 24,112.3
P = C + PV(K) − S0 = 24,112.3 − 24,000 = 112.3
```

If the quoted put were 150, a trader could sell the overpriced put, buy the call, buy... (see Pitfalls) — the parity violation is the arb signal.

```python
from decimal import Decimal
# Decimal approximation of e^(−rT): use Decimal.exp on the exact power
S0, K = Decimal("24000"), Decimal("24000")
r = Decimal("0.07"); T = Decimal(30) / Decimal(365)
C = Decimal("250")

pvK = K * (-r * T).exp()
P = C + pvK - S0
print("PV(K):", pvK)      # ≈ 23862.3
print("fair put:", P)     # ≈ 112.3
```

### 3) Common pitfalls

> **Pitfall:** Dropping the `e^(−rT)` discount — K must be present-valued, not raw.
>
> **Pitfall:** Applying parity to American options (early exercise) without care — the identity is cleanest for European options.
>
> **Pitfall:** Ignoring dividends/borrow costs, which add extra terms.
>
> **Pitfall:** Getting the sign wrong — it is `C + PV(K) = P + S`, and mixing sides manufactures the wrong synthetic.

### 4) Key takeaways

- **Takeaway:** `C + K·e^(−rT) = P + S0` — the no-arbitrage option identity.
- **Takeaway:** Two identical-payoff portfolios must price identically.
- **Takeaway:** Parity manufactures synthetic options and checks chain prices.
- **Takeaway:** Cleanest for European options; dividends add terms.

## Lesson 6.3 — Black-Scholes intuition

### 1) Concept

The **Black-Scholes formula** (`bs_price`) prices a European option from five inputs: spot `S0`, strike `K`, time to expiry `T`, risk-free rate `r`, and **volatility σ**. Four are observable; **σ is the only unobservable input**. That is why every option chain quotes **implied volatility (IV)**: the σ you must plug in so that `bs_price(...)` equals the *market* price. IV is the market's consensus bet on future volatility — it is quoted like a price.

The core intuition: an option is a leveraged bet on the *probability distribution* of the underlying at expiry. Because M1 told us prices are **lognormal** (`P_T = P_0·exp(...)`), the probability that S ends above K is computable, and the option is the probability-weighted average of its payoffs, discounted back at `r`. The formula packages that expectation into two `N(d1)` and `N(d2)` terms (cumulative normal probabilities) — you do not need to derive them for NISM, but you must know:

- The option is worth more when **S** is far in your favour (high S for calls).
- More when **K** is favourable (low K for calls).
- More when **T** is longer (more time for movement).
- More when **σ** is higher (wider distribution — *volatility is the option buyer's friend, not the seller's*).
- **r** enters through discounting and carry.

The formula's role in this course is as the *engine* you call — `bs_price`, `bs_greeks`, `implied_volatility` — not as algebra to memorise.

### 2) Worked example

The wheel's own worked call: spot 24,000, strike 24,000 (ATM), 30 days, r = 7%, σ = 12%.

```
Intuition check: ATM call, 30 days, low vol (12%) → small premium.
Formula (via bs_price): call price ≈ 403 per unit (see Lab 6 output)
```

Let the wheel do the closed-form computation:

```python
from decimal import Decimal
from tantra.options import bs_price

price = bs_price(
    spot=Decimal("24000"), strike=Decimal("24000"),
    expiry=Decimal("30") / Decimal("365"),
    rate=Decimal("0.07"), vol=Decimal("0.12"), kind="call", style="european",
)
print("call price:", price)   # ≈ 403 (exact digits from the wheel)
```

Answer: ≈ 403 per unit — almost all time value, since the call is ATM (intrinsic 0).

### 3) Common pitfalls

> **Pitfall:** Treating σ as observable — it is not; IV is *solved* from market prices.
>
> **Pitfall:** Expecting B-S to price American options directly — `style="european"` matters; use the American-aware chain data for early-exercise features.
>
> **Pitfall:** Using calendar days instead of a year-fraction — `expiry` is in *years* (e.g. `Decimal("30")/Decimal("365")`).
>
> **Pitfall:** Forgetting that B-S is a model — real tails are fatter (M1 kurtosis), so B-S prices are a baseline, not a truth.

### 4) Key takeaways

- **Takeaway:** B-S inputs: S0, K, T, r, σ — only σ is unobservable.
- **Takeaway:** IV is the market's volatility quote, recovered from price.
- **Takeaway:** Price rises with S (calls), T, and σ; falls with K.
- **Takeaway:** Volatility is the option buyer's friend.

## Lesson 6.4 — Greeks

### 1) Concept

**Greeks** are sensitivities — how much the option price changes when one input moves a little:

```
Delta  Δ = ∂Price/∂Spot      Gamma  Γ = ∂Δ/∂Spot
Theta  Θ = ∂Price/∂time      Vega   ν = ∂Price/∂σ
Rho    ρ = ∂Price/∂rate
```

- **Delta (Δ)** — price change per ₹1 of spot move. An ATM call has Δ ≈ 0.5; a deep-ITM call approaches 1; an OTM call approaches 0. Delta is the option's *effective share count*.
- **Gamma (Γ)** — how fast delta itself changes; high gamma (ATM, near expiry) means the delta is a moving target.
- **Theta (Θ)** — *time decay* per day. Options are wasting assets: theta is usually negative for the buyer, and it accelerates as expiry nears.
- **Vega (ν)** — price change per 1-point move in σ (IV). Vega is the option seller's revenue and the buyer's cost.
- **Rho (ρ)** — sensitivity to the interest rate; small for typical equity options.

The wheel's `bs_greeks` returns all five in one call, and the option chain (`gamma_profile`) exposes gamma across strikes. Reading greeks is how a trader knows *what they are actually exposed to*: a long straddle is betting on vega and gamma, not on direction (delta ≈ 0).

### 2) Worked example

An ATM NIFTY call: Δ = 0.52, Γ = 0.00012, Θ = −12 per day, ν = 22 per 1 vol point, ρ = 0.03. Spot = 24,000.

```
Spot moves +100: price change ≈ Δ × 100 = 0.52 × 100 = 52
One day passes:  price change ≈ Θ = −12 (time decay)
σ rises 1 point: price change ≈ ν = +22
```

Total first-order estimate for the day (+100 spot, +1 vol point): +52 + 22 − 12 = +62.

```python
from decimal import Decimal
from tantra.options import bs_greeks

g = bs_greeks(spot=Decimal("24000"), strike=Decimal("24000"),
              expiry=Decimal("30")/Decimal("365"), rate=Decimal("0.07"),
              vol=Decimal("0.12"), kind="call")
print("delta:", g.delta)      # ≈ 0.52
print("gamma:", g.gamma)      # small positive
print("theta:", g.theta)      # negative (time decay)
print("vega :", g.vega)       # positive
print("rho  :", g.rho)        # small
```

(Field names are verified: `Greeks(delta, gamma, theta, vega, rho)` — all `Decimal`, theta in daily units, vega per 1 vol-point.)

### 3) Common pitfalls

> **Pitfall:** Mixing up units — theta is per day, delta is per point of spot, vega is per vol point; state units on every number.
>
> **Pitfall:** Treating delta as constant — gamma means delta moves with spot.
>
> **Pitfall:** Sign errors: long options have negative theta (buyers pay for time); short options have positive theta.
>
> **Pitfall:** Guessing greek attribute names — the wheel returns a frozen `Greeks` dataclass with fields `delta, gamma, theta, vega, rho` (all `Decimal`). Verify the *directions* (Δ positive call, Θ negative) as the conceptual check.

### 4) Key takeaways

- **Takeaway:** Greeks = price sensitivities to spot (Δ, Γ), time (Θ), vol (ν), rate (ρ).
- **Takeaway:** Δ ≈ 0.5 ATM, →1 deep ITM, →0 OTM.
- **Takeaway:** Θ is the option buyer's daily rent; it accelerates near expiry.
- **Takeaway:** ν is the volatility bet — the straddle's whole point.

## Lesson 6.5 — Basic strategies

### 1) Concept

Options exist to be *combined*. Every strategy is a portfolio of legs with a known max profit, max loss, and breakeven — which is exactly why payoff diagrams are the analyst's language.

| Strategy | Construction | View |
|---|---|---|
| Covered call | Long stock + short call | Mildly bullish / collect premium |
| Protective put | Long stock + long put | Bullish with insurance |
| Bull/bear spread | Buy/sell two calls or two puts | Directional, limited risk |
| Straddle | Long call + long put, same strike | Volatility view |
| Strangle | Long OTM call + OTM put | Volatility view, cheaper |

- **Covered call**: you own the stock and sell a call against it. The premium income cushions a small fall, but you cap upside above the strike. Max profit = premium + (K − S0); max loss = S0 − premium (if stock collapses); breakeven = S0 − premium.
- **Protective put**: you own the stock and buy a put — insurance. Max loss = S0 − K + premium (the put sets a floor); upside unlimited.
- **Bull call spread**: buy K1 call, sell K2 call (K2 > K1). Cheaper than the naked call; max profit = (K2 − K1) − net debit; max loss = net debit.
- **Straddle**: long call + long put at the same strike — you lose theta daily but win big on any large move either way; breakevens are K ± total premium.
- **Strangle**: same idea with OTM strikes — cheaper premium, needs a *bigger* move to profit.

For each: state max profit, max loss, and breakeven; draw the diagram. That discipline turns "I think it will move" into a measured bet with known worst case.

### 2) Worked example

RELIANCE at 3,000. Buy a 3,000 call for 120 and a 3,000 put for 110 (straddle). Total debit = 230.

```
Max loss = 230 (if S stays exactly 3,000)
Upside breakeven = 3000 + 230 = 3,230
Downside breakeven = 3000 − 230 = 2,770
At S = 3,400: call pays 400 → P&L = 400 − 230 = +170
At S = 2,500: put pays 500 → P&L = 500 − 230 = +270
```

You win if the stock moves more than 230 points in *either* direction — a pure volatility bet.

```python
from decimal import Decimal
S0, K = Decimal("3000"), Decimal("3000")
call_p, put_p = Decimal("120"), Decimal("110")
debit = call_p + put_p

def straddle_pnl(S):
    return max(S - K, Decimal(0)) + max(K - S, Decimal(0)) - debit

print("debit:", debit)                              # 230
print("max loss:", -debit)                          # −230
print("up breakeven:", K + debit)                   # 3230
print("down breakeven:", K - debit)                 # 2770
print("P&L @3400:", straddle_pnl(Decimal("3400")))  # +170
print("P&L @2500:", straddle_pnl(Decimal("2500")))  # +270
```

### 3) Common pitfalls

> **Pitfall:** Drawing a strategy without labelling max profit / max loss / breakeven — a diagram without those three is decoration.
>
> **Pitfall:** Forgetting the short leg in a spread — the payoff is the *net* of both legs.
>
> **Pitfall:** Assuming a straddle needs direction — it needs *movement*; delta ≈ 0.
>
> **Pitfall:** Ignoring theta cost in long-volatility strategies — a straddle bleeds daily until the move arrives.

### 4) Key takeaways

- **Takeaway:** Every strategy = known max profit, max loss, breakeven.
- **Takeaway:** Covered call caps upside for income; protective put floors the downside for a fee.
- **Takeaway:** Spreads cut cost and risk by adding an opposite leg.
- **Takeaway:** Straddles/strangles are volatility bets, not direction bets.

## Tantra Lab 6 — Price, greeks, and IV from the wheel

### Lab goal

Price an ATM call with `bs_price`, read its full greek profile with `bs_greeks`, and recover volatility via `implied_volatility` — closing the price → IV → price round-trip in Decimal.

### Code

The verified snippet is unchanged and self-contained.

```python
from decimal import Decimal
from tantra.options import bs_price, bs_greeks, implied_volatility

price = bs_price(
    spot=Decimal("24000"), strike=Decimal("24000"),
    expiry=Decimal("30") / Decimal("365"),
    rate=Decimal("0.07"), vol=Decimal("0.12"), kind="call", style="european",
)
print("call price:", price)
print("greeks:", bs_greeks(spot=Decimal("24000"), strike=Decimal("24000"),
                           expiry=Decimal("30")/Decimal("365"), rate=Decimal("0.07"),
                           vol=Decimal("0.12"), kind="call"))
iv = implied_volatility(price, spot=Decimal("24000"), strike=Decimal("24000"),
                        expiry=Decimal("30")/Decimal("365"), rate=Decimal("0.07"),
                        kind="call")
print("implied vol round-trip:", iv)
```

Run `tantra-examples/examples/options/02_greeks_calculation.py`, `01_option_chain.py`, and `03_backtest_straddle.py` for the full picture.

### Expected output

The script prints a positive call premium (≈ 403 for an ATM 30-day 12%-vol call; exact digits from the wheel), a greeks object whose delta ≈ 0.5, theta negative, vega and rho positive, and finally an implied volatility that returns ≈ 0.12 — the round-trip proof that `implied_volatility` inverts `bs_price`.

### Hand-in checklist

- [ ] Call price printed from `bs_price` with expiry as a year-fraction.
- [ ] All five greeks recorded with their units (per-point, per-day, per-vol-point).
- [ ] IV round-trip verified: `implied_volatility(bs_price(...)) ≈ vol` input.
- [ ] Notes from `02_greeks_calculation.py`, `01_option_chain.py`, `03_backtest_straddle.py`.
- [ ] One sentence on what ATM delta ≈ 0.5 means.

### Common errors

- **Expiry not in years** — `Decimal("30")/Decimal("365")`, never `30` or a float.
- **Inverting the round-trip** — `implied_volatility(price, ...)` takes the *price* first; passing spot there errors or returns garbage.
- **Float creep** — every option input must be `Decimal`; a stray `0.07` float breaks the chain.
- **Greeks attribute names** — the wheel returns `Greeks(delta, gamma, theta, vega, rho)`; the concept checks (Δ>0, Θ<0, ν>0) are what the quiz tests.

## Practice problems

1. Spot 25,000, strike 25,200, 20 days to expiry. Call premium = 180. Compute intrinsic and time value; state the moneyness.
2. Put-call parity check: S0 = 10,000, K = 10,000, r = 5%, T = 90/365, C = 300. What should P be (approx)?
3. A call has Δ = 0.55. Spot rises by 40. Roughly how much does the call price change (first order)?
4. Which greek is negative for a long option, and what happens to it as expiry approaches?
5. RELIANCE 3,000. Protective put: buy put K = 2,900 at 60. Compute the maximum loss if the stock falls to any level.
6. Draw (in words) a bull call spread with K1 = 3,000 (buy, 120) and K2 = 3,100 (sell, 50). Max profit, max loss, breakeven?
7. Straddle at K = 24,000, total debit 600. Give both breakevens.
8. (Short code) Compute `bs_price` for the same inputs as Lab 6 but `vol=0.18`. Is the price higher or lower than the 0.12 case? Explain.

### Solutions

1. Intrinsic = max(25000−25200, 0) = 0; time value = 180 − 0 = 180; OTM.
2. PV(K) ≈ 10000×e^(−0.05×90/365) ≈ 9877.6; P = C + PV(K) − S0 = 300 + 9877.6 − 10000 ≈ 177.6.
3. Δ × 40 ≈ 0.55 × 40 = 22 (first order, ignoring gamma).
4. Theta; as expiry nears, theta decay accelerates (more negative per day for long options).
5. Max loss = S0 − K + premium = 3000 − 2900 + 60 = 160. Below K the put pays exactly the floor; below that the put keeps the position worth K, so loss is capped at 160.
6. Net debit = 120 − 50 = 70. Max profit = (K2−K1) − debit = 100 − 70 = 30. Max loss = debit = 70. Breakeven = K1 + debit = 3,070.
7. K ± debit → 24,600 and 23,400.
8. Higher — higher vol widens the terminal distribution; calls gain from more upside probability. Run the wheel to confirm the exact premium.

## Quiz bank

| Question | A | B | C | D | Answer |
|---|---|---|---|---|---|
| Call payoff at expiry = | max(K−S,0) | max(S−K,0) | S−K | K−S | B |
| A put is ITM when | S > K | K > S | S = K | r > σ | B |
| Premium = | intrinsic + time value | intrinsic − time | payoff | IV | A |
| Put-call parity states | C + PV(K) = P + S | C + S = P + PV(K) | C − P = K | P + C = S | A |
| In B-S, the unobservable input is | S0 | σ | K | r | B |
| Implied volatility is solved from | greeks | market price | spot | dividends | B |
| An ATM call delta is near | 0 | 1 | 0.5 | −0.5 | C |
| Which greek measures time decay? | Delta | Theta | Vega | Rho | B |
| Theta is usually | positive for buyers | negative for buyers | zero | constant | B |
| A straddle is | a direction bet | a volatility bet | riskless | a hedge only | B |
| Covered call = | long stock + short call | short stock + long call | two calls | two puts | A |
| In a bull call spread the sold leg has | lower strike | higher strike | same strike | any strike | B |
| BS expiry must be | calendar days | a year fraction | months | integer days | B |
| Vega measures sensitivity to | spot | volatility | time | rate | B |

## Glossary

- **Option** — the right, not obligation, to buy (call) or sell (put) at a strike.
- **Strike (K)** — the fixed price in the option contract.
- **Expiry (T)** — the settlement date; time-to-expiry in years for B-S.
- **Call payoff** — `max(S−K, 0)`.
- **Put payoff** — `max(K−S, 0)`.
- **Intrinsic value** — payoff if exercised now.
- **Time value** — premium − intrinsic; the bet on future movement.
- **Moneyness** — ITM / ATM / OTM classification.
- **Put-call parity** — `C + K·e^(−rT) = P + S0`.
- **Black-Scholes** — closed-form European option price model; engine = `bs_price`.
- **Implied volatility** — σ solving `bs_price(...) = market price`.
- **Delta / Gamma / Theta / Vega / Rho** — price sensitivities to spot, delta, time, vol, and rate.
- **Covered call / Protective put / Spread / Straddle / Strangle** — multi-leg strategies from the Lesson 6.5 table.

## Reading assignment

Study NIFM Chapter 3 (options) and IFMC item 63 in the [reading list](../appendices/reading-list.md), with CFTe Appendix G as the statistics bridge. Run all three wheel option examples (`01_option_chain.py`, `02_greeks_calculation.py`, `03_backtest_straddle.py`) end-to-end.

## Assessment reminder

This module feeds the strategy payoff-diagram lab (8 strategies with max profit/max loss/breakeven) and the parity/greeks/moneyness quiz; keep your diagrams and the Lab 6 round-trip output in the journal for the [assessment plan](../front/assessment.md).

**Next:** [M7 — Hedging & Risk Management](m7-hedging-risk.md)
