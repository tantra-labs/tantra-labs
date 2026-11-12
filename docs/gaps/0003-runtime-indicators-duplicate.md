# 0003 — `tantra-runtime/tantra-indicators` is an exact duplicate of `tantra-market-indicators`

**Status**: open

**Provider repo**: `tantra-runtime`

## What's stubbed or hardcoded

`tantra-runtime/crates/tantra-indicators/src/lib.rs` is a single comment line:
`// Stub crate: tantra-indicators`. It is registered as a member of the `tantra-runtime`
workspace, and `tantra-runtime/workspace.dependencies` maps `tantra-indicators` to it.

Meanwhile the real indicator engine is `tantra-market/crates/tantra-market-indicators`
(4,635 lines of `src`, real indicators). Nothing in any workspace imports
`tantra_indicators` in code (verified: `grep -rn "tantra_indicators" --include=*.rs` returns
nothing outside the stub's own directory).

## Why

A legacy `honba-ya-indicators` / `honba-me-indicators` naming collision: the runtime workspace was
scaffolded with a stub of the old name while the market workspace received the real ported crate.
The stub was never removed.

## How to close it

1. Remove `tantra-runtime/crates/tantra-indicators` directory and its `members` +
   `workspace.dependencies` entry in `tantra-runtime/Cargo.toml`.
2. Confirm no crate in `tantra-runtime` or elsewhere depends on `tantra-indicators`
   (verified: only the stub's own `Cargo.toml` listed it; `tantra-runtime-api-rest`'s
   `Cargo.toml` references it only via the workspace alias).
3. Keep `tantra-market-indicators` as the single canonical indicator crate.
4. Verify: `cd tantra-runtime && cargo check --workspace --profile prod` and `make test`.

## Verification

`cargo check --workspace --profile prod` passes without the stub; `tantra-market-indicators`
remains the single indicator crate in the ecosystem.
