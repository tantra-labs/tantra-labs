# M8 — Financial Modeling

> **Weeks 45–47 · 30 hrs lab · PLO-7 · Core:** IFMC items 51–59; PGP T4(RA)-403

## Learning outcomes

- Build a **revenue builder** from price × volume drivers.
- Build asset/depreciation, capex, and debt schedules.
- Wire a three-statement model: P&L, balance sheet, cash flow.
- Compute FCFF/FCFE inside the model and run checks.
- Deliver a balanced, cross-footed, sensitivity-tested model in `Decimal`.

## Prerequisites

- [M7 — Valuation Methods](m7-valuation-methods.md): the DCF that a financial
  model exists to feed — FCFF/FCFE come out of this module's wiring.
- [M3 — Financial Statement Analysis](m3-financial-statement-analysis.md):
  the statements you are re-projecting; M3's sign conventions carry over.
- [M6 — Cost of Capital, CAPM & WACC](m6-cost-of-capital-capm.md): WACC, the
  discount rate the model's DCF bridge consumes.
- [M4 — Ratio Analysis & DuPont](m4-ratios-dupont.md): the ratios your
  assumptions sheet is expressed in (margins, turnover, days).

## Lesson 8.1 — Revenue builders

### 1) Concept

A financial model is a forecast, and a forecast needs *drivers* — inputs you
can defend — not a "growth rate I made up". The **revenue builder** starts with
the drivers of the business:

```
Revenue = Volume × Price
        = Units × Realization per unit
```

**Bottom-up** building: project units sold (market share × market size, or
capacity × utilisation) and realization per unit (price × mix), optionally with
price hikes layered in by year. **Top-down** building: start from the addressable
market and apply a projected share.

```
Revenue (top-down) = Market size × Company share
```

The **assumptions sheet** is where every driver lives as an explicit, named,
editable input — year-by-year volumes, price hikes, raw-material pass-through,
segment mix. The discipline: *no number in the model may be invisible*. Every
revenue cell traces back to an assumptions-sheet driver; an analyst reviewing
your model can change the driver and watch revenue move. This is what separates
a model from a spreadsheet full of typed numbers.

### 2) Worked example

A 5-year bottom-up revenue builder:

```python
from decimal import Decimal
units_0 = Decimal("100_000"); price_0 = Decimal("1_000")
unit_growth = Decimal("0.08"); price_hike = Decimal("0.04")
rows = []
units, price = units_0, price_0
for y in range(1, 6):
    units = units * (Decimal(1) + unit_growth)
    price = price * (Decimal(1) + price_hike)
    rows.append({"year": y, "units": units, "price": price,
                 "revenue": units * price})
for r in rows:
    print(r)
```

Answer: year-1 revenue = 108,000 × 1,040 = ₹112,320,000, compounding to year-5
revenue ≈ 136,048.90 × 1,169.86 ≈ ₹159.15M. Two explicit drivers (volume growth
8%, price hike 4%) instead of one opaque "12% growth" — and each driver is a
row on the assumptions sheet with its own justification.

### 3) Common pitfalls

> **Pitfall:** Writing `revenue = revenue × 1.12` with no driver behind the
> 12% — the reviewer cannot defend it. Mixing volume and price in one opaque
> number so the *mix* (volume vs price contribution) is invisible. Hard-coding
> a single year's revenue and copying it forward.

### 4) Key takeaways

- **Takeaway:** Revenue = Volume × Price; build it from defensible drivers.
- **Takeaway:** Every driver lives on the assumptions sheet as a named input.
- **Takeaway:** Separate volume growth from price hikes — they move margins
  differently.

## Lesson 8.2 — Asset & depreciation schedule

### 1) Concept

Fixed assets enter through **capex** and age through **depreciation**. The
schedule tracks the gross block:

```
Opening gross block + Capex = Closing gross block
Depreciation = rate × (opening + additions, time-apportioned)
Closing accumulated depreciation = opening + this year's depreciation
Net block = Closing gross block − Closing accumulated depreciation
```

**Gross block** is assets at original cost; **accumulated depreciation** is the
total written off so far; **net block** is what the balance sheet carries.
Assets bought mid-year are depreciated for the months they were in use (a
simplification in most student models: a full-year average `(opening +
closing)/2 × rate` is acceptable if stated).

Why this schedule matters: depreciation flows into the P&L (EBITDA → EBIT, M3),
the balance sheet (net block), and the cash-flow statement (added back to
OCF). An error here poisons all three statements. A *young* company with heavy
capex shows high depreciation and low PAT but high cash (depreciation is
non-cash) — exactly the M3 lesson, now inside a model.

