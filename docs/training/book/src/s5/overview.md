# Semester 5 — Track Specialization & Capstone

> **Weeks 65–80 · elective · mirrors PGP Trimester-IV (PM/IA/RA) and the CFTe II / CMT optional paths**

## How it works

Choose **one** track. Each track = 3 modules + a capstone + a mock sprint. You
may study two tracks if you have the capacity, but certification credit applies
to the primary track.

This is the **final programme gate**: the semester grade, and ultimately your
eligibility for the NISM/CFTe credentials listed below, rests on the capstone
you deliver here. Everything from Semesters 1–4 — statements and ratios, DCF,
statistics, portfolio theory, risk, and the NISM XV pass — is now applied in one
published-grade piece of work. You are no longer learning a skill; you are
proving it.

## The four tracks

| Track | Capstone | Credential at stake |
|---|---|---|
| [RA — Research Analyst](track-ra.md) | Publish-grade research report + 30-min panel defense | NISM XV (already passed in S4) → RA registration path |
| [TA — Technical Analyst](track-ta.md) | Constructed chart-analysis package (CFTe II style) | **CFTe II** / CMT I |
| [PM — Portfolio Management](track-pm.md) | Model portfolio + mandate-compliance memo | PM registration path |
| [IA — Investment Advisory](track-ia.md) | Client financial plan (case-based) | IA registration path |

All four capstones share one shape: a **written deliverable** you could hand to
a professional, plus a **spoken defense or mock exam** that proves you can
explain it. The written work is graded on structure, evidence, exactness, risk
& disclosure, and presentation — the same five criteria every rubric in this
semester uses, so whichever track you choose you are being held to the same
professional standard.

## How to choose a track

Ask three questions before you decide (deadline: end of Week 65):

1. **Which skill already gives you the most energy?** If reading financial
   statements and building DCF models felt like play in S3, choose RA. If you
   stayed up late drawing trendlines and testing indicator rules in S2, choose
   TA. If portfolio math (S4-M3) and allocation felt natural, choose PM. If you
   enjoyed advising, risk-profiling, and product selection, choose IA.
2. **Which credential feeds your first job goal?** An equity research
   associate role starts from the RA track; a prop-desk or technical analyst
   trainee role from TA; portfolio operations/fund accounting from PM; wealth
   associate / relationship manager / mutual fund distributor roles from IA
   (the NISM V-A and X-A pathways).
3. **Which capstone can you finish in 16 weeks on your current foundations?**
   RA is the heaviest on written output and rebuilds your S4 report. TA is the
   most exam-shaped (CFTe II is a single high-stakes constructed paper). PM and
   IA are the most procedural and case-based — good choices if you want the
   capstone to double as on-the-job evidence for a support role.

If you are genuinely split between two tracks, choose the one whose capstone
you would rather *defend in front of a panel*. That defense is where the grade
is actually decided.

A quick decision shortcut — match the row that sounds most like you:

| If your best module was… | …and your goal is… | Choose |
|---|---|---|
| S3-M7 valuation / S3-M8 modeling | equity research, sell-side, "idea" work | RA |
| S2 charting and indicator labs | trading floors, terminal roles, CFTe path | TA |
| S4-M3 portfolio theory / S4-M4 performance | running money, fund ops, PMS | PM |
| Advising, suitability, product selection | client-facing wealth roles, MF distribution | IA |

The choice is reversible until the end of Week 66 if you change your mind — the
three module titles in Weeks 67–68 all rebuild foundations you already covered,
so a late switcher loses at most a fortnight of runway, not the semester.

## Common timeline

All tracks follow the same 16-week arc, and every track chapter below expands
this skeleton into a week-by-week plan:

| Weeks | Phase | What is happening |
|---|---|---|
| 65–66 | Track selection & briefing | Pick your track, read the track chapter, set up your workspace and journal. |
| 67–70 | Modules 1–2 | Rebuild the foundations specific to your track (advanced valuation, CFTe practice, allocation, planning blocks). |
| 71–74 | Module 3 + capstone start | Compliance/regulation module, then begin the capstone deliverable in earnest. |
| 75–78 | Capstone build + mock sprint | Draft, verify numbers, run the mock sprint, iterate on peer review. |
| 79 | Final draft & compliance pass | Disclosure annex, Decimal re-check, presentation rehearsal. |
| 80 | Defense / submission | Panel defense (RA), final submission (TA/PM/IA), journal close-out. |

A rule of thumb that keeps you out of trouble: **finish the first full draft of
the capstone by the end of Week 77**, because weeks 78–79 are for the two
things that decide grades — checking every number and rehearsing the defense.

## Weekly rhythm

Every week in this semester has the same four-beat rhythm, and keeping the beat
is what makes the 16 weeks finishable:

1. **Read (Mon–Tue)** — the week's module material plus one item from the
   reading list; add to your glossary.
2. **Build (Wed–Thu)** — the week's lab: the indicator sheet, the strategy
   comparison, the screen, or the SIP worksheet, all in `Decimal`.
3. **Write (Fri)** — one page of the capstone's document: the thesis, the memo
   section, the annex. This is how a 6–12 page capstone appears almost without
   noticing.
4. **Log (Sat)** — one journal entry: what you built, what it said, one thing
   you would redo. The journal is worth ~10% of the semester and is the 
   evidence the defense panel reads before you walk in.

Plan for **8–10 focused hours a week**. Week 75 (the mock sprint) and weeks
78–79 (compliance freeze and rehearsal) will feel heavier — protect them in
your calendar now, before deadlines collide with them.

## Tantra tie-in

Every track capstone uses the platform:

- **RA:** your S3 model + S4 report, sharpened.
- **TA:** indicators, backtests, system testing (`10_walkforward_optimization.py`).
- **PM:** `portfolio_strategy` (universe, selection, weighting, rebalance).
- **IA:** screening + suitability frameworks (`mutual_funds/*`, `screening/*`).

None of these replaces the professional deliverable — the platform supplies the
evidence, the math, and the reproducibility that a publish-grade document needs.
Every number in your capstone must come from a Decimal computation you can
re-run (Zero-Floats policy: prices, returns, and balances are `decimal.Decimal`,
never `float`).

## Assessment

- Track capstone (the capstone is the final programme gate).
- Track mock sprint (CFTe II style or NISM-style).
- Modules are assessed through the weekly lab/journal hand-ins that feed the
  capstone; see `../front/assessment.md` for how semester weights are applied.

Three hard rules for the gate:

1. **The capstone must be submitted** — a missing or incomplete capstone fails
   the semester regardless of module scores.
2. **Every number must be Decimal** — any float-typed price, return, or balance
   in the submitted work triggers a mandatory rewrite.
3. **Every claim must be sourced** — an assertion with no model, calculation, or
   citation cannot pass the evidence criterion of the rubric.

**Next:** [Track RA — Research Analyst](track-ra.md)
