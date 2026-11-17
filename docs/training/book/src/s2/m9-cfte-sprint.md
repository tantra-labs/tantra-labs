# M9 — CFTe I Mock Sprint

> **Week 32 · 16 hrs · Exam prep for CFTe I (120 Q, 2h30m, pass 74/120)**

## Learning outcomes

- Sit three timed IFTA-format mock exams (120 questions each) and score them.
- Convert mock analytics into targeted weak-topic clinics.
- Write the S2 formula sheet from memory and audit it against the module
  formulas.
- Execute the exam-day time budget and complete the CFTe I registration.

## Prerequisites

- Every formula from [M4](m4-indicators-math.md) and [M6](m6-advanced-indicators.md)
  — the sprint assumes you can *derive*, not just recognise.
- Pattern vocabulary from [M2](m2-candlesticks.md), [M3](m3-chart-patterns.md),
  and the Dow framework from [M1](m1-dow-theory.md).
- Paper-trading habits from [M8](m8-trading-terminal-paper.md) — exam stamina is
  a skill you train, like position sizing.

## What you will do

### 1) Concept

The CFTe I (Certified Financial Technician, Level I) is the IFTA's 120-question,
2-hour-30-minute multiple-choice exam; the pass bar is **74/120**. The sprint's
job is to make the real exam *boring*: three timed mocks, analytics-driven
clinics, and a booking. You will sit the mocks under real timing, receive
weak-topic clinics from mock analytics, and register for a Pearson VUE exam
window (year-round).

### 2) Worked example

Know the pass bar in decimal before you sit anything: `74/120 ≈ 0.6167`. A
score of 73 is a fail by one question — plan for margin, not for 74.

```python
from decimal import Decimal
pass_bar = Decimal("74") / Decimal("120")
print("pass fraction:", pass_bar)      # 0.6166666666666666666666666667
print("73 is a fail:", Decimal("73") < Decimal("74"))   # True
```

### 3) Common pitfalls

> **Pitfall:** taking the first mock untimed *and* counting it. Calibrate on
> Mock #1 untimed, then treat every subsequent session as exam conditions.
> **Pitfall:** booking the exam before the third mock — the sprint's pass gate
> is `≥ 75/120` on Mock #3, and the booking follows the evidence.
> **Pitfall:** skipping the analytics. "I got 68" is noise; "I missed 9 of 14
> in indicator math" is a clinic list.

### 4) Key takeaways

- **Takeaway:** pass bar `74/120 ≈ 61.7%` — one question matters.
- **Takeaway:** three timed mocks, then analytics, then clinics.
- **Takeaway:** book Pearson VUE only after the Mock #3 gate.

## Mock format

### 1) Concept

| Item | Value |
|---|---|
| Questions | 120 multiple-choice, single answer |
| Duration | 2 hours 30 minutes |
| Pass bar | 74/120 |
| Sources | CFTe I syllabus core reading (E&M, Murphy, Pring, Nison, Le Beau/Lucas, Du Plessis) + IFTA Appendices A–D |

Two properties shape strategy: **150 minutes ÷ 120 questions = 75 seconds per
question**, and the single-answer format rewards *elimination* — two options are
usually absurd, one is a distractor, one is correct.

### 2) Worked example

Time budget in `Decimal`: 120 questions, 150 minutes.

```
seconds per question = 150 × 60 / 120 = 75
```

```python
from decimal import Decimal
minutes, questions = Decimal("150"), Decimal("120")
print("sec/question:", minutes * Decimal("60") / questions)   # 75
```

### 3) Common pitfalls

> **Pitfall:** spending 4 minutes on a hard question and losing three easy ones.
> The 75-second budget is a *cap* — flag and move on.
> **Pitfall:** assuming your mock score on IFTA questions transfers to your
> trading wins. The exam tests *recognition and recall* of the syllabus.
> **Pitfall:** ignoring Appendix B (breadth) and C (cycles) — they are on the
> exam even though they felt like "concept" modules.

### 4) Key takeaways

- **Takeaway:** 75 seconds per question — the budget is the exam.
- **Takeaway:** single answer + elimination beats blank guessing.
- **Takeaway:** all source material is on the [Reading & Resource
  List](../appendices/reading-list.md).

## Week plan

### 1) Concept

Six days, one purpose — convert mock analytics into score:

- **Day 1:** Mock #1 (untimed first, to calibrate); then timed.
- **Day 2:** clinic — Dow Theory, chart patterns, candlesticks, indicators math
  (**M4 is the priority**).
- **Day 3:** Mock #2 (timed, 150 min) + clinic on gaps/cycles/sentiment.
- **Day 4:** clinic — point & figure, breadth, money management.
- **Day 5:** Mock #3 (timed) — **target ≥ 75/120**; book the exam.
- **Day 6:** review all three mocks; log the weakest 20 topics.

