# 0016 — Indicator golden-parity suite

**Status**: open
**Filed**: 2026-11-23 — workspace design review (root plan 0021) · **Kind**: duplication · **Severity**: high
**Plan**: [0021](../plans/0021-workspace-design-review-2026-11.md)

## What's stubbed or hardcoded

Indicators and studies exist in three or four places with no common parity suite. The home of the library is Python `tantra-strategies` (`tantra_library`, user decision); the Rust `tantra-market-indicators` crate is the streaming runtime twin. Copies: `tantra-strategies/tantra_strategies/sdk/indicators.py`, `tantra-ffi/python/tantra/indicators/`, TypeScript `tantra-ui-web/src/lib/{screener-indicators,chart-indicators,indicator-lab}.ts` (for example `sma` at `screener-indicators.ts:17`), and `tantra-market-finance/src/studies/*` versus `experimental_analysis.rs`. `tantra-market-indicators` now computes in exact `Decimal` (gap `0009` closed 2026-11-24), TypeScript uses Decimal, and only ATR and CMO are golden-paired (`tests/golden/atr_cmo_tantra_library.json`). No per-repo gap tracker row exists for this family; it is tracked through per-repo plan items.

| Repo tracker | Severity | What it covers |
|---|---|---|
| `tantra-market/docs/plans/0006-design-review-2026-11.md` R3 | high | Rust indicator parity vs `tantra_library`, `DynIndicator`, `Result` constructors |
| `tantra-ui-web/docs/plans/0018-design-review-2026-11.md` R4 | high | Retire TS indicator copies (WASM or REST `/studies`) |
| `tantra-market` gap `0009` (`closed` 2026-11-24) | closed | Zero-floats Decimal migration of `tantra-market-indicators` |

## Why

The same RSI/EMA/Bollinger inputs give different values on the chart, in the screener, in a Python backtest and in the live Rust engine, so a strategy validated in research trades different signals live, and the screener shows hits the chart does not.

## How to close it

1. `tantra-strategies`: `tantra_library` is the reference; fold `sdk/indicators.py` into it.
2. `tantra-strategies`: extend golden vectors beyond ATR/CMO to RSI, EMA, SMA, Bollinger, MACD and Supertrend (warm-up, NaN-gap and constant-series cases), stored as JSON.
3. `tantra-market`: make `tantra-market-indicators` consume those vectors in `tests/` and finish plan 0006 R3 (`DynIndicator`, `Result` constructors).
4. `tantra-ffi`: indicator module becomes a wheel binding or thin wrapper of the Rust crate.
5. `tantra-ui-web`: replace TS indicator code with WASM or the REST `/studies` endpoint (plan 0018 R4); keep only layout code.
6. CI: `tantra-strategies` generates the vectors; `tantra-market` and `tantra-ui-web` fail if their outputs deviate beyond the declared tolerance.

**Verification**: `cargo test -p tantra-market-indicators --test golden --profile prod`, `pytest -q tantra_library`, `npx vitest run`, all reading one fixture set.

## Related

- Root plan [0021](../plans/0021-workspace-design-review-2026-11.md); overlaps 0019 P4.4 (zero-floats indicators — closed 2026-11-24).
- Other root gaps: [0015](0015-pricing-and-quant-math-single-source.md).
