# 📚 The Investor's Study — Reading-List mdBook

A **study book** that merges the curated trading & investing collection
(`/tmp/opencode/some-investment-books` — 126 unique titles, ~200 files including
archive editions) into **one macro → micro curriculum**, published as an
[mdBook](https://rust-lang.github.io/mdBook/).

| | |
|---|---|
| **Location** | `docs/reading-list/` |
| **Source collection** | `/tmp/opencode/some-investment-books/` (phases `00-Start-Here` … `08-Duplicates-Archive`) |
| **Structure** | Macro → micro parts (see tree below) |
| **AI companion** | Every chapter & book entry carries a **model-refresh** note for expanding against larger LLMs' training data |

## Why this book exists

The source collection is a folder of PDFs/EPUBs grouped by a *reading phase*
(mindset → foundations → TA → systems → styles → advanced → stories). This study
book re-arranges the same books **by topic, from macro to micro** so you can study
a coherent subject (e.g., "how markets work" or "money management") without
jumping across phases — and it adds study notes, reading orders, self-test
questions, and cross-links that a folder of files cannot.

## Macro → micro structure

```
Part I    The Macro Lens  — markets, money, investing philosophy (ch. 1–3)
Part II   The Company     — fundamentals, valuation, growth systems (ch. 4–5)
Part III  The Chart       — trends/Dow, candlesticks, patterns, volume & price action (ch. 6–9)
Part IV   The Trader      — psychology, systems, money management, trend following (ch. 10–12)
Part V    Styles & Markets— day/swing, forex, binary options (⚠ warning) (ch. 13–15)
Part VI   The Deep End    — professional price action, evidence/algo, options, specialized (ch. 16–20)
Part VII  The Story       — Wizards interviews, legends, crashes & cautionary tales (ch. 21–22)
Part VIII Beyond Markets  — mispriced markets, macro, fiction & leisure (ch. 23–24)
```

Each part descends from the **widest lens** (the whole market) to the **narrowest**
(the individual trader, the single instrument, the micro-pattern).

## References

- **Source collection README** — `/tmp/opencode/some-investment-books/README.md`
  (the original phase-by-phase roadmap this book reorganizes).
- **Collection metadata** — `/tmp/opencode/some-investment-books/_info.json` /
  `_info.text` (title, year, Goodreads rating & review counts for ~128 titles).
- **This book's catalog appendix** — `src/appendices/catalog.md` (every title,
  author, edition, rating, and model-refresh note, generated from the metadata).
- **Little Books, Big Profits series catalogue** — Wiley's
  `little-books-asia.pdf` (contents/topics/summaries of ~31 Little Books;
  catalogued and mapped to chapters in `src/appendices/little-books.md`).
- **AI study companion** — `src/ai-companion.md` (how to use a larger model to
  refresh older editions from its training data).
- **Training curriculum** (this workspace's SEBI-certification mdBook) —
  `docs/training/book/` — the hands-on companion course built on the Tantra platform.

## Build

```sh
mdbook build docs/reading-list      # → docs/reading-list/book/
mdbook serve docs/reading-list      # local dev server (http://localhost:3000)
```

`book/` is git-ignored build output (same convention as `docs/training/book/`).

## Contents

- `book.toml` — mdBook config.
- `CONTENT-SPEC.md` — binding content spec for expanding/editing chapters.
- `src/` — book source: `SUMMARY.md`, parts I–VIII, appendices.
