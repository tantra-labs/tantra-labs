# Track TA — Technical Analyst

> **Capstone: constructed chart-analysis package (CFTe II style) · Credentials: CFTe II, CMT I**

## Capstone at a glance

| | |
|---|---|
| **Deliverable** | Constructed chart-analysis package on one live instrument, written as for a fund manager — trend, structure, patterns, indicators, cycles, targets, risks, and a recommendation memo |
| **Format** | ~8–12 page written analysis (essay format) + a backtested rule with walk-forward results + a 15-min recorded presentation |
| **Time budget** | Weeks 65–80 (16 weeks); ~8–10 hours/week = 130–160 total hours |
| **Grading weight** | Capstone ≈ 50% of the semester; modules (labs + quizzes) ≈ 30%; mock sprint ≈ 10%; journal ≈ 10% |
| **Credential at stake** | **CFTe II** (April/October windows, online proctored) and optional CMT Level I — your CFTe I from S2 is the entry ticket |

## Modules

1. **CFTe II constructed-analysis practice** — analyze a current chart as
   *for a fund manager*: trend, structure, patterns, indicators, cycles,
   targets, risks, and a trade/recommendation memo (essay format).
2. **System development & testing** — Le Beau/Lucas and Kirkpatrick discipline:
   define an edge, code it, test out-of-sample, walk-forward.
3. **Advanced charting mastery** — Ichimoku, Point & Figure, Market Profile,
   breadth, and Japanese charts (Nison's *Beyond Candlesticks*: renko/kagi/
   three-line-break).

## Track modules

### Module 1 — CFTe II constructed-analysis practice (weeks 67–70)

The CFTe II constructed-analysis exam gives you *current* charts of a real
market and asks you to write the analysis **a fund manager would pay for**: what
is the trend, what is the market structure, which patterns matter, what do the
indicators say, where are the cycles, what are the price targets, what are the
risks, and what — if anything — should be done with capital. This module trains
exactly that essay. You will practice on **live charts**, write to a word
budget, and learn to separate observation (what the chart shows) from opinion
(what you conclude from it). The discipline: *every statement must be anchored
to a chart feature you can point to.*

**Builds on:** [S2-M1 Dow theory](../s2/m1-dow-theory.md), [S2-M2 candlesticks](../s2/m2-candlesticks.md), [S2-M3 chart patterns](../s2/m3-chart-patterns.md), [S2-M5 gaps & cycles](../s2/m5-gaps-sentiment-cycles.md), [S2-M7 Elliott wave & psychology](../s2/m7-elliott-wave-psychology.md).

**Deliverables:** (1) four constructed-analysis essays on live charts (one per
fortnight), each in the full fund-manager format, (2) a one-page "template
essay" you will reuse in the capstone and the real exam, (3) a self-marked
checklist against the CFTe II marking areas.

### Module 2 — System development & testing (weeks 69–72)

An opinion is not a system. This module teaches the Le Beau/Lucas and
Kirkpatrick discipline of building a **testable edge**: define the rule
precisely, code it, test it on in-sample data, then prove it survives
**out-of-sample** and **walk-forward** testing. The enemy of every beginner is
overfitting — a rule that looks brilliant on history and dies in live trading.
The antidote is a fixed pipeline: (1) write the hypothesis, (2) code the
signals, (3) backtest in-sample, (4) test out-of-sample, (5) walk forward,
(6) evaluate with a deflated Sharpe that punishes curve-fitting, and only then
(7) form a view on allocation size.

**Builds on:** [S2-M4 indicator math](../s2/m4-indicators-math.md), [S2-M6 advanced indicators](../s2/m6-advanced-indicators.md), [S4-M1 statistics](../s4/m1-statistics.md), [S4-M2 correlation & regression](../s4/m2-correlation-regression.md), [S4-M4 performance measurement](../s4/m4-performance-measurement.md).

**Deliverables:** (1) a written edge statement for one rule (entry, exit, stop,
position size), (2) the coded rule run through
`10_walkforward_optimization.py`, (3) an out-of-sample test log, (4) a
deflated-Sharpe evaluation via `optimizer/03_deflated_sharpe_analysis.py`,
(5) a "kill decision" paragraph — the evidence that would make you abandon the
rule.

### Module 3 — Advanced charting mastery (weeks 71–74)

The full charting toolkit beyond candlesticks and Western patterns: **Ichimoku**
(cloud, tenkan/kijun, senkou spans — a complete trend-and-support system),
**Point & Figure** (price-only charts, box size and reversal), **Market
Profile** (where value actually traded, not just where price went), **market
breadth** (how many stocks participate in an index move), and the **Japanese
charts** from Nison's *Beyond Candlesticks* — renko, kagi, and three-line-break,
which filter noise by construction rather than by averaging.

**Builds on:** [S2-M4 indicator math](../s2/m4-indicators-math.md), [S2-M6 advanced indicators](../s2/m6-advanced-indicators.md), [S4-M1 statistics](../s4/m1-statistics.md).

