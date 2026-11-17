# M9 — Research Report Writing & Analyst Presentations

> **Weeks 61–62 · 20 hrs · PLO-10 · Core:** NIFM Ch 25, 26, 30, 38; IFMC items 24, 48, 65–67

## Learning outcomes

- Structure a professional research report: thesis, business, industry,
  financials, valuation, risks, rating, target price.
- Write objectively with evidence and data accuracy.
- Deliver a 15-minute analyst presentation.
- Keep "points to remember while preparing research" (NIFM Ch 25) as a checklist.

## Prerequisites

- [S3-M7 valuation](../s3/m7-valuation-intro.md) and [S3-M8 modelling](../s3/m8-financial-modelling.md): the financials and valuation sections of the report are *reused* deliverables.
- [S4-M7](m7-hedging-risk.md): the one-page risk plan becomes the Risks section.
- [S4-M4](m4-performance-measurement.md): performance language for mutual-fund/strategy comparisons if the report covers funds.
- [S2-M6](../s2/m6-overfitting-walkforward.md): the honesty rule — evidence that cannot survive out-of-sample has no place in a report.

## Lesson 9.1 — Fundamentals of research

### 1) Concept

Research is a **process**, not an opinion. The NIFM-research process runs: **question → data → analysis → conclusion → disclosure**. You start with a question ("is RELIANCE's retail-FMCG expansion worth the capital?"), collect the data (filings, transcripts, prices), analyse it with the tools from S3/S4, reach a conclusion (rating + target), and *disclose* what you assumed and what could break it.

Two habits separate professional research from blogging. **Objectivity**: write both sides of the case *before* you pick one — the bear case written first (the S4-M7 lesson applied to the whole report). **Data accuracy**: every number cited must be re-checkable — the reader must be able to open the same source and reproduce it. A report's credibility is the product of its footnotes; one unverifiable number poisons all of them. The Tantra stack makes the second habit mechanical: a lab script can reproduce any chart or number in the report (Lab 9), so "the data says X" is a *run-able claim*.

### 2) Worked example

A claim checklist for one sentence of a report. Claim: "RELIANCE's consumer segment grew 18% YoY."

```
1. Source identified (filing/press release, date, page/section).
2. Calculation reproducible: (Q2_2026 rev − Q2_2025 rev)/Q2_2025 rev in Decimal.
3. Definition stated (segmental revenue, excluding other income?).
4. Both sides checked (what would the number look like with a different definition?).
```

A number that fails any of the four is not a claim yet — it is a draft.

```python
from decimal import Decimal
q2_26 = Decimal("33000")   # segmental revenue, ₹ crore
q2_25 = Decimal("27966")
growth = (q2_26 - q2_25) / q2_25
print("YoY growth:", growth)   # ≈ 0.18 (18%) — and now the definition matters
```

### 3) Common pitfalls

> **Pitfall:** Writing the conclusion first and selecting data that supports it — confirmation bias is the report's most expensive error.
>
> **Pitfall:** Citing numbers without a source the reader can open.
>
> **Pitfall:** Saying "about 18%" when the calculation is checkable — state the exact figure and the arithmetic.
>
> **Pitfall:** Skipping disclosure of assumptions (discount rate, growth, exit multiple).

### 4) Key takeaways

- **Takeaway:** Research = question → data → analysis → conclusion → disclosure.
- **Takeaway:** Objectivity means writing the bear case before conviction.
- **Takeaway:** Every number must be re-checkable to its source.
- **Takeaway:** Scripts make data claims run-able — use them.

## Lesson 9.2 — The report anatomy

### 1) Concept

A professional research report is a fixed skeleton — the reader knows exactly where to find each answer:

| Section | Contents |
|---|---|
| Investment thesis | 2–3 bullet "why" |
| Company & business | What it does, segments |
| Industry | Forces, cycle position (S3-M2) |
| Financials | Historicals + model (S3-M8) |
| Valuation | Methods + target + range (S3-M7) |
| Risks | What breaks the thesis (S4-M7) |
| Rating & target | Buy/Hold/Sell with horizon |

