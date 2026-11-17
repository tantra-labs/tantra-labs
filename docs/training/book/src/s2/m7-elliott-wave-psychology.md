# M7 — Elliott Wave & Market Psychology

> **Weeks 28–29 · 16 hrs · PLO-3 · Core reading:** Frost & Prechter, *Elliott Wave Principle*, ch. 1–4; IFTA App A; Elder, *Trading for a Living*, ch. 1–2

## Learning outcomes

- State the Elliott Wave rule: a motive wave of five sub-waves, a corrective wave of three.
- Apply wave-counting guidelines and Fibonacci relationships between waves.
- Present alternate wave counts honestly.
- Explain the psychological drivers of trends (Elder): fear, greed, hope, regret.

## Prerequisites

- [M1 — Dow Theory](m1-dow-theory.md): swings and trend phases — waves are
  swings at different *degrees*.
- [M6 — Advanced Indicators](m6-advanced-indicators.md): Fibonacci retracement
  levels and `φ` — wave relationships are Fibonacci relationships.
- `Decimal.sqrt()` for the `φ` lab.

## Lesson 7.1 — The wave principle

### 1) Concept

Ralph Nelson Elliott observed that crowd-driven prices advance in a
five-wave **motive** pattern and correct in a three-wave **corrective** pattern:

```
Motive (impulse):  1-2-3-4-5      Corrective:  A-B-C
```

The trend direction follows the *next-larger degree*: a completed five-wave
advance is followed by a three-wave decline, and that whole cycle is one wave of
an even larger pattern. Three rules are **non-negotiable** (violating one
invalidates the count):

1. **Wave 2 never retraces more than 100% of wave 1** (it may not undercut wave
   1's start).
2. **Wave 3 is never the shortest impulse wave** (it is usually the longest).
3. **Wave 4 never enters the price territory of wave 1** (no overlap, in
   impulse mode).

These are *rules*; everything else — equality of waves 1 and 5, alternation of
corrective patterns, channeling — is *guideline*.

### 2) Worked example

The wave-2 rule as code: wave 1 runs 24,000 → 25,000; wave 2 may retrace up to
100% of wave 1 — a close below 24,000 invalidates the impulse count.

```python
from decimal import Decimal
wave1_start, wave1_end = Decimal("24000"), Decimal("25000")
wave2_low = Decimal("24050")
valid = wave2_low > wave1_start
print("wave 2 valid (no 100% retrace):", valid)   # True
print("invalidation price:", wave1_start)
```

### 3) Common pitfalls

> **Pitfall:** treating guidelines (alternation, equality) as rules. Only the
> three rules invalidate a count.
> **Pitfall:** counting waves before the sub-structure is complete — a "wave 3"
> label on three bars is a guess, not a count.
> **Pitfall:** ignoring degree. Labelling a minor (daily) five-wave as a
> primary impulse is the classic beginner error.

### 4) Key takeaways

- **Takeaway:** motive = 5 waves, corrective = 3; larger trends are made of
  both, nested.
- **Takeaway:** three hard rules: 2 < 100% of 1, 3 never shortest, 4 no overlap
  into 1.
- **Takeaway:** a count is only valid *until* a rule breaks — that price is your
  invalidation.

## Lesson 7.2 — Fibonacci structure

### 1) Concept

Wave relationships are Fibonacci relationships:

- **Wave 2** commonly retraces 0.382–0.618 of wave 1.
- **Wave 3** often *extends* to 1.618 of wave 1 (a projection, not a
  retracement).
- **Wave 5** relates to waves 1 and 3: equality (`1.0`) or extension (`1.618`,
  `0.618`), typically measured from wave 4's end.

The golden ratio governs the whole family:

```
φ = (1 + √5)/2 ≈ 1.618    1/φ ≈ 0.618    1/φ² ≈ 0.382    1/φ³ ≈ 0.236
```

### 2) Worked example

Wave 1 = 500 points (24,000 → 24,500). Wave 3's 1.618 projection:

```
wave 3 target = wave 1 length × 1.618 + wave 2 low
              = 500 × 1.618 + 24,100 ≈ 24,909
```

```python
from decimal import Decimal

phi = (Decimal(1) + Decimal(5).sqrt()) / 2
print("phi =", phi)  # 1.618...

def wave3_projection(wave1: Decimal) -> Decimal:
    return wave1 * Decimal("1.618")

print("wave 3 extension:", wave3_projection(Decimal("500")))
```

`Decimal("1.618")` is the ratio as a constant; `phi` itself derives from `√5`.

### 3) Common pitfalls

> **Pitfall:** using exact Fib numbers as precision levels — treat them as
> *zones* around which you wait for candle confirmation.
> **Pitfall:** confusing retracement (fraction of a completed wave) with
> *extension* (multiple of a completed wave beyond its end).
> **Pitfall:** anchoring wave 3 projections to the wrong origin — extensions
> are measured from the *end of wave 2*, not from wave 1's start.

### 4) Key takeaways

- **Takeaway:** wave 2 retraces 0.382–0.618; wave 3 extends 1.618 of wave 1.
- **Takeaway:** `φ = (1+√5)/2 ≈ 1.618` and its inverse family drive the levels.
- **Takeaway:** projections are zones; confirm with candles.

## Lesson 7.3 — Counting in practice

### 1) Concept

Counting is a discipline, not a party trick:

1. Count from the **lowest swing** for the largest visible degree.
2. Mark wave labels, then label the **alternate count** — a bullish and a
   bearish alternative, honestly.
3. **Never trade a count, trade the invalidation**: a count is only as good as
   its "if X breaks, the count is wrong" price.

A count with no invalidation is astrology; a count with an invalidation is a
tradeable hypothesis.

### 2) Worked example

Bullish count: 24,000 → 25,000 (wave 1), pullback to 24,200 (wave 2), target
24,909 (wave 3 projection). Invalidation: a close below 24,000 breaks the wave-2
rule (100% retrace). Alternate bearish count: the whole move 24,000–25,000 was a
corrective B-wave — a close below 24,000 flips to C-wave decline.

```python
from decimal import Decimal
invalidation = Decimal("24000")
close = Decimal("24100")
print("bullish count alive:", close > invalidation)   # True
```

### 3) Common pitfalls

> **Pitfall:** refusing to publish an alternate count. The alternate is what
> saves you when the main count fails.
> **Pitfall:** trading the label instead of the stop — "wave 4" is not a reason
> to buy; the invalidation price is.
> **Pitfall:** re-labelling every move to keep the preferred count alive. A
> count that needs constant surgery is a dead count.

### 4) Key takeaways

- **Takeaway:** count from the largest visible swing; mark labels and alternates.
- **Takeaway:** every count carries an invalidation price.
- **Takeaway:** the count is a hypothesis, the stop is the trade.

## Lesson 7.4 — Trading psychology (Elder)

### 1) Concept

The four emotions of the market (Elder): **fear**, **greed**, **hope**, and
**regret**. They drive the loop that destroys accounts: a losing trade triggers
regret, which triggers revenge trading, which overtrades, which loses more.
Elder's essentials are brutally practical: **trade the plan** (rules written
before the market opens), **size for survival** (the M8 1–2% rule), and
**journal everything** (your own emotions are data). Mass psychology explains
why trends persist — trends are crowds agreeing — and why everyone crowds the
top (greed) and the bottom (fear).

