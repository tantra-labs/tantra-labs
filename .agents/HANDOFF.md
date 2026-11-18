# HANDOFF — tantra-labs

**Status**: Layers 0–6 GREEN; **T12 (EE+)**, **T13 (`_kernel` removal)**, **T14 (Paper Exchange)**, **T15 (Data Provisioning)**, **T17 Phases 1–3 (Lakehouse v3)**, and **T18 (Independent Fixes)** complete.
**Date**: 2026-11-18 · **Workspace**: `tantra-labs` · **Task List**: [`docs/task-list-tracks-and-phases.md`](../docs/task-list-tracks-and-phases.md)

---

## Latest Batch — Track T19 Architecture Plans (`Elicherla01/fireapp`, docs-only)

Date: 2026-11-18. Analyzed `https://github.com/Elicherla01/fireapp/tree/main` ("FIRE Works") and authored full-stack L1–L6 architecture plans (no `src/` changes yet; **`tantra-core` L0 untouched**):
- **Master Plan**: [`docs/plans/0013-fire-planning-and-cashflow-platform.md`](../docs/plans/0013-fire-planning-and-cashflow-platform.md) (Track **T19**, Phases **P0–P6** / `T19.1–T19.7`).
- **Per-Repo Plans (7)**:
  - **L1 (Primary Domain Owner)**: [`tantra-ledger/docs/plans/0006-fire-bucket-glidepath-and-swr-metrics.md`](../tantra-ledger/docs/plans/0006-fire-bucket-glidepath-and-swr-metrics.md) (`tantra-ledger-allocation::{fire, fire_buckets}` Zero-Float `Decimal` compounding, 5 archetypes, 3-bucket cashflow & glidepath, `SplitMix64` SoRR stress + `tantra-ledger-performance::swr`, `wasm32`-clean; reuses `tantra-core::{Money, Currency}` & `SplitMix64` read-only).
  - **L3A**: [`tantra-runtime/docs/plans/0008-fire-planning-persistence-and-rest-api.md`](../tantra-runtime/docs/plans/0008-fire-planning-persistence-and-rest-api.md) (`tantra-runtime-api::fire` `schemars` DTOs, `Profile.fire_plans` CAS, `/api/{v1,v2}/planning/fire/*`, live ledger/Greeks/Finance Act 2025 tax hydration, OpenAPI regen).
  - **L3B**: [`tantra-agent/docs/plans/0015-fire-planning-chat-and-mcp-tools.md`](../tantra-agent/docs/plans/0015-fire-planning-chat-and-mcp-tools.md) (`fire_simulate`, `fire_portfolio_check` in `tantra-agent-chat-tools` + `tantra-agent-mcp` via `tantra-ledger-allocation`, Rule R4 compliant).
  - **L4**: [`tantra-ffi/docs/plans/0005-fire-planning-python-bindings.md`](../tantra-ffi/docs/plans/0005-fire-planning-python-bindings.md) (`tantra.wire.fire` codegen + `tantra.fire` PyO3 over `tantra-ledger-allocation::fire`).
  - **L5B**: [`tantra-ui-web/docs/plans/0015-fire-works-simulator-and-cashflow-ui.md`](../tantra-ui-web/docs/plans/0015-fire-works-simulator-and-cashflow-ui.md) (`vyapaar-ui-web-wasm` via `tantra-ledger-allocation`, `/fire`, Workspace tab, Portfolio `FIRE Runway` tab, dark/gold theme).
  - **L5A**: [`tantra-ui/docs/plans/0009-fire-planning-workstation-cli-tui-wasm.md`](../tantra-ui/docs/plans/0009-fire-planning-workstation-cli-tui-wasm.md) (`tantra-ui-core`, Leptos CSR `AppRoute::Fire`, `tantra fire` CLI, TUI tab via `tantra-ledger-allocation`).
  - **L6**: [`tantra-strategies/docs/plans/0004-fire-cashflow-theta-and-compounding-templates.md`](../tantra-strategies/docs/plans/0004-fire-cashflow-theta-and-compounding-templates.md) (`manifests/fire_barbell_basket.toml` + `fire_bridge.py`).
- **Indexes & Task List Updated**: root + all 7 plan `docs/plans/README.md` tables + `docs/task-list-tracks-and-phases.md`.

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

1. **Track T19 (Proposed, `docs/plans/0013`)** — await user approval to commit plan docs and/or begin **Phase P0 (`T19.1` — `tantra-ledger` plan 0006 `tantra-ledger-allocation::fire`)**.
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
