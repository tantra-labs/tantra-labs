# 0002 — Reduce-Only Enforcement Contract (Risk Gate ↔ Runtime REST)

**Status**: Accepted (decision recorded) — 2026-11-13
**Scope**: Cross-repo behavioral contract between `tantra-risk` (position-free gate) and
  `tantra-runtime-api-rest` (position-aware order route), plus the price-collar contract.
**Inputs**: Verified against `tantra-risk/src/engine.rs`, `tantra-risk/tests/plan0002_tests.rs`
  (commit `9a0bc59`) and `tantra-runtime/crates/tantra-runtime-api-rest/src/orders.rs`
  (`state_refusal`, ADR 0018).

---

## 1. Problem

`GlobalState::ReduceOnly` ("close/reduce only, no new risk") existed as a switch on the risk
gate but no check path enforced it; the position-accurate semantics were ambiguous because
`tantra-risk` is a pure, zero-I/O, **position-free** gate.

## 2. Decision — two-layer reduce-only

Reduce-only is enforced in **two complementary layers**:

1. **Position-free backstop — `tantra-risk::RiskEngine`** (all order paths, plan 0002): under
   `GlobalState::ReduceOnly`, an order-opening `Buy` is refused with
   `RiskRefusal::ReduceOnlyViolation`; a `Sell` is approved as the documented close-long
   approximation; `ModifyOrder` and new position sizing are refused; cancels pass.
   `check_order_fast` requires `side: OrderSide` so the fast path enforces the same rule.
2. **Position-aware front gate — `tantra-runtime-api-rest`** (ADR 0018, pre-existing): before
   the risk gate, `state_refusal` rejects under `TradingState::Reducing` unless
   `reduces_position(position, side, quantity)` — an opposite-direction order within the held
   size. This is the correctness layer; the gate's side-based rule is the conservative backstop
   for every path that does not carry position context.

## 3. Decision — price collar semantics

`RiskLimits::price_collar_bps` collars **market orders** at the risk gate: the worst-case
band-edge fill (`band.upper` for Buy, `band.lower` for Sell) must stay within
`reference_price ± collar`, else `RiskRefusal::PriceCollarViolation`. The gate has no market
data, so the band edge is the conservative fill proxy; skipped when no band exists.

## 4. Consequences

- Every declared risk limit is now enforced (plan 0002): reduce-only, price collar, fast-path
  OTR parity, and configured OTR windows — see `tantra-risk/docs/design/code-reduce-only.md`
  for the full decision record and enforcement matrix.
- The FFI wheel surface mirrors the gate (`check_order_fast(..., side, ...)`).
- A future position-aware mode inside `tantra-risk` would need a position port into the pure
  gate — deliberately out of scope.

## 5. Referenced docs

- `tantra-risk/docs/design/code-reduce-only.md` — per-repo decision record (enforcement
  matrix, rationale, verification).
- `tantra-risk/docs/design/code-engine.md` — the enforced pipeline (steps 1.25 / 4.5).
- `tantra-runtime/crates/tantra-runtime-api-rest/src/orders.rs` — `state_refusal` (ADR 0018).
- `tantra-risk/docs/gaps/README.md` — gaps 0001–0004 Closed (commit `9a0bc59`).
