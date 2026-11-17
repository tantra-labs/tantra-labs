# M8 — Currency & Fixed Income Markets

> **Weeks 60–61 · 16 hrs · PLO-2, PLO-9 · Core:** NIFM Ch 4; PGP T2-203

## Learning outcomes

- Explain FX pairs, factors driving exchange rates, and RBI's role.
- Price a bond: YTM, duration, and price-yield relationship.
- Describe the yield curve and its information content.
- Place fixed income and currency in the instrument taxonomy (S1-M5).

## Prerequisites

- [M5](m5-forwards-futures.md): the cost-of-carry logic behind FX forwards and the margin/MTM machinery of futures.
- [M3 of Semester 4](m3-portfolio-theory.md): the risk-free rate and discounting — bond pricing is discounting in disguise.
- [M1 of Semester 3](../s3/m1-financial-statements.md): the instrument taxonomy and what "fixed income" means as an asset class.
- Decimal exponent comfort: `(1 + y) ** t` for cash-flow discounting.

## Lesson 8.1 — Currency market basics

### 1) Concept

A currency pair is written base/quote: in **USD/INR**, the *base* is USD and the *quote* is INR, so the rate 82.50 means 1 USD buys ₹82.50. A **rise in USD/INR** is a *depreciation of the rupee* — each dollar costs more rupees. Getting this reading right is the single most important habit in FX work: "USD/INR up" is bad news for Indian importers and good news for IT exporters whose revenue is in dollars.

Exchange rates are driven by fundamentals and flows. **Interest-rate differentials** pull capital toward the higher-yielding currency (a 6% repo differential attracts carry flows into INR assets). The **trade balance** — exports minus imports — matters: an importer-heavy economy needs dollars, weakening the rupee. **Capital flows** (FII/FPI equity and debt flows, FDI) move the rate on daily time scales. **RBI's role**: India runs a **managed float** — the rupee floats, but the RBI intervenes through its **foreign-exchange reserves** (buying/selling dollars) to smooth disorderly moves. The RBI's policy rate (the **repo rate**) also feeds the interest-rate differential. For the analyst, the FX view is a *relative* view: it depends on India vs the world, not India alone.

### 2) Worked example

USD/INR moves from 82.50 to 83.60 in a week.

```
Move = 83.60 − 82.50 = +1.10 rupees per dollar
Percent change = 1.10/82.50 ≈ +1.33%
```

An IT exporter with $1 million of monthly revenue: the rupee's 1.33% fall raises the rupee value of the dollar revenue by 1.33%.

```python
from decimal import Decimal
rate0, rate1 = Decimal("82.50"), Decimal("83.60")
move = rate1 - rate0
pct = move / rate0 * Decimal(100)
print("move:", move, "pct:", pct)    # +1.10, ≈ +1.33%
```

### 3) Common pitfalls

> **Pitfall:** Misreading the pair direction — USD/INR *up* = rupee *down*. State it in rupee terms to avoid ambiguity.
>
> **Pitfall:** Ignoring the RBI — a managed float means intervention can disconnect the rate from fundamentals temporarily.
>
> **Pitfall:** Treating FX as a one-driver story — differentials, trade, flows, and policy interact.
>
> **Pitfall:** Using `float` for rates — a currency is money; Decimal only.

### 4) Key takeaways

- **Takeaway:** USD/INR up = rupee depreciation; importers hurt, IT exporters benefit.
- **Takeaway:** Drivers: rate differentials, trade balance, capital flows, RBI policy.
- **Takeaway:** India runs a managed float backed by FX reserves.
- **Takeaway:** FX is a relative view — India vs the world.

## Lesson 8.2 — Currency derivatives (India)

### 1) Concept

India trades **USD/INR futures and options** on the exchanges, alongside pairs like EUR/INR and GBP/INR. Contracts are standardised with fixed **lot sizes** (USD 1,000 per contract), monthly expiries, cash settlement, and the full margin/MTM machinery of M5. The natural hedgers are the two ends of the trade balance: an **importer** who must pay dollars *buys* USD/INR futures (locking the rate they pay); an **exporter** who will receive dollars *sells* them (locking the rate they earn). The forward price follows M5's cost-of-carry logic: `F = S0·(1 + (r_INR − r_USD)·T)` approximately — the differential between the two currencies' interest rates replaces the single rate.

