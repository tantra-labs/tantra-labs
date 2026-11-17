# Track PM — Portfolio Management

> **Mirrors PGP T4(PM)-401/402/403 · Capstone: model portfolio + mandate-compliance memo**

## Capstone at a glance

| | |
|---|---|
| **Deliverable** | A model portfolio with an explicit mandate — universe, selection rule, weighting scheme, rebalance schedule — plus a mandate-compliance memo and a performance report |
| **Format** | Portfolio construction workbook (CSV/Excel) + mandate-compliance memo (3–5 pages) + performance report + 15-min recorded defense |
| **Time budget** | Weeks 65–80 (16 weeks); ~8–10 hours/week = 130–160 total hours |
| **Grading weight** | Capstone ≈ 50% of the semester; modules (labs + quizzes) ≈ 30%; mock sprint ≈ 10%; journal ≈ 10% |
| **Credential at stake** | PM registration path under SEBI PMS regulations — the capstone memo mirrors the compliance documentation a PMS must maintain |

## Modules

1. **Portfolio strategy** — equity/fixed income/alternatives across the
   efficient frontier; strategic vs tactical allocation (S4-M3 built up).
2. **Quantitative tools & techniques** — factor selection, risk models,
   performance attribution, rebalancing schedules.
3. **Operational & regulatory aspects of PM** — SEBI PM regulations, mandate
   compliance, reporting, client segregation.

## Track modules

### Module 1 — Portfolio strategy (weeks 67–70)

A portfolio is only as good as its **mandate**: the written contract that says
whose money this is, what it can own, what risk it can take, and how it will be
rebalanced. This module builds the strategic layer on top of the efficient
frontier and portfolio theory from S4-M3 — choosing the asset mix
(equity/fixed income/alternatives) that fits the mandate's risk budget, then
layering **tactical** decisions on top that deviate from the strategic weights
only within stated limits. You will learn the language of mandates: investment
objective, benchmark, permitted instruments, concentration limits, and
rebalancing policy.

**Builds on:** [S4-M1 statistics](../s4/m1-statistics.md), [S4-M2 correlation & regression](../s4/m2-correlation-regression.md), [S4-M3 portfolio theory](../s4/m3-portfolio-theory.md), [S4-M4 performance measurement](../s4/m4-performance-measurement.md), [S4-M8 currency & fixed income](../s4/m8-currency-fixed-income.md).

**Deliverables:** (1) a written mandate for a fictional client (objective,
benchmark, risk budget, constraints), (2) a strategic asset allocation
justified by the efficient frontier from [S4-M3](../s4/m3-portfolio-theory.md),
(3) a tactical-deviation policy with stated bands.

### Module 2 — Quantitative tools & techniques (weeks 69–72)

This is the machine room: **factor selection** (why pick `momentum` or
`low_volatility` as the selection signal), **risk models** (volatility,
correlation, drawdown), **performance attribution** (how much of the return came
from allocation vs security selection), and **rebalancing schedules** (calendar
rebalancing vs drift-band rebalancing, and the cost of each). The platform's
`portfolio_strategy` API encodes exactly this pipeline: a *universe*, a
*selector* (which names to hold), a *weighting* scheme, and a *schedule* for
when to rebuild. Your job in this module is to understand every knob and to be
able to defend each choice in writing.

**Builds on:** [S4-M1 statistics](../s4/m1-statistics.md), [S4-M2 correlation & regression](../s4/m2-correlation-regression.md), [S4-M4 performance measurement](../s4/m4-performance-measurement.md).

**Deliverables:** (1) a backtest comparing `momentum` vs `low_volatility`
selection over the same universe and window, (2) an attribution write-up of one
strategy's returns, (3) a rebalancing-cost comparison (monthly vs drift-band),
(4) a risk report (volatility, max drawdown, Sharpe) in Decimal.

### Module 3 — Operational & regulatory aspects of PM (weeks 71–74)

Running money is a regulated business. This module covers the **SEBI
Portfolio Manager regulations**: what a registered portfolio manager may and
may not do, the disclosure and reporting obligations to clients, **client
segregation** (your money and the PM's money never mix; each client's portfolio
is accounted separately), mandate compliance (the portfolio must stay inside
the mandate that was agreed), and the operational calendar — NAV computation,
reporting cycles, and audit trails.

**Builds on:** [S4-M10 regulatory & ethics](../s4/m10-regulatory-ethics.md), [S4-M11 NISM sprint](../s4/m11-nism-sprint.md).

**Deliverables:** (1) a compliance memo template (what must be disclosed, when,
and to whom), (2) a client-segregation checklist, (3) a mandate-compliance
self-audit of the portfolio you are building for the capstone.

## Capstone

Build a **model portfolio** with an explicit mandate:

- Universe + selection rule + weighting scheme + rebalance schedule.
- Mandate-compliance memo: how every position satisfies the mandate.
- Performance report: Sharpe, alpha, attribution vs benchmark.

