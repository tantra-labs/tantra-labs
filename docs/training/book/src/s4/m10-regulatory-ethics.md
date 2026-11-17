# M10 — Regulatory Ecosystem & Ethics

> **Weeks 62–63 · 16 hrs · PLO-10 · Core:** NIFM Ch 39; CFTe II App F; PGP T3-303, T4-403

## Learning outcomes

- State SEBI's structure and the key regulations governing markets and analysts.
- Apply the analyst codes of conduct: RA, IA, PM.
- Identify conflicts of interest and insider-trading situations.
- Know the IFTA ethical and professional standards (CFTe II requirement).

## Lesson 10.1 — SEBI and the regulatory ecosystem

- SEBI's mandate and structure; powers under SEBI Act.
- Regulations that matter: RA Regulations, IA Regulations, PM Regulations,
  PIT (Prohibition of Insider Trading), Listing Obligations.

## Lesson 10.2 — The analyst codes

- **Research Analyst (RA):** registration, disclosure of conflicts, no
  front-running, fair dealing, record keeping.
- **Investment Advisor (IA):** suitability, fee disclosure, client suitability.
- **Portfolio Manager (PM):** mandate, reporting, segregation of funds.

## Lesson 10.3 — Insider trading basics

- UPSI (Unpublished Price Sensitive Information); trading window; codes of
  conduct; the "don't" list.
- Tipping is insider trading too.

## Lesson 10.4 — Conflicts of interest

- Brokerage + research conflicts; holding disclosure in the report.
- The golden rule: disclose everything a reasonable reader would want to know.

## Lesson 10.5 — IFTA ethics (CFTe II App F)

- Professional integrity, competence, objectivity, confidentiality,
  fair dealing.
- Applied to a technical analyst's chart calls and subscriptions.

## Tantra Lab 10 — Compliance scenario sim

```python
# Decision gate pattern: a compliant pipeline never ships an un-approved order.
# This is exactly what tantra.risk.RiskEngine does before an order reaches a broker.
from tantra import Decision, RiskEngine

engine = RiskEngine()
dec = Decision(...)   # fill with a closed Decision (deny_unknown_fields contract)
result = engine.evaluate(dec)  # RiskRefused if the decision fails a rule
print(result)
```

**Task:** work the 10-scenario compliance test (conflicts, tipping, disclosure,
suitability). Then read `tantra-examples/examples/strategies/04_risk_management.py`
to see the risk gate applied to orders — the platform treats *untrusted input*
(the same principle as SEBI treating an analyst's call as a recommendation with
duties) as something that must pass a gate before action.

## Assessment

- Compliance scenario test (10 scenarios).
- Quiz: regulator names, codes, insider-trading rules.

**Next:** [M11 — NISM XV Mock Sprint & Final Exams](m11-nism-sprint.md)
