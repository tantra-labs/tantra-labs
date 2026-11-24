# 0014 — Unified financial enums and position model

**Status**: open
**Filed**: 2026-11-23 — workspace design review (root plan 0021) · **Kind**: duplication · **Severity**: high
**Plan**: [0021](../plans/0021-workspace-design-review-2026-11.md)

## What's stubbed or hardcoded

The same financial concepts are modelled several times with different shapes. There are three `Product` enums: `Product{Delivery,Intraday,CoverOrder,BracketOrder}` in `tantra-core` portfolio, `ProductType{Delivery,Intraday,Options,Futures}` in the ledger journal, and `ProductType{CncDelivery,MisIntraday,NrmlDerivative,MtfMargin}` in exec-core. Position, lot and account state appear at least five times: `PositionRecord` in `tantra-ledger/.../repository.rs:105`, `tantra-core/src/portfolio.rs:39`, `tantra-runtime-api/src/wire.rs:756`, `tantra-runtime-backtest/src/engine.rs:105`, and `AccountState` in `tantra-exec-paper/src/paper.rs:55`, plus Python copies in `tantra-ffi/python/tantra/{position,portfolio,order_state}.py`. `TaxLot.lot_id` is a `String`, and `Money::notional` hard-codes INR. Position DTOs are not derived from core via `schemars`.

| Repo tracker | Severity | What it covers |
|---|---|---|
| [tantra-core 0008](../../tantra-core/docs/gaps/0008-money-currency-safety.md) | medium | `Money::notional` hard-codes INR; no currency-checked arithmetic |
| [tantra-ffi 0006](../../tantra-ffi/docs/gaps/0006-python-fallback-parity-vectors.md) | high | Python copies of Rust domain logic without parity vectors |

## Why

A position opened under one `Product` meaning cannot be mapped losslessly to another: CNC/MIS/NRML versus Delivery/Intraday/Options/Futures drop information, so margin and tax treatment can differ between backtest, paper and live. Duplicate position logic in backtest and paper means PnL differs from the ledger for the same fills. Binding rules: `.agents/rules/interface-first-and-modularity.md` §1.4 (do not fork order/position types) and the single-source DTO rule in `AGENTS.md` §3.

## How to close it

1. `tantra-core`: define one canonical `Product`, `Position`, `TaxLot` (typed `LotId`) and currency-checked `Money`; derive wire DTOs with `schemars` (0008).
2. `tantra-ledger`: `PositionRecord` and journal `ProductType` become views over the core types; `Portfolio::apply_fill` is the only position-mutation path.
3. `tantra-exec`: map broker-specific products (CNC/MIS/NRML/MTF) to core `Product` in the ACL, with a lossless-or-error mapping.
4. `tantra-runtime`: wire DTO re-exports core types; backtest and paper call `Portfolio::apply_fill` instead of private models.
5. `tantra-ffi`: Python models come from the wheel; keep a thin typed wrapper with parity vectors (0006).
6. Golden fixtures: a fill sequence with expected positions/lots/PnL consumed by ledger, backtest, paper and pytest.

**Verification**: proptest on FIFO lot invariants in `tantra-ledger`; golden fill-sequence tests in each consumer; `cargo clippy --all-targets -- -D warnings`; `pytest -q` in `tantra-ffi`.

## Related

- Root plan [0021](../plans/0021-workspace-design-review-2026-11.md); overlaps 0019 P2.1 (paper/backtest clone) and 0019 P4.5, which covers only the Python models, not the Rust enums or DTOs.
- Other root gaps: [0010](0010-order-idempotency-end-to-end.md), [0019](0019-calendar-instrument-master-corporate-actions-sources.md).
