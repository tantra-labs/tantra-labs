# M1 — Statistics for Markets

> **Weeks 49–51 · 24 hrs · PLO-8 · Core:** IFMC items 22, 27–28, 31; CFTe II App G; PGP T1-102

## Learning outcomes

- Compute mean, median, mode, range, variance, and standard deviation.
- Interpret skewness and kurtosis as risk information.
- Describe the normal distribution and why returns are not normal.
- Summarize a return series with a stats deck.
- Compute simple returns, log returns, and annualized volatility by hand and in Decimal.

## Prerequisites

- [M1 of Semester 1](../s1/m1-markets-institutions.md) gave you the vocabulary: index, tick, close price, daily session.
- [Semester 2 indicators](../s2/m1-price-basics.md): you should already know what a *series of prices* is and why we study *changes* in price.
- A working Python environment with `tantra` and `tantra_examples` installed (`pip install tantra`), and the habit of writing `Decimal` everywhere — never `float`.

## Lesson 1.1 — Descriptive statistics

### 1) Concept

Statistics is how we compress thousands of daily prices into a handful of numbers that describe the *shape* of the data. The first three numbers answer "where is the middle?" and "how spread out is it?".

The **mean** (μ, "mu") is the arithmetic average — add up every observation and divide by the count. The **median** is the middle value when you sort the data; it resists outliers, so it is a fairer "typical value" for skewed return data. The **mode** is the most frequent value — for continuous price data it is rarely useful, but for round lot sizes or tick prices it can be. The **range** is `max − min`, the crudest spread measure, because a single extreme day can stretch it enormously.

**Variance** measures average squared deviation from the mean. Squaring makes every deviation positive and punishes big deviations more than small ones. **Standard deviation** (σ, "sigma") is the square root of variance, which puts the measure back in the original units — percent per day, rupees, points. Variance is in *squared* units, which are hard to interpret; that is why finance almost always quotes σ.

Percentiles and quartiles slice the sorted data: the median is the 50th percentile, the 25th and 75th percentiles (Q1, Q3) bound the middle half, and the interquartile range `IQR = Q3 − Q1` is a robust spread measure. A **population** is every member of the group you care about (all 500 NIFTY constituents); a **sample** is a subset (the 250 days in one year). Population variance divides by `n`; sample variance divides by `n−1` to compensate for the extra uncertainty of estimating from a subset. Know which you are using — the wheel's `std_dev` follows a convention, and mixing them shifts risk numbers.

```
Population:
Mean       μ = Σx / n
Variance   σ² = Σ(x − μ)² / n
Std dev    σ = √σ²

Sample:
Variance   s² = Σ(x − x̄)² / (n − 1)
```

### 2) Worked example

Suppose NIFTY's daily returns over five sessions (in percent): 0.4, −0.2, 0.1, −0.3, 0.5.

```
μ = (0.4 − 0.2 + 0.1 − 0.3 + 0.5) / 5 = 0.5 / 5 = 0.10
σ² = [ (0.4−0.1)² + (−0.2−0.1)² + (0.1−0.1)² + (−0.3−0.1)² + (0.5−0.1)² ] / 5
   = [ 0.09 + 0.09 + 0.00 + 0.16 + 0.16 ] / 5 = 0.50 / 5 = 0.10
σ  = √0.10 ≈ 0.316% per day
```

```python
from decimal import Decimal
from tantra.quant import mean, std_dev

# Returns as percentages, kept as Decimal.
r = [Decimal("0.4"), Decimal("-0.2"), Decimal("0.1"),
     Decimal("-0.3"), Decimal("0.5")]

print("mean:", mean(r))        # ≈ 0.10
print("std :", std_dev(r))     # ≈ 0.316 (% per day)
```

Answer: mean return ≈ 0.10% per day and daily volatility ≈ 0.316%. Notice the wheel takes `Decimal` in and gives `Decimal` out — there is never a `float` in the money path.

### 3) Common pitfalls

> **Pitfall:** Mixing units. If prices are in rupees but returns are in percent, do not average them together. Decide one unit (percent) and convert everything before computing.
>
> **Pitfall:** Using `float` for money. `Decimal("0.1")` is exact; `0.1` in binary is a repeating fraction, so sums drift. The house rule is Zero-Floats for any price, quantity, fee, or return.
>
> **Pitfall:** Population vs sample. Dividing by `n` when you have only a sample understates σ. If the data are "this month's 20 sessions", use the sample formula.
>
> **Pitfall:** Trusting the range. Range uses only two points of data; a single crash day makes it meaningless as a risk measure.

### 4) Key takeaways

