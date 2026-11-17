# M10 — Regulatory Ecosystem & Ethics

> **Weeks 62–63 · 16 hrs · PLO-10 · Core:** NIFM Ch 39; CFTe II App F; PGP T3-303, T4-403

## Learning outcomes

- State SEBI's structure and the key regulations governing markets and analysts.
- Apply the analyst codes of conduct: RA, IA, PM.
- Identify conflicts of interest and insider-trading situations.
- Know the IFTA ethical and professional standards (CFTe II requirement).

## Prerequisites

- [S1-M10 regulators](../s1/m10-regulators-legal.md) (or equivalent): the regulator names and market structure basics — this module adds the *codes of conduct*.
- [M9](m9-research-report-writing.md): you have written a report that must now carry the required disclosures.
- The decision-gate idea from the Tantra stack: a compliant pipeline rejects un-approved actions before they execute.

## Lesson 10.1 — SEBI and the regulatory ecosystem

### 1) Concept

**SEBI** (Securities and Exchange Board of India) is the market regulator under the SEBI Act, with a mandate to protect investors, develop the market, and regulate it. It has three pillars of power: **quasi-legislative** (making regulations), **quasi-judicial** (adjudicating violations), and **quasi-executive** (investigating and enforcing). It registers and supervises every market participant — brokers, exchanges, research analysts, investment advisors, portfolio managers, mutual funds, and listed companies.

The regulations an analyst actually touches:

- **RA Regulations** (Research Analyst) — who may publish research and under what duties.
- **IA Regulations** (Investment Advisor) — who may advise on investments.
- **PM Regulations** (Portfolio Manager) — who may manage client portfolios.
- **PIT Regulations** (Prohibition of Insider Trading) — who may trade on what information, and when.
- **Listing Obligations and Disclosure Requirements (LODR)** — what listed companies must disclose to the market.

The ecosystem's logic: every party who touches investors is *registered*, and every registration carries a *code of conduct* with enforceable consequences. The "freedom" of markets is a freedom under rules — which is exactly the design of the Tantra stack's risk gates (Lab 10).

### 2) Worked example

A classification drill — which regulation governs each activity?

```
Publishing a stock research report            → RA Regulations
Advising a client on an equity portfolio       → IA Regulations
Running client money under a discretionary mandate → PM Regulations
Trading while holding a client's unpublished deal info → PIT Regulations
A listed company delaying a price-moving announcement → LODR
```

Each of the five maps to one regulation — the drill the compliance test in Lab 10 will repeat in story form.

```python
# Regulatory classification as data — map each activity to its regulation.
cases = {
    "research report": "RA",
    "investment advice": "IA",
    "portfolio management": "PM",
    "trading on unpublished info": "PIT",
    "delayed disclosure": "LODR",
}
print("matches:", len(cases), "of 5 classifications")
```

### 3) Common pitfalls

> **Pitfall:** Confusing RA and IA — research is *published for many readers*; advice is *given to a specific client*. Different regulations, different duties.
>
> **Pitfall:** Forgetting SEBI's three powers — remembering only "it makes rules" misses how it enforces them.
>
> **Pitfall:** Thinking PIT only covers directors — it covers anyone with UPSI, including analysts and even their relatives.
>
> **Pitfall:** Treating the ecosystem as a list to memorise — each regulation is a *code of conduct* for a specific role.

### 4) Key takeaways

- **Takeaway:** SEBI = protect, develop, regulate; with legislative, judicial, and executive powers.
- **Takeaway:** RA / IA / PM / PIT / LODR are the analyst-relevant regulations.
- **Takeaway:** Registration + code of conduct + enforcement is the ecosystem's logic.
- **Takeaway:** Every role has the regulation that governs it.

## Lesson 10.2 — The analyst codes

### 1) Concept

Each registration carries a **code of conduct**. The **Research Analyst (RA)** code is the analyst's own: *registration* before publishing; *disclosure* of any conflicts (holdings, relationships, compensation arrangements) in the report; no *front-running* (trading ahead of your own published recommendation); *fair dealing* (never mislead, never cherry-pick); and *record keeping* (support for every claim, exactly the M9 data-accuracy rule made legal).

