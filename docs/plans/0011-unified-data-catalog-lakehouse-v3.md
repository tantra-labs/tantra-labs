# 0011 — Unified Data Catalog & Git-Style Content-Addressed Lakehouse (v3)

**Status**: **Phases 1–3 Implemented 2026-11-18** — Phases 1–2 Python provider engine (`tantra-data` plan `0009` A–C: `ee802e9`/`398eeb7`/`d64c877`, gap `0025` closed, + atomic `trees/<hash>.json` export in `ManifestStore`); **Phase 3 Rust consumers & `tantra serve` Implemented 2026-11-18** (`tantra-market` gap `0008` closed: `ManifestResolver`, post-close compaction, `CatalogInstrumentMaster` `Decimal128(18, 4)`, OI & projection readers; `tantra-runtime` gap `0011` closed: `CatalogLoader` `data_ref` pinning + `reference/aliases` continuity + `(instrument_uid, ts)` RowGroup pruning + `load_v3_bars_grouped`, `BacktestRequest.data_ref` + `RunManifest.{data_commit_sha, data_as_of_ist}`, `AppState::has_lakehouse_v3` ignoring `catalog/.gitkeep` & `prepare_server` auto-detection). Phase 4 (legacy `*.NSE.parquet` & un-indexed `catalog/` deprecation) remains.  
**ADR**: [`docs/design/0004-data-catalog-lakehouse-layout.md`](../design/0004-data-catalog-lakehouse-layout.md)

## 0. Executive Summary & Objective

Replace `tantra-labs`'s four divergent on-disk data layouts (`*.NSE.parquet`, `catalog/{TF}/{EXCHANGE}/{SYMBOL}/{YYYY}.parquet`, Lakehouse v2 `ticks/`+`bars/`, and ad-hoc dated snapshot directories) with a single **two-layer hybrid lakehouse** specified in ADR `0004`:

1. **Logical categorization & grouping:** Canonical `domain/dataset/exchange/asset_class/timeframe/time_bucket` hierarchy backed by `instrument_uid` symbology aliases and relational classification/index-membership tags (`tantra-data` plan `0007`), with right-sized IST partitions and Parquet row-group sorting for both single-symbol and cross-sectional reads.
2. **Git-style CAS + versioned manifests:** Content-addressed immutable Parquet blobs (`objects/sha256/<2-char>/<hash>.parquet`), atomic staging commits (`commits/*.json`), named refs/tags (`refs/{heads,tags}/*`), an indexed `catalog.duckdb` manifest table, and nightly compaction that preserves reproducible snapshots.

## 1. Context & Gaps Covered

