# 14 · Forex: Currencies as an Asset Class

> Part V · Chapter 14 · Books: 18 · Topic level: styles ▸ instrument ▸ micro

## What this topic is about

The forex market is the largest and most liquid financial market in the world —
a decentralized, over-the-counter (OTC) network of banks, funds, brokers, and
retail traders exchanging trillions of dollars every day. There is no central
exchange and no opening bell; the market runs nearly 24 hours a day from Sydney
to New York. The central question of this chapter: can a retail trader treat
currencies as a tradeable asset class — and at what cost?

In the macro→micro path, forex is a micro-instrument topic: it follows
[Chapter 13 · Day Trading & Swing Trading](13-day-swing.md) (the styles its
books assume) and feeds [Chapter 15 · Binary Options — Read the
Warning](15-binary-options.md) (the instrument that preys on the same retail
urges). Everything here is one instrument — the currency pair — studied from
"what is a pip" to institutional forecasting.

The eighteen books share one vocabulary the reader must own first: currency
**pairs**, **base** and **quote** currencies, **pips**, **lot sizes**, **margin**
and **leverage**, and **rollover/swap**. The beginner books hand you that
vocabulary, because the strategy books assume it and the deep books assume both.

The chapter is really two books in one: a macro asset class driven by central
banks, interest-rate differentials, and the carry trade (Laïdi, Henderson,
Saettele), and an intraday technical playground driven by news and price action
(Ponsi, VanMetre, Lien). Both are true; the books only disagree about which
matters on which timeframe.

Finally, the honest warning that shapes everything: **leverage magnifies both
ways** — a 2% adverse move can wipe out a thinly margined account. That is why
the collection deliberately includes low-rated and flagged books, so that
studying them teaches caution. Read this chapter with the risk section open.

## The books on this topic

| Title | Author | Year | Rating | Role |
|---|---|---|---|---|
| Day Trading the Currency Market | Kathy Lien | 2005 | ★ 3.8 | The news-trader's playbook |
| Forex Patterns and Probabilities | Ed Ponsi | 2007 | ★ 4.1 | The pattern framework |
| The 10 Essentials of Forex Trading | Jared F. Martinez | 2007 | ★ 3.9 | The discipline checklist |
| Currency Trading and Intermarket Analysis | Ashraf Laïdi | 2008 | ★ 4.0 | The intermarket bridge |
| Day Trading and Swing Trading the Currency Market | Kathy Lien | 2008 (2nd ed.) | ★ 4.0 | The two-timeframe playbook |
| Sentiment in the Forex Market | Jamie Saettele | 2008 | ★ 4.0 | The contrarian compass |
| Essentials of Foreign Exchange Trading | James Chen | 2009 | ★ 4.1 | The mechanics textbook |
| Forex Trading Secrets | James Dicks | 2010 | ★ 3.3 | ⚠️ The flagged warning |
| How to Make a Living Trading Foreign Exchange | Courtney D. Smith | 2010 | ★ 3.6 | ⚠️ The over-promise warning |
| The Little Book of Currency Trading | Kathy Lien | 2010 | ★ 3.8 | The pocket guide |
| Attacking Currency Trends | Steve VanMetre | 2011 | ★ 4.6 | The trend trader's bible |
| Currency Trading For Dummies | Kathleen Brooks & Brian Dolan | 2011 (2nd ed.) | ★ 4.1 | The on-ramp |
| Inside the Currency Market | Jeff Ready | 2011 | ★ 4.0 | The market-structure guide |
| Forex for Beginners | Anna Coulling | 2012 | ★ 4.0 | The beginner's primer |
| The Sensible Guide to Forex | Cliff Wachtel | 2012 | ★ 3.8 | The risk-first guide |
| 17 Proven Currency Trading Strategies | Mario Singh | 2013 | ★ 2.4 | ⚠️ The retail-trap warning |
| Currency Strategy | Callum Henderson | 2002 | ★ — | The institutional strategist |
| Forex Trading Basics & Secrets | — | n.d. | ★ — | ⚠️ The unverified warning |

