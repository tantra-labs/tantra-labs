# M7 — Introduction to Financial Statements

> **Weeks 12–14 · 24 hrs · PLO-5**

## Learning outcomes

- Read an income statement, balance sheet, and cash-flow statement.
- Explain the accounting equation: `Assets = Liabilities + Equity`.
- Read an annual report and DRHP structure (per IFMC syllabus).
- Interpret quarterly results releases.

## Prerequisites

- [M1 — Financial Literacy & Business Math](m1-math.md): margins and growth rates in this module are M1 arithmetic applied to company numbers.
- [M2 — Excel for Finance](m2-excel.md): your lab is a workbook that dissects a real annual report.
- [M3 — How Capital Markets Work](m3-markets.md): the DRHP was introduced there; this module reads it.
- [M6 — Corporate Actions](m6-corporate-actions.md): EBIT/PAT and banking vocabulary are already in your word bank.

## Lesson 7.1 — The income statement (P&L)

### 1) Concept

The **income statement** (profit & loss account, "P&L") tells the profit story for a period (a quarter or a year). It is a staircase: start with **revenue** (sales), subtract the direct cost of making/selling the product — **COGS** (cost of goods sold) — to get **gross profit**; subtract **operating expenses** (salaries, rent, marketing, R&D) to get **EBIT** (earnings before interest and tax — the operating profit); subtract **interest** (finance cost) to get profit before tax; subtract **tax** to get **PAT** (profit after tax — the bottom line). 

Three **margins** summarise the staircase: *gross margin* (gross profit ÷ revenue — pricing power of the product), *operating margin* (EBIT ÷ revenue — how efficiently the business is run), and *net margin* (PAT ÷ revenue — what survives all costs and taxes). Margins are ratios, so they let you compare a ₹1,000 crore company with a ₹100 crore company (M1's ratio habit). The full ratio treatment is S3-M4; here you learn to walk the staircase.

### 2) Worked example

The P&L staircase:

```
Revenue           100,00,00,000
COGS              60,00,00,000
Gross profit      40,00,00,000   (gross margin 40%)
Opex              15,00,00,000
EBIT              25,00,00,000   (operating margin 25%)
Interest           2,00,00,000
PBT               23,00,00,000
Tax (20%)          4,60,00,000
PAT               18,40,00,000   (net margin 18.4%)
```

```python
from decimal import Decimal

revenue, cogs, opex = Decimal("100_00_00_000"), Decimal("60_00_00_000"), Decimal("15_00_00_000")
interest, tax = Decimal("2_00_00_000"), Decimal("4_60_00_000")
gross = revenue - cogs
ebit = gross - opex
pat = ebit - interest - tax
print("gross margin:", gross / revenue, "| operating margin:", ebit / revenue,
      "| net margin:", pat / revenue)
```

Output: `gross margin: 0.4 | operating margin: 0.25 | net margin: 0.184`.

### 3) Common pitfalls

> **Pitfall:** computing net margin as PAT ÷ *gross profit* — the denominator is always revenue. **Pitfall:** calling EBIT "the bottom line" — interest and tax are still ahead. **Pitfall:** comparing one quarter's margin to a very different season's margin without a YoY check.

### 4) Key takeaways

- **Takeaway:** revenue → COGS → gross → opex → EBIT → interest → tax → PAT.
- **Takeaway:** gross/operating/net margins are the three lenses on profitability.
- **Takeaway:** margins make different-sized companies comparable.
- **Takeaway:** S3-M4 formalises these into the full ratio toolkit.

## Lesson 7.2 — The balance sheet

### 1) Concept

The **balance sheet** is a snapshot *at a point in time* of what a company owns and owes:

```
Assets = Liabilities + Equity
```

**Assets** are what the company owns: **current assets** (cash, receivables, inventory — convertible to cash within a year) and **non-current assets** (plant, machinery, goodwill — long-lived). **Liabilities** are what it owes: **current liabilities** (payables, short-term debt) and **non-current liabilities** (long-term debt). **Equity** is the owners' stake: **share capital** (the money from issued shares at face value), **reserves** (accumulated retained profits), and **retained earnings** — the arithmetic remainder that makes the two sides balance.

**Working capital** is the short-run operating cushion: `current assets − current liabilities`. Positive working capital means the company can meet near-term obligations without selling its factory. The equation is the built-in error check of accounting: if the two sides don't balance, someone mis-added — which is why your Excel models must carry a cross-foot (M2's hygiene).

### 2) Worked example

The balance sheet balances:

