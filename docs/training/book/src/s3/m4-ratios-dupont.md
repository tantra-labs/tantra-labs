# M4 — Ratio Analysis & DuPont

> **Weeks 39–40 · 16 hrs · PLO-5 · Core:** NIFM Ch 21; IFMC items 36–39

## Learning outcomes

- Compute the liquidity, solvency, profitability, and efficiency ratio families.
- Explain the **step-wise DuPont decomposition** of ROE.
- Interpret PE, EPS, P/B, EV/EBITDA, dividend yield in context.
- Benchmark a company's ratios against its industry.

## Lesson 4.1 — Ratio families

| Family | Examples |
|---|---|
| Liquidity | Current, quick/acid-test |
| Solvency | Debt/equity, interest coverage (ICR), debt service |
| Profitability | Gross/operating/net margin, ROE, ROA |
| Efficiency | Debtor days, inventory days, asset turnover, payable days |

## Lesson 4.2 — DuPont decomposition

Three-step:

```
ROE = (PAT / Revenue) × (Revenue / Assets) × (Assets / Equity)
       net margin        asset turnover       financial leverage
```

Five-step (adds tax and interest):

```
ROE = Net Margin × Asset Turnover × Equity Multiplier
    = (PAT/EBT) × (EBT/EBIT) × (EBIT/Revenue) × (Revenue/Assets) × (Assets/Equity)
```

**The analyst question:** is a high ROE from margin, from asset efficiency, or
from leverage? Same ROE, very different businesses.

## Lesson 4.3 — Market ratios

- **EPS** = PAT / shares; **PE** = price / EPS (trailing vs forward).
- **P/B** = price / book value; **EV/EBITDA** (formal in M7).
- **Dividend yield** = DPS / price; payout ratio = DPS / EPS.
- Ratios are meaningless without a benchmark (peer, history, sector).

## Lesson 4.4 — Ratio interpretation pitfalls

- One ratio never tells the story; cross-check families.
- Balance-sheet ratios are point-in-time; margins are flow — match periods.
- Window-dressing risk at year-end.

## Tantra Lab 4 — DuPont in Decimal

```python
from decimal import Decimal

def dupont(pat, revenue, assets, equity):
    margin = pat / revenue
    turnover = revenue / assets
    leverage = assets / equity
    return {"net_margin": margin, "asset_turnover": turnover,
            "equity_multiplier": leverage, "roe": margin * turnover * leverage}

print(dupont(Decimal("100_000"), Decimal("1_000_000"), Decimal("2_000_000"), Decimal("800_000")))
```

**Task:** build the ratio deck for your S3-M2 shortlist company in Excel:
liquidity, solvency, profitability, efficiency, plus the 5-step DuPont. Write a
one-page memo: "Why did ROE change?" between two years.

## Assessment

- Ratio-deck Excel deliverable + DuPont memo.
- Quiz: ratio definitions and interpretation.

**Next:** [M5 — Time Value of Money & Capital Budgeting](m5-tvm-capital-budgeting.md)