The **Investment Advisor (IA)** code centres on *suitability*: advice must fit the client's risk profile and goals, fees must be disclosed, and the client's interests come first. The **Portfolio Manager (PM)** code centres on *mandate and separation*: manage within the agreed mandate, report performance truthfully, and keep client funds **segregated** from the manager's own money.

The three codes share a backbone: *disclose, don't front-run, put the client first, and keep records*. A research report that fails the RA disclosures is not just bad writing — it is a *regulatory breach*. This is why the M9 report template carries the disclosure block: the disclosure is the report's legal spine.

### 2) Worked example

A disclosure drill: an analyst publishes a BUY on RELIANCE while holding the stock.

```
Required disclosure (RA): "The analyst and/or related entities hold a position
in RELIANCE. This report is for information purposes and is not investment
advice."  → Conflict stated, not hidden.
Forbidden behaviour: buying more *before* the report goes out (front-running),
or publishing the BUY to exit a personal position (manipulation).
```

The holding is not illegal; the *undisclosed* holding and the *front-running* are.

```python
# Compliance boolean: a report may carry a holding, but only with disclosure.
holding = True
disclosed = True
front_running = False
ok = disclosed and not front_running
print("compliant:", ok)   # True — disclosure + no front-running
```

### 3) Common pitfalls

> **Pitfall:** Believing a conflict itself is the violation — it is the *undisclosed* conflict that breaches the code.
>
> **Pitfall:** Treating "I didn't trade on it" as sufficient — the RA code requires *disclosure* regardless of trading.
>
> **Pitfall:** Advising like an IA without IA registration — suitability duties attach to the *role*, not the title.
>
> **Pitfall:** Co-mingling client and own funds (PM) — segregation is the code's hard rule.

### 4) Key takeaways

- **Takeaway:** RA code: register, disclose conflicts, no front-running, fair dealing, keep records.
- **Takeaway:** IA code: suitability, fee disclosure, client-first.
- **Takeaway:** PM code: mandate, truthful reporting, segregated funds.
- **Takeaway:** The common backbone: disclose, don't front-run, client first, keep records.

## Lesson 10.3 — Insider trading basics

### 1) Concept

**Insider trading** is trading on, or *tipping others to*, **UPSI — Unpublished Price Sensitive Information**: material information that is not yet public, such as quarterly results, mergers, buybacks, or major orders. The logic of **PIT** is simple: the market should price *public* information; anyone trading on private price-sensitive information is stealing from everyone else who cannot.

The operational rules: companies maintain a **trading window** (typically closed from the end of the quarter until results are announced); **designated persons** (directors, key employees — and their relatives) may trade only in the open window and only with pre-clearance. Analysts face the code's "don't" list: no trading on UPSI, no *tipping* (telling anyone else — **tipping is insider trading too**, even if the tipper does not trade), and no recommending while holding undisclosed positions. When a company announces results, the information becomes *published* — only then does it become tradable. The boundary in practice: "would a reasonable investor consider this price-sensitive?" If yes and it is not public, it is UPSI.

### 2) Worked example

A scenario test: an analyst learns (privately) that a client company's results beat estimates by 20%, to be announced in three days.

```
Is it UPSI?  Yes — material (20% beat) and unpublished.
May the analyst buy the stock today?   No.
May the analyst tell a friend to buy?  No — tipping is itself the offence.
When may the analyst act?              After the results are published to the
                                       market, when the information is no
                                       longer unpublished.
```

The three answers are the PIT test in miniature.

```python
public = False          # results not yet announced
material = True         # 20% earnings beat
upsi = material and not public
trade_ok = public       # only public information is tradable
print("UPSI:", upsi)    # True
print("may trade:", trade_ok)   # False
```

### 3) Common pitfalls

> **Pitfall:** Thinking only the trader is guilty — the *tipper* is guilty too, whether or not anyone traded.
>
> **Pitfall:** Trading "just after the call, before the announcement" — if the information is not public, it is UPSI.
>
> **Pitfall:** Forgetting relatives — the code's designated-person net includes them.
>
> **Pitfall:** Assuming "materiality" is legalese — the practical test: would a reasonable investor consider it price-sensitive?

