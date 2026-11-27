# HANDOFF — tantra-labs

**Status**: Wave 0 & chronological gap sweep across Layers 0–6 — **5 critical gaps closed (`tantra-data` `0027`, `tantra-exec` `0004`, `tantra-adapters` `0008`, `tantra-market` `0010`, `tantra-ledger` `0014`) + `tantra-core` `0003`/`0005` + `tantra-runtime` Gap `0020` (with `tantra-ui` CLI `--allow-insecure-bind`) + Zed Python/Rust diagnostics across `tantra-strategies`/`tantra-ffi`/`tantra-market` COMPLETE**; plus **`tantra-runtime` `0028`** (2026-11-26) and **`tantra-core` `0008`** + root `0014` unchecked-`Money` follow-ups (2026-11-27); next **`tantra-core` `0004`**, and Wave 0 remaining (`tantra-risk 0006/0007`, `tantra-agent 0011/0012`).
Date: 2026-11-27 · Workspace: `tantra-labs`
Playbook: `docs/future-work-bottoms-up-build-order.md`

## Latest Batch — `tantra-core` Gap `0008` (currency-safe `Money`) + root `0014` unchecked sums COMPLETE 2026-11-27

- **Core** (`a1448f5`, `688da93`): private `Money` fields + `amount()`/`currency()`, `notional(price, qty, currency)`, `checked_add`/`checked_sub` → `CoreError::CurrencyMismatch`, `quantize`, `Money::zero`, `Exchange::currency()` (all venues INR), fallible `FeeBreakdown::total()`/`FillReport::with_fee_breakdown()`.
- **Callers**: accessor migration in risk `b7d41af`, ledger `161cc79`, exec `fe6a954`, agent `46497a9`, runtime `ce2942c`, ui `61df2e5`; checked sums in risk `5f5ef22` (sizing refuses mixed equity currencies), ledger `fbe6cf7` (`MetricsError::CurrencyMismatch`, `Result` calendars), runtime `da0934e` (journal 422 on mismatch, backtest venue-currency fees) and `25868fe` (snapshot `Result`; `PortfolioActor::new` now seeds `initial_cash`), exec `76abc88` / ui `997dd80` (venue currency), agent `d3dbeac` (`run_simulation` → `Result`).
- **Also fixed**: tantra-agent `--all-features` errors (`1a564b7`), runtime trade-journal edge-score v2 assertion (`3bd42ce`).
- **Known, not fixed**: tantra-ui `tantra-cli` `test_run_ask_backtest_synthesis` needs a Python with the `tantra` wheel (shells out to generated Python); `tantra-market-store` → `tantra-agent-analytics` upward L2→L3 edge (root gap 0015).

## Prior batches (2026-11-06..2026-11-26, collapsed per `.agents/rules/handoff-hygiene.md`)

- **`tantra-runtime` `0028` (2026-11-26)**: `ZerodhaKiteAdapter::with_executor(Arc<dyn BrokerExecutor>, Handle)`, no owned runtime or credentials, dependency-rule guard (`49647d0`).
- **`tantra-runtime` `0020` + Zed diagnostics (Wave 0 #4, 2026-11-25)**: fail-closed non-loopback bind (`StartupError`, `--allow-insecure-bind`), CORS `AUTHORIZATION` with auth (`769075f`); `tantra-strategies` `3e8482f`, `tantra-ffi` `3a9f45d` typing cleanups.
- **`tantra-ledger` `0014` (Wave 0, 2026-11-25)**: `CORPORATE_ACTION_WIRE_VERSION = 2`, required `instrument`, rupee `Money` dividends, SHA-256 `ActionId` idempotency, `{lot_id}:DM:{action_id}` demerger lots.
- **`tantra-market` `0010` (Wave 0 #3, 2026-11-25)**: Redacted `Debug`/URL/error logging, `WsHandshake` token rotation, dead-connection deadline, integer-ms backoff, and `DhanFeed`/`KiteFeed` resubscribe + snapshot gap-fill (`1a2f55e`/`d13b66d`/`4287579`).
- **`tantra-adapters` `0008` & `tantra-exec` `0004` (Wave 0 #2, 2026-11-25)**: `OrderTag` Base32 wire tags, `BrokerError::OutcomeUnknown`, SOR reconciliation (`d8d7d4a`/`6e24975`/`d2ce1f1`) + Python `idempotency.py`, `AmbiguousOrderError`, 7-broker wire tag parity (`be51d9b`/`6ae89bf`).
- **`tantra-data` `0027` (Wave 0 #1, 2026-11-25)**: `ManifestStore.commit` parent merge, `entries_for_commit`, `tantra-catalog repair --root` (`3b21c30`/`49ff21f`).
- **`tantra-core` `0003` & `0005` (2026-11-24..25)**: Private validated constructors + `PortError::Unavailable`/`AccountId` (`2ff789d`/`d03d8b5`, `ce32fe9`).

## Immediate Next Step
1. **`tantra-core` Gap `0004`** (`0004-wire-schema-evolution-gate.md`).
2. **Wave 0 remaining**: `tantra-risk` (`0006`, `0007`), `tantra-agent` (`0011`, `0012`), UI (`ui-web 0079`, `ui 0008`), CI/lockfiles (root `0024`, `0025`).

## Operating Invariants
- Toolchain: `cargo 1.97.1` / `rustc 1.97.1`; edition 2024, `rust-version = "1.85"`; canonical build profile is always `prod` (`--profile prod` / `make prod`). Run heavy Cargo test binaries one by one sequentially.
- Zero inline `#[test]` / `#[cfg(test)]` in `src/**/*.rs` (Parallel Test Directory Rule).
- Wire compatibility: `Price`/`Quantity` remain string-encoded decimals (`serde-with-str`); `-0.00` parses to `Decimal::ZERO` semantics.
- All `.agents/rules/`, `.agents/config/project-settings.json`, and `.agents/checklists/` are binding workspace-wide.
- Plan & Gap discipline: cite upstream `docs/{plans,gaps}/XXXX-*.md` at stubs/fallbacks; clean up completed docs and update indexes on closure.
