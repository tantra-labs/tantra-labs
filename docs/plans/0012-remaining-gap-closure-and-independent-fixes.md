# 0012 — Remaining Open Gaps: Consolidated Inventory & Independent-Fixes Track (T18)

> **Numbering note (2026-11-17, pull rebase)**: originally filed as plan `0011`/track `T17`;
> the upstream pull (`b4c4edf`) introduced plan `0011-unified-data-catalog-lakehouse-v3.md` +
> the T17 Lakehouse track, so this plan was renumbered to `0012` and its track to **T18** per
> the repo's `df37955` precedent (upstream keeps the number; local renumbers).

**Status**: **T18.1–T18.6 Implemented 2026-11-17** — all six independent-fixes track rows landed
(see the task list), and the owning gaps are closed in their repos:
`tantra-data` 0015/0023/0024, `tantra-runtime` 0009/0010, `tantra-strategies` 0007. This document
is retained as the consolidated inventory + completion record; the T18 rows in
`docs/task-list-tracks-and-phases.md` carry the closing commits.
**Scope**: workspace-wide (every repo with an open gap)
**Owning repos**: `tantra-data`, `tantra-market`, `tantra-runtime`, `tantra-strategies`,
`tantra-core`, `tantra-exec`, `tantra-risk`, `tantra-ledger`, `tantra-ui` (+ root gap 0001)

## 0. Executive Summary

After the T13/T14/T15 closure runs (2026-11-16), the workspace has **16 open gap documents**
across 10 repos. Nine of them are already tracked by an active master plan (Elephant Edge
`docs/plans/0005` → T12, Trade Signal Generator `docs/plans/0008`, Qullamaggie `docs/plans/0009`
→ T16, Screener `docs/plans/0010`, and the broker-feed feature tracker T3.3). **Seven gaps have
no governing master-plan track** and are consolidated here into the new **T18** track so nothing
ships without a home:

| T18 | Gap | One-line scope |
| :--- | :--- | :--- |
| T18.1 | `tantra-data` 0015 | NSE trading-holiday provider + reader/store, replacing the runtime's hardcoded `seed_standard_holidays` |
| T18.2 | `tantra-runtime` 0009 | `/ws/chat` per-turn `model` override + multimodal image attachments |
| T18.3 | `tantra-runtime` 0010 | `QuoteTick` session summary fields (`day_high`/`day_low`/`prev_close`/`last_price`/`volume`) |
| T18.4 | `tantra-data` 0023 | `tantra_data.store.mutual_funds` DuckDB store surface (un-skips the MF screener) |
| T18.5 | `tantra-data` 0024 | Shareholding / pledge / SAST / insider / analyst-estimate ingestion |
| T18.6 | `tantra-strategies` 0007 | Runnable catalog strategies (`alpha30_factor`, `equal_weight`) |

T18 items are mutually independent (different repos / crates) and can execute one per wave
under the 2-subagent ceiling.

## 1. Full Open-Gap Inventory (the scrape)

Every open gap document found in the workspace on 2026-11-16. "Governing track" is where the
work is executed from; gaps without a track are the T18 rows above.

| # | Gap doc | Repo | Missing capability | Governing track |
| :--- | :--- | :--- | :--- | :--- |
| 1 | `docs/gaps/0001` = `tantra-market` 0003 | `tantra-market` | Real broker WS feed crates for **upstox / fyers / angelone** (`dhan` + `zerodha` already real, T3.3) | **T3.3** (feature tracker, 2 of 5) |
| 2 | `tantra-core` 0002 | `tantra-core` | Level-map / options-positioning / order-block / stop-protection / signal kernel types | **T12.1** (EE+; core plan 0003) |
| 3 | `tantra-data` 0015 | `tantra-data` | NSE trading-holiday provider (data owner) + runtime calendar wiring | **T18.1** |
| 4 | `tantra-data` 0016 | `tantra-data` | Intraday option-chain snapshot lakehouse + point-in-time GEX series | **T12.3** (EE+) |
| 5 | `tantra-data` 0023 | `tantra-data` | `tantra_data.store.mutual_funds` DuckDB store surface | **T18.4** |
| 6 | `tantra-data` 0024 | `tantra-data` | Shareholding / pledge / SAST / insider / analyst-estimate ingestion | **T18.5** |
| 7 | `tantra-exec` 0003 | `tantra-exec` | Bracket-order (SL / target-ladder / trailing-stop) execution contract | **T12.5** (EE+) + plan 0008 |
| 8 | `tantra-ledger` 0012 | `tantra-ledger` | Bracket-order OMS lifecycle (`BracketOrder` aggregate + TSL journaling) | **T12.7** (EE+) + plan 0008 |
| 9 | `tantra-market` 0005 | `tantra-market` | EE+ indicators: Elephant zones / OI walls & Local-Range PCR / gamma profile / Order Blocks | **T12.2** (EE+) |
| 10 | `tantra-market` 0007 | `tantra-market` | ADR%(20) and Chandelier Exit streaming indicators | **T16.4** (Qullamaggie) + plan 0008 presets |
| 11 | `tantra-risk` 0005 | `tantra-risk` | Stop-protection (mandatory SL, SL band, no-widening TSL) + weight/ADV sizing caps | **T12.6** (EE+) + plan 0008 |
| 12 | `tantra-runtime` 0009 | `tantra-runtime` | `/ws/chat` `model` override + multimodal image attachments | **T18.2** |
| 13 | `tantra-runtime` 0010 | `tantra-runtime` | `QuoteTick` day-high/low/prev-close/volume fields | **T18.3** |
| 14 | `tantra-strategies` 0007 | `tantra-strategies` | Runnable `alpha30_factor` / `equal_weight` catalog strategies | **T18.6** |
| 15 | `tantra-ui` 0007 | `tantra-ui` | Chart level / zone / annotation / stop-line primitives | **T12.9** (EE+ Studio; ui plan 0006) |