### 2) Worked example

Opening gross block ₹5,000, capex ₹1,000 each year, depreciation rate 10% on
opening block (simplified):

```python
from decimal import Decimal
gross = Decimal("5000"); capex = Decimal("1000"); rate = Decimal("0.10")
acc_dep = Decimal("2000")          # opening accumulated depreciation
for y in range(1, 4):
    dep = gross * rate             # simplified: on opening gross block
    acc_dep += dep
    gross += capex
    net = gross - acc_dep
    print(f"Y{y}: gross {gross} | accum dep {acc_dep} | net block {net} | dep {dep}")
```

Answer: Y1 net block = (5,000 + 1,000) − (2,000 + 500) = 6,000 − 2,500 =
3,500; Y2 = 7,000 − 3,100 = 3,900; Y3 = 8,000 − 3,700 = 4,300. Gross block
grows by capex every year, accumulated depreciation by the annual charge, and
net block tracks the difference — the balance sheet's fixed-asset line is
*driven*, never typed.

### 3) Common pitfalls

> **Pitfall:** Depreciating the *net* block (depreciation would shrink as
> assets age and never fully capture new capex) — depreciate the gross block.
> Forgetting the accumulated-depreciation balance entirely and showing net
> block as "gross − this year's depreciation only". Not time-apportioning
> mid-year additions (state the convention).

### 4) Key takeaways

- **Takeaway:** Gross block grows by capex; accumulated depreciation by the
  annual charge; net block is the difference.
- **Takeaway:** The schedule feeds P&L, balance sheet, and cash flow — errors
  spread.
- **Takeaway:** Heavy depreciation with healthy cash is normal for growth
  companies.

## Lesson 8.3 — Capex and debt schedules

### 1) Concept

**Capex** can be a fixed plan (a factory costing ₹X over years 1–3) or a driver
(`Capex = % of revenue`, or `replacement capex = depreciation + growth capex`).
However it is modelled, the *same* number must hit the asset schedule (gross
block) and the investing-cash-flow line — one capex, three effects.

The **debt schedule** is the balance sheet's other engine:

```
Opening debt + Drawdowns − Repayments = Closing debt
Interest = avg(open, close) × rate
```

Interest uses the **average** balance (`(opening + closing) / 2`) because
mid-year drawdowns earn (cost) only part of the year. **Mandatory repayments**
(term-loan instalments) and **optional repayments** (prepayments when cash is
flush) are separate lines. The schedule's output — interest — flows into the
P&L; the closing balance into the balance sheet; and drawdown/repayment into
financing cash flow. A debt schedule that "balances" (opening + draws − repays
= closing) is the single most common place models break, so every model check
(8.5) tests it.

### 2) Worked example

A two-year debt schedule:

```python
from decimal import Decimal
debt = Decimal("2_000"); draw = Decimal("500"); repay = Decimal("300")
rate = Decimal("0.09")
for y in (1, 2):
    close = debt + draw - repay
    interest = (debt + close) / 2 * rate
    print(f"Y{y}: opening {debt} | closing {close} | avg interest {interest}")
    debt = close
```

Answer: Y1 interest = (2,000 + 2,200)/2 × 0.09 = 2,100 × 0.09 = ₹189; Y2 =
(2,200 + 2,400)/2 × 0.09 = 2,300 × 0.09 = ₹207. The average-balance convention
captures the ₹500 drawdown being lent only part of the year — a full-year
charge on closing debt would overstate interest.

### 3) Common pitfalls

> **Pitfall:** Computing interest on the *closing* balance only (overstates)
> or the *opening* only (understates) — use the average and state it.
> Letting the debt schedule's closing row disagree with the balance-sheet debt
> line. Forgetting mandatory vs optional repayments as separate lines.

### 4) Key takeaways

- **Takeaway:** Capex is one number, three effects: gross block, ICF, and the
  depreciation charge.
- **Takeaway:** Debt: opening + draws − repays = closing; interest on the
  average balance.
- **Takeaway:** The schedule must agree with the balance sheet *every year*.

## Lesson 8.4 — The three-statement model

### 1) Concept

The **three-statement model** wires the P&L, balance sheet, and cash-flow
statement so they *drive each other*:

1. **P&L:** revenue (from the 8.1 builder) → EBIT (via margins, less
   depreciation from 8.2) → interest (from 8.3) → tax → PAT.
