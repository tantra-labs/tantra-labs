# Assessment & Grading Scheme

## Weighting

| Component | Weight | Where |
|---|---|---|
| Continuous assessment (quizzes, labs, journals, presentations) | 25% | Every module |
| Mid-term exams | 15% | Week 8 (S1), Week 24 (S2), Week 40 (S3), Week 56 (S4) |
| End-term exams | 30% | Weeks 16, 32, 48, 64 |
| Portfolio projects (model, research report, track capstone) | 20% | S3 model, S4 report, S5 capstone |
| Certification mocks | 10% | CFTe I sprint, NISM XV sprint |

### Worked example: how a final grade is calculated

A learner's semester grades combine with the weights above. Example: continuous
80%, mid-term 70%, end-term 65%, portfolio 75%, mocks 90%.

```text
final = 0.25 x 80  + 0.15 x 70  + 0.30 x 65  + 0.20 x 75  + 0.10 x 90
      = 20.0      + 10.5       + 19.5       + 15.0       + 9.0
      = 74.0   -> B+ (Good), above the 60% pass line
```

Run your own numbers with your last semester's scores before the first mid-term,
so no grade ever arrives as a surprise: the weights are fixed, and the
arithmetic is yours to check.

## Grading scale

| Grade | Range | Meaning |
|---|---|---|
| A+ | ≥ 90% | Distinction |
| A | ≥ 80% | Excellent |
| B+ | ≥ 70% | Good |
| B | ≥ 60% | **Pass** |
| Fail | < 60% | Remedial + re-sit required |

## Gates (non-negotiable)

1. **S1 → S2:** must pass the S1 end-term exam (≥ 60%).
2. **S3 deliverable:** the modeled-company Excel workbook must be submitted and
   pass rubric review.
3. **S4 deliverable:** the full research report must be submitted and defended.
4. **S5 capstone:** the track capstone must be completed before certification
   mocks count toward the certificate.

## Exam discipline

- **Every semester has a mid-term and an end-term examination** — this mirrors
  the IFMC syllabus requirement and keeps pacing honest.
- Results are returned within one week and reviewed in a mentor 1:1.
- Any failed exam can be re-sat once per semester; a second failure triggers a
  personal remedial plan before re-admission to the next semester gate.

## Lab & journal grading

- Tantra Labs are graded on a rubric: **runs cleanly**, **uses exact Decimal math**,
  **correct outputs**, **explains the result**.
- The paper-trading journal is graded on: **entries logged**, **rules followed**,
  **lessons written**, **no loss-blame language**.

## Sample rubric

The rubric below shows the three bands used across the programme. **"Meets
expectations" is the programme standard** — it is a pass and a normal grade.
**"Exceeds"** is what a distinction portfolio looks like.

| Component | Exceeds expectations (A band) | Meets expectations (B band) | Below expectations (rework) |
|---|---|---|---|
| A graded Tantra Lab (e.g., the S2-M4 RSI lab) | Runs cleanly; every price is `Decimal`; output is explained with a takeaway; adds one extra check (e.g., a different period) | Runs cleanly; correct Decimal outputs; a short explanation present | Does not run; `float` leakage in prices; no explanation |
| A journal entry (one trading day) | Rule stated, outcome recorded, an honest lesson, and a forward question | Rule + outcome recorded clearly | Missing fields, or loss-blame language ("the market did this to me") |
| A research report (S4 deliverable) | Defensible thesis, data cited, a risk section, a clear recommendation, defended under questions | All required sections, correct ratio math, sources cited | Missing sections, unsupported claims, ratio errors |

Two notes on the bands. First, the **Decimal requirement is not decorative**:
any `float` where a price, quantity, or balance belongs fails the "meets" bar
for that row. Second, the "rework" column is not a punishment — it is the normal
feedback loop; see the FAQ below for what happens next.

## What happens if I fail

1. **I failed a module quiz. Is the course over?** No. Quizzes are continuous
   assessment (part of the 25%). The lowest quiz score each semester is dropped,
   and a failed quiz can be re-attempted once for a capped score.
2. **I failed the S1 end-term — the gate to Semester 2.** You may re-sit it once
   in the next exam window (about two weeks later). A second failure triggers a
   personal remedial plan (extra lab hours plus a weekly mentor 1:1) before you
   are re-admitted to the gate.
3. **I failed the S3 modeled-company deliverable.** You submit a reworked
   workbook within two weeks and it is re-graded by rubric. Because this is the
   gate to S4, the rework is mandatory — it is not optional bonus work.
4. **I failed a certification mock.** Mocks are 10% of the grade and exist
   precisely to find your weak topics. After every mock there is a weak-topic
   clinic; you re-sit the mock and your mock grade is the best of the series.
5. **What if I fail the same exam twice?** A second failure triggers the
   personal remedial plan and a reduced module load. You do not advance to the
   next gate until you pass — the calendar stretches, the standard does not.
6. **Do failed attempts appear on my final certificate?** No. The certificate
   records final grades and the certifications you passed. Re-sits are a normal,
   accepted part of the system; what the gates protect is *mastery*, not your
   first-attempt record.

## Study-time budget

The default load is **~30 hours/week for 64+ weeks ≈ 1,920 hours**. A weekly
template:

| Block | Hours | What you do |
|---|---|---|
| Lectures | 12 | Watch/read the module lectures; take notes in your own words |
| Lab | 10 | Tantra Labs, the linked example scripts, journal entries |
| Self-study | 8 | Reading assignment, flashcards, weekly review, mock practice |

Adjustments, not exceptions: in **mock weeks**, move ~4 self-study hours to a
timed mock plus its clinic; in **exam weeks**, move ~6 lab hours to revision.
Learners who fall behind almost always under-invest in *lab*, not lectures — if
you must cut something, cut note-taking before you cut a lab.

**Next:** [Certification Ladder](certifications.md)
