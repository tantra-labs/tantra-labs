# 0021 — Simulation and fill-model unification across Rust and Python research harnesses

**Status**: open
**Filed**: 2026-11-23 — workspace design review (root plan 0021) · **Kind**: duplication · **Severity**: high
**Plan**: [0021](../plans/0021-workspace-design-review-2026-11.md)

## What's stubbed or hardcoded

There are four fill/simulation engines. Root plan 0019 P2.1 only removes the Rust clone
(`tantra-exec-paper` vs `tantra-runtime-backtest/src/sim`). The Python side is untouched and carries different
fill semantics, so research PnL differs from paper PnL for the same strategy.

- `tantra-exec-paper` (Rust, canonical owner) and `tantra-runtime-backtest/src/sim/*` (Rust clone; 0019 P2.1).
- `tantra-strategies/.../sdk/context.py:45` `SimulatedContext`: fills at the bar close, no tick rounding,
  no fees, no slippage; stops and brackets never leave the private simulator.
- `tantra-ffi/python/tantra/backtest/{simulated,l2_sim}.py`: further Python simulators selected by env var.
- `tantra-examples` backtest harness: float quantity/price in public records and two engines in one module.

| Repo tracker / evidence | Severity | What it covers |
|---|---|---|
| [strategies 0018](../../tantra-strategies/docs/gaps/0018-simulated-context-fill-model.md) | medium | `SimulatedContext` fills at close, no tick rounding, fees or slippage |
| [examples 0012](../../tantra-examples/docs/gaps/0012-backtest-float-fills.md) | medium | Float fills; two engines in `backtest.py` |
| [strategies 0009](../../tantra-strategies/docs/gaps/0009-live-context-parity.md) | high | Private simulator breaks research/live parity |
| `tantra-ffi/python/tantra/backtest/{simulated,l2_sim}.py` | n/a | Wheel-side Python simulators (see ffi design-review plan [0005](../../tantra-ffi/docs/plans/0005-design-review-2026-11.md)) |

## Why

- A strategy that looks profitable in the Python harness fills at close with zero cost; the same strategy in
  paper uses tick rounding, fees and slippage. Promotion decisions are made on numbers that cannot be reproduced.
- Float fills in the examples harness violate the zero-floats rule (`.agents/rules/interface-first-and-modularity.md` §2.3).
- Every fill-semantic fix (partial fills, tick size, STT/charges) must be made four times.

## How to close it

1. `tantra-exec` (owner): finish 0019 P2.1 so `tantra-exec-paper` is the single Rust matching engine;
   document its fill semantics (limit/market/stop, tick rounding, fee schedule hook, slippage model).
2. `tantra-ffi`: expose `PaperExchange` through the wheel; make `tantra.backtest.simulated` and `l2_sim`
   thin delegates, removing the Python re-implementation.
3. `tantra-strategies`: make `SimulatedContext` wrap the wheel `PaperExchange`; emit fill events and route
   stops/brackets through it (strategies 0009, 0018).
4. `tantra-examples`: replace `backtest.py` engines with the wheel harness; Decimal quantities and prices
   (examples 0012).
5. Publish a golden order-tape to fills vector set (JSON) in `tantra-exec/tests`; Rust and Python harnesses both
   replay it and must produce byte-identical fills.

**Verification**: golden tape parity tests in `tantra-exec` and `tantra-ffi` (pytest); hypothesis test that
Python harness fills equal wheel fills; `make prod` plus targeted `cargo test -p tantra-exec-paper --profile prod`.

## Related

- Extends root plan 0019 P2.1 (Rust clone only).
- [0014](0014-unified-financial-enums-and-position-model.md) (shared position model) and
  [0015](0015-pricing-and-quant-math-single-source.md) (single-source quant math).
