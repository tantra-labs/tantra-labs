# M3 — How Capital Markets Work

> **Weeks 4–6 · 24 hrs · PLO-1**

## Learning outcomes

- Explain what a stock is and why companies issue shares.
- Distinguish primary and secondary markets.
- Describe NSE, BSE, and MCX and their role; read index basics (Sensex, Nifty).
- Explain the IPO process and the role of a DRHP.
- Compare Indian market structure with the US/EU/Asia (per IFMC syllabus).

## Prerequisites

- [M1 — Financial Literacy & Business Math](m1-math.md): percentages, index-number intuition, and CAGR underpin every "market up X%" statement.
- [M2 — Excel for Finance](m2-excel.md): you will later build the two-stock index as a spreadsheet.
- No prior knowledge of stocks is required — Lesson 3.1 starts from first principles.

## Lesson 3.1 — What a stock is

### 1) Concept

A **stock** (equity share) is a *unit of ownership* in a company. If a company has 100 shares and you own 1, you own 1% of the company — including its profits (through **dividends** and price appreciation) and, in good times, a **voting right** at shareholder meetings. The magic of a stock is **limited liability**: if the company goes bankrupt, you lose your invested money but nothing more; you are never asked to pay the company's debts.

Companies are born private — a promoter, then perhaps **private equity** money — and some choose to "go public" through an **IPO** (initial public offering), selling shares to the general public and becoming *listed*. That lifecycle — promoter → private equity → IPO → listed company — explains nearly everything about how the Indian market is structured: the biggest listed companies (RELIANCE, TCS, INFY, HDFC Bank) were once small private firms.

The market values a company by multiplying the number of shares by the price — the **market capitalisation**. The *number of shares* and the *price per share* both matter: a ₹3,000 stock with 300 crore shares outstanding is worth ₹9,00,000 crore (₹9 lakh crore), while a ₹100 stock with 10,000 crore shares is worth ₹10,00,000 crore.

### 2) Worked example

Market capitalisation (market cap):

```
Market cap = shares outstanding x price per share
RELIANCE   = 300 crore shares x ₹3,000  = 9,00,000 crore (₹9 lakh crore)
```

```python
from decimal import Decimal

shares = Decimal("300_00_00_000")      # 300 crore shares
price  = Decimal("3000")               # rupees
market_cap = shares * price
print("market cap (₹):", market_cap,
      "| in lakh crore:", (market_cap / Decimal("1_00_00_00_00_000")))
```

Output: `market cap (₹): 900000000000000 | in lakh crore: 9.00` — the number behind every "RELIANCE is worth ₹9 lakh crore" headline.

### 3) Common pitfalls

> **Pitfall:** treating **face value** (the printed nominal value, often ₹10 or ₹2) as the price. Face value is an accounting label; the market price is what trades. **Pitfall:** comparing companies by price per share — a ₹100 stock is not "cheaper" than a ₹3,000 stock; market cap is the comparable. **Pitfall:** thinking limited liability protects against price falls — it protects you from the *company's debts*, not from the market falling.

### 4) Key takeaways

- **Takeaway:** a share is a proportional ownership slice with voting rights and limited liability.
- **Takeaway:** company lifecycle: promoter → private equity → IPO → listed.
- **Takeaway:** market cap = shares × price is the true size of a company.
- **Takeaway:** face value, book value, and market value are three different numbers.

## Lesson 3.2 — Primary vs secondary markets

### 1) Concept

The **primary market** is where *new* money reaches the company: an **IPO** (first sale of shares to the public), an **FPO** (follow-on public offer — existing listed company selling more shares), a **rights issue** (new shares offered to existing shareholders, usually at a discount), or a **QIP** (qualified institutional placement — shares sold to large institutions). In every primary transaction, the company receives the money.

The **secondary market** is where investors trade *existing* shares with each other — on the NSE or BSE order book. When you buy RELIANCE at ₹3,050 today, the seller (another investor) receives your money; RELIANCE receives nothing. This is the fact most beginners find surprising: *the company raises money only in the primary market; daily stock movement is investor-to-investor*.

