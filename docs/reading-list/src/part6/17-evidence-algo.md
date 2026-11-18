# 17 · Evidence-Based & Algorithmic Trading

> Part VI · Chapter 17 · Books: 2 · Topic level: **deep end** ▸ micro

## What this topic is about

[Chapter 16](16-advanced-price-action.md) taught you to read price like a
professional. This chapter asks the question every professional eventually has
to answer: **how do you know what you are reading actually works?** The deep end
turns philosophical, then computational. David Aronson supplies the philosophy —
the scientific method applied to trading signals — and Ernest Chan supplies the
machine: a practical workflow for building, testing, and sizing small algorithms.

Honest prerequisites first: this is the point in the library where you need basic
statistics (mean, standard deviation, distributions, the idea of a hypothesis
test) and comfort writing small scripts — in practice today, Python. If either is
shaky, treat this chapter as the roadmap and come back when the skills are warm.
The two books below assume a reader who can compute a mean and run a backtest,
not a quant fund.

The stakes: everything before this chapter was a set of claims — price action
works, levels work, momentum works. Aronson's argument is that most of those
claims, as usually tested, are unfalsifiable or untested. The only honest test
is out-of-sample and statistical. Chan's contribution is the mundane,
transferable engineering: costs, walk-forward optimization, position sizing —
the 10% edge destroyed by 15% of friction, and how to measure both.

Macro→micro map: this chapter feeds everything that comes after, including the
[AI Study Companion](../ai-companion.md) chapter, which expands these tools with
modern ML/LLM assistants. The workspace's own Tantra quant platform is a practical
implementation of exactly this loop — Python strategies on a Rust engine.

## The books on this topic

| Title | Author | Year | Rating | Role |
|---|---|---|---|---|
| Evidence-Based Technical Analysis | David Aronson | 2007 | ★ 4.0 | The scientific method |
| Algorithmic Trading | Ernest P. Chan | 2013 | ★ 4.1 | The practical workflow |

## Study synthesis — what the books jointly teach

**1. An edge is not proven in-sample.**
Aronson's first and hardest lesson: performance on the data you fitted the rule
to (in-sample) is near-meaningless, because the rule was chosen *because* it
worked on those bars. Only out-of-sample performance — bars the rule never saw —
is evidence.

```text
in-sample     = fit the rule, measure on the same data   -> optimism
out-of-sample = freeze the rule, measure on unseen data  -> evidence
```

**2. Overfitting and data mining fool everyone.**
The more rules, thresholds, and indicator combinations you try, the more likely
one looks spectacular purely by chance. Aronson calls this data-mining bias;
statisticians call it the multiple-testing problem. A backtest that "shops" for
the best variant is silently performing thousands of tests and reporting only the
winner.

**3. Frame a null hypothesis and demand significance.**
Before trusting a signal, state what would be true if the signal had no edge —
the null hypothesis — then ask whether the observed result could plausibly arise
under it.

```text
null hypothesis H0: the signal has no edge
   P(up | signal) = P(up | no signal)
if the test statistic under H0 is very unlikely, the edge "is significant"
significance level: p < 0.05, or stricter after many tests
```

**4. Two strategy families cover most of the field.**
Chan's practical taxonomy: **mean reversion** (prices snap back — trade the
stretched) and **momentum/trend** (prices persist — trade the moving). Mean
reversion is usually coded with a z-score:

```text
z = (price - rolling mean) / rolling standard deviation
  z > +2  -> stretched high, expect a snap back down   (mean reversion: fade)
  z < -2  -> stretched low, expect a snap back up      (mean reversion: buy)
```

Momentum instead buys strength and rides it. The two live in different regimes —
the skill is knowing which regime you are in.

**5. Costs are part of the strategy, not an afterthought.**
Chan's reports center on profit factors (gross profit / gross loss) and
Sharpe-like ratios, but the honest part is that slippage, commissions, and impact
are subtracted *inside* the backtest. A strategy that nets 2% before costs can
vanish after them; a strategy must be measured net, or it is not measured.

**6. Walk-forward optimization is the adult version of backtesting.**
Instead of one all-history run, re-optimize on a rolling window and test each
configuration on the next out-of-sample slice. It bakes out-of-sample testing
into the workflow itself and tells you how stable the edge really is.

**7. Size the position for survival.**
Chan's risk layer: Kelly gives the growth-maximizing fraction, but the intuition
is the lesson — never bet a fraction so large that a drawdown can end you.

```text
Kelly fraction  f* = (b * p - q) / b
  b = net odds received per unit stake
  p = probability of winning,  q = 1 - p
practitioners scale down: half-Kelly or less, because f* assumes known
probabilities that are never truly known
```

Position sizing, drawdown limits, and per-trade risk caps turn a good backtest
into a survivable account.

## Book-by-book annotations

### Evidence-Based Technical Analysis — David Aronson (2007, ★ 4.0)

Aronson applies the scientific method and statistical inference to trading
signals. His subject is why most backtested "edges" are artifacts — overfitting,
data snooping, data-mining bias — and how to test honestly: hypothesis,
out-of-sample validation, significance, multiple-testing awareness. The book is a
mindset gate: after it, "it worked in backtest" is no longer an argument.

- **Read it for:** in-sample vs out-of-sample testing; overfitting and
  data-snooping bias; the null hypothesis and significance testing; the
  multiple-testing/data-mining bias argument.
- **Model refresh:** Edition here appears current; your AI companion can still
  expand these notes from its training data.

### Algorithmic Trading — Ernest P. Chan (2013, ★ 4.1)

Chan turns the discipline into a workflow any individual can run. He lays out
mean-reversion and momentum strategies, reports profit factors honestly, and
spends real pages on the unglamorous parts: transaction costs, walk-forward
optimization, Kelly sizing, drawdown. His thesis is the whole chapter in one
line — a small real edge, engineered cleanly, beats a big imagined one.

- **Read it for:** mean reversion vs momentum as the two strategy families;
  profit factors and honest performance reporting; backtesting with slippage and
  commissions; walk-forward optimization; Kelly intuition, drawdown, and
  position sizing.
- **Model refresh:** Edition here appears current; your AI companion can still
  expand these notes from its training data.

## Reading order

1. **Evidence-Based Technical Analysis** — the mindset gate. Read this first; it
   defines what "proof" means for everything after.
2. **Algorithmic Trading** — the implementation. Bring the Aronson discipline to
   Chan's workflow and you have the whole chapter.

Both books assume basic statistics and scripting comfort. If the Python is
rusty, the [AI Study Companion](../ai-companion.md) chapter and the workspace's
Tantra quant platform
(Python strategies, Rust engine) are the modern sandboxes to practice in.

## Self-test questions

1. What is the difference between in-sample and out-of-sample performance, and
   why does only the latter count?
2. Why does trying 1,000 indicator variants guarantee at least one "great"
   backtest by chance?
3. State the null hypothesis you would test before trusting any signal.
4. In Chan's framing, what distinguishes a mean-reversion from a momentum
   strategy?
5. Why must slippage and commissions be subtracted inside the backtest, not
   after it?
6. What does walk-forward optimization do that a single all-history backtest
   cannot?
7. Write the Kelly fraction in ASCII and explain why practitioners trade a
   fraction of it.
8. What is a profit factor, and what does PF below 1.0 mean?

## Cross-links

**Next:** [Chapter 18 · Specialized Systems: Harmonic, Ichimoku, Intermarket & COT](18-specialized-systems.md) ·
**Back:** [Chapter 16](16-advanced-price-action.md)
