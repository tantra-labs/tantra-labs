# M3 — Financial Statement Analysis

> **Weeks 37–39 · 24 hrs · PLO-5 · Core:** NIFM Ch 19, 34; PGP T1-103; IFMC items 3–5, 15–16

## Learning outcomes

- Read the income statement, balance sheet, and cash-flow statement at depth.
- Distinguish accrual earnings from cash reality.
- Spot accounting red flags: unusual receivables, related-party transactions,
  aggressive revenue recognition.
- Read quarterly results and annual reports like an analyst.
- Compute FCF and cash conversion in `Decimal` and interpret what they say
  about survival.

## Prerequisites

- [M1 — Economics for Securities Markets](m1-economics.md): the macro backdrop
  against which you read a company's growth.
- [M2 — Industry & Company Qualitative Analysis](m2-industry-company-qualitative.md):
  management claims from the MD&A that this module's statements must verify.
- [S1-M5 — Instruments](../s1/m5-instruments.md): what a share, a dividend, and
  a board are; the annual report's anatomy.
- [S2-M3 — Chart patterns](../s2/m3-chart-patterns.md) is not needed here, but
  the habit of *reading the data before interpreting it* transfers directly.

## Lesson 3.1 — Income statement deep dive

### 1) Concept

The income statement (P&L) answers: *how much did we earn in this period, and
how much is left after each layer of cost?* It runs on the **accrual basis**:
revenue is recognised when *earned and reasonably certain*, not when cash
arrives. That single idea — **revenue recognition** — is where most accounting
games live.

The layers:

```
Revenue
− COGS (cost of goods sold)          → Gross Profit
− Opex (selling, general, admin)     → EBITDA
− Depreciation & amortisation        → EBIT (operating profit)
− Interest                           → PBT
− Tax                               → PAT (net profit)
```

**COGS** is the direct cost of making the product; **opex** is everything else
running the business. **EBITDA** (earnings before interest, tax, depreciation,
amortisation) is the cash-operations view before capital charges; **EBIT** is
the operating profit an owner of the asset base cares about; **PAT** is what is
attributable to shareholders. Each step has a margin (Lesson 4.1) and each step
is where quality issues hide.

**Quality of earnings** is the analyst's filter: how much of PAT is *recurring*
versus one-time? Extraordinary gains (selling land, arbitration awards),
tax-effect reversals, and "other income" inflate PAT for one year. An analyst
normalises PAT — strips one-time items and re-computes margins — before valuing
the company. If a company's PAT doubles but only because of a one-time sale, the
*recurring* story is unchanged.

### 2) Worked example

Walk a mock P&L from revenue to PAT, all in `Decimal`:

```python
from decimal import Decimal
revenue = Decimal("10_000_000"); cogs = Decimal("6_000_000")
opex = Decimal("1_200_000"); d_and_a = Decimal("400_000")
interest = Decimal("150_000"); tax_rate = Decimal("0.25")
gross = revenue - cogs
ebitda = gross - opex
ebit = ebitda - d_and_a
pbt = ebit - interest
pat = pbt * (Decimal(1) - tax_rate)
print("Gross:", gross, "EBITDA:", ebitda, "EBIT:", ebit, "PBT:", pbt, "PAT:", pat)
```

Answer: Gross ₹4,000,000; EBITDA ₹2,800,000; EBIT ₹2,400,000; PBT ₹2,250,000;
PAT ₹1,687,500. Now suppose a one-time land sale adds ₹1,000,000 of "other
income" before PBT — normalised PAT is ~₹1,687,500, but reported PAT jumps. The
*reported* number is real cash; the *normalised* number is what the business can
repeat. Analysts value the normalised number.

### 3) Common pitfalls

> **Pitfall:** Quoting EBITDA as if it were cash — EBITDA ignores working
> capital and capex, which can be huge (Lesson 3.3). Treating one-time gains as
> recurring. Forgetting that *revenue recognition* rules changed: aggressive
> "bill and hold" or channel stuffing (loading distributors at quarter-end)
> inflates revenue today and reverses tomorrow.

