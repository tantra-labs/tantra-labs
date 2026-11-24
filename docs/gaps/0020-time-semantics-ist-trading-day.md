# 0020 — Time semantics: IST trading day vs UTC, naive datetimes, `date.today()`, missing day rollover

**Status**: open
**Filed**: 2026-11-23 — workspace design review (root plan 0021) · **Kind**: design-flaw · **Severity**: high
**Plan**: [0021](../plans/0021-workspace-design-review-2026-11.md)

## What's stubbed or hardcoded

The trading day is an IST (Asia/Kolkata) concept, but every layer picks its own notion of "today" and of
a timestamp. There is no shared definition of session date, rollover instant or timezone handling, so the
same instant maps to different trading days depending on which repo reads it.

- `TradingCalendar` uses a fixed UTC offset with one unvalidated session per date and no day navigation.
- Risk counters (daily loss, turnover, PnL, OTR) never reset at a trading-day boundary; the daily-loss halt is
  global and sticky.
- Lot holding periods are hard-coded and dated in UTC, so lots opened near the IST midnight boundary classify wrongly.
- The runtime jobs registry accepts UTC-only cron, so "09:20 IST" schedules need manual offset arithmetic.
- Web "today" dates use UTC/browser-local time; ids use `Math.random`.
- Python adapters mix naive datetimes with IST and UTC; `tantra-data` stamps `as_of_ist` from `date.today()` (host-local time).

| Repo tracker / evidence | Severity | What it covers |
|---|---|---|
| [core 0007](../../tantra-core/docs/gaps/0007-calendar-session-model.md) | medium | Fixed UTC offset, single unvalidated session per date, no day navigation |
| [ledger 0020](../../tantra-ledger/docs/gaps/0020-tax-lot-classification-and-dates.md) | medium | Holding period hard-coded and UTC-dated |
| [risk 0009](../../tantra-risk/docs/gaps/0009-trading-day-rollover.md) | high | No rollover of daily loss, turnover, PnL, OTR; sticky global halt |
| [runtime 0032](../../tantra-runtime/docs/gaps/0032-jobs-single-runner-and-ist-cron.md) | high | UTC-only cron, single JSON registry |
| [ui-web 0087](../../tantra-ui-web/docs/gaps/0087-ist-dates-and-ids.md) | medium | UTC/browser-local "today"; `Math.random` ids |
| [adapters 0016](../../tantra-adapters/docs/gaps/0016-timestamp-normalisation.md) | medium | Naive datetimes, mixed IST/UTC |
| [data 0033](../../tantra-data/docs/gaps/0033-as-of-ist-clock.md) | medium | `date.today()` stamps `as_of_ist` |

## Why

- Risk limits that do not reset on a new session either block trading on day two or, if reset ad hoc elsewhere,
  silently diverge between processes. A sticky global halt turns one bad day into a manual intervention.
- A lot sold at 00:30 IST is dated the previous UTC day; holding-period (statutory tax) classification and
  as-of stamps in the lakehouse then disagree with broker contract notes.
- Wall-clock reads (`date.today()`, `Utc::now()`) in domain code also violate the zero-clock rule in
  `.agents/rules/interface-first-and-modularity.md` §2.2 and make replays non-deterministic.

## How to close it

1. `tantra-core` (owner): add a `TradingDay` / `SessionDate` value object and an IST `Clock` port
   (`now() -> DateTime<Utc>`, `trading_day(instant) -> SessionDate`) backed by a real timezone (not a fixed
   offset), plus session navigation (`next_session`, `prev_session`) per core 0007.
2. `tantra-risk`: consume `SessionDate` as an explicit parameter; roll daily counters and make the daily-loss halt
   per-session (risk 0009). `tantra-ledger`: date lots by `SessionDate` (ledger 0020).
3. `tantra-runtime`: IST-aware cron (runtime 0032); inject the `Clock` instead of calling the wall clock.
4. Python (`tantra-adapters`, `tantra-data`, `tantra-strategies`): expose the same helper through the wheel
   (zoneinfo `Asia/Kolkata`), reject naive datetimes at the ACL boundary, inject `as_of` instead of `date.today()`.
5. `tantra-ui-web`: format and compute "today" in IST; use `crypto.randomUUID` for ids.
6. Add a cross-language golden vector set (instants around 18:29/18:30 UTC, holidays, month and year ends)
   consumed by Rust and Python tests.

**Verification**: golden vector tests in `tantra-core/tests` and `tantra-ffi` pytest; proptest that
`trading_day` is monotonic; risk rollover test across a session boundary; CI grep guard for `date.today()`
and `datetime.now()` without tz in Python library code; `cargo clippy --all-targets -- -D warnings`, `make check`.

## Related

- Root plan 0019 P1 wasm `Instant::now` guard (clock injection) is adjacent; this gap adds the semantic definition.
- [0019](0019-calendar-instrument-master-corporate-actions-sources.md) covers calendar single sourcing; this gap
  covers time semantics on top of it.
