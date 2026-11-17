# M5 — Securities & Instruments

> **Weeks 8–10 · 20 hrs · PLO-2**

## Learning outcomes

- Classify any instrument as equity, debt, hybrid, or derivative.
- Describe the features of ordinary/preference shares, bonds, debentures, G-secs.
- Explain mutual funds (types, AMC, AUM), ETFs, REITs/InvITs.
- Compute and interpret Net Asset Value (NAV).
- Know the alternative asset classes (gold, commodities, art, crypto).

## Lesson 5.1 — Equity

- Ordinary vs preference shares; face value, book value, market cap.
- EPS and dividends (formal ratios in S3-M4).
- Equity risk: why equity is the riskiest mainstream asset.

## Lesson 5.2 — Debt and hybrids

- Bonds, debentures, G-secs; coupon, yield, maturity, credit risk.
- Hybrids: convertible debentures, preference shares as quasi-debt.
- **Inverse relationship between bond price and yield** (intuition; math in S4-M8).

## Lesson 5.3 — Mutual funds and ETFs

- AMC, scheme, AUM, expense ratio, exit load.
- Types: equity, debt, hybrid, index, ELSS; direct vs regular.
- ETF vs index fund vs active fund.

## Lesson 5.4 — NAV analysis

```
NAV = (Market value of scheme assets - liabilities) / units outstanding
```

- Why NAV itself is not the right comparison metric across funds — returns,
  risk, and costs are (foreshadows S4-M4 performance measurement).

## Lesson 5.5 — Alternatives

- Commodities (MCX), gold, REITs/InvITs, international funds, private markets.
- Where alternatives sit in a portfolio (link to S5-PM/IA tracks).

## Tantra Lab 5 — NAV and a two-fund comparison

```python
from decimal import Decimal

def nav(assets: Decimal, liabilities: Decimal, units: Decimal) -> Decimal:
    return (assets - liabilities) / units

# Fund A vs Fund B, same NAV — but different assets/costs
a = nav(Decimal("1_000_000_000"), Decimal("50_000_000"), Decimal("950_000_000"))
b = nav(Decimal("2_000_000_000"), Decimal("100_000_000"), Decimal("1_900_000_000"))
print("NAV A", a, "NAV B", b)  # identical — but A is smaller
```

**Task:** build a fund-comparison worksheet in Excel (S1-M2 skills): NAV,
expense ratio, 1y/3y returns (compute returns in Decimal), and risk. Read the
AMFI NAV import example `tantra-examples/examples/storage/03_import_amfi_nav.py`
and `mutual_funds/01_fetch_nav.py` to see real NAV pipelines.

## Assessment

- Assignment: fund-comparison table + NAV worksheet (Excel).
- Quiz: classify 20 instruments.

**Next:** [M6 — Corporate Actions & Financial Terminology](m6-corporate-actions.md)
