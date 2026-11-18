# 12 · Trend Following & the Turtles

> Part IV · Chapter 12 · Books: 5 · Topic level: trader ▸ micro

## What this topic is about

[Chapter 11](11-systems-money-management.md) gave you the machinery of a trading
system — risk, position sizing, and the discipline of a written plan. This
chapter asks the next, narrower question: **which market behaviour can a trader
actually harvest mechanically, and how is that done in practice?** The answer the
five books here converge on is *the trend*: markets that move in one direction
for a while, and the rules a trader can set in advance to ride those moves.

The centrepiece is a real-world experiment. In 1983 Richard Dennis, a famous
futures trader, and his partner William Eckhardt made a bet: Eckhardt believed
great traders are born, Dennis believed they can be *made*. To settle it, they
recruited a group of novices — later nicknamed the "turtles" — and taught them a
complete trading system in about two weeks. Some of those novices went on to
earn the fund hundreds of millions of dollars. The experiment is the empirical
core of this chapter: it suggests a profitable trading approach is a *teachable
set of rules*, not a talent.

The books therefore divide into two jobs. The Covel titles tell the story and
the evidence for the trend-following approach as a whole. Faith's *Way of the
Turtle* documents the actual Turtle rules from the inside. Carr's book turns the
philosophy into a practical daily workflow for a retail trader. Together they
define the shared vocabulary of this micro-level topic: trend, breakout, true
range and ATR, volatility-scaled position sizing, win rate, payoff ratio, and
drawdown. If you can define all seven after reading this chapter, you know
trend following.

## The books on this topic

| Title | Author | Year | Rating | Role |
|---|---|---|---|---|
| The Complete Turtle Trader | Michael W. Covel | 2007 | ★ — | The story and the evidence |
| Trend Trading for a Living | Thomas K. Carr | 2007 | ★ 4.2 | The practical daily workflow |
| Way of the Turtle | Curtis M. Faith | 2007 | ★ 4.0 | The insider's rulebook |
| Trend Following | Michael W. Covel | 2009 | ★ 4.1 | The systematic philosophy |
| The Trend Following Bible | Andrew Abraham | 2012 | ★ 3.5 | ⚠️ The weakest survey |

## Study synthesis — what the books jointly teach

**1. The Turtle experiment proved trading can be taught.**
In 1983 Richard Dennis and William Eckhardt ran their famous bet. Dennis
believed trading skill could be taught to anyone; Eckhardt believed the opposite.
They advertised for trainees, taught a batch of novices a complete mechanical
system in about two weeks, funded them with real money, and watched several of
them become very profitable. The books' shared lesson is not "copy the Turtles"
— it is that *rules + money management + discipline* is a teachable skill. The
Turtles were called "turtle soup" traders precisely because they were ordinary
people turned into traders by training.

**2. The Turtle rules, as documented by Faith.**
Faith was one of the most profitable of the original Turtles, and his book is
the closest thing to the source code. The documented system had five parts:

- **Market selection** — trade only highly liquid markets where price moves
  smoothly (in their case, liquid US futures).