| Capability | Current State | Tracking Doc |
|---|---|---|
| Per-symbol & flat Parquet fragmentation | **Closed** — migrated to v3 hierarchy & CAS manifests | [`tantra-data` gap 0025 (closed)](../../tantra-data/docs/gaps/README.md#closed-gaps) |
| Option-chain intraday snapshots | Aligned to `date=YYYY-MM-DD` sorted by `(expiry, strike, option_type, as_of_ts)` | [`tantra-data` gap 0016 (closed)](../../tantra-data/docs/gaps/README.md#closed-gaps) |
| CAS object store, manifests, compaction & CLI | **Implemented** — `objects/sha256`, `refs/`, `commits/`, `trees/`, `views/`, `catalog.duckdb` + CLI | [`tantra-data` plan 0009](../../tantra-data/docs/plans/0009-unified-lakehouse-v3-and-cas-manifest.md) |
| Rust Lakehouse v3 + Decimal `instruments` schema | **Closed 2026-11-18** — `ManifestResolver`, post-close CAS compaction, `CatalogInstrumentMaster` `Decimal128(18, 4)`, OI & projection readers | [`tantra-market` gap 0008 (closed)](../../tantra-market/docs/gaps/README.md#closed-gaps) |
| Deterministic backtest data pinning & `tantra serve` v3 | **Closed 2026-11-18** — `CatalogLoader` `data_ref`/alias/RowGroup pruning, `BacktestRequest.data_ref`, `RunManifest` provenance, `prepare_server` v3 detection | [`tantra-runtime` gap 0011 (closed)](../../tantra-runtime/docs/gaps/README.md#closed-gaps) |

Dependencies & synergies:
- Pairs with [`tantra-data` plan 0007](../../tantra-data/docs/plans/0007-instrument-master-index-membership.md) (supplies `instruments`, `aliases`, NSE 4-level classification, index membership, and SEBI/AMFI cap buckets stored under `reference/`).
- Enforces ADR `0004` Zero-Floats (`Decimal128(18, 4)`), IST calendar boundaries, and point-in-time zero-lookahead invariants.

## 2. Component Specifications & Phases (Build Order)

1. **Phase 1 — Unified v3 Logical Taxonomy & Decimal Schema Alignment (`tantra-data` plan `0009` §P1 + gap `0025` + `tantra-market` gap `0008`):** ✅
   - Pin canonical logical paths (`market/`, `derivatives/`, `reference/`, `fundamentals/`, `disclosures/`, `derived/`) and right-sized time buckets (`year=YYYY` for 1D, `year=YYYY/month=MM` for intraday/OI/disclosures, `date=YYYY-MM-DD` IST for ticks & option chains).
   - Migrate `CatalogInstrumentMaster` numeric columns (`lot_size`, `tick_size`, `freeze_qty`, `strike`) from `Float64` to `Decimal128(18, 4)`.
   - Align `tantra-data` gap `0016` option-chain snapshots to `derivatives/option_chain/exchange={EX}/underlying={SYM}/date=YYYY-MM-DD/` sorted by `(expiry, strike, option_type, as_of_ts)`.
2. **Phase 2 — Git-Style CAS & `catalog.duckdb` Manifest Engine (`tantra-data` plan `0009` §P2–P3):** ✅
   - Implement CAS writer (`objects/sha256/<2-char>/<hash>.parquet`), staging commits (`refs/heads/staging/*` → atomic fast-forward to `refs/heads/main`), immutable `commits/<sha>.json` + `trees/<tree_hash>.json`, and `refs/tags/*`.
   - Build `catalog.duckdb` manifest + symbology alias resolution (`ticker → instrument_uid`) + coverage derivation from active commit manifests.
   - Ship `tantra-catalog` CLI (`status`, `log`, `tag`, `verify`, `compact`, `gc`, `materialize-views`) and one-shot migration tool from v1/v2 `data/catalog/` → v3 CAS.
3. **Phase 3 — Cross-Repo Rust Store, Backtest Pinning & `tantra serve` (`tantra-market` gap `0008` + `tantra-runtime` gap `0011`):** ✅
   - Extended `tantra-market-store` (`ManifestResolver`, post-close CAS compaction preserving pinned tags, `Decimal128(18, 4)` instrument snapshots, OI & all 9 projection readers with `views/` fallback on `main`).
   - Updated `tantra-runtime-backtest::CatalogLoader`, `NseTradingCalendar::from_data_root_at`, `BacktestRequest.data_ref` / `RunManifest.{data_commit_sha, data_as_of_ist}`, and `tantra serve` (`AppState::from_lakehouse_v3` + `prepare_server` v3→catalog→parquet detection ignoring `catalog/.gitkeep`).
4. **Phase 4 — Legacy Deprecation & Verification:** *(Remaining)*
   - Remove fallback readers for `*.NSE.parquet` and un-indexed `{TF}/{EX}/{SYM}` once `tantra-data/data/`, `tantra-examples/provision/`, and runtime tests pass exclusively on v3.

## 3. Verification & Acceptance Gates

- **Python (`tantra-data`):** Round-trip Arrow/Polars/DuckDB parity on `Decimal128(18, 4)`, atomic commit crash-safety & tree export (`test_cas_manifest.py` 13 passed), row-group pruning, compaction preservation of older tagged commits.
- **Rust (`tantra-market`, `tantra-runtime`):** Cross-language Parquet read/write parity (`tantra-market-store` `lakehouse_v3` 3 + `instruments` 5 + `chain_oi_tests` 10 + doctests 2), pinned REST + backtest determinism (`tantra-runtime-backtest` `lakehouse_v3_pinning` 3 + `catalog_tests` 1 + `catalog_and_settlement_tests` 7 + `calendar_tests` 8; `tantra-runtime-api` 28; `tantra-runtime-api-rest` `lakehouse_v3_serve` 1 + `openapi_conformance` 3 + `bootstrap` 16 + `market_data` 29 + `runs` 12 + `runs_cache` 3 + `runs_store` 13 + `journal_tests` 7 + `block_deals_tests` 4), live read-only smoke test against `tantra-data/data/`, `cargo fmt --check` + `clippy --workspace --all-targets --profile prod -- -D warnings` + `make prod` green.

## 4. Referenced Docs

- [`docs/design/0004-data-catalog-lakehouse-layout.md`](../design/0004-data-catalog-lakehouse-layout.md)
- [`tantra-data/docs/plans/0009-unified-lakehouse-v3-and-cas-manifest.md`](../../tantra-data/docs/plans/0009-unified-lakehouse-v3-and-cas-manifest.md)
- [`tantra-data/docs/gaps/README.md#closed-gaps`](../../tantra-data/docs/gaps/README.md#closed-gaps) (gaps `0016`, `0025`)
- [`tantra-market/docs/gaps/README.md#closed-gaps`](../../tantra-market/docs/gaps/README.md#closed-gaps) (gap `0008`)
- [`tantra-runtime/docs/gaps/README.md#closed-gaps`](../../tantra-runtime/docs/gaps/README.md#closed-gaps) (gap `0011`)
