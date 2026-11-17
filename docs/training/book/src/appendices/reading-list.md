# Reading & Resource List

This appendix is the book's reference shelf. The lists are ordered by how the
course actually uses each item; the **"Reading order"** note under every category
tells you which semesters open which books, so you never buy a book "early" or
read one in the wrong semester.

## Core technical analysis (CFTe syllabus from `CFTe-I-II.md`)

- Edwards, R.D. & Magee, J. — *Technical Analysis of Stock Trends* (9th ed.)
- Murphy, J.J. — *Technical Analysis of the Financial Markets*
- Pring, M.J. — *Technical Analysis Explained* (4th ed.)
- Nison, S. — *Candlestick Charting Techniques*; *Beyond Candlesticks*
- Le Beau, C. & Lucas, D. — *Technical Trader's Guide to Computer Analysis of the Futures Market*
- Du Plessis, J. — *The Definitive Guide to Point and Figure*
- Frost, A.J. & Prechter, R.R. — *Elliott Wave Principle*
- Kirkpatrick, C. & Dahlquist, J. — *Technical Analysis: The Complete Resource*
- Elder, A. — *Trading for a Living*
- IFTA *CFTe Syllabus & Study Guide* (2026 ed.) + Appendices A–G + official mocks

> **Why this is assigned** — Semester 2 is organised *as* the CFTe I syllabus,
> and these books are that syllabus: Murphy and Edwards & Magee for charting
> structure, Nison for candlesticks, Frost & Prechter for Elliott Wave, and the
> IFTA study guide for the exact exam format and question style.
>
> **Reading order** — **Semester 2 only.** Murphy first, in the S2 lecture
> order; Nison alongside S2-M2 (candlesticks); Le Beau & Lucas and Du Plessis
> with S2-M6 (systems, point & figure); Elder with S2-M7 (psychology). The IFTA
> study guide and official mocks are for the end-of-S2 exam sprint. Frost &
> Prechter is reference reading, not cover-to-cover.

## Fundamentals, valuation & modeling

- NISM Series XV & Series VIII workbooks (NISM official)
- Damodaran, A. — *Investment Valuation* (chapters as assigned) / *The Little Book of Valuation*
- Penman, S. — *Financial Statement Analysis and Security Valuation* (concept chapters)
- Benninga, S. — *Financial Modeling* (Excel)
- Ross, Westerfield & Jaffe — *Corporate Finance* (selected chapters)

> **Why this is assigned** — Semester 3 is built on this canon: Damodaran for
> valuation and ratios, Penman for how statements behave, Benninga for the Excel
> modelling the S3 workbook demands, and the NISM workbooks because the *exams*
> are NISM's own.
>
> **Reading order** — the NISM workbooks from Semester 1 (reference, alongside
> the S1 lectures); Damodaran's *Little Book of Valuation* in early S3 as the
> beginner on-ramp; *Investment Valuation* chapters with S3-M5–M7; Penman
> concept chapters and Benninga with S3-M8 (the modelling sprint); Ross,
> Westerfield & Jaffe selected chapters with S3-M6 (cost of capital, WACC).

## Statistics & portfolio

- Grinold & Kahn — *Active Portfolio Management* (foundation chapters)
- Elton, Gruber, Brown & Goetzmann — *Modern Portfolio Theory and Investment Analysis* (selected)

> **Why this is assigned** — the S4 quantitative core (descriptive statistics,
> regression, portfolio theory, performance measures) is the content of these
> two books; Elton-Gruber is the friendlier on-ramp for a first-time reader.
>
> **Reading order** — **Semester 4 only.** Elton-Gruber selected chapters with
> S4-M1–M3; Grinold & Kahn foundation chapters with S4-M4, after you can compute
> Sharpe/Treynor/Alpha/Beta by hand and in `tantra.quant`.

## Indian context & practice

- SEBI regulations: Research Analysts, Investment Advisers, Portfolio Managers, PIT
- NSE/BSE/MCX educational material and exchange circulars
- Annual reports & DRHPs of listed companies (live lab material)

> **Why this is assigned** — the exams test Indian regulation and Indian market
> practice, and the S3/S4 labs run on real filings: annual reports and DRHPs are
> the raw data of the modeled-company workbook and the research report.
>
> **Reading order** — exchange education material from S1-M3/M4 (market
> literacy); annual reports and DRHPs from S3-M3 onward as live lab material;
> the SEBI regulations with S4-M10 (the regulatory module); exchange circulars
> on an as-needed basis whenever a lab references one.

## Platform references (this workspace)

- `tantra-examples/examples/` — numbered learning path (01–15 + `basic/`,
  `backtesting/`, `options/`, `screening/`, `strategies/`, `stocksharp/`, `storage/`)
- `tantra-ffi/python/tantra/` — the wheel surface: `indicators`, `quant`,
  `options`, `optimizer`, `portfolio_strategy`, `paper`, `screener`, `metrics`
- `tantra-market/crates/tantra-market-indicators/` — the Rust indicator catalog
  (SMA, EMA, RSI, MACD, Bollinger, ATR, ADX, Ichimoku, SuperTrend, Fisher
  Transform, VWAP, and more)

> **Why this is assigned** — this is the lab itself: the numbered learning path
> is the companion to every Tantra Lab in the book, and the wheel/indicator
> sources are where you check what a surface *actually* does.
>
> **Reading order** — alongside every lab, from S1-M2 (your first run of
> `01_loading_data.py`) through S5. `tantra-ffi/python/tantra/` is the reference
> for the wheel surfaces; the Rust indicator catalog is the deep-dive for
> S2-M4/M6. Set up and smoke-test all of it in Week 1 — see
> [Tantra Platform & Lab Environment](../front/tantra-environment.md).

## Getting the books

- **Start with the free official material** — the NISM workbooks, NSE/BSE/MCX
  education pages and circulars, SEBI regulations, and the annual reports and
  DRHPs used as lab data. None of these costs anything, and most of them *are*
  the exam's own material.
- **Buy the international titles in the semester they are used.** The
  reading-order notes above exist so you never buy early. Libraries and
  second-hand copies are the norm; any listed edition is fine unless a module
  says otherwise.
- **Treat the IFTA study guide and official mocks as consumables**, not shelf
  books: they belong to the end-of-S2 sprint, and re-doing them under timed
  conditions is the point.
