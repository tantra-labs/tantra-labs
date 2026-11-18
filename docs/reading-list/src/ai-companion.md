# The AI Study Companion

> How to use larger AI models to expand every chapter of this book from their
> training data — especially when a newer edition of a book exists.

## The idea in one sentence

Every book annotation in this study book carries a **Model refresh** note; those
notes exist so you can paste the book's title + edition + the chapter into a
**larger language model** and get a fuller, up-to-date study treatment based on
the model's training data — which may include editions newer than the files in
the collection.

## Why this matters for a 200-book library

This collection's files are editions published mostly between 1990 and 2017
(e.g., *Option Volatility & Pricing* here is the **1994** edition; a **2013 2nd
edition** exists. *Technical Analysis of Stock Trends* here is the **9th ed.
2007**; the **10th ed. 2012** exists. *Encyclopedia of Chart Patterns* here is
the **2nd ed. 2005**; the **3rd ed. 2016** exists). A frontier model trained on a
broad corpus has often "seen" these newer editions, and can:

1. **Summarise what changed** between the edition in the collection and the
   latest edition it knows.
2. **Expand a chapter** with the newest edition's material (new indicators, new
   case studies, updated market conventions).
3. **Fill in facts this book intentionally left blank** (authors flagged `—`,
   uncertain "latest edition" claims) — the `catalog.md` appendix marks these.

## The refresh prompt (copy-paste)

Use this template with any capable model. Replace the bracketed parts.

```text
You are my AI study companion for a curated investing library.

I am studying <TOPIC> from The Investor's Study, a macro→micro study book.

The collection holds this edition of a book:
  Title:  <BOOK TITLE>
  Author: <AUTHOR>
  Year:   <YEAR IN COLLECTION>
  Rating: <RATING>

Please:
1. If your training data contains a LATER edition of this book, tell me which one
   (edition + year) and summarize what it changed, added, or removed.
2. Expand the study notes below into 300–600 words of accurate study material
   reflecting the latest edition you have seen. Preserve any formulas as plain
   text/code blocks (no LaTeX).
3. Flag anything you are unsure about rather than guessing, and state your
   knowledge cutoff year.

STUDY NOTES FROM THE BOOK:
<PASTE THE BOOK'S ANNOTATION FROM THIS STUDY BOOK>
```

## Rules of engagement

- **Always state the model's knowledge cutoff.** A model cannot know editions
  released after its cutoff — the refresh is only as good as the training window.
- **Do not let the model overwrite this book's structure.** Use refreshes to
  *expand annotations*, not to re-write chapters. This book's ordering and
  macro→micro spine are editorial, not subject to the model's opinion.
- **Cross-check anything surprising.** Models can hallucinate editions, authors
  and page counts. If a claim matters (e.g., "10th edition published 2012"),
  verify it against the publisher before relying on it.
- **Ratings stay from the collection.** Goodreads averages in this book come from
  `_info.json`; a model's memory of a rating is not more authoritative.

## Where the model-refresh hooks live

| Where | What to do |
|---|---|
| Every `### Book` annotation in chapters I–VIII | Paste the book title + this chapter's notes into the refresh prompt |
| Appendix A · catalog.md | Look up any title's edition + whether a newer edition is suspected |
| Appendix B · reading plans | Ask the model to re-plan a path around the newest editions it knows |
| `—` (unknown) facts | Ask the model to fill in the author/latest-edition gap — flagged on purpose |

## The edition watch-list (collection edition → likely newer)

These are the books where a later edition is **most likely** in a modern model's
training data. Full list: [Appendix A · catalog.md](appendices/catalog.md).

| Book (edition in collection) | Likely newer edition |
|---|---|
| Option Volatility & Pricing (1994) | 2nd ed. 2013 |
| Technical Analysis of Stock Trends (9th ed. 2007) | 10th ed. 2012 |
| Encyclopedia of Chart Patterns (2nd ed. 2005) | 3rd ed. 2016 |
| Technical Analysis Explained (4th ed. 2002) | 5th ed. 2014 |
| The Warren Buffett Way (2nd ed. 2005) | 3rd ed. 2013 |
| A Random Walk Down Wall Street (11th ed. 2015) | 12th ed. 2023 |
| The Little Book of Common Sense Investing (2007) | 10th-anniversary ed. 2017 |
| Day Trading For Dummies (3rd ed. 2014) | 4th ed. 2019 |
| Swing Trading For Dummies (2008) | 2nd ed. 2015 |
| The Little Book That Beats the Market (2006) | later editions (2010/2015) |
| How to Make Money in Stocks (4th ed. 2009) | "Complete" ed. 2013 + later |

> ⚠️ **Cutoff caution:** the 12th edition of *A Random Walk Down Wall Street*
> (2023) is only within the training data of the newest models. Always pair an
> edition claim with the model's cutoff year.

**Next:** [Chapter 1 · How Markets Actually Work](part1/01-how-markets-work.md) ·
[Appendix A · The Full Annotated Catalog](appendices/catalog.md)