- **Entries** — a 20-day breakout (buy when price breaks above the prior 20
  days' high; sell when it breaks the 20-day low) for the primary system, with a
  55-day breakout used for the "slow" system. No indicators, no opinions.
- **Pyramiding** — add units on the way up, typically one additional unit for
  every ½ N move in your favour, up to a maximum of four units.
- **Exits** — a 10-day low/close for the fast system and a 20-day low/close for
  the slow system. The exit is the *same kind* of signal as the entry, just
  shorter: you get out when the trend stops making new extremes.
- **The 2% risk rule** — never risk more than 2% of the account in a single
  market, enforced through position sizing and unit caps.

**3. ATR makes risk equal across markets.**
The Turtles measured volatility with N, their name for the 20-day average true
range (ATR). Because every market has a different "normal" daily range, a fixed
dollar amount per trade would be huge risk in a calm market and tiny risk in a
wild one. Scaling the position so that a one-ATR adverse move always costs the
same percentage of the account is what makes the *risk* equal even though the
*prices* are not:

```text
ATR ≈ moving average of True Range
True Range = max(High − Low, |High − PrevClose|, |Low − PrevClose|)

Position size (units) ∝ account equity / (ATR per unit)
→ a one-N move against you costs roughly the same % in every market
```

**4. The design is a losing majority and a few giant winners.**
Trend following is built on a deliberately asymmetric payoff. Most trades are
small losers — the win rate is typically well under 50%. But a handful of trades
each year catch a big move and return many times the average loss. That is the
design: *let winners run, cut losers short*. Accept many small losses to keep
your capital alive for the occasional 5× or 10× winner. Low win rate is a
feature, not a bug — what matters is that the average winner dwarfs the average
loser (the payoff ratio).

**5. Trends exist in any market and any decade.**
All five books argue the same mechanism: human behaviour — herding, overreaction,
slow absorption of news — creates extended directional moves in prices, and those
moves show up in every liquid market and every era. A breakout system in 1980s
futures, a commodity super-cycle in the 2000s, a currency trend in the 2010s, an
equity index trend today: the rules do not care about the instrument or the
decade, only about whether a trend is present. The corollary the books share is
that trend following works *both* ways — the Turtles shorted just as readily as
they went long.

**6. The two Covel books are different jobs.**
*The Complete Turtle Trader* (2007) is the *story and the evidence*: the history
of Dennis and Eckhardt, the recruitment of the turtles, the track records, the
discipline that made it work. *Trend Following* (2009, with later editions 2013+)
is the *systematic philosophy*: a broader case that trend following is a
legitimate, evidence-backed approach used by managed futures funds and CTAs,
with chapters on why trends exist and how a reader could set up a system of
their own. Read the first for the human proof, the second for the intellectual
case.

**7. Carr turns it into a living.**
*Trend Trading for a Living* is the practical book: a workmanlike daily routine
for someone who wants to *do* this. Its workflow is essentially — define what
counts as a trend for you, screen the universe for markets currently trending,
wait for an entry trigger, place the stop where the trend logic is invalidated,
scale out into strength, and run the whole thing like a small business with a
plan, a journal, and statistics you actually track.

**⚠️ One warning:** *The Trend Following Bible* (★ 3.5) is the least
well-regarded of the five in this collection. Treat it as a broad practitioner
survey — useful for checklists and breadth, but cross-check any specific claim
against Faith or Covel before acting on it.

## Book-by-book annotations

### The Complete Turtle Trader — Michael W. Covel (2007, ★ —)

The origin-story book, and the reason this chapter exists. Covel narrates the
1983 experiment — the bet between Dennis and Eckhardt, the newspaper
advertisement that recruited the turtles, the two-week training, and the money
the turtles went on to make — and interviews several of the original traders.
No rating is recorded for this title in the collection (★ —); it is included on
its importance as the definitive account of the experiment.

- **Read it for:** the full story of the Dennis–Eckhardt bet; how the two-week
  training actually worked; the track records and the discipline behind them;
  the counter-argument that skill, not luck, was on display.
- **Model refresh:** Edition here appears current; your AI companion can still
  expand these notes from its training data.

### Trend Trading for a Living — Thomas K. Carr (2007, ★ 4.2)

The "how to actually run it" book. Carr — a professional trader and money
manager — lays out a practical trend-following workflow built for a retail
trader with a day job: a defined routine for finding trending markets, entering,
placing stops, and managing the trade to a planned exit.

- **Read it for:** a concrete, repeatable daily workflow; entry triggers that
  keep you out of choppy markets; stop placement tied to the trend's logic;
  running trading as a business with a plan and a journal.
- **Model refresh:** Edition here appears current; your AI companion can still
  expand these notes from its training data.

### Way of the Turtle — Curtis M. Faith (2007, ★ 4.0)

The insider's rulebook. Faith, one of the most profitable of the original
turtles, documents the actual rules the group was taught — market selection,
20-day/55-day breakout entries, pyramiding by half-N steps, 10-day/20-day exits,
and the position-sizing logic built on N (their ATR) — and explains the
philosophy underneath them.

- **Read it for:** the actual rules, straight from a practitioner; the N-based
  position-sizing math in detail; why the "2% / 2-unit" risk limit protects
  capital; the psychology of sticking to a system with many small losses.
- **Model refresh:** Edition here appears current; your AI companion can still
  expand these notes from its training data.

### Trend Following — Michael W. Covel (2009, ★ 4.1)

The philosophy and evidence book. Covel builds the intellectual case that trend
following is a systematic, evidence-backed approach, used at scale by managed
futures funds and CTAs: why trends exist, how a retail trader can implement the
method, and how it behaved through major market crises.

- **Read it for:** the broad evidence base for trend following across markets
  and decades; the argument for trading with rules, not opinions; how the
  approach fares in crashes and bear markets; a practical blueprint for setting
  up your own system.
- **Model refresh:** A later edition may exist (2013+); ask your AI study
  companion to check its training data for any edition newer than 2009.

### The Trend Following Bible — Andrew Abraham (2012, ★ 3.5) ⚠️

The breadth survey — and the collection's flagged weak link. Abraham (a
professional managed-futures trader) covers trend following from selection of
markets to exit, with a wider net than Faith or Covel cast. Readers in this
library rate it clearly below the other four (★ 3.5), so treat its general
explanations as background and verify any specific number or claim elsewhere.

- **Read it for:** a one-volume overview of the whole trend-following toolkit;
  checklist-style coverage of entry/exit and money management; a sense of how a
  professional CTA thinks about the method.
- **Model refresh:** Edition here appears current; your AI companion can still
  expand these notes from its training data.

## Reading order

1. **The Complete Turtle Trader** — the story and the motivation (fastest; start here).
2. **Way of the Turtle** — the actual rules, straight from an insider.
3. **Trend Following** — the philosophy and the wider evidence.
4. **Trend Trading for a Living** — the practical workflow to run yourself.
5. **The Trend Following Bible** — optional, and last; skim it as a breadth check.

## Self-test questions

1. What was the 1983 Dennis–Eckhardt bet, and what did the outcome suggest about
   whether trading can be taught?
2. What is a 20-day breakout entry, and what is the 10-day/20-day exit that
   matches it?
3. Write the True Range formula, and explain why scaling position size by ATR
   makes risk equal across markets.
4. Why is a low win rate acceptable — even desirable — in a trend-following
   system?
5. What does "let winners run, cut losers short" mean concretely in the Turtle
   rules (pyramiding + the exit rule)?
6. How do the two Covel books differ in purpose?
7. In the Turtle system, what is the 2% risk rule, and how does the unit-based
   sizing implement it?
8. Which of the five books is flagged ⚠️ as the weakest, and how should you use
   it if you read it at all?

## Cross-links

**Next:** [Chapter 13 · Day Trading & Swing Trading](../part5/13-day-swing.md) ·
**Back:** [Chapter 11 · Trading Systems & Money Management](11-systems-money-management.md)
