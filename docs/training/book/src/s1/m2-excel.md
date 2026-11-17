# M2 — Excel for Finance

> **Weeks 2–4 · 30 hrs (lab-heavy) · PLO-5, PLO-7 prerequisites**

## Learning outcomes

- Navigate Excel/LibreOffice fluently; know when *not* to use a calculator.
- Build worksheets with formulas, lookups, pivot tables, and charts.
- Use financial functions: `PV`, `FV`, `NPV`, `IRR`, `PMT`.
- Format models so they are readable and auditable (modeling hygiene that S3-M8 depends on).

## Prerequisites

- [M1 — Financial Literacy & Business Math](m1-math.md): you will type the exact compounding, PV, and EMI formulas from M1 into Excel cells.
- Basic file management: save workbooks, use folders, keep versions.
- A working copy of Excel (or LibreOffice Calc) and the `bars.csv` output idea from the M1 lab — you will generate your own data file in this module's lab.
- Later modules that assume this module: [M8 — Introduction to Technical Analysis](m8-intro-technical-analysis.md) uses your charting skills, and [M9 — Professional Skills](m9-professional-skills.md) uses your 3-slide workbook habit.

## Lesson 2.1 — Spreadsheet literacy

### 1) Concept

A spreadsheet is a grid of **cells**. Each cell has an address: column letter then row number, so `B3` is column B, row 3. A **range** is a rectangular block — `A1:A5` means the five cells A1 through A5. A **formula** always starts with `=`; it computes from other cells. This is the difference from a calculator: formulas *update* when the inputs change, which is what makes a spreadsheet a model rather than a one-off computation.

References come in two flavours. **Relative references** (`A1`) shift when you copy the formula to another cell — this is usually what you want when filling a column. **Absolute references** (`$A$1`) stay pinned to one cell — you use them when every row must divide by the same constant, such as a single tax-rate cell. `$A1` pins the column and `A$1` pins the row.

Core functions: `SUM` adds a range, `AVERAGE` averages it, `IF` chooses between two results based on a condition, and `AND`/`OR` combine conditions. The mantra of this lesson: *every number in a model should come from a cell, not from your head*.

### 2) Worked example

Five daily closing prices of INFY in `A1:A5`: 1800, 1812, 1805, 1820, 1818.

```
=SUM(A1:A5)      -> 9055
=AVERAGE(A1:A5)  -> 1811
=B1/$B$1         -> the value in B1 divided by the single assumption cell B1
```

```python
from decimal import Decimal

prices = [Decimal("1800"), Decimal("1812"), Decimal("1805"),
          Decimal("1820"), Decimal("1818")]
print("sum   :", sum(prices, Decimal(0)))
print("average:", sum(prices, Decimal(0)) / Decimal(len(prices)))
```

Output: `sum : 9055`, `average: 1811` — the same answers Excel gives, but computed exactly with Decimal (Excel uses binary doubles internally; Decimal is the course standard).

### 3) Common pitfalls

> **Pitfall:** copying a formula with a relative reference and watching it silently shift (`=A1*B1` copied one row down becomes `=A2*B2`). Pin what must not move with `$`. **Pitfall:** typing a number inside a formula (`=9055/5`) instead of referencing cells — that is a hard-coded number, and it is how models rot. **Pitfall:** trusting Excel's rounded display — Excel stores full precision; what you see is a display format.

### 4) Key takeaways

- **Takeaway:** a formula `=` builds a live model; a typed number builds a dead one.
- **Takeaway:** use `$` to pin assumptions; let relative references do the filling.
- **Takeaway:** `SUM`/`AVERAGE`/`IF`/`AND`/`OR` cover most of daily analyst work.
- **Takeaway:** check every number in a cell, because Excel will faithfully recalculate your mistakes.

## Lesson 2.2 — Lookups and data handling

### 1) Concept

**Lookups** find one piece of data from a key. `VLOOKUP(value, table, column, FALSE)` searches the *first column* of a table for a value and returns a cell further right in the same row — the `FALSE` forces an exact match. `XLOOKUP` (newer Excel) searches any column and is simpler to read. `INDEX` returns the cell at a row/column position; `MATCH` returns the *position* of a value. `INDEX` + `MATCH` together do everything `VLOOKUP` does and more (e.g., looking up to the *left*), which is why you should learn both idioms.

