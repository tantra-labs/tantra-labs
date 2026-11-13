# 0002 — Real `tantra-market` feed / loaders implementations

**Status**: open — **feature tracker**. The empty stub crates were removed 2026-11-13
(root plan 0003 Phase 1); the real `MarketDataFeed` trait stays in `tantra-market-core` and the
lakehouse in `tantra-market-store`. This gap tracks the real feed/loaders implementations
(task T3.4).

**Provider repo**: `tantra-market`

## What's stubbed or hardcoded

- `tantra-market-feed` — `src/lib.rs` is one doc-comment line. The actual market-data feed
  abstractions (`MarketDataFeed` trait, `CoalescingTickBuffer`, `ReconnectionManager`, `WsClient`,
  `Subscription`, `SymbolMapper`) all live in `tantra-market-core`.
- `tantra-market-loaders` — `src/lib.rs` is one doc-comment line. Lakehouse/history loading
  (Parquet loaders, dataset readers) lives in `tantra-market-store`.

## Why

`tantra-market-feed` and `tantra-market-loaders` were scaffolded from the old `honba-me-feed`
and `honba-me-store` split (see `docs/ddd-conflict.md` Conflict #4), but the split was later
resolved by putting the feed traits in `tantra-market-core` and the lakehouse in
`tantra-market-store`. The two scaffolded crates were never deleted, so the workspace carries two
empty crates whose names imply they own functionality that actually lives elsewhere.

## How to close it

1. Remove `tantra-market-feed` and `tantra-market-loaders` from `tantra-market/Cargo.toml`
   `members` and `workspace.dependencies`.
2. Verify no workspace imports `tantra_market_feed` / `tantra_market_loaders` in code
   (verified: none do).
3. Update `tantra-market/docs/gaps/README.md` index if a per-repo gap was filed there.
4. Verify: `cd tantra-market && cargo check --workspace --profile prod` and `make test`.

## Verification

`cargo check --workspace --profile prod` passes without the crates; `tantra-market-core` remains
the single home of the feed trait; `tantra-market-store` remains the single home of the lakehouse.
