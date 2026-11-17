# M2 — Excel for Finance

> **Weeks 2–4 · 30 hrs (lab-heavy) · PLO-5, PLO-7 prerequisites**

## Learning outcomes

- Navigate Excel/LibreOffice fluently; know when *not* to use a calculator.
- Build worksheets with formulas, lookups, pivot tables, and charts.
- Use financial functions: `PV`, `FV`, `NPV`, `IRR`, `PMT`.
- Format models so they are readable and auditable (modeling hygiene that S3-M8 depends on).

## Lesson 2.1 — Spreadsheet literacy

- Cells, ranges, absolute vs relative references (`$A$1`).
- `SUM`, `AVERAGE`, `IF`, nested `IF`, `AND/OR`.
- Sorting, filtering, and tables.

## Lesson 2.2 — Lookups and data handling

- `VLOOKUP`/`XLOOKUP` and `INDEX`/`MATCH`.
- Cleaning text data (TRIM, TEXT, LEFT/RIGHT/MID).
- Best practice: keep data and calculations on separate sheets.

## Lesson 2.3 — Financial functions

| Function | Use |
|---|---|
| `PV(rate, nper, pmt)` | Present value |
| `FV(...)` | Future value |
| `NPV(rate, values...)` | Net present value of cash flows |
| `IRR(values...)` | Internal rate of return |
| `PMT(rate, nper, pv)` | Payment per period (EMI) |

Practice: a 5-year project with uneven cash flows — compute NPV and IRR, then
decide accept/reject under the NPV rule.

## Lesson 2.4 — Pivot tables and charts

- Pivot tables to summarize large datasets (later used for screening outputs).
- Line/column/scatter charts; charting price series.
- Adding moving-average trendlines to a price chart (bridging to M8/S2).

## Lesson 2.5 — Modeling hygiene

- One input cell per assumption (single-source-of-truth).
- Colour conventions: blue = input, black = formula.
- No hard-coded numbers inside formulas; document every assumption.
- Cross-foot checks (sum rows = sum columns).

## Tantra Lab 2 — Bars to CSV, then pivot in Excel

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

## Assessment

- Practical: 3 worksheets submitted (ledger sheet, ratio sheet, mini-model).
- Modeling-hygiene rubric: assumptions visible, formulas auditable.

**Next:** [M3 — How Capital Markets Work](m3-markets.md)
