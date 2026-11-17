# M5 — Securities & Instruments

> **Weeks 8–10 · 20 hrs · PLO-2**

## Learning outcomes

- Classify any instrument as equity, debt, hybrid, or derivative.
- Describe the features of ordinary/preference shares, bonds, debentures, G-secs.
- Explain mutual funds (types, AMC, AUM), ETFs, REITs/InvITs.
- Compute and interpret Net Asset Value (NAV).
- Know the alternative asset classes (gold, commodities, art, crypto).

## Prerequisites

- [M3 — How Capital Markets Work](m3-markets.md): equity shares and indices are now joined by the rest of the instrument family.
- [M1 — Financial Literacy & Business Math](m1-math.md): returns and percentages in the worked examples reuse M1 arithmetic.
- [M4 — Market Microstructure](m4-microstructure.md): the participants who issue and trade these instruments are fresh in your head.

## Lesson 5.1 — Equity

### 1) Concept

**Equity** is ownership. **Ordinary (equity) shares** carry voting rights and a claim on whatever profit is left after everyone else is paid; there is no promised return — you participate in the company's fortunes. **Preference shares** are a hybrid: they promise a fixed dividend *before* ordinary shareholders are paid, and rank ahead of them on a wind-up, but usually carry no (or limited) voting rights. Think of preference shares as "quasi-debt with equity-like tax treatment" — more on that in Lesson 5.2.

Three values get confused daily: **face value** (the printed nominal, e.g., ₹10, used for accounting), **book value** (net assets per share — what the *accounts* say the share is worth), and **market value** (what the market pays). **Market cap** (from M3) is shares × market price. Two per-share measures matter for the rest of the course: **EPS** (earnings per share = profit ÷ shares) and **dividends per share** (the cash handed out per share). Because equity sits at the very end of the payment queue — after suppliers, employees, lenders, and the taxman — it is the *riskiest mainstream asset*, and that is why its expected return is the highest. Equity risk shows up as volatility: INFY can fall 10% in a week on a weak quarter, and no one owes you compensation.

### 2) Worked example

EPS and market cap:

```
PAT = ₹10,000 crore; shares = 500 crore
EPS = 10,000 / 500 = ₹20 per share
Price = ₹1,200 -> market cap = 500 cr x 1,200 = ₹6,00,000 crore
```

```python
from decimal import Decimal

pat = Decimal("10000_00_00_000")            # ₹10,000 crore
shares = Decimal("500_00_00_000")           # 500 crore shares
price = Decimal("1200")
eps = pat / shares
print("EPS:", eps, "| market cap:", (shares * price).quantize(Decimal("1")))
```

Output: `EPS: 20.0 | market cap: 600000000000000` (₹6 lakh crore).

### 3) Common pitfalls

> **Pitfall:** treating face value as the price. **Pitfall:** classifying preference shares as "equity" in a risk discussion — their fixed dividend makes them debt-like. **Pitfall:** comparing two companies' share prices instead of their market caps and EPS.

### 4) Key takeaways

- **Takeaway:** equity = residual claim + voting rights + highest risk and expected return.
- **Takeaway:** face value, book value, and market value are three different numbers.
- **Takeaway:** EPS and market cap are the per-share and total lenses on a company.

## Lesson 5.2 — Debt and hybrids

### 1) Concept

**Debt** is a loan you (or the market) make to a borrower. A **bond** has a **face value** (repayment amount, e.g., ₹1,000), a **coupon** (the stated interest, e.g., 7% paid yearly), a **maturity** (when the face value is returned), and a **credit risk** (the chance the borrower defaults). A **debenture** is an unsecured bond issued by a company; a **G-sec** is a government security — the safest paper in the market, because the government can tax and print to repay. Ratings (AAA down to D, from CRISIL/ICRA/CARE) grade that default risk.

The single most counter-intuitive fact in fixed income: **bond price and yield move inversely**. Yield is what the bond *actually* earns you at today's price, not the printed coupon. If interest rates rise, existing bonds (with older, lower coupons) become less attractive and their prices fall — pushing their yield up to match the market. If rates fall, prices rise. The full price–yield math is Semester 4 (S4-M8); today you build the intuition with numbers.

