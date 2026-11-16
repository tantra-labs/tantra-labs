# 0006 — Dismantle the `_kernel` Shared Harness (Clean-Architecture Alignment)

**Status**: **Implemented 2026-11-16** (T13.1–T13.7 complete).
**Track**: T13 · **Phase**: 5 (Python wheel / SDK surface)
**Owning repos**: `tantra-ffi` (wheel domain surfaces) + `tantra-examples` (harness dismantle)
**Per-repo plans**: `tantra-ffi/docs/plans/0002-*.md` (Thrust A — wheel lift, **Implemented**),
`tantra-examples/docs/plans/0003-*.md` (Thrust B — harness rename + gate, **Implemented**)

## Closing record (2026-11-16)

- **Thrust A (T13.1–T13.5)**: `tantra.portfolio`/`risk`/`options`/`metrics`/`calendar` shipped
  in the wheel (`tantra-ffi` `9b354d5` + `3d5a1ac` + `f210c8a`; 52 new wheel tests, 480 wheel
  suite passed). The six `_kernel` domain modules deleted and every consumer retargeted to the
  wheel (`tantra-examples` `25cb5df`).
- **Thrust B (T13.6)**: harness renamed `tantra_examples/_kernel/` → `tantra_examples/harness/`
  (`1acabfb`), facade rewritten to expose only harness names (no wheel re-exports), all ~60
  `_kernel.*` import sites retargeted, `_kernel/` deleted repo-wide, docs swept (`3c2e5ae`).
- **Gate (T13.7)**: wheel 480 passed; examples `tests/unit` 909 passed / 51 skipped with **zero
  new failures** (6 `test_06_multi_broker_dispatch` failures are pre-existing/environmental —
  the installed `tantra_adapters` entry points bypass the example's paper fallback; reproduce
  identically on pre-T13 `1d89fd9`); ruff check + format clean; 6 example import-smokes pass.
  Follow-on consolidation candidates recorded (not required): `harness/runner.py` vs the wheel
  `tantra.backtest.session`, `harness/service.py` vs `tantra_data`, `harness/testing.py` as a
  future wheel replay helper, and the end-to-end Decimal conversion of
  `metrics.fills_equity_curve` + consumers.
- **No Rust changes** (pure-Python plan); no gaps were filed/closed under this plan.

## Why

With all 8 `_kernel` mirror gaps closed (0001–0008, 2026-11-15), the `tantra_examples/_kernel/`
package no longer mirrors anything — but 14 modules still live under a name that means
"kernel internals", and six of them are domain/math logic that belongs in the `tantra` wheel,
not in the learning-path examples package. This violates two standing rules:

- **Consolidation Over Duplication** (`.agents/AGENTS.md` §4.1): "Never write duplicate logic
  across repositories. If a type or mathematical function is needed in multiple places, lift it
  into `tantra-core` or `tantra-ledger`." Portfolio aggregates, risk checks, Black-Scholes,
  option-chain models, bar-metrics and the IST calendar are wheel-domain surfaces; the wheel
  exists to be the canonical Decimal-canonical Python SDK surface (§6.1).
- **Bounded contexts** (§2.1, §3.1): the examples repo is the *learning path*, not a domain
  home. A package named `_kernel` in `tantra_examples` falsely advertises domain internals and
  invites future duplication.

The name `_kernel` is itself the residue of the mirror era. Industry-standard clean
architecture says the split is **domain → wheel (`tantra.*`)**, **application/harness →
examples package**, with no package pretending to be kernel internals.

## Current state (audited 2026-11-15)

`tantra_examples/_kernel/` (14 modules + the facade `__init__.py`):

