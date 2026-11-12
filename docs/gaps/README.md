# Gaps Index — `tantra-labs` (root)

Root-level gaps tracked per `.agents/rules/gap-tracking.md`. Each gap documents an individual
stub, duplicate, or missing feature at the workspace level. Gaps whose root cause lives in a
provider submodule are filed here for cross-repo visibility and cite the provider repo; the
provider repo's own `docs/gaps/README.md` is the implementation tracker.

## Open Gaps

| # | Title | Provider Repo / Scope | Filed |
|---|-------|-----------------------|-------|
| [0001](0001-market-broker-feed-stubs.md) | `tantra-market` broker WS feed crates (`zerodha`, `upstox`, `fyers`, `angelone`, `dhan`) are empty stubs | `tantra-market` | 2026-11-12 |
| [0002](0002-market-feed-loaders-stubs.md) | `tantra-market-feed` and `tantra-market-loaders` are empty stubs; the real `MarketDataFeed` trait lives in `tantra-market-core` | `tantra-market` | 2026-11-12 |
| [0003](0003-runtime-indicators-duplicate.md) | `tantra-runtime/tantra-indicators` is an exact duplicate of the real `tantra-market-indicators` and nothing imports it | `tantra-runtime` | 2026-11-12 |
| [0004](0004-runtime-feed-shim.md) | `tantra-runtime/tantra-runtime-feed` is a 30-line re-export shim over `tantra-market-store` | `tantra-runtime` | 2026-11-12 |
| [0005](0005-runtime-stub-crates.md) | `tantra-runtime-market` and `tantra-runtime-test-utils` are empty stubs (legacy `honba` names) | `tantra-runtime` | 2026-11-12 |
| [0006](0006-exec-angelone-stub.md) | `tantra-exec-angelone` is a near-empty stub (9 lines, no broker logic) | `tantra-exec` | 2026-11-12 |
| [0007](0007-facade-crate-convention.md) | Facade-crate convention is inconsistent across Rust repos (ledger/agent have facades; market/exec/runtime/ffi/ui do not) | all Rust workspaces | 2026-11-12 |
| [0008](0008-legacy-alias-deps.md) | `tantra-runtime` `workspace.dependencies` still carries unused legacy honba aliases (`tantra-api`, `tantra-api-rest`, `tantra-backtest`, `tantra-actors`) | `tantra-runtime` | 2026-11-12 |

## Closed Gaps

| # | Title | Closed In |
|---|-------|-----------|
| — | *(none yet)* | — |

## Related

- [`docs/plans/0003-crate-topology-consolidation.md`](../plans/0003-crate-topology-consolidation.md)
  — the phased plan that executes these gaps.
- [`docs/design/0001-crate-topology-audit-and-target.md`](../design/0001-crate-topology-audit-and-target.md)
  — full audit and target arrangement.