## Study synthesis — what the books jointly teach

**1. The physical market.** Forex is decentralized OTC: banks quote each other
continuously and there is no single price — only the live bid/ask of whoever you
trade with. Every trade is a **pair** (buy one currency, sell the other), written
base/quote: in `GBP/USD = 1.27` the pound is the base and the dollar the quote,
meaning 1 pound buys 1.27 dollars. The **pip** is the smallest standard price
unit (0.0001 on most pairs, 0.01 on JPY pairs) and **lots** are contract sizes
(standard = 100,000, mini = 10,000, micro = 1,000); **margin** lets you control
a large notional with a small deposit while **leverage** multiplies both profits
and losses:

```text
pip value (USD) per standard lot (100,000 units), EUR/USD at 1.1000:

  pip value = (0.0001 / price) x position size
            = (0.0001 / 1.1000) x 100,000
            = 9.09 USD per pip

JPY pairs: one pip is the second decimal. USD/JPY at 150.00:

  (0.01 / 150.00) x 100,000 = 6.67 USD per pip
```

**2. Reading the pairs.** The **majors** — EUR/USD, USD/JPY, GBP/USD, USD/CHF —
are the most liquid with the tightest spreads; the commodity currencies
(AUD/USD, NZD/USD, USD/CAD) move with their export prices; the **crosses**
(EUR/JPY, GBP/JPY, EUR/GBP) are dollar-free pairs that behave more erratically.
Every book here agrees: start on the majors.

**3. The macro drivers.** Exchange rates are relative prices, so they move on
anything that changes one currency against another: interest-rate
**differentials** (money flows toward yield), **carry** (borrow the low-yield
currency, buy the high-yield one, pocket the difference while it lasts), central
banks (policy rates, forward guidance, intervention), economic releases (CPI,
payrolls, GDP, PMI), and the **risk-on / risk-off** cycle in which the dollar
and yen act as funding currencies when risk appetite falls.

```text
daily swap/rollover (approximation):

  overnight interest (USD) = notional x (base rate - quote rate) / 365

Long the high-yield currency and short the low-yield one, you are paid;
reverse the pair and you pay. Broker swap rates embed a markup, and the
differential resets with every central-bank decision.
```

**4. Intermarket links (Laïdi).** Currencies do not move alone: a pair is a
*symptom* of the relationship between two economies. EUR/USD tends to track
yield **spreads** between European and US bonds; AUD, NZD, and CAD track
**commodity** prices; the dollar and yen track global **equity** risk appetite.
Laïdi's method: check what the other markets are saying before trading the pair.

**5. Technical approaches specific to forex.** Because forex is 24-hour and
highly liquid, technicals on the H1–D1 timeframes are the default tool:
**support/resistance** levels and session extremes, **moving-average** trends,
breakouts. Ponsi's organising idea — is the market **trending** or
**range-bound**, and which strategy fits? — is the chapter's most reusable
lesson. Lien adds the event-driven layer: scheduled data drives many of the
biggest short-term moves, so a news calendar is a trading tool.

**6. Sentiment as a signal (Saettele).** Retail positioning is crowded and
reactive, so **positioning extremes** are contrarian signals. Saettele reads the
CFTC's weekly **Commitment of Traders (COT)** report and looks for extremes in
net speculative positioning at the same time price hits support or resistance.
The discipline: an extreme is a *warning* of a turn, confirmed only by price.

**7. The risk law the whole chapter is built around.** Leverage cuts both ways:

```text
position value = units x price     margin = position value / leverage

Example: 1.0 standard lot EUR/USD is ~$110,000 notional; at 50:1 the margin
is ~$2,200. A 1% adverse move costs ~$1,100 of equity. At high leverage a
few percent against you is a margin call.

risk-based size:
  risk per trade (USD)  = account equity x risk % per trade
  position size (units) = risk per trade / (stop distance in pips x pip value)

Example: $10,000 account, 1% risk, 20-pip stop, pip value 9.09 USD:
  risk  = 10,000 x 0.01     = $100
  units = 100 / (20 x 9.09) = 55,000 units  (~0.55 standard lots)
```

## Book-by-book annotations

### Reading ladder: On-ramp

#### Forex for Beginners — Anna Coulling (2012, ★ 4.0)

The genuine start-from-zero primer: what a currency pair is, what actually moves
exchange rates, simple chart reading, and a beginner's trading plan and
psychology.

- **Read it for:** the absolute-basics vocabulary; price drivers; first charts;
  the beginner's plan and the traps to avoid.
- **Model refresh:** Edition here appears current; your AI companion can still
  expand these notes from its training data.

#### Currency Trading For Dummies — Kathleen Brooks & Brian Dolan (2011, ★ 4.1)

The full Dummies on-ramp by two institutional veterans (Brooks of DailyFX, Dolan
a former FXCM chief currency strategist): what forex is, account and platform
setup, the first trade, and the risk chapters.

- **Read it for:** definitions from zero; the setup walkthrough; the first
  trade; margin, leverage, and risk management.
- **Model refresh:** A later edition may exist — ask your AI study companion to
  check its training data for any edition newer than 2011.

#### The Sensible Guide to Forex — Cliff Wachtel (2012, ★ 3.8)

The risk-first on-ramp. Wachtel asks not "how do I get rich in forex" but
"should *I* trade forex at all, and at what size?" — low leverage, small
positions, and forex as a complement to other assets.

- **Read it for:** who should and should not trade FX; low-leverage sizing; the
  "sensible" mindset; forex in a broader portfolio.
- **Model refresh:** Edition here appears current; your AI companion can still
  expand these notes from its training data.

### Reading ladder: Mechanics

#### Essentials of Foreign Exchange Trading — James Chen (2009, ★ 4.1)

The mechanics textbook of this chapter: pairs, pips, lots, margin, leverage,
rollover, platforms, and the technical-analysis basics — a reference to keep
beside the desk.

- **Read it for:** the complete trading vocabulary; margin and leverage
  mechanics; order types and platforms; the technical primer.
- **Model refresh:** Edition here appears current; your AI companion can still
  expand these notes from its training data.

#### The 10 Essentials of Forex Trading — Jared F. Martinez (2007, ★ 3.9)

A trading coach's ten-point discipline checklist: trading plan, risk rules,
trade management, and psychology — the non-chart causes of most retail losses.

- **Read it for:** the ten-point checklist; the pre-trade routine;
  money-management rules; trading psychology.
- **Model refresh:** Edition here appears current; your AI companion can still
  expand these notes from its training data.

#### Inside the Currency Market — Jeff Ready (2011, ★ 4.0)

The market-structure guide: who the participants actually are (interbank desks,
funds, corporates, brokers, retail), how quotes and liquidity really work, and
where a retail order sits in the plumbing.

- **Read it for:** the institutional view; order flow and liquidity; realistic
  execution; the gap between bank and retail dealing.
- **Model refresh:** Edition here appears current; your AI companion can still
  expand these notes from its training data.

### Reading ladder: Strategy

#### Forex Patterns and Probabilities — Ed Ponsi (2007, ★ 4.1)

Ponsi's organising idea — classify the market as **trending** or **range-bound**
first, then apply the matching toolkit of moving averages, support/resistance,
Fibonacci, and candlesticks — is the chapter's most reusable lesson.

- **Read it for:** the trending vs range-bound method; moving-average trends;
  Fibonacci and candlestick confirmation; stops, targets, and probabilities.
- **Model refresh:** Edition here appears current; your AI companion can still
  expand these notes from its training data.

