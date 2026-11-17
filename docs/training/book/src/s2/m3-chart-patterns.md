# M3 — Chart Patterns & Reversals

> **Weeks 21–23 · 24 hrs · PLO-3 · Core reading:** Edwards & Magee ch. 6–11; Murphy ch. 7

## Learning outcomes

- Recognize head & shoulders, double/triple tops & bottoms.
- Classify triangles, flags, pennants, wedges, and consolidation formations.
- Compute measured-move price targets for each pattern.
- State the invalidation level of every pattern you trade.
- Wire a pattern to a complete plan: entry, stop, target, risk-reward ratio.

## Prerequisites

- [M1 — Dow Theory & Trends](m1-dow-theory.md): swing highs/lows, trendlines,
  and support/resistance zones — patterns are made of those.
- [M2 — Candlesticks](m2-candlesticks.md): "confirmed close" and the idea that
  shape means nothing without context.
- `Decimal` subtraction and multiplication for target arithmetic.

## Lesson 3.1 — Reversal patterns

### 1) Concept

A **head & shoulders (H&S)** top has three peaks: a left shoulder, a higher head,
and a right shoulder roughly matching the left. The **neckline** joins the two
troughs between the peaks. The pattern completes only when price *closes below
the neckline*. The measured target projects the height of the head below the
neckline. An **inverted H&S** is the same pattern upside down at a bottom.

**Double tops** test a resistance level twice and fail; **double bottoms** test
support twice and hold. **Triple tops/bottoms** are the three-attempt versions.
In every case the rule is identical: pattern completion = **a confirmed close**,
never a mere touch of the line.

### 2) Worked example

H&S: left shoulder 24,200; head 24,500; neckline drawn at 23,000; right shoulder
24,150; breakout (confirmed close below neckline) at 22,800.

```
height = head − neckline = 24,500 − 23,000 = 1,500
target = breakout − height = 22,800 − 1,500 = 21,300
```

The lab function computes exactly this:

```python
from decimal import Decimal

def hs_target(neckline: Decimal, head: Decimal, breakout_price: Decimal) -> Decimal:
    """Downside target of a head & shoulders: project the head's height below the neckline."""
    height = head - neckline
    return breakout_price - height

neckline = Decimal("23000"); head = Decimal("24500"); breakout = Decimal("22800")
print("H&S target:", hs_target(neckline, head, breakout))   # 21300
```

The **stop** belongs above the right shoulder (e.g. 24,300): if price rallies
back above the right shoulder the pattern failed. Risk = `24,300 − 22,800 =
1,500`; reward = `22,800 − 21,300 = 1,500`; risk-reward ≈ 1 : 1 — too thin for
most traders, which is why measured targets are only the *first* objective.

### 3) Common pitfalls

> **Pitfall:** calling it H&S before the neckline break. The three peaks are a
> *candidate*; the close below the neckline is the *completion*.
> **Pitfall:** drawing the neckline from the wrong troughs — it must join the
> two reaction lows between the peaks.
> **Pitfall:** measuring the target from the *breakout bar's low* instead of the
> neckline height. The height is `head − neckline`, projected from the breakout.

### 4) Key takeaways

- **Takeaway:** reversal = structure + confirmed close beyond a trigger line.
- **Takeaway:** measured move = pattern height projected from the trigger.
- **Takeaway:** a pattern without an invalidation level is not a pattern, it is
  a hope.

## Lesson 3.2 — Triangles and consolidation

### 1) Concept

**Triangles** are converging ranges:

- **Symmetric triangle** — rising lows and falling highs meet; a spring that
  resolves *in either direction*. Trade the breakout, not the guess.
- **Ascending triangle** — flat resistance, rising lows. Supply is capped at one
  level while demand improves → bullish bias.
- **Descending triangle** — flat support, falling highs → bearish bias.

**Flags** and **pennants** are short consolidations *after* a sharp move (the
pole): a flag is a small parallel channel tilted against the pole; a pennant is
a tiny symmetric triangle. Both are **continuation** patterns — after the pause
the prior move resumes. **Wedges** are triangles that slant *with* the move: a
rising wedge usually breaks down (bearish), a falling wedge usually breaks up
(bullish).

### 2) Worked example

Classification helper for the daily bars of a synthetic series: an ascending
triangle requires a flat resistance (highs within a small band) and rising lows.