The **investment thesis** is the top of the funnel: 2–3 bullets that state the *why* so plainly that a stranger could repeat them. **Company & business** describes what the firm does, its segments, and where the money comes from. **Industry** locates the company in its competitive forces and cycle position (the S3-M2 framework). **Financials** shows history *and* the forward model — every forecast row tied to an assumption. **Valuation** presents methods (DCF/DDM/relative — S3-M7), a target price, *and a range*, with the key sensitivity (what the target becomes if the growth assumption drops by 2 points). **Risks** is the S4-M7 risk plan in report form: what breaks the thesis and the pre-committed reaction. **Rating & target** is the single bottom line: Buy/Hold/Sell with a horizon and the target price.

The anatomy exists so that the reader can *disagree efficiently*: attack the thesis, the model, or the valuation — never the whole report at once.

### 2) Worked example

A one-line skeleton for an INFY report:

```
Thesis:    Currency tail + digital deal pipeline → EPS growth re-acceleration
Business:  IT services; banking & retail verticals ≈ 50% of revenue
Industry:  IT services cycle mid-cycle; deal TCV (total contract value) leading
Financials: FY25–FY27 model; revenue +9%, margin ~21% (see model workbook)
Valuation: DCF + PE-band cross-check → target ₹1,650; range 1,520–1,780
Risks:     USD/INR reversal, client budget cuts, margin pressure from attrition
Rating:    BUY, 12-month horizon
```

Each of the seven lines is a section that already exists as a deliverable from S3/S4.

```python
# Anatomy as data: every report number should map to a script cell or workbook row.
from tantra_examples import SampleInstruments, synthetic_bars
bars = synthetic_bars(SampleInstruments.INFY, days=250, seed=7)
print("data anchor: last close", bars[-1].close)
```

### 3) Common pitfalls

> **Pitfall:** Reordering the anatomy to fit a narrative — the standard order is the reader's contract.
>
> **Pitfall:** A thesis that is a paragraph — 2–3 bullets, each one testable.
>
> **Pitfall:** A valuation with one method and no range — a target without a sensitivity is a guess with a number.
>
> **Pitfall:** Risks that say "the stock may fall" — a risk is a *trigger* plus a *consequence* plus a *plan*.

### 4) Key takeaways

- **Takeaway:** Seven sections in a fixed order: thesis → business → industry → financials → valuation → risks → rating.
- **Takeaway:** The thesis is 2–3 testable bullets.
- **Takeaway:** Valuation = method + target + range + sensitivity.
- **Takeaway:** The anatomy lets readers disagree efficiently.

## Lesson 9.3 — Qualities of a good report

### 1) Concept

Five qualities grade every report: **structure** (the anatomy, obeyed), **clarity** (plain sentences; a Class-12 passout must be able to read it), **evidence** (every claim sourced and script-verifiable), **balanced risks** (both sides presented, not just the winner), and **honest assumptions** (discount rates, growth rates, exit multiples stated *with* their sources). 

The test that binds them: **the reader must be able to disagree with you using your own numbers.** If your DCF says ₹1,650 but a reader lowering growth from 9% to 7% can recompute the report's own model to ₹1,380, then the report is *arguable in its own terms* — that is professional writing. If the reader cannot recompute anything, the report is a sales pitch. This is also why the data-accuracy habit (Lesson 9.1) is a quality: a report whose every number is re-checkable is a report whose every *argument* is addressable.

### 2) Worked example

Two ways to state one fact:

```
Weak:  "The company is growing fast and the stock is cheap."
Strong: "Revenue grew 18% YoY (₹27,966 cr → ₹33,000 cr, Q2 filing p.12).
         At ₹1,650 target vs ₹1,380 intrinsic at 7% growth (model row 42),
         the upside rests entirely on the 9% growth assumption."
```

The strong version gives the reader the number, the source, the model row, and the exact assumption that decides the argument.

```python
# Reproducibility: the strong claim's arithmetic in Decimal
q2_26, q2_25 = Decimal("33000"), Decimal("27966")
growth = (q2_26 - q2_25) / q2_25
print("growth:", growth)    # ≈ 0.18
```

### 3) Common pitfalls

