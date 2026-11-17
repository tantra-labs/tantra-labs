# M3 — Chart Patterns & Reversals

> **Weeks 21–23 · 24 hrs · PLO-3 · Core reading:** Edwards & Magee ch. 6–11; Murphy ch. 7

## Learning outcomes

- Recognize head & shoulders, double/triple tops & bottoms.
- Classify triangles, flags, pennants, wedges, and consolidation formations.
- Compute measured-move price targets for each pattern.
- State the invalidation level of every pattern you trade.

## Lesson 3.1 — Reversal patterns

- **Head & shoulders (H&S):** left shoulder, head, right shoulder, neckline.
  - Entry: close below neckline. Target: neckline minus `head − neckline`.
  - Inverted H&S for bottoms.
- **Double/triple tops & bottoms:** two (three) tests of a level, failure to break.
- Pattern completion = confirmed close, not a touch.

## Lesson 3.2 — Triangles and consolidation

- **Symmetric triangle:** converging highs and lows — directional resolution.
- **Ascending triangle:** flat resistance, rising lows — bullish bias.
- **Descending triangle:** flat support, falling highs — bearish bias.
- **Flags & pennants:** brief consolidations *after* a strong move (continuation).
- **Wedges:** rising wedge (bearish), falling wedge (bullish).

## Lesson 3.3 — Measurement objectives

- Triangle target: height of the base projected from breakout.
- Flag/pennant: measured move = prior pole length.
- H&S target: neckline projection (above).
- The **trading range** concept: breakouts from ranges with volume.

## Lesson 3.4 — Volume confirmation

- Breakouts should show volume expansion.
- Failed breakouts: low-volume breaks fail more often; beware.

## Lesson 3.5 — Pattern-to-strategy wiring

- Every pattern → entry, stop (invalidation), target, risk-reward ratio.
- This is the seed of the *system building* idea in M6 and S5-TA.

## Tantra Lab 3 — H&S target math

```python
from decimal import Decimal

def hs_target(neckline: Decimal, head: Decimal, breakout_price: Decimal) -> Decimal:
    """Downside target of a head & shoulders: project the head's height below the neckline."""
    height = head - neckline
    return breakout_price - height

neckline = Decimal("23000"); head = Decimal("24500"); breakout = Decimal("22800")
print("H&S target:", hs_target(neckline, head, breakout))
```

**Task:** on a printed NIFTY chart, find a triangle or flag, measure the
formation's height, compute the target by hand, and then test the same logic in
code with a breakout-detection rule. Log it in your journal with the
invalidation level. Run `tantra-examples/examples/07_turtle_breakout_backtest.py`
— the Turtle system is literally a Donchian-channel breakout pattern turned into
a rule (Donchian channels return in M6).

## Assessment

- Chart-lab practical: 10 patterns, each with entry/stop/target/invalidation.
- Quiz: pattern classification.

**Next:** [M4 — Technical Indicators: The Math](m4-indicators-math.md)
