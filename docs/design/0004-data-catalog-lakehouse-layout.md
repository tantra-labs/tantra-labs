# 0004 — Unified Data Catalog & Git-Style Content-Addressed Lakehouse (v3)

**Status**: **Phases 1–3 Implemented 2026-11-18** (Root Plan `0011`; `tantra-data` gap `0025`, `tantra-market` gap `0008`, `tantra-runtime` gap `0011` closed) — Phase 4 (legacy fallback removal) and CAS locking/GC hardening (`tantra-data` `0027`–`0032`, root gap `0018`) remain open.  
**Scope**: Cross-repo market, derivatives, reference, and fundamentals storage contract across `tantra-data` (`ParquetCatalog`, DuckDB stores, `LakehouseBridgeExporter`, `CoverageLedger`), `tantra-market-store` (`Lakehouse`, `CatalogInstrumentMaster`, `ParquetOpenInterestStore`, projection readers), and `tantra-runtime-backtest` (`CatalogLoader`).  
**Inputs**: Verified against `tantra-market/crates/tantra-market-store/src/{lakehouse,dataset,instruments,open_interest}.rs`, `tantra-data/tantra_data/{adapters/parquet_catalog,service/bridge_exporter}.py`, `tantra-runtime/crates/tantra-runtime-backtest/src/catalog.rs`, and `tantra-data/docs/gaps/0016-intraday-option-chain-snapshot-lakehouse.md`.

---

## 1. Problem

`tantra-labs` currently mixes four incompatible physical storage conventions across its Rust and Python crates:

1. **Legacy flat equity files:** `data/<SYMBOL>.NSE.parquet`.
2. **Runtime per-symbol yearly trees:** `data/catalog/<TF>/<EXCHANGE>/<SYMBOL>/<YYYY>.parquet` (read by `tantra-runtime-backtest::CatalogLoader` and `tantra_data.adapters.parquet_catalog.ParquetCatalog`).
3. **Lakehouse v2 Hive trees:** `{root}/ticks/exchange={EX}/date=YYYY-MM-DD/{SYMBOL}[.part-NNNN].parquet` and `{root}/bars/timeframe={tf}/exchange={EX}/year=YYYY/month=MM/{SYMBOL}.parquet` (`tantra-market-store::lakehouse`).
4. **Dated snapshots & bridge projections:** `{root}/instruments/YYYY-MM-DD.parquet`, `{root}/open_interest/YYYY-MM-DD.parquet`, flat `{root}/catalog/{filings,corporate_actions,...}/*.parquet`, plus proposed `option_chain/{expiry}/YYYY-MM-DD-HHMM.parquet` in `tantra-data` gap `0016`.

In addition, naive per-instrument, per-day hierarchies (`<exchange>/<instrument>/year/month/day`) fail at production scale:

- **Small-file explosion:** 2,000 NSE symbols × 15 years × 250 trading days = **7.5M+ single-row files** for daily bars, or millions of 1–5 KB files for intraday bars and 5-minute option-chain snapshots. OS open/close latency and Parquet footer overhead dominate reads, and columnar dictionary/Zstd compression collapses.
- **Slow cross-sectional scans:** Putting `<instrument>` above `<date>` forces screeners (*"all NSE symbols on date D"* or *"Nifty 500 last 252 bars"*) to traverse thousands of subdirectories instead of reading one time-bucketed file.
- **Derivatives & corporate-identity churn:** Weekly/monthly `NFO`/`MCX` contracts create hundreds of thousands of ephemeral paths, while equity renames (`ZOMATO` → `ETERNAL`, demergers/mergers) fragment continuous history when paths are keyed solely by display ticker.
- **No snapshot pinning or safe compaction:** Compaction of live `part-NNNN.parquet` flushes risks mutating files referenced by historical backtests, violating research determinism. `CatalogInstrumentMaster` also currently stores numeric columns as `Float64`, drifting from the Zero-Floats (`Decimal128(18, 4)`) invariant.

---

## 2. Decision — Hybrid "Git CAS + Categorized Virtual Catalog" (Lakehouse v3)

We separate **Logical Categorization (how datasets are grouped, tagged, and queried)** from **Physical Storage (immutable Parquet blobs + versioned manifests)**.

### 2.1 Physical Storage Layer (Content-Addressed Object Store + Git-Like Refs)