> **Pitfall:** Vague adjectives instead of numbers ("fast", "cheap") — every adjective should have a checkable quantity behind it.
>
> **Pitfall:** Overclaiming precision — "target ₹1,650.00" when the model is ±15% is theatre; give the range.
>
> **Pitfall:** Long paragraphs — one idea per short paragraph; tables for comparisons.
>
> **Pitfall:** Hiding the key assumption deep in an appendix — the decisive assumption belongs in the thesis.

### 4) Key takeaways

- **Takeaway:** Five qualities: structure, clarity, evidence, balanced risks, honest assumptions.
- **Takeaway:** The reader must be able to disagree using your own numbers.
- **Takeaway:** Every adjective should carry a checkable number.
- **Takeaway:** State the decisive assumption where the reader is looking.

## Lesson 9.4 — Analyst presentations

### 1) Concept

The 15-minute **analyst presentation** is the report, spoken. The structure mirrors the anatomy: **thesis → evidence → valuation → risks → Q&A**. The 3-slide discipline from S1-M9 scales up: slide 1 is the thesis and rating (30 seconds of talk), slide 2 the evidence and model (the bulk), slide 3 the valuation range and risks (the close), with room for a data slide if needed. The presentation is *not* the report read aloud — it is the argument, compressed to the numbers that decide it.

**Q&A** is where presentations are won or lost. The rules: restate the question to buy a second of thought; answer the *question*, not the prepared speech; if asked about an assumption, name it and its source; if asked about noise ("why did the stock fall 2% yesterday?"), say it is noise and explain what *would* move the thesis. Never bluff a number you cannot recompute — "let me get back to you on that, and here is the model cell" beats a wrong figure, because the report is reproducible.

### 2) Worked example

A 15-minute script for an INFY report:

```
0:00–0:30  Thesis + rating on one slide.
0:30–4:00  Evidence: deal TCV, currency tail, margin trend (charts from the lab).
4:00–8:00  Model: revenue/EPS path, key assumptions (rows 12–42 of the workbook).
8:00–10:00 Valuation: DCF + cross-check, target, range, sensitivity table.
10:00–12:00 Risks: USD/INR reversal, budget cuts, attrition; pre-committed reactions.
12:00–15:00 Q&A.
```

Total: one argument, seven sections, and the same number your report's reader could recompute.

```python
# The 15-minute clock as a data structure — practise against it.
schedule = [
    ("thesis+rating", 30), ("evidence", 210), ("model", 240),
    ("valuation", 120), ("risks", 120), ("Q&A", 180),
]
print("total seconds:", sum(sec for _, sec in schedule))   # 900
```

### 3) Common pitfalls

> **Pitfall:** Reading the report aloud — the deck is the argument, not the document.
>
> **Pitfall:** Filling slides with the full model — one chart per point; the workbook lives in the appendix.
>
> **Pitfall:** Dreading hostile questions into silence — a hostile question is an assumption hunt; state the assumption and its source.
>
> **Pitfall:** Bluffing a number under pressure — a reproducible report never needs to.

### 4) Key takeaways

- **Takeaway:** Thesis → evidence → valuation → risks → Q&A, in 15 minutes.
- **Takeaway:** The deck is the argument; the workbook is the appendix.
- **Takeaway:** Restate the question, answer the question, don't defend noise.
- **Takeaway:** Never bluff a number a reproducible report could supply.

## Lesson 9.5 — Stock selection for consistent returns (NIFM Ch 26)

### 1) Concept

NIFM's Chapter 26 asks the honest question: why do most stock pickers not compound? The answer the chapter (and this course) gives: **consistent returns come from a process, not a prediction**. The winning process combines three gears you have already built:

1. **Fundamental screen (S3)** — the business and valuation filter: quality of earnings, ROE/ROCE, balance-sheet strength, margin of safety at the price.
2. **Technical timing (S2)** — entry and exit around the fundamental view: trend structure, support/resistance, and indicator confirmation so you buy *with* the tape, not against it.
3. **Risk control (S4-M7)** — position sizing, stops, and hedges that keep any single mistake small.

Each gear is necessary; none is sufficient. A great business bought at any price (no valuation) delivers years of dead money; a great chart of a broken business is a trap; a great idea with 5% position sizing and no stop is a lottery ticket. "Consistent returns" is the *average* of many disciplined decisions — the process compounds while any single prediction, right or wrong, is just one data point.

### 2) Worked example

A one-page selection memo applying all three gears:

```
Gear 1 (fundamental): ROE 22% (5-yr avg), net cash, margin-of-safety 18%
                      vs DCF value (S3 deliverables).
Gear 2 (technical):   above 200-DMA, fresh breakout on volume, RSI 62 —
                      trend confirmed, not exhausted (S2).
Gear 3 (risk):        1% risk position, structural stop below breakout,
                      beta-hedge contingency (S4-M7).
Decision: BUY with defined exit and pre-decided invalidation.
```

The memo is the same shape as the S4-M7 risk plan, with the fundamental and technical cases attached.

```python
# The three-gear checklist as scored data — 0/1 per gear, process total.
gears = {"fundamental": 1, "technical": 1, "risk": 1}
print("gears engaged:", sum(gears.values()), "of 3")   # 3 of 3
```

### 3) Common pitfalls

> **Pitfall:** Substituting one gear for the process — a wonderful chart is not a valuation, and a wonderful valuation is not a stop.
>
> **Pitfall:** Chasing "consistent returns" as a prediction — it is an average over disciplined decisions.
>
> **Pitfall:** Skipping the risk gear because the idea is "obvious" — the obvious ideas are exactly where sizing discipline matters.
>
> **Pitfall:** Scoring yourself on one trade — the process is graded over a series, not an episode.

### 4) Key takeaways

- **Takeaway:** Consistent returns = process: fundamental + technical + risk control.
- **Takeaway:** Each gear is necessary, none sufficient.
- **Takeaway:** The process compounds; any single prediction is one data point.
- **Takeaway:** Grade yourself on the series, not the episode.

## Tantra Lab 9 — The report as data

### Lab goal

Prove the report's data scaffold is reproducible: every chart and number in the research report must trace to a script like this one.

### Code

The verified core snippet is unchanged; the extension adds a small price-statistics anchor for the report's market-data section.

```python
from tantra_examples import SampleInstruments, synthetic_bars

bars = synthetic_bars(SampleInstruments.INFY, days=250, seed=7)
# Data scaffold: every report number must be reproducible from a script like this.
print("coverage days:", len(bars), "last close:", bars[-1].close)

# --- extend: a few report-ready statistics from the scaffold -----------------
from decimal import Decimal
from tantra.quant import returns, mean, std_dev
rets = returns([b.close for b in bars])
print("daily mean:", mean(rets))
print("daily sigma:", std_dev(rets))
print("annualised sigma ≈", std_dev(rets) * Decimal("252").sqrt())
```

**Task:** write the **full research report** on your S3 shortlist company using every deliverable you already built (S3 model, S3 valuation, S4 risk plan, S4 performance notes). Present it in 15 minutes to the panel. This report is a **programme gate**.

### Expected output

The script prints the coverage days (250), the last close (the seed-7 synthetic price), and the daily mean/σ of the return series with the annualised σ — a miniature "market data" appendix whose every number is reproducible by re-running it.

### Hand-in checklist

- [ ] Report follows the seven-section anatomy.
- [ ] Thesis = 2–3 testable bullets; bear case written before conviction.
- [ ] Every number maps to a script or workbook cell (source + formula).
- [ ] Valuation includes target + range + one sensitivity.
- [ ] Risks section = triggers + consequences + pre-committed reactions (S4-M7).
- [ ] 15-minute presentation delivered to the panel with Q&A handled.

### Common errors

- **Unverifiable numbers** — any figure without a source/cell fails the quality gate; fix by linking the script that produces it.
- **Missing range** — a single target price without a sensitivity range reads as a guess.
- **Bear case written after the thesis** — the objectivity requirement fails; rewrite risks first.
- **Presentation = report read aloud** — compress to the argument; the workbook is the appendix.
- **Float in report statistics** — market-data appendix numbers must be Decimal.

## Practice problems

1. List the seven sections of the report anatomy in order, and say which S3/S4 deliverable each reuses.
2. Rewrite "the company is growing fast and is cheap" as a strong, checkable claim.
3. Why must the bear case be written *before* the thesis? Answer in two sentences.
4. A report cites "EPS grew 15%". What four things must the reader be able to check?
5. Give the 15-minute presentation structure with rough minute budgets.
6. A panel member asks "but the stock fell 3% yesterday — is your thesis broken?" How do you answer?
7. Name the three gears of NIFM Ch 26 stock selection and the S-semester each came from.
8. (Short code) Using the Lab 9 scaffold, print the 20-day average close of the series. What is it the appendix to?