Why does the secondary market matter to companies at all? Because the secondary price *is* the price at which the next primary issue will happen, and because it makes shares liquid — owners can exit any time. **Price discovery** — buyers and sellers bidding until an order matches — happens continuously in the secondary market and is the heart of the next lesson.

### 2) Worked example

IPO price vs listing-day outcome:

```
Issue:  10 crore shares at ₹400 (company receives 10 cr x 400 = ₹4,000 crore)
Listing: shares open at ₹450, close at ₹465
Investor profit (sold at ₹450): 10 shares x (450 - 400) = ₹500
Company raised: 4,000 crore — unchanged by the listing-day price move
```

```python
from decimal import Decimal

issue_price = Decimal("400"); listing = Decimal("450")
shares_owned = Decimal("10")
company_proceeds = Decimal("10_00_00_000") * issue_price   # 10 crore shares
investor_profit = shares_owned * (listing - issue_price)
print("company raised:", company_proceeds)
print("investor profit on 10 shares:", investor_profit)
```

Output: `company raised: 40000000000`, `investor profit on 10 shares: 500`.

### 3) Common pitfalls

> **Pitfall:** believing the stock exchange "pays" the company — it never does; only the primary market does. **Pitfall:** confusing FPO, rights issue, and QIP — all primary, but aimed at the public, existing shareholders, and institutions respectively. **Pitfall:** expecting IPO returns to continue after listing — listing-day gains are a secondary-market event.

### 4) Key takeaways

- **Takeaway:** primary = company raises capital; secondary = investors trade with each other.
- **Takeaway:** IPO/FPO/rights/QIP are all primary-market events.
- **Takeaway:** the secondary market provides liquidity and sets the price for future primary issues.

## Lesson 3.3 — Exchanges and indices

### 1) Concept

An **exchange** is a regulated venue where orders meet. India's two equity exchanges are the **NSE** (National Stock Exchange, home of the **Nifty 50**) and the **BSE** (Bombay Stock Exchange, home of the **Sensex**). **MCX** is the commodity derivatives exchange (gold, silver, crude). Exchanges do not trade for themselves; they match investor orders and enforce rules set by the regulator, **SEBI**.

An **index** is one number built from many stocks, designed to represent "the market". The Nifty 50 is built from the 50 largest and most liquid NSE-listed stocks; the Sensex from 30 BSE stocks. Two construction ideas matter now (the exact formulas arrive in Semester 4):

- **Weighting:** each stock contributes in proportion to its **free-float market cap** (only shares actually available to trade count) — so RELIANCE moves the Nifty more than a small constituent does.
- **Rebalancing:** index committees review constituents periodically and drop/add stocks, so an index stays a fair picture of the market.

Because indices aggregate hundreds of prices into one number, "Nifty up 1.2%" is a fast way to summarise an entire market — which is why the daily markets read in M9 starts there.

### 2) Worked example

A simple mean-of-prices index vs a weighted index for two stocks:

```
Stock A: price 100, free-float shares 100 crore  (weight 100 x 100 = 10,000)
Stock B: price 400, free-float shares 25 crore   (weight 400 x 25  = 10,000)

Simple mean index    = (100 + 400) / 2 = 250
Free-float cap-weight = (100 x 10,000 + 400 x 10,000) / 20,000 = 250   (equal weights here)
If A doubles to 200:  simple mean = 300;  cap-weighted = (200x10000 + 400x10000)/20000 = 300
```

```python
from decimal import Decimal

a_p, b_p = Decimal("100"), Decimal("400")
w_a = Decimal("100_00_00_000") * a_p
w_b = Decimal("25_00_00_000") * b_p
mean = (a_p + b_p) / 2
widx = (w_a + w_b) / (Decimal("100_00_00_000") + Decimal("25_00_00_000"))
print("simple mean:", mean, "| free-float weighted:", widx)
```

