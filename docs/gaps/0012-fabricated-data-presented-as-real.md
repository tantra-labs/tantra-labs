# 0012 — Fabricated or synthetic data presented as real

**Status**: open
**Filed**: 2026-11-23 — workspace design review (root plan 0021) · **Kind**: design-flaw · **Severity**: high
**Plan**: [0021](../plans/0021-workspace-design-review-2026-11.md)

## What's stubbed or hardcoded

Several surfaces return invented values instead of an explicit "unavailable": MCP tools report fabricated "queued/started/ALL PASSED" results for backtests and optimisation; the CLI drives strategy run/tune/suggest from synthetic sine-wave bars; the web option chain silently falls back to a fabricated chain (open interest, OI change, LTP change, skew) whenever loading fails, while the runtime endpoint itself encodes missing values as zeros or modelled IV with no per-field provenance; the Python adapters turn missing prices and margins into zero; the FFI `StrategyRunner` "GIL-free batch" is a placeholder checksum. At the root of this, `PortError` is stringly-typed and has no `unavailable` variant, so there is no typed way to say "not provided".

| Repo tracker | Severity | What it covers |
|---|---|---|
| [tantra-runtime 0027](../../tantra-runtime/docs/gaps/0027-options-chain-oi-change-and-iv-fields.md) | high | Options-chain fields encode missing data as zero/model values, no per-field provenance |
| [tantra-agent 0011](../../tantra-agent/docs/gaps/0011-mcp-stub-tools-fabricate-results.md) | high | MCP `run_backtest`/`optimize_strategy`/`explain_decision` fabricate results |
| [tantra-ui 0008](../../tantra-ui/docs/gaps/0008-synthetic-bars-in-run-tune-suggest.md) | high | Sine-wave bars drive run/tune/suggest |
| [tantra-ui-web 0079](../../tantra-ui-web/docs/gaps/0079-option-chain-fabricated-fields.md) | high | Option chain silently falls back to a fabricated chain on any load error |
| [tantra-adapters 0013](../../tantra-adapters/docs/gaps/0013-missing-data-as-zero.md) | high | Missing data fabricated as zero (prices, margins) |
| tantra-core 0005 ([closed](../../tantra-core/docs/gaps/README.md#closed-gaps)) | medium | `PortError::unavailable` landed 2026-11-25 |
| [tantra-ffi 0009](../../tantra-ffi/docs/gaps/0009-strategy-runner-placeholder.md) | medium | `StrategyRunner` placeholder checksum |

## Why

A trader or an LLM agent reading "ALL PASSED", a zero margin, or a plausible-looking IV skew acts on numbers that never came from a market or a backtest. The failure is silent: nothing signals the data is invented. The binding rule is `.agents/rules/interface-first-and-modularity.md` §1.3: missing upstream capabilities return `PortError::unavailable(...)` paired with a filed gap, never silent empty values or fake defaults.

## How to close it

1. ~~`tantra-core`: add typed `PortError` with `unavailable` and use it as the port contract (0005).~~ (Closed 2026-11-25.)
2. `tantra-runtime`: make missing options-chain values nullable with per-field provenance instead of zeros/modelled IV (0027).
3. `tantra-ui-web`: replace the silent `catch {}` fallback to a fabricated chain with an explicit unavailable state, and render "—" for null fields (0079).
4. `tantra-agent`: MCP stub tools return an explicit unavailable error or call the real backtest port (0011).
5. `tantra-ui`: run/tune/suggest take real lakehouse bars or fail with a clear message (0008).
6. `tantra-adapters`: missing data raises or returns `None`, never `0` (0013).
7. `tantra-ffi`: implement the real GIL-free batch or remove the placeholder (0009).
8. Add a grep-based CI guard for sentinel patterns (`queued`, `ALL PASSED`, sine-wave generators) in non-test `src/`.

**Verification**: per-repo negative tests (missing field renders unavailable, not zero); `npx vitest run` in ui-web; `pytest -q` in adapters; `make check` for Rust repos.

## Related

- Root plan [0021](../plans/0021-workspace-design-review-2026-11.md); relates to 0019 P5.1/P5.2 (wiring unwired crates).
- Other root gaps: [0010](0010-order-idempotency-end-to-end.md), [0015](0015-pricing-and-quant-math-single-source.md).