### Solutions

1. Thesis (new), Business (new), Industry (S3-M2), Financials (S3-M8 model), Valuation (S3-M7), Risks (S4-M7 risk plan), Rating & target (S3-M7 + thesis).
2. "Revenue grew 18% YoY (₹27,966 cr → ₹33,000 cr, Q2 filing p.12). At a target of ₹1,650 vs ₹1,380 intrinsic at 7% growth, the upside rests entirely on the 9% growth assumption (model row 42)."
3. Before conviction, the writer still imagines failure honestly; after committing, loss aversion edits the bear case into unreality. Pre-written risks are the only reliable ones.
4. Source (filing/page), the two underlying numbers and dates, the calculation itself, and the definition of EPS (diluted? adjusted?).
5. 0:30 thesis+rating, ~4 min evidence, ~4 min model, ~2 min valuation, ~2 min risks, 3 min Q&A.
6. State it is short-term noise unless it is evidence of a thesis break; name what *would* break the thesis (the risk triggers) and show today's data doesn't hit them.
7. Fundamental screen (S3), technical timing (S2), risk control (S4-M7).
8. Average of the last 20 closes in Decimal; it is the report's market-data appendix anchor (and the raw material for an S2 indicator chart).

## Quiz bank

| Question | A | B | C | D | Answer |
|---|---|---|---|---|---|
| The research process ends with | conclusion | disclosure | data | a chart | B |
| Objectivity in a report means | only bullish facts | writing both sides first | no opinions | no data | B |
| A cited number must be | approximate | re-checkable | round | positive | B |
| The thesis section should be | a paragraph | 2–3 testable bullets | a chart | the disclaimer | B |
| The risks section in a report reuses | S3-M8 model | S4-M7 risk plan | S2 indicators | S1 glossary | B |
| Valuation must include | only a target | target + range + sensitivity | a logo | three logos | B |
| A good report lets the reader | disagree with your numbers | trust you blindly | never verify | skip risks | A |
| The 15-minute deck order is | thesis→evidence→valuation→risks→Q&A | risks→thesis→valuation | Q&A→thesis | valuation→thesis | A |
| A hostile question about noise should be | bluffed | answered as noise with thesis-break criteria | ignored | repeated | B |
| Consistent returns come from | predictions | process | luck | a single trade | B |
| NIFM Ch 26's three gears are | fundamental, technical, risk | growth, value, momentum | three sectors | three ratios | A |
| Each report number must map to | a script/workbook cell | memory | the news | the logo | A |
| The decisive assumption belongs | in the appendix | in the thesis | nowhere | in the disclaimer | B |

## Glossary

- **Research process** — question → data → analysis → conclusion → disclosure.
- **Investment thesis** — 2–3 testable bullets stating the *why*.
- **Objectivity** — presenting both sides before choosing one.
- **Data accuracy** — every cited number traceable to a source.
- **Report anatomy** — the seven fixed sections (thesis to rating).
- **Target price** — the model's fair value at the horizon.
- **Sensitivity** — how the target changes as a key assumption moves.
- **Analyst presentation** — 15-minute spoken argument of the report.
- **Q&A discipline** — restate the question, answer it, never bluff.
- **Three gears** — fundamental screen + technical timing + risk control.
- **Consistent returns** — the average outcome of a disciplined process.

## Reading assignment

Study NIFM Chapters 25 (points to remember while preparing research), 26 (stock selection for consistent returns), 30 (report formats), and 38 (presentations), plus IFMC items 24, 48, 65–67 in the [reading list](../appendices/reading-list.md). Re-read your S3 model and S4 risk plan as the report's core inputs.

## Assessment reminder

This module feeds the **programme-gate full research report** (graded, presented to the panel) and the presentation rubric (structure, evidence, Q&A handling); the report bundles your S3/S4 deliverables, so assemble the journal for the [assessment plan](../front/assessment.md).

**Next:** [M10 — Regulatory Ecosystem & Ethics](m10-regulatory-ethics.md)
