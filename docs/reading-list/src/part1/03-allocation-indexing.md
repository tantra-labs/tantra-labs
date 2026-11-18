# 3 · Asset Allocation, Indexing & Systematic Strategy

> Part I · Chapter 3 · Books: 3 · Topic level: macro ▸ micro

## What this topic is about

[Chapter 2](02-investing-philosophy.md) built a worldview — price is what you
pay, value is what you get, and the gap is where investing happens. This chapter
takes that worldview and asks the practical follow-up: **how do you turn a
belief into a portfolio you can actually run?** The three books here are
deliberately small ("little books"), and all three give the same kind of answer:
not prediction, but *rules*.

The books disagree on whether you can beat the market, which makes them useful
to study together. John Bogle says you cannot reliably beat the market, so buy
the whole market cheaply and hold it — indexing. Joel Greenblatt says you can
beat the average by running a mechanical two-factor screen — the magic formula —
that combines value and quality without needing anyone's opinion. Gary Antonacci
says the market's own momentum is the strongest signal, so a rules-based
rotation among asset classes beats static allocation. All three nevertheless
agree on the deeper point: emotion is the enemy, cost is a variable you control,
and a rule you can follow dispassionately beats a forecast you cannot help
second-guessing.

This chapter sits at the hinge of the macro→micro path. It is macro because it
settles the allocation questions — how much of which asset, at what cost, under
what regime. It feeds micro because Greenblatt's screen hands Part II its raw
material: a shortlist of companies that still need the balance-sheet and
valuation work of [Chapter 4](../part2/04-fundamentals-valuation.md). And it
completes the loop with [Chapter 1](01-how-markets-work.md), which first raised
the index-fund argument: this chapter shows you what indexing actually costs
you, and what it buys you.

For the Indian reader the chapter is directly runnable: Nifty 50 and Sensex
index funds supply the low-cost haystack, your broker's stock screener can
produce magic-formula ranks from exchange data, and the momentum rule needs
nothing but price history you can download for free.

## The books on this topic

| Title | Author | Year | Rating | Role |
|---|---|---|---|---|
| The Little Book That Beats the Market | Joel Greenblatt | 2006 | ★ 4.1 | The value-plus-quality screener |
| The Little Book of Common Sense Investing | John C. Bogle | 2007 | ★ 4.6 | The index-fund case |
| Dual Momentum Investing | Gary Antonacci | 2015 | ★ 4.7 | The systematic rotation playbook |

## Study synthesis — what the books jointly teach

**1. The relentless rules of humble arithmetic.**
Bogle's phrase is the chapter's foundation: what you earn is what the market
gives, *minus* what you pay to get it. Costs compound against you year after
year, so a small annual cost difference grows into an enormous wealth difference
over decades. The arithmetic is brutal and simple:

```text
net return = gross market return − costs
```

Because costs are the one variable the investor fully controls, controlling them
is the first and largest decision in every strategy in this chapter — the
expense ratio of an index fund, the turnover of a screen, and the taxes of a
monthly rotation are all cost decisions wearing different clothes.

**2. The index-fund case.**
Before costs, the average investor must earn the market return — buying
everything at market weight *is* the market. After costs, the average active
investor must earn less than the market return. Therefore the cheapest way to
own the market — a broad index fund or ETF — beats the average active investor,
mechanically. Bogle's image: don't look for the needle; buy the haystack. On
NSE/BSE, the equivalent haystack is an index fund or ETF tracking the Nifty 50
or the Sensex, at an expense ratio close to zero.

**3. The magic formula: value plus quality, mechanically.**
Greenblatt's screen ranks a universe of stocks by two numbers and buys the
best-ranked:

```text
Return on Capital = EBIT / (Net Working Capital + Net Fixed Assets)
Earnings Yield    = EBIT / Enterprise Value
```

Return on capital is Fisher's quality — how much profit a business earns on the
capital it actually uses. Earnings yield is Graham's cheapness — how much the
business earns relative to the price someone pays for the whole enterprise. Rank
every stock by each measure, combine the two ranks, buy the top ~30, hold a
year, repeat. The formula is the [Chapter 2](02-investing-philosophy.md)
synthesis (Graham plus Fisher) turned into an algorithm — and its most important
lesson is psychological: expect it to underperform the market for two to three
years at a stretch, because buying cheap and good companies is out of fashion
precisely when it is working.

**4. Momentum is a real, repeatable factor.**
Antonacci's dual momentum is a second kind of systematic rule, built from prices
alone:

- **Lookback:** measure each asset's 12-month return, skipping the most recent
  month (which tends to reverse in the short term).
- **Absolute momentum:** only buy assets whose own 12-month return is positive —
  the trend is up.
- **Relative momentum:** among assets that pass absolute momentum, buy the
  strongest.
- **Rebalance monthly**, and when no equity class passes absolute momentum, hold
  bonds or cash instead.

```text
momentum(t) = Price(t−1) / Price(t−13) − 1    # 12-month return, last month skipped
```

The rule needs no earnings forecast and no macro view — it only reads prices.
That is the point: a systematic factor can replace prediction entirely.

