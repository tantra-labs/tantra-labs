# Gaps Index — `tantra-labs` (root)

Root-level gaps tracked per `.agents/rules/gap-tracking.md`. Each gap documents an individual
stub, duplicate, or missing feature at the workspace level. Gaps whose root cause lives in a
provider submodule are filed here for cross-repo visibility and cite the provider repo; the
provider repo's own `docs/gaps/README.md` is the implementation tracker.

## Open Gaps

| # | Title | Provider Repo / Scope | Filed |
|---|-------|-----------------------|-------|
| [0001](0001-market-broker-feed-stubs.md) | Real broker WS feed crates (`zerodha`, `upstox`, `fyers`, `angelone`, `dhan`) — **feature tracker**: the empty stub crates were removed 2026-11-13 (plan 0003); real feeds are re-added as real crates here when implemented (task T3.3) | `tantra-market` | 2026-11-12 |
| [0002](0002-market-feed-loaders-stubs.md) | Real `tantra-market-feed` / `tantra-market-loaders` implementations — **feature tracker**: the empty stub crates were removed 2026-11-13 (plan 0003); `MarketDataFeed` stays in `core`, lakehouse in `store` (task T3.4) | `tantra-market` | 2026-11-12 |
| [0006](0006-exec-angelone-stub.md) | `tantra-exec-angelone` is a 9-line stub — **decision taken 2026-11-13: implement** (kept as the home of the real SmartAPI 2.0 adapter, tracked by `tantra-exec` plan 0002, task T4.11) | `tantra-exec` | 2026-11-12 |

## Closed Gaps

| # | Title | Closed In |
|---|-------|-----------|
| 0003 | `tantra-runtime/tantra-indicators` exact duplicate of `tantra-market-indicators` | Deleted 2026-11-13 (plan 0003 Phase 2) — nothing imported it |
| 0004 | `tantra-runtime/tantra-runtime-feed` re-export shim over `tantra-market-store` | Absorbed into `tantra-runtime-api-rest::market_feed` module 2026-11-13 (plan 0003 Phase 2); shim crate deleted, all 25 import sites re-pointed |
| 0005 | `tantra-runtime-market` and `tantra-runtime-test-utils` empty stubs (legacy `honba` names) | Deleted 2026-11-13 (plan 0003 Phase 2) — declared-but-unused in `tantra-runtime-strategy` / `api-rest` |
| 0007 | Facade-crate convention inconsistent across Rust repos | Pinned as ADR + facades added (`tantra-market`, `tantra-exec`, `tantra-runtime`, `tantra-ffi`, `tantra-ui`) 2026-11-13 (plan 0003 Phase 4); see `docs/design/0001-crate-topology-audit-and-target.md` §4.2 |
| 0008 | `tantra-runtime` `workspace.dependencies` legacy honba aliases (`tantra-api`, `tantra-api-rest`, `tantra-backtest`, `tantra-actors`) | Removed 2026-11-13 (plan 0003 Phase 4) — nothing consumed them; `tantra-ffi` unused `tantra-market-*` deps removed in the same batch |

## Related

- [`docs/plans/README.md`](../plans/README.md) — the Implemented table records plan 0003
  (crate-topology consolidation) with its closing batch.
- [`docs/design/0001-crate-topology-audit-and-target.md`](../design/0001-crate-topology-audit-and-target.md)
  — full audit and target arrangement (incl. the pinned facade convention, §4.2).
