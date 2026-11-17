# M1 — Economics for Securities Markets

> **Weeks 33–35 · 24 hrs · PLO-6 · Core:** NIFM Ch 17, 31; PGP T2-201; IFMC items 9–13, 67–69

## Learning outcomes

- Explain GDP, IIP, CPI/WPI inflation, and PMI and what each tells the market.
- Explain how monetary policy (repo, reverse repo, CRR, SLR) transmits to stocks.
- Connect fiscal policy and global events (Eurozone, oil, IT/visa, US Fed) to
  Indian markets.
- Read an economic calendar and interpret one policy decision end to end.
- Convert nominal to real numbers using a deflator, and read percentage moves
  in macro indicators in `Decimal` (never float).

## Prerequisites

- [S1-M3 — Markets](../s1/m3-markets.md): the difference between equity, debt,
  and derivatives; who SEBI and the RBI are.
- [S1-M7 — Financial statements](../s1/m7-financial-statements.md): reading
  revenue and profit; the banking lens (NIM, NPA, CASA, CAR) that Lesson 1.5
  leans on.
- [S1-M1 — Math](../s1/m1-math.md): percentages, averages, and index numbers
  so the growth-rate arithmetic in this module feels familiar.
- The money-is-not-float discipline from Semester 1: every price and rate in
  code will be `decimal.Decimal`.

## Lesson 1.1 — Growth indicators

### 1) Concept

A country's growth is measured first by **GDP (Gross Domestic Product)** — the
total value of everything produced inside the country in a period. The identity
to memorise is:

```
GDP = C + I + G + (X − M)
```

where **C** = private consumption (what households buy), **I** = investment
(capex by firms plus housing), **G** = government spending, and **(X − M)** =
exports minus imports (net trade). When the RBI and the MOSPI report "GDP grew
8.2%", they mean real (inflation-adjusted) GDP growth *year on year* (YoY), and
markets react to the *surprise* — the gap between the actual number and the
consensus forecast — not the number itself.

**IIP (Index of Industrial Production)** is the manufacturing pulse. It tracks
output of factories, mines, and electricity. It is a *coincident* indicator: it
confirms a trend already under way. A rising IIP tells you the industrial
engine is running; a falling one tells you demand is weak.

The classic tension: good growth is *usually* good for equities (higher future
earnings), but if growth comes with inflation, the central bank may raise rates,
and higher rates compress equity valuations (Lesson 1.4). So a very strong GDP
print can actually send the Nifty down. Always ask: *growth at what price?*

### 2) Worked example

Nominal GDP in FY24 was ₹295 lakh crore; in FY25 it was ₹331 lakh crore. The GDP
deflator rose from 100 to 104. Find real GDP growth.

```
Real GDP (FY25) = Nominal GDP (FY25) / (Deflator / 100)
Real growth YoY = (Real FY25 − Real FY24) / Real FY24
```

```python
from decimal import Decimal
nominal_24 = Decimal("295")            # lakh crore
nominal_25 = Decimal("331")
deflator = Decimal("104")              # 100 -> 104, so 4% price rise
real_25 = nominal_25 / (deflator / Decimal(100))
real_growth = (real_25 - nominal_24) / nominal_24
print("Real GDP FY25:", real_25, "lakh crore")
print("Real growth YoY ≈", (real_growth * 100).quantize(Decimal("0.01")), "%")
```

Answer: Real GDP ≈ ₹318.27 lakh crore, so real growth ≈ 7.89% — well below the
nominal 12.2% jump. The difference of ~4.3 points is inflation.

### 3) Common pitfalls

> **Pitfall:** Quoting nominal growth as if it were real growth. Nominal "12%
> growth" with 6% inflation is really ~5.7% real growth. Always deflate.
> Also, comparing a quarterly GDP print *annualised* against a *YoY* number —
> Indian GDP is reported YoY; mixing the two conventions overstates moves. And
> in code, never compute `growth = (new - old) / old` with `float` prices —
> keep `Decimal`.

### 4) Key takeaways

- **Takeaway:** GDP is a four-part identity; growth is real, deflated, and YoY.
- **Takeaway:** IIP is the coincident industrial pulse; GDP is the headline.
- **Takeaway:** Markets trade the *surprise* and the *inflation consequence*,
  not just the level.