```
Assets:  cash 20 + receivables 30 + inventory 25 + plant 125 = 200
Liabilities:  payables 40 + long-term debt 80 = 120
Equity:  share capital 30 + reserves 50 = 80
Check: 200 = 120 + 80  ✓   Working capital = (20+30+25) - 40 = 35
```

```python
from decimal import Decimal

ca = Decimal("20") + Decimal("30") + Decimal("25")   # current assets
cl = Decimal("40")                                    # current liabilities
assets = ca + Decimal("125")
liab = cl + Decimal("80")
equity = Decimal("30") + Decimal("50")
print("assets == liab + equity:", assets == liab + equity,
      "| working capital:", ca - cl)
```

Output: `assets == liab + equity: True | working capital: 35`.

### 3) Common pitfalls

> **Pitfall:** reading the balance sheet as a *flow* — it is a point-in-time snapshot; the P&L is the flow. **Pitfall:** treating all assets as instantly cashable — plant and goodwill are not current assets. **Pitfall:** skipping the "does it balance?" check.

### 4) Key takeaways

- **Takeaway:** `Assets = Liabilities + Equity` is the accountant's inviolable law.
- **Takeaway:** current vs non-current tells you *timing* of claims and cash.
- **Takeaway:** working capital = current assets − current liabilities.
- **Takeaway:** equity = share capital + reserves (accumulated profit).

## Lesson 7.3 — The cash-flow statement

### 1) Concept

The **cash-flow statement** tracks *actual money movement* in three sections: **operating** (OCF — cash from the core business), **investing** (capex on plant, purchases/sales of investments), and **financing** (borrowing, repaying, dividends, equity issuance). Its job is to answer the question the P&L can't: *is the profit real cash?*

Why profit ≠ cash: **accruals** (revenue booked before cash arrives — credit sales sit in receivables), **depreciation** (an accounting cost that removes *no cash* — it just allocates a past purchase over years), and **working-capital changes** (growing inventory and receivables consume cash). So a company can report a fat PAT and still run out of cash — and vice versa. The bridge number is **free cash flow**:

```
FCF ≈ OCF - Capex
```

FCF is what the business can distribute or reinvest after maintaining its assets. The full statement-level build is S3-M8; this module's job is the intuition that *profit is an opinion; cash is a fact*.

### 2) Worked example

Profit vs cash:

```
PAT (accrual) = 25 crore, but:
  depreciation added back    +6 crore   (a non-cash cost)
  receivables grew           -8 crore   (sold on credit, cash not yet in)
  inventory grew             -3 crore
  OCF = 25 + 6 - 8 - 3 = 20 crore
  Capex = -12 crore
  FCF = 20 - 12 = 8 crore
```

```python
from decimal import Decimal

pat, dep = Decimal("25"), Decimal("6")
receivables_growth, inventory_growth = Decimal("8"), Decimal("3")
capex = Decimal("12")
ocf = pat + dep - receivables_growth - inventory_growth
print("OCF:", ocf, "| FCF:", ocf - capex)
```

Output: `OCF: 20 | FCF: 8` — PAT of 25 became FCF of 8, because profit and cash are different numbers.

### 3) Common pitfalls

> **Pitfall:** treating PAT as spendable cash. **Pitfall:** ignoring working-capital changes — a company growing receivables/inventory "eats" cash even while showing profit. **Pitfall:** calling depreciation a "cash expense" — it is a non-cash allocation.

### 4) Key takeaways

- **Takeaway:** cash flow has three sections: operating, investing, financing.
- **Takeaway:** `FCF ≈ OCF − Capex` is the cash the business truly generates.
- **Takeaway:** profit ≠ cash: accruals, depreciation, and working capital are the gap.
- **Takeaway:** S3-M8 builds the full free-cash-flow model.

## Lesson 7.4 — Annual report & MD&A

### 1) Concept

