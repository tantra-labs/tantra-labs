# M9 — Professional Skills & Markets Lab

> **Weeks 1–16 · continuous · PLO-10 (foundation)**

## Learning outcomes

- Read markets news daily and summarize it in plain English.
- Present a 3-slide weekly markets summary.
- Take research-grade notes and build a personal knowledge system.
- Practice professional ethics and discipline from day one.

## Prerequisites

- Every Semester 1 module feeds this one: [M1](m1-math.md) (percentages and CAGR for index moves), [M2](m2-excel.md) (workbook habits), [M3](m3-markets.md) (exchanges and indices), [M4](m4-microstructure.md) (participants and order flow), [M5](m5-instruments.md) (instrument vocabulary), [M6](m6-corporate-actions.md) (terminology and calendars), [M7](m7-financial-statements.md) (results reading), and [M8](m8-intro-technical-analysis.md) (price action and trends).
- You need a journal (digital or paper), a `labs/` folder for scripts, and a routine — this module runs *continuously* from Week 1 to Week 16.

## Lesson 9.1 — The daily markets read

### 1) Concept

The **daily markets read** is the analyst's morning habit: 15–20 minutes absorbing what happened in markets and why. Sources, in order of authority: **NSE/BSE/MCX circulars and daily reports** (primary source), financial dailies (Economic Times, Business Standard, Mint), and **broker research notes** (interpretation, not gospel). What to look for: index moves (Nifty 50, Sensex, and their percentage change), sector leaders and laggards (which sector drove the move), and macro headlines (repo rate, inflation, global markets, USD/INR).

The non-negotiable habit is **vocabulary hygiene**: any term you use in your summary, you must be able to explain in one line — if you can't, you don't get to use it. "The index fell because of selling pressure" is journalism; "Nifty fell 1.2% led by banks, after the RBI kept the repo rate unchanged" is analysis. The M9 Friday lab turns this read into a repeatable, code-assisted summary.

### 2) Worked example

Turning a headline into numbers:

```
Headline: "Nifty 50 down today"
Analyst version: Nifty closed 24,100, down 1.2% from 24,393.
Compute: (24,100 - 24,393) / 24,393 = -1.20%
```

```python
from decimal import Decimal

prev_close, close = Decimal("24393"), Decimal("24100")
move = (close - prev_close) / prev_close
print("move:", (move * 100).quantize(Decimal("0.01")), "%")
```

Output: `move: -1.20 %` — the one number your summary must lead with.

### 3) Common pitfalls

> **Pitfall:** repeating a headline without the percentage — the number *is* the news. **Pitfall:** using terms you can't define (look up *liquidity, FII outflows, futures premium* before quoting them). **Pitfall:** treating broker notes as fact — they are opinions with a model.

### 4) Key takeaways

- **Takeaway:** primary sources (exchanges, circulars) before dailies, dailies before broker notes.
- **Takeaway:** every summary leads with numbers: index level, %, sector and macro drivers.
- **Takeaway:** vocabulary hygiene — define any term you use.
- **Takeaway:** the habit compounds: 15 minutes a day becomes an analyst's reflex.

## Lesson 9.2 — The weekly 3-slide presentation

### 1) Concept

Once a week you present the market in exactly three slides — the discipline of *compression*. **Slide 1: What happened** — index levels and returns (Nifty, Sensex, maybe a sector index), the week's macro events. **Slide 2: What moved** — the sector leaders and laggards, the stocks or themes that drove the move, with the numbers. **Slide 3: So what** — one lesson or one question: *what does this week teach you, or what do you now need to find out?* That third slide is the difference between a news recital and analysis.

The rubric rewards: numbers on every slide, vocabulary you can defend, a clear "so what", and slides you can deliver in under five minutes. You are not forecasting; you are *summarising honestly and asking one sharp question*.

### 2) Worked example

The three slides, pre-filled:

```
Slide 1 (What happened): Nifty 24,100 (-1.2% WoW); repo rate unchanged at 6.5%.
Slide 2 (What moved): banks -2.4% (FII outflows), IT +0.8% (₹ weakening).
Slide 3 (So what): "If FII selling continues next week, do banks keep underperforming?"
```

```python
from decimal import Decimal

nifty_prev, nifty_now = Decimal("24400"), Decimal("24100")
banks = Decimal("-2.4"); it = Decimal("0.8")
print("Nifty WoW:", ((nifty_now - nifty_prev) / nifty_prev * 100).quantize(Decimal("2")),
      "% | banks", banks, "% | IT", it, "%")
```

Output: `Nifty WoW: -1.23 % | banks -2.4 % | IT 0.8 %`.

### 3) Common pitfalls

> **Pitfall:** a third slide that is another prediction instead of a question — "so what" means *what do I now need to learn*. **Pitfall:** slides without numbers. **Pitfall:** reading the slide instead of explaining it — three slides, five minutes, plain English.

### 4) Key takeaways

