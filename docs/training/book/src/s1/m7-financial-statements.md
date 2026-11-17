# M7 — Introduction to Financial Statements

> **Weeks 12–14 · 24 hrs · PLO-5**

## Learning outcomes

- Read an income statement, balance sheet, and cash-flow statement.
- Explain the accounting equation: `Assets = Liabilities + Equity`.
- Read an annual report and DRHP structure (per IFMC syllabus).
- Interpret quarterly results releases.

## Lesson 7.1 — The income statement (P&L)

- Revenue, COGS, gross profit, operating expenses, EBIT, interest, tax, PAT.
- Margins: gross, operating, net (full ratio treatment in S3-M4).

## Lesson 7.2 — The balance sheet

- The accounting equation.
- Current vs non-current assets/liabilities; working capital intuition.
- Equity: share capital, reserves, retained earnings.

## Lesson 7.3 — The cash-flow statement

- Operating, investing, financing sections.
- Why "profit ≠ cash": accruals, depreciation, working-capital changes.
- **Free cash flow preview:** `FCF ≈ OCF - Capex` (fully built in S3-M8).

## Lesson 7.4 — Annual report & MD&A

- What is in an annual report: directors' report, MD&A, financials, notes.
- Management discussion & analysis: the qualitative bridge to numbers.
- How the DRHP (from M3) is structured and what to read first.

## Lesson 7.5 — Quarterly results

- How to read a quarterly release: revenue, PAT, margin, YoY/QoQ.
- "One quarter doesn't make a trend" — the analyst discipline.

## Tantra Lab 7 — A mini financial statement in Decimal

```python
from decimal import Decimal

class PnL:
    def __init__(self):
        self.revenue = Decimal("0"); self.cogs = Decimal("0")
        self.opex = Decimal("0"); self.interest = Decimal("0"); self.tax = Decimal("0")
    @property
    def ebit(self): return self.revenue - self.cogs - self.opex
    @property
    def pat(self):  return self.ebit - self.interest - self.tax

pnl = PnL()
pnl.revenue = Decimal("1_000_000"); pnl.cogs = Decimal("600_000")
pnl.opex = Decimal("150_000"); pnl.interest = Decimal("20_000"); pnl.tax = Decimal("46_000")
print("EBIT", pnl.ebit, "PAT", pnl.pat, "net margin", pnl.pat / pnl.revenue)
```

**Task:** dissect one real annual report (e.g., Infosys or an NSE-listed
company of choice). Build an Excel worksheet that extracts revenue, EBIT, PAT,
total assets, and operating cash flow; answer three questions: *Is the company
profitable? Solvent? Cash-rich?* This mirrors `screening/04_intelligent_investor_screener.py`.

## Assessment

- Lab: one annual report dissection workbook.
- Quiz: statement basics.

**Next:** [M8 — Introduction to Technical Analysis](m8-intro-technical-analysis.md)