### 4) Key takeaways

- **Takeaway:** Accrual accounting books revenue when earned, not when cash
  arrives — that gap is where quality analysis lives.
- **Takeaway:** Walk EBITDA → EBIT → PBT → PAT and know what each layer pays
  for.
- **Takeaway:** Normalise PAT: strip one-time items before valuing.

## Lesson 3.2 — Balance sheet deep dive

### 1) Concept

The balance sheet is a photograph at a date:

```
Assets = Liabilities + Equity
```

**Working capital** is the short-term engine: **receivables** (money customers
owe), **inventory** (goods waiting to sell), **payables** (money you owe
suppliers). The **cash conversion cycle** measures how long cash is locked up:

```
CCC = Days inventory + Days receivables − Days payables
```

Shorter is better: a company that collects fast and pays slowly funds its own
growth (FMCG and CPG brands often run *negative* cash conversion cycles).
**Debt structure** matters: short-term debt (due within a year) refinances risk
vs long-term bonds; **debt covenants** (the promises in loan agreements — e.g.,
a maximum Debt/EBITDA) can force distress if breached; **off-balance-sheet
items** (operating leases, guarantees, contingent liabilities) hide true
obligations — Indian companies now report leases on the balance sheet under
Ind-AS 116, but guarantees and contingencies still live in the notes.

**Equity quality**: share capital (par value of issued shares) vs **reserves**
(accumulated retained profits) — together **net worth** = assets − liabilities.
Treasury shares reduce equity; **minority interest** (shareholders of partly
owned subsidiaries) sits *between* liabilities and equity and must be excluded
from "equity attributable to parent" when you compute ROE in Lesson 4.2. Equity
is not a pile of cash — it is the *accounting claim* left over; that confusion
is how beginners misread "net worth".

### 2) Worked example

Compute the cash conversion cycle and verify the balance-sheet identity:

```python
from decimal import Decimal
revenue = Decimal("3_650_000"); cogs = Decimal("2_190_000")
inventory = Decimal("180_000"); receivables = Decimal("300_000"); payables = Decimal("120_000")
days_inv = inventory / (cogs / Decimal("365"))
days_rec = receivables / (revenue / Decimal("365"))
days_pay = payables / (cogs / Decimal("365"))
ccc = days_inv + days_rec - days_pay
print("Inventory days:", days_inv.quantize(Decimal("0.1")),
      "| Receivable days:", days_rec.quantize(Decimal("0.1")),
      "| Payable days:", days_pay.quantize(Decimal("0.1")),
      "| CCC:", ccc.quantize(Decimal("0.1")))
```

Answer: inventory ~30.0 days, receivables ~30.0 days, payables ~20.0 days,
CCC ≈ 40 days. The business holds ~40 days of its sales cycle in tied-up cash.
A rival with CCC of 10 days needs far less financing for the same growth — the
efficiency edge shows up in the ratios of Lesson 4.1.

### 3) Common pitfalls

> **Pitfall:** Reading "equity = net worth = cash" — net worth is an accounting
> residual, not a bank balance. Mixing payable days using revenue when payables
> relate to purchases/COGS. Ignoring off-balance-sheet guarantees that will
> strike when a subsidiary or related party defaults.

### 4) Key takeaways

- **Takeaway:** Working capital and the cash conversion cycle measure how much
  cash growth needs.
- **Takeaway:** Debt has structure: maturity, covenants, and off-balance-sheet
  siblings.
- **Takeaway:** Equity is the residual claim; net worth ≠ cash on hand.

## Lesson 3.3 — Cash-flow statement deep dive

### 1) Concept

The cash-flow statement re-runs the P&L and balance sheet in *cash*:

- **Operating (OCF):** cash actually collected from running the business —
  PAT, then add back non-cash charges (depreciation), then adjust for working
  capital (rising receivables *consume* cash; rising payables *release* it).