```python
from decimal import Decimal
res_hi, res_lo = Decimal("24500"), Decimal("24480")   # flat resistance band
lows = [Decimal("24100"), Decimal("24200"), Decimal("24300")]   # rising lows
flat_res = res_hi - res_lo <= Decimal("20")
rising_lows = all(lows[i] < lows[i + 1] for i in range(len(lows) - 1))
print("ascending triangle:", flat_res and rising_lows)   # True
```

### 3) Common pitfalls

> **Pitfall:** treating a symmetric triangle as directional. It is a coiled
> spring — wait for the breakout close.
> **Pitfall:** mistaking a wedge for a flag. Flags sit *against* the pole's
> slope and are short; wedges are longer and slant *with* it.
> **Pitfall:** demanding a minimum number of touches. Two touches per side is
> the absolute floor; three is materially stronger.

### 4) Key takeaways

- **Takeaway:** triangles compress price; the breakout direction is the trade.
- **Takeaway:** flat side + rising/falling other side = a bias (ascending/
  descending).
- **Takeaway:** flags/pennants continue the pole; wedges warn of a turn.

## Lesson 3.3 — Measurement objectives

### 1) Concept

Every pattern has a **measured move**: a numeric target computed from the
pattern's own geometry, not from guesswork.

- **Triangle:** measure the base (the widest vertical span) and project it from
  the breakout point in the breakout direction.
- **Flag/pennant:** the target is the length of the pole added to the breakout.
- **H&S:** neckline − (head − neckline) downward, or + the height upward for the
  inverted pattern.
- **Trading range:** a flat rectangle of support/resistance; breaking out of it
  projects the range's height from the break.

A target is an *objective*, not a promise: always pair it with an invalidation
stop.

### 2) Worked example

Ascending-triangle base: 24,000 (support) to 24,500 (resistance); height 500.
Breakout close 24,520 → target `24,520 + 500 = 25,020`. Flag: pole from 23,000
to 24,000 (length 1,000); consolidation, then breakout close 24,050 → target
`24,050 + 1,000 = 25,050`.

```python
from decimal import Decimal
def measured_move(breakout: Decimal, pattern_height: Decimal) -> Decimal:
    return breakout + pattern_height

print("triangle target:", measured_move(Decimal("24520"), Decimal("500")))    # 25020
print("flag target:", measured_move(Decimal("24050"), Decimal("1000")))       # 25050
```

### 3) Common pitfalls

> **Pitfall:** projecting the triangle height from the *widest* bar instead of
> the base. The base is the vertical span at the pattern's start.
> **Pitfall:** treating the target as a guaranteed fill — price often stalls or
> reverses before it. The target is where you *take profit*, not where price
> must go.
> **Pitfall:** forgetting the stop when "measuring". Target and stop are a pair
> — one without the other is a coin flip.

### 4) Key takeaways

- **Takeaway:** every pattern has an arithmetic target from its own geometry.
- **Takeaway:** measured move = pattern height/pole length projected from break.
- **Takeaway:** a target needs its twin: the invalidation stop.

## Lesson 3.4 — Volume confirmation

### 1) Concept

Volume is the jury that votes on the pattern. A breakout *with* volume expansion
is a breakout the crowd believes; a breakout on shrinking volume is a suspicion,
not a fact. Two rules from Edwards & Magee: (1) breakouts should show volume
expansion, especially downward breakouts from tops; (2) **failed breakouts** —
price knifes through the line and immediately closes back — fail more often on
low volume. Always check the volume bar at the trigger before you commit.

### 2) Worked example

Compare the volume of the breakout bar with the average of the prior 5 bars:

```python
from decimal import Decimal
breakout_volume = Decimal("1850000")
prior = [Decimal("1200000"), Decimal("1100000"), Decimal("1350000"), Decimal("1000000"), Decimal("1250000")]
avg = sum(prior) / Decimal(len(prior))
print("avg prior volume:", avg)                # 1180000.0
print("volume expansion:", breakout_volume > 1.5 * avg)   # True (1850000 > 1770000)
```

The 1.5× rule of thumb is a lab convention; the idea is that a real breakout is
*confirmed by a crowd*.

### 3) Common pitfalls

> **Pitfall:** ignoring volume entirely on the trigger bar — the most common
> beginner mistake in this module.
> **Pitfall:** using volume in *absolute* numbers across different instruments.
> Compare to the instrument's own recent average.
> **Pitfall:** forgetting that a failed breakout on high volume is *more*
> serious, not less — the crowd tried and lost.