## Lesson 1.2 — Inflation

### 1) Concept

**Inflation** is the rate at which prices rise. India tracks two headline
numbers. **CPI (Consumer Price Index)** measures the retail prices households
actually pay — food has a large weight (~46%), which is why the monsoon and
vegetable prices matter to the RBI. **WPI (Wholesale Price Index)** tracks
prices at the wholesale/factory gate. **Core inflation** excludes volatile food
and energy; **headline** includes everything.

The RBI is the inflation *targeter*: since 2016 its statutory mandate is to
keep **headline CPI between 2% and 6%**, with 4% as the middle. When CPI runs
above the band, the RBI raises the **repo rate** — the rate at which it lends
to banks — which raises borrowing costs across the economy and cools demand.

Inflation is *two-edged* for equities. The **revenue tailwind**: companies can
push through price hikes, so nominal earnings rise with prices. The
**discount-rate headwind**: higher inflation forces higher interest rates, which
raises the discount rate used to value future earnings (M6–M7), pulling stock
prices down. Which edge wins depends on how much of the inflation the company
can pass through and how rate-sensitive its valuation is. Banks *like* moderate
inflation and rising rates (NIMs expand); long-duration growth stocks dislike
them.

### 2) Worked example

A consumer basket costs ₹200 one year and ₹212 the next. Compute CPI inflation.
Then convert a 5.5% repo-rate world into a *real* repo rate.

```python
from decimal import Decimal
basket_0, basket_1 = Decimal("200"), Decimal("212")
cpi_inflation = (basket_1 - basket_0) / basket_0
repo = Decimal("0.055")
real_repo = repo - cpi_inflation
print("CPI inflation:", (cpi_inflation * 100).quantize(Decimal("0.01")), "%")
print("Real repo rate ≈", (real_repo * 100).quantize(Decimal("0.01")), "%")
```

Answer: CPI inflation = 6.0%; real repo rate = −0.5% (negative real rates —
the RBI is under pressure to hike). If the repo rate is 6.50% instead, the real
rate is +0.5%: a "neutral-to-restrictive" stance that pressure-tests equities.

### 3) Common pitfalls

> **Pitfall:** Comparing CPI and WPI as if they were the same basket — food and
> fuel weights differ hugely, so they can point in opposite directions.
> Confusing *core* with *headline* in a news headline. And treating one CPI
> print as a trend — the RBI targets a *4-quarter* average; a single high month
> is a data point, not a policy change.

### 4) Key takeaways

- **Takeaway:** CPI is the RBI's legal target (2–6%, midpoint 4%); repo rate is
  the lever.
- **Takeaway:** Core vs headline tells you whether the inflation is *durable*.
- **Takeaway:** Inflation's two edges — earnings tailwind vs discount-rate
  headwind — decide which sectors win.

## Lesson 1.3 — PMI and business cycles

### 1) Concept