- **Takeaway:** Mean + σ describe the center and spread; they are the "two numbers" of any return series.
- **Takeaway:** Variance squares the units; σ restores interpretable units.
- **Takeaway:** Percentiles and the median are robust — they barely move when one crazy day enters the data.
- **Takeaway:** Always state population vs sample; risk numbers disagree otherwise.

## Lesson 1.2 — Returns as the unit of analysis

### 1) Concept

Prices are not the natural unit of analysis — a ₹50 stock moving ₹1 is +2%, a ₹5000 stock moving ₹1 is +0.02%. **Returns** standardize across instruments so you can compare RELIANCE's daily move to TCS's. Two kinds dominate.

The **simple return** is the percentage change: `R_t = P_t / P_{t−1} − 1`. It is intuitive — "NIFTY rose 0.8% today". But simple returns are not additive over time: a 10% gain followed by a 10% loss is not 0% but −1% (`1.1 × 0.9 = 0.99`).

The **log return** is `ln(P_t / P_{t−1})` where `ln` is the natural logarithm. Log returns *are* time-additive: `ln(P2/P1) + ln(P3/P2) = ln(P3/P1)`. This additivity makes log returns the workhorse of quantitative research — two weeks of daily log returns sum exactly to the fortnight's log return. Also, for small moves the two are nearly identical (`ln(1+r) ≈ r`), so practitioners switch freely for day-scale work.

**Annualization** rescales daily numbers to a year of ~252 trading sessions. Daily σ is scaled by √252, not 252, because volatility compounds through a square root while time itself scales linearly:

```
σ_annual ≈ σ_daily × √252     (√252 ≈ 15.87)
```

Why √252 and not 252? Variance adds up over independent days: a year's variance is 252 × daily variance, so a year's σ is √252 × daily σ. This rule also underlies VAR and option pricing (M6), so get comfortable with it now.

### 2) Worked example

A stock closes at ₹100 on Monday and ₹102 on Tuesday.

```
Simple return:  R = 102/100 − 1 = 0.02  →  +2%
Log return:     r = ln(102/100) = ln(1.02) ≈ 0.0198  →  ≈ +1.98%
```

If the daily σ is 1%, what is the annual σ?

```
σ_annual ≈ 1% × √252 ≈ 1% × 15.87 ≈ 15.87% per year
```

```python
from decimal import Decimal
from tantra.quant import returns

prices = [Decimal("100"), Decimal("102")]
r = returns(prices)                     # simple returns: [0.02]
print(r)

# Annualize a 1% daily σ with Decimal arithmetic.
DAILY_SIGMA = Decimal("0.01")
ROOT_252 = Decimal("252").sqrt()
annual = DAILY_SIGMA * ROOT_252
print("annual sigma ≈", annual)         # ≈ 0.1587
```

Answer: the simple return is +2%, the log return ≈ +1.98%, and 1% daily σ annualizes to ≈ 15.9%.

### 3) Common pitfalls

> **Pitfall:** Believing 10% + 10% = 20%. Simple returns do not add; compounding does. Always multiply factors `(1+r)`.
>
> **Pitfall:** Annualizing the mean by ×252. Only *variance/σ* scales with √252 for independent returns; scaling the mean needs compounding.
>
> **Pitfall:** Mixing simple and log returns inside one formula. Pick one flavour for a calculation and stay with it.
>
> **Pitfall:** Ignoring warm-up or missing values — `returns` needs at least two prices; with one price there is nothing to return.

### 4) Key takeaways

- **Takeaway:** Returns standardize comparison across differently priced stocks.
- **Takeaway:** Log returns are time-additive and are preferred for research.
- **Takeaway:** `σ_annual ≈ σ_daily × √252`; the square root comes from variance adding over independent days.
- **Takeaway:** Use Decimal and one consistent return flavour throughout.

## Lesson 1.3 — Skewness and kurtosis

### 1) Concept

Mean and σ assume a roughly symmetric, bell-shaped cloud of returns. Real markets are not symmetric. **Skewness** measures asymmetry; **kurtosis** measures how fat the tails are. Both are computed by standardizing each observation into z-score units `(x − μ)/σ` and then averaging powers.

```
Skewness = (1/n) Σ ((x − μ)/σ)³
Kurtosis = (1/n) Σ ((x − μ)/σ)⁴
```

A normal distribution has skewness 0 and kurtosis 3 (excess kurtosis `= kurtosis − 3`). 

