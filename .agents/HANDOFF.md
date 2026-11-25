# HANDOFF — tantra-labs

**Status**: Chronological gap/plan sweep across Layers 0–6 — **Wave 0 #1 (`tantra-data` `0027`), Wave 0 #2a (`tantra-exec` `0004`), & Wave 0 #2b (`tantra-adapters` `0008`) + `tantra-core` gaps `0003`, `0005` COMPLETE 2026-11-25**; next **Wave 0 #3 (`tantra-market` `0010` — WS client resilience & token logging)**, then `tantra-ledger 0014`, `tantra-core 0008`.
Date: 2026-11-25 · Workspace: `tantra-labs`
Playbook: `docs/future-work-bottoms-up-build-order.md`

## Latest Batch — `tantra-adapters` Gap `0008` (Python Order Idempotency & No POST Replay) COMPLETE 2026-11-25

- **`tantra_adapters/common/idempotency.py`**: Added `encode_order_tag` (matching `tantra-exec-core::OrderTag` Base32 golden vectors `AERUKZ4JVNGN5AJDIVTQ` / `AERUKZ4JVNGN5AJDIVTYTK6N54`), `decode_uuid_tag`, `tag_matches_client_order_id`, `normalize_order_status`, and typed `AmbiguousOrderError`.
- **Fail-Closed Wire Tagging & Transport Non-Retry**: All 7 REST adapters (`zerodha`, `upstox`, `angelone`, `dhan`, `fyers`, `iifl`, `kotak`) fail closed on absent `client_order_id`/`tag`, emit broker-specific tag fields, and implement `get_orders()`/`find_order_by_client_id()`/`reconcile_order()`. `PooledHttpTransport` (`max_attempts=1`), `RetryTransport` (no `429` retry), and `BaseRestAdapter._request` (refresh without `401` replay) honor `idempotent=False`; post-send IO timeouts/`502`/`504` raise `AmbiguousOrderError`.
- **Verification**: `ruff check .`, `ruff format --check .`, `mypy --strict` (25 source files), `pytest -q tests` (203/203 incl. `test_idempotency_and_replay.py`), and downstream `tantra-strategies` `test_intrabar_bracket_fills.py` all passed.

## Prior batches (2026-11-06..2026-11-25, collapsed per `.agents/rules/handoff-hygiene.md`)

- **`tantra-exec` Gap `0004` (Idempotent Submit & `OutcomeUnknown`, 2026-11-25)**: `OrderTag` Base32 wire tags, `BrokerError::OutcomeUnknown`, `find_by_client_order_id` SOR reconciliation, downstream `tantra-runtime-strategy` dispatch mapping (`d8d7d4a` / `6e24975` / `d2ce1f1`).
- **`tantra-data` Gap `0027` (Lakehouse v3 Snapshot Commits, 2026-11-25)**: `ManifestStore.commit` parent merge, `entries_for_commit`, `tantra-catalog repair --root`, `lakehouse-v3-snapshot-contract.md` (`3b21c30` / `49ff21f`).
- **`tantra-core` Gaps `0003` & `0005` (2026-11-24..25)**: Private validated constructors + `PortError::Unavailable`/`AccountId` (`2ff789d`/`d03d8b5`, `ce32fe9`).

## Immediate Next Step
1. **Wave 0 Criticals & `tantra-core` Phase A**: Implement `tantra-market 0010` (WS client resilience & token logging), then `tantra-ledger 0014`, and `tantra-core 0008`.
2. **Active cross-repo roadmaps**: `docs/plans/0008`–`0010`, `0019`–`0023`, T3.3 remaining feeds (`upstox`/`fyers`/`angelone`).

## Operating Invariants
- Toolchain: `cargo 1.97.1` / `rustc 1.97.1`; edition 2024, `rust-version = "1.85"`; canonical build profile is always `prod` (`--profile prod` / `make prod`). Run heavy Cargo test suites one by one.
- Zero inline `#[test]` / `#[cfg(test)]` in `src/**/*.rs` (Parallel Test Directory Rule).
- Wire compatibility: `Price`/`Quantity` remain string-encoded decimals (`serde-with-str`); `-0.00` parses to `Decimal::ZERO` semantics.
- All `.agents/rules/`, `.agents/config/project-settings.json`, and `.agents/checklists/` are binding workspace-wide.
- Plan & Gap discipline: cite upstream `docs/{plans,gaps}/XXXX-*.md` at stubs/fallbacks; clean up completed docs and update indexes on closure.