### 2) Worked example

The revenge-trade audit: track, after every losing trade, the size of the next
position and the emotional trigger. A simple ledger:

```python
from decimal import Decimal
# each row: (trade_pnl, next_size_ratio_to_plan)
trades = [("loss", Decimal("1.0")), ("loss", Decimal("2.0")), ("loss", Decimal("4.0"))]
revenge = [s for kind, s in trades if kind == "loss" and s > Decimal("1.0")]
print("revenge-trades detected:", len(revenge))   # 2
```

Doubling size after a loss is the mechanical signature of revenge trading —
flag it in the journal, never let it through the plan.

### 3) Common pitfalls

> **Pitfall:** judging results by a single trade. Judge the *process*: was the
> plan followed?
> **Pitfall:** "hoping" a losing position recovers. Hope is a strategy only in
> the sense that it is *not* a plan.
> **Pitfall:** skipping the journal. Without a journal, fear and greed are
> invisible; with one, they become measurable (and correctable).

### 4) Key takeaways

- **Takeaway:** fear, greed, hope, regret — name the emotion before you act.
- **Takeaway:** size for survival (1–2%), trade the plan, journal everything.
- **Takeaway:** trends are crowd psychology with a price tag.

## Tantra Lab 7 — Fibonacci relationships in a synthetic wave

### Lab goal

Compute `φ` from `√5` in `Decimal` and the 1.618 wave-3 projection, then apply
both to a real chart with two alternate counts and an invalidation.

### Code

```python
from decimal import Decimal

phi = (Decimal(1) + Decimal(5).sqrt()) / 2
print("phi =", phi)  # 1.618...

def wave3_projection(wave1: Decimal) -> Decimal:
    return wave1 * Decimal("1.618")

print("wave 3 extension:", wave3_projection(Decimal("500")))
```

### Expected output

`phi = 1.618033988749894848204586834` and `wave 3 extension: 809.0` (500 ×
1.618). The φ value matches `(1+√5)/2` to the full `Decimal` context precision.

### Hand-in checklist

- [ ] The two printed lines.
- [ ] A chart with the preferred count and *two* alternates (bullish and
      bearish), labels marked.
- [ ] The Fibonacci wave-3 projection drawn on the chart and its value written
      out.
- [ ] The invalidation price for each count, stated as "if close below/above X".
- [ ] The trade plan (entry/stop/target) logged in the journal.

### Common errors

- **Computing φ with float** — `Decimal(5).sqrt()` is the exact route; `5**0.5`
      is float and forbidden.
- **Forgetting `Decimal("1.618")` is an approximation** — the constant in
      `wave3_projection` is the textbook figure; `phi` is the derived one.