## Capstone tasks

Complete these in order; each task has a deliverable that is graded.

1. **Write the mandate** — objective, benchmark, risk budget, constraints, and
   the rebalancing policy. *Deliverable:* the mandate document.
2. **Define the universe** — the investable set (e.g., NIFTY50 constituents)
   with the liquidity/eligibility screen stated. *Deliverable:* universe list
   with the eligibility rule.
3. **Choose the selection rule** — the factor (momentum, low volatility, or a
   hybrid) with the research that justifies it. *Deliverable:* factor-choice
   memo with the comparison backtest.
4. **Choose the weighting scheme** — equal weight, inverse-volatility, or
   another scheme, with the reason in risk terms. *Deliverable:* weighting
   rationale.
5. **Choose the rebalance schedule** — calendar (monthly first session) or
   drift-band, with the cost logic. *Deliverable:* schedule rationale.
6. **Build the portfolio** — construct the model portfolio in
   `portfolio_strategy` (see Tantra Lab) and run it. *Deliverable:* the
   runnable construction + position list in Decimal.
7. **Write the mandate-compliance memo** — walk position by position through
   every mandate constraint. *Deliverable:* the memo.
8. **Produce the performance report** — Sharpe, alpha, attribution, and max
   drawdown vs the benchmark. *Deliverable:* the report.
9. **Record the 15-minute defense** — present mandate → construction → results
   → compliance. *Deliverable:* recording + final submission.

## Grading rubric

| Criterion | Exceeds (A) | Meets (B/C) | Below (D/F) |
|---|---|---|---|
| **Structure** | Mandate → construction → compliance → performance flows in order; every document could be handed to a compliance officer | Correct order with minor gaps; some documents thin | Pieces of the pipeline missing or out of order; no single portfolio narrative |
| **Evidence / math correctness** | Every factor, weighting, and schedule choice backed by a shown backtest or calculation; attribution reconciles to returns | Most choices justified; one or two asserted without a shown test | Choices asserted with no evidence; attribution does not add up |
| **Decimal / exactness** | All weights, prices, returns, Sharpe, and alpha are `Decimal`; weights sum to 100% exactly | Decimal throughout with minor formatting slips | Float-typed returns/weights; weights that don't sum to 100% |
| **Risk & disclosure** | Risk budget respected and shown; client segregation and reporting obligations addressed; benchmark risk stated | Risks and disclosures present; some generic | No risk budget; no compliance view; benchmark undefined |
| **Presentation** | 15-min defense within time, numbers legible, compliance questions answered from the memo | Clear delivery, minor time overrun, most questions answered | Reading slides; unable to defend a weighting choice under Q&A |

## Study plan (weeks 65–80)

- **Week 65** — Choose the track; read this chapter; set up the journal and the
  portfolio workspace.
- **Week 66** — Module 1 start: refresh [S4-M3 portfolio theory](../s4/m3-portfolio-theory.md)
  and [S4-M4 performance measurement](../s4/m4-performance-measurement.md).
- **Week 67** — Write the fictional client mandate; strategic asset allocation
  from the efficient frontier.
- **Week 68** — Tactical-deviation policy; start Module 2: `momentum` vs
  `low_volatility` comparison backtest.
- **Week 69** — Factor choice memo; risk-model review (volatility, correlation,
  drawdown).
- **Week 70** — Performance attribution walkthrough; rebalancing-cost
  comparison (monthly vs drift-band).
- **Week 71** — Module 3: SEBI PM regulations; client-segregation checklist.
- **Week 72** — Compliance memo template; mandate-compliance self-audit of the
  evolving portfolio.
- **Week 73** — Capstone build: fix the universe and the full construction
  (tasks 2–5).
- **Week 74** — Run the portfolio in `portfolio_strategy` (Tantra Lab); first
  full draft of the compliance memo.
- **Week 75** — Mock sprint week: NISM-style regulatory mock (see below).
- **Week 76** — Peer review a classmate's memo; revise your own.
- **Week 77** — Performance report: Sharpe, alpha, attribution in Decimal;
  reconcile every number.
- **Week 78** — Compliance freeze: position-by-position mandate check, Decimal
  re-run, weights-sum-to-100% check.
- **Week 79** — Defense rehearsal (15 minutes, stopwatch); prepare the five
  hardest compliance questions.
- **Week 80** — Final submission and defense; journal close-out.

## Mock sprint

A **NISM-style regulatory mock** on portfolio management regulation, in the
same question format as the NISM exams (multiple-choice, no negative marking):

1. Build a 40-question mock from the Module 3 material — SEBI PM regulations,
   mandate compliance, reporting obligations, client segregation, disclosure —
   and sit it timed (60 minutes).
2. Score it at the official pass rule (50%) and review every wrong answer
   against the [S4-M10](../s4/m10-regulatory-ethics.md) and
   [S4-M11](../s4/m11-nism-sprint.md) notes.