Data cleaning functions: `TRIM` removes stray spaces, `TEXT` formats numbers as text, and `LEFT`/`RIGHT`/`MID` cut parts of a string (useful for ISINs, ISIN codes, and bloated broker exports). Best practice that will save you all semester: **keep raw data and calculations on separate sheets** — a `data` sheet (imported, untouched) and a `model` sheet (formulas only).

### 2) Worked example

A two-column price table and a lookup:

```
A: RELIANCE  1800.00        =VLOOKUP("RELIANCE", A:B, 2, FALSE) -> 1800.00
   INFY     1850.50        =INDEX(B:B, MATCH("INFY", A:A, 0))  -> 1850.50
   TCS      4125.00
```

```python
from decimal import Decimal

prices = {"RELIANCE": Decimal("1800.00"), "INFY": Decimal("1850.50"),
          "TCS": Decimal("4125.00")}
print("RELIANCE:", prices["RELIANCE"], "| INFY via index/match idea:",
      list(prices.values())[list(prices.keys()).index("INFY")])
```

Output: `RELIANCE: 1800.00 | INFY via index/match idea: 1850.50`.

### 3) Common pitfalls

> **Pitfall:** `VLOOKUP` with `FALSE` omitted — Excel defaults to approximate match and silently returns the *wrong row*. Always type the fourth argument. **Pitfall:** `VLOOKUP` looking left — it cannot; reach for `INDEX`/`MATCH`. **Pitfall:** leading/trailing spaces making `"RELIANCE"` fail to match `"RELIANCE "` — run `TRIM` first.

### 4) Key takeaways

- **Takeaway:** `VLOOKUP(...,FALSE)` = exact lookup down the first column.
- **Takeaway:** `INDEX`/`MATCH` is the flexible lookup that works in any direction.
- **Takeaway:** `TRIM`/`LEFT`/`RIGHT`/`MID` clean the messy exports brokers give you.
- **Takeaway:** data sheet and model sheet never share a workbook page.

## Lesson 2.3 — Financial functions

### 1) Concept

Excel ships the TVM math you hand-computed in M1 as built-in functions:

| Function | Use |
|---|---|
| `PV(rate, nper, pmt)` | Present value |
| `FV(...)` | Future value |
| `NPV(rate, values...)` | Net present value of cash flows |
| `IRR(values...)` | Internal rate of return |
| `PMT(rate, nper, pv)` | Payment per period (EMI) |

Two rules from M1 apply verbatim: divide the annual rate by periods per year (`8.5%/12` for monthly EMI), and respect signs — Excel's functions return the opposite sign to the flow you are solving for (a loan you receive is `+PV`, the `PMT` comes back negative). `NPV` discounts a stream of cash flows at a discount rate; `IRR` is the discount rate that makes `NPV` zero. Under the **NPV rule** you accept a project when `NPV > 0` (it adds value) and reject when `NPV < 0`.

### 2) Worked example

A 5-year project costs ₹100 lakh today and returns ₹30, 40, 50, 60 lakh at the end of years 1–5. At a 12% discount rate:

```
NPV = -100 + 30/1.12 + 40/1.12^2 + 50/1.12^3 + 60/1.12^4
    = -100 + 26.79 + 31.89 + 35.59 + 38.13
    = 32.40  (lakh)   -> NPV > 0, accept
```

```python
from decimal import Decimal

cash = [Decimal("-100"), Decimal("30"), Decimal("40"),
        Decimal("50"), Decimal("60")]
r = Decimal("0.12")
npv = sum(cf / (Decimal(1) + r) ** (i + 1) for i, cf in enumerate(cash))
print("NPV (lakh):", npv.quantize(Decimal("0.01")),
      "-> accept" if npv > 0 else "-> reject")
```

Output: `NPV (lakh): 32.40 -> accept`. In Excel: `=NPV(12%, 30, 40, 50, 60) - 100` (NPV excludes the t=0 outflow, so subtract it after).