#### Attacking Currency Trends — Steve VanMetre (2011, ★ 4.6)

The highest-rated book here and the pure trend-follower's text: mechanical
trend trading with momentum, moving averages, patient entries, and exits that
let winners run.

- **Read it for:** the trend-trading rule set; breakout and momentum entries;
  trailing and trade management; the patience of holding a trend.
- **Model refresh:** Edition here appears current; your AI companion can still
  expand these notes from its training data.

#### Day Trading the Currency Market — Kathy Lien (2005, ★ 3.8)

The first of Lien's three books here: currency day trading built around
scheduled economic news and central-bank events — the calendar as a trading
tool.

- **Read it for:** the news/event trading framework; the economic calendar;
  day-trading mechanics; the leverage discipline day trading demands.
- **Model refresh:** Edition here appears current; your AI companion can still
  expand these notes from its training data.

#### Day Trading and Swing Trading the Currency Market — Kathy Lien (2008, ★ 4.0)

Lien's expanded second edition: keeps the news-driven day trading and adds
swing trading on longer timeframes plus deeper fundamentals — written through
the 2008 crisis, so the risk chapters carry real weight.

- **Read it for:** the day + swing two-timeframe structure; event trading; swing
  setups and exits; the crisis-seasoned risk picture.
- **Model refresh:** Edition here appears current; your AI companion can still
  expand these notes from its training data.

#### The Little Book of Currency Trading — Kathy Lien (2010, ★ 3.8)

The pocket version of Lien's approach: why currencies, how to trade them, and
the dangers — leverage front and centre.

- **Read it for:** the quick overview; the leverage warning; a simple starting
  framework; the bridge into Lien's longer books.
- **Model refresh:** Edition here appears current; your AI companion can still
  expand these notes from its training data.

### Reading ladder: Deeper

#### Currency Trading and Intermarket Analysis — Ashraf Laïdi (2008, ★ 4.0)

The intermarket book: currencies as the output of bonds, equities, and
commodities — EUR/USD vs yield spreads, the commodity currencies vs their
exports, the dollar vs global risk appetite.

- **Read it for:** cross-asset correlation maps; yield spreads as EUR/USD
  drivers; commodity-linked pairs; the intermarket pre-trade checklist.
- **Model refresh:** Edition here appears current; your AI companion can still
  expand these notes from its training data.

#### Currency Strategy — Callum Henderson (2002, ★ —)

The institutional strategist's book, unrated in the collection. Henderson shows
how banks actually form currency views: forecast frameworks, flows, and policy
analysis — the discipline of a written strategy rather than a tip.

- **Read it for:** the institutional forecasting process; fundamentals and
  flows; the discipline of a written view; the professional mindset.
- **Model refresh:** Edition here appears current; your AI companion can still
  expand these notes from its training data — ask it to bring the carry-trade
  and quantitative-easing era up to date, as the book predates 2008.

#### Sentiment in the Forex Market — Jamie Saettele (2008, ★ 4.0)

The contrarian book: Saettele (an Elliott-wave analyst) reads the CFTC's weekly
COT report for extremes in speculative positioning and treats crowded retail
positioning at key price levels as a *warning* of a turn.

- **Read it for:** reading the COT report; positioning extremes as contrarian
  signals; sentiment confirmed by price; crowd behavior.
- **Model refresh:** Edition here appears current; your AI companion can still
  expand these notes from its training data.

### Reading ladder: Read critically

#### Forex Trading Secrets — James Dicks (2010, ★ 3.3)

⚠️ **Low-value per source README.** A "secrets" framing of day-trading
shortcuts — the retail-pitch genre, read to learn the pattern, not for an edge.

- **Read it for:** recognising marketing language; what "secrets" titles promise
  versus deliver; the cautionary reading exercise.
- **Model refresh:** Edition here appears current; your AI companion can still
  expand these notes from its training data.

