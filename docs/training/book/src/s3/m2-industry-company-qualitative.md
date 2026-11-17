# M2 — Industry & Company Qualitative Analysis

> **Weeks 35–37 · 20 hrs · PLO-5, PLO-6 · Core:** NIFM Ch 18, 20, 32, 33; IFMC items 8, 17–18, 25, 33, 43

## Learning outcomes

- Run a **top-down** (macro → industry → company) and **bottom-up** (company →
  industry) analysis.
- Apply Porter's five forces and the industry life cycle.
- Assess management quality, governance, brand, and moats qualitatively.
- Read MD&A and Directors' Report; analyse an IPO via its DRHP.
- Use the **CANSLIM** framework as a selection screen.
- Translate qualitative judgements into a checklist you can score, so the
  qualitative memo feeds the quantitative model in M8.

## Prerequisites

- [M1 — Economics for Securities Markets](m1-economics.md): the top-down layer —
  this module's Lesson 2.1 starts from M1's macro indicators.
- [S1-M5 — Instruments](../s1/m5-instruments.md): shares, boards, and the
  annual-report documents this module dissects.
- [S1-M7 — Financial statements](../s1/m7-financial-statements.md):
  banking-specific terms (NIM, NPA, CAR) you will need when analysing a bank's
  moat.
- [S1-M3 — Markets](../s1/m3-markets.md): who buys and sells, so the
  "institutional sponsorship" leg of CANSLIM makes sense.

## Lesson 2.1 — Top-down vs bottom-up

### 1) Concept

**Top-down** analysis moves from the economy to the industry to the stock:
M1's macro view (GDP, repo rate, inflation) → the sectors that benefit → the
best company in those sectors. Example: repo-rate cuts are expected → housing
finance and auto demand benefit → you screen for the best NBFC/auto franchise.
**Bottom-up** analysis inverts it: you find a brilliant company first (great
management, rising market share) and treat the macro as context that determines
*when* to buy. Example: you find a niche pharma exporter growing 25% a year and
wait for a macro sell-off to enter cheaply.

Both are valid and they answer different questions. Top-down asks *"which
markets should I be in?"*; bottom-up asks *"which businesses are genuinely
good?"*. Practitioners blend them: top-down sets the sector bet, bottom-up picks
the name. In the research report you will write (S4-M9) you will be expected to
show both directions and then reconcile them.

A stock price = the market's view of (business quality) × (industry
attractiveness) × (macro conditions). Ignore any one of the three and your
analysis is incomplete. Top-down analysis protects you from buying the best
company in a dying industry; bottom-up analysis protects you from buying the
worst company in a fashionable one.

### 2) Worked example

Score a hypothetical stock on three qualitative axes to see how the two lenses
combine. The exercise is to *formalise* the judgement, not to compute anything
deep — scores 1 (poor) to 5 (excellent), all in `Decimal`.

```python
from decimal import Decimal
axes = {
    "macro (top-down)":      Decimal("2"),   # rising rates hurt the sector
    "industry (Porter)":     Decimal("4"),   # high barriers, low rivalry
    "company (bottom-up)":   Decimal("5"),   # best-in-class margins
}
weighted = (axes["macro (top-down)"] + axes["industry (Porter)"]
            + axes["company (bottom-up)"]) / Decimal("3")
print("Composite qualitative score:", weighted)
```

Answer: 3.67/5. The company is excellent but the macro is against it — the
analyst's job is to state *which* factor dominates and why, not just average
the numbers. A bottom-up investor might buy; a top-down investor might wait for
the rate cycle to turn.

### 3) Common pitfalls

> **Pitfall:** Letting a macro headline override a genuinely great company, or
> vice versa — the two lenses answer different questions and must be kept
> separate in your memo. Scoring with `float` instead of `Decimal` in any
> quantitative follow-up. And writing "top-down" and "bottom-up" as buzzwords
> without ever connecting the macro to a specific P&L line.

### 4) Key takeaways

- **Takeaway:** Top-down = macro → sector → stock; bottom-up = company quality
  first, macro as timing context.
