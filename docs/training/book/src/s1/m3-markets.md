# M3 — How Capital Markets Work

> **Weeks 4–6 · 24 hrs · PLO-1**

## Learning outcomes

- Explain what a stock is and why companies issue shares.
- Distinguish primary and secondary markets.
- Describe NSE, BSE, and MCX and their role; read index basics (Sensex, Nifty).
- Explain the IPO process and the role of a DRHP.
- Compare Indian market structure with the US/EU/Asia (per IFMC syllabus).

## Lesson 3.1 — What a stock is

- Ownership share, limited liability, dividends, voting rights.
- Company lifecycle: promoter → private equity → IPO → listed.

## Lesson 3.2 — Primary vs secondary markets

- Primary: new capital raised via IPO, FPO, rights issue, QIP.
- Secondary: exchange trading between investors; company raises nothing.
- Price discovery in secondary markets.

## Lesson 3.3 — Exchanges and indices

- NSE (Nifty 50), BSE (Sensex), MCX (commodities).
- How an index aggregates prices; free-float market-cap weighting (intuition;
  exact math in S4).
- Index constituents and periodic rebalancing.

## Lesson 3.4 — IPO process and the DRHP

- Merchant bankers, book building, price band, allotment, listing.
- **DRHP** = Draft Red Herring Prospectus: the single best source of company
  information for a first-year analyst (used again in S3).

## Lesson 3.5 — How markets work worldwide

- US (NYSE/Nasdaq, SEC), EU (Euronext, ESMA), Asia (HKEX, SGX, Tokyo, Shanghai).
- Depositories, clearing houses, and the idea that every market has a
  regulator, an exchange, brokers, and clearing/settlement (the theme of M4).

## Tantra Lab 3 — A synthetic index and "IPO" of a bar series

```python
from decimal import Decimal
from tantra_examples import SampleInstruments, synthetic_bars

nifty = synthetic_bars(SampleInstruments.NIFTY50, days=120, seed=7, base_price_paise=24_000)

# Simple mean-of-prices "index" of two instruments (illustrative only)
first  = synthetic_bars(SampleInstruments.RELIANCE, days=120, seed=1)
index = [Decimal((n.close + r.close) / 2) for n, r in zip(nifty, first)]
print("first 10 index levels:", index[:10])
```

**Task:** print the first and last index level, compute the "return" of this
two-stock index, and explain in your own words why a free-float index differs
from a simple mean. Write a 2-page essay: "How capital markets work worldwide"
(per IFMC syllabus item 7).

## Assessment

- Quiz (instruments, markets, IPO).
- 2-page essay on global markets.

**Next:** [M4 — Market Microstructure & Participants](m4-microstructure.md)