### 4) Key takeaways

- **Takeaway:** volume expansion separates a breakout from a poke-through.
- **Takeaway:** compare breakout volume to the instrument's own recent average.
- **Takeaway:** a failed high-volume breakout is a warning, not a do-over.

## Lesson 3.5 — Pattern-to-strategy wiring

### 1) Concept

A pattern is not a trade until it is a *plan*. Every pattern must map to four
numbers before entry:

1. **Entry** — the trigger close (neckline, triangle edge, flag breakout).
2. **Stop** — the invalidation level (beyond the right shoulder, the far side of
   the triangle, the flag low).
3. **Target** — the measured move from Lesson 3.3.
4. **Risk-reward ratio** — `(target − entry) / (entry − stop)`; most systems
   demand ≥ 1.5 or 2.

This wiring is the seed of the *system building* idea that returns in M6 and in
S5-TA: a rule, a stop, a target, and a risk budget.

### 2) Worked example

H&S entry 22,800, stop 24,300 (above right shoulder), target 21,300:

```python
from decimal import Decimal
entry, stop, target = Decimal("22800"), Decimal("24300"), Decimal("21300")
risk = entry - stop
reward = target - entry
print("risk:", risk, "reward:", reward, "R/R:", reward / risk)
# risk: -1500  reward: -1500  R/R: 1
```

R/R = 1 is *below* a professional 1.5–2 bar; the trader would either pass or
demand a better entry closer to the neckline. (Work with `abs()` on `risk` when
you compute ratios mechanically.)

### 3) Common pitfalls

> **Pitfall:** computing R/R upside down (`risk / reward` instead of
> `reward / risk`) — decide once and standardise.
> **Pitfall:** placing the stop *inside* the pattern's noise (e.g. inside the
> right shoulder). The stop lives beyond the invalidation level.
> **Pitfall:** taking a pattern whose R/R is below your minimum. Low R/R trades
> are how good patterns lose money.

### 4) Key takeaways

- **Takeaway:** entry, stop, target, R/R — four numbers, no exceptions.
- **Takeaway:** the stop is the *invalidation*, not a comfort level.
- **Takeaway:** this four-number habit is the DNA of every system you will build.

## Tantra Lab 3 — H&S target math

### Lab goal

Prove the H&S measured-move formula in `Decimal` and then see the same
"breakout → measured move" logic inside a real Turtle breakout backtest.

### Code

```python
from decimal import Decimal

def hs_target(neckline: Decimal, head: Decimal, breakout_price: Decimal) -> Decimal:
    """Downside target of a head & shoulders: project the head's height below the neckline."""
    height = head - neckline
    return breakout_price - height

neckline = Decimal("23000"); head = Decimal("24500"); breakout = Decimal("22800")
print("H&S target:", hs_target(neckline, head, breakout))
```

### Expected output

`H&S target: 21300`. The height is `24,500 − 23,000 = 1,500`, projected below
the breakout close `22,800 − 1,500 = 21,300`.

### Hand-in checklist

- [ ] The `21300` output line in the journal.
- [ ] A printed NIFTY chart with a triangle or flag: formation height measured,
      target computed by hand, and the same logic reproduced in code with a
      breakout-detection rule (close beyond the pattern edge).
- [ ] The entry/stop/target/invalidation written out for the pattern.
- [ ] Output of `python tantra-examples/examples/07_turtle_breakout_backtest.py`
      pasted, with a sentence connecting Donchian-channel breakouts to the
      measured-move idea.

### Common errors

- **Subtracting in the wrong order** — `head − neckline` is positive by
  construction (the head is *above* the neckline); swapping them flips the
  target to the wrong side.
- **Projecting from the head instead of the breakout** — the height is anchored
  to the neckline, the projection point is the confirmed breakout close.
- **Using float** — `Decimal("23000")` vs `23000.0`: the wheel returns
  `Decimal`, so keep everything in `Decimal`.

## Practice problems

1. H&S: neckline 22,000, head 23,400, breakout close 21,800. Compute the
   measured target and the R/R if the stop sits at 23,000.
2. An ascending triangle has support 24,000 and resistance 24,500. It breaks
   with a close of 24,540. What is the measured target?
3. A flag's pole runs 23,000 → 24,200; the breakout close is 24,250. What is the
   measured move?
4. Explain the difference between a symmetric and an ascending triangle, and the
   correct way to trade the symmetric one.