Output: `simple mean: 250 | free-float weighted: 250` — two very different constructions can agree; they diverge when weights differ, which is why free-float matters.

### 3) Common pitfalls

> **Pitfall:** reading a high index level as "expensive" — index levels are scaled by a base value and are *not* comparable across markets or time without care. **Pitfall:** assuming every index is equal-weighted; Nifty/Sensex are market-cap weighted. **Pitfall:** confusing an index (a number) with an index *fund* (a product you can buy) — Lesson 5.3 separates them.

### 4) Key takeaways

- **Takeaway:** NSE/Nifty 50, BSE/Sensex, MCX/commodities — the Indian market's three pillars.
- **Takeaway:** free-float market-cap weighting makes big, tradeable companies dominate the index.
- **Takeaway:** periodic rebalancing keeps the index honest.
- **Takeaway:** the index is the daily weather report of the whole market.

## Lesson 3.4 — IPO process and the DRHP

### 1) Concept

An IPO is a heavily regulated process. The company appoints **merchant bankers** (investment banks) who run **book building**: a **price band** is announced (say ₹400–450 per share) and institutions and the public bid within it; the issuer then sets the final issue price where demand is strongest. Shares are **allotted** (rationed, often by lottery for retail investors when oversubscribed) and then **listed** on the exchange, where the price is free to move from day one.

The single best document in the process is the **DRHP** — the *Draft Red Herring Prospectus*. It contains the company's business, financial statements, risk factors, promoter details, and the objects of the issue. For a first-year analyst it is a complete education in a company — and it is why this course returns to it in Semester 3 (M7 reads its financials). "Red herring" is the warning that the offer price is *not yet fixed*; the DRHP is a *draft*, superseded by the final RHP and prospectus.

### 2) Worked example

Book building at work:

```
Issue size: 10 crore shares; price band ₹400–450
Retail bids: 3 crore shares at 400, 5 crore shares at 430, 2 crore shares at 450
Final price set at ₹440 (where demand clears); company raises 10 cr x 440 = ₹4,400 crore
```

```python
from decimal import Decimal

shares = Decimal("10_00_00_000")      # 10 crore shares
final_price = Decimal("440")
proceeds = shares * final_price
print("proceeds at ₹440:", proceeds)
```

Output: `proceeds at ₹440: 44000000000` (₹4,400 crore). Retail oversubscription is then handled by SEBI's allotment rules (minimum lot size, proportionate or lottery allotment).

### 3) Common pitfalls

> **Pitfall:** treating the DRHP as the final prospectus — it is a *draft*, and numbers can change before the RHP. **Pitfall:** skimming past the **risk factors** section — analysts read risk factors first, because that is where the company is forced to be honest. **Pitfall:** reading the "objects of the issue" without asking whether the company even needs the money.

### 4) Key takeaways

- **Takeaway:** IPO = merchant banker → book building → price band → allotment → listing.
- **Takeaway:** the DRHP is the richest public document about a company pre-listing.
- **Takeaway:** book building lets the market help discover the price.
- **Takeaway:** retail allotment is rationed; don't assume you get the shares you bid for.

## Lesson 3.5 — How markets work worldwide

### 1) Concept

Every developed capital market has the *same skeleton* — a **regulator**, **exchanges**, **brokers**, and a **clearing/settlement system** — with local names and rules. The US has the SEC (regulator), NYSE and Nasdaq (exchanges); the EU has ESMA (regulator) and Euronext (exchange); Asia has HKEX (Hong Kong), SGX (Singapore), the Tokyo Stock Exchange, and the Shanghai/Shenzhen exchanges (China). India's names: **SEBI** (regulator), NSE/BSE/MCX (exchanges), SEBI-registered **stock brokers**, and clearing via clearing corporations with **depositories** (NSDL/CDSL) — the M4 theme.