### 4) Key takeaways

- **Takeaway:** UPSI = material + unpublished; trading on it is insider trading.
- **Takeaway:** Tipping is insider trading even with no trade.
- **Takeaway:** Trading windows and pre-clearance govern designated persons.
- **Takeaway:** The boundary: published = tradable; unpublished + material = off-limits.

## Lesson 10.4 — Conflicts of interest

### 1) Concept

A **conflict of interest** arises when your incentives point one way and your client's interest points another: a broker whose research desk rates the stocks its trading desk wants to sell; an analyst holding the stock they recommend; an advisor paid more for one product. Conflicts cannot be eliminated — every market participant has them. They are *managed*, and the management tool is **disclosure**.

The golden rule: **disclose everything a reasonable reader would want to know.** For the research report: the analyst's and the firm's holdings in the covered stock, any underwriting or advisory relationship with the issuer, and the compensation structure. The reader cannot evaluate a recommendation without knowing who benefits from it. After disclosure, the code adds conduct duties: no front-running (Lesson 10.2), no publishing to benefit a personal position, and fair dealing with all readers equally. The test for a report: *would the reader change their mind if they knew the conflict?* If yes, the conflict is material, and the disclosure must make it visible.

### 2) Worked example

Three disclosure drills for a RELIANCE report:

```
Analyst holds the stock                → disclose the position in the report.
Firm recently advised RELIANCE         → disclose the relationship.
Compensation partly tied to deal fees  → disclose the arrangement.
```

Any one alone is manageable; all three *undisclosed* is a breach of the RA code and of the reader's trust.

```python
# Materiality test in code: would the reader's view change with the fact?
def material(fact_unknown_to_reader):
    return fact_unknown_to_reader
print("holding must be disclosed:", material(True))      # True
print("deal relationship:", material(True))              # True
print("fee structure:", material(True))                  # True
```

### 3) Common pitfalls

> **Pitfall:** Treating "I don't personally benefit" as no conflict — the *firm's* interests and the *perception* matter too.
>
> **Pitfall:** Disclosing in tiny print — the disclosure must be where the reader looks (the M9 report template puts it with the thesis).
>
> **Pitfall:** Confusing disclosure with permission — disclosed conflicts still prohibit front-running and manipulation.
>
> **Pitfall:** Hiding a conflict "because it is small" — materiality is judged from the reader's side.

### 4) Key takeaways

- **Takeaway:** Conflicts are managed by disclosure, not eliminated.
- **Takeaway:** Golden rule — disclose what a reasonable reader would want to know.
- **Takeaway:** Disclosure does not authorise front-running or manipulation.
- **Takeaway:** Materiality is judged from the reader's side of the table.

## Lesson 10.5 — IFTA ethics (CFTe II App F)

### 1) Concept

The **IFTA** (International Federation of Technical Analysts) code — examined in CFTe II Appendix F — states the professional standards that apply to a *technical* analyst's chart calls and subscription products. Its pillars: **professional integrity** (never misrepresent results), **competence** (only claim skill you can defend), **objectivity** (report what the chart shows, not what you want it to show), **confidentiality** (protect client and proprietary information), and **fair dealing** (treat all subscribers alike — no "better" calls for preferred clients).

Applied to this course's context, two practices matter most. A chart call must carry its **invalidation level** — the level at which the analyst is objectively wrong (the S4-M7 stop logic is the same discipline). A subscription product must be *honest about performance*: no cherry-picked winners, no unaudited "98% success" claims; present the full track record, because a technical analyst's claims are testable data. The IFTA code is the S4-M7 risk discipline restated in ethics: write the bear case, disclose the record, be wrong gracefully and early.

### 2) Worked example

A compliance test for a chart newsletter:

```
Claim: "This pattern has a 70% win rate."
Must the newsletter show the full tested track record?  Yes — wins, losses,
                                                        sample size, and the period.
Does the call carry an invalidation level?              Yes — where the thesis breaks.
Are all subscribers told the same thing at the same time?  Yes — fair dealing.
```

A "70% win rate" without the losing trades shown is a marketing claim, not a professional track record.