- **Takeaway:** What happened → What moved → So what, every week.
- **Takeaway:** numbers on every slide; vocabulary you can defend.
- **Takeaway:** the "so what" is a question, not a forecast.
- **Takeaway:** four graded presentations across the semester train the habit.

## Lesson 9.3 — Notes & knowledge system

### 1) Concept

Research-grade notes are a *system*, not a notebook. The course standard is **Cornell notes**: a page split into a left "cue" column (keywords and questions) and a right "notes" column (the lesson content), with a bottom "summary" box (the lesson in 2–3 lines). The cue column is the test: cover the notes, read the cues, recall the content — that recall is the actual learning event.

Your knowledge system has three parts: (1) **lesson notes** (Cornell), (2) a **running glossary** — every technical term you meet, in your own words, added the same day, and (3) the **journal + labs folder**: every lab output and entry *dated and filed*, because by Week 16 that folder *is* your portfolio. Naming matters: `labs/lab7.py`, `journal/2026-11-17.md`. Future-you (and your assessor) must be able to find the 20-day MA chart in under a minute.

### 2) Worked example

A Cornell cue-and-summary for one lesson:

```
Cue:  "NAV formula?"   ->  Notes: NAV = (assets - liabilities) / units (M5)
Cue:  "T+1 means?"     ->  Notes: settle next business day (M4)
Summary:  "Settlement and NAV both reduce to one formula;
          the formula, not the jargon, is the memory."
```

### 3) Common pitfalls

> **Pitfall:** writing notes without cues — the cue column is the recall test. **Pitfall:** filing lab output without a date — "output.csv" is archaeology by Week 10. **Pitfall:** maintaining a glossary you never read — review it weekly; the recall is the point.

### 4) Key takeaways

- **Takeaway:** Cornell structure = cues + notes + a summary box.
- **Takeaway:** a running glossary in your own words, kept daily.
- **Takeaway:** every lab output and journal entry dated and filed — your portfolio.
- **Takeaway:** a knowledge system you don't review is a dead archive.

## Lesson 9.4 — Ethics & discipline (preview of S4-M10)

### 1) Concept

Professional markets conduct rests on three pillars. **Conflicts of interest**: disclose them — if you write about a stock you hold, say so; the SEBI research-analyst regime exists because undisclosed conflicts corrupt research. **Confidentiality**: inside information and client data are not yours to share; acting on unpublished price-sensitive information is insider trading (Prohibition of Insider Trading regulations). **"No tips" discipline**: you never give or take unsolicited tips — "my uncle's broker says buy RELIANCE" is not an investment thesis and has no place in your journal.

The second half is **discipline** — and it beats cleverness. The 2% rule is the classic: risk no more than ~1–2% of capital per trade, so a string of losses cannot cripple the account. Rules, stops, and journaling are the machinery: a written plan, an exit before entry, and a journal that tells you honestly whether *you* followed the plan. The full treatment arrives in S4-M10; today you install the habits.

### 2) Worked example

The 1% risk budget:

```
Capital = ₹1,00,000; risk 1% per trade = ₹1,000 max loss per trade.
Position at a ₹2 stop-loss per share: max 500 shares.
```

```python
from decimal import Decimal

capital, risk_pct = Decimal("100000"), Decimal("0.01")
stop = Decimal("2")
risk_budget = capital * risk_pct
print("risk budget:", risk_budget, "| max shares at ₹2 stop:",
       (risk_budget / stop).quantize(Decimal("1")))
```

Output: `risk budget: 1000 | max shares at ₹2 stop: 500` — decided before entry, not after.

### 3) Common pitfalls

> **Pitfall:** "one small tip won't hurt" — tips are how conflicts and leaks start; the discipline is binary. **Pitfall:** moving the stop after entry "just this once" — that is how ₹1,000 risk becomes ₹10,000 loss. **Pitfall:** journaling only winners — the losers are where the lessons are; no loss-blame language.

### 4) Key takeaways

- **Takeaway:** conflicts are disclosed, not hidden; confidentiality is absolute.
- **Takeaway:** no tips in, no tips out — inside information is off-limits.
- **Takeaway:** risk 1–2% per trade, stops before entry, rules over cleverness.
- **Takeaway:** the journal's job is honesty about *process*, not profit.

## Tantra Lab 9 — Your first market summary in code

### Lab goal

Produce a repeatable weekly summary — index start, end, and percentage move — for a synthetic index, then write the 3-slide narrative around the numbers in your own words.

### Code

```python
from tantra_examples import SampleInstruments, synthetic_bars

bars = synthetic_bars(SampleInstruments.NIFTY50, days=30, seed=42)
first, last = bars[0].close, bars[-1].close
move = (last - first) / first
print(f"week: {first:.2f} -> {last:.2f}  ({(move * 100):.2f}%)")
```

**Task:** every Friday, generate this summary for a synthetic index and write
the 3-slide narrative in your own words. By Week 16 you will have 15 entries.

### Expected output

`week: <start close> -> <end close>  (<move>%)` — for example `week: 24000.00 -> 24153.00  (0.64%)`. The exact numbers come from the seeded series; the format is always the same.

