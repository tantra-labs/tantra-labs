# M2 — Candlestick Analysis

> **Weeks 19–21 · 24 hrs · PLO-3 · Core reading:** Nison, *Candlestick Charting Techniques*, ch. 1–9

## Learning outcomes

- Construct a candlestick from OHLC data.
- Recognize single-, double-, and multi-bar reversal patterns.
- Distinguish reversal from continuation patterns; know when context matters.
- Use candlesticks with trend context and volume.
- Classify every bar of a series mechanically (body/wick rules) in `Decimal`.

## Prerequisites

- [M1 — Dow Theory & Trends](m1-dow-theory.md): bar anatomy (body, wicks,
  range), support/resistance zones, and the three-trend idea. Candles are a
  *zoomed-in* view of the same tape.
- `Decimal` arithmetic for body/wick comparisons; `abs()`, `max()`, `min()`.
- The `tantra` wheel with `tantra_examples.synthetic_bars` (used in the lab).

## Lesson 2.1 — Candlestick construction

### 1) Concept

A candlestick is a one-bar story. It needs four prices: open, high, low, close.
The rectangle between open and close is the **body**; the thin lines above and
below are the **shadows** (or wicks). A bullish bar (`close > open`) is drawn
hollow or green; a bearish bar (`close < open`) is drawn filled or red. The
three numbers that describe any candle are its body size, its upper shadow, and
its lower shadow:

```
body         = |close − open|
upper shadow = high − max(open, close)
lower shadow = min(open, close) − low
range        = high − low = body + upper + lower
```

### 2) Worked example

A TCS session: open 3,400, high 3,450, low 3,380, close 3,430.

```python
from decimal import Decimal
o, h, l, c = Decimal("3400"), Decimal("3450"), Decimal("3380"), Decimal("3430")
body = abs(c - o)
upper = h - max(o, c)
lower = min(o, c) - l
print("body:", body, "upper:", upper, "lower:", lower, "range:", h - l)
# body: 30  upper: 20  lower: 20  range: 70
```

`close > open`, so the candle is bullish: buyers pushed price 30 points from the
open and defended the top; sellers pushed 20 points down from the close but
could not hold it.

### 3) Common pitfalls

> **Pitfall:** computing the upper shadow as `high − close`. Use the *higher of
> open and close* — a gap-down bar (open above close) has a different shadow
> structure.
> **Pitfall:** forgetting that `range = body + both shadows`. If they do not
> add up, you have mis-measured one of them.
> **Pitfall:** calling every green bar "bullish". A green bar at the top of a
> long rally may be the last gasp — colour is a *report*, context is the
> *verdict*.

### 4) Key takeaways

- **Takeaway:** four prices, three measurements (body, upper, lower).
- **Takeaway:** the body is the fight; the shadows are the rejected extremes.
- **Takeaway:** measurement must be exact — the lab's classifier depends on it.

## Lesson 2.2 — Single-bar patterns

### 1) Concept

Single candles get names only when their proportions are extreme:

- **Doji** — `open ≈ close`, body tiny or zero. The market opened and closed at
  the same price: indecision. At the end of a strong move it warns of
  exhaustion; in a range it means nothing.
- **Hammer** — small body near the top, long lower shadow (≥ 2× the body). In a
  *downtrend* it says sellers drove price down but buyers dragged it back:
  potential bottom. The identical shape at the top of an *uptrend* is called a
  **hanging man** and warns of a top.
- **Shooting star** — small body near the bottom, long upper shadow. In an
  *uptrend* it says buyers failed to hold the highs: potential top. The mirror
  shape in a downtrend is the **inverted hammer**, a potential bottom.

The lesson behind the naming: **the pattern's meaning depends on where it
appears**. Hammer vs hanging man are the *same candle* in different contexts.

### 2) Worked example

Rule used by the lab: a lower shadow counts as "long" when it is at least twice
the body, and the upper shadow is then short (≤ half the body).

```python
from decimal import Decimal

def single_bar(b):
    body = abs(b.close - b.open)
    upper = b.high - max(b.open, b.close)
    lower = min(b.open, b.close) - b.low
    if body == Decimal(0): return "doji"
    if lower >= 2 * body and upper <= body // 2:
        return "hammer" if b.close > b.open else "hanging_man"
    if upper >= 2 * body and lower <= body // 2:
        return "shooting_star" if b.close < b.open else "inverted_hammer"
    return "bullish" if b.close > b.open else "bearish"
```

A bar with open 100, high 102, low 98, close 100.5 has body 0.5, lower shadow
`min(100, 100.5) − 98 = 2.0` (4× the body) and upper shadow 1.5 — a hammer in a
downtrend, a hanging man at a top.

