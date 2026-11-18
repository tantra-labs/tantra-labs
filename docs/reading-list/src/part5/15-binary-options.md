# 15 · Binary Options — Read the Warning

> Part V · Chapter 15 · Books: 2 · Topic level: instrument ▸ micro · ⚠️ Warning chapter

## What this topic is about

This is the shortest chapter in the book, and the only one that is a warning
first and a study topic second. The two titles catalogued here exist in the
collection to teach one transferable skill: **how to recognise a structurally
unfavourable instrument before you trade it.** Everything else in this library
teaches you to find an edge; this chapter teaches you to spot a product that has
no edge for you by construction.

A binary option is an all-or-nothing bet on a single yes/no question at a fixed
expiry: will this asset be *above* or *below* this level at that exact moment?
If your guess is right you receive a fixed payout; if it is wrong you lose your
entire premium. There is no partial outcome, no stop-loss, no exit between the
two extremes — which is why the instruments are called *binary*. The classic
form is a broker-hosted bet on a short time frame (minutes to hours), and the
short expiry is itself a design feature: the faster the bet, the more often the
house collects its edge.

The chapter sits at the micro end of the instrument ladder, after the currency
mechanics of [Chapter 14](14-forex.md). It belongs in the reading path precisely
because binary options are the cleanest, most legible example in finance of a
bad deal: the payout structure is unfavourable on paper, the platform takes the
other side of your trade, and regulators have concluded that retail investors
cannot be protected inside the product — only from it. Study it once, carefully,
and you will recognise the same anatomy hiding inside more respectable products
for the rest of your career.

## The books on this topic

| Title | Author | Year | Rating | Role |
|---|---|---|---|---|
| Trading Binary Options | Abe Cofnas | 2016 (2nd ed.) | ★ 3.0 | The case study |
| Top Binary Options Trading Strategies | — (not verified) | n.d. | ★ — | The warning exhibit |

## Study synthesis — what the books jointly teach

**1. A binary option is a coin flip with a payout below fair value.**
You stake a fixed premium on whether an asset is above or below a level at
expiry. If the underlying moves randomly — as all short-horizon moves
approximately do — your chance of being right is close to 50%. But the payout on
a win is less than 1:1. That single mismatch is the whole story:

```text
Assumptions: 50% win probability, typical broker payout of 70–90%

Expectancy per unit staked, at an 80% payout:
  E = p(win) × payout − p(loss) × stake
    = 0.50 × (+0.80) + 0.50 × (−1.00)
    = +0.40 − 0.50
    = −0.10     ← you lose ₹0.10 per ₹1 staked, on average

At 70% payout:  E = 0.35 − 0.50 = −0.15
At 90% payout:  E = 0.45 − 0.50 = −0.05

Break-even win rate needed at an 80% payout:
  1 / (1 + payout) = 1 / 1.80 ≈ 55.6%
```

Every payout in the realistic range leaves the buyer with negative expectancy.
You would need to win more than 55% of bets at an 80% payout just to break even
— and the short, random time frames make a sustained 55% win rate a fantasy.

**2. The broker is on the other side of your trade.**
In the retail-broker binary model the platform is not an exchange connecting two
independent parties: it is your counterparty, and it earns its revenue when you
lose. The house sets the payout below the fair 1:1 value, takes the opposite
side of the position, and profits from the difference. Nothing in the product
structure aligns the broker's interest with yours — the opposite of an exchange
or a regulated market-maker, whose income is a visible fee and whose obligation
is to give you the best available price.

**3. Regulators have banned it for retail — that is the expert verdict.**
The regulatory record is the strongest external evidence that this product
cannot be fixed for the retail buyer: the European Union's ESMA imposed a
permanent ban on selling binary options to retail clients (2019); the UK's FCA
followed with its own retail ban; Australia's ASIC banned them outright in 2021;
Israel, where much of the industry was built, banned them in 2016; in the US
retail trading survives only on regulated exchanges such as Nadex under
CFTC oversight. In India, NSE/BSE list no binary option — the retail investor who
encounters one meets an unregulated offshore website, and the product is
effectively unavailable on SEBI-regulated exchanges. When every major regulator
concludes the product is the problem, the sane conclusion is to not trade it.

**4. Why the collection includes these books at all.**
The source library's note is explicit: *reading these is fine; trading binary
options is generally not recommended.* The two titles are included as a **case
study in identifying a bad instrument** — the diagnostic checklist you build here
transfers directly to legitimate markets. Does the product cap your upside below
the fair value of your chance? Is your win probability near 50% but the payout
below 1:1? Is the person selling you the trade also taking the other side? Do
regulators ban it for retail? If every answer points the wrong way, the product
is not a trade — it is a tax.

## Book-by-book annotations

### Trading Binary Options — Abe Cofnas (2016, ★ 3.0)

The only author-authored book in the pair, this is the mechanics-and-strategy
treatment: how the instrument quotes, expiries, and payout tables work, plus
strategy schemes built on technical analysis. Read it as *the case study*, not
as a recommendation — it explains the product competently, which is exactly what
you need in order to see clearly why the payout math cannot be overcome.

- **Read it for:** the product mechanics (how quotes, strikes, and expiries
  work); the payout tables that make the negative expectancy visible; the
  technical strategies framed as ways to lift the win rate toward the
  break-even threshold; a concrete feel for how the broker operates the market.
- **Model refresh:** edition here appears current; your AI companion can still
  expand these notes from its training data.

### Top Binary Options Trading Strategies — author — (n.d., ★ —)

The anonymous, undated strategy booklet — the kind of free "make money trading
binary options" PDF that populates affiliate websites. It is flagged in the
source README as a retail trap and is catalogued as **the warning exhibit**: a
specimen of how a bad instrument is marketed. It has no verifiable author or
publication date, and that absence is itself the lesson — legitimate literature
tells you who wrote it and when.

- **Read it for:** the marketing anatomy of a retail trap (win-rate claims, no
  payout disclosures, no expectancy math); practice at applying the diagnostic
  checklist from this chapter to a sales pitch; the concrete example of a title
  whose existence in a library is a red flag, not a study asset.
- **Model refresh:** edition here appears current; your AI companion can still
  expand these notes from its training data. The author and publication date
  were not verifiable from the collection and are left as "—".

## Reading order

1. **Trading Binary Options** — the mechanics case study (read it once, for
   understanding).
2. **Top Binary Options Trading Strategies** — the warning exhibit (skim it as a
   red-flag exercise — spotting the marketing is the point, not learning the
   strategies).

## Self-test questions

1. Define a binary option in one sentence. What does "all-or-nothing" mean for
   your risk and your payout?
2. Using an 80% payout, show the expectancy calculation and state what it means
   in plain words.
3. What win rate is required to break even at a 70% payout? At 90%?
4. In the retail binary model, who is on the other side of your trade, and why
   does that matter?
5. Name three regulators that have banned or heavily restricted binary options
   for retail investors.
6. Why does the collection include two binary-options books if trading the
   product is not recommended? What skill is the chapter really teaching?
7. What four-question diagnostic checklist would you apply to any new
   instrument before trading it?

## Cross-links

**Next:** [Chapter 16 · Professional Price Action](../part6/16-advanced-price-action.md) ·
**Back:** [Chapter 14 · Forex: Currencies as an Asset Class](14-forex.md)
