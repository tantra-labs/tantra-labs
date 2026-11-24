# HANDOFF — tantra-labs

**Status**: Chronological gap/plan sweep across Layers 0–6 — **`tantra-core` gap `0003` COMPLETE 2026-11-24**; Wave 0 criticals & remaining `tantra-core` plan `0006` items next.
Date: 2026-11-24 · Workspace: `tantra-labs`
Playbook: `docs/future-work-bottoms-up-build-order.md`

## Latest Batch — `tantra-core` Gap `0003` (Value-Object Invariants) COMPLETE 2026-11-24

- **Hardened L0 value objects (`tantra-core/src/{types,instrument}.rs`)**: Private inner fields with validated `try_new` / `try_from_parts` constructors and `#[serde(try_from = "...")]` validation on `Price` (`>= 0`, `get()`/`as_decimal()`), `Quantity` (`>= 0`, `get()`/`as_decimal()`), `PriceBand` (`lower <= reference_price <= upper`, `0 < band_pct <= 1`), `InstrumentId` (trimmed ASCII uppercase across constructors + serde, `symbol()` accessor), and `Instrument` (`tick_size > 0`, `lot_size > 0`).
- **Verification**: `tantra-core/tests/value_object_invariants.rs` (unit + proptest + negative JSON golden vectors), full Rust + `wasm32-unknown-unknown --profile prod` gates across `tantra-core`, `tantra-risk`, `tantra-exec`, `tantra-ledger`, `tantra-market`, `tantra-agent`, `tantra-ffi` (Rust + `make py` 521 pytest), `tantra-ui`, `tantra-runtime` (`make check`, `make prod`, all non-REST crates + targeted REST suites + regenerated `schema/openapi.v2.json`), `tantra-ui-web` (`codegen:api` + `check:api-contract` + `tsc` + `lint` + 152 tests + `build`), and `scripts/check-api-paths.sh` green.
- **Pre-existing runtime test caveats**: `bar_ingest::posted_bars_fill_a_market_order_and_refresh_quotes`, `trade_journal::overview` (date-dependent default range).

## Prior batches (2026-11-06..2026-11-24, collapsed per `.agents/rules/handoff-hygiene.md`)

- **UI Web E2E (`tantra-ui-web` gap `0078`, 2026-11-24)**: `playwright.config.ts`, `npm run e2e`, mocked `/api/runtime/**` + `/api/chat` fixtures (`5c515fd` / root `b913e4e`).
- **Runtime API surface (root design `0006` R0–R5, 2026-11-24)**: `/api/v2/...` canonical only, `tantra-runtime-api-rest` fail-closed auth & caller-partitioned paper accounts (`0017`) / journals (`0013`), Option Chain (`0016`), HTTP status alignment (`0015`), `tantra-market` pure-Decimal indicators (`0009`) + `AdrPct`/`ChandelierExit` (`0007`), `tantra-agent` `DisplayBlock::Chart` (`0009`), `make api-gate`.
- **Plan `0020` / T21–T22 / Lakehouse v3 / Paper & Core Foundations (2026-11-06..2026-11-23)**: Dockview + `SqlxSessionStore` threads + `CodeDiff` (`agent 0010`, `runtime 0014`), `strategies` Decimal kernel / `OverlayScene`, `tantra-data` CAS v3, reading-list `mdbook`, `tantra-exec-paper`.

## Immediate Next Step
1. **Continue chronological open gaps/plans sweep**: Next up — `tantra-core` `0005` (`PortError::unavailable` / typed `cancel`) & `0008` (`Money::notional` currency safety) + `0004` (`wire-schema-evolution-gate`), and Wave 0 criticals (`tantra-ledger 0014`, `tantra-exec 0004`, `tantra-market 0010`, `tantra-data 0027`, `tantra-adapters 0008`).
2. **Active cross-repo roadmaps**: `docs/plans/0008`–`0010`, `0019`–`0023`, T3.3 remaining feeds (`upstox`/`fyers`/`angelone`).

## Operating Invariants
- Toolchain: `cargo 1.97.1` / `rustc 1.97.1`; edition 2024, `rust-version = "1.85"`; canonical build profile is always `prod` (`--profile prod` / `make prod`).
- Zero inline `#[test]` / `#[cfg(test)]` in `src/**/*.rs` (Parallel Test Directory Rule).
- Wire compatibility: `Price`/`Quantity` remain string-encoded decimals (`serde-with-str`); `-0.00` parses to `Decimal::ZERO` semantics.
- All `.agents/rules/`, `.agents/config/project-settings.json`, and `.agents/checklists/` are binding workspace-wide.
- Plan & Gap discipline: cite upstream `docs/{plans,gaps}/XXXX-*.md` at stubs/fallbacks; clean up completed docs and update indexes on closure.
