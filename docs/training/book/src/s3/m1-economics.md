# M1 — Economics for Securities Markets

> **Weeks 33–35 · 24 hrs · PLO-6 · Core:** NIFM Ch 17, 31; PGP T2-201; IFMC items 9–13, 67–69

## Learning outcomes

- Explain GDP, IIP, CPI/WPI inflation, and PMI and what each tells the market.
- Explain how monetary policy (repo, reverse repo, CRR, SLR) transmits to stocks.
- Connect fiscal policy and global events (Eurozone, oil, IT/visa, US Fed) to
  Indian markets.
- Read an economic calendar and interpret one policy decision end to end.

## Lesson 1.1 — Growth indicators

- **GDP** = C + I + G + (X − M). Growth vs level; YoY and quarterly annualized.
- **IIP** = Index of Industrial Production — manufacturing pulse.
- Market reaction logic: growth above expectation → equities up (unless it forces
  rate hikes — the classic tension).

## Lesson 1.2 — Inflation

- **CPI** (retail) vs **WPI** (wholesale); core vs headline.
- Why central banks target CPI; the repo-rate link.
- Inflation's two-edged effect on stocks: revenue tailwind vs discount-rate headwind.

## Lesson 1.3 — PMI and business cycles

- **PMI** = Purchasing Managers' Index; >50 expansion, <50 contraction.
- PMI as a *leading* indicator vs IIP as a *coincident* one.

## Lesson 1.4 — Monetary & fiscal policy

- Repo, reverse repo, CRR, SLR, MSF; liquidity operations.
- Transmission: rates → bond yields → discount rates → equity valuations
  (this is the CAPM/WACC link you will formalize in M6).
- Fiscal: deficit, borrowing, crowding out.

## Lesson 1.5 — Global macro

- Eurozone crisis, oil price shocks, IT/visa policies, US Fed hikes — how each
  reaches Indian equities via flows, FX, and sectors.
- Banking sector terminology refresher (S1-M6): NIM, NPA, CASA, CAR — the
  macro-to-sector translation.

## Tantra Lab 1 — Returns on a macro-moved index

```python
from decimal import Decimal
from tantra.quant import returns
from tantra_examples import SampleInstruments, synthetic_bars

bars = synthetic_bars(SampleInstruments.NIFTY50, days=250, seed=42, base_price_paise=24_000)
closes = [b.close for b in bars]
rets = returns(closes)

print("first 5 returns:", rets[:5])
print("count:", len(rets))
```

**Task:** write a 1,000-word commentary on a live policy event (e.g., a repo
rate decision): what was expected, what happened, what happened to the index and
to banks/IT sectors, and why. Submit with the return series printed.

## Assessment

- Macro commentary assignment (1,000 words).
- Quiz: indicator definitions and transmission channels.

**Next:** [M2 — Industry & Company Qualitative Analysis](m2-industry-company-qualitative.md)