### 3) Common pitfalls

> **Pitfall:** forgetting to divide `rate` by periods per year. **Pitfall:** double-counting the initial outlay by including it inside `NPV` and also subtracting it. **Pitfall:** trusting `IRR` when cash flows change sign more than once — multiple IRRs exist; prefer `NPV` for the accept/reject call.

### 4) Key takeaways

- **Takeaway:** `PV`/`FV`/`PMT` are M1's TVM formulas with signs attached.
- **Takeaway:** `NPV > 0` means the project earns more than your discount rate.
- **Takeaway:** `IRR` is the break-even rate; it can be ambiguous, `NPV` is not.
- **Takeaway:** Excel sign conventions mirror cash flow direction: in (+) and out (−).

## Lesson 2.4 — Pivot tables and charts

### 1) Concept

A **pivot table** is a drag-and-drop summarizer: you feed it a big table (say, 250 rows of daily bar data) and tell it to group by one column and aggregate another (average close by month). It turns raw data into a summary grid without writing a single formula — exactly what you will use later to summarize screener outputs. A **chart** is a visual of a range: line charts for price series, column charts for comparisons, scatter charts for relationships (price vs volume).

For a price series, the **line chart** is the workhorse — put dates on the horizontal axis and closes on the vertical. Excel can add a **moving-average trendline** directly, which is your first technical-analysis artifact and the bridge to M8 and Semester 2. One honest warning: an unadjusted price chart lies when a stock splits or pays a big dividend (the price gap looks like a crash) — you will learn the fix in M6.

### 2) Worked example

Summarize 90 days of closes into 3 monthly averages:

```
Pivot: rows = month, values = AVERAGE(close)

Month   Average close
Oct-26   24105.55
Nov-26   24210.20
Dec-26   24450.90
```

```python
from decimal import Decimal

oct_closes = [Decimal("24100"), Decimal("24111")]   # 2-day illustration
nov_closes = [Decimal("24210"), Decimal("24210")]
dec_closes = [Decimal("24450"), Decimal("24451")]

def avg(xs):
    return sum(xs, Decimal(0)) / Decimal(len(xs))

for label, xs in [("Oct-26", oct_closes), ("Nov-26", nov_closes), ("Dec-26", dec_closes)]:
    print(label, avg(xs))
```

Output: `Oct-26 24105.50`, `Nov-26 24210.00`, `Dec-26 24450.50`.

### 3) Common pitfalls

> **Pitfall:** forgetting to refresh the pivot after changing the source data — Excel keeps the old summary silently. **Pitfall:** plotting a date column as a series (so the axis shows 1, 2, 3…) — mark the date column as the axis. **Pitfall:** charting a price series without adjusting for corporate actions (see M6).

### 4) Key takeaways

- **Takeaway:** pivot tables summarise thousands of rows in a few clicks.
- **Takeaway:** line charts for prices, columns for comparisons, scatter for relationships.
- **Takeaway:** moving-average trendlines are your first TA tool — they get formalised in M8/S2.
- **Takeaway:** always chart *adjusted* prices after corporate actions.

## Lesson 2.5 — Modeling hygiene

### 1) Concept

A **model** is a workbook someone else has to understand — your mentor, your future analyst team, or you in six months. **Modeling hygiene** is the set of habits that keeps it readable and auditable. First: **one input cell per assumption** — a single growth-rate cell that every formula references, never eleven copies of the number scattered around. Second: **colour conventions** — blue fill for inputs, black text for formulas — so a reviewer instantly sees what you may change. Third: **no hard-coded numbers inside formulas** — every constant lives in a labelled cell. Fourth: **cross-foot checks** — if rows and columns both total, the totals must agree; a cell that shows the difference is your self-audit. Fifth: **document every assumption** — a comment or an `assumptions` sheet saying where the 8% came from.

### 2) Worked example

A two-line income-statement model with one input cell:

```
Assumptions sheet:  growth = 8% (B1), margin = 12% (B2)
Model sheet:
  B5 = revenue last year  = 1000
  B6 = revenue this year  = =B5*(1+Assumptions!B1)  -> 1080
  B7 = operating profit   = =B6*Assumptions!B2      -> 129.60
  Cross-foot:  B6 - B5*(1+B1)  -> 0.00   (a cell that proves the model ties out)
```

```python
from decimal import Decimal

rev_last = Decimal("1000")
growth = Decimal("0.08"); margin = Decimal("0.12")
rev_now = rev_last * (Decimal(1) + growth)
profit = rev_now * margin
tie = rev_now - rev_last * (Decimal(1) + growth)
print("revenue:", rev_now, "| profit:", profit, "| cross-foot check:", tie)
```

Output: `revenue: 1080.00 | profit: 129.60 | cross-foot check: 0.00` — a self-checking model.

### 3) Common pitfalls

> **Pitfall:** green cells for inputs (Excel's default "good" colour) — use blue; green means "fine" and misleads. **Pitfall:** a formula full of raw numbers that cannot be traced. **Pitfall:** formatting a cell to *look* right instead of computing the tie — the visual lie catches auditors, not your model. **Pitfall:** assuming "it prints a number" equals "it is correct" — every model needs a check.

### 4) Key takeaways

- **Takeaway:** single-source-of-truth inputs; formula cells reference them.
- **Takeaway:** blue = input, black = formula — a universal audit convention.
- **Takeaway:** cross-foot checks turn arithmetic errors into visible red flags.
- **Takeaway:** modelling hygiene here becomes the S3-M8 full-model discipline.

## Tantra Lab 2 — Bars to CSV, then pivot in Excel

### Lab goal

Prove the data pipeline of this course: generate synthetic NIFTY 50 daily bars, export them to CSV, then summarise and chart them in Excel — the exact workflow you will reuse for every later module.

### Code

```python
# tantra-examples/examples/01_loading_data.py does exactly this
from decimal import Decimal
import csv, tempfile
from pathlib import Path
from tantra_examples import SampleInstruments, synthetic_bars

bars = synthetic_bars(SampleInstruments.NIFTY50, days=250, seed=42)
with tempfile.TemporaryDirectory() as tmp:
    p = Path(tmp) / "bars.csv"
    with p.open("w", newline="") as fh:
        w = csv.writer(fh)
        w.writerow(["ts", "open", "high", "low", "close", "volume"])
        for b in bars:
            w.writerow([b.ts.isoformat(), b.open, b.high, b.low, b.close, b.volume])
    print("wrote", p)
```

**Task:** open the CSV in Excel, compute a 20-day average of `close` with a
formula, plot the price series, and add a moving-average trendline. Submit the
workbook plus a one-page "NPV vs IRR decision" worksheet.

### Expected output

`wrote <tempdir>/bars.csv` with 250 rows of bar data (a temp path, so the exact path differs per machine). Each row has a timestamp and Decimal prices `open/high/low/close` plus `volume`.

### Hand-in checklist

- [ ] Workbook `lab2.xlsx` with a `data` sheet (raw CSV import) and a `model` sheet (20-day average formula using `$` on the period cell).
- [ ] Line chart of `close` with a 20-day moving-average trendline, correctly labelled axes.
- [ ] One-page "NPV vs IRR decision" worksheet using the M2 Lesson 2.3 numbers (project: −100, +30, +40, +50, +60; rate 12%), with the accept/reject conclusion stated.
- [ ] Pivot table: average close by month, on its own sheet.
- [ ] Journal entry explaining why `model` and `data` live on different sheets.

### Common errors

- **CSV column count mismatch** — writing fewer headers than values makes Excel misalign columns; keep the six columns exactly as in the snippet.
- **Decimal doesn't "look like" a number in Excel** — it arrives as text if your CSV cell is quoted; the snippet writes plain values, so keep `csv.writer` defaults.
- **Moving-average trendline covering the whole series** — a 20-day trendline needs at least 20 points *after* the window start; start the chart data at the right row.

## Practice problems

1. In one cell, write the formula (not the result) for "average of the five prices in B2:B6 multiplied by the assumption in `$C$1`".
2. The `VLOOKUP` idiom: write the formula that returns the price of `INFY` from a two-column table `A1:B4` where column A holds names. Which argument forces exact match?
3. A ₹30,00,000 home loan at 9% p.a. for 20 years: write the `PMT` function signature with the correct per-period rate, and state the sign of the result.
4. A project costs ₹200 lakh and returns ₹60 lakh per year for 5 years at a 10% discount rate. Is `NPV > 0`? (Compute by hand with `1.1^5 = 1.61051`.)
5. Explain why `=NPV(12%,30,40,50,60)-100` is the correct NPV of the Lesson 2.3 project.
6. Your boss asks for "the month with the highest average close". Which Excel feature answers this in under a minute?

### Solutions

1. `=AVERAGE(B2:B6)*$C$1`.
2. `=VLOOKUP("INFY", A1:B4, 2, FALSE)` — the fourth argument `FALSE` forces exact match.
3. `=PMT(9%/12, 20*12, 3000000)` → approximately −₹26,990 per month (negative because it is money out).
4. `NPV = -200 + 60 x [1 - 1.1^-5]/0.1 = -200 + 60 x 3.79079 = 27.45` lakh → `NPV > 0`, accept.
5. Excel's `NPV` discounts the first cash flow by one period, so it treats year-1 flows correctly but must not receive the time-0 outflow; subtracting 100 after the call puts the t=0 cost at the right time.
6. A pivot table: rows = month, values = AVERAGE of close, then sort the month column descending.

## Quiz bank

| Question | A | B | C | D | Answer |
|---|---|---|---|---|---|
| Which reference stays pinned when copied? | `A1` | `$A$1` | `A$1` | none | B |
| The Excel function for a loan's per-period payment is: | `PV` | `FV` | `PMT` | `NPV` | C |
| `VLOOKUP` returns an exact match only when: | the table is sorted | the 4th arg is `FALSE` | the key is numeric | always | B |
| `INDEX`/`MATCH` beats `VLOOKUP` when: | you need to look left | the table is tiny | you need SUM | never | A |
| The NPV rule says: | accept if `NPV < 0` | accept if `NPV > 0` | reject if `IRR > 0` | accept always | B |
| A good modelling convention is: | blue = input | green = input | red = formula | numbers in formulas | A |
| Excel's `NPV` function discounts the first cash flow by: | 0 periods | 1 period | 2 periods | rate itself | B |
| `TRIM` is used to: | delete rows | remove stray spaces | round prices | make charts | B |

## Glossary

- **Cell / range** — a single box in the grid / a rectangular block of cells.
- **Relative / absolute reference** — reference that shifts when copied (`A1`) vs pinned (`$A$1`).
- **Formula** — a calculation beginning with `=`, recomputed when inputs change.
- **VLOOKUP** — exact (`FALSE`) or approximate lookup down the first column of a table.
- **INDEX/MATCH** — position-based lookup; works in any direction.
- **NPV** — net present value: sum of discounted cash flows; accept when positive.
- **IRR** — the discount rate that makes NPV zero.
- **Pivot table** — drag-and-drop summariser that groups and aggregates a big table.
- **Moving-average trendline** — a chart overlay smoothing a price series.
- **Modelling hygiene** — conventions (one input per assumption, colour coding, cross-foots) that keep a model auditable.
- **Cross-foot check** — a cell proving that row totals and column totals agree.

## Reading assignment

From the [Reading & Resource List](../appendices/reading-list.md), start Benninga's *Financial Modeling* early chapters (spreadsheet conventions) and keep the NSE/BSE educational material handy for the data you will chart. The `tantra-examples/examples/01_loading_data.py` script listed under platform references is the pipeline you just reproduced.

## Assessment reminder

M2 is graded through the **practical worksheets** (ledger sheet, ratio sheet, mini-model) and the **modeling-hygiene rubric** — three submitted workbooks plus your journal entries, all continuous assessment. The NPV/IRR worksheet you build here reappears in the S1 mid-term. See [Assessment & Grading Scheme](../front/assessment.md) for the rubric and the pass gate.

**Next:** [M3 — How Capital Markets Work](m3-markets.md)