**PMI (Purchasing Managers' Index)** is a monthly survey of purchasing managers
at ~500 manufacturing firms. It is a **diffusion index**: managers answer whether
new orders, output, employment, supplier deliveries, and inventories rose, fell,
or stayed the same versus last month. The index is built as:

```
PMI = 0.40 × New Orders + 0.30 × Output + 0.15 × Employment
      + 0.075 × Supplier Deliveries + 0.075 × Inventories
```

with each sub-index read as (share reporting "up") + 0.5 × (share reporting
"same"). **PMI > 50 means expansion, < 50 means contraction, 50 means no
change.** The India Manufacturing PMI has hovered in the high-50s in recent
years — one of the strongest readings in Asia.

PMI is a **leading** indicator: it tells you what purchasing managers are
*ordering now*, which shows up in IIP and GDP months later. IIP is coincident —
it confirms what is already happening. That ordering — leading, coincident,
lagging — is what an **economic calendar** is organised around: GDP and IIP are
released with a lag, PMI arrives the first week of the following month, and the
RBI's **MPC (Monetary Policy Committee)** policy decisions arrive on a fixed
6-weekly schedule.

The **business cycle** is the repeating sequence: **expansion → peak → recession
(trough) → recovery**. Cyclical sectors (autos, metals, capital goods, banks)
amplify the cycle; **defensive** sectors (FMCG, pharma, IT at times) hold up in
downturns because demand for soap, medicines, and outsourced services is
inelastic. Knowing where you are in the cycle tells you which sector basket to
favour.

### 2) Worked example

In a survey, the shares reporting "up / same / down" for each component produce
the sub-index values below. Build the PMI:

```python
from decimal import Decimal
new_orders   = Decimal("62")   # sub-index, >50 = expansion
output       = Decimal("60")
employment   = Decimal("55")
suppliers    = Decimal("52")   # higher = slower deliveries = busier
inventories  = Decimal("54")
pmi = (Decimal("0.40") * new_orders + Decimal("0.30") * output
       + Decimal("0.15") * employment + Decimal("0.075") * suppliers
       + Decimal("0.075") * inventories)
print("PMI ≈", (pmi).quantize(Decimal("0.1")))
```

Answer: PMI ≈ 58.0 — comfortably above 50, so manufacturing is expanding. If
new orders fall below 50 next month, PMI will dip toward the no-change line and
markets will start pricing a slowdown in IIP two quarters out.

### 3) Common pitfalls

> **Pitfall:** Reading "PMI fell" as contraction. PMI *falling from 59 to 56*
> is still expansion — only crossing **50** flips the sign. Treating the
> *level* as a growth rate: PMI 58 is not "58% growth". And ignoring the new
> orders sub-index, which is the most forward-looking piece.

### 4) Key takeaways

- **Takeaway:** PMI > 50 expansion, < 50 contraction; it leads IIP by months.
- **Takeaway:** Business cycle position picks the sector basket (cyclical vs
  defensive).
- **Takeaway:** Read the economic calendar as leading/coincident/lagging.

## Lesson 1.4 — Monetary & fiscal policy

### 1) Concept

The RBI's toolkit for steering liquidity and interest rates:

| Tool | What it is | Direction |
|---|---|---|
| **Repo rate** | Rate RBI lends to banks (LAF) | Hike = dearer money |
| **Reverse repo** | Rate RBI pays banks for parking money | Hike = banks park more |
| **CRR (Cash Reserve Ratio)** | % of deposits banks must hold as cash with RBI | Hike = drains liquidity |
| **SLR (Statutory Liquidity Ratio)** | % of deposits to hold in G-secs/gold | Hike = locks funds |
| **MSF** | Emergency lending window above repo | Used when repo taps exhausted |

The **transmission mechanism** runs like this:

```
Repo rate ↑ → bank lending rates ↑ → credit demand ↓
            → bond yields ↑ (prices ↓) → discount rate ↑
            → present value of future earnings ↓ → equity valuations ↓
```

That last step is the *formal* link to this semester: the discount rate you
will meet in M6 (WACC) and M7 (DCF) is anchored on the risk-free rate, which
tracks G-sec yields, which track the repo rate. A 50 bps repo hike raises the
risk-free rate and can shave several percent off a long-duration stock's value
even when its earnings are unchanged.

**Fiscal policy** is the government's side: the **fiscal deficit** is the gap
between spending and (non-borrowed) receipts. The government borrows that gap by
issuing G-secs. Heavy borrowing can **crowd out** private investment — the
state's demand for funds pushes yields up, making corporate borrowing costlier.
Markets read the Budget's deficit number the way they read the RBI's repo
decision: a higher-than-expected deficit → higher bond supply → higher yields →
a headwind for equities, and a weaker INR.

### 2) Worked example

A bank holds ₹10,000 crore of deposits. The RBI hikes CRR by 50 bps (0.50%).
How much lendable money is drained? Then trace the equity effect: a 10-year
G-sec yield rises from 6.80% to 7.30%; the discount rate in a Gordon model
(Lesson 7.1) rises by the same 50 bps.

```python
from decimal import Decimal
deposits = Decimal("10_000_000_000_000")   # 10,000 crore in rupees
crr_hike = Decimal("0.005")                 # 50 bps
drained = deposits * crr_hike
print("Liquidity drained per bank:", drained.quantize(Decimal("10000000")), "₹")
```

Answer: ₹5,000 crore per bank — a real squeeze when multiplied across the
system, which is exactly why CRR is called a "blunt instrument". The 50 bps
yield rise flows into every discount rate in M6/M7 and lowers present values.

### 3) Common pitfalls

> **Pitfall:** Confusing repo (RBI lends to banks) with reverse repo (RBI
> borrows from banks). Mixing CRR (cash, no interest) with SLR (G-secs, earns
> interest). And forgetting that the *whole chain* matters: a repo hike that
> does not transmit to bank lending rates (weak transmission) is a different
> world from one that does.

### 4) Key takeaways

- **Takeaway:** Repo is the policy anchor; CRR/SLR are liquidity drains.
- **Takeaway:** Transmission is rates → bond yields → discount rate → equity
  value — the M6/M7 bridge.
- **Takeaway:** Fiscal deficit and government borrowing can crowd out private
  investment via yields.

## Lesson 1.5 — Global macro

### 1) Concept

Indian equities are not an island. Four recurring global channels:

1. **Eurozone crisis / global risk-off:** when foreign institutional investors
   (FIIs) get nervous, they sell wherever they can — India among them. A
   **global risk-off** episode shows up as FII outflows, INR depreciation, and a
   falling Nifty even if Indian fundamentals are fine. Flow-led, not
   fundamentals-led.
2. **Oil price shocks:** India imports ~85% of its crude. Oil at $120 vs $70
   worsens the current-account deficit, pressures the INR, raises fuel-linked
   input costs (paints, airlines, logistics, FMCG packaging) — a clear sector
   loser, while upstream ONGC and windfall-tax questions cut the other way.
3. **IT/visa policies:** US H-1B and visa policy changes directly affect Indian
   IT exporters (TCS, INFY, WIPRO) whose cost base includes on-site US staff;
   US client budgets and the USD/INR level drive their INR earnings. A strong
   dollar is, other things equal, good for IT margins.
4. **US Fed hikes:** when the US Fed raises rates, US bond yields rise and the
   dollar strengthens, pulling capital *toward* the US and away from emerging
   markets — the "taper tantrum" of 2013 was exactly this. USD/INR weakens
   (INR depreciates), and high-multiple Indian stocks de-rate.

The **macro-to-sector translation** uses the banking vocabulary from S1-M6: a
rate hike cycle improves bank **NIMs** (net interest margin) while a slump
raises **NPAs** (non-performing assets); a strong deposit franchise shows in
**CASA** (current and savings account) ratios; and **CAR** (capital adequacy
ratio) tells you how much shock capital the bank can absorb. Reading the macro
event and then asking "which sectors' P&L does this touch?" is the analyst's
daily translation work.

### 2) Worked example

Brent crude rises from $80 to $88 and USD/INR moves from 83.50 to 84.80. A paint
company's imported raw material is billed in dollars. By how much do its input
costs rise in rupees?

```python
from decimal import Decimal
crude_0, crude_1 = Decimal("80"), Decimal("88")
usdinr_0, usdinr_1 = Decimal("83.50"), Decimal("84.80")
imports_usd = Decimal("10_000_000")            # 10 m USD of resin imports
cost_0 = imports_usd * usdinr_0
cost_1 = imports_usd * usdinr_1
print("Cost rise in ₹:", (cost_1 - cost_0).quantize(Decimal("1000000")))
```

Answer: cost rises from ₹83.50 cr to ₹84.80 cr — a ₹1.30 cr hit from the rupee
alone, *plus* the 10% crude-price effect passed through into resin prices. This
is why macro analysis feeds straight into the company work of M2–M8.

### 3) Common pitfalls

> **Pitfall:** Treating an FII outflow day as a company-specific story — check
> whether the whole market fell (beta) before blaming the company. Mixing up
> which way the INR moves (USD/INR at 84.80 means the rupee *weakened*). And
> assuming every oil spike helps "energy stocks" — downstream refiners and
> airlines are *losers* from a crude spike.

### 4) Key takeaways

- **Takeaway:** Global risk-off, oil, US Fed, and visa policy are four recurring
  channels into Indian equities via flows, FX, and sector P&Ls.
- **Takeaway:** Translate macro events into sector P&L using NIM/NPA/CASA/CAR
  for banks and input-cost pass-through for manufacturers.
- **Takeaway:** Know the direction of every flow: dollar up / INR down hits
  importers and helps IT exporters.

## Tantra Lab 1 — Returns on a macro-moved index

### Lab goal

Prove that a macro event (a repo decision, an oil shock) shows up as a sequence
of day-over-day index returns, and that computing those returns on `Decimal`
closes is precise and lossless — the same arithmetic you will use to judge the
market's reaction to the event you write up.

### Code

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

### Expected output

```
first 5 returns: [Decimal('0.0058...'), Decimal('-0.0012...'), ...]
count: 249
```

Exactly **249** returns for 250 closes (each return needs a previous close).
Values are `Decimal` — never rounded floats. The sign and size of the first few
returns should look like small daily index moves (roughly ±1%), which is what a
real Nifty daily return looks like.

### Hand-in checklist

- [ ] The printed return series (first 5 values + count = 249) is pasted in your
      journal, showing `Decimal` types.
- [ ] 1,000-word commentary: expected vs actual policy action, index reaction,
      sector reaction (banks/IT), and your transmission explanation.
- [ ] The return series is annotated with the event date: which day's return
      captured the announcement, and whether the market "priced it in".
- [ ] At least one sentence connects the observed move to a Lesson 1.4 channel
      (rates → yields → discount rate).

### Common errors

- **Error:** running the script before `pip install tantra` / activating the
  project venv — fix with the S1 setup instructions before blaming the code.
- **Error:** expecting 250 returns; each return consumes a previous close, so
  the series is `days − 1`. Indexing `rets[249]` will raise `IndexError`.
- **Error:** converting closes to `float` to "make it simpler" — that breaks
  the Zero-Floats rule and can show spurious tiny differences; keep `Decimal`.

## Practice problems

1. Nominal GDP grows from ₹300 lakh crore to ₹324 lakh crore while the deflator
   rises from 100 to 105. Compute (a) nominal growth, (b) real GDP in the new
   year, (c) real growth.
2. A household basket costs ₹150 this year and ₹159 next year. Compute CPI
   inflation. If the repo rate is 6.00%, what is the real repo rate?
3. A PMI survey gives new orders 61, output 58, employment 54, supplier
   deliveries 51, inventories 53. Compute the PMI using the Lesson 1.3 weights.
   Is the economy expanding or contracting?
4. The RBI hikes CRR from 4.0% to 4.5%. A bank has ₹20,000 crore of deposits.
   How much lendable liquidity is drained? Explain the equity transmission in
   one paragraph.
5. Brent rises from $75 to $82.50 and USD/INR moves 83.00 → 84.40. A tyre maker
   imports $5 million of rubber. Compute the rupee cost before and after, and
   the rupee increase (use `Decimal`).
6. Classify each indicator as leading, coincident, or lagging: PMI, IIP, GDP,
   unemployment, retail sales. Which two would you watch first after a repo
   hike and why?
7. A US Fed hike sends USD/INR from 83.50 to 85.00. Explain, in 3–4 sentences,
   which of TCS (IT exporter), Maruti (auto, some imports), and an FMCG company
   are helped or hurt, and why.
8. "Good GDP growth always pushes equities up." Defend or refute in a short
   paragraph, using the growth-vs-rate-hike tension.

### Solutions

1. Nominal growth = (324 − 300)/300 = 8%. Real new-year GDP = 324/1.05 ≈ 308.57.
   Real growth ≈ (308.57 − 300)/300 ≈ 2.86%.
2. CPI inflation = (159 − 150)/150 = 6%. Real repo = 6.00% − 6.00% = 0.00%.
3. PMI = 0.40(61) + 0.30(58) + 0.15(54) + 0.075(51) + 0.075(53) = 24.4 + 17.4 +
   8.1 + 3.825 + 3.975 = 57.7 → expansion.
4. Drained = 20,000 × 0.005 = ₹100 crore. The chain: less lendable money → bank
   rates up → credit demand down → yields up → discount rates up → valuations
   down.
5. Cost before = 5m × 83.00 = ₹415m; after = 5m × 84.40 = ₹422m; rise = ₹7m,
   before the crude price effect is added.
6. Leading: PMI. Coincident: IIP. Lagging: GDP, unemployment. Retail sales is
   coincident. After a repo hike watch PMI (orders) and IIP (confirmation).
7. USD/INR 85.00 means a weaker rupee. TCS earns in dollars → INR revenue and
   margin tailwind (helped). Maruti has imported components → cost pressure
   (hurt, partly). FMCG is largely domestic → roughly neutral to flows, but
   higher import costs for palm oil could squeeze margins slightly.
8. Refute with the tension: very strong growth → higher inflation → RBI/rate
   repricing → discount rates up → valuations down even as earnings rise. The
   market trades growth *and* the price paid for it.

## Quiz bank

| Question | A | B | C | D | Answer |
|---|---|---|---|---|---|
| GDP at 6% growth while the deflator rose 5% implies real growth of about… | 11% | 6% | 1% | −1% | C |
| Which indicator is *coincident* with the business cycle? | PMI | IIP | New orders | G-sec yields | B |
| PMI reading of 52 means… | Contraction | Peak of boom | Expansion | No change | C |
| The RBI's statutory CPI band is… | 2–4% | 2–6% | 4–6% | 0–4% | B |
| A repo rate hike most directly raises… | SLR | Bank lending rates | Corporate tax | CRR | B |
| Core inflation excludes… | Food & energy | Services | Housing | Gold | A |
| USD/INR moving 83.50 → 84.80 means… | INR appreciated | INR depreciated | No change | Dollar weakened | B |
| CRR is… | % of deposits held as G-secs | % of deposits held as cash with RBI | The emergency lending rate | A tax on banks | B |
| A crude price spike most directly hurts… | Upstream ONGC | Domestic FMCG | Airlines | IT exporters | C |
| Higher-than-expected fiscal deficit tends to… | Lower bond yields | Raise bond yields | Strengthen INR | Cut repo rate | B |

## Glossary

- **GDP (Gross Domestic Product)** — the total value of goods and services
  produced in a country in a period; C + I + G + (X − M).
- **GDP deflator** — the price index that converts nominal GDP into real GDP.
- **IIP (Index of Industrial Production)** — a coincident index of factory,
  mining, and electricity output.
- **CPI (Consumer Price Index)** — retail inflation; the RBI's legal target.
- **WPI (Wholesale Price Index)** — wholesale/factory-gate price inflation.
- **Core inflation** — headline minus volatile food and energy prices.
- **Repo rate** — the rate at which the RBI lends to banks.
- **Reverse repo** — the rate the RBI pays banks for parking surplus cash.
- **CRR (Cash Reserve Ratio)** — the share of deposits banks must keep as cash
  with the RBI.
- **SLR (Statutory Liquidity Ratio)** — the share of deposits held in G-secs
  and gold.
- **PMI (Purchasing Managers' Index)** — a diffusion index; >50 expansion,
  <50 contraction; a leading indicator.
- **Fiscal deficit** — government spending minus non-borrowed receipts; the gap
  financed by G-sec issuance.
- **Crowding out** — government borrowing pushing up yields and displacing
  private investment.
- **MPC (Monetary Policy Committee)** — the RBI committee that sets the repo
  rate.

## Reading assignment

Read the corresponding chapters on macro and markets in
[the reading list](../appendices/reading-list.md) — NIFM Ch 17 & 31 (GDP,
monetary policy, banking), PGP T2-201, and the IFMC items 9–13 and 67–69. Also
skim the monthly RBI **Monetary Policy Report** press releases for one full
cycle so the transmission language (Lesson 1.4) becomes second nature.

## Assessment

- Macro commentary assignment (1,000 words).
- Quiz: indicator definitions and transmission channels.

## Assessment reminder

This module feeds the **end-term exam** (indicator definitions and the
transmission chain are standard exam questions) and the **macro commentary
assignment** in your lab journal. The economic-calendar reading habit you build
here is assumed by every later semester, so record your indicator glossary in
the journal now — see [Assessment](../front/assessment.md) for how graded
components map to your final programme grade.

**Next:** [M2 — Industry & Company Qualitative Analysis](m2-industry-company-qualitative.md)
