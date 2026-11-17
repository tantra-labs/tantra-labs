# 0011 — Unified Data Catalog & Git-Style Content-Addressed Lakehouse (v3)

**Status**: Proposed — 2026-11-17  
**ADR**: [`docs/design/0004-data-catalog-lakehouse-layout.md`](../design/0004-data-catalog-lakehouse-layout.md)

## 0. Executive Summary & Objective

Replace `tantra-labs`'s four divergent on-disk data layouts (`*.NSE.parquet`, `catalog/{TF}/{EXCHANGE}/{SYMBOL}/{YYYY}.parquet`, Lakehouse v2 `ticks/`+`bars/`, and ad-hoc dated snapshot directories) with a single **two-layer hybrid lakehouse** specified in ADR `0004`:

1. **Logical categorization & grouping:** Canonical `domain/dataset/exchange/asset_class/timeframe/time_bucket` hierarchy backed by `instrument_uid` symbology aliases and relational classification/index-membership tags (`tantra-data` plan `0007`), with right-sized IST partitions and Parquet row-group sorting for both single-symbol and cross-sectional reads.
2. **Git-style CAS + versioned manifests:** Content-addressed immutable Parquet blobs (`objects/sha256/<2-char>/<hash>.parquet`), atomic staging commits (`commits/*.json`), named refs/tags (`refs/{heads,tags}/*`), an indexed `catalog.duckdb` manifest table, and nightly compaction that preserves reproducible snapshots.

## 1. Context & Gaps Covered

| Capability | Current State | Tracking Doc |
|---|---|---|
| Per-symbol & flat Parquet fragmentation | `tantra-data/data/` mixes `*.NSE.parquet`, `catalog/{1D,5M}/NSE/<SYM>/<YYYY>.parquet`, and flat `catalog/<projection>/*.parquet` | [`tantra-data` gap 0025](../../tantra-data/docs/gaps/0025-legacy-catalog-layout-and-flat-parquet-fragmentation.md) |
| Option-chain intraday snapshots | Planned `option_chain/{expiry}/YYYY-MM-DD-HHMM.parquet` would create thousands of small files; realigned to `date=YYYY-MM-DD` sorted by `(expiry, strike, option_type, as_of_ts)` | [`tantra-data` gap 0016](../../tantra-data/docs/gaps/0016-intraday-option-chain-snapshot-lakehouse.md) |
| CAS object store, manifests, compaction & CLI | No `objects/sha256`, `refs/`, `commits/`, or `catalog.duckdb` manifest engine exists | [`tantra-data` plan 0009](../../tantra-data/docs/plans/0009-unified-lakehouse-v3-and-cas-manifest.md) |
| Rust Lakehouse v3 + Decimal `instruments` schema | `tantra-market-store::lakehouse` only covers v2 `ticks/`+`bars/`; `CatalogInstrumentMaster` reads/writes `Float64`; `ParquetOpenInterestStore` uses separate `{root}/open_interest/` | [`tantra-market` gap 0008](../../tantra-market/docs/gaps/0008-lakehouse-v3-manifest-and-snapshot-reader.md) |
| Deterministic backtest data pinning | `tantra-runtime-backtest::CatalogLoader` walks raw `{TF}/{EX}/{SYM}` directories without commit/ref pinning | [`tantra-runtime` gap 0011](../../tantra-runtime/docs/gaps/0011-backtest-catalog-manifest-pinning.md) |

Dependencies & synergies:
- Pairs with [`tantra-data` plan 0007](../../tantra-data/docs/plans/0007-instrument-master-index-membership.md) (supplies `instruments`, `aliases`, NSE 4-level classification, index membership, and SEBI/AMFI cap buckets stored under `reference/`).
- Enforces ADR `0004` Zero-Floats (`Decimal128(18, 4)`), IST calendar boundaries, and point-in-time zero-lookahead invariants.

## 2. Component Specifications & Phases (Build Order)

