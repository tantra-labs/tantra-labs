# 18 · Specialized Systems: Harmonic, Ichimoku, Intermarket & COT

> Part VI · Chapter 18 · Books: 5 · Topic level: deep end ▸ micro

## What this topic is about

These four systems are the deep end's specialist tooling. Each answers a different
question about the same chart: **who is positioned on the other side?** (the
Commitments of Traders report), **what is the whole market telling this one?**
(intermarket analysis), **where does Fibonacci geometry say the turn is?**
(harmonic patterns), and **what is the complete structure of this trend?**
(Ichimoku). They are different lenses, but they belong to one family: all four are
data- or price-based systems a retail trader can run from a normal data feed, and
all four are *timing* tools — they say *when* to act, not what the asset is worth.

This chapter sits at the micro end of the macro→micro path. The earlier parts
built the macro worldview (what a market is, what a bubble is, how risk is sized)
and the discrete strategies (trend, swing, event, pairs). These books go the last
step: instead of a single indicator, each hands you a *complete decision
procedure* — a whole system you could trade alone. That is why they sit here, at
the very end of Part VI, as the deep end's technical ceiling.

The chapter is also honest about difficulty. Two of the five books carry warnings
in the collection: harmonic trading is flagged by the source README as complex,
and the Ichimoku book's ★ 3.0 average rating is a fair indicator of its learning
curve. These are not beginner books and the synthesis below marks where "in
practice" is harder than "in the textbook diagram."

One thing none of these systems does is set your position size or your risk — the
discipline you built in the earlier chapters still governs. These systems improve
*when* you act; the risk framework decides *how much*. Read them that way: as the
culmination of the technical curriculum, and the last theory stop before Part
VII's stories.

## The books on this topic

| Title | Author | Year | Rating | Role |
|---|---|---|---|---|
| The Commitments of Traders Bible | Stephen Briese | 2008 | ★ 4.6 | The positioning-data bible |
| Intermarket Trading Strategies | Markos Katsanos | 2009 | ★ 4.6 | The cross-market toolkit |
| Harmonic Trading, Volume One | Scott M. Carney | 2010 | ★ 3.6 | The Fibonacci pattern system |
| Harmonic Trading, Volume Two | Scott M. Carney | 2010 | ★ 4.2 | The trade-management sequel |
| Trading with Ichimoku Clouds | Manesh Patel | 2010 | ★ 3.0 | The all-in-one charting method |

## Study synthesis — what the books jointly teach

**1. Commitments of Traders — reading the other side's position.**

Every Friday the US CFTC publishes the weekly Commitments of Traders (COT)
report, showing open interest as of the prior Tuesday, split into three groups:
**commercials** (hedgers — producers, processors, and consumers who use futures
to protect a physical business), **non-commercials** (large speculators — funds
and big discretionary traders), and **non-reportable/small traders** (everyone
below the reporting threshold). The theory of the book: commercials are informed
by the cash market they physically operate in, while speculators ride trends —
so the two groups are usually on opposite sides.

Briese's **COT Index** turns the raw numbers into a bounded signal. It
normalizes a group's net position within its recent range:

```text
COT Index = 100 × (current net − lowest net over window)
             / (highest net over window − lowest net over window)
```

A reading near 100 means the group is near its most-extended long in the window;
near 0, its most-extended short. The signal is **contrarian**: when the
commercials (the informed hedgers) are heavily long and the speculators heavily
short, the crowd is often on the wrong side of an imminent turn. Briese's
divergence signals fire when price makes a new high while commercial net longs
are falling — the smart money quietly fading the move. The same logic is portable
to markets without a COT report: the FPI/DII positioning data published daily in
India is a cousin of the same idea.

**2. Intermarket analysis — four markets, one tape.**

Intermarket analysis treats equities, bonds, commodities, and currencies as one
connected system rather than four separate ones. The classical relationships: a
falling dollar tends to push dollar-priced commodities up; rising commodity
prices feed inflation expectations and press bond prices down; rising bond
yields in turn pressure equity multiples. Every market's move is simultaneously a
cause and a confirmation for the others. The trading consequence is the
**intermarket filter**: take a long in a stock only when the related market that
*leads* it is rising, and a short only when the leader is falling.

Katsanos's book turns that idea from anecdote into method. It shows how to
measure correlations between the market you trade and the markets that might lead
it, how to test for leading/lagging relationships, and how to combine the
confirming market with the price signal into a mechanical strategy. This is the
same lineage as John Murphy's intermarket work and Chapter 14's Laïdi — the
shared claim is that no market trades in isolation. Katsanos's contribution is
the statistical toolkit that makes the claim testable. The honest caveat he would
accept: correlations drift over time, and a filter that worked in one decade can
silently stop working in the next.

**3. Harmonic patterns — Fibonacci geometry at the turning point.**

Harmonic patterns are named price structures built from Fibonacci ratios: the
**AB=CD**, the **Gartley**, the **butterfly**, the **bat**, and the **crab**.
Each is defined by precise retracement/extension ratios between its swings — the
Gartley's B-leg retraces a specific portion of the X–A leg, the bat's D-point is
defined by its retracement of X–A, and so on. The payoff is the **D-point**: the
place where the completed pattern projects the turn. The entry is at D, with the
stop beyond the pattern's extreme and targets set from the pattern's measured
legs.

Carney's two volumes are the reference for this discipline, and they are
exacting: a pattern that is "almost" the right shape is not the pattern — it is
nothing. That precision is also the honest warning. ⚠️ The source README for this
collection flags harmonic trading as complex, and Volume One's ★ 3.6 average
rating reflects how subjective real-world pattern identification turns out to be.
Textbook diagrams are cleaner than live charts; treat the ratios as a discipline,
not a shortcut.

