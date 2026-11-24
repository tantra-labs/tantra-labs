# 0017 — Broker integration consolidation

**Status**: open
**Filed**: 2026-11-23 — workspace design review (root plan 0021) · **Kind**: duplication · **Severity**: high
**Plan**: [0021](../plans/0021-workspace-design-review-2026-11.md)

## What's stubbed or hardcoded

The same brokers are integrated more than once. Rust owns orders in `tantra-exec-{zerodha,upstox,angelone}` and ticks in `tantra-market-{dhan,zerodha}`. Python `tantra-adapters` (`zerodha`, `upstox`, `angelone`, `dhan`, with `common/{auth,transport,contract,models,registry}.py`) maps the same brokers again, and the wheel ships a third kit in `tantra-ffi/python/tantra/adapters/*` (its `contract.py` is 712 lines versus 280 in `common/contract.py`). The Kite WebSocket client exists twice: `tantra-exec-zerodha/src/ticker.rs` and `tantra-market-zerodha/src/lib.rs`. Order mapping in Python is lossy and silently divergent from Rust; rate limiting, TOTP and secrets handling are reimplemented.

| Repo tracker | Severity | What it covers |
|---|---|---|
| [tantra-adapters 0010](../../tantra-adapters/docs/gaps/0010-python-rust-mapping-divergence.md) | high | Same brokers mapped twice with divergent, lossy semantics |

## Why

An order placed through the Python adapter can map product, order type or validity differently from the Rust executor, so the same strategy behaves differently by path. A fix to Zerodha auth or rate limits must be made in up to four places, and the Kite WebSocket reconnect logic drifts. Related to the live-order and idempotency gaps because each copy needs the same safeguards.

## How to close it

1. Decide the Python path: the wheel `tantra.adapters` owns the shared kit; `tantra-adapters` shrinks to thin broker plugins on top of it.
2. `tantra-exec`: the Rust executors expose the canonical mapping tables (`BrokerEnumMap`); see `tantra-exec/docs/plans/0004-design-review-2026-11.md` R2/R3.
3. `tantra-ffi`: expose mapping and rate-limit/TOTP primitives to Python; delete the duplicate `contract.py` surface.
4. `tantra-adapters`: remove local mapping and auth code in favour of the kit (0010).
5. `tantra-exec` / `tantra-market`: single Kite WS client in `tantra-market-core` `ws_client`; `tantra-exec-zerodha/src/ticker.rs` uses it.
6. Cross-language golden vectors for order mapping (product, type, validity, side) per broker, run by Rust and pytest.

**Verification**: golden mapping tests in `tantra-exec` and `tantra-adapters`; `cargo test --profile prod` on the ticker; `pytest -q`.

## Related

- Root plan [0021](../plans/0021-workspace-design-review-2026-11.md); overlaps 0019 P2.4 (adapters boilerplate) and 0019 P4.5 (Python models to wheel).
- Other root gaps: [0010](0010-order-idempotency-end-to-end.md), [0011](0011-secrets-leak-debug-logs-urls.md), [0013](0013-risk-gate-single-shared-fail-closed.md).
