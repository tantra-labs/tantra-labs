# HANDOFF — tantra-labs

**Status**: Wave 0 & chronological gap sweep across Layers 0–6 — **5 critical gaps closed (`tantra-data` `0027`, `tantra-exec` `0004`, `tantra-adapters` `0008`, `tantra-market` `0010`, `tantra-ledger` `0014`) + `tantra-core` `0003`/`0005` + `tantra-runtime` Gap `0020` (with `tantra-ui` CLI `--allow-insecure-bind`) + Zed Python/Rust diagnostics across `tantra-strategies`/`tantra-ffi`/`tantra-market` COMPLETE**; plus **`tantra-runtime` `0028`** (2026-11-26); next **`tantra-core` `0008`**/`0004`, and Wave 0 remaining (`tantra-risk 0006/0007`, `tantra-agent 0011/0012`).
Date: 2026-11-26 · Workspace: `tantra-labs`
Playbook: `docs/future-work-bottoms-up-build-order.md`

## Latest Batch — `tantra-runtime` Gap `0028` (Strategy crate executor injection) COMPLETE 2026-11-26

- `ZerodhaKiteAdapter::with_executor(Arc<dyn BrokerExecutor>, Handle, cash)` replaces `with_credentials`/`with_base_url`; no credentials, no owned `Runtime`, no `tantra-exec-zerodha` in `tantra-runtime-strategy` `[dependencies]` (`49647d0`).
- Sync bridge `block_on_executor`: `block_in_place` on multi-thread runtimes, typed refusal (not a panic) on current-thread runtimes. The composition root must keep the injected runtime alive; no composition root wires a live Zerodha adapter yet.
- `AngelOneSmartApiAdapter` `Debug` redacted; zeroize still waits on `tantra-exec` gap `0007`.
- Verified: `dependency_rules` (2, checked red with zerodha re-added), `zerodha_wire_tests` (8), `dispatch_tests` (7), `clippy --profile prod -D warnings`, `cargo check --workspace --profile prod`, `make -C tantra-runtime prod`.

## Prior batches (2026-11-06..2026-11-25, collapsed per `.agents/rules/handoff-hygiene.md`)

- **`tantra-runtime` `0020` + Zed diagnostics (Wave 0 #4, 2026-11-25)**: fail-closed non-loopback bind (`StartupError`, `--allow-insecure-bind`), CORS `AUTHORIZATION` with auth (`769075f`); `tantra-strategies` `3e8482f`, `tantra-ffi` `3a9f45d` typing cleanups.
- **`tantra-ledger` `0014` (Wave 0, 2026-11-25)**: `CORPORATE_ACTION_WIRE_VERSION = 2`, required `instrument`, rupee `Money` dividends, SHA-256 `ActionId` idempotency, `{lot_id}:DM:{action_id}` demerger lots.
- **`tantra-market` `0010` (Wave 0 #3, 2026-11-25)**: Redacted `Debug`/URL/error logging, `WsHandshake` token rotation, dead-connection deadline, integer-ms backoff, and `DhanFeed`/`KiteFeed` resubscribe + snapshot gap-fill (`1a2f55e`/`d13b66d`/`4287579`).
- **`tantra-adapters` `0008` & `tantra-exec` `0004` (Wave 0 #2, 2026-11-25)**: `OrderTag` Base32 wire tags, `BrokerError::OutcomeUnknown`, SOR reconciliation (`d8d7d4a`/`6e24975`/`d2ce1f1`) + Python `idempotency.py`, `AmbiguousOrderError`, 7-broker wire tag parity (`be51d9b`/`6ae89bf`).
- **`tantra-data` `0027` (Wave 0 #1, 2026-11-25)**: `ManifestStore.commit` parent merge, `entries_for_commit`, `tantra-catalog repair --root` (`3b21c30`/`49ff21f`).
- **`tantra-core` `0003` & `0005` (2026-11-24..25)**: Private validated constructors + `PortError::Unavailable`/`AccountId` (`2ff789d`/`d03d8b5`, `ce32fe9`).

## Immediate Next Step
1. **`tantra-core` Gap `0008`** (`0008-money-currency-safety.md`) & **`0004`** (`0004-wire-schema-evolution-gate.md`).
2. **Wave 0 remaining**: `tantra-risk` (`0006`, `0007`), `tantra-agent` (`0011`, `0012`), UI (`ui-web 0079`, `ui 0008`), CI/lockfiles (root `0024`, `0025`).

## Operating Invariants
- Toolchain: `cargo 1.97.1` / `rustc 1.97.1`; edition 2024, `rust-version = "1.85"`; canonical build profile is always `prod` (`--profile prod` / `make prod`). Run heavy Cargo test binaries one by one sequentially.
- Zero inline `#[test]` / `#[cfg(test)]` in `src/**/*.rs` (Parallel Test Directory Rule).
- Wire compatibility: `Price`/`Quantity` remain string-encoded decimals (`serde-with-str`); `-0.00` parses to `Decimal::ZERO` semantics.
- All `.agents/rules/`, `.agents/config/project-settings.json`, and `.agents/checklists/` are binding workspace-wide.
- Plan & Gap discipline: cite upstream `docs/{plans,gaps}/XXXX-*.md` at stubs/fallbacks; clean up completed docs and update indexes on closure.
