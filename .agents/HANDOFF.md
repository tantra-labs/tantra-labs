# HANDOFF — tantra-labs

**Status**: Layers 0–6 GREEN; **T12 (EE+)**, **T13 (`_kernel` removal)**, **T14 (Paper Exchange)**, **T15 (Data Provisioning)**, **T17 Phases 1–3 (Lakehouse v3)**, **T18 (Independent Fixes)**, and **T19 P0 (`T19.1` FIRE L1 engine)** complete.
**Date**: 2026-11-18 · **Workspace**: `tantra-labs` · **Task List**: [`docs/task-list-tracks-and-phases.md`](../docs/task-list-tracks-and-phases.md)

---

## Latest Batch — Track T19 Phase P0 (`T19.1` — `tantra-ledger`) Complete

Date: 2026-11-18. Implemented and verified P0 (`T19.1`) of [`docs/plans/0013-fire-planning-and-cashflow-platform.md`](../docs/plans/0013-fire-planning-and-cashflow-platform.md) (`Elicherla01/fireapp` L1–L6 incorporation; **`tantra-core` L0 untouched**):
- **`tantra-ledger` (`a735aa3`, Plan 0006 closed/retired)**:
  - `tantra-ledger-allocation::fire`: `Decimal` compounding engine, `FirePlanConfig`, `TaxDragConfig::india_finance_act_2025`, 5 archetypes (`Lean`, `Standard`, `Fat`, `Coast`, `Barista`), 3-bucket post-FIRE cashflow simulator, `SplitMix64` SoRR stress with 256-bin quantile table.
  - `tantra-ledger-allocation::fire_buckets`: `FireBucketKind`, `FireGlidepathPolicy`, `compute_bucket_drift`, `allocate_fire_bucket_discrete`.
  - `tantra-ledger-performance::swr`: `SwrEvaluationInput`, `SwrReport`, `evaluate_swr`.
  - Verification: 15 new tests (`fire_engine_tests.rs` incl. `fire_golden.json` + proptest, `fire_buckets_tests.rs`, `swr_tests.rs`) + all 83 existing tests in `allocation` & `performance` pass (`cargo clippy --workspace --all-targets --profile prod -- -D warnings` & `make prod` green; note 2 pre-existing unrelated `tantra-ledger-oms` `trade_manager_tests` failures untouched).
- **Remaining T19 Phases (P1–P6)**:
  - **P1 (`T19.2`)**: [`tantra-runtime` plan 0008](../tantra-runtime/docs/plans/0008-fire-planning-persistence-and-rest-api.md) (`tantra-runtime-api::fire`, `Profile.fire_plans`, `/api/{v1,v2}/planning/fire/*`).
  - **P2–P6 (`T19.3–T19.7`)**: `tantra-agent` `0015`, `tantra-ffi` `0005`, `tantra-ui-web` `0015`, `tantra-ui` `0009`, `tantra-strategies` `0004`.

---

## Previous Batch — Lakehouse v3 Phases 1–3 Complete (Track T17)

Date: 2026-11-18. Shipped and committed (`tantra-data` `dd4a953`, `tantra-market` `1d26fde`, `tantra-runtime` `dcc8ecf`, root `tantra-labs` `d66b891`):
- **T17.1–T17.2**: Logical v3 layout + CAS `objects/sha256` + `trees/<hash>.json` export + `catalog.duckdb` (`tantra-data` plan `0009`, gap `0025` closed).
- **T17.3**: Rust `ManifestResolver`, CAS compaction preserving tags, `CatalogInstrumentMaster` `Decimal128(18, 4)`, OI & projection readers (`tantra-market` gap `0008` closed).
- **T17.4**: `CatalogLoader` `data_ref`/`commit_sha` pinning, RowGroup stats pruning, `reference/aliases` continuity, `prepare_server` v3 detection (`tantra-runtime` gap `0011` closed).
- Remaining: Phase 4 legacy `catalog/` / `*.NSE.parquet` fallback removal.

---

## Completed Milestones (Collapsed Summary)

- **T0–T11** (Topology consolidation, Risk T1, Ledger T2, Adapters T4, Data T5, Agent/MCP T6, Runtime API T7, Strategies T8, Python Wheel T9, UI T10, Docs T11): Complete (`docs/task-list-tracks-and-phases.md`).
- **T12 (EE+ Strategy Platform)** · **T13 (`_kernel` Dismantled)** · **T14 (Paper Exchange)** · **T15 (Data Provisioning)** · **T18 (Independent Fixes T18.1–T18.6)**: Complete 2026-11-16/17.

---

## Immediate Next Step

1. **Track T19 (`docs/plans/0013`)** — commit P0 (`tantra-ledger` + root updates) if requested and start **Phase P1 (`T19.2` — `tantra-runtime` plan 0008 `tantra-runtime-api::fire`, `Profile.fire_plans`, `/planning/fire/*`)**.
2. **Other Active/Proposed Tracks**:
   - **T3.3 (`tantra-market/docs/gaps/0003`)**: remaining 3 broker WS feeds (`upstox`, `fyers`, `angelone`) + live credential check on `dhan`/`zerodha`.
   - **T16 (`docs/plans/0009`)**: Qullamaggie Multi-Market Swing Trading Platform.
   - **TSG (`docs/plans/0008`)**: `TradePlanner` P2 (`TradeManager`) + P3 presets (`core 0005` / `runtime 0006` / `agent 0014` / `ffi 0004` / `strategies 0003`).
   - **Screener (`docs/plans/0010`)**: P2–P9 (`runtime 0007`, `agent 0013`, `ui-web 0014`, `strategies 0002`).
   - **T17 Phase 4 (`docs/plans/0011`)**: Remove legacy `catalog/` & `*.NSE.parquet` fallback once transition window closes.
3. **Track `tantra-ui-web` local state**: `tantra-ui-web` lives at `tantra-ui-web/` as an independent git repo (not listed in root `.gitmodules`).

---

## Operating Invariants

- Toolchain: `cargo 1.97.1` / `rustc 1.97.1`; edition 2024, `rust-version = "1.85"`.
- Zero inline `#[test]` / `#[cfg(test)]` in `src/**/*.rs` (Parallel Test Directory Rule, `AGENTS.md` §3.2).
- Zero floats (`f32`/`f64`) in monetary/quantity/rate domain & wire types (`Decimal` / `serde-with-str` / `decimal.js` / `decimal.Decimal`).
- `.agents/rules/{subagent-discipline,no-recon,gap-tracking,handoff-hygiene}.md` are binding workspace-wide.