#### How to Make a Living Trading Foreign Exchange — Courtney D. Smith (2010, ★ 3.6)

⚠️ **Low-value per source README.** A real professional's methodology wrapped in
a "make a living" over-promise — read as a caution about trading income, not as
a plan.

- **Read it for:** realistic income expectations; the costs of full-time
  trading; the methodology read skeptically.
- **Model refresh:** Edition here appears current; your AI companion can still
  expand these notes from its training data.

#### 17 Proven Currency Trading Strategies — Mario Singh (2013, ★ 2.4)

⚠️ **Poorly rated, retail-trap flagged.** A catalogue of canned strategies
organised by market condition, carrying the collection's worst rating — and
"proven" is marketing, not a claim any book can back.

- **Read it for:** the strategy-type menu; the lesson in what "proven" really
  means; the retail-trap warning in action.
- **Model refresh:** Edition here appears current; your AI companion can still
  expand these notes from its training data.

#### Forex Trading Basics & Secrets — — (n.d., ★ —)

⚠️ **Low-value per source README.** The author and publication date are
unverified in the collection, and the title's "secrets" framing is the retail
pitch pattern again — included as a warning label, not a recommendation.

- **Read it for:** the warning; recognising unverifiable sourcing; the
  discipline of skipping unattributable books.
- **Model refresh:** Edition here appears current; your AI companion can still
  expand these notes from its training data. The author is listed as "—" in the
  catalog — your companion may identify the book from training data, but do not
  trust unverified authorship.

## Reading order

1. **Forex for Beginners** (Coulling) — start from zero.
2. **Currency Trading For Dummies** (Brooks & Dolan) — the fuller on-ramp.
3. **The Sensible Guide to Forex** (Wachtel) — the risk mindset, before you size
   anything.
4. **Essentials of Foreign Exchange Trading** (Chen) — lock down pips, lots,
   margin, leverage.
5. **The 10 Essentials of Forex Trading** (Martinez) — the discipline checklist.
6. **Forex Patterns and Probabilities** (Ponsi) — the technical core.
7. **Attacking Currency Trends** (VanMetre) — the highest-rated trend approach.
8. **Day Trading and Swing Trading the Currency Market** (Lien) — news/event
   trading; its 2005 ancestor *Day Trading the Currency Market* is shorter, and
   *The Little Book of Currency Trading* is the pocket summary.
9. **Inside the Currency Market** (Ready) — optional structural depth.
10. **Currency Trading and Intermarket Analysis** (Laïdi) then **Sentiment in
    the Forex Market** (Saettele) — the intermarket and contrarian layers.
11. **Currency Strategy** (Henderson) — the institutional lens (optional).
12. **The four ⚠️ books — read critically, or skip.** They are catalogued to
    teach what to avoid.

## Self-test questions

1. Define a pip. What is the pip value in USD of one standard lot of EUR/USD
   when the rate is 1.1000?
2. In the quote `GBP/USD = 1.27`, which currency is the base and which the quote
   — and what does the number mean?
3. Explain the carry trade: which side gets *paid* overnight when the base
   currency yields more than the quote currency, and what risk does the trade
   hide?
4. Name three central-bank actions that move exchange rates and the usual
   direction of the effect.
5. List three intermarket relationships from Laïdi and the pair each one is most
   often linked to.
6. Using Saettele's framework, when does COT positioning data become a
   contrarian signal — and what must confirm it?
7. On a $10,000 account at 50:1 leverage, what notional position can you
   control, and why would a sensible trader risk far less?
8. Why does the catalog flag *17 Proven Currency Trading Strategies* and the
   "secrets"/"make a living" titles as warnings rather than endorsements?

## Cross-links

**Next:** [Chapter 15 · Binary Options — Read the Warning](15-binary-options.md) ·
**Back:** [Chapter 13 · Day Trading & Swing Trading](13-day-swing.md)