| Module | Lines | Classification | Consumers (outside `_kernel/`) |
| :--- | ---: | :--- | :--- |
| `portfolio.py` | 65 | **domain** — `Account`/`Portfolio` aggregates (Decimal `Money`, wheel types) | none found (only the facade re-export) |
| `risk.py` | 189 | **domain** — pure-Python pre-trade checks (`check_state`, `RiskRefusal`/`RiskRefused`/`OrderRejected`, `limits_from_config`, `check_order`) + `_native_attr` probe for the not-yet-compiled risk classes | `_kernel/runner.py` |
| `greeks.py` | 198 | **domain** — `bs_greeks`/`bs_price` (Black-Scholes, Decimal) | options examples 02/04/05/06/08 |
| `option.py` | 78 | **domain** — `OptionKind`/`OptionChain`/`OptionContract`/`OptionStyle` | options examples 01/03/04/05/06/08, `_kernel/greeks.py` |
| `evaluator.py` | 268 | **domain** — `extract_metrics_from_bars` (bar metric extraction) | `screening/nl_support.py` |
| `calendar.py` | 101 | **domain** — `ist_midnight_ns` + IST session helpers | `_kernel/ports.py` |
| `config.py` | 62 | **harness** — `StrategyConfig` | `_kernel/loader.py`, `tests/integration/test_06_equal_weight_rebalance_parity.py` |
| `loader.py` | 505 | **harness** — catalog / strategy loading, `CatalogError` | `tantra_examples/catalog.py`, examples 06/07, tests/integration |
| `log.py` | 304 | **harness** — event logging | `_kernel/runner.py` |
| `manifest.py` | 431 | **harness** — pipeline manifests | tests/unit |
| `ports.py` | 164 | **harness** — `BarStore`/`MarketDataProvider`/`validate_bar` protocols | `_kernel/service.py`, `examples/storage/01` |
| `runner.py` | 653 | **harness** — `StrategyRunner` (the examples' own backtest runner) | `tantra_examples/backtest.py` |
| `service.py` | 182 | **harness** — `DataService` (store + providers) | `sip_plan.py` |
| `testing.py` | 223 | **harness** — `replay`/`ReplayResult` (deterministic replay) | ~20 examples + tests |

Total: 3,469 lines. ~60 `_kernel.*` import sites across `tantra_examples/`, `examples/`, `tests/`.

## Thrust A — lift the domain/math modules into the wheel (`tantra-ffi`)

Each surface: promote the module verbatim into `python/tantra/`, keep the public API
byte-identical, Decimal-canonical (already the case), add wheel tests in `python/tests/`,
then delete the `_kernel/` module and retarget its consumers.

| # | Wheel surface | Source module | Public API (kept) |
| :--- | :--- | :--- | :--- |
| A1 | `tantra.portfolio` | `_kernel/portfolio.py` | `Account`, `Portfolio` |
| A2 | `tantra.risk` | `_kernel/risk.py` | `check_state`, `check_order`, `limits_from_config`, `RiskRefusal`, `RiskRefused`, `OrderRejected` (+ `_native_attr` probe for the absent compiled classes) |
| A3 | `tantra.options` | `_kernel/greeks.py` + `_kernel/option.py` | `bs_greeks`, `bs_price`, `OptionKind`, `OptionStyle`, `OptionChain`, `OptionContract` |
| A4 | `tantra.metrics` | `_kernel/evaluator.py` | `extract_metrics_from_bars` (+ any exported metric helpers) |
| A5 | `tantra.calendar` | `_kernel/calendar.py` | `ist_midnight_ns` (+ IST helpers) |

Decision notes:
- **A1 `Account`/`Portfolio`**: audited consumers outside the facade = none. Primary path:
  promote to `tantra.portfolio` (the ledger-domain aggregate, matches `tantra-ledger`);
  during execution, re-verify zero consumers — if still unused, the surface may be deleted
  outright instead (recorded decision, not guessed).
- **A2 `tantra.risk`**: the wheel genuinely ships no compiled risk classes (tracked since
  ex 0006); the promoted module keeps the `_native_attr` probe that raises `RuntimeError`
  and lets callers fall back to the pure-Python rules — same contract as today, now from the
  wheel.
- **A3 `tantra.options`**: `bs_greeks`/`bs_price` are exact-Decimal Black-Scholes (the
  documented float exception in `examples/13_black_scholes_greeks.py` is the *example's*
  internal demo, not this module). Option-chain models live beside the India pack
  (`tantra.markets.india` is the natural sibling).
- **A4 `tantra.metrics`**: `extract_metrics_from_bars` is the screener's bar-metric
  extractor; the wheel's `tantra.algo_analytics.metrics` already holds sharpe-style math —
  the plan places this beside it.

## Thrust B — rename the remaining harness out of `_kernel` (`tantra-examples`)

After Thrust A, `_kernel/` holds only app-harness modules. Rename the package to
`tantra_examples/harness/` (application-layer scaffolding; the name states what it is):

- Move `config.py`, `loader.py`, `log.py`, `manifest.py`, `ports.py`, `runner.py`,
  `service.py`, `testing.py` (+ a rewritten facade `__init__.py` that no longer re-exports
  wheel domain names) into `tantra_examples/harness/`.
- Retarget every `tantra_examples._kernel.*` import (~60 sites: examples, tests, SDK
  modules) to `tantra_examples.harness.*` (or to the wheel surfaces where the import was
  domain).
- Delete `tantra_examples/_kernel/` entirely — the name disappears from the repo.
- Docs sweep: `docs/design/architecture.md`, `code-migration-map.md`,
  `gap-cascade-kernel-mirror.md`, the READMEs, HANDOFFs.

Follow-on consolidation **candidates** (recorded, not required): `harness/runner.py`
(`StrategyRunner`) vs the wheel `tantra.backtest.session.Tantra.backtest`;
`harness/service.py` (`DataService`) vs `tantra_data`'s service layer;
`harness/testing.py` (`replay`) as a future wheel backtest helper. These are kept as
documented candidates so the harness can keep shrinking toward the wheel over time.

## Execution order

1. **A1–A5** (wheel lift) — each wave: promote module → wheel tests → delete `_kernel/`
   module → retarget consumers → verify. Sequential (they share the `_kernel` package and
   the `_kernel/__init__.py` facade).
2. **B** (harness rename) — after A (so the wheel surfaces are the import targets).
3. **Gate** — full wheel suite + `tests/unit` (baseline 841 passed / 73 pre-existing
   float-rooted failures / 3 environmental errors / 50 skipped — zero new failures), `ruff
   check .` + `ruff format --check .` clean, and the `examples/*` smoke runs.

## Governing rules

- `.agents/AGENTS.md` §2.3 Zero-I/O domain purity (domain modules: no I/O, no wall clock;
  explicit `DateTime`/ts where temporal), §3.1 DDD bounded contexts, §4.1 Consolidation Over
  Duplication, §6.1 Python-first SDK (the wheel is the SDK surface), §3.2 tests live in
  `tests/` only (never inline), §11 build/test under the `prod` profile where Rust is touched
  (this plan is pure-Python: no Rust changes).
- `.agents/rules/gap-tracking.md`: on closure, remove the plan docs from active indexes and
  move the rows to Implemented with the closing commits.
- Per-repo HANDOFF hygiene (§10): update each repo's HANDOFF in the same change.

## Cross-repo plan map

| Plan | Repo | Covers | Track rows |
| :--- | :--- | :--- | :--- |
| [`tantra-ffi/docs/plans/0002-*.md`](../../tantra-ffi/docs/plans/0002-tantra-wheel-domain-harness-surface.md) | `tantra-ffi` | Thrust A (A1–A5) | T13.1–T13.5 |
| [`tantra-examples/docs/plans/0003-*.md`](../../tantra-examples/docs/plans/0003-tantra-examples-harness-dismantle.md) | `tantra-examples` | Thrust B + gate + follow-on | T13.6–T13.7 |