Currency moves are also an *equity* story. An IT company books revenue in dollars; when the rupee weakens, rupee-reported revenue rises — the reason IT stocks (TCS, INFY) often rally with a falling rupee. Conversely, firms with dollar *costs* or dollar *debt* suffer. An equity analyst must therefore track USD/INR as a sector factor, and a **hedge** view: IT exporters may *choose* to hedge a fraction of receivables (M7's machinery applied to FX) — and the market prices that choice into guidance.

### 2) Worked example

An importer must pay $50,000 in one month. Current USD/INR spot 83.00; 1-month futures 83.40. How many contracts (lot $1,000) and what rate is locked?

```
Contracts = 50,000 / 1,000 = 50
Locked outflow = 50,000 × 83.40 = ₹41,70,000
```

Without the hedge, if the spot is 84.20 at payment time, the unhedged outflow would be 50,000 × 84.20 = ₹42,10,000 — the hedge saved ₹40,000. (Offset by the futures gain on 50 contracts.)

```python
from decimal import Decimal
amount = Decimal("50000"); lot = Decimal("1000")
fut = Decimal("83.40")
contracts = amount / lot
locked = amount * fut
print("contracts:", contracts)     # 50
print("locked outflow:", locked)   # ₹41,70,000
```

### 3) Common pitfalls

> **Pitfall:** Getting the hedge side backwards — importers buy (they need dollars), exporters sell (they have dollars).
>
> **Pitfall:** Forgetting lot size — USD/INR lots are per 1,000 USD, not per dollar.
>
> **Pitfall:** Pricing the forward with one interest rate — FX carry uses the *differential* `r_INR − r_USD`.
>
> **Pitfall:** Ignoring the equity link — an IT-equity recommendation without the FX view is incomplete.

### 4) Key takeaways

- **Takeaway:** Importers buy USD/INR futures; exporters sell them.
- **Takeaway:** FX forwards price on the interest-rate differential.
- **Takeaway:** Lot = USD 1,000; contracts = exposure ÷ lot.
- **Takeaway:** USD/INR is a sector factor for IT and import-cost equities.

## Lesson 8.3 — Bond pricing and YTM

### 1) Concept

A **bond** is a loan that pays a fixed **coupon C** each period and returns the **face value FV** at maturity. Its **price** is the present value of all those cash flows, discounted at the market yield `y`:

```
Price = Σ C/(1+y)^t + FV/(1+y)^n
```

Every term is a discounting exactly like M3's. The result is the **inverse price-yield relationship**: when yields rise, the discount factors `1/(1+y)^t` shrink, so *prices fall* — and the longer the maturity, the harder they fall. **YTM** (yield to maturity) is the answer to the reverse question: "what single discount rate makes this price exactly fair?" — i.e., the bond's **IRR**. Quote a bond price and you have implicitly quoted a yield; quote a yield and you have implied a price.

**Duration** measures price sensitivity — the weighted-average time to receive the cash flows:

```
Duration ≈ Σ [t·PV(CF_t)] / Price
```

Each cash flow's present value is weighted by the year `t` in which it arrives, summed, and divided by the price. **Modified duration** is the rule of thumb `%ΔPrice ≈ −ModifiedDuration × ΔYield`: a modified duration of 6 means a 1% yield rise knocks ≈ 6% off the price. Duration is the bond world's beta — the number every fixed-income risk conversation starts from.

### 2) Worked example

A 5-year bond, 8% coupon, face ₹1,000. Price at yield 10% (annual coupons):

```
Price = 80/(1.10) + 80/(1.10)² + 80/(1.10)³ + 80/(1.10)⁴ + 80/(1.10)⁵ + 1000/(1.10)⁵
     = 72.73 + 66.12 + 60.11 + 54.64 + 49.67 + 620.92 ≈ 924.18
```

At yield 8% the price would be ≈ 1,000 (coupon = yield); at 12% ≈ 855.8. Inverse relationship confirmed: yield up, price down.

```python
from decimal import Decimal

def bond_price(coupon, face, yield_, years):
    p = Decimal(0)
    for t in range(1, years + 1):
        p += coupon / (Decimal(1) + yield_) ** t
    p += face / (Decimal(1) + yield_) ** years
    return p

print(bond_price(Decimal("80"), Decimal("1000"), Decimal("0.10"), 5))   # ≈ 924.18
print(bond_price(Decimal("80"), Decimal("1000"), Decimal("0.08"), 5))   # ≈ 1000
print(bond_price(Decimal("80"), Decimal("1000"), Decimal("0.12"), 5))   # ≈ 855.8
```

Answer: ≈ 924.18 at 10%, ≈ 1,000 at 8%, ≈ 855.8 at 12% — the inverse price-yield curve over the three yields.

### 3) Common pitfalls

> **Pitfall:** Pricing at the coupon rate and being surprised the price equals face — that is the definitional anchor, not a coincidence.
>
> **Pitfall:** Off-by-one in the exponent — the last coupon arrives at `t = n` together with the face value.
>
> **Pitfall:** Confusing duration with maturity — a 5-year zero-coupon bond has duration 5; a 5-year coupon bond has duration < 5 (cash arrives earlier).
>
> **Pitfall:** Reading modified duration's sign — price change is *negative* for a yield rise.

### 4) Key takeaways

- **Takeaway:** Price = PV of coupons + PV of face; yield up → price down.
- **Takeaway:** YTM is the bond's IRR — the single rate that prices it fairly.
- **Takeaway:** Duration = weighted-average cash-flow time; modified duration ≈ % price change per 1% yield move.
- **Takeaway:** Long duration = high sensitivity — the bond's beta.

## Lesson 8.4 — Yield curves and credit

### 1) Concept

Plot yields against maturity and you get the **yield curve**. A **normal (upward-sloping)** curve — short rates below long rates — is the healthy default: investors demand more to lend for longer. An **inverted curve** — short rates above long — has historically preceded recessions: the market expects the central bank to cut later, so long yields fall below today's high short rates. A **flat** curve signals transition and uncertainty. In India, watch the repo rate at the short end and the 10-year G-sec as the benchmark long yield; the **term premium** (extra yield for length) is what steepens the curve.

**Credit spreads** are the other axis: a corporate bond yields more than a G-sec of the same maturity because the issuer can default. The **spread = corporate YTM − G-sec YTM** compensates for that default risk. Rating agencies (CRISIL, ICRA, CARE, India Ratings) grade that risk from AAA (safest) down to D (default) — and a *downgrade* widens the spread, which mechanically *lowers* the bond's price (Lesson 8.3), which is how ratings hit portfolios. For the analyst, the two questions are always: where on the curve, and how much credit risk premium am I being paid?

### 2) Worked example

The 10-year G-sec yields 7.0%; an AAA corporate yields 7.6%; a BBB corporate yields 9.1%.

```
AAA spread = 7.6 − 7.0 = 0.6 points (60 bps)
BBB spread = 9.1 − 7.0 = 2.1 points (210 bps)
BBB vs AAA = 2.1 − 0.6 = 1.5 points (150 bps for the rating gap)
```

The BBB bond pays 150 bps more than AAA for the extra default risk.

```python
from decimal import Decimal
g = Decimal("0.070"); aaa = Decimal("0.076"); bbb = Decimal("0.091")
print("AAA spread:", (aaa - g) * Decimal(100), "bps")    # 60
print("BBB spread:", (bbb - g) * Decimal(100), "bps")    # 210
```

### 3) Common pitfalls

> **Pitfall:** Reading an inverted curve as "rates will rise" — history's message is the opposite: it is a recession/rate-cut warning.
>
> **Pitfall:** Quoting a spread without its benchmark — "6.0" bps is meaningless unless the G-sec tenor matches.
>
> **Pitfall:** Treating ratings as permanent — downgrades widen spreads and hit prices.
>
> **Pitfall:** Confusing the term premium with the credit spread — one pays for time, the other for default risk.

### 4) Key takeaways

- **Takeaway:** Normal = upward, inverted = recession warning, flat = transition.
- **Takeaway:** Credit spread = corporate YTM − G-sec YTM; the price of default risk.
- **Takeaway:** Downgrades widen spreads and lower prices.
- **Takeaway:** Two fixed-income questions: where on the curve, and how much spread.

## Lesson 8.5 — Alternatives overview

### 1) Concept

**Alternatives** are the asset classes that are neither plain equity nor plain bonds. **REITs** (Real Estate Investment Trusts) and **InvITs** (Infrastructure Investment Trusts) hold rent-producing property and infrastructure; they trade like equity but pay out most of their cash flows as distributions — a hybrid with bond-like income and equity-like price risk. **Gold** behaves like a store of value with low correlation to equities — the classic diversifier from M3. **Commodities** (crude, metals, agri) are real assets whose prices follow supply/demand, storage, and carry logic (M5). 

Each sits in a different role in a portfolio: REITs/InvITs for income and inflation-linked real assets, gold for tail-risk diversification and crisis hedging, commodities for inflation and carry exposure. The S5 capstone tracks allocate across these sleeves; the S4 point is simpler: alternatives are *not* "exotic equities" — each has its own pricing logic, risk drivers, and portfolio role, and none should be bought because "it went up."

### 2) Worked example

A ₹10 lakh portfolio rebalanced to 70% equity / 20% fixed income / 10% gold. Compare the 10% gold sleeve to a 10% extra-equity sleeve.

```
Gold sleeve = 0.10 × 10,00,000 = ₹1,00,000
If gold's correlation with the equity book is ~0.1 (vs 1.0 for the extra
equity), the gold sleeve diversifies the tail without a full unit of equity
risk. The 10% gold allocation is insurance; the 10% extra equity is more of
the same bet.
```

```python
from decimal import Decimal
pv = Decimal("10_00_000")
gold = Decimal("0.10") * pv
print("gold sleeve:", gold)     # ₹1,00,000
```

### 3) Common pitfalls

> **Pitfall:** Buying alternatives for momentum ("gold is up") instead of portfolio role.
>
> **Pitfall:** Treating REITs as "safe bonds" — they carry real-estate and interest-rate risk.
>
> **Pitfall:** Forgetting alternatives have their own costs (fund expenses, storage for gold, wide spreads).
>
> **Pitfall:** Skipping the correlation check (M2) — an "alternative" that correlates 0.9 with your equity book adds no diversification.

### 4) Key takeaways

- **Takeaway:** REITs/InvITs = income real assets; gold = tail hedge; commodities = real-asset/carry exposure.
- **Takeaway:** Each alternative has its own pricing logic and risk drivers.
- **Takeaway:** Correlation, not label, decides whether an alternative diversifies.
- **Takeaway:** Allocate by role, never by recent performance.

## Tantra Lab 8 — Bond price and duration in Decimal

### Lab goal

Price a bond at three yields to verify the inverse price-yield relationship, then compute duration by hand in Decimal and summarise a week of USD/INR with three named drivers.

### Code

The verified core snippet is unchanged; the extension adds duration computed from the same cash flows.

```python
from decimal import Decimal

def bond_price(coupon, face, yield_, years):
    p = Decimal(0)
    for t in range(1, years + 1):
        p += coupon / (Decimal(1) + yield_) ** t
    p += face / (Decimal(1) + yield_) ** years
    return p

print(bond_price(Decimal("80"), Decimal("1000"), Decimal("0.10"), 5))

# --- extend: duration = Σ [t·PV(CF_t)] / Price -----------------------------
def duration(coupon, face, yield_, years):
    num = Decimal(0)
    for t in range(1, years + 1):
        pv = coupon / (Decimal(1) + yield_) ** t
        num += Decimal(t) * pv
    pv_face = face / (Decimal(1) + yield_) ** years
    num += Decimal(years) * pv_face
    return num / bond_price(coupon, face, yield_, years)

d = duration(Decimal("80"), Decimal("1000"), Decimal("0.10"), 5)
print("duration:", d)             # ≈ 4.20 years (cash-weighted average)
print("price @8%:", bond_price(Decimal("80"), Decimal("1000"), Decimal("0.08"), 5))
print("price @12%:", bond_price(Decimal("80"), Decimal("1000"), Decimal("0.12"), 5))
```

**Task:** verify the inverse price-yield relationship by re-pricing the bond at yield 8%, 10%, and 12%; compute duration by hand; then fetch an FX series in `tantra_examples` (or the `markets/india` module) and summarize one week of `USD/INR` moves with three drivers named.

### Expected output

The script prints ≈ 924.18 for the 10%-yield price, a duration ≈ 4.2 years (less than the 5-year maturity, because coupons arrive early), and prices ≈ 1,000 and ≈ 855.8 at 8% and 12% — demonstrating the inverse relationship. The FX summary should list daily USD/INR closes and three named drivers (e.g. RBI intervention, US rate expectations, oil prices).

### Hand-in checklist

- [ ] Bond priced at 8%, 10%, 12% with the inverse relationship stated.
- [ ] Duration computed by hand and by the script, agreeing to reasonable precision.
- [ ] One sentence on why duration < maturity for a coupon bond.
- [ ] One-week USD/INR summary with three named drivers.
- [ ] Modified-duration estimate: price change per 1% yield move.

### Common errors

- **Float exponent inputs** — `years` is an `int` for the loop; `yield_` and coupons must be `Decimal`.
- **Off-by-one in `range(1, years+1)`** — `range(1, years)` skips the final coupon year.
- **Duration weighting** — each PV is multiplied by its *year t*; forgetting the weight collapses duration toward maturity.
- **FX unit confusion** — report USD/INR in rupees per dollar and label the direction (rupee deprec/apprec).

## Practice problems

1. A 3-year bond, 6% coupon, face 1,000. Price it at yield 8%.
2. State the inverse price-yield relationship and give the intuition in one sentence.
3. Same bond re-priced at yield 6%: what do you expect the price to be, and why?
4. A zero-coupon 5-year bond (no coupons) at yield 10%: compute its price. What is its duration, and why?
5. Modified duration ≈ 5.5. Yields rise 0.5%. Approximately what % price change?
6. G-sec 10Y yields 7.2%; a corporate yields 8.5%. What is the credit spread in bps? What compensates for it?
7. An IT exporter holds a dollar receivable. Should they buy or sell USD/INR futures? Why?
8. (Short code) Using the Lab 8 `bond_price`, price a 10-year 7% coupon bond at yields 7%, 9%, and 11%.

### Solutions

1. Price = 60/1.08 + 60/1.08² + 60/1.08³ + 1000/1.08³ = 55.56 + 51.44 + 47.63 + 793.83 ≈ 948.46.
2. When yields rise, every discount factor `1/(1+y)^t` shrinks, so the PV of future cash flows — and hence the price — falls.
3. ≈ 1,000: when the market yield equals the coupon rate, the bond prices exactly at face (the "par" anchor).
4. Price = 1000/1.10⁵ ≈ 620.92; duration = 5 years, because the *only* cash flow arrives at year 5, so the weighted-average time is 5.
5. ≈ −5.5 × 0.5 = −2.75% (price falls ≈ 2.75%).
6. Spread = 8.5 − 7.2 = 1.3 points = 130 bps; it compensates the lender for default (credit) risk.
7. Sell — the exporter will receive dollars and wants to lock the rupee value; selling locks the conversion rate and hedges a depreciation of USD/INR in their favour... no: a rising USD/INR is good for them, so they hedge against a *fall* in USD/INR (rupee appreciation). Selling USD/INR futures gains when USD/INR falls, offsetting the lost rupee value of the receivable.
8. Run the code: 7% → ≈ 1,000; 9% and 11% → below par, decreasing (≈ 870 and ≈ 764).

## Quiz bank

| Question | A | B | C | D | Answer |
|---|---|---|---|---|---|
| In USD/INR = 82.50, the base currency is | INR | USD | both | neither | B |
| A rising USD/INR is | rupee appreciation | rupee depreciation | RBI buying INR | a recession | B |
| India's FX regime is | a hard peg | a managed float | a dollar standard | free float only | B |
| Importers hedging payables should | sell futures | buy futures | buy options only | do nothing | B |
| Bond price = | ΣC/(1+y)^t + FV/(1+y)^n | ΣC×(1+y)^t | FV×(1+y)^n | C/n + FV | A |
| When yields rise, bond prices | rise | fall | stay flat | double | B |
| YTM is the bond's | coupon | IRR | rating | duration | B |
| Duration is the | maturity | weighted-average cash-flow time | coupon rate | spread | B |
| A normal yield curve is | downward | upward | flat always | inverted | B |
| An inverted curve historically warns of | inflation | recession | boom | default | B |
| The credit spread compensates for | time | default risk | inflation | liquidity only | B |
| An AAA-to-BBB rating gap typically means | lower spread | wider spread | same spread | no spread | B |
| A zero-coupon bond's duration equals its | coupon | maturity | yield | price | B |

## Glossary

- **Currency pair** — base/quote rate; USD/INR = rupees per dollar.
- **Managed float** — a floating rate smoothed by central-bank intervention.
- **FX reserves** — the RBI's stock of foreign assets used to intervene.
- **Repo rate** — the RBI's policy rate; the short end of the curve.
- **Bond price** — PV of coupons and face value at the market yield.
- **YTM** — the discount rate that makes the price fair (the bond's IRR).
- **Inverse price-yield relationship** — yield up → price down.
- **Duration** — `Σ[t·PV(CF_t)]/Price`, the cash-weighted average time.
- **Modified duration** — ≈ % price change per 1% yield change.
- **Yield curve** — yields vs maturity; normal/inverted/flat.
- **Credit spread** — corporate YTM − G-sec YTM; the price of default risk.
- **REITs/InvITs** — exchange-traded real-estate/infrastructure income trusts.
- **Alternatives** — gold, commodities, real assets; each with its own pricing logic.

## Reading assignment

Study NIFM Chapter 4 (currency and fixed income) and PGP T2-203 in the [reading list](../appendices/reading-list.md). Use `tantra_examples` data or the `markets/india` module to practise fetching a USD/INR series for the weekly summary.

## Assessment reminder

This module feeds the bond-pricing worksheet (three yields + duration) and the one-page FX weekly summary; submit both per the [assessment plan](../front/assessment.md), and keep your Decimal scripts in the lab journal.

**Next:** [M9 — Research Report Writing & Analyst Presentations](m9-research-report-writing.md)
