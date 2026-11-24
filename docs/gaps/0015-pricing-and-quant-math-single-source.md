# 0015 — Pricing and quant math single source

**Status**: open
**Filed**: 2026-11-23 — workspace design review (root plan 0021) · **Kind**: duplication · **Severity**: high
**Plan**: [0021](../plans/0021-workspace-design-review-2026-11.md)

## What's stubbed or hardcoded

Normal CDF/erf is implemented seven times with different error bounds: `tantra-market-pricing/src/lib.rs:225` (Hart polynomial), `tantra-agent-mcp/src/tools.rs:3271`, `tantra-agent-research/src/verification.rs:222`, `tantra-agent-analytics/src/math.rs:4` (A&S 7.1.26), `tantra-ui-core/src/strategy.rs:459`, `tantra-ffi/python/tantra/options.py:117` and `tantra-ui-web/src/lib/option-chain.ts:231`. The exact Decimal `norm_cdf`/`norm_inv` in `tantra-core/src/analytics/distribution.rs:60` is the best version and is not used by them. Black-Scholes, greeks and implied vol exist in Rust (f64, bisection), Python (Decimal) and TypeScript, with no Black-76 for index options. Performance metrics are also copied: `tantra-examples/.../metrics.py:335` (float), `tantra-ffi/python/tantra/algo_analytics/metrics.py:20` (float), the MCP `MetricsCalculatorService`, the web WASM analytics, and `tantra-ui-core`, with differing annualisation (252 hard-coded versus parameter) and ddof.

| Repo tracker | Severity | What it covers |
|---|---|---|
| [tantra-ffi 0006](../../tantra-ffi/docs/gaps/0006-python-fallback-parity-vectors.md) | high | Python copies (`options.py`, metrics) without parity vectors |
| [tantra-ui-web 0080](../../tantra-ui-web/docs/gaps/0080-ts-black-scholes-duplicate.md) | high | BS, greeks, IV skew re-implemented in TypeScript |
| [tantra-examples 0010](../../tantra-examples/docs/gaps/0010-metrics-float-and-wheel-duplication.md) | medium | `metrics.py` float metrics duplicate the wheel |
| [tantra-core 0010](../../tantra-core/docs/gaps/0010-decimal-wire-scale-pinning.md) | medium | `Decimal` serialization not pinned to canonical scale |

## Why

The same input yields different p-values and greeks per surface (differences up to 1.5e-7 in the CDF alone), so a DSR/PBO gate can pass in the agent and fail in the runtime, and the IV shown in the web differs from the Python SDK. Index options priced with Black-Scholes are wrong everywhere. Float metrics in Python also breach `.agents/rules/interface-first-and-modularity.md` §2.3 (zero floats in financial math).

## How to close it

1. `tantra-core::analytics`: add a wasm-safe f64 `erf`/`norm_cdf` fuzz-compared to the Decimal version; pin Decimal wire scale (0010).
2. `tantra-market-pricing`: use it; add Black-76 and a tighter IV solver; remain the single pricing owner.
3. `tantra-agent`, `tantra-ui`: delete the five Rust copies and call core (this overlaps 0019 P4.2 for analytics).
4. `tantra-ffi`: expose `price`/`greeks`/`implied_volatility`/metrics through PyO3; keep `options.py`/metrics wrappers thin (0006).
5. `tantra-ui-web`: export the same functions via the `tantra-ui-api-wasm` module and delete TS math (0080).
6. `tantra-examples`: replace float `metrics.py` with wheel calls (0010).
7. Golden vectors (CDF table for z in -6..6; spot/strike/t/r/q/vol to price/greeks/IV round-trip; metric series) consumed by Rust, pytest and vitest.

**Verification**: proptest `|cdf_f64 - cdf_decimal| < 1e-9`; golden JSON in core CI; `npx vitest run` and `pytest -q` read the same vectors.

## Related

- Root plan [0021](../plans/0021-workspace-design-review-2026-11.md); 0019 P4.2 covers only the analytics erf/CDF and metrics move to `tantra-core::analytics`, not pricing, ui-core, ffi or TS copies.
- Other root gaps: [0012](0012-fabricated-data-presented-as-real.md), [0016](0016-indicator-golden-parity-suite.md).