### 3) Common pitfalls

> **Pitfall:** trading a hammer without a downtrend. The shape is a hammer
> *because* it ended a decline.
> **Pitfall:** requiring exactly 2× for the shadow. The 2× ratio is a lab
> convention, not a law — use it to be mechanical, not to be right.
> **Pitfall:** treating a doji as a signal by itself. A doji in the middle of a
> range is wallpaper.

### 4) Key takeaways

- **Takeaway:** single-bar patterns are *extremes of proportion*, not magic.
- **Takeaway:** the same shape has two names — the trend decides which.
- **Takeaway:** context (trend + location) converts shape into signal.

## Lesson 2.3 — Two-bar and multi-bar patterns

### 1) Concept

Pairs and triples tell a story across sessions:

- **Bullish engulfing** — a small bearish bar is swallowed whole by a large
  bullish bar. Sellers controlled day 1, buyers wiped out their entire range on
  day 2: a one-session shift of control. **Bearish engulfing** is the mirror at
  a top.
- **Harami** — the second bar's body fits entirely inside the first bar's body
  ("pregnant"); a pause. The second bar is often a doji — a *harami cross*.
- **Piercing line** — a bearish bar, then a gap-down open that closes back above
  the midpoint of the first bar's body. **Dark cloud cover** is its bearish twin
  (close back *below* the first bar's midpoint).
- **Morning star** — three bars: long bearish, small/doji gap-down, long bullish
  closing above the midpoint of bar one. **Evening star** is the mirror at a
  top.
- **Continuation patterns** — rising/falling three methods: a trend bar, then
  small counter-trend bars *inside* its range, then a fresh trend bar. These
  say "pause, then continue", not "reverse".

### 2) Worked example

Bullish engulfing check: bar 2 must be bullish, bar 1 bearish, and bar 2 must
cover bar 1's *entire* range.

```python
from decimal import Decimal
b1, b2 = (Decimal("100"), Decimal("96")), (Decimal("95"), Decimal("101"))  # (open, close)
bull_engulfing = (b2[1] > b2[0] and b1[1] < b1[0]
                  and b2[0] < b1[1] and b2[1] > b1[0])
print("bullish engulfing:", bull_engulfing)   # True
```

Bar 1 range is 96–100; bar 2 covers 95–101: the buyer's bar swallowed the
seller's bar completely.

### 3) Common pitfalls

> **Pitfall:** comparing *bodies* instead of *ranges* for engulfing — an
> engulfing must swallow the whole prior bar, wicks included.
> **Pitfall:** demanding the morning star's third bar close above the first
> bar's *high*. Nison's rule is the *midpoint of the first body*.
> **Pitfall:** classifying a three-methods bar as a reversal. Rising three
> methods is a *continuation*: the pause happens inside the prior bar's range.

### 4) Key takeaways

- **Takeaway:** two-bar patterns are a *one-session shift of control*.
- **Takeaway:** stars and engulfing need trend context to mean reversal.
- **Takeaway:** three methods are the classic continuation counter-example.

## Lesson 2.4 — The "magic doji" & context rules

### 1) Concept

A doji after a strong trend is the market's "I don't know" moment: the same
crowd that pushed price is suddenly unwilling to push further. That is why dojis
near extremes are watched — but Nison's rule is the discipline of the whole
candle system: **candles signal *where*, other tools confirm *when***. A doji at
resistance with a falling RSI and high volume is a candidate top; a doji in the
middle of nowhere is noise. Never combine candles with only themselves — always
ask: trend context, volume, nearby support/resistance.

### 2) Worked example

A confirmation rule: a doji at a resistance zone is only a *watch* until the
next bar closes below the doji's low (bearish confirmation).

```python
from decimal import Decimal
doji_low = Decimal("24050")
next_close = Decimal("24010")
confirm = next_close < doji_low
print("doji downside confirmed:", confirm)   # True
```

The doji froze the market at 24,050–24,070; the follow-through close below
24,050 is what turns a watch into a short-setup.

### 3) Common pitfalls

> **Pitfall:** treating a doji as a standalone buy/sell. It is a *watch*, not an
> entry.
> **Pitfall:** ignoring volume. A doji on shrinking volume is a quiet pause; a
> doji on huge volume at a top is a climax — very different trades.
> **Pitfall:** looking for confirmation beyond the zone. The doji must sit at
> price where a reversal *matters*.

### 4) Key takeaways

- **Takeaway:** doji = indecision; its power comes from *where* it appears.
- **Takeaway:** candles say where; trend/volume/S-R say when.
- **Takeaway:** always wait for the confirming follow-through bar.

## Lesson 2.5 — Japanese charts beyond candles

### 1) Concept

The Japanese school invented more than candlesticks: **renko** (draws bricks of
a fixed size; time is invisible), **kagi** (lines that flip direction on
reversals of a fixed amount), and **three-line break** (columns that break the
last three rows). All three *filter noise* by removing time — you see only
price moves that matter. They are required material for CFTe II and studied in
detail in S5-TA; for now, remember the family exists and why: to see structure
when time-based charts are too noisy.

### 2) Worked example

A renko brick of size 50: starting at 24,000, price must reach 24,050 to draw
the next brick; if it drops to 23,950 it draws a down-brick. A small helper that
tracks the running level:

```python
from decimal import Decimal
def renko_next(level: Decimal, price: Decimal, brick: Decimal) -> Decimal | None:
    """Return the new level if a brick closed, else None."""
    if price >= level + brick: return level + brick
    if price <= level - brick: return level - brick
    return None

level = Decimal("24000")
print(renko_next(level, Decimal("24040"), Decimal("50")))   # None (not yet)
print(renko_next(level, Decimal("24060"), Decimal("50")))   # 24050 (brick)
```

### 3) Common pitfalls

> **Pitfall:** assuming renko shows *when* moves happen — it deliberately
> erases time.
> **Pitfall:** mixing brick sizes across charts when comparing two instruments.
> **Pitfall:** thinking kagi/three-line-break add new information — they are
> *filters* of the same OHLC data.

### 4) Key takeaways

- **Takeaway:** renko/kagi/three-line-break are time-free filters.
- **Takeaway:** they zoom the eye out from daily noise to move structure.
- **Takeaway:** CFTe II material — preview only, S5-TA has the depth.

## Tantra Lab 2 — Classify every bar of a series

### Lab goal

Write a mechanical single-bar classifier, run it over real synthetic bars, and
prove that "pattern names" are just extreme proportions of the body/wick
measurements.

### Code

```python
from decimal import Decimal
from tantra_examples import SampleInstruments, synthetic_bars

bars = synthetic_bars(SampleInstruments.NIFTY50, days=120, seed=7, base_price_paise=24_000)

def body(b): return b.close - b.open
def upper_wick(b): return b.high - max(b.open, b.close)
def lower_wick(b): return min(b.open, b.close) - b.low

def classify(b):
    if body(b) == Decimal(0): return "doji"
    if upper_wick(b) >= 2 * abs(body(b)) and lower_wick(b) <= abs(body(b)) // 2:
        return "shooting_star" if body(b) < 0 else "inverted_hammer"
    if lower_wick(b) >= 2 * abs(body(b)) and upper_wick(b) <= abs(body(b)) // 2:
        return "hammer" if body(b) > 0 else "hanging_man"
    return "bullish" if body(b) > 0 else "bearish"

for b in bars[:10]:
    print(b.ts.date(), classify(b))
```

### Expected output

Ten lines, one per bar, each a date followed by one of `doji`, `hammer`,
`hanging_man`, `shooting_star`, `inverted_hammer`, `bullish`, `bearish`. Most
bars will be plain `bullish`/`bearish`; the extreme-shape names appear only when
a shadow is ≥ 2× the body — that rarity is the point.

### Hand-in checklist

- [ ] The 10-bar classification output pasted into the journal.
- [ ] The extended **two-bar engulfing** detector (compare `body[i]` vs
      `body[i-1]` with opposite signs and bar-2 range covering bar-1 range).
- [ ] The **100-pattern timed drill** score and time recorded.
- [ ] 10 annotated chart screenshots, each with a one-line *context* note
      (where in the trend, volume, nearby S/R) — not just the name.
- [ ] A one-paragraph answer: why does `classify()` return `doji` more often
      than `hammer` on a synthetic NIFTY series?

### Common errors

- **Dividing Decimals by ints wrongly** — `body(b) // 2` is fine in `Decimal`;
  do not cast to `float` to "make it work".
- **Missing the `Decimal(0)` doji branch** — without it, a zero-body bar falls
  through to `bullish`/`bearish` by sign and is mislabelled.
- **Forgetting that the same shape flips names** — `hammer` vs `hanging_man` is
  decided by `body(b) > 0`, not by the chart's colours.

## Practice problems

1. A bar has open 500, high 512, low 494, close 506. Compute body, upper and
   lower shadows. Which single-bar name does the lab rule give it?
2. Explain, in one paragraph each, why the *same candle* is a hammer at a bottom
   and a hanging man at a top.
3. Bar 1: O 100, H 105, L 98, C 99 (bearish). Bar 2: O 98, H 107, L 97, C 106
   (bullish). Is bar 2 a bullish engulfing bar of bar 1? Show the range math.
4. A doji forms at a resistance level at 24,000 with high volume. What one
   confirmation do you need before acting, and why?
5. Distinguish a morning star from a rising-three-methods pattern. Which is a
   reversal and which a continuation?
6. In `Decimal`, classify a bar with open 250, high 255, low 249, close 250.5
   using the lab rule. What name does it get?
7. Renko brick size 50, current level 24,000. Price prints 24,035 then 24,060.
   How many bricks draw? Show the level transitions.
8. Why is a doji in the middle of a range "wallpaper"? Connect your answer to
   Nison's *where* vs *when* rule.

### Solutions

1. body `= |506−500| = 6`; upper `= 512 − 506 = 6`; lower `= 500 − 494 = 6`.
   No shadow is ≥ 2× the body, so the rule returns `bullish` (close > open).
2. The shape is identical; the *trend it ends* differs. After a decline, the
   long lower shadow shows buyers absorbing the final sell-off (hammer); after a
   rally, the same shape means buyers failed to hold price up (hanging man).
3. Bar 1 range 98–105; bar 2 range 97–107 with close 106 > open 98, and
   `97 < 98` and `106 > 105` — bar 2 covers bar 1's whole range: yes, bullish
   engulfing.
4. A close below the doji's low on the next bar. A doji alone is a watch; the
   follow-through proves the indecision resolved downward.
5. Morning star: three bars ending with a strong bullish close above the first
   body's midpoint — a reversal. Rising three methods: trend bar, small inside
   bars, fresh trend bar — a continuation.
6. body `= 0.5`; lower `= min(250, 250.5) − 249 = 1.0` (2× body); upper
   `= 255 − 250.5 = 4.5` (> half body, so the hammer branch's upper test
   `upper ≤ body // 2` = 0.25 fails) → returns `bullish`.
7. One brick. At 24,035 no brick (`< 24,050`); at 24,060 level advances to
   24,050 — one up-brick.
8. A doji only matters at a place where a reversal *would mean something* —
   trend extremes, S/R, exhaustion zones. In a range it just confirms the range
   continues; candles signal where, other tools confirm when.

## Quiz bank

| Question | A | B | C | D | Answer |
|---|---|---|---|---|---|
| The body of a candle equals | high − low | \|close − open\| | high − close | close − low | B |
| A hammer's meaning depends on | Its colour | The trend it appears in | Its volume | The time of day | B |
| A doji signals | Certain reversal | Indecision | Continuation | Distribution | B |
| Bullish engulfing requires bar 2 to | Gap up | Cover bar 1's whole range | Have equal bodies | Be a doji | B |
| The mirror image of a hammer at a top is | Shooting star | Hanging man | Harami | Doji | B |
| Morning star is a | 2-bar continuation | 3-bar reversal | 1-bar doji | 4-bar gap | B |
| Rising three methods is a | Reversal pattern | Continuation pattern | Doji family | Gap pattern | B |
| Renko charts draw bricks based on | Time | Price change | Volume | Open interest | B |
| Nison's rule says candles signal | When | Where | Volume | News | B |

## Glossary

- **Body** — the rectangle between open and close; the day's core fight.
- **Shadow (wick)** — the line from body to high/low; rejected price.
- **Doji** — a candle with open ≈ close; indecision.
- **Hammer** — small body, long lower shadow, found at bottoms.
- **Hanging man** — the same shape at tops; a warning.
- **Shooting star** — small body, long upper shadow at a top.
- **Inverted hammer** — the mirror shape at a bottom.
- **Engulfing** — a bar whose range fully covers the prior bar's range.
- **Harami** — a small bar whose body sits fully inside the prior body.
- **Morning/evening star** — three-bar reversals with a star in the middle.
- **Rising/falling three methods** — three-bar continuation patterns.
- **Renko/Kagi/Three-line-break** — time-free Japanese charts.

## Reading assignment

- Nison, *Candlestick Charting Techniques*, ch. 1–9 (this module's core).
- Nison, *Beyond Candlesticks* — for renko/kagi depth (CFTe II preview).
- IFTA *CFTe Syllabus & Study Guide*, Appendix A (candlestick terminology).
- Platform: reuse `tantra-examples/examples/02_indicators.py` as a data source
  for your pattern journal.
- Full list: [Reading & Resource List](../appendices/reading-list.md).

## Assessment reminder

This module feeds the **100-pattern timed recognition drill** (quiz component)
and the **pattern journal** — 10 patterns, each with chart + one-line reason —
which is graded as part of your journal. Both are described in
[Assessment](../front/assessment.md).

## Assessment

- 100-pattern timed recognition drill.
- Pattern journal (10 patterns × chart + reason).

**Next:** [M3 — Chart Patterns & Reversals](m3-chart-patterns.md)