```python
# Track-record honesty: publish both sides of the sample.
wins, losses, sample = 7, 3, 10
print("win rate:", wins / sample)      # 0.7 — but 3 losses disclosed too
```

### 3) Common pitfalls

> **Pitfall:** Cherry-picking winners in a "track record" — the code requires the full record.
>
> **Pitfall:** Publishing a call without an invalidation level — that is a tip, not a professional call.
>
> **Pitfall:** Giving different subscribers different timing — fair dealing means equal service.
>
> **Pitfall:** Claiming competence beyond evidence ("guaranteed profits") — integrity forbids it.

### 4) Key takeaways

- **Takeaway:** IFTA pillars: integrity, competence, objectivity, confidentiality, fair dealing.
- **Takeaway:** A chart call carries its invalidation level.
- **Takeaway:** Track records show both sides of the sample.
- **Takeaway:** Ethics is the S4-M7 risk discipline applied to claims.

## Tantra Lab 10 — Compliance scenario sim

### Lab goal

See the "gate" pattern — the same design SEBI builds into market conduct and the Tantra stack builds into order flow — by running a decision through a risk gate and then working the 10-scenario compliance test.

### Code

The verified core snippet is unchanged (a gate pattern); the extension makes the Decision gate call concrete without inventing API surface.

```python
# Decision gate pattern: a compliant pipeline never ships an un-approved order.
# This is exactly what tantra.risk.RiskEngine does before an order reaches a broker.
from tantra import Decision, RiskEngine

engine = RiskEngine()
dec = Decision(...)   # fill with a closed Decision (deny_unknown_fields contract)
result = engine.evaluate(dec)  # RiskRefused if the decision fails a rule
print(result)

# --- extend: the compliance gate as a decision test -------------------------
# An approval gate: a recommendation may not proceed unless its disclosures pass.
def compliance_gate(has_disclosure, no_front_run, suited_to_client):
    return has_disclosure and no_front_run and suited_to_client

print("gate passes:", compliance_gate(True, True, True))    # True
print("gate blocks:", compliance_gate(True, False, True))   # False — front-running
```

