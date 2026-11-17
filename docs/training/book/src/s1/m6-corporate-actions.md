# M6 — Corporate Actions & Financial Terminology

> **Weeks 10–12 · 16 hrs · PLO-1, PLO-2**

## Learning outcomes

- Explain dividends (interim/final), bonus issues, stock splits, buybacks, and rights issues.
- Adjust prices for ex-dates and understand record dates.
- Speak the equity and debt market terminology like a professional.
- Know banking-sector terminology (per IFMC syllabus).

## Lesson 6.1 — Cash corporate actions

- **Dividend:** interim vs final; record date, ex-date, payment date.
- **Buyback:** company buys its own shares; impact on share count and EPS.
- **Rights issue:** raising capital from existing holders at a discount.

## Lesson 6.2 — Non-cash corporate actions

- **Bonus issue:** free shares from reserves (no cash changes hands).
- **Stock split:** lower face value, more shares; price adjusts proportionally.
- Why prices fall on the ex-date and how to adjust historical prices for
  charting (important for technical analysis in S2!).

## Lesson 6.3 — Equity & debt terminology

- Equity: EPS, book value, market cap, free float, face value, promoter holding.
- Debt: coupon, YTM, credit rating, spread, duration (math in S4-M8).
- Corporate: EBIT, PAT, margins (formalized in S3).

## Lesson 6.4 — Banking sector terminology

- Repo/reverse repo, CRR, SLR, NIM, NPA/GNPA, CASA, CAR.
- Why bank-sector analysis is vocabulary-heavy (used in S3-M1 and S3-M2).

## Lesson 6.5 — Reading a corporate-action calendar

- Sources: exchange notices, NSE/BSE announcements, screener tools.
- Interpreting record date vs ex-date vs book closure.

## Tantra Lab 6 — Price adjustment for a split

```python
from decimal import Decimal

# A 1:1 bonus/split: every 1 share becomes 2; old price adjusts by 1/2.
def adjust_historical(prices: list[Decimal], factor: Decimal) -> list[Decimal]:
    return [p / factor for p in prices]

old_prices = [Decimal("120"), Decimal("121"), Decimal("119")]
print("adjusted:", adjust_historical(old_prices, Decimal("2")))
```

**Task:** generate a synthetic series, "apply" a split, and plot both original
and adjusted series. Explain in the journal why a technician must adjust
historical prices before drawing support/resistance or computing indicators
(foreshadows S2-M1).

## Assessment

- Quiz + corporate-action price-adjustment lab.
- Vocabulary flashcard deck due (50 terms).

**Next:** [M7 — Introduction to Financial Statements](m7-financial-statements.md)
