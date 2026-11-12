# 0005 — `tantra-runtime-market` and `tantra-runtime-test-utils` are empty stubs

**Status**: open

**Provider repo**: `tantra-runtime`

## What's stubbed or hardcoded

- `tantra-runtime/crates/tantra-runtime-market/src/lib.rs` — one comment line:
  `// Stub crate: tantra-me-market`. Nothing imports `tantra_runtime_market` in code.
- `tantra-runtime/crates/tantra-runtime-test-utils/src/lib.rs` — one comment line:
  `// Stub crate: tantra-testing`. Nothing imports `tantra_runtime_test_utils` in code.

Both are registered in `tantra-runtime/Cargo.toml` `members` and `workspace.dependencies`.
`tantra-runtime-api-rest` lists `tantra-runtime-market` in its own `[dependencies]` via
`tantra-runtime-market.workspace = true`, but never uses it.

## Why

Legacy `honba-me-market` and `honba-testing` scaffold leftovers. The actual runtime
market-repository functionality lives in `tantra-runtime-persistence` and
`tantra-runtime-strategy`; the actual test helpers live in `tantra-runtime-testing`.

## How to close it

1. Remove both crates' directories and their `members` + `workspace.dependencies` entries in
   `tantra-runtime/Cargo.toml`.
2. Remove the now-dangling `tantra-runtime-market.workspace = true` line from
   `tantra-runtime-api-rest/Cargo.toml`.
3. Keep `tantra-runtime-testing` as the single test-helper crate.
4. Verify: `cd tantra-runtime && cargo check --workspace --profile prod && make test`.

## Verification

`cargo check --workspace --profile prod` passes without the stubs; grep confirms no
`tantra_runtime_market` / `tantra_runtime_test_utils` imports remain anywhere.
