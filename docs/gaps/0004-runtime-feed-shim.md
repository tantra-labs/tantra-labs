# 0004 — `tantra-runtime/tantra-runtime-feed` is a re-export shim over `tantra-market-store`

**Status**: open

**Provider repo**: `tantra-runtime`

## What's stubbed or hardcoded

`tantra-runtime/crates/tantra-runtime-feed/src/lib.rs` (30 lines) is a pure re-export shim:
it does `pub use tantra_market_store::{...}` for the Parquet lakehouse types (`Lakehouse`,
`TickRecorder`, `Dataset`, `ParquetTickStore`, `ReportWriter`, etc.), plus re-export modules
`ports`, `import`, and `wire`.

It is consumed by `tantra-runtime-api-rest` (and declared in `tantra-runtime-strategy`'s
workspace deps), which **also** already depends directly on `tantra-market-store`.

## Why

During the `honba-*` → `tantra-*` migration the old `tantra_runtime_feed` import path was kept
alive so that `tantra-runtime-api-rest` and its ~28 test/`src` files would not need an import
rename in the same change that moved the lakehouse into `tantra-market-store`. The shim has
outlived that purpose.

## How to close it

Two options (plan 0003 Phase 2 decides; either closes this gap):

- **Option A (absorb)** — move the `pub use tantra_market_store::*` re-exports into a small
  `market_feed` module inside `tantra-runtime-api-rest` (or the crate that still needs the old
  path), update imports from `tantra_runtime_feed::X` to the new path, delete the shim crate and
  its `members`/`workspace.dependencies` entry.
- **Option B (keep as facade)** — document `tantra-runtime-feed` as an intentional facade crate
  (part of the facade convention from gap 0007) and leave it as-is. This closes the gap in the
  sense that it is no longer an *accidental* shim — it is a declared compatibility facade.

## Verification

`cd tantra-runtime && cargo check --workspace --profile prod && make test`; for Option A, grep
confirms no `tantra_runtime_feed::` imports remain outside the deleted crate.