An **annual report** is the company's yearbook: the **directors' report** (management's narrative of the year), the **MD&A** (management discussion & analysis — the qualitative bridge from strategy to numbers), the audited **financial statements** (P&L, balance sheet, cash flow), and the **notes to accounts** (the fine print where the real disclosures live — accounting policies, contingent liabilities, related-party deals). A DRHP (from M3) follows the same DNA but in a pre-IPO frame: business overview, financials, risk factors, promoter details, objects of the issue.

The analyst's reading order: **first the risk factors** (where the company is forced to be honest), **then MD&A** (what management claims), **then the numbers** (do the numbers confirm the claims?), **then the notes** (what hides in the fine print?). A common beginner trap is reading only the P&L headline — the note on "contingent liabilities" (lawsuits, guarantees) can change the story.

### 2) Worked example

Pulling the two-year revenue growth from an annual report:

```
FY24 revenue = 8,000 crore ; FY25 revenue = 9,600 crore
YoY growth = (9600 - 8000) / 8000 = 20%
MD&A claims "strong double-digit growth" — the numbers agree.
```

```python
from decimal import Decimal

fy24, fy25 = Decimal("8000_00_00_000"), Decimal("9600_00_00_000")
print("YoY growth:", (fy25 - fy24) / fy24)
```

Output: `YoY growth: 0.2`.

### 3) Common pitfalls

> **Pitfall:** reading the MD&A as fact — it is management's *story*; check it against the numbers. **Pitfall:** skipping the notes where provisions and contingent liabilities live. **Pitfall:** comparing FY numbers without checking the *financial year* definition (most Indian companies follow April–March).

### 4) Key takeaways

- **Takeaway:** an annual report = directors' report + MD&A + financials + notes.
- **Takeaway:** read risk factors → MD&A → numbers → notes.
- **Takeaway:** the DRHP is an annual report in pre-IPO form.
- **Takeaway:** verify every narrative claim against the statements.

## Lesson 7.5 — Quarterly results

### 1) Concept

Listed companies release **quarterly results**: revenue, PAT, margins, and commentary, along with **YoY** (vs the same quarter last year — the seasonality-safe comparison) and **QoQ** (vs the previous quarter — the momentum comparison). The discipline: compare YoY primarily, QoQ with care (many businesses are seasonal — a Diwali quarter differs from a monsoon quarter). One quarterly beat is not a trend; the analyst waits for confirmation across quarters before changing a view.

The release's "beats or misses" is measured against *expectations* (analyst consensus), not just last year. A stock can fall on a strong quarter if the market expected stronger — price moves on the *surprise*, which is the M8 lesson that price discounts everything.

### 2) Worked example

YoY and QoQ:

```
Q2 FY26 revenue = 2,400 crore
Q2 FY25 revenue = 2,000 crore  -> YoY +20%
Q1 FY26 revenue = 2,300 crore  -> QoQ +4.3%
```

```python
from decimal import Decimal

q2fy26, q2fy25, q1fy26 = Decimal("2400"), Decimal("2000"), Decimal("2300")
print("YoY:", (q2fy26 - q2fy25) / q2fy25, "| QoQ:", (q2fy26 - q1fy26) / q1fy26)
```

Output: `YoY: 0.2 | QoQ: 0.0434782608695652173913043478`.

### 3) Common pitfalls

> **Pitfall:** panicking on a QoQ dip that is pure seasonality — always pair QoQ with YoY. **Pitfall:** treating one quarter as a trend — "one quarter doesn't make a trend" is a rule, not a cliché. **Pitfall:** judging a quarter without knowing what the market *expected*.

### 4) Key takeaways

- **Takeaway:** quarterly results report revenue, PAT, margins, YoY and QoQ.
- **Takeaway:** YoY is the seasonality-safe comparison; QoQ shows momentum.
- **Takeaway:** price moves on the surprise vs expectations.
- **Takeaway:** confirmation across quarters, not one print, builds a view.

## Tantra Lab 7 — A mini financial statement in Decimal

### Lab goal

Build the P&L staircase as a tiny Decimal class and prove the margin arithmetic with exact arithmetic — then do the same walk on a real annual report in Excel.

### Code

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

### Expected output

`EBIT 250000 PAT 184000 net margin 0.184` — the exact staircase from Lesson 7.1's worked example, computed without a single float.

### Hand-in checklist

- [ ] Lab script `lab7.py` output pasted in the journal.
- [ ] Annual-report dissection workbook: revenue, EBIT, PAT, total assets, operating cash flow extracted from one real report, with source page/note cited per line.
- [ ] Written answers to the three questions — profitable? solvent? cash-rich? — each with the supporting number.
- [ ] One paragraph connecting the workbook to `screening/04_intelligent_investor_screener.py` (run it and note what it screens on).

### Common errors

- **Float sneaking in** — `self.revenue = 1_000_000` would be an `int` (fine), but any `0.5` becomes float; keep every money field a `Decimal`.
- **Copying the wrong year** — annual reports contain two years of comparatives; label FY columns explicitly in the workbook.
- **Treating OCF as profit** — the "cash-rich?" question uses the *cash-flow statement*, not the P&L.

## Practice problems

1. Revenue 500 crore, COGS 300 crore, opex 100 crore, interest 20 crore, tax 25 crore. Compute gross profit, EBIT, PBT, PAT, and all three margins.
2. Assets 300 (cash 40, receivables 60, inventory 50, plant 150), liabilities 180 (payables 70, long-term 110). Compute equity and working capital. Does it balance?
3. PAT 50 crore, depreciation 10 crore, receivables +12 crore, inventory +5 crore, capex 25 crore. Compute OCF and FCF.
4. Why is PAT ≠ cash even when the company has no debt and pays no tax?
5. Name the four parts of an annual report and the analyst's reading order.
6. A quarter reports revenue +5% QoQ but −2% YoY. What is the more meaningful number, and why?

### Solutions

1. Gross = `500-300 = 200` (40%); EBIT = `200-100 = 100` (20%); PBT = `100-20 = 80`; PAT = `80-25 = 55` (11%).
2. Equity = `300-180 = 120`; working capital = `(40+60+50) - 70 = 80`; balance: `300 = 180 + 120` ✓.
3. `OCF = 50 + 10 - 12 - 5 = 43`; `FCF = 43 - 25 = 18`.
4. Accruals (credit sales in receivables), depreciation (non-cash), and working-capital build all separate profit from cash — debt/tax are not the only gap.
5. Directors' report, MD&A, financial statements, notes; reading order: risk factors → MD&A → numbers → notes.
6. The YoY (−2%) — QoQ can be seasonal; YoY strips seasonality by comparing the same calendar quarter.

## Quiz bank

| Question | A | B | C | D | Answer |
|---|---|---|---|---|---|
| The correct profit staircase is: | revenue→EBIT→gross→PAT | revenue→gross→EBIT→PAT | PAT→EBIT→gross | revenue→PAT→EBIT | B |
| Net margin = | PAT ÷ revenue | EBIT ÷ revenue | gross ÷ revenue | PAT ÷ equity | A |
| The accounting equation is: | A = L + E | A + L = E | E = A + L | A − E = L + L | A |
| Working capital = | current assets − current liabilities | revenue − COGS | equity − reserves | assets − equity | A |
| The statement that tracks actual cash movement is: | balance sheet | cash-flow statement | P&L | notes | B |
| Depreciation is: | a cash expense | a non-cash allocation | revenue | a liability | B |
| FCF is approximately: | PAT − tax | OCF − capex | revenue − opex | assets − liabilities | B |
| The first section an analyst reads in a DRHP is: | auditor report | risk factors | shareholding | dividend policy | B |
| YoY compares: | this quarter vs previous quarter | this quarter vs same quarter last year | this year's budget | vs industry | B |
| "Profit is an opinion; cash is a fact" warns against: | reading PAT as cash | reading cash as PAT | both statements | inflation | A |

## Glossary

- **P&L (income statement)** — the period's revenue-to-profit staircase.
- **Revenue / COGS / gross profit** — sales / direct cost of sales / revenue minus COGS.
- **EBIT / PBT / PAT** — operating profit / profit before tax / profit after tax.
- **Margin** — a profit measure ÷ revenue (gross, operating, net).
- **Balance sheet** — a point-in-time snapshot; `Assets = Liabilities + Equity`.
- **Current vs non-current** — realisable/owing within a year vs longer.
- **Working capital** — current assets minus current liabilities.
- **Cash-flow statement** — operating / investing / financing cash movements.
- **FCF** — free cash flow ≈ operating cash flow minus capex.
- **MD&A** — management discussion & analysis: the narrative bridge to the numbers.
- **Notes to accounts** — the fine print: policies, provisions, contingencies.
- **YoY / QoQ** — same-quarter-last-year / previous-quarter comparisons.

## Reading assignment

From the [Reading & Resource List](../appendices/reading-list.md), read Penman's *Financial Statement Analysis* concept chapters and the NISM XV workbook statement sections; keep the annual report or DRHP you chose for the lab open while you work. The `screening/04_intelligent_investor_screener.py` platform example shows the statement ratios in production.

## Assessment reminder

M7 is graded by the **annual-report dissection workbook** and the **statement-basics quiz**, both continuous assessment; statement-reading questions appear in the S1 end-term. Your three "profitable/solvent/cash-rich?" answers are the first full-company analysis you submit. See [Assessment & Grading Scheme](../front/assessment.md).

**Next:** [M8 — Introduction to Technical Analysis](m8-intro-technical-analysis.md)
