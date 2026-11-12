# 0007 — Facade-crate convention is inconsistent across Rust workspaces

**Status**: open

**Provider repo**: all Rust workspaces (`tantra-ledger`, `tantra-agent`, `tantra-market`,
`tantra-exec`, `tantra-runtime`, `tantra-ffi`, `tantra-ui`)

## What's stubbed or hardcoded

Not a stub — a convention inconsistency. The ecosystem has two competing patterns for how a
consumer imports a bounded context:

- **Facade pattern** (used by `tantra-ledger`, `tantra-agent`): a repo-named crate
  (`tantra-ledger`, `tantra-agent`) re-exports the member crates; consumers write
  `use tantra_ledger::{oms, portfolio, journal}`.
- **No-facade pattern** (used by `tantra-market`, `tantra-exec`, `tantra-runtime`,
  `tantra-ffi`, `tantra-ui`): there is no repo-named crate; consumers import member crates
  directly (`use tantra_market_core::...`, `use tantra_runtime_api_rest::...`).

`tantra-runtime`'s `workspace.dependencies` even carries both: real names
(`tantra-runtime-api-rest`) and legacy aliases (`tantra-api-rest`, `tantra-api`,
`tantra-backtest`, `tantra-actors`).

## Why

Migration happened repo-by-repo: ledger and agent were ported with a facade crate first; later
repos kept the `-core`/member-crate convention from `honba`. No ADR was written to pin one
convention.

## How to close it

1. Write an ADR/design decision pinning the convention. Recommended: **repo-named facade crate for
   every multi-crate workspace** (matches `docs/design/0001-crate-topology-audit-and-target.md`
   §4.3; facade crates contain only re-exports).
2. Add facade crates (`tantra-market`, `tantra-exec`, `tantra-runtime`, `tantra-ffi`,
   `tantra-ui`) or, if the reverse decision is taken, retire the existing ledger/agent facades —
   but not both.
3. Remove the legacy aliases from `tantra-runtime/workspace.dependencies` (see gap 0008).
4. Verify each workspace: `cargo check --workspace --profile prod && make test`.

## Verification

A single documented convention; `docs/design/architecture.md` (and the new design doc) state it;
`grep` shows no consumer importing a member crate directly where the facade should be used (per the
pinned convention).