**Task:** work the 10-scenario compliance test (conflicts, tipping, disclosure, suitability). Then read `tantra-examples/examples/strategies/04_risk_management.py` to see the risk gate applied to orders — the platform treats *untrusted input* (the same principle as SEBI treating an analyst's call as a recommendation with duties) as something that must pass a gate before action.

### Expected output

The RiskEngine snippet prints the evaluation result for the Decision you construct (RiskRefused when a rule fails). The extension prints `True`/`False` for the compliance gate: all three duties pass, or the gate blocks when any duty fails (e.g., front-running).

### Hand-in checklist

- [ ] RiskEngine decision gate run once with a closed Decision.
- [ ] All 10 compliance scenarios worked and graded.
- [ ] Every scenario mapped to its regulation (RA/IA/PM/PIT/LODR).
- [ ] Notes on how `strategies/04_risk_management.py` gates orders.
- [ ] One paragraph: where the gate pattern appears in SEBI's ecosystem vs the Tantra stack.

### Common errors

- **`Decision(...)` left as a stub** — the ellipsis is a placeholder; construct a real closed Decision per the deny_unknown_fields contract before running.
- **Mixing RA and IA duties** — publishing ≠ advising; the scenario's role decides the code.
- **Failing the tip test** — a scenario where the trader tells a friend is a PIT violation even with zero trades.
- **Gate logic inverted** — the gate passes only when *all* duties hold; a single False blocks.

## Practice problems

1. Name SEBI's three powers and give one example of each.
2. Which regulation governs each: (a) publishing research, (b) advising a client, (c) discretionary portfolio management, (d) trading on unpublished results?
3. An analyst holds RELIANCE and publishes a BUY. What must the report contain, and what may the analyst NOT do around publication?
4. Is tipping someone who then trades insider trading? What if the friend does not trade?
5. What makes information UPSI? Give two examples.
6. Define the golden rule of conflicts and apply it to a broker-owned research house.
7. List the five IFTA ethical pillars and show one application to a chart newsletter.
8. (Short code) Using the `compliance_gate` pattern from Lab 10, evaluate: disclosed holding, no front-running, but the client's risk profile says conservative while the product is aggressive. What does the gate output?

### Solutions

1. Quasi-legislative (making regulations), quasi-judicial (adjudicating violations), quasi-executive (investigating/enforcing). Examples vary: the RA Regulations, an adjudication order, a search-and-seizure inspection.
2. (a) RA, (b) IA, (c) PM, (d) PIT.
3. Disclose the holding in the report; may not front-run (trade ahead of publication) or manipulate the call to benefit the personal position.
4. Yes — tipping is insider trading whether or not the recipient trades; the tipper is liable even with zero trades.
5. Information is UPSI when it is *material* and *unpublished*; examples: an unreleased quarterly result, an announced-but-not-yet-public merger.
6. Disclose everything a reasonable reader would want to know; a broker-owned research house must disclose the ownership/relationship and any dealing relationships with covered issuers.
7. Integrity, competence, objectivity, confidentiality, fair dealing — e.g., the newsletter must show the full track record (integrity), state the invalidation level (objectivity), and serve all subscribers equally (fair dealing).
8. The gate output is `False`: the suitability duty fails (aggressive product for a conservative client), so the recommendation is blocked.

## Quiz bank

| Question | A | B | C | D | Answer |
|---|---|---|---|---|---|
| SEBI's mandate includes | protecting investors | setting tax rates | printing currency | fixing wages | A |
| Publishing a research report is governed by | IA Regs | RA Regs | PM Regs | LODR | B |
| Client suitability is the core of the | RA code | IA code | PIT code | IFTA only | B |
| Fund segregation is required of | RAs | IAs | PMs | exchanges | C |
| UPSI means information that is | material and published | material and unpublished | small and public | old and public | B |
| Tipping someone who then trades is | legal | insider trading | only a fine | only SEBI's problem | B |
| Trading windows are closed | after results | from quarter-end to announcement | on weekends | on Mondays | B |
| A conflict of interest is managed by | hiding it | disclosure | denial | switching brokers | B |
| The golden rule of disclosure asks | what would SEBI want | what a reasonable reader would want to know | what the analyst wants | what the client wants to hear | B |
| Front-running means | trading ahead of your own recommendation | trading after results | hedging | covering shorts | A |
| Which is an IFTA pillar? | integrity | leverage | speed | secrecy | A |
| A chart call must carry | an invalidation level | a guarantee | a logo | a disclaimer only | A |
| A track record should show | only winners | both wins and losses | only the period | only the sample | B |
| The Tantra RiskEngine gate mirrors | SEBI's conduct gate | an Excel table | a broker's desk | a bank | A |

## Glossary

- **SEBI** — the market regulator; protect, develop, regulate.
- **RA Regulations** — code of conduct for research analysts.
- **IA Regulations** — code of conduct for investment advisors (suitability).
- **PM Regulations** — code of conduct for portfolio managers (mandate, segregation).
- **PIT** — Prohibition of Insider Trading regulations.
- **UPSI** — Unpublished Price Sensitive Information.
- **Tipping** — passing UPSI to anyone; an offence by itself.
- **Trading window** — the period when designated persons may trade (open) or may not (closed).
- **Conflict of interest** — incentives that diverge from the client's interest.
- **Front-running** — trading ahead of your own published recommendation.
- **Fair dealing** — equal, honest treatment of all clients/readers.
- **IFTA code** — integrity, competence, objectivity, confidentiality, fair dealing.
- **Risk gate** — a mandatory check that blocks non-compliant actions (SEBI conduct, or `RiskEngine` orders).

## Reading assignment

Study NIFM Chapter 39 (regulatory ecosystem and ethics), CFTe II Appendix F (IFTA professional standards), and PGP T3-303/T4-403 in the [reading list](../appendices/reading-list.md). Skim the actual RA and PIT regulation texts on the SEBI website to connect the rules to their source.

## Assessment reminder

This module feeds the compliance scenario test (10 scenarios) and the regulator/codes/insider-trading quiz; the disclosures you learn here must also appear in your M9 report, so treat this module's checklist as part of the programme gate under the [assessment plan](../front/assessment.md).

**Next:** [M11 — NISM XV Mock Sprint & Final Exams](m11-nism-sprint.md)
