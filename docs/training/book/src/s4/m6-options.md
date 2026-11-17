# M6 — Options: Pricing & Strategies

> **Weeks 57–59 · 24 hrs · PLO-9 · Core:** NIFM Ch 3; IFMC item 63; CFTe App G (statistics bridge)

## Learning outcomes

- Explain call/put payoff, intrinsic vs time value, and moneyness.
- State put-call parity and the Black-Scholes formula *intuition*.
- Compute option greeks and read an option chain.
- Construct basic strategies: covered call, protective put, spreads, straddles.

## Lesson 6.1 — Payoffs and moneyness

```
Call payoff = max(S − K, 0)      Put payoff = max(K − S, 0)
Intrinsic = payoff at current S; Time value = Option price − intrinsic
```

- Moneyness: ITM / ATM / OTM.

## Lesson 6.2 — Put-call parity

```
C + K·e^(−rT) = P + S0
```

- The cleanest no-arbitrage relationship in options; used to check prices.

## Lesson 6.3 — Black-Scholes intuition

The wheel's `bs_price` implements the standard closed-form model. Key inputs:
`S0`, `K`, `T`, `r`, `σ` (volatility). Only `σ` is unobservable — hence
**implied volatility** (solve `bs_price(...) = market price` for σ). The formula's
core intuition: the option is a leveraged bet on the probability distribution of
the underlying at expiry (the lognormal bridge from M1).

## Lesson 6.4 — Greeks

```
Delta  Δ = ∂Price/∂Spot      Gamma  Γ = ∂Δ/∂Spot
Theta  Θ = ∂Price/∂time      Vega   ν = ∂Price/∂σ
Rho    ρ = ∂Price/∂rate
```

- Read them from the wheel (`bs_greeks`) and the option chain
  (`gamma_profile` in the Rust crate / wheel options chain).

## Lesson 6.5 — Basic strategies

| Strategy | Construction | View |
|---|---|---|
| Covered call | Long stock + short call | Mildly bullish / collect premium |
| Protective put | Long stock + long put | Bullish with insurance |
| Bull/bear spread | Buy/sell two calls or two puts | Directional, limited risk |
| Straddle | Long call + long put, same strike | Volatility view |
| Strangle | Long OTM call + OTM put | Volatility view, cheaper |

Every strategy: max profit, max loss, breakeven — draw the payoff diagram.

## Tantra Lab 6 — Price, greeks, and IV from the wheel

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

Run `tantra-examples/examples/options/02_greeks_calculation.py`,
`01_option_chain.py`, and `03_backtest_straddle.py` for the full picture.

## Assessment

- Strategy payoff-diagram lab (8 strategies, max profit/loss/breakeven).
- Quiz: parity, greeks, moneyness.

**Next:** [M7 — Hedging & Risk Management](m7-hedging-risk.md)
