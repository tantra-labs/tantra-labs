# HANDOFF — tantra-labs

**Status**: Chronological gap/plan sweep across Layers 0–6 — **All 5 critical design-review gaps closed (2026-11-25): `tantra-data` `0027`, `tantra-exec` `0004`, `tantra-adapters` `0008`, `tantra-market` `0010`, `tantra-ledger` `0014` + `tantra-core` `0003`, `0005` COMPLETE**; next **`tantra-core` `0008` (`0008-money-currency-safety.md`)**, then Wave 0 remaining (`tantra-runtime 0020/0028`, `tantra-risk 0006/0007`, `tantra-agent 0011/0012`).
Date: 2026-11-25 · Workspace: `tantra-labs`
Playbook: `docs/future-work-bottoms-up-build-order.md`

## Latest Batch — `tantra-ledger` Gap `0014` (Scoped & Idempotent Corporate Actions) COMPLETE 2026-11-25

- **`tantra-ledger-portfolio`**: Added required `instrument: InstrumentId` to every `CorporateAction` variant (`CORPORATE_ACTION_WIRE_VERSION = 2`, no `#[serde(default)]`); switched `Dividend::amount_per_share` and `record_dividend` to `Money` (major currency units, e.g. INR rupees) with account-currency guard; added deterministic SHA-256 `ActionId` (`(instrument, kind, ex_date)` + `new_instrument` on demerger) and `AccountState::applied_corporate_actions: BTreeSet<ActionId>`; filtered all lot and position adjustments by `instrument == *action.instrument()` and `entry_date < action.ex_date()`, ordered chronologically; allocated collision-free `{lot_id}:DM:{action_id}` demerger lot IDs.
- **Verification**: `cargo fmt --check`, `cargo clippy --workspace --all-targets --profile prod -- -D warnings`, sequential `--profile prod` tests (`corporate_action_scoping_tests` 7/7 incl. proptest, `per_lot_corporate_action_tests` 10/10, `unit_tests` 23/23, `apply_fill_tests` 7/7, `bracket_fifo_tests` 5/5, `clearing_calendar_injection_tests` 7/7, `repository_and_sizing_tests` 4/4), `wasm32-unknown-unknown` check, `make check`, `make prod`, plus downstream `tantra-runtime` (`make check` + `tantra-runtime-actors --all-targets`) and `tantra-ffi` (`cargo check --workspace --profile prod`) all passed.

## Prior batches (2026-11-06..2026-11-25, collapsed per `.agents/rules/handoff-hygiene.md`)

- **`tantra-market` Gap `0010` (Wave 0 #3, 2026-11-25)**: Redacted `Debug`/URL/error logging, `WsHandshake` token rotation, dead-connection deadline, integer-ms backoff, and `DhanFeed`/`KiteFeed` resubscribe + snapshot gap-fill (`1a2f55e`/`d13b66d`/`4287579`).
- **`tantra-adapters` `0008` & `tantra-exec` `0004` (Wave 0 #2, 2026-11-25)**: `OrderTag` Base32 wire tags, `BrokerError::OutcomeUnknown`, SOR reconciliation (`d8d7d4a`/`6e24975`/`d2ce1f1`) + Python `idempotency.py`, `AmbiguousOrderError`, 7-broker wire tag parity (`be51d9b`/`6ae89bf`).
- **`tantra-data` Gap `0027` (Wave 0 #1, 2026-11-25)**: `ManifestStore.commit` parent merge, `entries_for_commit`, `tantra-catalog repair --root` (`3b21c30`/`49ff21f`).
- **`tantra-core` Gaps `0003` & `0005` (2026-11-24..25)**: Private validated constructors + `PortError::Unavailable`/`AccountId` (`2ff789d`/`d03d8b5`, `ce32fe9`).

## Immediate Next Step
1. **`tantra-core` Gap `0008`** (`0008-money-currency-safety.md`).
2. **Wave 0 remaining**: `tantra-runtime` (`0020`, `0028`), `tantra-risk` (`0006`, `0007`), `tantra-agent` (`0011`, `0012`), UI (`ui-web 0079`, `ui 0008`), CI/lockfiles (root `0024`, `0025`).

## Operating Invariants
- Toolchain: `cargo 1.97.1` / `rustc 1.97.1`; edition 2024, `rust-version = "1.85"`; canonical build profile is always `prod` (`--profile prod` / `make prod`). Run heavy Cargo test suites one by one.
- Zero inline `#[test]` / `#[cfg(test)]` in `src/**/*.rs` (Parallel Test Directory Rule).
- Wire compatibility: `Price`/`Quantity` remain string-encoded decimals (`serde-with-str`); `-0.00` parses to `Decimal::ZERO` semantics.
- All `.agents/rules/`, `.agents/config/project-settings.json`, and `.agents/checklists/` are binding workspace-wide.
- Plan & Gap discipline: cite upstream `docs/{plans,gaps}/XXXX-*.md` at stubs/fallbacks; clean up completed docs and update indexes on closure.
