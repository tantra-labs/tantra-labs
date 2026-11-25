# HANDOFF — tantra-labs

**Status**: Wave 0 & chronological gap sweep across Layers 0–6 — **5 critical gaps closed (`tantra-data` `0027`, `tantra-exec` `0004`, `tantra-adapters` `0008`, `tantra-market` `0010`, `tantra-ledger` `0014`) + `tantra-core` `0003`/`0005` + `tantra-runtime` Gap `0020` (with `tantra-ui` CLI `--allow-insecure-bind`) + Zed Python/Rust diagnostics across `tantra-strategies`/`tantra-ffi`/`tantra-market` COMPLETE**; next **`tantra-runtime` `0028`**, **`tantra-core` `0008`**, and Wave 0 remaining (`tantra-risk 0006/0007`, `tantra-agent 0011/0012`).
Date: 2026-11-25 · Workspace: `tantra-labs`
Playbook: `docs/future-work-bottoms-up-build-order.md`

## Latest Batch — `tantra-runtime` Gap `0020` (Fail-Closed Bind & CORS) + Zed Diagnostics COMPLETE 2026-11-25

- **`tantra-runtime` & `tantra-ui` (Gap `0020`, Wave 0 #4)**: Added `StartupError`, `ALLOW_INSECURE_BIND_ENV` (`TANTRA_ALLOW_INSECURE_BIND`), `ServeConfig.allow_insecure_bind`, `ApiConfig.allow_insecure_bind`, `validate_bind_security`, and `tantra serve --allow-insecure-bind`; fail-closed non-loopback bind without auth across `prepare_server`, `serve_with_shutdown`, `run_server_blocking`, `serve_with_config`, and `run_tape_serve` (replacing `non_loopback_warning` free helper); `api_router_with_config` returns `Result<Router, StartupError>` cleanly on unreadable/invalid token files; `cors_layer` returns `None` when origins are empty and includes `AUTHORIZATION` in `allow_headers` when auth is enabled.
- **Zed Diagnostics Resolved (`tantra-strategies`, `tantra-ffi`, `tantra-market`)**:
  - `tantra-strategies` (`3e8482f`): widened `conftest.py` `make_bars`/`basket_bars` to `Sequence[...]`; `basedpyright`, `ruff`, `pytest` green.
  - `tantra-ffi` (`3a9f45d`): explicit `__init__.pyi` submodule re-exports, `to_decimal(int)` widening, `Indicator.update` typing under `if not TYPE_CHECKING:`, `sum(..., Decimal(0))` & NaN `.is_nan()` cleanup across 96 files; `basedpyright` (`0 errors, 0 warnings`), `ruff`, `pytest`, and downstream `cargo check --workspace --profile prod` green.
  - `tantra-market`: verified `adr_pct_unit` (`8/8` `--profile prod`) clean (`AdrPct` already exported).
- **Gap `0020` Verification (`--profile prod` sequential)**: `cors` (3/3), `bootstrap_tests` (10/10), `bootstrap` (18/18), `auth_fail_closed` (7/7), `inproc_router` (1/1), `serve` (1/1), `paper_serve` (4/4), `make check`, `make prod`; `tantra-ui` `fmt --check`, `clippy --all-targets --profile prod -- -D warnings`, `tantra-cli` `unit_tests` (46/46), `make prod`; `tantra-ffi` `cargo check --workspace --profile prod`.

## Prior batches (2026-11-06..2026-11-25, collapsed per `.agents/rules/handoff-hygiene.md`)

- **`tantra-ledger` `0014` (Wave 0, 2026-11-25)**: `CORPORATE_ACTION_WIRE_VERSION = 2`, required `instrument`, rupee `Money` dividends, SHA-256 `ActionId` idempotency, `{lot_id}:DM:{action_id}` demerger lots.
- **`tantra-market` `0010` (Wave 0 #3, 2026-11-25)**: Redacted `Debug`/URL/error logging, `WsHandshake` token rotation, dead-connection deadline, integer-ms backoff, and `DhanFeed`/`KiteFeed` resubscribe + snapshot gap-fill (`1a2f55e`/`d13b66d`/`4287579`).
- **`tantra-adapters` `0008` & `tantra-exec` `0004` (Wave 0 #2, 2026-11-25)**: `OrderTag` Base32 wire tags, `BrokerError::OutcomeUnknown`, SOR reconciliation (`d8d7d4a`/`6e24975`/`d2ce1f1`) + Python `idempotency.py`, `AmbiguousOrderError`, 7-broker wire tag parity (`be51d9b`/`6ae89bf`).
- **`tantra-data` `0027` (Wave 0 #1, 2026-11-25)**: `ManifestStore.commit` parent merge, `entries_for_commit`, `tantra-catalog repair --root` (`3b21c30`/`49ff21f`).
- **`tantra-core` `0003` & `0005` (2026-11-24..25)**: Private validated constructors + `PortError::Unavailable`/`AccountId` (`2ff789d`/`d03d8b5`, `ce32fe9`).

## Immediate Next Step
1. **`tantra-runtime` Gap `0028`** (`0028-strategy-crate-concrete-executor-and-nested-runtime.md`) — Wave 0 #4 remaining.
2. **`tantra-core` Gap `0008`** (`0008-money-currency-safety.md`) & **`0004`** (`0004-wire-schema-evolution-gate.md`).
3. **Wave 0 remaining**: `tantra-risk` (`0006`, `0007`), `tantra-agent` (`0011`, `0012`), UI (`ui-web 0079`, `ui 0008`), CI/lockfiles (root `0024`, `0025`).

## Operating Invariants
- Toolchain: `cargo 1.97.1` / `rustc 1.97.1`; edition 2024, `rust-version = "1.85"`; canonical build profile is always `prod` (`--profile prod` / `make prod`). Run heavy Cargo test binaries one by one sequentially.
- Zero inline `#[test]` / `#[cfg(test)]` in `src/**/*.rs` (Parallel Test Directory Rule).
- Wire compatibility: `Price`/`Quantity` remain string-encoded decimals (`serde-with-str`); `-0.00` parses to `Decimal::ZERO` semantics.
- All `.agents/rules/`, `.agents/config/project-settings.json`, and `.agents/checklists/` are binding workspace-wide.
- Plan & Gap discipline: cite upstream `docs/{plans,gaps}/XXXX-*.md` at stubs/fallbacks; clean up completed docs and update indexes on closure.
