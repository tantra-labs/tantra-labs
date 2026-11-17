# M8 — Currency & Fixed Income Markets

> **Weeks 60–61 · 16 hrs · PLO-2, PLO-9 · Core:** NIFM Ch 4; PGP T2-203

## Learning outcomes

- Explain FX pairs, factors driving exchange rates, and RBI's role.
- Price a bond: YTM, duration, and price-yield relationship.
- Describe the yield curve and its information content.
- Place fixed income and currency in the instrument taxonomy (S1-M5).

## Lesson 8.1 — Currency market basics

- FX pairs: base/quote; `USD/INR` reading.
- Drivers: interest-rate differentials, trade balance, capital flows, RBI policy.
- RBI's role: intervention, reserves, managed float.

## Lesson 8.2 — Currency derivatives (India)

- USD/INR futures and options; lot sizes; who hedges (importers/exporters).
- The link between FX moves and equity sectors (IT revenue, importers' costs).

## Lesson 8.3 — Bond pricing and YTM

```
Price = Σ C/(1+y)^t + FV/(1+y)^n
```

- **Inverse price-yield relationship**: yield up → price down.
- YTM is the IRR of the bond's cash flows.
- Bond price sensitivity = **duration**:

```
Duration ≈ Σ [t·PV(CF_t)] / Price
```

- Modified duration ≈ % price change per 1% yield change.

## Lesson 8.4 — Yield curves and credit

- Normal (upward), inverted, flat curves and what they signal.
- Credit spreads: corporate vs G-sec; rating agency terminology.

## Lesson 8.5 — Alternatives overview

- REITs/InvITs, gold, commodities — how they differ from bonds/equity;
  where they appear in a portfolio (S5 tracks).

## Tantra Lab 8 — Bond price and duration in Decimal

```python
from decimal import Decimal

def bond_price(coupon, face, yield_, years):
    p = Decimal(0)
    for t in range(1, years + 1):
        p += coupon / (Decimal(1) + yield_) ** t
    p += face / (Decimal(1) + yield_) ** years
    return p

print(bond_price(Decimal("80"), Decimal("1000"), Decimal("0.10"), 5))
```

**Task:** verify the inverse price-yield relationship by re-pricing the bond at
yield 8%, 10%, and 12%; compute duration by hand; then fetch an FX series in
`tantra_examples` (or the `markets/india` module) and summarize one week of
`USD/INR` moves with three drivers named.

## Assessment

- Quiz + bond-pricing worksheet (3 yields, duration).
- FX weekly summary (1 page).

**Next:** [M9 — Research Report Writing & Analyst Presentations](m9-research-report-writing.md)