**Deliverables:** (1) one Ichimoku essay on Nifty 50 with cloud/tenkan/kijun
read, (2) one renko or kagi study on a trending stock (e.g., RELIANCE), (3) one
breadth study (advance/decline or participation) across a 3-month window,
(4) a journal glossary of the new terms with one Indian example each.

## Capstone

Produce a **constructed chart-analysis package** on a live instrument (mimics the
CFTe II exam: current charts, one market, analysis as for a fund manager), plus
a **backtested rule** with walk-forward results.

## Capstone tasks

Complete these in order; each task has a deliverable that is graded.

1. **Choose the instrument** — one liquid NSE instrument (index or stock) with
   ≥ 3 years of daily history. *Deliverable:* instrument rationale (liquidity,
   relevance, data length).
2. **Draw the structure** — multi-timeframe trend, market structure (higher
   highs/lows), and the key support/resistance zones. *Deliverable:* annotated
   charts with a structure memo.
3. **Read the patterns** — flag the patterns that matter (reversal/continuation,
   candlestick, Japanese-chart signals). *Deliverable:* pattern log with one
   sentence of significance per pattern.
4. **Run the indicators** — Ichimoku, ADX (+DI/−DI), Donchian, and breadth
   (see Tantra Lab) on the chosen data. *Deliverable:* indicator sheet with
   readings stated in Decimal price terms.
5. **Map the cycles and targets** — cycle context and measured-move/fibonacci
   target zones, not single points. *Deliverable:* target zone memo.
6. **List the risks** — the events and levels that invalidate the view.
   *Deliverable:* risk section with invalidation levels.
7. **Write the recommendation memo** — the fund-manager memo: stance, size
   thinking, entry/target/stop framework. *Deliverable:* the memo.
8. **Backtest and walk forward a rule** — code the rule, test in-sample and
   out-of-sample, walk forward. *Deliverable:* system-testing report with a
   deflated-Sharpe verdict.
9. **Record the presentation** — 15 minutes walking through the package as if
   to a manager. *Deliverable:* recording + final PDF package.

## Grading rubric

| Criterion | Exceeds (A) | Meets (B/C) | Below (D/F) |
|---|---|---|---|
| **Structure** | Full fund-manager essay order; every section earns its place; memo could be read standalone | All sections present; a couple of transitions or redundancies | Sections missing; essay reads as chart notes, not analysis |
| **Evidence / math correctness** | Every statement anchored to a chart feature; targets derived from a stated measurement | Most statements anchored; some targets asserted without derivation | Claims with no visible anchor; targets pulled from nowhere |
| **Decimal / exactness** | All prices, levels, and returns in `Decimal`; targets and stops stated to the paisa, consistently | Decimal levels used with minor display inconsistencies | Float-typed prices/levels; rounding that obscures a level |
| **Risk & disclosure** | Invalidation levels explicit; the no-trade answer is considered; position sizing framed in risk | Risks listed with levels; some generic | Risk section boilerplate; no invalidation levels; always "buy" |
| **Presentation** | 15-min recording within time, charts legible, answers embedded in narrative | Clear walkthrough with minor time overrun | Slides read aloud; charts unreadable on screen |

## Study plan (weeks 65–80)

- **Week 65** — Choose the track; read this chapter; register the CFTe II exam
  window (April or October) as the forcing date; set up the journal.
- **Week 66** — Module 1 start: re-read [S2-M1 Dow theory](../s2/m1-dow-theory.md) and
  [S2-M3 patterns](../s2/m3-chart-patterns.md); choose the practice instrument.
- **Week 67** — First constructed-analysis essay (full fund-manager format) on
  a live chart; self-mark against the CFTe II areas.
- **Week 68** — Second essay; start Module 2: write the edge statement.
- **Week 69** — Code the rule; in-sample backtest via
  `07_turtle_breakout_backtest.py`; record refusals/orders.
- **Week 70** — Out-of-sample test; walk-forward via
  `10_walkforward_optimization.py`.
- **Week 71** — Deflated-Sharpe evaluation
  (`optimizer/03_deflated_sharpe_analysis.py`); write the kill-decision
  paragraph.
- **Week 72** — Third essay; start Module 3: Ichimoku deep-dive (Tantra Lab).
- **Week 73** — Renko/kagi/three-line-break study; Point & Figure and Market
  Profile from the reading list.
- **Week 74** — Breadth study; consolidate the toolkit glossary.
- **Week 75** — Mock sprint week: timed CFTe II-style constructed analysis.
- **Week 76** — Capstone build: structure, patterns, indicators (tasks 2–4);
  peer-review a classmate's draft.
- **Week 77** — Targets, risks, recommendation memo (tasks 5–7); first full
  draft of the package.
- **Week 78** — Backtest report finalization; re-run every price level in
  Decimal; chart annotation pass.
- **Week 79** — Presentation recording; compliance-freeze pass (sources for
  every claim, Decimal check).
- **Week 80** — Final submission; journal close-out; exam logistics (ID,
  proctor setup, timings).

## Mock sprint

A **timed CFTe II-style constructed analysis**, the exact shape of the real
exam:

1. Book 3 uninterrupted hours. You are handed *current* charts of one market
   (use your practice instrument) and must produce the full fund-manager
   analysis: trend, structure, patterns, indicators, cycles, targets, risks,
   and recommendation memo.
2. Write to the capstone's essay format, in the exam's word budget, with a
   visible clock. No talking, no web, no indicator books.
3. Mark yourself against the grading rubric's five criteria and, most
   honestly, against the **evidence** row: highlight every sentence that is
   not anchored to a chart feature you actually drew.
4. Fix the top two weaknesses before the capstone submission. Keep the marked
   script in the journal as exam evidence.

## Lab surface

- `tantra.indicators` — Ichimoku, Donchian, ADX, Fisher Transform, breadth.
- `tantra-examples/examples/10_walkforward_optimization.py` and
  `07_turtle_breakout_backtest.py` — the system-testing discipline.
- `optimizer/03_deflated_sharpe_analysis.py` — honest evaluation of a strategy.

## Tantra Lab

### Lab goal

Prove you can read a market the CFTe II way from code: Ichimoku cloud, ADX
trend strength, and Donchian breakout levels on the same instrument, all in
Decimal, and state what each says in price terms.

### Code

```python
from decimal import Decimal
from tantra.indicators import Ichimoku, Adx, Donchian
from tantra_examples import SampleInstruments, synthetic_bars

bars = synthetic_bars(SampleInstruments.NIFTY50, days=250, seed=42,
                      base_price_paise=24_000)

ichimoku = Ichimoku(tenkan=9, kijun=26, senkou_b=52, displacement=26)
adx = Adx(di_length=14, adx_smoothing=14)
donchian = Donchian(period=20)

last_cloud = last_adx = last_dc = None
for bar in bars:
    cloud = ichimoku.update(bar.high, bar.low)        # (span_a, span_b) | None
    d = adx.update(bar.high, bar.low, bar.close)      # AdxValue | None
    dc = donchian.update(bar.high, bar.low)           # DonchianValue | None
    if cloud is not None:
        last_cloud = cloud
    if d is not None:
        last_adx = d
    if dc is not None:
        last_dc = dc

close = bars[-1].close
print("Last close           ≈", close)
print("Senkou span A / B    ≈", last_cloud[0], last_cloud[1])
print("ADX / +DI / -DI      ≈", last_adx.adx, last_adx.plus_di, last_adx.minus_di)
print("Donchian upper/lower ≈", last_dc.upper, last_dc.lower)
print("Price vs cloud:", "above" if close > last_cloud[0] and close > last_cloud[1] else "inside/below")
```

Then, for the system-testing half of the capstone, run the verified scripts:

```bash
python tantra-examples/examples/07_turtle_breakout_backtest.py
python tantra-examples/examples/10_walkforward_optimization.py
python tantra-examples/examples/optimizer/03_deflated_sharpe_analysis.py
```

### Expected output

Decimal price levels for the last bar: a 20-day Donchian upper/lower (for the
turtle-style breakout), an ADX reading with +DI/−DI (state whether +DI leads —
uptrend — or −DI leads), and the Ichimoku span A/B with the close's position
relative to the cloud. The narrative in your journal must answer: *is the
trend, per these three tools, up, down, or undefined — and where would that view
be invalidated?* The Fisher Transform and breadth readings belong to the same
journal note, described in the module reading, not coded here.

### Hand-in checklist

- [ ] Indicator sheet printed in Decimal for the chosen instrument.
- [ ] One-sentence trend verdict per tool (Ichimoku, ADX, Donchian).
- [ ] Invalidation levels stated in price terms.
- [ ] Walk-forward run logged with in-sample vs out-of-sample results.
- [ ] Journal entry on what the system-testing discipline changed in your view.

### Common errors

- **Reading indicators off their warm-up `None`** — ignore leading `None`
  values; the last bar of 250 days is always past warm-up.
- **Copying float candles into price levels** — bar fields are `Decimal`; if
  any level is a `float`, re-read the import and re-run.
- **Backtesting on the same data you tuned on** — in-sample optimisation is
  not evidence; only the walk-forward/out-of-sample leg counts.

## Deliverables checklist

- [ ] Constructed-analysis package (9 sections, essay format) on the chosen instrument.
- [ ] Annotated charts with structure memo and pattern log.
- [ ] Indicator sheet + breadth study (journal).
- [ ] Backtested rule with in-sample, out-of-sample, and walk-forward results.
- [ ] Deflated-Sharpe verdict and kill-decision paragraph.
- [ ] Mock sprint marked script (evidence row highlighted).
- [ ] 15-minute recorded presentation + final PDF package.

## Reading assignment

See the TA path in the [course reading list](../appendices/reading-list.md) —
the IFTA CFTe syllabus texts, Nison's *Beyond Candlesticks* (renko/kagi/
three-line-break), and the system-testing titles map directly to Modules 1–3.

## Out the other side

- CFTe I (S2) → **CFTe II** (April/October windows, online proctored).
- Optional **CMT Level I** for the international credential.
- Immediate careers: technical analyst trainee, terminal operations, prop-desk support.
