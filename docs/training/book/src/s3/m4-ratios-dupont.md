# M4 — Ratio Analysis & DuPont

> **Weeks 39–40 · 16 hrs · PLO-5 · Core:** NIFM Ch 21; IFMC items 36–39

## Learning outcomes

- Compute the liquidity, solvency, profitability, and efficiency ratio families.
- Explain the **step-wise DuPont decomposition** of ROE.
- Interpret PE, EPS, P/B, EV/EBITDA, dividend yield in context.
- Benchmark a company's ratios against its industry.
- Compute every ratio in `Decimal` and know which family answers which
  question.

## Prerequisites

- [M3 — Financial Statement Analysis](m3-financial-statement-analysis.md):
  this module is pure arithmetic on M3's statements — revenue, EBIT, PAT,
  assets, equity, OCF.
- [M2 — Industry & Company Qualitative Analysis](m2-industry-company-qualitative.md):
  the industry benchmark you will compare ratios against.
- [S1-M7 — Financial statements](../s1/m7-financial-statements.md): banking
  ratios (NIM, NPA, CAR) are the *sector* cousins of the generic ratios here.

## Lesson 4.1 — Ratio families

### 1) Concept

Ratios are the language that turns statements into comparisons. Four families,
four questions:

| Family | Question | Examples |
|---|---|---|
| Liquidity | Can we pay near-term bills? | Current, quick/acid-test |
| Solvency | Can we survive our long-term debt? | Debt/equity, interest coverage (ICR), debt-service |
| Profitability | How much do we keep per rupee sold? | Gross/operating/net margin, ROE, ROA |
| Efficiency | How fast do assets turn into cash? | Debtor days, inventory days, payable days, asset turnover |

**Liquidity:** `Current ratio = Current assets / Current liabilities` (2.0 is
the old rule of thumb, but retail/FMCG with negative working capital run well
below). The **quick/acid-test ratio** strips inventory:

```
Quick ratio = (Current assets − Inventory) / Current liabilities
```

**Solvency:** `Debt/Equity` (or Debt/EBITDA) measures financial risk;
**Interest coverage (ICR)** = EBIT / Interest — how many times operating profit
covers the interest bill. ICR below ~2 is uncomfortable for most non-banks.

