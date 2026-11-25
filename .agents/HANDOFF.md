# HANDOFF — tantra-labs

**Status**: Chronological gap/plan sweep across Layers 0–6 — **Wave 0 #1 (`tantra-data` `0027`) & Wave 0 #2a (`tantra-exec` `0004` idempotent submit & `OutcomeUnknown`) + `tantra-core` gaps `0003`, `0005` COMPLETE 2026-11-25**; next **Wave 0 #2b (`tantra-adapters` `0008` — Python order idempotency & no POST replay)**, then `tantra-market 0010`, `tantra-ledger 0014`, `tantra-core 0008`.
Date: 2026-11-25 · Workspace: `tantra-labs`
Playbook: `docs/future-work-bottoms-up-build-order.md`

## Latest Batch — `tantra-exec` Gap `0004` (Idempotent Submit & `OutcomeUnknown`) COMPLETE 2026-11-25

- **`tantra-exec-core`**: Added `tag.rs` (`OrderTag`, `DecodedOrderTag`, `OrderTagRegistry` — RFC 4648 uppercase Base32 lossless 26-char `wire_tag_full()` for Upstox & 20-char 96-bit `wire_tag_20()` for Zerodha/AngelOne), `BrokerError::OutcomeUnknown { client_order_id, message }`, `OrderSnapshot.tag` + `matches_client_order_id`, and `BrokerExecutor::find_by_client_order_id` (plus `RateLimitedBroker`, `RiskGatedExecutor`, `MockBrokerExecutor`, and `PaperExecutor` support).
- **Adapters & Router**: Zerodha/Upstox/AngelOne now emit Base32 correlation wire tags, classify post-send timeouts/EOF/stream drops on `place_order`/`place_iceberg_order` as `OutcomeUnknown` (keeping `is_connect()` as `Transport`), and recover client IDs on `fetch_order_book`; `ResilientRouter::route_order` reconciles via `find_by_client_order_id` on `OutcomeUnknown` and never fails over or trips the circuit breaker. Updated downstream `tantra-runtime-strategy/src/dispatch.rs`.
- **Verification**: `cargo fmt --check`, `cargo clippy --workspace --all-targets --profile prod -- -D warnings`, all `tantra-exec` test targets run sequentially (`--profile prod`), `make prod` in `tantra-exec` & `tantra-runtime`, `tantra-runtime-strategy` tests, and `tantra-agent` `make check` all passed.

## Prior batches (2026-11-06..2026-11-25, collapsed per `.agents/rules/handoff-hygiene.md`)

- **`tantra-data` Gap `0027` (Lakehouse v3 Snapshot Commits, 2026-11-25)**: `ManifestStore.commit` parent merge (`entries_replace_only=False` default), `entries_for_commit`, `tantra-catalog repair --root`, `docs/design/lakehouse-v3-snapshot-contract.md` (`3b21c30` / `49ff21f`).
- **`tantra-core` Gap `0005` (Typed Port Errors & `AccountId`, 2026-11-25)**: Added `PortErrorKind`/`PortError::Unavailable`, typed `cancel`, `PortfolioAccount.account_id: AccountId`, L0–L5 `prod`/`wasm32`/OpenAPI checks green (`ce32fe9`).
- **`tantra-core` Gap `0003` (Value-Object Invariants, 2026-11-24)**: Private validated constructors + `#[serde(try_from)]` invariants on `Price`, `Quantity`, `PriceBand`, `InstrumentId`, `Instrument` (`2ff789d` / L0–L5 `d03d8b5`).

## Immediate Next Step
1. **Wave 0 Criticals & `tantra-core` Phase A**: Implement `tantra-adapters 0008` (idempotency token/algo tag, never auto-retry POSTs, refresh without replay on 401 — closes root gap `0010` adapter pair), then `tantra-market 0010`, `tantra-ledger 0014`, and `tantra-core 0008`.
2. **Active cross-repo roadmaps**: `docs/plans/0008`–`0010`, `0019`–`0023`, T3.3 remaining feeds (`upstox`/`fyers`/`angelone`).

## Operating Invariants
- Toolchain: `cargo 1.97.1` / `rustc 1.97.1`; edition 2024, `rust-version = "1.85"`; canonical build profile is always `prod` (`--profile prod` / `make prod`). Run heavy Cargo test suites one by one.
- Zero inline `#[test]` / `#[cfg(test)]` in `src/**/*.rs` (Parallel Test Directory Rule).
- Wire compatibility: `Price`/`Quantity` remain string-encoded decimals (`serde-with-str`); `-0.00` parses to `Decimal::ZERO` semantics.
- All `.agents/rules/`, `.agents/config/project-settings.json`, and `.agents/checklists/` are binding workspace-wide.
- Plan & Gap discipline: cite upstream `docs/{plans,gaps}/XXXX-*.md` at stubs/fallbacks; clean up completed docs and update indexes on closure.