### Hand-in checklist

- [ ] `lab9.py` saved in `labs/`; the weekly run appended to the journal each Friday.
- [ ] 15 weekly entries by Week 16 (title, numbers, 3-slide narrative in plain English).
- [ ] For at least one week: the full 3-slide deck (What happened / What moved / So what) presented in class.
- [ ] Running glossary checked: every term used in the summaries defined in your own words.
- [ ] Journal honesty check: every entry follows the plan, uses Decimal numbers, and avoids loss-blame language.

### Common errors

- **Formatting Decimal with `.2f` failing** — the format spec works on Decimal; if you copied `float(...)` anywhere, the Zero-Floats reviewer will fail it.
- **Comparing `first` and `last` across different lists** — both must come from the same `bars` list, as in the snippet.
- **Skipping the narrative** — the printout is the *data*; the 3-slide narrative is the *analysis*; submitting only the number loses most of the marks.

## Practice problems

1. Turn "markets were mixed" into an analyst sentence with numbers (invent a Nifty level and move).
2. A week's Nifty: 24,200 → 23,900. Compute the WoW return.
3. Name the three pillars of professional conduct from Lesson 9.4 and give one example behaviour for each.
4. Why is the third slide a *question*, not a forecast?
5. A journal entry for a losing trade: write the three required elements (plan, actual, lesson) without blame language.
6. Order the news sources by authority and justify your ranking.

### Solutions

1. Example: "Nifty 50 closed at 24,100, down 1.2% week-on-week, with banks falling 2.4% on FII outflows while IT rose 0.8%." — numbers, sector, and driver.
2. `(23900 - 24200) / 24200 = -1.24%`.
3. Conflicts (disclose any holding when writing about a stock); confidentiality (never share inside/client information); no-tips discipline (give/receive no unsolicited tips).
4. A question drives the next week's research; a forecast invites overconfidence and is rarely testable in one week.
5. Plan: "Buy above 20-day MA, stop 2%, risk ₹1,000." Actual: "Entered late, stopped out for ₹950." Lesson: "My entry rule needs a tighter trigger; I followed the stop — good process."
6. Exchanges/circulars (primary) → financial dailies (verified reporting) → broker notes (opinions with models): authority runs from source-of-record to interpretation.

## Quiz bank

| Question | A | B | C | D | Answer |
|---|---|---|---|---|---|
| The most authoritative daily source is: | broker tip | NSE/BSE circular | a WhatsApp group | a friend's call | B |
| The weekly 3-slide structure is: | What happened / What moved / So what | News / Charts / Prices | Tips / Trades / Wins | Prices / Targets / P&L | A |
| The third slide should end with: | a forecast | a sharp question | your P&L | a prediction of next week | B |
| Cornell notes include: | cues + notes + summary | only a summary | no cues | only the textbook | A |
| A professional whose journal names no losses is: | disciplined | not honest about process | efficient | lucky | B |
| The 1% rule refers to: | return target | max loss per trade | commission | position size always | B |
| "No tips" discipline means: | only share tips with family | never give/act on unsolicited tips | always follow tips | tips are fine | B |
| The 2% risk budget on ₹1,00,000 with a ₹2 stop allows: | 500 shares | 1,000 shares | 2,000 shares | 50 shares | A |
| Acting on unpublished price-sensitive info is: | smart | insider trading | a tip | normal | B |
| The weekly lab runs: | every Friday | once a month | never | only before exams | A |

## Glossary

- **Daily markets read** — the morning habit of summarising index, sector, and macro moves.
- **Primary source** — exchange circulars and official documents (highest authority).
- **3-slide summary** — What happened / What moved / So what.
- **Cornell notes** — cue column + notes column + summary box.
- **Running glossary** — a personal, own-words dictionary kept daily.
- **Knowledge system** — notes + glossary + dated lab/journal portfolio.
- **Conflict of interest** — a personal interest that can bias research; to be disclosed.
- **Confidentiality** — the duty not to share inside or client information.
- **No-tips discipline** — refusing to give or act on unsolicited tips.
- **Risk budget** — the fixed ₹ (e.g., 1% of capital) a trade may lose.
- **Loss-blame language** — journaling that blames the market instead of the process.

## Reading assignment

From the [Reading & Resource List](../appendices/reading-list.md), read the SEBI regulations on Research Analysts and Prohibition of Insider Trading (the ethics core), and keep the NSE/BSE/MCX circulars as your primary daily source. The platform reference `tantra-examples/examples/01_loading_data.py` is the data pipeline behind your weekly lab.

## Assessment reminder

M9 is assessed **continuously across the semester**: attendance and participation, the **4 graded 3-slide presentations**, the **glossary and journal completeness check**, and the 15 weekly lab entries. Together with every module's continuous assessment they feed the 25% continuous component, and the S1 **end-term exam (Week 16)** is the gate to Semester 2. See [Assessment & Grading Scheme](../front/assessment.md).

**End of Semester 1.** Sit the end-term exam (Week 16), then move to
[Semester 2](../s2/overview.md).