- **Takeaway:** The research report blends both and states the dominant factor.
- **Takeaway:** Qualitative judgements should be scored so they can be tracked
  and debated.

## Lesson 2.2 — Industry analysis

### 1) Concept

Industries live a **life cycle**: **emerging** (small, unproven demand, losses;
think EV two decades ago) → **growth** (fast expansion, winners emerge; e.g.,
quick commerce) → **mature** (slow growth, consolidation, dividends; e.g.,
Indian steel, FMCG) → **declining** (shrinking demand; e.g., film roll/CRT-era
industries). Valuation and capital allocation differ by stage: growth companies
eat cash, mature ones return it.

**Porter's five forces** is the standard map of industry attractiveness:

1. **Rivalry among existing players** — many equal-sized competitors + slow
   growth = price wars (commodity cement) vs cosy oligopoly (some branded FMCG).
2. **Threat of new entrants** — high barriers (licences, capital, brand) protect
   incumbents; low barriers attract disruption.
3. **Threat of substitutes** — what else does the customer buy instead? Video
   streaming replaced DTH for many; railways substitute for trucking on long
   hauls.
4. **Bargaining power of suppliers** — few powerful suppliers squeeze industry
   margins (rare-earth metals for EV batteries).
5. **Bargaining power of buyers** — concentrated powerful buyers squeeze margins
   (auto OEMs squeezing small component suppliers).

An industry where all five forces are weak is structurally profitable (classic:
branded cigarettes/consumer monopolies). An industry where several are strong
(airlines — brutal rivalry, powerful suppliers, substitute travel modes) is a
value trap for equity even in a growing economy.

Finally, position in the **economic cycle**: **cyclicals** (autos, metals,
capital goods, banks) ride the boom-bust; **defensives** (FMCG, pharma,
healthcare) keep earnings steadier. Your M1 business-cycle reading decides which
group to overweight.

### 2) Worked example

Score an industry on Porter's five forces (1 = weak force, favourable; 5 = strong
force, unfavourable) and read the average:

```python
from decimal import Decimal
forces = {"rivalry": Decimal("2"), "entrants": Decimal("3"),
          "substitutes": Decimal("4"), "suppliers": Decimal("2"),
          "buyers": Decimal("4")}
avg = sum(forces.values()) / Decimal(len(forces))
print("Average force score:", avg, "(< 3 favourable, > 3 unfavourable)")
```

Answer: 3.0 — a *mediocre* industry. Substitutes (4) and buyers (4) are the
pressure points. A company in this industry must win on cost or brand to earn
above-average returns despite the industry. That sentence — industry score →
company strategy → margin — is the bridge to Lesson 2.3.

### 3) Common pitfalls

> **Pitfall:** Forgetting that substitutes are a separate force from rivalry —
> DTH providers competed fiercely with each other *and* were killed by
> streaming. Calling an industry "good" because demand grows — airlines grew
> for decades and destroyed value. And scoring forces without saying *who* the
> supplier/buyer is.

### 4) Key takeaways

- **Takeaway:** Life cycle stage decides whether the industry returns cash or
  consumes it.
- **Takeaway:** Five forces map structural profitability; weak forces = good
  industry.
- **Takeaway:** Cyclical vs defensive position follows the M1 business-cycle
  reading.

## Lesson 2.3 — Company qualitative dimensions

### 1) Concept

With the industry understood, assess the *firm*:

**Business model clarity** — can you explain in two sentences how the company
makes money? If you cannot, the analyst cannot value it. **Revenue
diversification** — concentration in one client/product/country is a risk;
spread is a cushion (an auto-ancillary earning 70% from one OEM lives at that
OEM's mercy).

**Moat** — the durable edge that keeps rivals out:

| Moat source | Example |
|---|---|
| Cost advantage | Large integrated steel plants, scale FMCG |
| Brand | Titan, Asian Paints pricing power |
| Network effects | Payment rails, marketplaces |
| Switching costs | ERP software, bank core systems |
| Regulatory licence | Defence, exchanges, banking licences |

A moat shows up *quantitatively* as consistently above-average ROE/margins at
stable or growing market share — Lesson 4.2's DuPont will check exactly this.

**Management** — track record of delivery, **capital allocation** (are profits
reinvested at good returns or frittered into unrelated diversifications?),
stewardship of minority shareholders, and honest communication. **Governance red
flags**: related-party deals, promoter pledging, auditor resignations, frequent
board departures, opacity in the notes. **ESG** is the emerging fourth lens —
environmental liabilities, employee relations, and governance are increasingly
priced by both lenders and equity investors.

### 2) Worked example

Two companies earn the same ROE today. The qualitative difference is the *source
of the moat*: one holds margin through brand, the other through a single
regulated licence. Score durability (1–5) and concentration risk (1–5):

```python
from decimal import Decimal
brand_co = {"moat_durability": Decimal("4"), "concentration_risk": Decimal("2")}
licence_co = {"moat_durability": Decimal("5"), "concentration_risk": Decimal("5")}
for name, s in (("BrandCo", brand_co), ("LicenceCo", licence_co)):
    net = s["moat_durability"] - s["concentration_risk"]
    print(name, "durability net score:", net)
```

Answer: BrandCo 2, LicenceCo 0. LicenceCo's moat is *complete but fragile* —
one regulatory change and it is gone. Brand moats erode slowly; licence moats
can vanish overnight. Qualitative analysis is precisely about grading *durability
minus fragility*.

### 3) Common pitfalls

> **Pitfall:** Equating a moat with a *momentary* high margin — margin must be
> durable *and* defensible; commodity prices can inflate a cyclical's margin for
> a year. Ignoring promoter pledging in the annual report's disclosures.
> Confusing ESG scoring with a licence to ignore the first three lenses.

### 4) Key takeaways

- **Takeaway:** A moat is durable only if its source is checked against rivals.
- **Takeaway:** Management quality = delivery + capital allocation + governance
  honesty.
- **Takeaway:** Score durability minus fragility; never take a margin at face
  value.

## Lesson 2.4 — MD&A & Directors' Report

### 1) Concept

The **MD&A (Management Discussion & Analysis)** and the **Directors' Report**
are the narrative halves of the annual report. The MD&A covers industry
outlook, operations, financial performance, risks, and internal controls. The
Directors' Report covers governance: board changes, dividends, related-party
transactions, and compliance. Together they are *management's story* about the
year.

The analyst's discipline: **management says vs the numbers show**. Every
claim — "market share improved", "cost leadership intact", "receivables
collection stable" — must be checked against the financial statements you will
dissect in M3. Rising receivables while management praises collections? Red
flag. Flat market share claimed while a rival's volume grew? Cross-check against
industry data.

The **DRHP (Draft Red Herring Prospectus)** is the IPO equivalent: the document
a company files with SEBI before listing. Its **Risk Factors** section is the
most honest reading in finance — SEBI-mandated, it forces the company to state
its weaknesses: customer concentration, promoter pledging, litigation, raw
material dependence, related-party reliance. Analysts read the DRHP backwards:
start with risks, then business, then financials, and check that management's
growth story survives contact with the risk list. The **RHP (Red Herring
Prospectus)** is the final version with the price band.

### 2) Worked example

Extract two claims from a mock MD&A and check them with simple arithmetic:

```python
from decimal import Decimal
# Claim 1: "receivables under control" — but DSO (debtor days) rose
revenue = Decimal("1_200_000")
receivables_0, receivables_1 = Decimal("90_000"), Decimal("150_000")
dso = receivables_1 / (revenue / Decimal("365"))
print("Debtor days (this year):", dso.quantize(Decimal("0.1")))
# Claim 2: "market share stable" — but sales grew 4% in a 12% market
company_growth = Decimal("0.04"); market_growth = Decimal("0.12")
share_change = (Decimal(1) + company_growth) / (Decimal(1) + market_growth) - Decimal(1)
print("Market-share change:", (share_change * 100).quantize(Decimal("0.01")), "%")
```

Answer: debtor days jumped from ~27 to ~46 — the "under control" claim fails.
Market share fell ~7.1% — the "stable" claim fails. Two sentences from the MD&A,
two red flags, zero deep valuation needed. This cross-check *is* Lesson 2.4.

### 3) Common pitfalls

> **Pitfall:** Reading the MD&A for what it *claims* rather than what it
> *verifies*. Treating a 100-page DRHP as something to skim — the Risk Factors
> and Related-Party Transactions sections deserve the most time. Believing
> "market share stable" without computing share change (growth minus market
> growth).

### 4) Key takeaways

- **Takeaway:** MD&A is a claim to verify against M3 statements, never a fact.
- **Takeaway:** DRHP risk factors are the honest pages; read them first.
- **Takeaway:** DSO and share-change arithmetic are the quickest cross-checks.

## Lesson 2.5 — CANSLIM (O'Neil)

### 1) Concept

**CANSLIM**, from William O'Neil's *How to Make Money in Stocks*, combines
fundamentals with price behaviour as a *selection screen* — it finds candidate
stocks, it does not value them:

- **C — Current quarterly earnings:** up strongly YoY (O'Neil: +20%+).
- **A — Annual earnings growth:** several years of rising EPS (25%+).
- **N — New:** new products, new management, *or new highs* — buyers pay up for
  novelty.
- **S — Supply/demand:** low float relative to demand; high ownership.
- **L — Leader or laggard:** buy the leader in the group, not the laggard
  (strongest relative strength).
- **I — Institutional sponsorship:** accumulation by mutual funds/FIIs.
- **M — Market direction:** stay out in a bear market even with great stocks —
  the "M" governs all the others.

Use CANSLIM as a *screen*: it tells you *what to look at* (strong recent
earnings, new highs, leadership), not *how much to pay*. Every candidate that
passes the screen then gets M2 qualitative work and the M3–M7 quantitative
work. Screens find candidates; analysis picks investments.

### 2) Worked example

Encode the "C" and "L" checks with the Tantra data helpers — the same pattern
the multibagger screener uses:

```python
from tantra_examples import SampleInstruments, synthetic_bars
bars = synthetic_bars(SampleInstruments.NIFTY50, days=250, seed=42)
# C: is the latest close above the level 10 sessions ago (momentum proxy)?
latest = bars[-1].close
ten_back = bars[-11].close
c_check = latest > ten_back
# L: is the stock near its own recent high (leader behaviour)?
recent_high = max(b.close for b in bars[-40:])
l_check = latest >= recent_high * Decimal("0.95")
print("C (momentum up):", c_check, "| L (near recent high):", l_check)
```

Answer: both booleans print — a quick, mechanical pass/fail for two CANSLIM
letters. The real screen (`screening/01_multibagger_screener.py`) combines more
letters and fundamental filters; your job is to *read* how each line encodes a
rule.

### 3) Common pitfalls

> **Pitfall:** Buying a "new high" stock without the "M" check — in a falling
> market, breakouts fail. Screening with raw `float` prices. Treating CANSLIM
> as a valuation method (it has no price target) or as a fundamental analysis
> (it has no balance-sheet work).

### 4) Key takeaways

- **Takeaway:** CANSLIM screens candidates on earnings + price leadership +
  market direction.
- **Takeaway:** Screen first, then apply M2 qualitative and M3–M7 quantitative
  work.
- **Takeaway:** "M" is the override: in a bear market, even a great "CANSL" is
  not bought.

## Tantra Lab 2 — A CANSLIM-style screen

### Lab goal

Prove you can encode a mechanical selection rule ("near recent highs" +
"20-day momentum") in `Decimal` on a synthetic index series — the same shape of
rule that a real CANSLIM/multibagger screen applies to the market.

### Code

```python
# This is the structure of tantra-examples/examples/screening/01_multibagger_screener.py
# Run it and read how screens encode "new highs + earnings growth" style rules.

from tantra_examples import SampleInstruments, synthetic_bars

bars = synthetic_bars(SampleInstruments.NIFTY50, days=250, seed=42)
recent = bars[-20:]
high = max(b.close for b in recent)
prev = bars[-21].close
print("near-52w-high test:", recent[-1].close >= high * 0.9, "20d return:", (recent[-1].close - prev) / prev)
```

**Task:** write a 2-page qualitative memo on a listed company of your choice:
business, industry forces, moat, management, governance, and risks. Run the
multibagger screener and screen 5 companies, then shortlist 1 for the S3-M8 model.

### Expected output

```
near-52w-high test: True
20d return: 0.01…
```

The "near-52w-high test" prints `True`/`False` — whether the latest close is
within 10% of the 20-day high. The 20-day return is a `Decimal` (roughly ±0.02);
a positive value means the stock has momentum. The exact numbers depend on the
seed-42 series; what matters is that the output is *interpretable* as a screen
verdict.

### Hand-in checklist

- [ ] Screener output (both lines) pasted in the journal with a one-line
      interpretation of each verdict.
- [ ] The real multibagger screener
      (`tantra-examples/examples/screening/01_multibagger_screener.py`) run, and
      its top 5 names recorded.
- [ ] 2-page qualitative memo: business model, Porter's five forces, moat
      source, management/governance, risks.
- [ ] 5 companies screened, 1 shortlisted, with the shortlist reason stated in
      one sentence.

### Common errors

- **Error:** using `recent[-1].close >= high * 0.9` where `high * 0.9` is
  Python-float — with `Decimal` closes this mixes types and raises
  `TypeError`; write `Decimal("0.9")` if you rebuild the line.
- **Error:** indexing `bars[-21]` off-by-one — with 250 bars the 21st-from-last
  exists, but if you trim `recent` to 10 bars first, `bars[-21]` still refers to
  the *original* list; keep the two windows separate.
- **Error:** running the screener script from the wrong directory so the example
  path is not importable — run from the `tantra-examples` repo root.

## Practice problems

1. Classify each statement as top-down or bottom-up: (a) "repo cuts will help
   NBFCs, I'll buy the best NBFC"; (b) "this pharma company compounds at 25%,
   I'll wait for a dip"; (c) "Nifty is overvalued, reduce everything".
2. Rank the five Porter forces from strongest to weakest for (a) Indian
   scheduled airlines and (b) branded FMCG (HUL, Nestlé). Give one reason per
   force.
3. A company claims "market share stable" while its sales grow 8% in a market
   growing 15%. Compute the share change.
4. Name the moat source for: Titan, Asian Paints, HDFC Bank, Infosys, IRCTC.
   For each, one sentence on how the moat could be eroded.
5. From the MD&A claim "receivables are under control", given revenue
   ₹900,000 and receivables ₹120,000, compute debtor days. If receivables were
   ₹180,000, what do you conclude?
6. In CANSLIM, why is "M" described as the override? Give a two-sentence
   example of a stock failing the M test.
7. Explain why a mature industry like steel often returns cash as dividends
   while a growth industry like quick commerce burns it.
8. List four governance red flags an analyst looks for in a Directors' Report
   or DRHP, and what you would do before buying despite one of them.

### Solutions

1. (a) top-down, (b) bottom-up, (c) top-down (macro). The memo should blend
   (a)+(b): sector bet from macro, name from company quality.
2. (a) Airlines: rivalry very high, buyers moderate (price-sensitive), suppliers
   high (two aircraft duopolists), entrants moderate-high, substitutes high
   (trains, video calls) → structurally poor. (b) FMCG: rivalry low-moderate
   (brand oligopoly), buyers weak (fragmented), suppliers weak (many),
   entrants low (distribution+brand), substitutes low-moderate → structurally
   excellent. This is why FMCG trades at high multiples.
3. Share change = (1.08/1.15) − 1 ≈ −6.1%. The claim fails.
4. Titan — brand; Asian Paints — brand + distribution; HDFC Bank — brand +
   switching costs (deposit franchise) + scale; Infosys — switching costs +
   client relationships; IRCTC — regulatory licence. Erosion: brand fade,
   competitor innovation, regulatory change, attrition to new models, licence
   revoked.
5. DSO = 120,000 / (900,000/365) ≈ 48.7 days; at 180,000 → ≈ 73 days — the
   "under control" claim fails; receivables are growing faster than sales.
6. "M" gates everything: in a bear market even a stock making new highs usually
   fails (new highs don't hold). Example: a leader breaks out at ₹200 in a
   falling Nifty, the breakout fails, price revisits ₹160 — the M test would
   have kept you out.
7. Mature industries have no profitable reinvestment scale — paying dividends
   is the efficient capital-allocation choice; growth industries reinvest every
   rupee because returns on new capacity are high and the market prices growth.
8. Red flags: related-party sales/loans, promoter share pledging, auditor
   qualification/resignation, frequent board changes, restated results. Before
   buying despite one, quantify it: size of the related-party revenue, pledging
   %, and the governance history — then only proceed with a compensating
   valuation margin.

## Quiz bank

| Question | A | B | C | D | Answer |
|---|---|---|---|---|---|
| "Macro → sector → stock" describes… | Bottom-up | Top-down | CANSLIM | DCF | B |
| Porter's forces are used to judge… | Management honesty | Structural industry profitability | Dividend policy | Beta | B |
| A strong force for industry profitability is… | High rivalry | Weak buyers | Powerful suppliers | Many substitutes | B |
| Which moat source erodes fastest in a regulatory change? | Brand | Cost | Licence | Network | C |
| DSO = 60 with revenue 730 means receivables ≈… | 60 | 120 | 730 | 6 | B |
| The DRHP's most honest section is… | Business overview | Risk factors | Auditor report | Cover page | B |
| "C" in CANSLIM stands for… | Cost | Current quarterly earnings | Capital | Cash flow | B |
| Which CANSLIM letter overrides all others? | C | A | M | I | C |
| A market share change of (1.10/1.20) − 1 means… | +10% share | −8.3% share | No change | +20% share | B |
| ESG is best treated as… | A replacement for moats | A fourth qualitative lens | A trading signal | A valuation method | B |

## Glossary

- **Top-down analysis** — macro → industry → stock selection order.
- **Bottom-up analysis** — company quality first; macro only as timing context.
- **Industry life cycle** — emerging → growth → mature → declining; each stage
  has distinct cash and valuation behaviour.
- **Porter's five forces** — rivalry, entrants, substitutes, suppliers, buyers;
  maps structural profitability.
- **Moat** — a durable competitive edge (cost, brand, network, switching costs,
  licence).
- **MD&A (Management Discussion & Analysis)** — management's narrative on
  operations and outlook; claims to be verified against the statements.
- **Directors' Report** — governance narrative: board, dividends, related-party
  transactions, compliance.
- **DRHP (Draft Red Herring Prospectus)** — the IPO filing; its Risk Factors
  section is the mandated honesty page.
- **Promoter pledging** — promoter shares offered as loan collateral; a
  governance red flag.
- **CANSLIM** — O'Neil's seven-factor growth-stock screen (Current earnings,
  Annual earnings, New, Supply/demand, Leader, Institutional, Market).
- **Cyclical vs defensive** — sectors that amplify vs resist the business
  cycle.
- **Related-party transaction** — a deal with promoters/associates; a
  governance risk if excessive or off-market.

## Reading assignment

Read the qualitative-analysis chapters in [the reading list](../appendices/reading-list.md):
NIFM Ch 18, 20, 32, 33 (industry analysis, company analysis, corporate
governance, IPO/DRHP), IFMC items 8, 17–18, 25, 33, 43, and O'Neil's *How to
Make Money in Stocks* for the original CANSLIM wording. Also read one real DRHP
of a recent Indian IPO — SEBI's website hosts them free.

## Assessment

- Qualitative company-analysis memo (2 pages).
- Screener practical (5 companies screened, 1 shortlisted).

## Assessment reminder

The qualitative memo is a graded **journal/lab** component, and the shortlisted
company you pick here is the subject of the **M8 modeled-company capstone** — a
programme gate (see [Assessment](../front/assessment.md)). Choose the shortlist
deliberately: the rest of the semester builds on it. Quiz questions on Porter,
moats, and CANSLIM also feed the end-term exam.

**Next:** [M3 — Financial Statement Analysis](m3-financial-statement-analysis.md)
