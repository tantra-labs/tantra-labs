# Reading-List Book Content Spec (binding)

This file is the **binding spec** for authoring/expanding chapters in
`docs/reading-list/src/`. It lives outside `src/` so it is never compiled into
the book. Every subagent that writes a chapter must follow it exactly.

## 1. Goal

Turn the curated collection (`/tmp/opencode/some-investment-books`, 126 unique
titles) into a **study book**: each chapter is a coherent macro→micro topic that
*names every book on that topic*, *synthesises what the books jointly teach*,
gives a *reading order*, provides *self-test questions*, and carries a
**model-refresh** note for each book so a larger LLM can expand the notes from
its training data (especially where a newer edition exists).

## 2. Non-negotiables

1. **Do not rename or remove existing files**; keep the exact `SUMMARY.md` paths
   and each chapter's `# Title` heading.
2. **Every book assigned to the chapter must appear** in the "Books on this
   topic" table and get its own annotation entry. Do not silently drop books.
3. **mdBook-safe markdown only**: no `$...$`/`$$...$$` KaTeX (no preprocessor is
   installed). Write formulas as ASCII/Unicode inline or in fenced code blocks.
4. **Facts only**: author, year, rating come from the catalog appendix
   (`src/appendices/catalog.md`) or this spec's book tables. If you do not know a
   fact, mark it `—`/`TBC` and put it in a **Model refresh** note rather than
   guessing.
5. **Ratings** are Goodreads averages from the collection's `_info.json`
   (0–5 scale; show one decimal). Show them as `★ 4.6` in annotations.
6. **Model-refresh notes are mandatory** on every book annotation (see template
   §3.4). This is the reader's hook to bigger models.
7. Keep fenced code blocks labelled (e.g. ```text or ```python).

## 3. Chapter template (in order)

```
# <Title>

> Part <X> · Chapter <N> · Books: <count> · Topic level: macro ▸ micro

## What this topic is about
3–6 paragraphs of prose: where this sits in the macro→micro path, the central
question the books answer, and the shared vocabulary they assume.

## The books on this topic
A markdown table: Title | Author | Year (in collection) | Rating | Role.
One row per book. "Role" is one short phrase (e.g. "the textbook", "the classic",
"study guide", "the reality check").

## Study synthesis — what the books jointly teach
The "combining" heart: 4–8 bullets or short sections that merge the books' core
lessons into one coherent set of study notes. Cover: key concepts, the
disagreements among the books (if any), and the formulas/methods they share
(written as ASCII math in code fences).

## Book-by-book annotations
For EACH book: a `### <Title>` (author, year, rating) subsection with:
1) one paragraph "What it teaches";
2) "Read it for" bullets (2–4);
3) a **Model refresh** line: "Newer edition? <yes/no — name it if known>.
   Ask your AI study companion to expand these notes from its training data if it
   has seen a later edition (<name the edition you believe exists>, or 'any
   edition after <year>')."

## Reading order
A numbered study path (shortest/fastest first, then depth).

## Self-test questions
5–8 questions the reader should be able to answer after studying the chapter.

## Cross-links
Next chapter link (`[Next: <title>](…)`) and back links.
```

### 3.4 Model-refresh note phrasing (exact options)
- If a newer edition is **known**: `Newer edition: <Title>, <ed.>, <year>. Ask
  your AI study companion to expand this section from its training data.`
- If a newer edition **may exist** (not certain): `A later edition may exist —
  ask your AI study companion to check its training data for any edition newer
  than <year>.`
- If the edition here is the latest: `Edition here is current; your AI companion
  can still expand these notes from its training data.`

## 4. Tone & style

- Clear, plain language; define every technical term at first use.
- Macro→micro awareness: each chapter tells the reader *what bigger topic it
  belongs to* and *what smaller topic it feeds*.
- Honest about the collection: flag ⚠️ books the source README marks as retail
  traps (binary options, some forex "secrets" books, Long-Term Secrets) with a
  warning, not a sales pitch.
- Indian-market-friendly where natural (NSE/BSE, Nifty, USD/INR) but the books
  are global classics — keep examples portable.

## 5. What NOT to do

- Do not add new chapter files or edit `SUMMARY.md` (orchestrator owns both).
- Do not invent author names, ratings, years, or "latest edition" claims.
- Do not write `$` LaTeX.
- Do not run `mdbook build` — write valid markdown only.

## 6. Reporting back

Return: files written, one-paragraph summary per file, and any book/fact you
could not annotate (precise question, not a guess) — per the zero-recon rule.
