# Training & Certification Materials — Index

Curricula, syllabi, and certification preparation materials for the Tantra
training programs.

| Doc | Description |
|---|---|
| **Book — [SEBI Capital Markets Professional Course](book/book/index.html)** | mdBook rendering of the high-school-passout curriculum (built output; source in `book/src/`). Parts = semesters, chapters = modules, lessons = sections; every TA formula given with its math, and every module ends with a **Tantra Lab** using the real wheel surfaces (`tantra.indicators`, `tantra.paper.PaperSession`, `tantra.quant`, `tantra.options`, `tantra_examples.synthetic_bars`). |
| [Curriculum — High School Passout Track](curriculum-high-school-passout.md) | **Canonical program design**: SEBI Capital Markets Professional — 4-semester + track specialization curriculum consolidating the `tmp/` certification syllabi (NISM PGP PM+IA+RA, NIFM RA, IFMC NISM XV prep, CFTe I/II & CMT). Includes PLOs, module-by-module tables, assessment & grading scheme, certification ladder, coverage matrix, and career pathways. |
| `tmp/NISM-PGP-PM+IA+RA.md` | Source: 4-trimester PGP structure with PM / IA / RA specialization tracks (credits & hours). |
| `tmp/NIFM-research-analyst.md` | Source: 39-chapter Research Analyst course map (capital market, derivatives, ODIN, technical analysis, fundamental analysis, RA profession). |
| `tmp/IFMC-research-analyst.md` | Source: 70-item SEBI NISM XV Research Analyst certification prep topic list. |
| `tmp/CFTe-I-II.md` | Source: IFTA CFTe I/II & CMT program links (syllabus PDFs). |

> The `tmp/` files are staged source material; the curriculum document and the
> mdBook are the consolidated, maintained artifacts. Update both the curriculum's
> coverage matrix and the book's chapters when source syllabi change.

## Building the course book (mdBook)

```bash
# one-time: cargo install mdbook --locked --version 0.4.48
cd book
mdbook build        # static site → book/book/
mdbook serve        # live preview at http://localhost:3000
```