2. **Cash flow:** `OCF = PAT + D&A − ΔWC` (working-capital changes from days-
   based drivers); `ICF = −capex`; financing = dividends, debt drawdowns/
   repayments, equity issues. `FCF = OCF + ICF`.
3. **Balance sheet:** assets grow by capex; **retained earnings = prior
   retained earnings + PAT − dividends**; liabilities by the debt schedule. The
   sheet *balances via a plug* — cash (or a revolver when cash would go
   negative).

The famous trick is **the balance sheet must balance every year** — not by
magic, but because the cash-flow statement is constructed so that:
`Ending cash = Opening cash + OCF + ICF + Financing`. If the balance sheet does
not balance, a wiring error exists somewhere; if it does, the model is
*internally consistent* — which is not the same as *right* (the assumptions may
still be wrong), but it is the only place to start. The cash plug (extra cash
when surplus, a revolver when short) is the *balancing item* — the model pulls
cash to force Assets = Liabilities + Equity.

### 2) Worked example

The P&L → cash-flow → balance-sheet loop, one year:

```python
from decimal import Decimal
rev = Decimal("1_200_000"); margin = Decimal("0.20"); tax_rate = Decimal("0.25")
d_and_a = Decimal("40_000"); d_wc = Decimal("25_000")   # working capital used cash
capex = Decimal("60_000"); dividend = Decimal("15_000")
ebit = rev * margin
pat = ebit * (Decimal(1) - tax_rate)
ocf = pat + d_and_a - d_wc
fcf = ocf - capex
print("EBIT:", ebit, "| PAT:", pat, "| OCF:", ocf, "| FCF:", fcf)
```

Answer: EBIT = 240,000; PAT = 180,000; OCF = 180,000 + 40,000 − 25,000 =
195,000; FCF = 195,000 − 60,000 = 135,000. The model's cash-flow statement says
the company generated ₹135,000 of free cash *after* reinvestment — the number
that feeds the M7 DCF bridge. Note the M3 echo: PAT 180,000 but cash (before
capex) 195,000 — depreciation made the cash bigger than the profit.

### 3) Common pitfalls

> **Pitfall:** Typing ending cash on the balance sheet instead of *linking* it
> to the cash-flow statement — the sheet will "balance" once and break the
> moment an assumption changes. Double-counting depreciation (P&L and cash
> flow are linked, not added twice). Forgetting retained earnings accumulates:
> `prior + PAT − dividends`.

### 4) Key takeaways

- **Takeaway:** OCF = PAT + D&A − ΔWC; FCF = OCF + ICF; balance sheet balances
  through the cash plug.
- **Takeaway:** Retained earnings = prior + PAT − dividends; every link is a
  formula, never a typed number.
- **Takeaway:** A balanced sheet proves consistency, not correctness —
  assumptions still need defending.

## Lesson 8.5 — Model checks

### 1) Concept

A model is only trustworthy after **checks**:

1. **Balance check:** Assets = Liabilities + Equity every single year.
2. **Cross-foot:** the sum of a row across years equals the row's total column
   and vice versa — catch a copied cell, a merged range, a missed link.
3. **Sensitivity:** change one assumption (growth, WACC, margin), watch FCF and
   the DCF target move — the model's outputs must *respond* to drivers, and
   the direction must be sensible (higher growth → higher revenue; higher WACC
   → lower DCF value).
4. **No circularity without a controlled solver:** a model that references
   itself (interest depends on debt depends on cash needs) must use an explicit
   iteration/solver or be restructured — silent circular references are the
   classic "the model works until someone changes an input" bug.
5. **No hard-coded numbers:** every cell is a formula or a named assumptions-
   sheet input; a reviewer can audit any number back to its driver.

The final discipline is **the model answers a question**: the capstone's model
must produce FCFF → DCF → target price that reconciles with M7. A model that
balances but cannot state its own answer has failed its purpose.

### 2) Worked example

A minimal automated check on a 3-statement skeleton:

```python
from decimal import Decimal
# model outputs for 5 years
rows = [{"assets": Decimal("3_000_000"), "liab_equity": Decimal("3_000_000")},
        {"assets": Decimal("3_100_000"), "liab_equity": Decimal("3_099_000")}]
for y, r in enumerate(rows, start=1):
    ok = r["assets"] == r["liab_equity"]
    print(f"Y{y} balance check:", ok)
    if not ok:
        print("  -> gap:", r["assets"] - r["liab_equity"], "— find the wiring error")
```