5. A breakout bar prints volume 2.4M against a 5-bar average of 1.2M. Is this a
   volume-confirmed break by the 1.5× rule?
6. State why the H&S right shoulder is the invalidation level for a top pattern,
   and where the equivalent stop sits for an inverted H&S.
7. For a descending triangle with support 19,800 and highs falling from 20,300,
   what is the measured move if the breakdown closes at 19,750?
8. Why is a pattern with R/R below 1.5 unattractive even when the pattern is
   textbook-perfect? Relate your answer to M8's position-sizing rule.

### Solutions

1. height `= 1,400`; target `= 21,800 − 1,400 = 20,400`. Risk `= |21800 − 23000|
   = 1,200`; reward `= 21,800 − 20,400 = 1,400`; R/R ≈ 1.17.
2. height `= 500`; target `= 24,540 + 500 = 25,040`.
3. pole `= 1,200`; target `= 24,250 + 1,200 = 25,450`.
4. Symmetric: both sides converge, no bias — trade the breakout in whichever
   direction it comes. Ascending: flat resistance with rising lows — bullish
   bias, so wait for an *up* break.
5. 2.4M / 1.2M = 2.0 ≥ 1.5 — yes, volume-confirmed.
6. A close back above the right shoulder means the sellers never took control —
   the pattern is void. For an inverted H&S the stop sits below the right
   trough.
7. Breakdown target `= 19,750 − (20,300 − 19,800) = 19,750 − 500 = 19,250`.
8. Low R/R means a few losers erase many winners; even a 60% win rate loses
   money at R/R = 1 after costs. M8 sizes positions off *risk per trade*, and
   R/R is the other half of that equation.

## Quiz bank

| Question | A | B | C | D | Answer |
|---|---|---|---|---|---|
| An H&S top completes when price | Touches the neckline | Closes below the neckline | Prints a double top | Volume halves | B |
| The H&S measured target projects | The neckline | The head's height below the neckline | The right shoulder | The last peak | B |
| An ascending triangle has | Flat support, rising highs | Flat resistance, rising lows | Converging sides | Falling lows | B |
| Flags and pennants are | Reversal patterns | Continuation patterns | Gap patterns | Doji clusters | B |
| A rising wedge usually breaks | Up | Down | Flat | Sideways | B |
| The triangle measured target equals | Base height projected from breakout | Pole length | Neckline | Volume | B |
| Pattern completion requires | A touch | A confirmed close | A news item | Two touches | B |
| Risk-reward ratio equals | risk / reward | reward / risk | entry / stop | target − entry | B |
| A valid breakout should show | Shrinking volume | Volume expansion | No volume | Low volume | B |

## Glossary

- **Head & shoulders** — a three-peak top with a higher middle peak, completed
  by a close below the neckline.
- **Neckline** — the line joining the troughs between the shoulders/head.
- **Double/triple top or bottom** — two/three failed tests of a level.
- **Symmetric triangle** — converging highs and lows; directional resolution.
- **Ascending triangle** — flat resistance with rising lows; bullish bias.
- **Descending triangle** — flat support with falling highs; bearish bias.
- **Flag / pennant** — short continuation consolidation after a pole.
- **Wedge** — a slanted triangle that usually breaks against its slant.
- **Measured move** — the pattern's height (or pole length) projected from the
  breakout to give a target.
- **Failed breakout** — a break that closes back inside the pattern.
- **Risk-reward ratio** — reward ÷ risk; the professional minimum is ≈ 1.5–2.
- **Invalidation** — the price level that proves the pattern wrong.

## Reading assignment

- Edwards & Magee, *Technical Analysis of Stock Trends*, ch. 6–11 (patterns and
  volume).
- Murphy, *Technical Analysis of the Financial Markets*, ch. 7 (patterns).
- Platform: study `tantra-examples/examples/07_turtle_breakout_backtest.py` — a
  Donchian breakout is a measured-move pattern turned into a rule.
- Full list: [Reading & Resource List](../appendices/reading-list.md).

## Assessment reminder

This module feeds the **chart-lab practical** — 10 patterns, each documented
with entry/stop/target/invalidation — and the **pattern-classification quiz**.
Both are graded components; see [Assessment](../front/assessment.md).

## Assessment

- Chart-lab practical: 10 patterns, each with entry/stop/target/invalidation.
- Quiz: pattern classification.

**Next:** [M4 — Technical Indicators: The Math](m4-indicators-math.md)
