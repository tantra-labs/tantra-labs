# 19 · Options

> Part VI · Chapter 19 · Books: 2 · Topic level: deep end ▸ micro

## What this topic is about

Options are derivative contracts: a **call** gives its holder the right to buy
the underlying at a fixed price, a **put** the right to sell it. The mechanics
are simple; what makes options a deep-end topic is the *pricing*. An option's
price is dominated by volatility — an unobservable input — so options are traded
as much on expectations about future turbulence as on direction. The floor
language is not "up or down" but "expensive or cheap."

The two books form a complete two-book curriculum. *Option Volatility & Pricing*
is the canonical options textbook: the contract, the pricing models, the Greeks,
and volatility trading, all in one volume. *Option Spread Strategies* is the
practical playbook: how to construct defined-risk positions — verticals,
calendars, butterflies, iron condors — that cap loss instead of betting the whole
premium.

Options are also leverage and insurance. The same instrument that lets a trader
express a view with a fraction of the capital of the underlying lets a portfolio
owner buy a protective put as insurance. On the NSE, Nifty options are among the
most-traded derivatives in the world; the mechanics here are global, and the
Indian market gives every example in this chapter a live home.

This is the last mechanics chapter of the deep end. By the end of it you should
be able to price an option *approximately*, read what its price says about the
market's fear, and know the difference between a naked bet and a defined-risk
spread — the vocabulary the market philosophy chapter (Chapter 20) then questions
at the level of the market itself.

## The books on this topic

| Title | Author | Year | Rating | Role |
|---|---|---|---|---|
| Option Volatility & Pricing | Sheldon Natenberg | 1994 (1st ed.) | ★ 4.3 | The options textbook |
| Option Spread Strategies | Anthony J. Saliba | 2009 | ★ 3.3 | The spread playbook |

## Study synthesis — what the books jointly teach

**1. What an option is.**

A call is the right to *buy* the underlying at the **strike** price on or before
**expiry**; a put is the right to *sell* at the strike. **Moneyness** describes
where the underlying sits relative to the strike: in-the-money (intrinsic value
positive), at-the-money, or out-of-the-money. An option is a *wasting asset*: its
time value falls to zero at expiry, so the holder needs the underlying to move in
the right direction — and by enough to beat the clock.

**2. Price = intrinsic value + time value.**

```text
option price = intrinsic value + time value

call intrinsic = max(0, underlying − strike)
put  intrinsic = max(0, strike − underlying)
time value     = option price − intrinsic value
```

Intrinsic value is mechanical. Time value is the market's payment for
uncertainty — the chance the option finishes in the money. At-the-money options
carry the most time value, because they have the most chance of either outcome;
deep in- or out-of-the-money options carry almost none.

**3. Volatility is the core pricing input.**

Every other input to an option's price is observable: the underlying price, the
strike, days to expiry, interest rates, dividends. **Volatility is not** — it is
the only number a pricing model cannot look up, and it is the dominant input.
Two otherwise identical options can trade at wildly different prices purely
because the market expects different turbulence ahead. That is why an options
trader spends the day talking about volatility, not direction.

**4. Black-Scholes and the Greeks.**

The **Black-Scholes model** prices a European option by assuming the underlying
follows a continuous random process, then valuing the option as the cost of a
continuously rebalanced hedge. Its intuition, without the calculus: if you can
dynamically hedge the underlying, the option's price is whatever makes the hedge
self-financing. The model's sensitivities — the **Greeks** — are the working
tools:

```text
delta  (Δ) — option price change per 1.00 change in the underlying
gamma  (Γ) — delta's change per 1.00 change in the underlying
theta  (Θ) — option price change per day passing (time decay; negative for a long option)
vega   (ν) — option price change per 1% change in implied volatility
rho    (ρ) — option price change per 1% change in the risk-free rate
```

For most retail trades rho is noise; delta, gamma, theta, and vega are the
working set. Gamma tells you how the directional sensitivity itself changes;
theta is the clock that makes long options bleed and short options earn.

**5. Implied volatility — the market's fear gauge.**

