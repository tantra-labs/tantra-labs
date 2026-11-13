# 0006 — `tantra-exec-angelone` is a near-empty stub

**Status**: open — **decision (root plan 0003 Phase 3, 2026-11-13): implement**, not remove.
  Angel One execution is on the near-term roadmap (`tantra-exec/docs/plans/0002`
  "Milestone 3 Adapter Completion", Phase 1 = `tantra-exec/docs/gaps/0001`); the stub crate is
  kept as the home of the real SmartAPI 2.0 adapter and filled by that plan's implementation.

**Provider repo**: `tantra-exec`

## What's stubbed or hardcoded

`tantra-exec/crates/tantra-exec-angelone/src/lib.rs` is 9 lines — essentially empty, with only
`tantra-core`, `serde`, `thiserror` in `[dependencies]` and no broker/order logic. Compare the
real siblings `tantra-exec-zerodha` (1,549 lines) and `tantra-exec-upstox` (1,333 lines).

## Why

The Angel One SmartAPI execution adapter was scaffolded during migration but never implemented
(the architecture requires ACL translation between Angel One's JSON SmartAPI wire format and
`tantra-core` canonical order types). Nothing imports `tantra_exec_angelone` in code.

## How to close it

1. Either **implement** the Angel One execution adapter (ACL: `angelone_json` ↔ `tantra_core`,
   per `docs/ddd-conflict.md` Conflict #6), or
2. **Remove** `tantra-exec-angelone` from `tantra-exec/Cargo.toml` `members` and
   `workspace.dependencies` until it is actually implemented (re-adding an empty stub is
   forbidden).
3. Update `tantra-exec/docs/plans/README.md` or `docs/gaps/README.md` index as appropriate.
4. Verify: `cd tantra-exec && cargo check --workspace --profile prod && make test`.

## Verification

`cargo check --workspace --profile prod` passes; the crate is either real (clippy-clean, has
`tests/`) or absent.
