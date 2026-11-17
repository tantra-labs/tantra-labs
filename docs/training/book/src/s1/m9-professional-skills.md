# M9 — Professional Skills & Markets Lab

> **Weeks 1–16 · continuous · PLO-10 (foundation)**

## Learning outcomes

- Read markets news daily and summarize it in plain English.
- Present a 3-slide weekly markets summary.
- Take research-grade notes and build a personal knowledge system.
- Practice professional ethics and discipline from day one.

## Lesson 9.1 — The daily markets read

- Where to read: NSE/BSE circulars, financial dailies, broker notes.
- What to look for: index moves, sector leaders/laggards, macro headlines.
- Vocabulary hygiene: explain any term you use.

## Lesson 9.2 — The weekly 3-slide presentation

1. What happened (index/returns/macro).
2. What moved (sector/stock/themes).
3. So what (one lesson or one question).

## Lesson 9.3 — Notes & knowledge system

- Cornell-style notes for every lesson; a running glossary.
- Filing every lab output and journal entry (this becomes your portfolio).

## Lesson 9.4 — Ethics & discipline (preview of S4-M10)

- Conflicts of interest, confidentiality, "no tips" discipline.
- Why discipline (rules, stops, journaling) beats cleverness.

## Tantra Lab 9 — Your first market summary in code

```python
from tantra_examples import SampleInstruments, synthetic_bars

bars = synthetic_bars(SampleInstruments.NIFTY50, days=30, seed=42)
first, last = bars[0].close, bars[-1].close
move = (last - first) / first
print(f"week: {first:.2f} -> {last:.2f}  ({(move * 100):.2f}%)")
```

**Task:** every Friday, generate this summary for a synthetic index and write
the 3-slide narrative in your own words. By Week 16 you will have 15 entries.

## Assessment

- Continuous rubric: attendance, participation, 4 graded presentations.
- Glossary & journal completeness check at end of semester.

**End of Semester 1.** Sit the end-term exam (Week 16), then move to
[Semester 2](../s2/overview.md).
