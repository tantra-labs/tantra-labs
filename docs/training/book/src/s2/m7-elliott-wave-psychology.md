# M7 — Elliott Wave & Market Psychology

> **Weeks 28–29 · 16 hrs · PLO-3 · Core reading:** Frost & Prechter, *Elliott Wave Principle*, ch. 1–4; IFTA App A; Elder, *Trading for a Living*, ch. 1–2

## Learning outcomes

- State the Elliott Wave rule: a motive wave of five sub-waves, a corrective wave of three.
- Apply wave-counting guidelines and Fibonacci relationships between waves.
- Present alternate wave counts honestly.
- Explain the psychological drivers of trends (Elder): fear, greed, hope, regret.

## Lesson 7.1 — The wave principle

- **Motive waves (impulses):** 5 waves (1-2-3-4-5). **Corrective waves:** 3
  waves (A-B-C). Trend direction follows the next-larger degree.
- **Rules (not guidelines):**
  1. Wave 2 never retraces more than 100% of wave 1.
  2. Wave 3 is never the shortest impulse wave.
  3. Wave 4 never enters the price territory of wave 1 (in impulse mode).

## Lesson 7.2 — Fibonacci structure

- Wave 2 commonly retraces 0.382–0.618 of wave 1.
- Wave 3 often extends to 1.618 of wave 1.
- Wave 5 relates to waves 1 and 3; projections use the golden ratio `φ`.

## Lesson 7.3 — Counting in practice

- Count from the **lowest swing** for the largest visible degree.
- Mark wave labels, then label the *alternate* count (analyst discipline).
- **Never trade a count, trade the invalidation**: a count is only as good as
  its "if X breaks, the count is wrong" level.

## Lesson 7.4 — Trading psychology (Elder)

- The emotional loop: hope, fear, greed, regret → overtrading, revenge trading.
- Elder's essentials: trade the plan, size for survival, journal everything.
- Mass psychology: why trends persist and why everyone crowds the top/bottom.

## Tantra Lab 7 — Fibonacci relationships in a synthetic wave

```python
from decimal import Decimal

phi = (Decimal(1) + Decimal(5).sqrt()) / 2
print("phi =", phi)  # 1.618...

def wave3_projection(wave1: Decimal) -> Decimal:
    return wave1 * Decimal("1.618")

print("wave 3 extension:", wave3_projection(Decimal("500")))
```

**Task:** on a chart, propose a wave count with *two* alternates (bullish and
bearish), label the Fibonacci projection for wave 3, and state the invalidation
price for each count. Log the trade plan in the journal.

## Assessment

- Elliott Wave chart practical (3 counts + alternates + invalidation).
- Journal: psychology self-audit entry.

**Next:** [M8 — Trading Terminal & Paper Trading Lab](m8-trading-terminal-paper.md)