**Hybrids** blend equity and debt: **convertible debentures** are debt that can become equity at a trigger; **preference shares** (Lesson 5.1) promise a fixed dividend — debt-like income with equity-like downside. In a wind-up, *secured lenders → unsecured lenders (debentures) → preference → ordinary equity* is the payment order.

### 2) Worked example

Coupon vs yield:

```
A ₹1,000 G-sec pays a 7% coupon = ₹70 per year.
You buy it at ₹875 (a discount): yield = 70 / 875 = 8%  -> price low, yield high
If you buy it at ₹1,250 (a premium): yield = 70 / 1,250 = 5.6% -> price high, yield low
```

```python
from decimal import Decimal

coupon = Decimal("70")
for price in (Decimal("875"), Decimal("1250")):
    yield_ = coupon / price
    print(f"price {price:>5} -> yield {yield_ * 100:.2f}%")
```

Output: `price   875 -> yield 8.00%`; `price  1250 -> yield 5.60%`. One bond, one coupon, and two different yields — price and yield are mirror images.

### 3) Common pitfalls

> **Pitfall:** calling the coupon the yield — yield is coupon ÷ *current price*. **Pitfall:** assuming G-secs can't lose money — they can't default, but they *can* lose price when rates rise. **Pitfall:** forgetting credit risk when comparing a debenture to a G-sec — the coupon difference is the *credit spread* for bearing default risk.

### 4) Key takeaways

- **Takeaway:** bond = face value + coupon + maturity + credit risk.
- **Takeaway:** price and yield are inversely related — the S4-M8 math comes later.
- **Takeaway:** G-secs are default-free but not price-risk-free.
- **Takeaway:** hybrids (convertibles, preference shares) sit between debt and equity.

## Lesson 5.3 — Mutual funds and ETFs

### 1) Concept

A **mutual fund** pools money from thousands of savers into one portfolio managed by an **AMC** (asset management company). Each **scheme** has an **AUM** (assets under management) and a stated objective (large-cap equity, debt, hybrid, index, ELSS tax-saver). You are charged for the service: an **expense ratio** (annual % of AUM, e.g., 1% — an index fund may charge 0.2%, an active fund 1.5%+) and possibly an **exit load** (a fee if you redeem within a holding period, e.g., 1% within 1 year). **Direct plans** (bought from the AMC, lower expense) vs **regular plans** (bought through a distributor, higher expense) are the same portfolio at two prices — the difference is the distributor's commission.

An **ETF** (exchange-traded fund) is a fund whose units trade on the exchange *like a stock*, all day at market prices — for example, a Nifty 50 ETF. An **index fund** is a fund that replicates an index but is bought/sold from the AMC at NAV (end-of-day price). An **active fund** tries to beat the index through stock-picking. Three versions of "Nifty exposure", three cost and convenience profiles. The fund family ends with **REITs/InvITs** — real-estate and infrastructure trusts that pay out most of their cash flow as distributions (Lesson 5.5).

### 2) Worked example

Expense ratio in money terms:

```
AUM = ₹10,000 crore; expense ratio = 1.25%
Yearly expense = 10,000 cr x 0.0125 = ₹125 crore charged to the fund's holders
A ₹1,00,000 investment pays ₹1,250/year in expenses (0.0125 x 100000)
```

```python
from decimal import Decimal

investment = Decimal("100000")
expense_ratio = Decimal("0.0125")
print("yearly cost on ₹1,00,000:", (investment * expense_ratio).quantize(Decimal("0.01")))
```

Output: `yearly cost on ₹1,00,000: 1250.00`. Costs compound against returns year after year — the reason index funds are so popular.

### 3) Common pitfalls

> **Pitfall:** conflating exit load with expense ratio — one is a one-time redemption fee, the other an annual ongoing charge. **Pitfall:** paying the regular-plan price when a direct plan exists. **Pitfall:** comparing two funds by AUM alone — big AUM ≠ good performance.

