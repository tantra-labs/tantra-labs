# M3 — Financial Statement Analysis

> **Weeks 37–39 · 24 hrs · PLO-5 · Core:** NIFM Ch 19, 34; PGP T1-103; IFMC items 3–5, 15–16

## Learning outcomes

- Read the income statement, balance sheet, and cash-flow statement at depth.
- Distinguish accrual earnings from cash reality.
- Spot accounting red flags: unusual receivables, related-party transactions,
  aggressive revenue recognition.
- Read quarterly results and annual reports like an analyst.

## Lesson 3.1 — Income statement deep dive

- Revenue recognition (accrual basis; when is revenue really revenue?).
- Cost structure: COGS, opex; EBITDA vs EBIT vs PAT walk.
- Quality of earnings: one-time items, extraordinary gains, tax effects.

## Lesson 3.2 — Balance sheet deep dive

- Working capital: receivables, inventory, payables; cash conversion cycle.
- Debt structure: short vs long term; debt covenants; off-balance-sheet items.
- Equity quality: share capital, reserves, treasury, minority interest.

## Lesson 3.3 — Cash-flow statement deep dive

- Operating, investing, financing — re-read the *why* for each.
- **Free cash flow preview:**

```
FCF = Operating Cash Flow − Capital Expenditure
```

- Cash conversion: `OCF / PAT` — how much of the profit is real cash?
- A company can be profitable and still die of cash starvation.

## Lesson 3.4 — Red-flag checklist

- Receivables growing faster than revenue.
- Related-party sales/loans; pledged promoter shares.
- Frequent auditor qualifications; restatements.
- Rising inventory with flat sales.

## Lesson 3.5 — Quarterly & annual dissection

- Quarterly: YoY vs QoQ, margin drift, management commentary.
- Annual: full statements + notes; the notes are where the truth hides.

## Tantra Lab 3 — Cash conversion in Decimal

```python
from decimal import Decimal

class Financials:
    revenue = Decimal("1_000_000"); receivables = Decimal("120_000")
    inventory = Decimal("90_000"); payables = Decimal("60_000")
    ocf = Decimal("140_000"); capex = Decimal("40_000"); pat = Decimal("100_000")

f = Financials()
fcf = f.ocf - f.capex
print("FCF:", fcf, "cash conversion (OCF/PAT):", f.ocf / f.pat)
```

**Task:** dissect one real company's annual report (or use
`screening/04_intelligent_investor_screener.py` to pull the metrics). Build the
full worksheet: revenue, EBIT, PAT, total assets, OCF, FCF; answer profitability,
solvency, cash quality. Submit with the red-flag checklist applied.

## Assessment

- Full-company statement dissection project (report + model skeleton).
- Quiz: statement mechanics and red flags.

**Next:** [M4 — Ratio Analysis & DuPont](m4-ratios-dupont.md)
