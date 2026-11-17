# M6 — Corporate Actions & Financial Terminology

> **Weeks 10–12 · 16 hrs · PLO-1, PLO-2**

## Learning outcomes

- Explain dividends (interim/final), bonus issues, stock splits, buybacks, and rights issues.
- Adjust prices for ex-dates and understand record dates.
- Speak the equity and debt market terminology like a professional.
- Know banking-sector terminology (per IFMC syllabus).

## Prerequisites

- [M5 — Securities & Instruments](m5-instruments.md): dividends are equity cash flows, buybacks return capital — the instrument classes make the actions meaningful.
- [M3 — How Capital Markets Work](m3-markets.md): primary-market terminology (rights issues, QIP) is used again here.
- [M1 — Financial Literacy & Business Math](m1-math.md): the ex-price adjustment math is division and subtraction with Decimal.
- The exact-record-date logic in Lesson 6.5 assumes you remember the T+1 settlement cycle from [M4](m4-microstructure.md).

## Lesson 6.1 — Cash corporate actions

### 1) Concept

A **corporate action** is an event a company initiates that affects its shareholders. **Cash** corporate actions move money.

A **dividend** is a share of profit paid to shareholders — **interim** (paid mid-year) or **final** (proposed by the board, approved at the AGM). The **record date** is the cut-off: shareholders *on the company's register* on the record date receive the dividend. The **ex-date** is the trading date from which the stock trades *without* the dividend: buy on or after the ex-date and you get no dividend. In India's T+1 settlement, the ex-date is typically *one business day before* the record date. The **payment date** is when the money actually lands.

A **buyback** is the company buying its own shares and cancelling them — fewer shares outstanding, so **EPS** rises (same profit ÷ fewer shares). A **rights issue** offers existing shareholders *new* shares at a discount in proportion to their holding (e.g., 1 new share for every 4 held); it raises capital from the people who already own the company. The price effects: on the ex-date, the price drops by roughly the dividend amount (cash action) or adjusts by the ratio (bonus/split/rights).

### 2) Worked example

Ex-date price adjustment for a cash dividend:

```
RELIANCE closes at ₹1,500 on the ex-date's previous day; dividend ₹15
Theoretical ex-price = 1,500 - 15 = ₹1,485
You own 100 shares: dividend = 100 x 15 = ₹1,500
```

```python
from decimal import Decimal

price, div = Decimal("1500"), Decimal("15")
shares = Decimal("100")
ex_price = price - div
print("theoretical ex-price:", ex_price, "| dividend received:", shares * div)
```

Output: `theoretical ex-price: 1485 | dividend received: 1500`. An owner's wealth is preserved: ₹1,48,500 of stock + ₹1,500 cash = ₹1,50,000.

### 3) Common pitfalls

> **Pitfall:** buying on the record date expecting the dividend — with T+1, the ex-date is the *previous* trading day; buy on the record date and you missed it. **Pitfall:** reading the ex-date price drop as a loss — it is a mechanical adjustment, not news. **Pitfall:** confusing interim and final dividends in a results read.

### 4) Key takeaways

- **Takeaway:** record date = who gets paid; ex-date = the day price trades without the cash; payment date = when money arrives.
- **Takeaway:** buybacks shrink share count and lift EPS.
- **Takeaway:** rights issues raise capital from existing holders at a discount.

## Lesson 6.2 — Non-cash corporate actions

### 1) Concept

**Non-cash** corporate actions change the share count but move no money.

A **bonus issue** gives you free shares out of the company's reserves (e.g., a 1:1 bonus doubles your shares) — no cash changes hands, and the price adjusts so your *total value* is unchanged. A **stock split** cuts the face value (e.g., from ₹10 to ₹5) and issues more shares in proportion — same value per holder, more, cheaper-priced shares (liquidity is the goal; think of it as cutting a ₹2,000 note into two ₹1,000 notes). A **consolidation** (reverse split) is the opposite.

Why prices fall on the ex-date and why technicians must adjust: if RELIANCE trades at ₹2,000 and splits 1:1, the ex-date price should halve to ₹1,000 — but a chart that just shows ₹2,000 → ₹1,000 looks like a 50% crash. So analysts **adjust historical prices** (divide all pre-ex prices by the factor) so the chart is continuous. This is the single most important fix before drawing support/resistance or computing indicators — which is exactly what Semester 2 does.

### 2) Worked example

Split and bonus adjustment of a price series:

```
Prices before a 1:1 split: 2,000, 2,040, 1,980
Adjusted series (divide by 2): 1,000, 1,020, 990
A 2:1 bonus has the same effect: every 1 share becomes 2, price divides by 2
```