**4. Ichimoku — one chart, one complete system.**

Ichimoku Kinko Hyo ("one look, balanced chart") bundles five lines into a single
system:

```text
Tenkan-sen      conversion line  — midpoint of the last 9 periods' high/low
Kijun-sen       base line        — midpoint of the last 26 periods' high/low
Senkou Span A   — midpoint of Tenkan & Kijun, plotted 26 periods ahead
Senkou Span B   — midpoint of the last 52 periods' high/low, plotted 26 periods ahead
Chikou Span     — today's close plotted 26 periods back
```

Senkou Span A and B together form the **Kumo** (the Cloud). The system's rules
are mechanical: price above the Cloud is an uptrend, price below is a downtrend,
and the Cloud's thickness shows how strong that support/resistance zone is.
Kijun-sen acts as the pullback line, Chikou-sen confirms the trend when it sits
on the correct side of historical price. Trend, momentum, support/resistance, and
entry timing all come from the same five lines — that is the appeal.

That comprehensiveness is also its weakness: the collection's single Ichimoku
book carries ★ 3.0, a fair reflection of a real learning curve. The Cloud does
not read like a native language on day one. Expect to study it before trusting
it.

## Book-by-book annotations

### The Commitments of Traders Bible — Stephen Briese (2008, ★ 4.6)

The definitive book on the COT report. Briese, who has followed and written about
the report since the 1980s, explains what each trader category actually does in
the futures market, how to construct the COT Index and related positioning
indicators, and how to trade the divergences between price and commercial
positioning. It is the least subjective system in this chapter: everything is
computed from published data.

- **Read it for:** the weekly COT report structure; the COT Index and its
  construction; divergence-based signals; why extreme positioning is a
  contrarian warning rather than a confirmation.
- **Model refresh:** Edition here appears current; your AI companion can still
  expand these notes from its training data.

### Intermarket Trading Strategies — Markos Katsanos (2009, ★ 4.6)

The statistical bridge between intermarket theory and practice. Katsanos shows
how to measure intermarket correlations with spreadsheets and modest software,
how to test which market leads the one you trade, and how to build filters that
require cross-market confirmation before a signal counts.

- **Read it for:** correlation and leading-indicator measurement; intermarket
  filters for equity and commodity trades; the backtesting methodology; the
  bridge from Murphy's intermarket theory to testable rules.
- **Model refresh:** Edition here appears current; your AI companion can still
  expand these notes from its training data.

### Harmonic Trading, Volume One — Scott M. Carney (2010, ★ 3.6)

The system book for harmonic patterns: the Fibonacci ratios, the five named
patterns (AB=CD, Gartley, butterfly, bat, crab), and the D-point entry
discipline. Read it with the ⚠️ warning in place — the source README flags
harmonic trading as complex, and the rating reflects the subjectivity of
real-world pattern identification.

- **Read it for:** the exact ratio requirements per pattern; the D-point as the
  entry; price-objective measurement; the discipline of waiting for a valid
  pattern instead of an approximate one.
- **Model refresh:** A later edition may exist — ask your AI study companion to
  check its training data for any edition newer than 2010.

### Harmonic Trading, Volume Two — Scott M. Carney (2010, ★ 4.2)

The sequel, and the payoff for readers who survive Volume One: trade management
after the entry. Volume Two covers what the pattern diagrams cannot — where to
place the stop, how to scale and manage the position as the trade moves toward
its D-point targets, and how to combine harmonic entries with confirming
technical context.

- **Read it for:** trade management after the D-point; stop placement and
  scaling; combining harmonic entries with trend confirmation; the complete
  two-volume method.
- **Model refresh:** A later edition may exist — ask your AI study companion to
  check its training data for any edition newer than 2010.

### Trading with Ichimoku Clouds — Manesh Patel (2010, ★ 3.0)

The collection's Ichimoku entry: the five lines, the Kumo (Cloud), and the
mechanical trading rules built on price/Cloud/Kijun/Chikou alignment. The honest
⚠️ note is visible in the ★ 3.0 rating before you open the book: Ichimoku is an
all-in-one system with a genuine learning curve — it rewards study and punishes
skimming.

- **Read it for:** the five-line anatomy of Ichimoku; Cloud trend rules and
  support/resistance; Kijun-sen pullback entries; a complete, self-contained
  charting method.
- **Model refresh:** Edition here appears current; your AI companion can still
  expand these notes from its training data.

## Reading order

1. **The Commitments of Traders Bible** — the most objective lens; start here.
2. **Intermarket Trading Strategies** — the cross-asset filter.
3. **Trading with Ichimoku Clouds** — the all-in-one system.
4. **Harmonic Trading, Volume One** — the pattern system, only if geometry
   appeals to you.
5. **Harmonic Trading, Volume Two** — only if you commit to harmonic trading.

## Self-test questions

1. Name the three COT report categories, and which one is the hedger.
2. How is the COT Index calculated, and what does a reading near 100 imply?
3. Why is extreme positioning a contrarian signal rather than a confirmation?
4. Give one intermarket relationship and how you would use it as a trade filter.
5. What do the AB=CD, Gartley, butterfly, bat, and crab share — and where is the
   entry in each?
6. Why is an "almost correct" harmonic pattern untradeable?
7. Which two Ichimoku lines form the Cloud, and what does price above the Cloud
   mean?
8. What do all four systems have in common about predicting direction?

## Cross-links

**Next:** [Chapter 19 · Options](19-options.md) ·
**Back:** [Chapter 17 · Evidence-Based & Algorithmic Trading](17-evidence-algo.md)