1. **Phase 1 — Unified v3 Logical Taxonomy & Decimal Schema Alignment (`tantra-data` plan `0009` §P1 + gap `0025` + `tantra-market` gap `0008`):**
   - Pin canonical logical paths (`market/`, `derivatives/`, `reference/`, `fundamentals/`, `disclosures/`, `derived/`) and right-sized time buckets (`year=YYYY` for 1D, `year=YYYY/month=MM` for intraday/OI/disclosures, `date=YYYY-MM-DD` IST for ticks & option chains).
   - Migrate `CatalogInstrumentMaster` numeric columns (`lot_size`, `tick_size`, `freeze_qty`, `strike`) from `Float64` to `Decimal128(18, 4)`.
   - Align `tantra-data` gap `0016` option-chain snapshots to `derivatives/option_chain/exchange={EX}/underlying={SYM}/date=YYYY-MM-DD/` sorted by `(expiry, strike, option_type, as_of_ts)`.
2. **Phase 2 — Git-Style CAS & `catalog.duckdb` Manifest Engine (`tantra-data` plan `0009` §P2–P3):**
   - Implement CAS writer (`objects/sha256/<2-char>/<hash>.parquet`), staging commits (`refs/heads/staging/*` → atomic fast-forward to `refs/heads/main`), immutable `commits/<sha>.json`, and `refs/tags/*`.
   - Build `catalog.duckdb` manifest + symbology alias resolution (`ticker → instrument_uid`) + coverage derivation from active commit manifests.
   - Ship `tantra-catalog` CLI (`status`, `log`, `tag`, `verify`, `compact`, `gc`, `materialize-views`) and one-shot migration tool from v1/v2 `data/catalog/` → v3 CAS.
3. **Phase 3 — Cross-Repo Rust Store & Backtest Pinning (`tantra-market` gap `0008` + `tantra-runtime` gap `0011`):**
   - Extend `tantra-market-store` to resolve partition objects by `commit_sha` / `ref` (with read-only Hive fallback during deprecation) and compact live `TickRecorder` flushes (`part-NNNN.parquet`) into sorted CAS objects after market close.
   - Update `tantra-runtime-backtest::CatalogLoader` and run journals to accept `--data-ref` / `commit_sha` and persist the exact `data_commit_sha` in backtest artifacts.
4. **Phase 4 — Legacy Deprecation & Verification:**
   - Remove fallback readers for `*.NSE.parquet` and un-indexed `{TF}/{EX}/{SYM}` once `tantra-data/data/`, `tantra-examples/provision/`, and runtime tests pass exclusively on v3.

## 3. Verification & Acceptance Gates

- **Python (`tantra-data`):** Round-trip Arrow/Polars/DuckDB parity on `Decimal128(18, 4)`, atomic commit crash-safety test, row-group pruning benchmark (single-symbol scan vs universe scan), compaction preservation of older tagged commits, and `make -C tantra-data check`.
- **Rust (`tantra-market`, `tantra-runtime`):** Golden cross-language Parquet read parity (Python CAS writer → Rust `Lakehouse` / `CatalogLoader`), `Decimal128(18, 4)` round-trip for instruments/OI/bars/ticks, and `cargo test --profile prod` + `clippy -D warnings` clean.

## 4. Referenced Docs

- [`docs/design/0004-data-catalog-lakehouse-layout.md`](../design/0004-data-catalog-lakehouse-layout.md)
- [`tantra-data/docs/plans/0009-unified-lakehouse-v3-and-cas-manifest.md`](../../tantra-data/docs/plans/0009-unified-lakehouse-v3-and-cas-manifest.md)
- [`tantra-data/docs/gaps/0025-legacy-catalog-layout-and-flat-parquet-fragmentation.md`](../../tantra-data/docs/gaps/0025-legacy-catalog-layout-and-flat-parquet-fragmentation.md)
- [`tantra-data/docs/gaps/0016-intraday-option-chain-snapshot-lakehouse.md`](../../tantra-data/docs/gaps/0016-intraday-option-chain-snapshot-lakehouse.md)
- [`tantra-market/docs/gaps/0008-lakehouse-v3-manifest-and-snapshot-reader.md`](../../tantra-market/docs/gaps/0008-lakehouse-v3-manifest-and-snapshot-reader.md)
- [`tantra-runtime/docs/gaps/0011-backtest-catalog-manifest-pinning.md`](../../tantra-runtime/docs/gaps/0011-backtest-catalog-manifest-pinning.md)