3. Target ≥ 75%. Below 75%, repeat with a fresh 20-question set in Week 77.
4. Log the score and the two topics you found hardest in the journal — these
   are the questions the defense panel is most likely to probe.

## Lab surface

```python
from decimal import Decimal
from tantra.portfolio_strategy import (
    build_portfolio_strategy, EqualWeight, TopN, momentum,
    MonthlyFirstSession, NamedUniverse,
)

strategy = build_portfolio_strategy(
    universe=NamedUniverse("NIFTY50"),
    selector=TopN(10, momentum),
    weighting=EqualWeight(),
    schedule=MonthlyFirstSession(),
)
print(strategy)   # the whole construction, declaratively
```

Read `tantra-examples/examples/12_portfolio_allocation.py`,
`mutual_funds/04_portfolio_optimization.py`, and
`portfolio_strategy/*` in the wheel for the complete API.

## Tantra Lab

### Lab goal

Build a **complete, runnable model portfolio** — the exact construction that
becomes your capstone — and prove the mandate choices are expressed in code, all
in Decimal.

### Code

```python
from decimal import Decimal
from tantra.portfolio_strategy import (
    build_portfolio_strategy, EqualWeight, TopN, momentum,
    low_volatility, MonthlyFirstSession, NamedUniverse,
    InverseVolatility, DriftBand,
)

# Primary capstone construction: momentum Top-10, equal weight,
# rebalanced on the first session of every month
strategy = build_portfolio_strategy(
    universe=NamedUniverse("NIFTY50"),
    selector=TopN(10, momentum),
    weighting=EqualWeight(),
    schedule=MonthlyFirstSession(),
)
print(strategy)

# Comparison arm for the factor-choice memo (Module 2 deliverable):
# low-volatility Top-20, inverse-volatility weighted
risk_controlled = build_portfolio_strategy(
    universe=NamedUniverse("NIFTY50"),
    selector=TopN(20, low_volatility),
    weighting=InverseVolatility(),
    schedule=MonthlyFirstSession(),
)
print(risk_controlled)

# Drift-band schedule: rebuild only when weights drift outside the
# tolerance band, instead of on a fixed calendar date. Verified
# signature: DriftBand(tolerance: Decimal), e.g. tolerance=Decimal("0.10")
# meaning "rebuild when any weight is more than 10 points off target".
from tantra.portfolio_strategy import DriftBand  # already imported above
drift_controlled = build_portfolio_strategy(
    universe=NamedUniverse("NIFTY50"),
    selector=TopN(10, momentum),
    weighting=EqualWeight(),
    schedule=DriftBand(tolerance=Decimal("0.10")),
)
print(drift_controlled)
```

### Expected output

Two printed constructions, each spelling out the full declarative pipeline —
universe, selector, weighting, schedule — for the momentum and low-volatility
variants. The two comparison arms feed your factor-choice memo; the primary
construction is what the capstone's compliance memo walks through position by
position. The `DriftBand` variant is described in prose (and against the
`portfolio_strategy/*` examples) for the rebalancing-cost comparison, since the
cheat sheet verifies the name but not its constructor arguments.

### Hand-in checklist

- [ ] Primary construction printed and pasted into the capstone workbook.
- [ ] Momentum-vs-low-volatility comparison logged with the factor memo.
- [ ] Drift-band variant compared to monthly on rebalancing cost.
- [ ] Every weight/price in the position list confirmed `Decimal`.
- [ ] Journal entry: which mandate constraint each construction knob encodes.

### Common errors

- **Inventing imports** — use exactly the names above from
  `tantra.portfolio_strategy`; the wheel's `portfolio_strategy/*` examples show
  the only other verified uses.
- **Float weights** — weights come out of `Decimal`-typed bars; if any weight
  prints as a bare `0.1`, trace the import and re-run.
- **Confusing selector and weighting** — the selector *chooses which names*;
  the weighting *decides how much of each*. A `TopN`-selecting, momentum-weighted
  sentence in the memo is a sign you mixed the layers.

## Deliverables checklist

- [ ] Mandate document (objective, benchmark, risk budget, constraints).
- [ ] Universe + selection rule + weighting scheme + rebalance schedule, each with a written rationale.
- [ ] Runnnable `portfolio_strategy` construction printed and archived.
- [ ] Mandate-compliance memo (position-by-position).
- [ ] Performance report: Sharpe, alpha, attribution, max drawdown vs benchmark.
- [ ] Mock sprint score ≥ 75% logged in the journal.
- [ ] 15-minute defense recording + final workbook.

## Reading assignment

See the PM path in the [course reading list](../appendices/reading-list.md) —
the portfolio-theory, performance-evaluation, and SEBI PMS regulation texts map
directly to Modules 1–3 and to the compliance memo.

## Out the other side

- NISM exams passed → complete the degree requirement → PM registration path.
- Immediate support roles: portfolio operations, fund accounting, research support.