## 2. T18 — Independent Gap Closure (the new track)

All seven are "ship the missing capability in the owning repo" fixes. Order below is
dependency-rough (L2 data first, L3/L4 runtime next, L6 SDK/screener last); none blocks another,
so waves may pick any item.

### T18.1 — NSE trading-holiday provider (`tantra-data` 0015)
Add an NSE trading-holiday provider/reader + DuckDB store (mirroring the economic-calendar
pipeline), then wire it into `tantra-runtime-backtest::NseTradingCalendar` replacing
`seed_standard_holidays` (2025/2026 hardcoded table + Muhurat sessions). Cite the gap and
`tantra-ledger` plan 0005 in the runtime consumer. Prerequisite already met: `ClearingCalendar::new()`
is empty and holidays inject via `with_holidays`.

### T18.2 — `/ws/chat` model override + multimodal attachments (`tantra-runtime` 0009)
Extend `ChatClientMessage` with `model: Option<String>` and
`attachments: Option<Vec<ChatAttachmentInput>>` (base64 `image/png` / `image/jpeg`). Route
per-turn model overrides when they differ from the server default (or return an explicit
capability notice), and pass image parts through `tantra-agent-chat` / `tantra-agent-llm` for
vision-capable providers. Unblocks `tantra-ui-web`'s model picker + "Capture area for Quant".

### T18.3 — `QuoteTick` session summary fields (`tantra-runtime` 0010)
Extend `QuoteTick` (or add a `/quotes/summary` schema) with `last_price`, `day_high`, `day_low`,
`prev_close`, `volume` populated from the feed / session aggregator. Regenerate the OpenAPI
artifact (per gap 0005's process) and map `dayHigh`/`dayLow` directly in
`tantra-ui-web/src/lib/vyapaar-runtime-client.ts`.

### T18.4 — Mutual-funds store surface (`tantra-data` 0023)
Ship `tantra_data/store/mutual_funds.py` with `DuckDbMutualFundsStore` over the AMFI ingestion:
`mf_holdings.isin ↔ companies.isin_code` lookthrough (weighted ROCE / P/E, market-cap
breakdown), NAV/AUM/TER/category/plan/option records, and portfolio-overlap queries. Then
`tantra-examples` drops the degraded skip and `test_mutual_fund_screener_execution` runs against
the provisioned `mutual_funds.duckdb` (plan 0004 dataset).

### T18.5 — Shareholding / pledge / SAST / analyst estimates (`tantra-data` 0024)
Verify a free machine-readable source first (NSE/BSE shareholding-pattern filings, SAST Reg.
29/31, PIT insider filings) — no fabricated data. Then `ShareholdingPattern` / `PledgeRecord` /
`InsiderDisclosure` domain + store + reader, point-in-time by filing date, Decimal percentages,
Parquet projection export for Rust readers (bridge pattern of gaps 0017–0019). Analyst estimates
stay open-and-documented unless a licensable source exists. Unblocks the Shareholding /
Forecaster / Red-Flag screener categories (plan 0010 F9).

### T18.6 — Runnable catalog strategies (`tantra-strategies` 0007)
Ship runnable `alpha30_factor` (and the `equal_weight` needed by
`tests/integration/test_07_alpha30_backtest.py`) as real `Strategy` subclasses with declarative
`Parameter`s, plus `config.toml` + `step.toml` beside them in the loader layout. Keeps the chain
validator honest ("validated *and* runnable") and un-skips the catalog-gated integration tests.

## 3. Non-goals / already-covered work

- **Gaps tracked by active master plans** (rows 1–2, 4, 7–11, 15 in §1) execute under their
  existing tracks (T12 EE+, T16 Qullamaggie, plan 0008 TSG, plan 0010 Screener, T3.3 feeds) —
  this plan only cross-links them so the inventory is complete.
- No new broker-feed stubs: `upstox`/`fyers`/`angelone` crates are re-added only as real wire
  implementations (gap-tracking §4).
- No data fabrication: every T18 data ingestion (0015, 0024) requires a verified source before
  provider code.

## 4. Related

- [`docs/task-list-tracks-and-phases.md`](../task-list-tracks-and-phases.md) — **T18 track rows**
  (updated in the same change as this plan).
- [`docs/plans/README.md`](README.md) — workspace plans index (this plan added to Active).
- Per-repo gap indexes: `tantra-data`, `tantra-market`, `tantra-runtime`, `tantra-strategies`,
  `tantra-core`, `tantra-exec`, `tantra-risk`, `tantra-ledger`, `tantra-ui` (source of truth for
  each gap's status).