Answer: Y1 balances (assets = liabilities + equity); Y2 shows a ₹1,000 gap —
somewhere a link was typed instead of referenced (a classic: retained earnings
missed the dividend, or an asset line was copied). The check *finds* the year;
the auditor then traces the gap to the broken link.

### 3) Common pitfalls

> **Pitfall:** Balancing the model once and moving on — every assumption
> change re-triggers the checks. Silent circular references that Excel does
> not flag by default — enable the circularity warning. Hard-coding the
> balancing plug (cash) so the sheet balances for the *current* inputs but
> breaks at the first sensitivity run.

### 4) Key takeaways

- **Takeaway:** Balance, cross-foot, sensitivity, no circularity, no hard
  codes — five non-negotiables.
- **Takeaway:** Sensitivity must move outputs in the right *direction*.
- **Takeaway:** A model is finished only when it answers its question and can
  survive a changed assumption.

## Tantra Lab 8 — A mini 3-statement skeleton

### Lab goal

Prove the core wiring of a three-statement model runs exactly in `Decimal` —
driver-based revenue compounding, margin → EBIT → PAT, and the tax step — the
spine that the full capstone workbook grows from.

### Code

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

### Expected output

```
[{'revenue': Decimal('1100000'), 'ebit': Decimal('220000'), 'pat': Decimal('165000')},
 {'revenue': Decimal('1210000'), 'ebit': Decimal('242000'), 'pat': Decimal('181500')},
 ...5 rows...]
```

Revenue compounds at 10% (1,100,000 → 1,464,100 by year 5), EBIT is 20% of
revenue, PAT is 75% of EBIT. All values `Decimal`. This is the *skeleton*: the
capstone adds the depreciation, debt, and cash links of Lessons 8.2–8.4 on top
of exactly this spine.

### Hand-in checklist

- [ ] Skeleton output pasted (5 rows of revenue/EBIT/PAT as `Decimal`).
- [ ] Full capstone workbook with *named tabs*: Assumptions, Revenue builder,
      Asset/Depreciation, Debt, P&L, Balance Sheet, Cash Flow, DCF bridge.
- [ ] Balance check true for all 5 years; cross-foot check documented.
- [ ] FCFF computed inside the model (EBIT(1−t) + D&A − Capex − ΔNWC) and a
      DCF bridge to a target price that reconciles with M7.
- [ ] Three sensitivity runs (growth, margin, WACC) with resulting target
      changes, and the assumptions sheet fully sourced.

### Common errors

- **Error:** linking the skeleton to `float` inputs — keep every driver
  `Decimal` or the model fails the Zero-Floats review.
- **Error:** forgetting ΔNWC when computing FCFF inside the model (the M7
  formula is `EBIT(1−t) + D&A − Capex − ΔNWC`, and ΔNWC is often the biggest
  cash consumer for a growing company).
- **Error:** submitting a workbook that balances for year 1 only — the 
  graders' first act is to change an assumption and re-check every year.

## Practice problems

1. Units 200,000 growing 6% a year, price ₹500 with 3% annual hikes. Build
   years 1–3 revenue in `Decimal`.
2. Opening gross block ₹8,000, capex ₹2,000/year, depreciation 10% on opening
   gross block, opening accumulated depreciation ₹3,000. Compute year-1 and
   year-2 net block.
3. Debt opening ₹3,000, drawdown ₹800, repayment ₹400, rate 8%. Compute closing
   debt and interest for two years using the average convention.
4. Revenue ₹2,000,000, margin 25%, tax 25%, D&A ₹80,000, ΔWC +₹50,000 (cash
   used), capex ₹120,000, dividend ₹40,000. Compute PAT, OCF, FCF.
5. Retained earnings opening ₹500,000, PAT ₹180,000, dividends ₹60,000. What is
   closing retained earnings? Where does it appear on the balance sheet?
6. Your model's year-3 balance sheet is ₹60,000 out of balance. List the three
   most likely wiring errors and how the balance check localises them.
7. Explain in two sentences why the cash plug (cash or revolver) exists in a
   three-statement model.
8. Why is "the balance sheet balances" not a proof the model is *right*? Give
   one example of a model that balances and is still wrong.

### Solutions

1. Y1: 212,000 × 515 = ₹109,180,000; Y2: 224,720 × 530.45 ≈ ₹119,202,724; Y3:
   238,203.2 × 546.36 ≈ ₹130,146,000 (compounded; exact figures in Decimal).
2. Y1 dep = 800; accum dep = 3,800; gross = 10,000; net = 6,200. Y2 dep = 800
   (still on opening block of 10,000 under the simplified convention); accum =
   4,600; gross = 12,000; net = 7,400.
