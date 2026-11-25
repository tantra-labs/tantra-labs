# HANDOFF — tantra-labs

**Status**: Chronological gap/plan sweep across Layers 0–6 — **Wave 0 #1 (`tantra-data` `0027` snapshot commits) & `tantra-core` gaps `0003`, `0005` COMPLETE 2026-11-25**; next Wave 0 criticals (`tantra-exec 0004`, `tantra-adapters 0008`, `tantra-market 0010`, `tantra-ledger 0014`) & `tantra-core` Phase A (`0008`).
Date: 2026-11-25 · Workspace: `tantra-labs`
Playbook: `docs/future-work-bottoms-up-build-order.md`

## Latest Batch — `tantra-data` Gap `0027` (Lakehouse v3 Snapshot Commits) COMPLETE 2026-11-25

- **Snapshot Commits (`tantra_data/adapters/manifest_store.py`)**: `ManifestStore.commit` merges parent snapshots keyed by `(domain, dataset, exchange, asset_class, timeframe, time_bucket)` with deterministic tree sorting and `entries_replace_only=False` default; added `ManifestStore.entries_for_commit` (authoritative `trees/<tree_hash>.json` + DuckDB fallback).
- **CLI & Docs (`tantra_data/cli/catalog.py`, `docs/design/lakehouse-v3-snapshot-contract.md`)**: `compact` passes `entries_replace_only=True` only on non-empty flush merges (preserving parent entries on no-op); added non-destructive `tantra-catalog repair --root` (walks `parent_sha`, replays oldest-to-newest, latest wins); documented snapshot contract shared with `tantra-market` `0014`.
- **Verification**: `ruff check .`, `ruff format --check .`, `mypy --strict --follow-imports=silent manifest_store.py catalog.py bridge_exporter.py`, and full `python3 -m pytest -q` (including sequential multi-dataset bridge export, Hypothesis idempotence, golden tree vector, and `repair` tests).

## Prior batches (2026-11-06..2026-11-25, collapsed per `.agents/rules/handoff-hygiene.md`)

- **`tantra-core` Gap `0005` (Typed Port Errors & `AccountId`, 2026-11-25)**: Added `PortErrorKind`/`PortError::Unavailable`, typed `cancel`, `PortfolioAccount.account_id: AccountId`, L0–L5 `prod`/`wasm32`/OpenAPI checks green (`ce32fe9`).
- **`tantra-core` Gap `0003` (Value-Object Invariants, 2026-11-24)**: Private validated constructors + `#[serde(try_from)]` invariants on `Price`, `Quantity`, `PriceBand`, `InstrumentId`, `Instrument` (`2ff789d` / L0–L5 `d03d8b5`).
- **UI Web E2E (`tantra-ui-web` `0078`) & API v2 Surface (`0006` R0–R5)**: Playwright E2E, `/api/v2/...` routes, fail-closed auth, `DisplayBlock::Chart`, `make api-gate`.

## Immediate Next Step
1. **Wave 0 Criticals & `tantra-core` Phase A**: Tackle `tantra-exec 0004` + `tantra-adapters 0008` (end-to-end order idempotency), `tantra-market 0010` (WS resilience & token logging), `tantra-ledger 0014` (corporate-action scoping), and `tantra-core 0008` (`Money` currency safety).
2. **Active cross-repo roadmaps**: `docs/plans/0008`–`0010`, `0019`–`0023`, T3.3 remaining feeds (`upstox`/`fyers`/`angelone`).

## Operating Invariants
- Toolchain: `cargo 1.97.1` / `rustc 1.97.1`; edition 2024, `rust-version = "1.85"`; canonical build profile is always `prod` (`--profile prod` / `make prod`). Run heavy Cargo test suites one by one.
- Zero inline `#[test]` / `#[cfg(test)]` in `src/**/*.rs` (Parallel Test Directory Rule).
- Wire compatibility: `Price`/`Quantity` remain string-encoded decimals (`serde-with-str`); `-0.00` parses to `Decimal::ZERO` semantics.
- All `.agents/rules/`, `.agents/config/project-settings.json`, and `.agents/checklists/` are binding workspace-wide.
- Plan & Gap discipline: cite upstream `docs/{plans,gaps}/XXXX-*.md` at stubs/fallbacks; clean up completed docs and update indexes on closure.