### 2) Worked example

Turn mock analytics into a clinic list: 120 questions, 20 topic tags; a topic
with `wrong ≥ 2` is a clinic.

```python
from decimal import Decimal
wrong = {"indicators_math": 9, "breadth": 3, "cycles": 1, "money_mgmt": 2}
clinics = sorted((t for t, w in wrong.items() if w >= 2), key=lambda t: -wrong[t])
print("clinic list:", clinics)   # ['indicators_math', 'breadth', 'money_mgmt']
```

### 3) Common pitfalls

> **Pitfall:** re-reading the *whole* book on clinic days. Clinics are targeted:
> wrong-topic sets, not chapters.
> **Pitfall:** taking Mock #2 before the Day-2 clinic — the sprint is a
> sequence, not a buffet.
> **Pitfall:** drifting from the 150-minute rule on Mock #2 — timed means
> *timed*.

### 4) Key takeaways

- **Takeaway:** mocks → analytics → clinics → mocks; a closed loop.
- **Takeaway:** M4 (indicators math) is the priority clinic.
- **Takeaway:** Day 5's `≥ 75/120` is the gate; book only past it.

## The exam-day checklist

### 1) Concept

The last three hours matter as much as the last three weeks:

- Pearson VUE booking confirmed; ID ready; arrive **30 minutes early**.
- **Budget:** Q1–Q80 by the 90-minute mark, all 120 by 140 minutes, review the
  flagged ~10 questions in the final 10.
- Never leave a question blank; educated elimination beats guessing blind.

### 2) Worked example

Check the budget numerically: 90 minutes for the first 80 questions,
`90 × 60 / 80 = 67.5 seconds` each — *faster* than the global average; the back
40 questions have `50 × 60 / 40 = 75` seconds each.

```python
from decimal import Decimal
print("Q1-80 pace:", Decimal(90) * Decimal(60) / Decimal(80))   # 67.5 sec/q
print("Q81-120 pace:", Decimal(50) * Decimal(60) / Decimal(40)) # 75.0 sec/q
```

### 3) Common pitfalls

> **Pitfall:** reviewing answered questions instead of the flagged ten — the
> final 10 minutes are for *flagged*, not for re-verifying everything.
> **Pitfall:** skipping the blank-question rule. A blank is a guaranteed miss;
> an eliminated guess has a real chance.
> **Pitfall:** arriving at the VUE centre in a rush — the 30-minute buffer is
> part of the plan.

### 4) Key takeaways

- **Takeaway:** Q1–80 by minute 90; all 120 by minute 140; review flags.
- **Takeaway:** never leave a blank — eliminate first, guess second.
- **Takeaway:** logistics (booking, ID, arrival) are scored too — by you.

## Tantra Lab 9 — Formula-sheet drill

### Lab goal

Write the entire S2 formula sheet from memory every day, then audit it against
the module formulas below — the fastest possible exam-recall trainer.

### Code

The reference sheet (reproduce from memory, then compare):

```
SMA_t = (1/n)Σp        EMA_t = α·p + (1−α)·EMA_{t−1}, α = 2/(n+1)
RSI = 100 − 100/(1+RS)   MACD = EMA12 − EMA26, Signal = EMA9(MACD)
Bollinger: Middle ± k·σ   ATR: Wilder(TR)   TR = max(H−L, |H−C|, |L−C|)
+DI/−DI, DX, ADX   Ichimoku: (HH+LL)/2 over 9/26/52
```

A `Decimal` audit of one line — the α constant:

```python
from decimal import Decimal
alpha = Decimal(2) / Decimal(11)
print("alpha:", alpha)     # 0.1818181818181818181818181818 — EMA(10)
```

### Expected output

`alpha: 0.1818181818181818181818181818`. The audit compares your *written*
sheet to the reference: every `α`, every `n`, every limit case (RSI = 100 when
AvgLoss = 0) must match character for character.

### Hand-in checklist

- [ ] One memory-written formula sheet per sprint day (6 sheets).
- [ ] The audit: every mismatch corrected and re-dated.
- [ ] The Mock #1/#2/#3 scores with question-count analytics.
- [ ] The weakest-20-topics log from Day 6.
- [ ] Pearson VUE registration confirmation (or a note on the planned window).

### Common errors

- **Writing `α = 1/(n+1)`** — the wheel uses `2/(n+1)`; half-remembered
  formulas are exactly what mocks punish.
- **Writing ATR as `SMA(TR)`** — ATR uses *Wilder* smoothing, the same
  `(n−1)/n` recursion as RSI.
- **Skipping the limit cases** — "RSI = 100 when AvgLoss = 0" is a favourite
  exam distractor; write it down every time.

## Practice problems

1. Convert the pass bar to a fraction and a percentage. How many questions can
   you *miss* and still pass (out of 120)?
