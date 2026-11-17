# Semester 2 — Technical Analysis & Trading Practice

> **Weeks 17–32 · Goal:** complete the **CFTe I syllabus** (Edwards & Magee,
> Murphy, Pring, Nison, IFTA appendices) and become operationally fluent on a
> trading terminal and paper-trading platform.

## Why the math matters

Every indicator in this semester is a **formula**. If you can write the formula,
you can debug why a signal fired, you can change a parameter safely, and you can
recognise when an indicator is being misused. The Tantra wheel exposes the exact
same indicators, in exact `Decimal`, so every formula here can be run and
verified by hand.

## Modules

| Module | Title | Focus |
|---|---|---|
| M1 | Dow Theory, Trends & Chart Construction | Dow Theory; trends; support/resistance; trendlines |
| M2 | Candlestick Analysis | Construction; reversal/continuation patterns |
| M3 | Chart Patterns & Reversals | H&S, double/triple tops, triangles, flags, pennants |
| M4 | **Technical Indicators: The Math** | SMA/EMA/RSI/MACD/Bollinger/ATR — formulas + Tantra |
| M5 | Gaps, Sentiment & Time Cycles | Gap types; sentiment; cycles |
| M6 | Advanced Indicators & Systems | Ichimoku, Fibonacci, ADX, P&F; system building |
| M7 | Elliott Wave & Market Psychology | Wave principle; trading psychology |
| M8 | Trading Terminal & Paper Trading Lab | Terminal ops; `PaperSession` journal |
| M9 | CFTe I Mock Sprint | 3 timed mocks + clinics |

## Assessment rhythm

- Mid-term exam (Week 24) covers M1–M4.
- End-term exam (Week 32) includes a constructed-analysis practical.
- The paper-trading journal runs Weeks 29–31 and beyond.
- CFTe I mock #3 (Week 32) must score ≥ 75/120.

## Tantra tie-in

This semester uses `tantra.indicators` heavily. Every indicator returns
`Decimal | None` until warmed up — handle `None` explicitly, as every lab does.

**Next module:** [M1 — Dow Theory, Trends & Chart Construction](m1-dow-theory.md)