**5. Systematic rules replace prediction.**
None of the three books asks you to forecast earnings or interest rates. Bogle's
strategy has no opinion at all; Greenblatt's formula never consults your
judgment about the companies it selects; Antonacci's system reacts only to
realized returns. The shared thesis is the chapter's title in miniature: decide
the rule in advance, follow it when it is uncomfortable, and let arithmetic and
time do the work. This is also the bridge to Part II, where the screens from
this chapter meet the fundamentals and valuation of
[Chapter 4](../part2/04-fundamentals-valuation.md).

**6. Where the three books agree and disagree.**
They agree that costs, discipline, and diversification matter more than
brilliance. They disagree on the market's efficiency: Bogle holds that beating
the market is a fool's errand, while Greenblatt and Antonacci each offer a
systematic way to beat it. The honest reading is that even the "beaters" are
passive in spirit — they run rules, not predictions — so the disagreement is
narrower than it looks, and all three books can coexist in one portfolio: an
index core, a value-quality sleeve, and a momentum overlay.

## Book-by-book annotations

### The Little Book That Beats the Market — Joel Greenblatt (2006, ★ 4.1)

Greenblatt's bet is that two simple, decades-old ideas — buy good businesses,
and only at attractive prices — outperform when combined mechanically. The book
explains the magic formula through a fable, then hands you the exact screen:
rank by return on capital and earnings yield, buy the top-ranked thirty,
rebalance annually. Its most valuable chapter is the warning: the formula will
lag the market for multi-year stretches, and the only way to capture the
long-run edge is to keep running the rule through the disappointment.

- **Read it for:** the two magic-formula variables and why each matters; the
  annual-rebalance discipline; the "expect underperformance for 2–3 years"
  psychology; how to run the screen on NSE/BSE data or your broker's stock
  screener.
- **Model refresh:** Newer edition: later eds., 2010/2015; ask your AI study
  companion to expand these notes from its training data.

### The Little Book of Common Sense Investing — John C. Bogle (2007, ★ 4.6)

The index-fund case, argued by the man who created the first retail index fund.
Bogle decomposes the market's long-run return into investment return (yield
plus earnings growth) and speculative return (changes in valuation), then shows
that costs drag the average investor below the market, with compounding making
the drag decisive. His prescription is deliberately boring: buy the whole
market, keep costs near zero, match stocks to bonds by your own risk tolerance,
and never sell on news.

- **Read it for:** the arithmetic of costs stated as an equation; the empirical
  record of index funds versus active funds; the yield-plus-growth decomposition
  of market return; the plain-language case for owning the haystack on
  Nifty 50, the Sensex, or any broad index.
- **Model refresh:** Newer edition: 10th-anniversary ed., 2017; ask your AI
  study companion to expand these notes from its training data.

### Dual Momentum Investing — Gary Antonacci (2015, ★ 4.7)

Antonacci's "global equities momentum" model combines two well-researched
effects — a market's own positive trend (absolute momentum) and strength
relative to other markets (relative momentum) — into a monthly rule: hold the
strongest equity asset whose own 12-month trend is positive, and switch to bonds
or cash when no equity asset passes the test. The book is the most quantitative
of the three, with decades of backtests showing that the rule survives bear
markets that buy-and-hold does not, and it is the clearest single demonstration
that a systematic factor can replace prediction.

- **Read it for:** absolute versus relative momentum defined precisely; the
  12-month lookback and why the most recent month is skipped; the
  monthly-rebalance discipline; a full worked system — US and non-US equities
  plus bonds — that you can rebuild with index funds.
- **Model refresh:** Edition here appears current; your AI companion can still
  expand these notes from its training data.

## Reading order

1. **The Little Book of Common Sense Investing** — the baseline: why own the
   market at all, and at what cost.
2. **The Little Book That Beats the Market** — the value-plus-quality screen you
   run on top of the index core.
3. **Dual Momentum Investing** — the momentum and rotation layer; read last
   because it presupposes the allocation question the first two books settle.

A faster route: if you already own index funds and your question is "can rules
do better?", read Greenblatt first and Antonacci second, then return to Bogle as
the reality check.

## Self-test questions

1. State Bogle's "relentless rules of humble arithmetic" as an equation. What
   does the average investor earn, in words?
2. Why must the average active investor, as a group, underperform the index?
   (Think about what the average must be before costs.)
3. Define the two magic-formula variables in words, and write them in ASCII.
4. Why does the magic formula combine *quality* (return on capital) and
   *cheapness* (earnings yield) rather than using either alone?
5. Define absolute momentum and relative momentum. What does the dual-momentum
   rule do when no equity asset passes absolute momentum?
6. Why does the momentum lookback skip the most recent month?
7. Give one example from each book of a rule that "replaces prediction." What,
   if anything, do the three have to forecast?
8. Where would a Nifty 50 index fund sit inside the dual-momentum asset set,
   and what data would you need to run the monthly rule on it?

## Cross-links

**Next:** [Chapter 4 · Financial Statements, Ratios & Valuation](../part2/04-fundamentals-valuation.md) ·
**Back to:** [Chapter 2 · The Investing Masters: Value & Growth](02-investing-philosophy.md)