### 4) Key takeaways

- **Takeaway:** a fund = pooled money + AMC + scheme + AUM + expense ratio.
- **Takeaway:** ETF trades intraday; index fund trades at end-of-day NAV; active fund tries to beat the index.
- **Takeaway:** lower costs compound into real money over years.

## Lesson 5.4 — NAV analysis

### 1) Concept

Every fund scheme publishes a **Net Asset Value** every business day:

```
NAV = (Market value of scheme assets - liabilities) / units outstanding
```

NAV is the "price" at which units are bought and sold, computed from the *actual* market value of the portfolio, not from any printed face value. What NAV is *not*: a yardstick for comparing funds. A fund with NAV ₹50 and one with NAV ₹250 are not "cheap" and "expensive" — NAV level depends on unit creation history, not quality. Compare funds on **returns** (same-period growth in NAV, including distributions), **risk**, and **costs**. When a fund pays a dividend, NAV drops by the dividend amount — so a 10% "return" that is mostly a dividend distribution is not an outperformance.

### 2) Worked example

NAV and a return comparison:

```
Fund A: assets ₹100 crore, liabilities ₹5 crore, units 95 crore -> NAV = 95/95 = ₹1.00
Fund B: assets ₹200 crore, liabilities ₹10 crore, units 190 crore -> NAV = 190/190 = ₹1.00
Same NAV — but A is a smaller pool; comparison metric must be return & risk, not NAV.
12-month return: NAV 1.00 -> 1.08 = 8% ;  NAV 1.00 -> 1.12 = 12%
```

```python
from decimal import Decimal

def nav(assets, liabilities, units):
    return (assets - liabilities) / units

a = nav(Decimal("100_00_00_000"), Decimal("5_00_00_000"), Decimal("95_00_00_000"))
b = nav(Decimal("200_00_00_000"), Decimal("10_00_00_000"), Decimal("190_00_00_000"))
print("NAV A", a, "NAV B", b)
r12 = (Decimal("1.12") - Decimal("1.00")) / Decimal("1.00")
print("12-month return at 12%:", r12)
```

Output: `NAV A 1.00 NAV B 1.00` and `12-month return at 12%: 0.12`.

### 3) Common pitfalls

> **Pitfall:** choosing a fund because its NAV is "low" — NAV level is meaningless across funds. **Pitfall:** reading a post-dividend NAV drop as a loss — it is a distribution of money you already owned. **Pitfall:** computing returns from unadjusted NAVs across a dividend date.

### 4) Key takeaways

- **Takeaway:** `NAV = (assets - liabilities) / units`.
- **Takeaway:** NAV levels are not comparable across funds; returns, risk, and cost are.
- **Takeaway:** dividends mechanically reduce NAV — adjust before computing returns.
- **Takeaway:** performance measurement gets its formal tools in S4-M4.

## Lesson 5.5 — Alternatives

### 1) Concept

Beyond equities and bonds sits the **alternatives** shelf. **Commodities** trade on MCX (gold, silver, crude, base metals). **Gold** is the Indian household's favourite: bought as jewellery, coins, **gold ETFs**, or **sovereign gold bonds**. **REITs and InvITs** distribute most of their rental/infrastructure cash flow as income — a "bond-like income with property-like growth" bundle. **International funds** give overseas exposure (with currency risk, from M3 Lesson 3.5). **Private markets** (private equity, venture capital, unlisted debt) are illiquid and institution-dominated.

Why hold alternatives at all? Because they behave *differently* from equities — gold often rises when stocks fall, real estate moves on its own cycle — so a small allocation can smooth a portfolio's ride. The risk caveat: some alternatives are illiquid (art, real estate) and some are extremely volatile and lightly regulated (**crypto**). The course's stance is allocation-first: alternatives earn a modest, deliberate weight in a portfolio (link to S5-PM/IA tracks), never a speculative whole-savings bet.

### 2) Worked example

A portfolio weight in Decimal:

```
Portfolio: ₹5,00,000 equity, ₹2,00,000 debt, ₹1,00,000 gold = ₹8,00,000
Gold weight = 1,00,000 / 8,00,000 = 12.5%
```

```python
from decimal import Decimal

equity, debt, gold = Decimal("500000"), Decimal("200000"), Decimal("100000")
total = equity + debt + gold
print("gold weight:", (gold / total * 100).quantize(Decimal("0.01")), "%")
```

Output: `gold weight: 12.50 %`.

### 3) Common pitfalls

> **Pitfall:** treating all alternatives as liquid — art, real estate, and private equity are not sold in a day. **Pitfall:** assuming "alternative" means "higher return" — it means *different risk and return profile*. **Pitfall:** sizing crypto like a savings account — it is the highest-volatility asset in the shelf.

### 4) Key takeaways

- **Takeaway:** alternatives = commodities, gold, REITs/InvITs, international, private markets.
- **Takeaway:** their value is *diversification* — different behaviour from equities.
- **Takeaway:** match the alternative's liquidity to your horizon.
- **Takeaway:** allocation discipline (S5 tracks) governs how much goes where.

## Tantra Lab 5 — NAV and a two-fund comparison

### Lab goal

Prove that two funds can share an identical NAV while being very different in size, then compare them the *right* way — on return and cost, not NAV level.

### Code

```python
from decimal import Decimal

def nav(assets: Decimal, liabilities: Decimal, units: Decimal) -> Decimal:
    return (assets - liabilities) / units

# Fund A vs Fund B, same NAV — but different assets/costs
a = nav(Decimal("1_000_000_000"), Decimal("50_000_000"), Decimal("950_000_000"))
b = nav(Decimal("2_000_000_000"), Decimal("100_000_000"), Decimal("1_900_000_000"))
print("NAV A", a, "NAV B", b)  # identical — but A is smaller
```

**Task:** build a fund-comparison worksheet in Excel (S1-M2 skills): NAV,
expense ratio, 1y/3y returns (compute returns in Decimal), and risk. Read the
AMFI NAV import example `tantra-examples/examples/storage/03_import_amfi_nav.py`
and `mutual_funds/01_fetch_nav.py` to see real NAV pipelines.

### Expected output

`NAV A 1.0 NAV B 1.0` — both ₹1.00, despite A's total assets (₹100 crore) being half of B's (₹200 crore). The two funds are the same *price per unit* but very different *sizes*.

### Hand-in checklist

- [ ] Lab script `lab5.py` printing both NAVs, saved in `labs/`.
- [ ] Excel fund-comparison worksheet: columns NAV, expense ratio, 1y and 3y returns (Decimal), and a risk column (e.g., max drawdown or price-range %) for two real or synthetic funds.
- [ ] Journal entry: "why NAV level is not a comparison metric", in your own words with the A/B numbers.
- [ ] One-sentence note on what `03_import_amfi_nav.py` or `01_fetch_nav.py` demonstrates after you run it.
- [ ] Quiz-ready: classify 20 instruments (equity/debt/hybrid/derivative/alternative) — the week's mini-quiz.

### Common errors

- **Reading `1.0` as "one rupee premium"** — it is the NAV level; nothing about cheapness or expensiveness follows.
- **Comparing returns across different periods** — always same-period NAV growth (both 1y, both 3y).
- **Import errors on AMFI scripts** — the NAV pipelines need internet or a cached AMFI file; run them with the harness's prepared data, not live-downloading in an exam room.

## Practice problems

1. Classify: ordinary share, convertible debenture, G-sec, Nifty ETF, gold, preference share, art, crude future.
2. A company earns PAT ₹6,000 crore with 300 crore shares. Compute EPS. At ₹900, compute market cap.
3. A ₹1,000 bond pays an 8% coupon. Compute its yield when bought at ₹800 and at ₹1,250.
4. Compute NAV for assets ₹250 crore, liabilities ₹10 crore, units 240 crore.
5. A fund's NAV goes ₹10.00 → ₹11.40 in one year. Compute the 1-year return. Then the fund pays a ₹1.40 dividend and NAV drops to ₹10.00 — is the investor worse off?
6. Why does a 0.5% cheaper expense ratio matter over 10 years? (Hint: compounding from M1.)

