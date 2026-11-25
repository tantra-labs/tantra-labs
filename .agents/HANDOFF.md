# HANDOFF — tantra-labs

**Status**: Chronological gap/plan sweep across Layers 0–6 — **`tantra-core` gaps `0003` & `0005` COMPLETE 2026-11-25**; Wave 0 criticals (`tantra-data 0027`, `tantra-exec 0004`, `tantra-adapters 0008`, `tantra-market 0010`, `tantra-ledger 0014`) & remaining `tantra-core` Phase A (`0008`) next.
Date: 2026-11-25 · Workspace: `tantra-labs`
Playbook: `docs/future-work-bottoms-up-build-order.md`

## Latest Batch — `tantra-core` Gap `0005` (`PortError::unavailable` & Typed Ports) COMPLETE 2026-11-25

- **Kernel (`tantra-core/src/{ports,portfolio,lib}.rs`)**: Added `#[non_exhaustive]` `PortErrorKind` (`Retryable`/`Permanent`/`Unavailable`) and `PortError::Unavailable { capability: &'static str, gap_ref: &'static str }` with `PortError::unavailable(...)`, `kind()`, `is_retryable()`, `Serialize + JsonSchema`, fixed `CalculationFailed` display/doc, typed `ExecutionGateway::cancel(&VenueOrderId)`, and switched `PortfolioAccount.account_id` to serde-transparent `AccountId`.
- **Downstream & Verification**: Added `tests/ports_error_tests.rs` + `schema/golden/port_error_schema_golden.json`, updated `tantra-ui` (`fixtures.rs` + portfolio/TUI tests) and `tantra-runtime-api-rest/src/executor.rs`. Passed `fmt`, `clippy --all-targets -- -D warnings`, `make check`, `make test`, `make prod`, `wasm32` (`tantra-core`, `tantra-ui-{core,api-wasm}`), `tantra-runtime-api-rest` (`openapi_conformance`, `orders_exec`), and `make check` across L1–L4 (`tantra-risk`, `tantra-exec`, `tantra-ledger`, `tantra-market`, `tantra-agent`, `tantra-ffi`).

## Prior batches (2026-11-06..2026-11-24, collapsed per `.agents/rules/handoff-hygiene.md`)

- **`tantra-core` Gap `0003` (Value-Object Invariants, 2026-11-24)**: Private validated constructors + `#[serde(try_from)]` invariants on `Price`, `Quantity`, `PriceBand`, `InstrumentId`, `Instrument` (`2ff789d` / L0–L5 `d03d8b5`).
- **UI Web E2E (`tantra-ui-web` gap `0078`, 2026-11-24) & API v2 Surface (design `0006` R0–R5)**: Playwright E2E, `/api/v2/...` canonical routes, fail-closed auth, Option Chain, `DisplayBlock::Chart`, `make api-gate`.
- **Plan `0020` / T21–T22 / Lakehouse v3 / Paper & Core Foundations (2026-11-06..2026-11-23)**: Dockview + `SqlxSessionStore`, `strategies` Decimal kernel, `tantra-data` CAS v3, reading-list `mdbook`, `tantra-exec-paper`.

## Immediate Next Step
1. **Wave 0 Criticals & `tantra-core` Phase A continuation**: Tackle oldest critical/foundational gaps (`tantra-data 0027` bridge snapshot commits, `tantra-exec 0004`, `tantra-ledger 0014`, `tantra-market 0010`, `tantra-adapters 0008`, `tantra-core 0008` `Money` currency safety).
2. **Active cross-repo roadmaps**: `docs/plans/0008`–`0010`, `0019`–`0023`, T3.3 remaining feeds (`upstox`/`fyers`/`angelone`).

## Operating Invariants
- Toolchain: `cargo 1.97.1` / `rustc 1.97.1`; edition 2024, `rust-version = "1.85"`; canonical build profile is always `prod` (`--profile prod` / `make prod`). Run heavy Cargo test suites one by one.
- Zero inline `#[test]` / `#[cfg(test)]` in `src/**/*.rs` (Parallel Test Directory Rule).
- Wire compatibility: `Price`/`Quantity` remain string-encoded decimals (`serde-with-str`); `-0.00` parses to `Decimal::ZERO` semantics.
- All `.agents/rules/`, `.agents/config/project-settings.json`, and `.agents/checklists/` are binding workspace-wide.
- Plan & Gap discipline: cite upstream `docs/{plans,gaps}/XXXX-*.md` at stubs/fallbacks; clean up completed docs and update indexes on closure.