2. Compute seconds per question for 120 questions in 150 minutes.
3. Your Mock #1 analytics show 11 wrong in indicator math out of 14 questions.
   Name the priority clinic and the module to re-study first.
4. Write the EMA line of the formula sheet from memory, then state `α` for
   `n = 26` (the MACD slow line).
5. A blank question is worth 0; a 50-50 elimination is worth ~0.5 expected
   points. Show the arithmetic for why you never leave a blank.
6. Why must `EMA_0 = p_0` (the seed) appear on the formula sheet even though it
   feels "obvious"?
7. The budget says Q1–80 by minute 90. At what per-question pace is that, and
   how does it differ from the back 40?
8. List the three Elliott impulse rules from memory (M7) and the four gap types
   (M5) in one line each — the exam's "recall" questions reward exactly this.

### Solutions

1. `74/120 ≈ 0.6167 ≈ 61.7%`. You may miss up to `120 − 74 = 46` questions and
   still pass — provided you *answer* 74 correctly.
2. `150 × 60 / 120 = 75` seconds per question.
3. Indicators math — re-study [M4](m4-indicators-math.md) first; 11/14 wrong is
   a structural gap, not a bad day.
4. `EMA_t = α·p_t + (1−α)·EMA_{t−1}`, `α = 2/(26+1) = 2/27 ≈ 0.07407`.
5. Blank: 0. Two-way guess: `0.5 × 1 = 0.5` expected points — a blank *gives
   up* half a point that elimination can earn.
6. Because the exam's distractor answers test exactly this: `EMA_0 = 0` and
   `EMA_0 = SMA` both *look* reasonable; only the seed rule is the wheel's.
7. `90 × 60 / 80 = 67.5` sec/q — front-loaded to bank time; the back 40 get
   the global 75.
8. Wave 2 never retraces > 100% of wave 1; wave 3 is never the shortest; wave 4
   never enters wave 1's territory. Gaps: common, breakaway, runaway,
   exhaustion.

## Quiz bank

| Question | A | B | C | D | Answer |
|---|---|---|---|---|---|
| The CFTe I pass bar out of 120 is | 60 | 70 | 74 | 80 | C |
| The exam duration is | 2h00m | 2h30m | 3h00m | 90m | B |
| Seconds per question (120 in 150 min) | 60 | 75 | 90 | 100 | B |
| The priority clinic in the sprint is | P&F | Indicators math (M4) | Seasonality | Terminal ops | B |
| Q1–80 should be done by minute | 60 | 75 | 90 | 110 | C |
| The α of the MACD slow EMA(26) is | 1/26 | 2/27 | 2/26 | 1/27 | B |
| A blank question is worth | 0 | 0.5 | 1 | −0.25 | A |
| A 50-50 elimination is worth | 0 | 0.25 | 0.5 | 1 | C |
| Mock #3's pass gate is | ≥ 70/120 | ≥ 74/120 | ≥ 75/120 | ≥ 80/120 | C |
| CFTe I is registered through | NSE | BSE | Pearson VUE | SEBI | C |

## Glossary

- **CFTe I** — IFTA's Certified Financial Technician Level I exam.
- **Mock exam** — a full-length practice exam under exam timing.
- **Pass bar** — 74/120; `≈ 61.7%`.
- **Analytics** — per-topic question-level breakdown of mock results.
- **Clinic** — a targeted re-study session on the worst topics.
- **Elimination** — removing absurd options to raise the guess's value.
- **Flag-and-skip** — marking a hard question and returning later.
- **Formula sheet drill** — writing the S2 formulas from memory daily.
- **Pearson VUE** — the exam delivery network where CFTe I is sat.
- **Weakest-20 log** — the Day-6 ranked list of weak topics.

## Reading assignment

- IFTA *CFTe Syllabus & Study Guide* (2026 ed.) + Appendices A–D + official
  mocks.
- Revision anchors: E&M (patterns, volume), Murphy (indicators), Pring
  (sentiment/cycles), Nison (candles), Le Beau/Lucas (systems), Du Plessis
  (P&F).
- Platform: re-run `tantra-examples/examples/02_indicators.py` as a living
  formula reference.
- Full list: [Reading & Resource List](../appendices/reading-list.md).

## Assessment reminder

The **final mock score ≥ 75/120 is the sprint's pass gate**, and the sprint ends
with the **S2 end-term exam** (theory + constructed-analysis practical). Both
are graded; see [Assessment](../front/assessment.md).

## Assessment

- Final mock score ≥ 75/120 is the pass gate for the sprint.
- Sit the S2 end-term exam (theory + constructed-analysis practical).

**End of Semester 2.** Next: [Semester 3](../s3/overview.md) — Fundamental
Analysis, Valuation & Modeling.
