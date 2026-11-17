# M5 — Derivatives: Forwards & Futures

> **Weeks 55–57 · 20 hrs · PLO-9 · Core:** NIFM Ch 2; IFMC items 60–62

## Learning outcomes

- Explain what a derivative is and why it exists.
- Price a forward and a futures contract; explain basis and convergence.
- Compute margin, leverage, and mark-to-market.
- Explain open interest and rollover.

## Lesson 5.1 — What derivatives are

- A derivative's value *derives* from an underlying (stock, index, commodity, FX).
- Uses: hedging, speculation, arbitrage.
- Exchange-traded (futures/options on NSE) vs OTC (forwards).

## Lesson 5.2 — Forward pricing

Cost-of-carry:

```
F = S0 · (1 + r)^T      (for a non-dividend asset)
F = S0 · e^(rT)         (continuous compounding)
F = S0·(1 + (r − y)T)   (with yield y, approx)
```

- Why `F ≠ S`: carry cost, interest, dividends, storage (commodities).

## Lesson 5.3 — Futures: margins & MTM

- Initial margin, maintenance margin, variation margin.
- **Mark-to-market:** daily settlement of gains/losses — the exchange removes
  counterparty risk.
- Leverage: `Notional / Initial margin`.

## Lesson 5.4 — Basis and convergence

```
Basis = Spot − Futures
```

- Basis converges to zero at expiry (arbitrage enforces it).
- Rollover: closing near-month, opening next-month; roll cost = basis difference.

## Lesson 5.5 — Open interest

- OI = number of open contracts — liquidity and positioning signal.
- OI + price action: rising price + rising OI = trend backed by new positions.

## Tantra Lab 5 — Forward price in Decimal

```python
from decimal import Decimal

def forward(spot: Decimal, rate: Decimal, years: Decimal) -> Decimal:
    return spot * (Decimal(1) + rate) ** years

print(forward(Decimal("24000"), Decimal("0.07"), Decimal("1")))   # ≈ 25,680
```

**Task:** extend the script for dividends (`F = (S − PV(Div))·(1+r)^T`) and
compute basis for a near-expiry future. Place a futures-style paper trade on a
`PaperSession` and journal the margin and MTM effect. Run
`tantra-examples/examples/options/01_option_chain.py` to see real NIFTY option
chain data structures (the next module's foundation).

## Assessment

- Quiz + futures pricing worksheet.
- Paper-trade journal entry (futures margin + MTM).

**Next:** [M6 — Options: Pricing & Strategies](m6-options.md)