**Negative skew** means the left tail is longer — occasional large losses. A long-only holder (buying and holding RELIANCE) hates negative skew: small steady gains punctuated by rare crashes. **Positive skew** (rare big wins) is attractive to option sellers' opponents — lotteries are positively skewed. **High kurtosis** (fat tails) means extreme moves are *more frequent than the normal predicts* — a 5-σ event that the bell curve says should happen once in centuries happens every few years in markets. Skewness and kurtosis are therefore **risk statistics**, not decoration: a fund can have a lovely mean and σ yet blow up because of negative skew + high kurtosis (see M7 hedging, M9 risk reporting).

### 2) Worked example

Five returns (percent): 2, −4, 1, 0, 1. First find μ and σ, then standardize and cube/fourth-power.

```
μ  = (2 − 4 + 1 + 0 + 1)/5 = 0.0
σ² = (4 + 16 + 1 + 0 + 1)/5 = 4.4   →  σ ≈ 2.098
z-values:  2/2.098 ≈ 0.953,  −4/2.098 ≈ −1.907,  1/2.098 ≈ 0.477,  0,  0.477
Skewness = [ (0.953)³ + (−1.907)³ + (0.477)³ + 0 + (0.477)³ ] / 5
         = [ 0.866 − 6.936 + 0.109 + 0 + 0.109 ] / 5 ≈ −5.85/5 ≈ −1.17
```

A skew of −1.17 is strongly negative: one bad −4% day drags the whole distribution's left tail out. That is risk a mean-and-σ summary would hide.

```python
from decimal import Decimal
from tantra.quant import mean, std_dev

r = [Decimal("2"), Decimal("-4"), Decimal("1"), Decimal("0"), Decimal("1")]
mu = mean(r)
sigma = std_dev(r)

n = Decimal(len(r))
skew = sum(((x - mu) / sigma) ** 3 for x in r) / n
kurt = sum(((x - mu) / sigma) ** 4 for x in r) / n

print("skewness   :", skew)   # ≈ −1.17
print("kurtosis   :", kurt)   # ≈ 4.3  (normal = 3)
print("excess     :", kurt - 3)
```

Answer: skewness ≈ −1.17 (bad left tail), kurtosis ≈ 4.3 → excess ≈ 1.3 (fat tails).

### 3) Common pitfalls

> **Pitfall:** Reading kurtosis "3 = fat tails". A normal already has kurtosis 3; report *excess* kurtosis so 0 means normal.
>
> **Pitfall:** Computing skewness on prices instead of returns. Price levels are non-stationary; skewness is a property of the *return* distribution.
>
> **Pitfall:** Ignoring the sign of skew in portfolio work — negative skew is the enemy of the long-only investor.
>
> **Pitfall:** Letting Decimal exponent `** 3` silently upcast — keep every input Decimal and check outputs remain Decimal.

### 4) Key takeaways

- **Takeaway:** Skewness = asymmetry; negative skew = bad left tail.
- **Takeaway:** Kurtosis = tail thickness; always quote excess kurtosis.
- **Takeaway:** Both are risk statistics — the crash you should be afraid of is invisible in mean and σ alone.
- **Takeaway:** Compute them in Decimal in the same units as your returns.

## Lesson 1.4 — Distributions

### 1) Concept

A **distribution** is a rule for how likely each outcome is. The **normal distribution** `N(μ, σ)` is the famous bell curve. A **z-score** `z = (x − μ)/σ` counts how many standard deviations an outcome sits from the mean, letting you compare any normal to any other. The **68-95-99.7 rule**: about 68% of outcomes lie within ±1σ, 95% within ±2σ, 99.7% within ±3σ.

Stock returns are famously **leptokurtic** — fatter tails and a sharper peak than the normal. The cause is **volatility clustering**: calm days follow calm days and stormy days follow stormy days, so big moves clump instead of spreading out evenly. A normal distribution would make 2008 or the March 2020 crash nearly impossible; markets delivered them anyway. This is why the risk engine in the Tantra stack treats normal-distribution assumptions as *baselines*, not guarantees.

If returns were normal and independently drawn, **prices** would be **lognormal**: `P_T = P_0·exp(...)` — a random walk that cannot go below zero. Lognormality is exactly the bridge to Black-Scholes in M6: B-S assumes prices follow a lognormal process, which is why option payoffs (`max(S−K, 0)`) never need negative-price guards. Two consequences worth memorizing now: prices are bounded below at zero (lognormal), returns can be negative (normal in the log domain).

### 2) Worked example

A return distribution has μ = 0.05%/day and σ = 1.2%/day. What z-scores bracket "95% of days" (roughly ±2σ)?

```
z = (x − μ)/σ
For x = μ + 2σ:  z = +2   →  upper ≈ 0.05 + 2×1.2 = 2.45%/day
For x = μ − 2σ:  z = −2   →  lower ≈ 0.05 − 2×1.2 = −2.35%/day
```

