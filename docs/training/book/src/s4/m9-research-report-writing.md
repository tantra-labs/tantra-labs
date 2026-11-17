# M9 — Research Report Writing & Analyst Presentations

> **Weeks 61–62 · 20 hrs · PLO-10 · Core:** NIFM Ch 25, 26, 30, 38; IFMC items 24, 48, 65–67

## Learning outcomes

- Structure a professional research report: thesis, business, industry,
  financials, valuation, risks, rating, target price.
- Write objectively with evidence and data accuracy.
- Deliver a 15-minute analyst presentation.
- Keep "points to remember while preparing research" (NIFM Ch 25) as a checklist.

## Lesson 9.1 — Fundamentals of research

- Research is a process: question → data → analysis → conclusion → disclosure.
- Objectivity: write both sides of the case before you pick one.
- Data accuracy: every number cited must be re-checkable.

## Lesson 9.2 — The report anatomy

| Section | Contents |
|---|---|
| Investment thesis | 2–3 bullet "why" |
| Company & business | What it does, segments |
| Industry | Forces, cycle position (S3-M2) |
| Financials | Historicals + model (S3-M8) |
| Valuation | Methods + target + range (S3-M7) |
| Risks | What breaks the thesis (S4-M7) |
| Rating & target | Buy/Hold/Sell with horizon |

## Lesson 9.3 — Qualities of a good report

- Structure, clarity, evidence, balanced risks, honest assumptions.
- The reader must be able to disagree with you using *your own numbers*.

## Lesson 9.4 — Analyst presentations

- 15-minute structure: thesis → evidence → valuation → risks → Q&A.
- The 3-slide discipline from S1-M9, scaled up.
- Handling hostile questions: state assumptions, don't defend noise.

## Lesson 9.5 — Stock selection for consistent returns (NIFM Ch 26)

- Combine fundamental screen (S3) + technical timing (S2) + risk control (S4-M7).
- "Consistent returns" = process, not prediction.

## Tantra Lab 9 — The report as data

```python
from tantra_examples import SampleInstruments, synthetic_bars

bars = synthetic_bars(SampleInstruments.INFY, days=250, seed=7)
# Data scaffold: every report number must be reproducible from a script like this.
print("coverage days:", len(bars), "last close:", bars[-1].close)
```

**Task:** write the **full research report** on your S3 shortlist company using
every deliverable you already built (S3 model, S3 valuation, S4 risk plan, S4
performance notes). Present it in 15 minutes to the panel. This report is a
**programme gate**.

## Assessment

- **Full research report** (graded, presented to panel).
- Presentation rubric (structure, evidence, Q&A handling).

**Next:** [M10 — Regulatory Ecosystem & Ethics](m10-regulatory-ethics.md)
