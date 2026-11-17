# M2 — Industry & Company Qualitative Analysis

> **Weeks 35–37 · 20 hrs · PLO-5, PLO-6 · Core:** NIFM Ch 18, 20, 32, 33; IFMC items 8, 17–18, 25, 33, 43

## Learning outcomes

- Run a **top-down** (macro → industry → company) and **bottom-up** (company →
  industry) analysis.
- Apply Porter's five forces and the industry life cycle.
- Assess management quality, governance, brand, and moats qualitatively.
- Read MD&A and Directors' Report; analyse an IPO via its DRHP.
- Use the **CANSLIM** framework as a selection screen.

## Lesson 2.1 — Top-down vs bottom-up

- Top-down: economy (M1) → sector → stock.
- Bottom-up: company quality first, macro as context.
- Both are valid; the research report (S4-M9) blends them.

## Lesson 2.2 — Industry analysis

- Industry life cycle: emerging → growth → mature → declining.
- **Porter's five forces:** rivalry, new entrants, substitutes, supplier power,
  buyer power.
- Where the industry sits in the economic cycle (cyclical vs defensive).

## Lesson 2.3 — Company qualitative dimensions

- Business model clarity; revenue diversification.
- **Moat** sources: cost, brand, network effects, switching costs, regulation.
- Management: track record, capital allocation, governance red flags.
- ESG as an emerging qualitative lens.

## Lesson 2.4 — MD&A & Directors' Report

- What management says vs what the numbers show — the analyst's cross-check.
- Risk factors section of the DRHP: the honest pages.

## Lesson 2.5 — CANSLIM (O'Neil)

- **C**urrent quarterly earnings, **A**nnual earnings growth, **N**ew products/
  highs, **S**upply/demand, **L**eader vs laggard, **I**nstitutional sponsorship,
  **M**arket direction.
- Use it as a *screen*, then apply fundamentals and TA.

## Tantra Lab 2 — A CANSLIM-style screen

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

## Assessment

- Qualitative company-analysis memo (2 pages).
- Screener practical (5 companies screened, 1 shortlisted).

**Next:** [M3 — Financial Statement Analysis](m3-financial-statement-analysis.md)