The international comparison matters for the IFMC syllabus: India has a *T+1 settlement cycle* (faster than the US's former T+2 standard), a *single-regulator* model (SEBI covers both markets and intermediaries), and a national clearing house under CCIL for government securities. Wherever you look, the same question applies: *who writes the rules, where do orders meet, who guarantees the trade completes, and where do ownership records live?*

### 2) Worked example

Reading a foreign market in Indian terms — converting a US price:

```
A US stock trades at $400.00; USD/INR = 83.50
Indian value = 400 x 83.50 = ₹33,400 per share
A 2% fall in the Nasdaq = same percentage move as a 2% fall in Nifty,
but in different currencies — always convert to a common currency before comparing
```

```python
from decimal import Decimal

usd_price = Decimal("400.00"); usd_inr = Decimal("83.50")
print("₹ value per share:", (usd_price * usd_inr).quantize(Decimal("0.01")))
print("percentages compare directly:", Decimal("2") == Decimal("2"), "(same % in any market)")
```

Output: `₹ value per share: 33400.00`.

### 3) Common pitfalls

> **Pitfall:** comparing index levels across countries (Sensex 80,000 vs S&P 500 5,000 means nothing — different bases and units). Compare *percentage moves*. **Pitfall:** forgetting that foreign investing adds **currency risk** on top of market risk. **Pitfall:** assuming settlement rules are identical everywhere — T+1 is India; check the local cycle.

### 4) Key takeaways

- **Takeaway:** every market = regulator + exchanges + brokers + clearing/depositories.
- **Takeaway:** US (SEC, NYSE/Nasdaq), EU (ESMA, Euronext), Asia (HKEX, SGX, Tokyo, Shanghai) mirror India's structure.
- **Takeaway:** compare markets in percentages and in one currency.
- **Takeaway:** currency risk is an extra layer when you invest abroad.

## Tantra Lab 3 — A synthetic index and "IPO" of a bar series

### Lab goal

Build a tiny two-stock "index" from synthetic NIFTY 50 and RELIANCE bars, and convince yourself (in writing) why a real free-float index is *not* a simple mean of prices.

### Code

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

### Expected output

`first 10 index levels: [Decimal('13340.00'), Decimal('13335.50'), ...]` — ten Decimal index levels around the *mean* of the NIFTY 50 close (≈ ₹24,000) and the RELIANCE close (≈ ₹2,600–2,700), i.e. ≈ ₹13,300–13,400.

### Hand-in checklist

- [ ] Lab script with the extension: first and last index level, and the two-stock index "return" printed in Decimal.
- [ ] Journal paragraph: why free-float weighting (M3 Lesson 3.3) changes the answer vs a simple mean.
- [ ] 2-page essay "How capital markets work worldwide" (IFMC item 7) covering a regulator, exchange, broker, and clearing/settlement role per region.
- [ ] Index level saved to `labs/lab3-index.csv` (optional but useful for M8 charting).

### Common errors

- **Index levels printed with int-looking values** — Nifty-50 closes are large (≈ ₹24,000) and RELIANCE smaller; a mean in the ₹13,000s is correct — don't "fix" it.
- **`zip` silently pairing mismatched lengths** — both calls use `days=120`, so lengths match; if you change one length, `zip` truncates silently.
- **Calling the mean "an index Nifty equals"** — it is illustrative only; the real Nifty uses free-float weights and a base, so the levels are unrelated.

## Practice problems

1. A company has 250 crore shares and trades at ₹1,200. Compute its market cap in lakh crore.
2. A company raises ₹2,500 crore in an IPO at ₹500 per share. How many shares were issued? If shares list at ₹620, what is the listing-day gain on 50 shares?
3. Why does the company receive nothing when its shares trade on the NSE at ₹1,500?
4. Two stocks: A at ₹50 with 200 crore free-float shares, B at ₹500 with 20 crore free-float shares. Show both the simple mean index and the free-float-weighted index.
5. List the four roles every capital market has (regulator, exchange, broker, clearing), giving the Indian name for each.
6. A US stock is $250; USD/INR = 83.0. What is the ₹ price? If the Nasdaq falls 1.5%, why can't you just subtract 1.5% from the ₹ price you computed?

### Solutions

1. `250 crore x ₹1,200 = ₹3,00,000 crore = ₹3 lakh crore`.
2. `2500 crore / 500 = 5 crore shares`; listing gain on 50 shares = `50 x (620 - 500) = ₹6,000`.
3. The secondary market is investor-to-investor; the company raised its capital once in the primary market (IPO) and is not a party to later trades.
4. Simple mean = `(50 + 500)/2 = 275`. Free-float weights: A = `50 x 200 = 10,000`, B = `500 x 20 = 10,000`, equal weights → weighted index = 275 too (a coincidence of this design; weights diverge as prices/float change).
5. Regulator = SEBI, exchange = NSE/BSE/MCX, broker = SEBI-registered stock broker, clearing/settlement = clearing corporation + depositories (NSDL/CDSL).
6. `250 x 83.0 = ₹20,750`. A 1.5% fall in the USD price does *not* directly translate — the ₹ price also moves with USD/INR; convert the final US price to ₹ at the *current* rate.

## Quiz bank

| Question | A | B | C | D | Answer |
|---|---|---|---|---|---|
| A stock is best described as: | a loan to a company | an ownership share | a bank deposit | a bond | B |
| In a secondary-market sale, the buyer's money goes to: | the company | the exchange | the seller | SEBI | C |
| An IPO is a: | secondary-market trade | primary-market issue | derivative | bank loan | B |
| The Nifty 50 index is weighted by: | equal weight | number of shares | free-float market cap | alphabet | C |
| The document a company files *before* the final RHP is the: | DRHP | balance sheet | red herring receipt | contract note | A |
| The Indian equity regulator is: | RBI | SEBI | NSE | SBI | B |
| MCX is the exchange for: | only equities | commodity derivatives | only bonds | only forex | B |
| Limited liability means a shareholder: | can lose more than invested | never loses anything | loses at most the amount invested | is guaranteed dividends | C |
| Market cap of 100 crore shares at ₹500 is: | ₹500 crore | ₹5,000 crore | ₹50,000 crore | ₹5 lakh crore | C |
| India's settlement cycle is: | T+5 | T+2 | T+1 | T+0 | C |

## Glossary

- **Stock / equity share** — a unit of ownership in a company.
- **Limited liability** — the shareholder's loss is capped at the amount invested.
- **IPO / FPO** — first / follow-on public offer of shares to the public.
- **Primary market** — where companies raise new capital.
- **Secondary market** — where investors trade existing securities.
- **Market cap** — shares outstanding × price per share.
- **Index** — one number summarising many prices (Nifty 50, Sensex).
- **Free float** — shares actually available for trading (excludes promoter locked-in holdings).
- **Book building** — the price-discovery process of an IPO via a price band.
- **DRHP** — Draft Red Herring Prospectus: the company's full disclosure document pre-IPO.
- **Price discovery** — the process by which buy and sell orders meet to set a price.

## Reading assignment

From the [Reading & Resource List](../appendices/reading-list.md), browse the NSE/BSE/MCX educational material and exchange circulars for the primary/secondary market mechanics, and keep an annual report or DRHP of a listed company handy for M7. The platform reference `tantra-examples/examples/01_loading_data.py` shows the live bar data you used in the lab.

## Assessment reminder

M3 is graded by the **instruments/markets/IPO quiz** and the **2-page global markets essay**, both continuous assessment; the essay rubric rewards naming the regulator–exchange–broker–clearing skeleton per region. Index basics from Lesson 3.3 reappear in the S1 mid-term and in every later index discussion. See [Assessment & Grading Scheme](../front/assessment.md).

**Next:** [M4 — Market Microstructure & Participants](m4-microstructure.md)
