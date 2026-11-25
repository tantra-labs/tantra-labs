# 0019 — Calendar, instrument master and corporate-action single sources

**Status**: open
**Filed**: 2026-11-23 — workspace design review (root plan 0021) · **Kind**: duplication · **Severity**: medium
**Plan**: [0021](../plans/0021-workspace-design-review-2026-11.md)

## What's stubbed or hardcoded

Three reference-data domains each have several sources. Calendars: `tantra-core` `TradingCalendar` (fixed UTC offset, one unvalidated session per date, no day navigation) versus `tantra-market-finance` `MarketCalendar`, `tantra-agent-chat-tools` `CalendarReader`, `tantra-runtime-api-rest` `RuntimeNseCalendar`, `tantra-data` `trading_holidays.py` and `tantra-ffi/python/tantra/calendar.py`; two holiday sources (static tables versus data-ingested). `PriceBand` is also duplicated in `tantra-market-finance/src/rules.rs:15`. Instrument master: the market normalizer indexes by bare symbol and empty-string token, `tantra-data` keeps `instrument_aliases`, and adapters leak raw broker identifiers with no master. Corporate actions: the ledger applies them without instrument scope and non-idempotently (critical), `tantra-data` has its own `corporate_actions.py`, and adjustment lives in the normalizer.

| Repo tracker | Severity | What it covers |
|---|---|---|
| ~~[tantra-ledger 0014](../../tantra-ledger/docs/gaps/README.md#closed-gaps)~~ | ~~critical~~ ✅ closed 2026-11-25 | Scoped `CorporateAction`, `ActionId` idempotency, rupee `Money` dividends, unique demerger lot IDs |
| [tantra-market 0015](../../tantra-market/docs/gaps/0015-instrument-master-keying.md) | high | Instrument master keyed by bare symbol / empty token |
| [tantra-adapters 0012](../../tantra-adapters/docs/gaps/0012-instrument-resolution-and-tokens.md) | high | Raw broker identifiers leak; no instrument master |
| [tantra-core 0006](../../tantra-core/docs/gaps/0006-canonical-priceband-and-calendar-trait.md) | medium | Duplicated `PriceBand` and calendar traits across four repos |
| [tantra-core 0007](../../tantra-core/docs/gaps/0007-calendar-session-model.md) | medium | Fixed UTC offset, single session per date, no navigation |

## Why

A split or bonus applied to the wrong instrument (or twice on replay) corrupts lot quantities and cost basis, and everything downstream (PnL, tax, margin). Two calendars disagreeing about a holiday or special session make a strategy trade on a closed day in one surface and not another. A symbol collision in the master routes an order to the wrong token. These are correctness bugs in reference data that every repo trusts.

## How to close it

1. `tantra-core`: one calendar trait and session model (multi-session, IST-correct), one `PriceBand`; define `CorporateAction` and the adjustment factor type (0006, 0007).
2. ~~`tantra-ledger`: scope corporate actions by instrument and make application idempotent (0014 ✅ 2026-11-25)~~.
3. `tantra-market`: key the instrument master by `(exchange, segment, token)` with alias resolution; one Rust resolver (0015).
4. `tantra-data`: holidays and corporate actions flow as lakehouse-fed sources behind the core ports; Python via wheel.
5. `tantra-adapters`: resolve through the wheel resolver; no raw broker ids past the ACL (0012).
6. Delete the finance/chat-tools/runtime calendar copies and the finance `PriceBand`.
7. Golden vectors: holiday/session table, split/bonus sequences with expected lot results, alias-resolution table.

**Verification**: golden tests in core, ledger and data; replay-twice idempotency test for corporate actions; `cargo clippy --all-targets -- -D warnings`; `pytest -q`.

## Related

- Root plan [0021](../plans/0021-workspace-design-review-2026-11.md); relates to 0019 P4.1 (cost tables) only incidentally.
- Other root gaps: [0014](0014-unified-financial-enums-and-position-model.md), [0018](0018-lakehouse-manifest-ref-contract.md).
