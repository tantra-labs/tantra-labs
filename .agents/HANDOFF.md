# HANDOFF — tantra-labs

**Status**: Chronological gap/plan sweep across Layers 0–6 — **Wave 0 #1 (`tantra-data` `0027`), Wave 0 #2 (`tantra-exec` `0004`, `tantra-adapters` `0008`), Wave 0 #3 (`tantra-market` `0010`) + `tantra-core` gaps `0003`, `0005` COMPLETE 2026-11-25**; next **`tantra-ledger` `0014` (`0014-corporate-action-scoping.md`)**, then **`tantra-core` `0008` (`0008-money-currency-safety.md`)** and Wave 0 serving/risk items (`tantra-runtime 0020`, `0028`).
Date: 2026-11-25 · Workspace: `tantra-labs`
Playbook: `docs/future-work-bottoms-up-build-order.md`

## Latest Batch — `tantra-market` Gap `0010` (WsClient Resilience & Token Redaction) COMPLETE 2026-11-25

- **`tantra-market-core`**: Added `WsHandshake` / `WsConnectTarget` / `OnConnectedHook` / `TokenProvider` / `StaticTokenProvider` ports; `redact_url` + `sanitize_error_text` + redacted `Debug` impls scrubbing query tokens/userinfo/headers from logs and errors; `tokio::time::Instant` dead-connection deadline in `run_ws_loop` (`dead_connection_timeout_secs`); pure integer-ms `compute_backoff_duration` (floor >= 1 s, exponential cap) with sequential `Reconnecting { attempt }` -> `Failed` transitions (`max_reconnect_attempts`); bounded outgoing queue + `connect_bounded`; lock-free `WsHealthSnapshot` (`connected`, `last_heartbeat`, ping/pong `rtt_ms`, `dropped_count`, `reconnect_count`).
- **`tantra-market-{dhan,zerodha}`**: Wired dynamic `DhanHandshake`/`KiteHandshake` over `TokenProvider` (plus `update_access_token` rotation), automatic `on_connected` subscription replay + REST `fetch_snapshot` gap-fill reconciliation via `ReconnectionManager`, and live `WsHealthSnapshot` counters into `FeedHealth`.
- **Verification**: `cargo fmt --check`, `cargo clippy --workspace --all-targets --profile prod -- -D warnings`, sequential `--profile prod` tests (`ws_client_resilience` 6/6, `enricher` 2/2, `symbol_mapper` 2/2, `dhan` `protocol_tests` 10/10 & `reconnect_tests` 1/1, `zerodha` `protocol_tests` 8/8 & `reconnect_tests` 1/1), `make check`, `make prod`, plus downstream `tantra-runtime` `make check` and `tantra-ffi` `cargo check --workspace --profile prod` all passed.

## Prior batches (2026-11-06..2026-11-25, collapsed per `.agents/rules/handoff-hygiene.md`)

- **`tantra-adapters` Gap `0008` & `tantra-exec` Gap `0004` (Wave 0 #2, 2026-11-25)**: Rust `OrderTag` Base32 wire tags, `BrokerError::OutcomeUnknown`, SOR reconciliation (`d8d7d4a`/`6e24975`/`d2ce1f1`) + Python `idempotency.py`, `idempotent=False` non-retry, `AmbiguousOrderError`, and 7-broker wire tag + `get_orders()` parity (`be51d9b`/`6ae89bf`).
- **`tantra-data` Gap `0027` (Wave 0 #1, 2026-11-25)**: `ManifestStore.commit` parent merge, `entries_for_commit`, `tantra-catalog repair --root`, `lakehouse-v3-snapshot-contract.md` (`3b21c30`/`49ff21f`).
- **`tantra-core` Gaps `0003` & `0005` (2026-11-24..25)**: Private validated constructors + `PortError::Unavailable`/`AccountId` (`2ff789d`/`d03d8b5`, `ce32fe9`).

## Immediate Next Step
1. **`tantra-ledger` Gap `0014`** (`0014-corporate-action-scoping.md`) and **`tantra-core` Gap `0008`** (`0008-money-currency-safety.md`).
2. **Wave 0 remaining**: `tantra-runtime` (`0020`, `0028`), `tantra-risk` (`0006`, `0007`), `tantra-agent` (`0011`, `0012`), UI (`ui-web 0079`, `ui 0008`), CI/lockfiles (root `0024`, `0025`).

## Operating Invariants
- Toolchain: `cargo 1.97.1` / `rustc 1.97.1`; edition 2024, `rust-version = "1.85"`; canonical build profile is always `prod` (`--profile prod` / `make prod`). Run heavy Cargo test suites one by one.
- Zero inline `#[test]` / `#[cfg(test)]` in `src/**/*.rs` (Parallel Test Directory Rule).
- Wire compatibility: `Price`/`Quantity` remain string-encoded decimals (`serde-with-str`); `-0.00` parses to `Decimal::ZERO` semantics.
- All `.agents/rules/`, `.agents/config/project-settings.json`, and `.agents/checklists/` are binding workspace-wide.
- Plan & Gap discipline: cite upstream `docs/{plans,gaps}/XXXX-*.md` at stubs/fallbacks; clean up completed docs and update indexes on closure.