So ~95% of single-day moves sit between ≈ −2.35% and +2.45%. A day of −6% is a roughly 5-σ event *by the normal*, yet markets produce such days regularly — the kurtosis lesson of Lesson 1.3, quantified.

```python
from decimal import Decimal

mu, sigma = Decimal("0.0005"), Decimal("0.012")
upper = mu + Decimal(2) * sigma
lower = mu - Decimal(2) * sigma
print("95% band lower:", lower)   # ≈ −0.0235
print("95% band upper:", upper)   # ≈  0.0245
```

### 3) Common pitfalls

> **Pitfall:** Applying the 68-95-99.7 rule to returns as if they were normal. Real returns are fat-tailed; the rule understates tail risk.
>
> **Pitfall:** Assuming price symmetry. Prices are lognormal (bounded below at zero); returns are approximately normal. Do not swap the two.
>
> **Pitfall:** Quoting σ as if every day were independent. Volatility clustering means the next day's risk resembles today's, not the long-run average.
>
> **Pitfall:** Forgetting that "5-σ events" recur — model them, don't be surprised by them.

### 4) Key takeaways

- **Takeaway:** The normal is the reference distribution; z-scores and the 68-95-99.7 rule are its vocabulary.
- **Takeaway:** Returns are leptokurtic with volatility clustering — fat tails, clumped storms.
- **Takeaway:** Prices are lognormal — never negative — which underpins option pricing in M6.
- **Takeaway:** Distribution shape (skew/kurtosis) is risk information; report it with every stats deck.

## Tantra Lab 1 — Stats deck from the wheel

### Lab goal

Build the full one-page "statistical character of NIFTY" memo — mean, σ, skewness, kurtosis (excess), and annualized σ — from real wheel data, proving you can summarise an index's return distribution in Decimal.

### Code

The verified core snippet is unchanged; the extension computes skewness and kurtosis by hand in `Decimal`, then annualizes σ.

```python
from decimal import Decimal
from tantra.quant import returns, mean, std_dev
from tantra_examples import SampleInstruments, synthetic_bars

bars = synthetic_bars(SampleInstruments.NIFTY50, days=500, seed=42, base_price_paise=24_000)
rets = returns([b.close for b in bars])

print("mean:", mean(rets))
print("std :", std_dev(rets))

# --- extend: skewness, kurtosis, annualized σ (all Decimal) ---
mu = mean(rets)
sigma = std_dev(rets)
n = Decimal(len(rets))

skew = sum(((x - mu) / sigma) ** 3 for x in rets) / n
kurt = sum(((x - mu) / sigma) ** 4 for x in rets) / n

ROOT_252 = Decimal("252").sqrt()
annual = sigma * ROOT_252

print("skew :", skew)
print("kurt :", kurt)
print("excess kurt:", kurt - 3)
print("annual sigma ≈", annual)
```

**Task:** run the script, then write the one-page memo: mean, σ, skew, kurtosis, what the tails say about risk, and the annualized σ. Compare the sign of skew to the story you would expect for a long-only index.

### Expected output

The script prints Decimal values: a mean very close to 0 per day, a daily σ around 1–2%, skewness and kurtosis that differ from the normal (skew often slightly negative, kurtosis noticeably above 3 → positive excess), and an annualized σ roughly 15–20× the daily σ. Exact digits depend on the seeded 500-day sample — report the *signs and orders of magnitude*, not fixed numbers.

### Hand-in checklist

- [ ] Script runs without `float` anywhere in the money path.
- [ ] Memo states daily mean, daily σ, skewness, kurtosis, and excess kurtosis.
- [ ] σ annualized with `√252` and the formula shown.
- [ ] One sentence on what the skew sign means for a long-only holder.
- [ ] One sentence on what excess kurtosis says about tail risk.

### Common errors

- **IndexError / empty returns** — `returns` needs ≥ 2 closes; confirm `days >= 2` and `len(rets) == days − 1`.
- **TypeError on `** 3`** — a stray `float` crept in. Keep every element `Decimal` (the wheel returns Decimals; do not divide by a plain `int` without wrapping).
- **Misreading excess kurtosis** — kurtosis of 4.3 is NOT "4.3 above normal"; subtract 3 first.
- **Population vs sample** — state which convention the wheel uses and be consistent in the memo.

## Practice problems