- **Skipping the alternates** — the lab's point is honest counting: one count,
      two alternates, one invalidation each.

## Practice problems

1. Wave 1 runs 20,000 → 21,000. State the price below which wave 2 would
   invalidate the impulse count, and which rule you are applying.
2. Wave 1 length is 300. What is the 1.618 extension of wave 3 if wave 2 ends at
   20,150?
3. Why is "wave 4 overlaps wave 1's territory" a *rule* violation, while
   "waves 1 and 5 are not equal" is only a *guideline*?
4. A trader labels a daily three-bar bounce "wave 2". What is wrong, and what
   degree should they check first?
5. List the four Elder emotions and give the one journal question that exposes
   revenge trading.
6. φ ≈ 1.618. Derive the 0.618 and 0.382 ratios from it (one line each).
7. A count is "alive" at 24,100 with invalidation 24,000. Price closes at
   23,980. What do you do, and what does the alternate count then say?
8. In two sentences: why do trends persist as crowd behaviour, and why does the
   crowd crowd the top?

### Solutions

1. A close below 20,000 — the wave-2 rule (never more than 100% retrace of
   wave 1).
2. `wave 3 target = 20,150 + 300 × 1.618 = 20,150 + 485.4 = 20,635.4`.
3. Overlap breaks the structure *definitionally* — the count cannot exist;
   equality is an observation about *typical* waves, not a requirement.
4. Degree: a three-bar daily bounce is minor-degree; wave 2 labels belong to
   the swing degree being counted — count from the largest visible swing.
5. Fear, greed, hope, regret. Journal question: "did my next position size
   differ from the plan after a loss?"
6. `0.618 = 1/φ`; `0.382 = 1 − 0.618` (equivalently `1/φ²`).
7. The close below 24,000 invalidates the bullish impulse count — exit and
   switch to the bearish alternate (the move was corrective B, now C down).
8. Trends persist because buyers and sellers reinforce each other's conviction
   (mass psychology — Elder's crowd). The crowd crowds the top because greed is
   strongest exactly when prices are highest.

## Quiz bank

| Question | A | B | C | D | Answer |
|---|---|---|---|---|---|
| An impulse has how many waves | 3 | 5 | 7 | 9 | B |
| A corrective wave has how many waves | 5 | 3 | 2 | 6 | B |
| Wave 2 may retrace up to | 100% of wave 1 | 61.8% of wave 1 | 38.2% of wave 1 | 50% | A |
| Which wave is never the shortest | Wave 1 | Wave 2 | Wave 3 | Wave 5 | C |
| Wave 4 may not enter the territory of | Wave 2 | Wave 3 | Wave 1 | Its start | C |
| The golden ratio φ equals | (1+√5)/2 | √2 | 1.5 | π | A |
| Wave 3 often extends to | 0.618 of wave 1 | 1.618 of wave 1 | 2.0 of wave 2 | 1.0 of wave 2 | B |
| The four Elder emotions are | Fear, greed, hope, regret | Fear, love, hate, joy | Greed, envy, pride, anger | Hope, fear, love, greed | A |
| The best invalidation for a count is | A feeling | A rule-breaking close | A target | A news item | B |
| Trade the plan means | Follow the rules you wrote first | Guess better | Copy others | Hold longer | A |

## Glossary

- **Motive wave** — a five-wave (1-2-3-4-5) move in the trend's direction.
- **Corrective wave** — a three-wave (A-B-C) counter-trend move.
- **Degree** — the size/context level of a wave (minor, intermediate, primary).
- **Impulse rules** — wave 2 < 100% of 1; wave 3 never shortest; wave 4 never
  overlaps wave 1.
- **Alternate count** — a competing, honestly labelled wave interpretation.
- **Invalidation** — the price that proves the count wrong.
- **Golden ratio (φ)** — `(1+√5)/2 ≈ 1.618`; source of the Fib family.
- **Extension** — a wave length projected as a multiple (1.618) beyond its
  origin.
- **Retracement** — a fraction (0.382–0.618) of a prior wave given back.
- **Fear/greed/hope/regret** — Elder's four market emotions.
- **Revenge trading** — immediately re-entering larger after a loss.
- **Journaling** — recording rules, emotions, and outcomes as data.

## Reading assignment

- Frost & Prechter, *Elliott Wave Principle*, ch. 1–4 (the wave rules).
- IFTA *CFTe Syllabus & Study Guide*, Appendix A (wave terminology).
- Elder, *Trading for a Living*, ch. 1–2 (psychology).
- Full list: [Reading & Resource List](../appendices/reading-list.md).

## Assessment reminder

This module feeds the **Elliott Wave chart practical** (3 counts + alternates +
invalidations) and the **psychology self-audit journal entry**. Both are graded
components — see [Assessment](../front/assessment.md).

## Assessment

- Elliott Wave chart practical (3 counts + alternates + invalidation).
- Journal: psychology self-audit entry.

**Next:** [M8 — Trading Terminal & Paper Trading Lab](m8-trading-terminal-paper.md)
