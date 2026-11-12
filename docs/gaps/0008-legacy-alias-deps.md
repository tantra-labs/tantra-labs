# 0008 — `tantra-runtime` `workspace.dependencies` carries unused legacy honba aliases

**Status**: open

**Provider repo**: `tantra-runtime`

## What's stubbed or hardcoded

`tantra-runtime/Cargo.toml` `[workspace.dependencies]` still declares four legacy alias entries
that exist only to preserve old `honba` names:

```toml
tantra-api-rest = { path = "crates/tantra-runtime-api-rest" }
tantra-api = { path = "crates/tantra-runtime-api" }
tantra-backtest = { path = "crates/tantra-runtime-backtest" }
tantra-actors = { path = "crates/tantra-runtime-actors" }
```

No crate in any workspace depends on `tantra-api-rest`, `tantra-api`, `tantra-backtest`, or
`tantra-actors` as a dependency name (verified by grepping all `Cargo.toml` files). The real
canonical names (`tantra-runtime-api-rest`, `tantra-runtime-api`, `tantra-runtime-backtest`,
`tantra-runtime-actors`) are used everywhere instead.

## Why

Migration-era compatibility aliases from the `honba-*` → `tantra-*` rename. The consumers that
used the old names have long since been ported to the canonical names.

## How to close it

1. Delete the four legacy alias entries from `tantra-runtime/Cargo.toml` `[workspace.dependencies]`.
2. Confirm no `Cargo.toml` in any workspace references the aliases (`grep -rn "tantra-api\b\|tantra-api-rest\|tantra-backtest\|tantra-actors"` across `--include=Cargo.toml`).
3. Verify: `cd tantra-runtime && cargo check --workspace --profile prod && make test`.

## Verification

`cargo check --workspace --profile prod` passes with the aliases removed; grep shows no remaining
references to the legacy names.