```text
{root}/
├── objects/
│   └── sha256/
│       └── <ab>/
│           └── <ab...hash>.parquet      # Immutable, sorted, Zstd Parquet segments (target 8–64 MB)
├── refs/
│   ├── heads/
│   │   ├── main                         # Pointer to current canonical commit SHA
│   │   └── staging/<pipeline>           # Atomic ingestion branch fast-forwarded on verification
│   └── tags/
│       └── <tag>                        # Pinned snapshot (e.g., backtest-2026-11-17)
├── commits/
│   └── <commit_sha>.json                # parent_sha, tree_hash, created_at_utc, as_of_ist, schema_version, summary
├── catalog.duckdb                       # Indexed "tree" manifests + instrument symbology + multi-axis taxonomy
└── views/                               # Optional materialized/hardlinked Hive view for ad-hoc inspection
    └── ...
```

Key mechanics:
- **Immutable blobs:** Every written `.parquet` segment is immutable, Zstd-compressed, sorted by its dataset's clustering key, and stored under `objects/sha256/<2-char>/<sha256>.parquet`. Repeated segments across snapshots deduplicate naturally.
- **Manifest trees (`catalog.duckdb`):** Maps logical coordinates `(commit_sha, domain, dataset, exchange, asset_class, timeframe, time_bucket)` → `[object_sha, min_ts, max_ts, row_count, schema_version, sort_key]`.
- **Atomic commits & branches:** Ingestion pipelines write blobs, populate `staging/*`, validate invariants (Zero-Floats, monotonic timestamps, coverage parity), and atomically update `refs/heads/main`. Readers never observe partial writes.
- **Deterministic backtest pinning & safe compaction:** Backtests, `Dataset` sweeps, and research reports record the `commit_sha` (or tag) they read. Nightly compaction merges live `part-*` flush objects into clean monthly/yearly objects on a new commit without breaking older pinned tags until explicit `gc`.

### 2.2 Logical Categorization Hierarchy & Right-Sized Time Buckets

Every dataset lives at a canonical logical coordinate `domain/dataset/exchange={EX}/[asset_class={AC}/][timeframe={TF}/]<time_bucket>`:

| Domain | Dataset | Logical Partition Path | Physical File Bucket (IST) | Internal Sort Key (Row-Group Pruning) | Target Row Group / File Size |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `market` | `bars` (`1d`, `1w`, `1M`) | `market/bars/timeframe={tf}/exchange={EX}/asset_class={AC}` | `year=YYYY` | `(instrument_uid, ts)` | 100K rows / ~10–64 MB |
| `market` | `bars` (`1m`, `5m`, `15m`, `1h`) | `market/bars/timeframe={tf}/exchange={EX}/asset_class={AC}` | `year=YYYY/month=MM` | `(instrument_uid, ts)` | 100K rows / ~16–64 MB |
| `market` | `ticks` (L1/L2) | `market/ticks/exchange={EX}/asset_class={AC}` | `date=YYYY-MM-DD` | `(instrument_uid, exchange_ts)` | 100K rows / ~16–128 MB |
| `derivatives` | `option_chain` | `derivatives/option_chain/exchange={EX}/underlying={SYM}` | `date=YYYY-MM-DD` | `(expiry, strike, option_type, as_of_ts)` | 50K–100K rows / ~8–64 MB |
| `derivatives` | `open_interest`, `gex` | `derivatives/{oi,gex}/exchange={EX}` | `year=YYYY/month=MM` | `(underlying, expiry, as_of_ts)` | ~8–32 MB |
| `reference` | `instruments`, `aliases`, `corporate_actions`, `classification`, `index_membership`, `cap_buckets` | `reference/{dataset}` | `snapshot=YYYY` (or single manifest table) | `(instrument_uid, effective_date)` | ~1–16 MB |
| `fundamentals` | `statements`, `ratios`, `filings`, `macro`, `calendar`, `profiles` | `fundamentals/{dataset}` | `filing_year=YYYY` (or `fundamentals.duckdb` + Parquet projection) | `(instrument_uid, filing_date, period_end_date)` | ~4–32 MB |
| `disclosures` | `block_deals`, `delivery`, `institutional_flows`, `news`, `ipos` | `disclosures/{dataset}/exchange={EX}` | `year=YYYY/month=MM` | `(as_of_date, instrument_uid)` | ~4–32 MB |
| `derived` | `indicators`, `features`, `journals` | `derived/{dataset}/exchange={EX}` | `year=YYYY/month=MM` + `params_hash` | `(instrument_uid, ts)` | ~8–64 MB |