3. Y1 close = 3,400; interest = 3,200 × 0.08 = 256. Y2 open 3,400, close 3,800;
   interest = 3,600 × 0.08 = 288.
4. EBIT = 500,000; PAT = 375,000; OCF = 375,000 + 80,000 − 50,000 = 405,000;
   FCF = 405,000 − 120,000 = 285,000.
5. Closing retained earnings = 500,000 + 180,000 − 60,000 = ₹620,000; it sits
   inside Shareholders' Equity on the balance sheet.
6. Most likely: retained earnings missed the dividend or a prior-year PAT;
   ending cash not linked from the cash-flow statement; the debt schedule's
   closing balance not linked to the balance-sheet debt line. The check
   identifies the year; tracing each link finds the line.
7. The plug absorbs the difference the operating assumptions leave: surplus
   cash when cash is positive, a revolver when cash would go negative — without
   it the sheet cannot balance and the model is inconsistent.
8. Balancing proves internal consistency, not truth: a model with a wrong
   growth assumption or a too-high margin balances perfectly yet overstates the
   target. The checks (8.5) verify *linkage*; the assumptions sheet verifies
   *inputs*.

## Quiz bank

| Question | A | B | C | D | Answer |
|---|---|---|---|---|---|
| A bottom-up revenue builder starts from… | Market size × share | Volume × price | Last year's revenue | GDP growth | B |
| Depreciation is charged on… | Net block | Gross block | Accumulated depreciation | Market value | B |
| Net block = … | Gross − accumulated depreciation | Gross + depreciation | Gross × rate | Gross − capex | A |
| Debt interest is usually computed on… | Closing balance | Opening balance | Average balance | Maximum balance | C |
| OCF = … | PAT + D&A − ΔWC | PAT − D&A | EBIT + D&A | Revenue − costs | A |
| Retained earnings closes as… | Prior + PAT − dividends | Prior + revenue | PAT only | Prior − dividends | A |
| The balance sheet balances via… | The cash plug | Management judgement | The auditor | An assumption | A |
| A silent circular reference… | Is always fine | Breaks the model on input change | Is Excel's fault | Improves accuracy | B |
| Cross-footing means… | Sums of rows = sums of columns | Checking the share price | Balancing two companies | Rounding numbers | A |
| A balanced model proves… | Consistency, not correctness | The target price is right | No assumptions | Growth is real | A |

## Glossary

- **Revenue builder** — the driver-based revenue projection (volume × price, or
  market size × share).
- **Assumptions sheet** — the named, editable drivers that power every model
  cell.
- **Gross block** — fixed assets at original cost.
- **Accumulated depreciation** — the total depreciation charged to date.
- **Net block** — gross block − accumulated depreciation.
- **Capex** — capital expenditure; grows gross block, hits investing cash flow.
- **Debt schedule** — opening + drawdowns − repayments = closing; interest on
  the average balance.
- **OCF** — PAT + D&A − ΔWC; operating cash flow.
- **ICF** — investing cash flow; −capex.
- **FCF** — OCF + ICF; free cash flow.
- **Retained earnings** — prior + PAT − dividends; inside shareholders' equity.
- **Cash plug** — surplus cash (or a revolver) that absorbs the balance-sheet
  residual so Assets = Liabilities + Equity.
- **Balance check** — assets equal liabilities + equity every year.
- **Cross-foot** — row sums equal column sums across the model.

## Reading assignment

Read the modeling chapters in [the reading list](../appendices/reading-list.md):
IFMC items 51–59, PGP T4(RA)-403, and any spreadsheet-modeling chapter in your
NIFM text. Then rebuild a published company's three statements from its annual
report for *one* year in a spreadsheet — hand-wiring the links once is the only
way the balance check stops being magic and becomes second nature.

## Assessment

- **Modeled-company capstone** (programme gate).
- 3-hour modeling practical in the end-term exam.

## Assessment reminder

The modeled-company capstone is a **programme gate**: it is graded on accuracy,
structure, and assumptions, and the end-term exam includes a **3-hour modeling
practical** on the same wiring. The journal you have kept across S3 (M2 memo,
M3 dissection, M4 deck, M6 WACC, M7 valuation) is the capstone's input pack —
check every figure traces to a prior module's worksheet. See
[Assessment](../front/assessment.md) for gate and grading details.

**End of Semester 3.** Next: [Semester 4](../s4/overview.md) — Quantitative
Methods, Derivatives, Research & Regulation.