```python
from decimal import Decimal

def adjust_historical(prices, factor):
    return [p / factor for p in prices]

old = [Decimal("2000"), Decimal("2040"), Decimal("1980")]
print("adjusted:", adjust_historical(old, Decimal("2")))
```

Output: `adjusted: [Decimal('1000'), Decimal('1020'), Decimal('990')]` — the *shape* of the chart is preserved; only the scale changes.

### 3) Common pitfalls

> **Pitfall:** forgetting to adjust — a 1:1 split looks like a "crash" on a raw chart and triggers false signals. **Pitfall:** adjusting *forward* prices instead of *historical* ones — you keep the current price and rewrite the past. **Pitfall:** applying the same factor to both a bonus and a split in sequence without compounding them.

### 4) Key takeaways

- **Takeaway:** bonus and split multiply share count and divide price; total value is unchanged.
- **Takeaway:** ex-date price drops are mechanical, not news.
- **Takeaway:** adjust *historical* prices before any charting or indicator work.
- **Takeaway:** this adjustment is the entry ticket to S2-M1 technical analysis.

## Lesson 6.3 — Equity & debt terminology

### 1) Concept

A professional speaks precisely. **Equity terms:** *EPS* (profit per share), *book value* (net assets per share), *market cap* (shares × price), *free float* (shares actually available to trade — the M3 index weight), *face value* (printed nominal), *promoter holding* (the founding family/group's stake — critical because it signals control and insider alignment). **Debt terms:** *coupon* (stated interest), *YTM* (yield-to-maturity — the *total* return if you hold to maturity: coupon income *plus* price gain/loss from buying at a discount/premium), *credit rating* (default risk grade), *spread* (a borrower's extra yield over the risk-free G-sec — the price of their default risk), *duration* (a bond's price sensitivity to a 1% rate move — full math in S4-M8).

**Corporate terms:** *EBIT* (earnings before interest and tax — operating profit), *PAT* (profit after tax — the bottom line), and *margins* (EBIT/revenue, PAT/revenue). These are formalised into ratios in Semester 3; today you just learn to say them without flinching.

### 2) Worked example

YTM intuition with numbers:

```
Bond: face ₹1,000, coupon 8% (₹80/yr), bought at ₹900, matures in 2 years
Rough YTM ≈ coupon yield + annualised price gain
  = 80/900 + (1000-900)/2 / 900 = 8.89% + 5.56% = 14.44% (approx)
Duration idea: a 6-year duration bond's price moves ≈ -6% for every +1% in rates
```

```python
from decimal import Decimal

coupon, price, face = Decimal("80"), Decimal("900"), Decimal("1000")
years = Decimal(2)
approx_ytm = (coupon / price) + ((face - price) / years) / price
print("approx YTM:", (approx_ytm * 100).quantize(Decimal("0.01")), "%")
```

Output: `approx YTM: 14.44 %` — buying below face value *raises* the true return above the coupon.

### 3) Common pitfalls

> **Pitfall:** quoting coupon as YTM — a discount bond's YTM exceeds its coupon. **Pitfall:** using "spread" without naming the benchmark (spread over *what*?). **Pitfall:** confusing promoter holding (control) with free float (tradability).

### 4) Key takeaways

- **Takeaway:** equity vocabulary (EPS, book value, free float, promoter holding) describes ownership and control.
- **Takeaway:** YTM = coupon income + price gain/loss to maturity.
- **Takeaway:** duration is the rate-sensitivity dial (math in S4-M8).
- **Takeaway:** EBIT → PAT and margins are the profit ladder you'll build in M7.

## Lesson 6.4 — Banking sector terminology

### 1) Concept

Bank-sector analysis is vocabulary-heavy because banks are regulated businesses with their own metrics. From the RBI's tool kit: the **repo rate** is the rate at which RBI lends to banks (its policy lever; a repo *cut* usually supports equity markets); **reverse repo** is the rate banks earn parking money *with* RBI; **CRR** (cash reserve ratio) is the % of deposits banks must keep as cash with RBI; **SLR** (statutory liquidity ratio) is the % to hold in safe securities. These ratios say how much of every deposit rupee is locked away from lending.

Profitability and asset quality: **NIM** (net interest margin) is interest *earned minus interest paid*, as % of earning assets — the bank's core money-maker. **NPA** (non-performing asset) is a loan on which interest/principal is overdue (beyond ~90 days); **GNPA** is gross NPA as % of loans — the quality gauge. **CASA** is the share of deposits that are cheap current-and-savings accounts (high CASA = low funding cost). **CAR** (capital adequacy ratio) is the bank's own capital as % of risk-weighted assets — the RBI's cushion requirement. This vocabulary returns in S3-M1 (macro) and S3-M2 (industry analysis).

### 2) Worked example

NIM and GNPA:

```
Interest earned = ₹12,000 crore; interest paid = ₹8,000 crore; earning assets = ₹1,00,000 crore
NIM = (12,000 - 8,000) / 1,00,000 = 4%
GNPA = ₹6,000 crore of gross loans of ₹2,00,000 crore = 3%
```

```python
from decimal import Decimal

earned, paid, assets = Decimal("12000_00_00_000"), Decimal("8000_00_00_000"), Decimal("100000_00_00_000")
npa, loans = Decimal("6000_00_00_000"), Decimal("200000_00_00_000")
print("NIM:", (earned - paid) / assets, "| GNPA %:", (npa / loans * 100))
```

Output: `NIM: 0.04 | GNPA %: 3.0`.

### 3) Common pitfalls

> **Pitfall:** treating a high GNPA as automatically fatal — compare it with the bank's *coverage* (provisions) and peers. **Pitfall:** confusing NIM with net profit margin — NIM is a spread on earning assets, not a bottom-line ratio. **Pitfall:** quoting repo rate moves without noting they affect borrowing costs across the whole economy.

### 4) Key takeaways

- **Takeaway:** repo/reverse repo, CRR, SLR are the RBI's control levers.
- **Takeaway:** NIM measures the lending business; GNPA measures loan quality; CAR measures the safety cushion.
- **Takeaway:** high CASA = cheap funding = a durable advantage.
- **Takeaway:** this vocabulary is the prerequisite for S3-M1/M2 sector analysis.

## Lesson 6.5 — Reading a corporate-action calendar

### 1) Concept

Corporate actions are announced through **exchange notices** (NSE/BSE), the company's announcements, and screener tools. Each notice lists the key dates — the **record date**, the **ex-date**, and sometimes a **book-closure period** (days the register is frozen). Reading order matters: check the *announcement date* (news), the *ex-date* (trading impact), the *record date* (ownership cut-off), and the *payment date* (cash timing). With T+1 settlement, the ex-date is *one trading day before* the record date.

A beginner's discipline: never trade a corporate action from memory — look the dates up in the exchange notice *before* placing the order. The same calendar logic applies to dividends (cash), bonuses and splits (share count), and rights (entitlement ratio).

### 2) Worked example

Reading the calendar:

```
Announcement: 10 Nov — RELIANCE declares final dividend ₹10
Ex-date:       19 Nov   (trades ex-dividend from here)
Record date:   20 Nov   (shareholders on the register get the dividend)
Payment date: 05 Dec
Buying on 18 Nov (close) -> you get the dividend.
Buying on 19 Nov (ex-date) -> the price you pay already excludes it.
```

```python
from decimal import Decimal

dividend = Decimal("10")
# Holder with 200 shares bought on 18 Nov:
print("dividend due:", (dividend * Decimal("200")).quantize(Decimal("0.01")))
```

Output: `dividend due: 2000.00`.

### 3) Common pitfalls

> **Pitfall:** treating record date and ex-date as the same day — with T+1 they differ by one trading day. **Pitfall:** ignoring book closure when it blocks transfers around the record date. **Pitfall:** trading on an unverified "tip" about a corporate action — dates from exchange notices only.

### 4) Key takeaways

- **Takeaway:** every corporate action has announcement, ex, record, and payment dates.
- **Takeaway:** ex-date < record date by one trading day (T+1 India).
- **Takeaway:** source dates from exchange notices, never from memory.
- **Takeaway:** the calendar is the same discipline as the S2 adjustment workflow.

## Tantra Lab 6 — Price adjustment for a split

### Lab goal

Prove that adjusting historical prices for a 1:1 bonus/split preserves the *shape* of a price series, which is the precondition for any technical-analysis work on that series.

### Code

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

### Expected output

`adjusted: [Decimal('60'), Decimal('60.5'), Decimal('59.5')]` — every pre-split price halved, so the series keeps its ups and downs while moving to the new scale.

### Hand-in checklist

- [ ] Lab script with the extension: a synthetic series (`synthetic_bars(SampleInstruments.NIFTY50, ...)`), a split applied with `adjust_historical`, and both series printed.
- [ ] Excel plot (S1-M2 skills) of original vs adjusted series side by side, showing the shape is preserved.
- [ ] Journal paragraph: why a technician must adjust before support/resistance and indicators (link to S2-M1).
- [ ] Vocabulary flashcard deck due: 50 terms from Lessons 6.3 and 6.4 (equity, debt, corporate, banking).

### Common errors

- **Dividing the wrong way** — after a 1:1 split, pre-split prices are *divided by 2* (halved), not multiplied.
- **Adjusting only some prices** — the entire historical series must be adjusted, or the chart still shows a fake crash.
- **Applying the factor to dates** — the adjustment is to *prices*, not timestamps.

## Practice problems

1. TCS closes at ₹4,000 and declares a ₹100 final dividend. Compute the theoretical ex-price. What happens to your ₹1,50,000 of wealth if you hold 37 shares? (Before vs after, ignoring tax.)
2. A 2:1 bonus is announced when a stock trades at ₹1,500. What is the adjusted price? How many shares do you hold if you had 50?
3. Distinguish record date, ex-date, and payment date in one sentence each.
4. A bank's interest earned is ₹15,000 crore, interest paid ₹9,000 crore, earning assets ₹1,50,000 crore. Compute NIM. If gross NPA is ₹4,500 crore on ₹1,50,000 crore of loans, compute GNPA %.
5. Which adjusts which: promoter holding vs free float — and which one feeds a free-float market-cap index?
6. Why does a buyback lift EPS even if profit is unchanged?

### Solutions

1. Ex-price = `4000 - 100 = ₹3,900`. Wealth before = `37 x 4000 = ₹1,48,000`; after = `37 x 3900 + 37 x 100 = ₹1,44,300 + ₹3,700 = ₹1,48,000` — unchanged (taxes aside).
2. 2:1 bonus → every 1 share becomes 3; price adjusts to `1500 x (1/3) = ₹500`; 50 shares become 150.
3. Record date — register cut-off for entitlement; ex-date — first day the stock trades without the entitlement (one trading day before record date in T+1); payment date — when the cash/shares arrive.
4. `NIM = (15000 - 9000)/150000 = 4%`; `GNPA = 4500/150000 = 3%`.
5. Free float is the tradable slice and feeds free-float indices (Nifty/Sensex); promoter holding is the locked control stake and reduces free float.
6. Buyback cancels shares: same profit ÷ fewer shares = higher EPS.

## Quiz bank

| Question | A | B | C | D | Answer |
|---|---|---|---|---|---|
| The register cut-off for a dividend is the: | ex-date | record date | payment date | announcement date | B |
| In T+1 India, the ex-date is: | the same as record date | one day after record date | one trading day before record date | the payment date | C |
| After a 1:1 split from ₹2,000, the theoretical price is: | ₹1,000 | ₹2,000 | ₹4,000 | ₹500 | A |
| A bonus issue changes: | your total value | the share count | the company's cash | the dividend yield only | B |
| A buyback typically: | raises EPS | lowers EPS | raises share count | pays a dividend | A |
| YTM is roughly: | the coupon | coupon income plus price gain/loss to maturity | the face value | the rating | B |
| A bond's duration estimates: | default risk | price sensitivity to rates | credit spread | tax liability | B |
| The RBI rate at which banks borrow from RBI is the: | SLR | CRR | repo rate | NIM | C |
| NIM measures: | loan defaults | net interest income as % of earning assets | capital ratio | deposit share | B |
| The investor cut-off that matters for buying the dividend is the: | ex-date | AGM date | payment date | book value | A |

## Glossary

- **Corporate action** — a company-initiated event affecting shareholders (dividend, bonus, split, buyback, rights).
- **Interim / final dividend** — mid-year dividend / board-proposed, AGM-approved dividend.
- **Record date / ex-date / payment date** — ownership cut-off / first ex-entitlement trading day / money-arrival day.
- **Buyback** — company repurchasing and cancelling its own shares.
- **Rights issue** — discounted new shares offered to existing holders.
- **Bonus issue** — free shares from reserves; no cash changes hands.
- **Stock split** — lower face value, proportionally more shares.
- **Adjustment** — rewriting pre-action prices so charts and indicators stay continuous.
- **YTM** — yield-to-maturity: total return if held to maturity.
- **Spread / duration** — extra yield over the risk-free rate / price sensitivity to rates.
- **Repo rate / CRR / SLR** — RBI policy rate / cash reserve requirement / statutory liquidity ratio.
- **NIM / NPA / CASA / CAR** — net interest margin / non-performing assets / cheap-deposit share / capital adequacy ratio.

## Reading assignment

From the [Reading & Resource List](../appendices/reading-list.md), read the NSE/BSE circular sections on corporate actions and the SEBI buyback/disclosure regulations; keep an annual report handy for the "50 terms" flashcard deck. The exchange-notice practice in Lesson 6.5 is the same habit the S2 adjustment modules assume.

## Assessment reminder

M6 is graded by the **corporate-action price-adjustment lab**, the **terminology quiz**, and the **50-term flashcard deck**, all continuous assessment. Ex-date logic and split/bonus adjustment are recurring mid-term and end-term items. See [Assessment & Grading Scheme](../front/assessment.md).

**Next:** [M7 — Introduction to Financial Statements](m7-financial-statements.md)