Why internal sort keys replace `<instrument>/year/month/day`:
- Sorting multi-instrument files by `(instrument_uid, ts)` with ~100K-row row groups allows Parquet readers (DuckDB, Polars, Rust `parquet` arrow reader) to use **row-group min/max column statistics** to skip 99% of a file when querying a single ticker, while letting cross-sectional screeners open **one** file per month/year instead of 2,000+ separate files.
- Rich groupings (*Nifty 500*, *IT sector*, *Mid-cap*, *Weekly Expiry Underlyings*) live as relational taxonomy & point-in-time membership tables in `catalog.duckdb` (`tantra-data` plan `0007`), never encoded in rigid filesystem directories.

### 2.3 Canonical Identity & Hard Invariants

1. **Immutable `instrument_uid` + Alias Resolution:** Historical series key off canonical `instrument_uid` (e.g., ISIN-backed or synthetic immutable ID for derivatives), with `reference/aliases` mapping `(exchange, ticker_symbol, series, valid_from, valid_to) -> instrument_uid`.
2. **Zero-Floats Everywhere:** All monetary, price, quantity, OI, IV, and Greek columns use Arrow `Decimal128(18, 4)` (including migrating `CatalogInstrumentMaster`'s current `Float64` `lot_size`/`tick_size`/`freeze_qty`/`strike` columns).
3. **IST Session Boundary:** All `date`, `year`, `month` partitions follow `Asia/Kolkata` (UTC+05:30); stored timestamp columns remain `Timestamp(Nanosecond, "UTC")` (or `Timestamp(Microsecond, "UTC")` normalized cleanly across Rust/Python).
4. **Point-in-Time / Zero-Lookahead:** Filings, corporate actions, option chains, and index membership carry explicit `as_of_ts` / `filing_date` / `[from_date, to_date)` bounds, reinforced at the catalog level by `commit_sha` pinning.

---

## 3. Migration Strategy

1. **Phase 1 — Unified Logical Hive v3 + Row-Group Sorting (No CAS required yet):**
   Standardize on-disk Hive paths (`market/`, `derivatives/`, `reference/`, `fundamentals/`, `disclosures/`), replace `Float64` in `CatalogInstrumentMaster`, align `tantra-data` gap `0016` away from per-5-minute files to `date=YYYY-MM-DD` sorted by `(expiry, strike, option_type, as_of_ts)`, and introduce dual-read fallback for legacy `data/catalog/{TF}/{EXCHANGE}/{SYMBOL}/` during transition.
2. **Phase 2 — Git-Style CAS + Manifest Engine (`catalog.duckdb`, `objects/`, `refs/`, `commits/`):**
   Add the content-addressed Parquet writer, staging commits, tagging, compaction CLI (`tantra-catalog`), and optional `views/` hardlink materializer in `tantra-data`.
3. **Phase 3 — Cross-Repo Rust Consumers & Legacy Removal:**
   Update `tantra-market-store` and `tantra-runtime-backtest::CatalogLoader` to resolve partitions via manifest/commit pinning, record `data_commit_sha` in backtest run journals, and retire the legacy `catalog/{TF}/{EX}/{SYM}` and flat `*.NSE.parquet` layouts.

---

## 4. Referenced Plans & Gaps

- Root Master Plan: [`docs/plans/0011-unified-data-catalog-lakehouse-v3.md`](../plans/0011-unified-data-catalog-lakehouse-v3.md)
- Provider Plan (`tantra-data`): [`tantra-data/docs/plans/0009-unified-lakehouse-v3-and-cas-manifest.md`](../../tantra-data/docs/plans/0009-unified-lakehouse-v3-and-cas-manifest.md)
- Legacy fragmentation & option-chain alignment (`tantra-data`, both closed): [`tantra-data/docs/gaps/README.md#closed-gaps`](../../tantra-data/docs/gaps/README.md#closed-gaps) (gaps `0016`, `0025`); open CAS/GC gaps in [`tantra-data/docs/gaps/README.md`](../../tantra-data/docs/gaps/README.md) (`0027`–`0032`)
- Rust Lakehouse v3 store reader/writer (`tantra-market`): [`tantra-market/docs/gaps/0008-lakehouse-v3-manifest-and-snapshot-reader.md`](../../tantra-market/docs/gaps/0008-lakehouse-v3-manifest-and-snapshot-reader.md)
- Backtest commit pinning (`tantra-runtime`): [`tantra-runtime/docs/gaps/0011-backtest-catalog-manifest-pinning.md`](../../tantra-runtime/docs/gaps/0011-backtest-catalog-manifest-pinning.md)