1. Five daily returns (percent): 0.3, −0.5, 0.2, 0.1, −0.1. Compute the mean, population variance, and population σ by hand.
2. A stock rises from ₹200 to ₹205 in one session. Compute the simple return and the log return to four decimals. Which is larger, and why?
3. A strategy's daily σ is 0.8%. Annualize it. How many trading days are assumed, and why is √252 used instead of 252?
4. Classify each series by skewness sign: (a) small steady gains with rare −8% days; (b) frequent small losses with rare +12% days; (c) symmetric data. Which is worst for a long-only holder?
5. A series has kurtosis 4.0. What is its excess kurtosis? Interpret.
6. Under the 68-95-99.7 rule, with μ = 0.02% and σ = 1.0% per day, between which two values do roughly 95% of days fall?
7. Explain in two sentences why prices can never be negative but returns can, using the lognormal idea.
8. (Short code) Using `tantra.quant.returns` and `synthetic_bars`, print the excess kurtosis of a 250-day NIFTY series. Is it positive or negative?

### Solutions

1. μ = 0.0; deviations 0.3, −0.5, 0.2, 0.1, −0.1; squares sum = 0.09+0.25+0.04+0.01+0.01 = 0.40; σ² = 0.40/5 = 0.08; σ = √0.08 ≈ 0.2828%.
2. Simple = 205/200 − 1 = 0.025 (2.5%); log = ln(1.025) ≈ 0.0247. Simple is slightly larger because `ln(1+r) < r` for r > 0.
3. σ_annual ≈ 0.8% × √252 ≈ 0.8% × 15.87 ≈ 12.7%. 252 trading sessions; √252 because *variance* adds over independent days, and σ is its root.
4. (a) negative skew, (b) positive skew, (c) zero skew. (a) is worst for long-only.
5. Excess = 4.0 − 3 = 1.0 — fat tails relative to normal.
6. μ ± 2σ → −1.98% to +2.02%.
7. Prices evolve multiplicatively (lognormal) so they can never hit zero from above; returns are log-price *differences*, which can be negative when price falls.
8. Run the code; with typical seeded data excess kurtosis comes out clearly positive (fat tails).

## Quiz bank

| Question | A | B | C | D | Answer |
|---|---|---|---|---|---|
| Population variance divides by | n−1 | n | √n | n² | B |
| The median resists outliers because it depends on | all values | squared values | sorted position | the mode | C |
| Log returns are preferred in research because they | are bigger | are time-additive | need no prices | remove kurtosis | B |
| σ_annual ≈ σ_daily × | 252 | √252 | 1/252 | 12 | B |
| A distribution with occasional large losses has | positive skew | zero skew | negative skew | infinite mean | C |
| Excess kurtosis of a normal distribution is | 3 | 0 | 1 | −1 | B |
| Leptokurtic returns mean | thinner tails | clumped volatility | no skew | constant σ | B |
| z = 2 for μ=0, σ=1 means the value is | 0 | 1 | 2 | 4 | C |
| Prices are modeled as | normal | lognormal | uniform | constant | B |
| Annualization uses 252 because that is roughly the count of | calendar days | trading sessions | weeks | months | B |

## Glossary

- **Mean (μ)** — arithmetic average `Σx/n`; the "center" of the data.
- **Median** — middle value when sorted; robust to outliers.
- **Variance (σ²)** — average squared deviation from the mean.
- **Standard deviation (σ)** — √variance; the default daily risk measure.
- **Population vs sample** — all members vs a subset; denominators `n` vs `n−1`.
- **Simple return** — `P_t/P_{t−1} − 1`; intuitive but not time-additive.
- **Log return** — `ln(P_t/P_{t−1})`; time-additive, used in quant work.
- **Annualized σ** — `σ_daily × √252`, the yearly volatility rescaling.
- **Skewness** — `(1/n)Σ((x−μ)/σ)³`; asymmetry of the return distribution.
- **Kurtosis** — `(1/n)Σ((x−μ)/σ)⁴`; tail thickness; normal = 3.
- **Excess kurtosis** — kurtosis − 3; 0 means "normal tails".
- **Lognormal** — price process bounded below at zero; the B-S assumption.
- **z-score** — `(x−μ)/σ`; standard-deviation distance from the mean.

## Reading assignment

Read the statistics chapters of the core books listed in the [reading list](../appendices/reading-list.md) — in particular IFMC chapters 22 and 27–28 (descriptive statistics, distributions, and return measurement) and PGP Module T1 topics on descriptive statistics. Skim CFTe II Appendix G for the exam-style treatment of skewness and kurtosis.

## Assessment reminder

This module feeds the statistics lab (return-series analysis of an index, Excel + Decimal script) and the statistics-definitions quiz; see the [assessment plan](../front/assessment.md) for how the weekly journal and lab notebook count toward your end-term grade.

**Next:** [M2 — Correlation, Regression & ANOVA](m2-correlation-regression.md)
