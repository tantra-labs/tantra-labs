# M8 — Financial Modeling

> **Weeks 45–47 · 30 hrs lab · PLO-7 · Core:** IFMC items 51–59; PGP T4(RA)-403

## Learning outcomes

- Build a **revenue builder** from price × volume drivers.
- Build asset/depreciation, capex, and debt schedules.
- Wire a three-statement model: P&L, balance sheet, cash flow.
- Compute FCFF/FCFE inside the model and run checks.

## Lesson 8.1 — Revenue builders

- Driver-based revenue: `Volume × Price`, `Units × Realization`, price hikes.
- Top-down: market size × share.
- Assumptions sheet: every driver is an explicit, documented input.

## Lesson 8.2 — Asset & depreciation schedule

- Opening gross block → add capex → closing gross block.
- Accumulated depreciation; `Depreciation = rate × (opening + additions)`.
- Net block = gross − accumulated depreciation.

## Lesson 8.3 — Capex and debt schedules

- Capex as % of revenue or a fixed plan.
- Debt schedule: opening balance, drawdowns, repayments, interest =
  `avg(open, close) × rate`. Mandatory vs optional repayments.

## Lesson 8.4 — The three-statement model

1. **P&L:** revenue → EBIT → interest → tax → PAT.
2. **Cash flow:** OCF = PAT + D&A − ΔWC; ICF = −capex; FCF = OCF + ICF.
3. **Balance sheet:** link retained earnings = prior + PAT − dividends;
   balancing via cash plug and/or revolver.

## Lesson 8.5 — Model checks

- Balance sheet must balance every year.
- Cross-foot: sum of rows = sum of columns.
- Sensitivity: change one assumption, watch FCF/target move.
- No circularity without a controlled solver; no hard-coded numbers.

## Tantra Lab 8 — A mini 3-statement skeleton

```python
from decimal import Decimal

def project_3stmt(revenue_0, growth, margin, tax_rate, years=5):
    rows = []
    rev = revenue_0
    for y in range(years):
        rev = rev * (Decimal(1) + growth)
        ebit = rev * margin
        pat = ebit * (Decimal(1) - tax_rate)
        rows.append({"revenue": rev, "ebit": ebit, "pat": pat})
    return rows

print(project_3stmt(Decimal("1_000_000"), Decimal("0.10"), Decimal("0.20"), Decimal("0.25")))
```

**Task:** build the **full modeled-company workbook** for your shortlist company
(revenue builder + schedules + 3-statement + FCFF + DCF bridge). This is the S3
**capstone deliverable** — graded on accuracy, structure, and assumptions. Run
`backtesting/01_first_backtest.py` as a bonus to see the modelling mindset
(cash in → cash out → returns) applied to trading.

## Assessment

- **Modeled-company capstone** (programme gate).
- 3-hour modeling practical in the end-term exam.

**End of Semester 3.** Next: [Semester 4](../s4/overview.md) — Quantitative
Methods, Derivatives, Research & Regulation.