- **Investing (ICF):** cash spent/collected on long-term assets — capex,
  acquisitions, sale of plant. Usually negative.
- **Financing (FCF sheet):** equity issuance, dividends, borrowings and
  repayments.

**Free cash flow** is the cash available *after* keeping the business alive:

```
FCF = Operating Cash Flow − Capital Expenditure
```

**Cash conversion** asks how much of profit is real:

```
Cash conversion = OCF / PAT
```

Above 1.0: the company collects more cash than it books as profit (good — often
seen in FMCG, or when depreciation is heavy). Below 1.0: earnings outrun cash —
watch for ballooning receivables. The hard lesson: **a company can be
profitable and still die of cash starvation** — it books profit on paper while
customers fail to pay and lenders refuse to roll over debt. The P&L shows the
story; the cash-flow statement shows whether the story is funded.

### 2) Worked example

Reconcile a profitable-but-tight company in cash terms:

```python
from decimal import Decimal
pat = Decimal("100_000"); depreciation = Decimal("20_000")
d_receivables = Decimal("45_000")   # customers paid late
d_inventory = Decimal("15_000")
d_payables = Decimal("10_000")
capex = Decimal("60_000")
ocf = pat + depreciation - d_receivables - d_inventory + d_payables
fcf = ocf - capex
print("OCF:", ocf, "| FCF:", fcf, "| Cash conversion:", (ocf / pat).quantize(Decimal("0.01")))
```

Answer: OCF = 100,000 + 20,000 − 45,000 − 15,000 + 10,000 = ₹70,000. FCF =
70,000 − 60,000 = ₹10,000. Cash conversion = 0.70 — for every ₹1 of profit only
₹0.70 arrived in cash. The business is profitable but each year of growth is
consuming cash into receivables and inventory; scale that gap over several years
and even a "profitable" company faces a cash crunch.

### 3) Common pitfalls

> **Pitfall:** Adding *all* changes in working capital with the same sign —
> receivables and inventory *use* cash (subtract), payables *provide* cash
> (add). Quoting "OCF grew" without checking *why* (quality: growth from
> collections vs growth from payables is very different). Forgetting capex when
> judging "cash generation" — FCF is the honest number.

### 4) Key takeaways

- **Takeaway:** `FCF = OCF − Capex`; `Cash conversion = OCF / PAT`.
- **Takeaway:** Working-capital sign conventions: receivables/inventory consume
  cash, payables release it.
- **Takeaway:** Profit is an opinion; cash is a fact — cash starvation kills
  profitable companies.

## Lesson 3.4 — Red-flag checklist

### 1) Concept

Analysts keep a checklist of signs that reported numbers are drifting from
reality. The core items:

1. **Receivables growing faster than revenue** — the company is selling but not
   collecting; could be channel-stuffing or credit losses hiding.
2. **Related-party sales/loans** — revenue to promoters' other companies at
   prices no outsider can verify; loans to related parties can vanish.
3. **Pledged promoter shares** — promoters borrowing against their holdings;
   a fall in the stock can trigger forced sales and governance instability.
4. **Frequent auditor qualifications or restatements** — the auditor's
   qualified opinion is the loudest alarm bell in the report.
5. **Rising inventory with flat sales** — production not turning into demand;
   either demand fell or products are obsolete.

These are *tripwires, not verdicts*: each one triggers deeper investigation, not
automatic avoidance. A fast-growing company can legitimately show receivables
growing faster than revenue for one quarter. The checklist is how an analyst
stays honest against management's story (Lesson 2.4). Cross-check each flag
against the *direction and duration*: one quarter vs four, related-party size
as a % of revenue, pledging % of promoter holding.

### 2) Worked example

Measure the first flag mechanically — receivables growth vs revenue growth:

```python
from decimal import Decimal
rev_0, rev_1 = Decimal("1_000_000"), Decimal("1_100_000")
rec_0, rec_1 = Decimal("120_000"), Decimal("170_000")
rev_growth = (rev_1 - rev_0) / rev_0
rec_growth = (rec_1 - rec_0) / rec_0
print("Revenue growth:", (rev_growth * 100).quantize(Decimal("0.01")), "%")
print("Receivables growth:", (rec_growth * 100).quantize(Decimal("0.01")), "%")
```

Answer: revenue +10%, receivables +41.7% — receivables growing 4× faster than
revenue. Flag raised. The follow-up questions: are the new customers credit-
worthy? Is the company relaxing terms to hit a revenue target? The ratio work
of Lesson 4.1 (debtor days rising every quarter) confirms or clears the flag.

### 3) Common pitfalls

> **Pitfall:** Treating any single flag as a verdict — investigate, don't
> condemn. Ignoring pledged-promoter disclosure (it lives in the annual
> report's corporate-governance section). Not annualising the comparison —
> comparing a quarter's receivables jump to a *year* of revenue growth
> misleads.

### 4) Key takeaways

- **Takeaway:** Five flags: receivables-vs-revenue, related parties, pledging,
  auditor qualifications, inventory-vs-sales.
- **Takeaway:** Flags trigger investigation; direction and duration decide.
- **Takeaway:** Growth can legitimately stretch working capital — context
  first.

## Lesson 3.5 — Quarterly & annual dissection

### 1) Concept

Quarterly results come with a **seasonal trap**: Indian companies face festival,
monsoon, and year-end effects, so the *right* comparison is **YoY** (same
quarter last year), with **QoQ** only meaningful after seasonality is removed.
The analyst's quarterly read: revenue and margin *trend* (not one quarter),
segment-level detail (which division grew?), and **management commentary** — the
audio track to the numbers.

The **annual report** is the master document: full statements, **notes** (the
accounting policies, related-party disclosure, contingencies, segment data —
"the notes are where the truth hides"), and the MD&A/Governance sections from
Lesson 2.4. The analyst reads the annual report *backwards*: notes and risk
disclosures first, then the cash-flow statement, then the P&L and balance sheet
with the notes in hand. A five-year table of the same metrics (the "5-year
financial highlights") converts one year's photograph into a trend.

### 2) Worked example

Compare YoY vs QoQ when seasonality is real — Q1 is a slow quarter, Q4 is a
strong one:

```python
from decimal import Decimal
q4_last = Decimal("1_000_000"); q1_this = Decimal("850_000"); q4_this = Decimal("1_080_000")
qoq = (q1_this - q4_last) / q4_last          # looks terrible
yoy_q1 = (q1_this - q4_last) / q4_last * 0   # placeholder — real YoY uses Q1 last year
q1_last = Decimal("800_000")
yoy = (q1_this - q1_last) / q1_last
print("QoQ (vs prior quarter):", (qoq * 100).quantize(Decimal("0.01")), "%")
print("YoY (vs same quarter last year):", (yoy * 100).quantize(Decimal("0.01")), "%")
```

Answer: QoQ is −15% (scary) but YoY is +6.25% (healthy). The same number reads
as disaster or progress depending on the base — exactly why the quarterly
discipline is *always* YoY first.

### 3) Common pitfalls

> **Pitfall:** Judging a company on one quarter's QoQ move without seasonal
> context. Reading the annual report front-to-back (start with the notes).
> Trusting the auditor's unqualified opinion without reading the *emphasis of
> matter* paragraphs, which flag exactly the risks to investigate.

### 4) Key takeaways

- **Takeaway:** Quarterly: YoY is the anchor; QoQ only after seasonality.
- **Takeaway:** Annual: read backwards — notes, cash flow, then the rest.
- **Takeaway:** The notes contain the truth: accounting policies, related
  parties, contingencies.

## Tantra Lab 3 — Cash conversion in Decimal

### Lab goal

Prove the cash-quality core of this module: FCF and cash conversion are a few
`Decimal` arithmetic steps, and their interpretation (profit ≠ cash) is the
first thing you compute from any company's statements.

### Code

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

### Expected output

```
FCF: 100000  cash conversion (OCF/PAT): 1.4
```

FCF = 140,000 − 40,000 = **₹100,000**. Cash conversion = 140,000 / 100,000 =
**1.4** — the company collects ₹1.40 of cash per ₹1 of profit: high-quality,
self-funding earnings. Contrast with the Lesson 3.3 worked example where a
different receivable policy produced 0.70 and a cash squeeze.

### Hand-in checklist

- [ ] Script output pasted (FCF and cash conversion as `Decimal`).
- [ ] Full worksheet for the chosen company: revenue, EBIT, PAT, total assets,
      OCF, FCF — all in `Decimal`.
- [ ] Profitability answer (margins), solvency answer (debt vs equity/EBITDA),
      cash-quality answer (conversion and its drivers).
- [ ] Red-flag checklist applied: each of the five Lesson 3.4 flags answered
      with data.

### Common errors

- **Error:** using the class attributes as `float` — the `Decimal` values are
  the point; convert nothing.
- **Error:** reading cash conversion without its parts: an OCF that grew only
  because payables ballooned is *not* good conversion.
- **Error:** pulling "FCF" off a website without checking its definition
  (some sites compute FCF = EBIT(1−t) + D&A − Capex − ΔWC, others OCF − Capex);
  state your definition in the worksheet.

## Practice problems

1. Revenue ₹5,000,000; COGS 55% of revenue; opex ₹800,000; D&A ₹250,000;
   interest ₹90,000; tax 25%. Compute gross, EBITDA, EBIT, PBT, PAT.
2. Receivables ₹240,000, revenue ₹3,650,000. Compute receivable days. If the
   company's customers take 40 days to pay, is collection good or bad?
3. Inventory ₹150,000, COGS ₹2,190,000, payables ₹90,000 (vs COGS). Compute
   inventory and payable days; combine with 30 receivable days into the CCC.
4. PAT ₹120,000, D&A ₹30,000, receivables rose ₹50,000, payables rose ₹15,000,
   inventory rose ₹10,000, capex ₹70,000. Compute OCF, FCF, cash conversion.
5. Explain the difference between EBITDA and operating cash flow in two
   sentences, with one example of each non-cash adjustment.
6. A company's receivables grew 35% while revenue grew 9% for four consecutive
   quarters. What red flag is raised and what three follow-up questions do you
   ask?
7. A seasonal company reports QoQ −20% but YoY +8% in the December quarter.
   Which number is more meaningful, and why?
8. "Net worth on the balance sheet is the same as cash in the bank." Agree or
   disagree in three sentences, using the identity Assets = Liabilities +
   Equity.

### Solutions

1. Gross = 5,000,000 × 0.45 = 2,250,000; EBITDA = 2,250,000 − 800,000 =
   1,450,000; EBIT = 1,450,000 − 250,000 = 1,200,000; PBT = 1,200,000 − 90,000 =
   1,110,000; PAT = 1,110,000 × 0.75 = 832,500.
2. Receivable days = 240,000 / (3,650,000/365) = 240,000 / 10,000 = 24 days.
   Better than 40 days — collections are strong.
3. Inventory days = 150,000 / (2,190,000/365) = 25 days; payable days =
   90,000/6,000 = 15 days; CCC = 25 + 30 − 15 = 40 days.
4. OCF = 120,000 + 30,000 − 50,000 + 15,000 − 10,000 = 105,000; FCF = 105,000 −
   70,000 = 35,000; conversion = 105,000/120,000 = 0.875.
5. EBITDA is the P&L's operating profit before interest/tax/depreciation;
   operating cash flow is actual cash collected after working-capital changes.
   Example: a rise in receivables reduces OCF but not EBITDA; depreciation is
   added back to OCF.
6. Flag: receivables growing far faster than revenue. Ask: are new customers
   creditworthy? Are credit terms being relaxed to push revenue? How much of
   receivables is overdue / likely to become a bad debt?
7. YoY +8% is more meaningful — the QoQ fall is seasonal (a strong December is
   followed by a slow one); YoY strips the season.
8. Disagree. Equity is a residual claim (Assets − Liabilities), not cash: a
   company can have high net worth tied up in receivables, inventory, and plant
   with little cash. Cash is one asset among many.

## Quiz bank

| Question | A | B | C | D | Answer |
|---|---|---|---|---|---|
| The income statement runs on… | Cash basis | Accrual basis | Invoice basis | Receipt basis | B |
| EBITDA stands for… | Earnings before interest, taxes, depreciation & amortisation | Earnings before international tax | Earnings by industry total | Equalised book income | A |
| The layer between EBITDA and EBIT is… | Interest | Tax | Depreciation & amortisation | Dividends | C |
| Which working-capital change *consumes* cash? | Rising payables | Falling inventory | Rising receivables | Falling receivables | D |
| Cash conversion = OCF/PAT at 1.4 means… | Profit exceeds cash | Cash exceeds profit | Breakeven | Loss | B |
| CCC = inventory days + receivable days − … | Tax days | Payable days | Interest days | Depreciation days | B |
| "A company can be profitable and die of cash starvation" is true because… | Profit is accrual, cash is reality | PAT is always wrong | Dividends kill firms | Debt is evil | A |
| Which is a governance red flag? | Rising revenue | Pledged promoter shares | New products | Dividend growth | B |
| Quarterly results are best compared… | QoQ only | YoY | Against the Nifty | Monthly | B |
| FCF equals… | PAT − dividends | OCF − capex | EBIT × tax | Revenue − costs | B |

## Glossary

- **Accrual basis** — recognising revenue when earned, not when cash arrives.
- **COGS (cost of goods sold)** — direct cost of producing the product sold.
- **EBITDA** — earnings before interest, tax, depreciation, amortisation.
- **EBIT** — operating profit after depreciation and amortisation.
- **PAT (profit after tax)** — net profit attributable to shareholders.
- **Quality of earnings** — how much of PAT is recurring vs one-time.
- **Working capital** — receivables + inventory − payables.
- **Cash conversion cycle (CCC)** — inventory days + receivable days − payable
  days; cash tied up in the operating loop.
- **OCF (operating cash flow)** — cash generated by running the business.
- **ICF (investing cash flow)** — cash used/bought in long-term assets.
- **FCF (free cash flow)** — OCF − capex; cash available after reinvestment.
- **Cash conversion ratio** — OCF/PAT; how much of profit is real cash.
- **Debt covenants** — promises in loan agreements that, if breached, trigger
  distress.
- **Minority interest** — the equity claim of outside shareholders in partly
  owned subsidiaries.
- **Auditor qualification** — an auditor's warning that the statements depart
  from a true and fair view.

## Reading assignment

Read the statement-analysis chapters in [the reading list](../appendices/reading-list.md):
NIFM Ch 19, 34 (financial statements, cash flows), PGP T1-103, and IFMC items
3–5 and 15–16. Keep one real annual report (e.g., any Nifty 50 company) beside
you and re-derive every formula in this module from its actual numbers — that
hand-practice is what makes the red-flag checklist stick.

## Assessment

- Full-company statement dissection project (report + model skeleton).
- Quiz: statement mechanics and red flags.

## Assessment reminder

The statement-dissection project is a **graded lab deliverable** and the 
numeric skeleton you build here (revenue → PAT, FCF, working-capital moves)
becomes the *input* to the M8 capstone — a programme gate. Quiz items on
statement mechanics and red flags also appear in the end-term exam. See
[Assessment](../front/assessment.md) for how journal and exam components map to
your final grade.

**Next:** [M4 — Ratio Analysis & DuPont](m4-ratios-dupont.md)