### Solutions

1. Ordinary share → equity; convertible debenture → hybrid; G-sec → debt; Nifty ETF → equity (fund); gold → alternative; preference share → hybrid; art → alternative; crude future → derivative.
2. `EPS = 6000/300 = ₹20`; market cap = `300 cr x 900 = ₹2,70,000 crore`.
3. Coupon = `1000 x 0.08 = ₹80`; at ₹800 yield = `80/800 = 10%`; at ₹1,250 yield = `80/1250 = 6.4%`.
4. `(250 - 10)/240 = ₹1.00`.
5. Return = `(11.40 - 10.00)/10.00 = 14%`. The ₹1.40 dividend + NAV drop back to ₹10.00 leaves the investor with value ₹11.40 pre- or post-dividend (taxes aside) — not worse off; the NAV drop is a distribution, not a loss.
6. Over 10 years a 0.5% annual drag compounds: `1.005^10 - 1 ≈ 5.1%` of final wealth lost to the fee difference alone — cost is a return killer.

## Quiz bank

| Question | A | B | C | D | Answer |
|---|---|---|---|---|---|
| The instrument with a *promised* fixed dividend is: | ordinary share | preference share | G-sec | ETF | B |
| A debenture is: | equity | unsecured corporate debt | a bank deposit | a derivative | B |
| When bond prices fall, yields: | rise | fall | stay equal | vanish | A |
| The safest Indian debt instrument is: | company debenture | G-sec | bank FD at a private bank | NBFC paper | B |
| An ETF trades: | only at end of day | intraday on the exchange | never | on MCX | B |
| Exit load is charged: | yearly | on early redemption | on purchase only | never | B |
| NAV equals: | assets ÷ units | (assets − liabilities) ÷ units | liabilities ÷ assets | units ÷ assets | B |
| Two funds with the same NAV: | have equal risk | are equally cheap | may differ hugely in size/cost | are the same fund | C |
| ELSS mutual funds offer: | tax deduction (Sec 80C) | guaranteed returns | fixed income | crypto exposure | A |
| REITs primarily distribute: | rental income | capital gains only | dividends on preference shares | coupons | A |

## Glossary

- **Equity** — ownership; residual claim, voting rights, highest risk/return.
- **Preference share** — hybrid: fixed dividend, priority over ordinary shares.
- **Bond / debenture / G-sec** — debt paper of a company / unsecured company debt / government debt.
- **Coupon** — the stated interest of a bond per year.
- **Yield** — coupon ÷ current price; the bond's true earnings rate.
- **AMC** — asset management company running mutual fund schemes.
- **AUM** — assets under management of a scheme.
- **Expense ratio** — annual % of AUM charged by the fund.
- **ETF / index fund / active fund** — exchange-traded index tracker / AMC-priced tracker / actively managed fund.
- **NAV** — net asset value: (assets − liabilities) ÷ units outstanding.
- **REIT / InvIT** — real-estate / infrastructure trust distributing cash flow.
- **Alternatives** — commodities, gold, art, private markets, crypto; a diversification sleeve.

## Reading assignment

From the [Reading & Resource List](../appendices/reading-list.md), read the NISM Series XV & Series VIII workbook sections on instruments and mutual funds, and keep the AMFI material for the NAV pipeline. The platform references `tantra-examples/examples/mutual_funds/` and `storage/03_import_amfi_nav.py` show real NAV data pipelines worth studying.

## Assessment reminder

M5 is graded by the **fund-comparison table + NAV worksheet (Excel)** assignment and the **20-instrument classification quiz**, plus the Lab 5 journal entry — all continuous assessment. Instrument classification and NAV arithmetic are standard mid-term and end-term questions. See [Assessment & Grading Scheme](../front/assessment.md).

**Next:** [M6 — Corporate Actions & Financial Terminology](m6-corporate-actions.md)