**Profitability:** margins (gross, operating/EBITDA, net) measure per-rupee
retention; **ROE** = PAT / average equity (the owner's return); **ROA** =
EBIT or PAT / average assets (the operating return before leverage).

**Efficiency:** debtor days (M3), inventory days, payable days, and **asset
turnover** = Revenue / Total assets — how hard the asset base works. The four
families are *complementary*: a company can have beautiful margins (P&L) and
be suffocating on liquidity (balance sheet) at the same time.

### 2) Worked example

One statement set, all four families:

```python
from decimal import Decimal
ca = Decimal("400_000"); cl = Decimal("250_000"); inventory = Decimal("90_000")
debt = Decimal("300_000"); equity = Decimal("500_000")
ebit = Decimal("180_000"); interest = Decimal("40_000")
pat = Decimal("105_000"); assets = Decimal("800_000"); revenue = Decimal("1_200_000")
print("Current:", (ca / cl).quantize(Decimal("0.01")),
      "| Quick:", ((ca - inventory) / cl).quantize(Decimal("0.01")))
print("D/E:", (debt / equity).quantize(Decimal("0.01")),
      "| ICR:", (ebit / interest).quantize(Decimal("0.01")))
print("Net margin %:", (pat / revenue * 100).quantize(Decimal("0.01")),
      "| ROE %:", (pat / equity * 100).quantize(Decimal("0.01")),
      "| Asset turnover:", (revenue / assets).quantize(Decimal("0.01")))
```

Answer: Current 1.60, Quick 1.24, D/E 0.60, ICR 4.5×, net margin 8.75%, ROE
21.0%, asset turnover 1.50. The single most important habit in this module:
read the families *together* — the same company is liquid (1.6), solvent (ICR
4.5×), profitable (21% ROE), and efficient (1.5× turnover).

### 3) Common pitfalls

> **Pitfall:** Judging liquidity from the current ratio alone — a 1.6 with
> inventory that cannot sell is worse than a 1.2 with cash-heavy assets; use
> the quick ratio. Using *period-end* balance-sheet numbers against *flow*
> P&L numbers — averages (opening + closing)/2 match periods properly.
> Comparing a bank's ratios to a manufacturer's — each sector has its own
> rules.

### 4) Key takeaways

- **Takeaway:** Four families answer four questions; never read one alone.
- **Takeaway:** Match flow (P&L) to average balances; use point-in-time values
  for point-in-time questions.
- **Takeaway:** Benchmark against the industry, not against universal
  cut-offs.

## Lesson 4.2 — DuPont decomposition

### 1) Concept

ROE tells you *what* the owner earns; DuPont tells you *how*. The three-step
decomposition splits ROE into the three levers management can pull:

```
ROE = (PAT / Revenue) × (Revenue / Assets) × (Assets / Equity)
       net margin        asset turnover       financial leverage
```

- **Net margin** — how much profit per rupee of sales (pricing power, cost
  control).
- **Asset turnover** — how many rupees of sales per rupee of assets (asset
  intensity, working-capital efficiency).
- **Equity multiplier (Assets/Equity)** — how much leverage multiplies the
  return (borrowing).

The **five-step** version opens the tax and interest layers:

```
ROE = (PAT/EBT) × (EBT/EBIT) × (EBIT/Revenue) × (Revenue/Assets) × (Assets/Equity)
       tax burden    interest burden   operating margin   turnover       leverage
```

**The analyst question:** is a high ROE from margin, from asset efficiency, or
from leverage? Same ROE, very different businesses. A bank's ROE is leverage-
driven (thin margin, huge multiplier); an FMCG's is margin-driven; a
distributor's is turnover-driven. Two companies can both show 20% ROE — one
earning it with 12% margin and 1.7× leverage, another with 3% margin and 8×
leverage. The second is *riskier for the same return*. DuPont converts a
scoreboard number into a risk-and-source diagnosis.

### 2) Worked example

The five-step DuPont on the Lesson 4.1 numbers, plus the three-step check:

```python
from decimal import Decimal
pat = Decimal("105_000"); pbt = Decimal("140_000"); ebit = Decimal("180_000")
revenue = Decimal("1_200_000"); assets = Decimal("800_000"); equity = Decimal("500_000")
tax_burden = pat / pbt
interest_burden = pbt / ebit
margin = ebit / revenue
turnover = revenue / assets
leverage = assets / equity
roe_5 = tax_burden * interest_burden * margin * turnover * leverage
roe_3 = (pat / revenue) * turnover * leverage
print("5-step ROE:", (roe_5 * 100).quantize(Decimal("0.01")), "%")
print("3-step ROE:", (roe_3 * 100).quantize(Decimal("0.01")), "%", "(check)")
```

Answer: both equal 21.0% — the decomposition is an *identity*, so the two
routes must agree. The value is in the terms: tax burden 0.75, interest burden
0.78, operating margin 15%, turnover 1.5, leverage 1.6. Now compare with a
leveraged sibling earning the same 21% from 5% margin and 4× leverage — the
diagnosis (source of ROE) is different, and so is the risk.

### 3) Common pitfalls

> **Pitfall:** Using *period-end* equity in the denominator — with equity
> growing through the year, end-period equity understates ROE; use average.
> Including minority interest in equity when it belongs outside the parent's
> equity. Quoting "ROE went up" without saying *which lever* moved it.

### 4) Key takeaways

- **Takeaway:** 3-step and 5-step DuPont are identities that split ROE into
  margin, turnover, leverage (plus tax and interest).
- **Takeaway:** Same ROE, different risk — decompose before comparing.
- **Takeaway:** Leverage amplifies return *and* risk; DuPont exposes it.

## Lesson 4.3 — Market ratios

### 1) Concept

Market ratios connect the statements to the *price* the market pays:

```
EPS          = PAT / number of shares
PE           = Price / EPS
P/B          = Price / Book value per share
EV/EBITDA    = (Market cap + Debt − Cash) / EBITDA
Dividend yield = DPS / Price
Payout ratio = DPS / EPS
```

**EPS** is the per-share slice of profit; **PE** is how many years of current
earnings the price costs — the market's payment for future growth. **Trailing
PE** uses the last reported year's EPS; **forward PE** uses forecast EPS.
**P/B** relates price to accounting net worth; it matters most for asset-heavy
businesses (banks, where book value is the core driver). **EV/EBITDA** (formal
in M7) strips capital structure: enterprise value pays for the *operating*
business. **Dividend yield** is the cash return for holders; **payout ratio**
shows how much profit is returned vs retained.

The discipline of Lesson 4.1 applies twice: **ratios are meaningless without a
benchmark** — against the company's own history, against its peers, and against
its sector. INFY at 28× PE means something very different from a smallcap IT
services at 28×. A "cheap" stock by PE can be expensively priced on its history;
an "expensive" leader can be cheap relative to its growth (hence the PEG-style
thinking later in S4).

### 2) Worked example

Market ratios from one stock's numbers:

```python
from decimal import Decimal
price = Decimal("150"); pat = Decimal("100_000_000"); shares = Decimal("10_000_000")
book_value = Decimal("500_000_000")
market_cap = Decimal("300_000_000"); debt = Decimal("50_000_000"); cash = Decimal("20_000_000")
ebitda = Decimal("40_000_000"); dps = Decimal("6")
eps = pat / shares
pe = price / eps
bvps = book_value / shares
pb = price / bvps
ev = market_cap + debt - cash
print("EPS:", eps, "| PE:", pe.quantize(Decimal("0.1")),
      "| P/B:", pb.quantize(Decimal("0.1")),
      "| EV/EBITDA:", (ev / ebitda).quantize(Decimal("0.1")),
      "| Div yield %:", (dps / price * 100).quantize(Decimal("0.01")),
      "| Payout %:", (dps / eps * 100).quantize(Decimal("0.01")))
```

Answer: EPS ₹10; PE 15.0×; P/B 3.0×; EV/EBITDA 8.25×; dividend yield 4.0%;
payout 60%. Reading: a 15× trailing PE with 60% payout is a mature, cash-return
profile — the market is paying ~15 years of current earnings, and the question
becomes whether growth justifies it.

### 3) Common pitfalls

> **Pitfall:** Mixing trailing and forward PE without saying which. Using
> *book value* computed with minority interest included. Forgetting that a
> zero-earnings company has an undefined PE (a loss makes PE negative and
> meaningless) — switch to EV/Sales for loss-makers. And quoting PE without the
> benchmark.

### 4) Key takeaways

- **Takeaway:** PE, P/B, EV/EBITDA, dividend yield each answer a different
  pricing question.
- **Takeaway:** Always state trailing vs forward and benchmark against
  history/peers/sector.
- **Takeaway:** EV/EBITDA strips leverage — the workhorse for cross-company
  comparison (M7).

## Lesson 4.4 — Ratio interpretation pitfalls

### 1) Concept

Ratios are arithmetic; interpretation is judgement. The three classic traps:

1. **One ratio never tells the story** — every ratio needs its family and its
   benchmark. A rising current ratio sounds good, but if it rises because
   receivables and inventory ballooned while sales flatlined, it is a *warning*.
2. **Balance-sheet ratios are point-in-time; margins are flow — match
   periods.** Year-end cash can be inflated by a rights issue *after* the
   operating year; the correct denominator for margins is the *average* balance
   across the year.
3. **Window-dressing risk at year-end** — companies may pull forward
   collections, delay payables, or run year-end offers to flatter the balance
   sheet snapshot. The quarterly average is more honest than the single year-end
   photograph.

Two more: **sector blindness** (valuing a bank with a manufacturer's ratios)
and **accounting-policy drift** (depreciation method, inventory valuation, and
revenue recognition changes make "same ratio" mean different things across
years). This is exactly where the M3 red-flag checklist and M2 qualitative work
reconnect: the numbers confirm or contradict the story.

### 2) Worked example

The window-dressing trap, quantified:

```python
from decimal import Decimal
# Two companies, identical operating year, different year-end collection push
a_avg_cash = Decimal("50_000"); b_avg_cash = Decimal("50_000")
a_year_end = Decimal("90_000")   # pulled collections forward into the snapshot
b_year_end = Decimal("55_000")
print("A: snapshot cash vs average:", (a_year_end / a_avg_cash).quantize(Decimal("0.01")), "x")
print("B: snapshot cash vs average:", (b_year_end / b_avg_cash).quantize(Decimal("0.01")), "x")
```

Answer: A's year-end cash is 1.8× its average — the *photograph* flatters A. B
is 1.1× — the *average* is the truth. An analyst using A's year-end current
ratio alone sees a company that was only briefly (or cosmetically) that liquid.
The fix is a habit: prefer averages, and compare the year-end snapshot to the
quarterly path.

### 3) Common pitfalls

> **Pitfall:** Treating a single ratio change as a story — cross-check the
> family. Comparing one company's year-end ratios to a peer's *average-based*
> ratios. Ignoring the footnotes when a ratio "improves" because of a policy
> change rather than operations.

### 4) Key takeaways

- **Takeaway:** Interpret families, match periods, benchmark sectors.
- **Takeaway:** Year-end snapshots can be window-dressed — averages are
  safer.
- **Takeaway:** Ratio changes must be traced to operations, not accounting
  policy.

## Tantra Lab 4 — DuPont in Decimal

### Lab goal

Prove the DuPont identity holds exactly in `Decimal` — the three-step and
five-step decompositions must agree to the last digit — and turn the four
component numbers into a one-line "source of ROE" diagnosis.

### Code

```python
from decimal import Decimal

def dupont(pat, revenue, assets, equity):
    margin = pat / revenue
    turnover = revenue / assets
    leverage = assets / equity
    return {"net_margin": margin, "asset_turnover": turnover,
            "equity_multiplier": leverage, "roe": margin * turnover * leverage}

print(dupont(Decimal("100_000"), Decimal("1_000_000"), Decimal("2_000_000"), Decimal("800_000")))
```

**Task:** build the ratio deck for your S3-M2 shortlist company in Excel:
liquidity, solvency, profitability, efficiency, plus the 5-step DuPont. Write a
one-page memo: "Why did ROE change?" between two years.

### Expected output

```
{'net_margin': Decimal('0.1'), 'asset_turnover': Decimal('0.5'),
 'equity_multiplier': Decimal('2.5'), 'roe': Decimal('0.125')}
```

ROE = 0.1 × 0.5 × 2.5 = **12.5%**. The diagnosis: a 10% margin is healthy but
the asset base turns over only 0.5× a year, and the 2.5× multiplier carries the
return — this ROE is *partly leveraged*. A peer with the same 12.5% ROE built
as 0.08 × 0.9 × 1.7 is safer and more efficient. The lab's real output is that
interpretation sentence.

### Hand-in checklist

- [ ] Script output pasted with ROE recomputed by hand (0.1 × 0.5 × 2.5).
- [ ] Ratio deck in Excel: liquidity, solvency, profitability, efficiency
      families for the shortlist company, all from M3's worksheet numbers.
- [ ] Five-step DuPont for two years of the company, with each lever
      (tax, interest, margin, turnover, leverage) computed in `Decimal`.
- [ ] One-page memo: "Why did ROE change?" — name the *lever*, quantify its
      contribution, and give one operational reason from M2's qualitative work.

### Common errors

- **Error:** changing the verified `dupont` function signature — keep it as-is
  and build the 5-step version as a *second* function.
- **Error:** using year-end equity instead of average equity — the memo will
  misattribute the ROE change to leverage when it was really a capital raise.
- **Error:** mixing `Decimal` with `float` when extending the script (e.g.,
  `margin * 2.5`) — raises `TypeError`; write `Decimal("2.5")`.

## Practice problems

1. Current assets ₹500,000 (inventory ₹120,000), current liabilities ₹280,000.
   Compute current and quick ratios.
2. EBIT ₹200,000, interest ₹50,000, debt ₹400,000, equity ₹600,000. Compute
   ICR and D/E. Interpret both.
3. PAT ₹150,000, revenue ₹2,000,000, assets ₹1,500,000, average equity
   ₹750,000. Compute net margin, asset turnover, equity multiplier, and ROE
   both ways (3-step and directly).
4. Price ₹240, PAT ₹96,000,000, shares 12,000,000, book value ₹480,000,000.
   Compute EPS, PE, BVPS, P/B. Which benchmark would you compare PE against?
5. Two companies both earn 18% ROE. Company A: 12% margin, 1.0× turnover,
   1.5× leverage. Company B: 4.5% margin, 2.0× turnover, 2.0× leverage. Compute
   each and state which is riskier for the same return, and why.
6. A company's current ratio rose from 1.4 to 2.0 in a year while revenue was
   flat. Give two benign and two worrying explanations.
7. Dividend per share ₹8, price ₹160, EPS ₹20. Compute dividend yield and
   payout ratio. If the company stops growing, which ratio would you watch and
   why?
8. Explain in three sentences why a bank's ROE is typically leverage-driven
   while an FMCG's is margin-driven, using the DuPont terms.

### Solutions

1. Current = 500,000/280,000 ≈ 1.79; Quick = (500,000 − 120,000)/280,000 ≈
   1.36.
2. ICR = 4× — operating profit covers interest four times (comfortable);
   D/E = 0.67 — moderate leverage.
3. Margin = 7.5%; turnover = 1.33; multiplier = 2.0; ROE = 0.075 × 1.33 × 2.0
   = 20% (and PAT/equity = 150,000/750,000 = 20% — identity holds).
4. EPS = 8; PE = 30; BVPS = 40; P/B = 6. Benchmark PE against the sector's
   range and the company's own history.
5. A: 0.12 × 1.0 × 1.5 = 18%; B: 0.045 × 2.0 × 2.0 = 18%. B is riskier: more
   leverage (2.0×) for the same ROE and thinner margins leave less room for
   error.
6. Benign: cash from a rights issue; payables extended longer. Worrying:
   receivables and inventory ballooning while sales are flat; cash inflated by
   one-off asset sales at year-end (window dressing).
7. Yield = 8/160 = 5%; payout = 8/20 = 40%. If growth stops, watch payout and
   yield — the return must come from cash, not repricing.
8. Banks borrow deposits (huge leverage) and earn thin spreads, so their ROE
   needs a large equity multiplier; FMCG earns fat margins on small assets and
   runs little debt, so its ROE comes from margin × (modest) turnover.

## Quiz bank

| Question | A | B | C | D | Answer |
|---|---|---|---|---|---|
| Current ratio = … | CA/CL | CL/CA | CA/Equity | Debt/Assets | A |
| The quick ratio excludes… | Cash | Inventory | Receivables | Payables | B |
| ICR = 4× means… | Interest is 4× EBIT | EBIT covers interest 4× | Equity is 4× debt | 4% interest | B |
| The 3-step DuPont multiplies… | Margin × turnover × leverage | Margin × leverage | EPS × PE | Turnover × debt | A |
| A high ROE from leverage is… | Safer than from margin | Riskier for the same return | Always bad | Always good | B |
| PE = … | Price × EPS | Price / EPS | EPS / Price | PAT / shares | B |
| EV = … | Market cap + debt − cash | Market cap − debt | Price × shares / EBITDA | Assets − equity | A |
| Trailing PE uses… | Forecast EPS | Last reported EPS | Book value | Dividend | B |
| Point-in-time vs flow means… | Match balance-sheet averages to P&L flows | Use year-end only | Ignore time | Use quarterly only | A |
| A rising current ratio with flat sales is… | Always good | Could signal inventory pile-up | Proof of growth | A tax effect | B |

## Glossary

- **Current ratio** — current assets / current liabilities; near-term
  liquidity.
- **Quick (acid-test) ratio** — (current assets − inventory) / current
  liabilities.
- **Debt/Equity** — leverage; financial risk measure.
- **Interest coverage (ICR)** — EBIT / interest; how many times interest is
  covered.
- **ROE (return on equity)** — PAT / average equity; the owner's return.
- **ROA (return on assets)** — profit / average total assets.
- **Asset turnover** — revenue / total assets; efficiency of the asset base.
- **DuPont decomposition** — the identity splitting ROE into margin × turnover
  × leverage (3-step) plus tax and interest burden (5-step).
- **EPS** — PAT / shares outstanding; per-share earnings.
- **PE ratio** — price / EPS; years of earnings the price pays.
- **P/B** — price / book value per share; asset-heavy valuation.
- **EV/EBITDA** — (market cap + debt − cash) / EBITDA; leverage-neutral
  operating multiple.
- **Dividend yield** — DPS / price; cash return on price.
- **Payout ratio** — DPS / EPS; share of profit returned as dividends.

## Reading assignment

Read the ratio-analysis chapters in [the reading list](../appendices/reading-list.md):
NIFM Ch 21 (ratio analysis), IFMC items 36–39, and the ratio appendices of
PGP T2. Then compute the full four-family deck by hand for one Nifty 50
company's published numbers — ten minutes of hand arithmetic is worth an hour
of theory.

## Assessment

- Ratio-deck Excel deliverable + DuPont memo.
- Quiz: ratio definitions and interpretation.

## Assessment reminder

The ratio deck and the "Why did ROE change?" memo are **graded lab/journal
deliverables**, and the DuPont diagnosis you write feeds the M8 capstone's
analysis narrative. Ratio definitions and interpretation questions appear
throughout the end-term exam and in S4 (portfolio analytics reuses ROE/PE
thinking). See [Assessment](../front/assessment.md) for the grading map.

**Next:** [M5 — Time Value of Money & Capital Budgeting](m5-tvm-capital-budgeting.md)
