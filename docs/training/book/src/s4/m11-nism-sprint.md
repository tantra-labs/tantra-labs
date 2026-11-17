# M11 — NISM XV Mock Sprint & Final Exams

> **Week 64 · 16 hrs · Exam prep for NISM Series XV (Research Analyst)**

## What you will do

- Sit **four timed NISM XV-style mocks**.
- Attend regulatory & ethics clinics (M10 is the highest-yield revision).
- Register for the NISM XV exam.
- Sit the **final programme exams** (theory + lab practical).

## Prerequisites

- Every module from [M1](m1-statistics.md) to [M10](m10-regulatory-ethics.md) of Semester 4 — this sprint assumes the content is *learned* and now needs to become *exam-fast*.
- [S3-M7 valuation](../s3/m7-valuation-intro.md) / [S3-M8 modelling](../s3/m8-financial-modelling.md): the valuation clinic reuses your model.
- A registered NISM Series XV exam slot (register in week 64, before Mock #2).

## NISM XV at a glance

| Item | Value |
|---|---|
| Format | CBT, multiple-choice |
| Coverage | The full RA syllabus: markets, fundamentals, valuation, technicals, derivatives, research, regulation |
| Pass bar | ~50–60% (NISM standard) |
| Source | NISM workbook + this semester's content |

### 1) Exam format

NISM Series XV (Research Analyst) is a **computer-based test (CBT) of multiple-choice questions** drawn from the full research-analyst syllabus. The exam is scored on questions that mix *recall* (definitions, regulator names, code duties) and *application* (compute a Sharpe, price a bond, classify moneyness, detect a conflict). The practical pattern from this course maps 1:1 onto the exam:

```
Recall questions    → M1, M10, S1, S3 glossary terms and code names.
Application math    → M2 beta, M4 Sharpe/Treynor/alpha, M6 parity/IV,
                      M7 hedge contracts, M8 bond price/duration.
Ethics scenarios    → M10 codes, PIT/tipping, conflicts, disclosures.
```

Because the exam is timed and computer-based, the skill being tested is *speed with accuracy* — which is exactly what the four mocks train.

### 2) Exam strategy

The three rules that move a mock score by ten points:

1. **Two-pass answering.** First pass: answer every question you know instantly, flag the rest, and never spend more than 60 seconds on a first pass. Second pass: return to flags with the clock's remaining time. This converts "I know 60%" into "I banked the 60% I know" instead of losing it to over-thinking one hard question.
2. **Formula sheet from memory.** Every core formula in this course fits on one page (see Lab 11). Rebuild it from a blank file *before* each mock; if you can reproduce it, you can apply it.
3. **Elimination.** MCQs reward elimination: mark the obviously-wrong options first (unit mismatches, sign errors, swapped definitions), then choose between the survivors. Two wrong answers are often easier to spot than the right one is to derive.

### 3) The pass target

The programme gate is **pass bar + 10%** — not "just passing". The reason: the NISM exam is a *licence* exam, and the margin is the buffer that makes passing on exam day likely rather than lucky. Mock #4 is the dress rehearsal: timed, seated, no notes, same conditions as the real CBT.

```python
# The gate math in Decimal: pass bar + 10% of the paper.
pass_bar_pct = Decimal("60")   # worst-case bar for planning
gate_pct = pass_bar_pct + Decimal("10")
print("mock gate target:", gate_pct, "%")   # 70%
```

## Week plan

- Mock #1: full syllabus, identify weak domains.
- Clinic: valuation & financial modeling (S3-M7/M8), ratios (S3-M4).
- Mock #2: timed; clinic on derivatives & options (S4-M5/M6).
- Clinic: regulation & ethics (S4-M10), research report (S4-M9).
- Mock #3: timed; clinic on statistics & portfolio (S4-M1–M4).
- Mock #4: timed under exam conditions — **target ≥ pass bar + 10%**.
- Final programme exams: 2-hr theory + 2-hr lab practical.

### 1) Mock-to-clinic loop

The week plan is a loop, not a to-do list. Each mock produces a **weak-domain list** — the questions you flagged or missed, sorted by module. The next clinic is *chosen by that list*: if Mock #1's misses cluster in options, the derivatives clinic does double duty. Keep a running score table:

```
Mock  Score  Weak domains            Next clinic
#1    52%    derivatives, ethics     S4-M5/M6 then S4-M10
#2    61%    ethics (still)          S4-M10 deep-dive
#3    67%    portfolio math          S4-M1-M4 drills
#4    72%    —                       final exam conditions
```

If a domain fails *twice*, treat it as a priority, not a preference: re-read the module, re-run its lab, and write the formulas from memory.

```python
# Score tracking as data: log each mock's score and target the gate.
scores = [Decimal("52"), Decimal("61"), Decimal("67"), Decimal("72")]
gate = Decimal("70")
print("gate met at mock #4:", scores[-1] >= gate)   # True
```

### 2) Clinic method

Clinics are *active*, not re-reads. For each weak domain: (1) rebuild the formula from memory; (2) re-run the module's Tantra Lab from memory (no peeking); (3) do the module's practice problems under a 20-minute cap; (4) explain the concept out loud in one minute (the Feynman test — if you cannot say it, you do not know it). The clinics that move scores are the ones where you *produce*, not the ones where you *consume*.

### 3) Final programme exams

The final programme exams are the semester's closing gate: a **2-hour theory exam** and a **2-hour lab practical**. The theory paper tests recall and application across S4 (formulas, definitions, scenario classification). The practical paper is Lab-11-flavoured: given a data scaffold, compute the statistics, the beta, the Sharpe, the hedge, and the bond price in Decimal — with the same no-float, verified-API rules this course has enforced all semester. The practical is open to the tools you already know, because that is the point: the exam *is* a Tantra Lab.

## Tantra Lab 11 — Full-stack formula review in code

### Lab goal

Build, from memory, one script that touches every semester's core math — the same production skill the final practical tests.

### Code

The verified scaffold is unchanged; the expansion fills in the four family blocks. **Build this from a blank file; that is the exam.**

```python
# One script that touches every semester's core math — build this from memory.
from decimal import Decimal

# S1/S3: CAGR, WACC
# S2: SMA, RSI
# S4: beta, Sharpe, BS price
# Run it, then re-build it from a blank file. That's your exam.
```

```python
# --- the exam-ready version (fill each family from memory, then check) -----
from decimal import Decimal
from tantra.quant import mean, std_dev, covariance_matrix, returns
from tantra.options import bs_price

# S1/S3: CAGR from 1-yr-ago price to today
p0, p1 = Decimal("100"), Decimal("135")
cagr = (p1 / p0) - Decimal(1)
print("CAGR:", cagr)                 # 0.35

# S2: SMA of the last 5 closes
closes = [Decimal("100"), Decimal("102"), Decimal("101"), Decimal("104"), Decimal("103")]
sma = sum(closes) / Decimal(len(closes))
print("SMA:", sma)                   # 102

# S4: beta, Sharpe, BS price
market = returns([Decimal("100"), Decimal("102"), Decimal("99"), Decimal("104")])
stock  = returns([Decimal("100"), Decimal("104"), Decimal("97"), Decimal("108")])
cov = covariance_matrix([[s, m] for s, m in zip(stock, market)])
beta = cov[0][1] / cov[1][1]
sharpe = (mean(stock) - Decimal("0.0001")) / std_dev(stock)
price = bs_price(spot=Decimal("24000"), strike=Decimal("24000"),
                 expiry=Decimal("30")/Decimal("365"), rate=Decimal("0.07"),
                 vol=Decimal("0.12"), kind="call", style="european")
print("beta:", beta, "sharpe:", sharpe, "call:", price)
```

### Expected output

The script prints: CAGR 0.35 (35% over one year), SMA 102, a positive beta near 1.3 (stock amplified the market moves), a small daily Sharpe, and the ATM call price ≈ 403. The *real* output to check is your memory: cover the answer block, rebuild the script, and diff the two.

### Hand-in checklist

- [ ] Formula families reproduced from memory for all four blocks.
- [ ] Diff against the reference version with zero unexplained differences.
- [ ] Four mocks logged with scores and weak-domain lists.
- [ ] NISM XV registration confirmed before Mock #2.
- [ ] Final theory + practical exams attempted under exam conditions.

### Common errors

- **Building from the reference, not from memory** — close the file. Peeking turns the drill into typing.
- **Float sneaking in** — any price/return/rate not `Decimal` fails the house rule on the practical.
- **BS expiry in days instead of years** — `Decimal("30")/Decimal("365")`, not `30`.
- **Answering the easy questions slowly** — the two-pass strategy is what banked time for the flagged ones.

## Practice problems

1. Write the four formula families (S1/S3 CAGR and WACC; S2 SMA/RSI; S4 beta/Sharpe; S4 BS inputs) from memory. Check against Lab 11.
2. A stock goes 100 → 135 over 12 months. Compute the CAGR. Over 24 months, what is the annualised CAGR?
3. Compute SMA(5) for 100, 102, 101, 104, 103. Which recent close pushes the SMA up or down?
4. Given market returns [2%, 1%, −1%], stock returns [4%, 2%, −2%], compute beta by the covariance recipe.
5. A fund returns 12%, Rf 5%, σ 18%. Compute Sharpe; state whether the mock gate is about this module or the NISM pass bar.
6. Classify the NISM XV pass strategy: why two-pass answering beats perfect-first-pass answering?
7. Which module is the "highest-yield revision" per the week plan, and why?
8. (Short code) Rebuild the Lab 11 reference script from memory, then diff.

### Solutions

1. Self-check against Lab 11: CAGR = (P1/P0)^(1/n) − 1; WACC = wE·rE + wD·rD·(1−t); SMA = Σ/period (RSI uses gains/losses over a window); beta = Cov/ Var(market); Sharpe = (Rp−Rf)/σp; BS inputs S0, K, T, r, σ.
2. CAGR = 135/100 − 1 = 35% for one year. For two years, annualised = √(135/100) − 1 ≈ 16.2%.
3. SMA = 510/5 = 102; a close above 102 lifts the next SMA, below drags it — the last close (103) is the current influence.
4. Cov(stock, mkt) = [(2·4)+(1·2)+(−1·−2)]/3 = 12/3 = 4; Var(mkt) = (4+1+1)/3 = 2; beta = 4/2 = 2.
5. Sharpe = (0.12 − 0.05)/0.18 ≈ 0.389. The mock gate (pass bar + 10%) governs *your mocks*; the NISM pass bar governs the *licence exam* — two different gates.
6. First pass banks every known answer while the clock is full, so the hard questions cannot consume the time that easy ones deserved; flags are then answered with the surplus.
7. S4-M10 (regulatory & ethics) — it is the highest-yield revision because scenario questions test it heavily and the material is compact and recall-friendly.
8. Diff check: any difference is a gap to clinic. If the diff shows a float, a wrong exponent, or a missing `style="european"`, fix and rebuild.

## Quiz bank

| Question | A | B | C | D | Answer |
|---|---|---|---|---|---|
| NISM XV is | a paper-and-pen essay | a CBT MCQ exam | a lab practical only | an interview | B |
| The programme mock gate is | NISM pass bar | pass bar + 10% | 100% | the class average | B |
| The two-pass strategy's first pass | answers known questions fast | works slowly | skips easy ones | reads the manual | A |
| Mock-to-clinic loops are driven by | weak-domain lists | calendar dates | mood | question order | A |
| The highest-yield revision module is | M1 | M10 | M5 | M8 | B |
| WACC weights come from | market values | book values always | guesswork | the CML | A |
| CAGR over two years uses | a square root | a cube root | no root | doubling | A |
| The final practical exam is | theory only | Lab-11 style in Decimal | multiple choice only | an interview | B |
| Every price in the practical must be | float | Decimal | integer | string | B |
| BS expiry must be | in years | in days | in months as int | in hours | A |
| The clinic method's last step is | re-reading | explaining aloud | highlighting | copying notes | B |
| Registration must happen | before Mock #2 | on exam day | after the mocks | never | A |

## Glossary

- **NISM XV** — the SEBI-mandated Research Analyst certification exam (CBT, MCQ).
- **Pass bar** — the passing score standard (~50–60%).
- **Mock gate** — the programme target of pass bar + 10% on Mock #4.
- **Two-pass strategy** — bank known answers first, return to flags second.
- **Weak-domain list** — the flagged/missed questions sorted by module.
- **Clinic** — an active revision session driven by weak domains.
- **Feynman test** — explain a concept out loud in one minute; if you cannot, you do not know it.
- **CBT** — computer-based test.
- **Final programme exams** — the 2-hour theory and 2-hour lab practical closing the semester.

## Reading assignment

Revise the NISM Series XV workbook alongside the [reading list](../appendices/reading-list.md); in the final week, re-read S4-M10 (regulatory & ethics) and re-run Labs 1, 4, 6, 8, and 11 as the highest-yield practical drills.

## Assessment reminder

The mock gate (Mock #4 ≥ pass bar + 10%) is the sprint's pass condition, and the final programme exams (theory + practical) determine the semester result; both are recorded in the [assessment plan](../front/assessment.md).

**End of Semester 4.** Next: [Semester 5](../s5/overview.md) — Track Specialization & Capstone.