Invert the model: take a market price and solve for the volatility that produces
it. That number — **implied volatility (IV)** — is the volatility the market is
pricing in, and it is a fear gauge. IV inflates when uncertainty inflates
(elections, earnings, crashes) and deflates when calm returns. The VIX index is
simply the market's implied volatility on S&P 500 options; India VIX plays the
same role on the NSE. Expensive options are the market's own forecast of
turbulence — read as sentiment, they tell you how scared the crowd already is.

**6. Why options have a price at all: no arbitrage.**

Option prices cannot be arbitrary, because they are chained to each other and to
the underlying by arbitrage. The anchor is **put-call parity**:

```text
C − P = S − K × e^(−r × T)
(call price − put price = underlying − present value of the strike)
```

If this equality breaks, a trader can buy the cheap side and sell the expensive
side for a riskless profit. Options are priced the way they are because a large,
fast arbitrage community enforces these links — the same efficiency logic you met
in Chapter 1, now applied *inside* the derivative market. This is the answer to
"why does an option have this price?": because the market will not let it have
any other.

**7. Spreads: defined risk instead of naked bets.**

Saliba's subject. A **naked** option is a single long or short — the short naked
call has theoretically unlimited loss. A **spread** is two or more options
combined so that the legs offset:

- **Vertical** — buy one strike, sell a higher strike, same expiry and same type.
  Caps risk, cuts cost, caps reward.
- **Calendar** — same strike, different expiries. Profits from time decay and
  the differing behavior of theta.
- **Butterfly** — three strikes, one expiry (buy one low, sell two middle, buy
  one high). Profits from quiet.
- **Iron condor** — an out-of-the-money call spread *plus* an out-of-the-money
  put spread. Profits if the underlying stays inside a range.

The core lesson is risk structure: a spread removes the unlimited-loss leg of a
naked short and lowers the cost of a long, in exchange for capped reward. The
honest trade-off, which Saliba keeps in view: defined risk only helps if the
position is still sized as a real trade — a capped-loss trade can still be
oversized into a large absolute loss.

## Book-by-book annotations

### Option Volatility & Pricing — Sheldon Natenberg (1994, ★ 4.3)

The textbook. Natenberg walks from the option contract to the pricing models to
the Greeks and on to volatility trading and hedging — the standard first book for
anyone going serious about options, and still assigned decades after its
publication. The collection holds the 1994 first edition; the book's 2013 second
edition is the model-refresh hook for a larger AI companion.

- **Read it for:** the full pricing intuition; the Greeks and how they change
  with the underlying and with time; volatility trading and hedging; reading
  what implied volatility tells you about the crowd's fear.
- **Model refresh:** Newer edition: 2nd ed., 2013; ask your AI study companion
  to expand these notes from its training data.

### Option Spread Strategies — Anthony J. Saliba (2009, ★ 3.3)

The practical spread guide. Saliba walks through verticals, calendars,
butterflies, and iron condors — how each is built, its risk/reward profile, and
when it is the right trade. Where Natenberg teaches pricing, Saliba teaches
position construction and the discipline of defined risk.

- **Read it for:** the spread menu; the risk/reward profile of each structure;
  using spreads to cut cost and cap risk versus naked options; running a
  defined-risk book with real trade examples.
- **Model refresh:** Edition here appears current; your AI companion can still
  expand these notes from its training data.

## Reading order

1. **Option Volatility & Pricing** — the pricing and Greeks foundation. It is a
   long book; work through it slowly rather than skimming.
2. **Option Spread Strategies** — the application, once the pricing vocabulary is
   in place.
3. Return to Natenberg's volatility chapters after your first few real spread
   trades — the second pass is where the book's depth lands.

## Self-test questions

1. Define strike, expiry, and moneyness for a call option.
2. Given a price and intrinsic value, compute the time value of an option.
3. Which pricing input is unobservable, and why does it dominate the price?
4. Which Greek measures time decay, and what is its sign for a long option?
5. What is implied volatility, and why does it spike in periods of fear?
6. State put-call parity and the arbitrage it rules out.
7. Which spread has capped risk and capped reward, and why — compared to a naked
   short call?
8. Why is an iron condor a range play, and what happens to it if the underlying
   breaks the range?

## Cross-links

**Next:** [Chapter 20 · Market Philosophy & Reflexivity](20-market-philosophy.md) ·
**Back:** [Chapter 18](18-specialized-systems.md)
