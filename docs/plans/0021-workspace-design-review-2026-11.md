# 0021 — Workspace design review (2026-11): correctness, de-duplication and release readiness

**Status**: Proposed (2026-11-23)
**Scope**: all 15 repos + `tantra-ui-web` · **Siblings**: [0022](0022-future-deployment-architecture.md), [0023](0023-build-ci-release-engineering.md) · **Complements**: [0019](0019-codebase-audit-refactoring-unification-and-wiring.md)

## 0. Executive Summary & Objective

On 2026-11-23 the workspace was reviewed with 16 per-repo audits and 3 cross-cutting audits (cross-repo duplication, deployment topology, build/CI/release). Critical claims were re-verified in code. The output is 133 per-repo gaps (5 critical, 63 high, 65 medium), 16 per-repo design-review plans, 20 root tracker gaps (0010–0029) and root plans 0021–0023. This plan is the umbrella index and the sequencing authority: it orders the work into four waves, each with a gate.

The five critical gaps:
- [tantra-ledger 0014](../../tantra-ledger/docs/gaps/0014-corporate-action-scoping.md) — corporate actions are not instrument-scoped and can be re-applied.
- [tantra-market 0010](../../tantra-market/docs/gaps/0010-ws-client-resilience-and-token-logging.md) — the WS client never resubscribes and logs the access token in the URL.
- [tantra-exec 0004](../../tantra-exec/docs/gaps/0004-idempotent-submit-and-outcome-unknown.md) — the client order id is never sent; the SOR fails over on timeout, so an order can be submitted twice.
- [tantra-adapters 0008](../../tantra-adapters/docs/gaps/0008-order-idempotency-and-replay.md) — no client order id or algo tag; order POSTs are replayed on transport errors and 401.
- ~~[tantra-data 0027](../../tantra-data/docs/gaps/README.md#closed-gaps)~~ *(closed 2026-11-25)* — snapshot-merge commits, `tantra-catalog repair`, and [snapshot contract](../../tantra-data/docs/design/lakehouse-v3-snapshot-contract.md).

**Non-goals** (owned by root plan 0019, referenced by phase id, not duplicated): P0 hygiene and renames; P1 safety (body caps, inline tests, bounded channels, `is_delivery`, version alignment P1.7); P2 de-duplication (paper/backtest sim clone P2.1, adapters boilerplate P2.4, adapter safeguards P2.5, persistence wiring P2.7); P3 god-file splits; P4 DAG repair (P4.1 cost tables, P4.2 analytics, P4.3 wire types, P4.4 zero-floats indicators, P4.5 Python models, P4.6 `make verify-architecture`); P5 wiring of unwired crates.

## 1. Context & Gaps Covered

### 1.1 Per-repo plans

| Repo | Plan | Gaps | # | crit/high/med | Docs commit |
|---|---|---|---|---|---|
| `tantra-core` | [0006](../../tantra-core/docs/plans/0006-design-review-2026-11.md) | 0003–0010 | 8 | 0/2/6 | 10ae923 |
| `tantra-ledger` | [0006](../../tantra-ledger/docs/plans/0006-design-review-2026-11.md) | 0014–0022 | 9 | 1/5/3 | c56fd21 |
| `tantra-risk` | [0003](../../tantra-risk/docs/plans/0003-design-review-2026-11.md) | 0006–0015 | 10 | 0/5/5 | a9ea033 |
| `tantra-market` | [0006](../../tantra-market/docs/plans/0006-design-review-2026-11.md) | 0010–0016 | 7 | 1/5/1 | d68a16a |
| `tantra-exec` | [0004](../../tantra-exec/docs/plans/0004-design-review-2026-11.md) | 0004–0012 | 9 | 1/5/3 | f7faa3e |
| `tantra-runtime` | [0012 (API)](../../tantra-runtime/docs/plans/0012-api-design-review-2026-11.md), [0013 (engine)](../../tantra-runtime/docs/plans/0013-engine-design-review-2026-11.md) | 0018–0037 | 20 | 0/12/8 | 04e11c4 |
| `tantra-agent` | [0021](../../tantra-agent/docs/plans/0021-design-review-2026-11.md) | 0011–0019 | 9 | 0/4/5 | a52c5fd |
| `tantra-ffi` | [0005](../../tantra-ffi/docs/plans/0005-design-review-2026-11.md) | 0003–0011 | 9 | 0/4/5 | 0372490 |
| `tantra-ui` | [0011](../../tantra-ui/docs/plans/0011-design-review-2026-11.md) | 0008–0011 | 4 | 0/1/3 | 293b465 |
| `tantra-ui-web` | [0018](../../tantra-ui-web/docs/plans/0018-design-review-2026-11.md) | 0079–0087 | 9 | 0/6/3 | 6ff30f5 |
| `tantra-strategies` | [0006](../../tantra-strategies/docs/plans/0006-design-review-2026-11.md) | 0009–0018 | 10 | 0/2/8 | c597bfb |
| `tantra-adapters` | [0005](../../tantra-adapters/docs/plans/0005-design-review-2026-11.md) | 0008–0018 | 11 | 1/5/5 | 8642609 |
| `tantra-data` | [0011](../../tantra-data/docs/plans/0011-design-review-2026-11.md) | 0027–0034 | 8 | 1/4/3 | 0741980 |
| `tantra-examples` | [0006](../../tantra-examples/docs/plans/0006-design-review-2026-11.md) | 0009–0012 | 4 | 0/1/3 | 50775b0 |
| `tantra-docs` | [0006](../../tantra-docs/docs/plans/0006-design-review-2026-11.md) | 0001–0006 | 6 | 0/2/4 | d38dcea |
| **Total** | 16 plans | | **133** | **5/63/65** | |

### 1.2 Root tracker gaps (cross-repo; each lists its per-repo gaps)

| Root gap | Title | Canonical owner | Severity |
|---|---|---|---|
| [0010](../gaps/0010-order-idempotency-end-to-end.md) | End-to-end order idempotency and unknown-outcome handling | `tantra-exec` (+ ledger exec-id dedupe) | critical |
| [0011](../gaps/0011-secrets-leak-debug-logs-urls.md) | Secrets leak via `Debug`, logs and URLs | `tantra-exec` secret types | high |
| [0012](../gaps/0012-fabricated-data-presented-as-real.md) | Fabricated or synthetic data presented as real | each producing repo (`PortError::unavailable`) | high |
| [0013](../gaps/0013-risk-gate-single-shared-fail-closed.md) | Risk gate not single, shared or fail-closed | `tantra-risk` | critical |
| [0014](../gaps/0014-unified-financial-enums-and-position-model.md) | Unified financial enums and position model | `tantra-core` + `tantra-ledger-portfolio` | high |
| [0015](../gaps/0015-pricing-and-quant-math-single-source.md) | Pricing and quant math single source | `tantra-core::analytics`, `tantra-market-pricing` | high |
| [0016](../gaps/0016-indicator-golden-parity-suite.md) | Indicator golden-parity suite | `tantra-strategies` (`tantra_library`) | high |
| [0017](../gaps/0017-broker-integration-consolidation.md) | Broker integration consolidation | `tantra-exec-*` / `tantra-market-*` | high |
| [0018](../gaps/0018-lakehouse-manifest-ref-contract.md) | Lakehouse manifest/ref contract | `tantra-market-store` | critical |
| [0019](../gaps/0019-calendar-instrument-master-corporate-actions-sources.md) | Calendar, instrument master, corporate-action sources | `tantra-core` | medium |
| [0020](../gaps/0020-time-semantics-ist-trading-day.md) | Time semantics: IST trading day | `tantra-core` calendar | high |
| [0021](../gaps/0021-simulation-fill-model-unification.md) | Simulation/fill-model unification | `tantra-exec-paper` | high |
| [0022](../gaps/0022-canonical-openapi-and-generated-clients.md) | Canonical OpenAPI and generated clients | `tantra-runtime-api-rest` | medium |
| [0023](../gaps/0023-tamper-evident-audit-trail-unification.md) | Tamper-evident audit trail unification | `tantra-exec-audit` | high |
| [0024](../gaps/0024-no-ci-for-rust-repos.md) | No CI for 7 Rust repos | root (plan 0023) | critical |
| [0025](../gaps/0025-reproducible-builds-lockfiles-toolchain.md) | Non-reproducible builds (lockfiles, toolchain) | root (plan 0023) | high |
| [0026](../gaps/0026-licensing-files-and-attribution.md) | Licensing files and attribution | root (plan 0023) | medium |
| [0027](../gaps/0027-live-broker-session-gateway-and-static-egress.md) | Live-broker session gateway and static egress | `tantra-runtime` (plan 0022) | high |
| [0028](../gaps/0028-configuration-contract-and-legacy-env.md) | Configuration contract and legacy env prefixes | `tantra-runtime-config` | medium |
| [0029](../gaps/0029-generated-artifact-drift.md) | Generated-artifact drift | generator repo + CI check | high |

## 2. Component Specifications & Phases

### 2.1 Cross-cutting themes

- **Order safety and idempotency** — 0010, 0013: a client order id on every path, unknown-outcome handling, one shared fail-closed risk state.
- **Data honesty** — 0012: nothing synthetic is shown or returned as real.
- **Secrets** — 0011: redacted `Debug`, no tokens in URLs or logs.
- **Restart-safe state** — held in root plan 0022 (persistence of order ledger, approvals, trading state).
- **Time** — 0020: IST trading day, no naive datetimes.
- **Duplicated models and math** — 0014, 0015, 0016, 0019, 0021.
- **Contracts** — 0018, 0022, 0029.
- **Audit** — 0023.
- **Build, CI, licensing** — 0024–0026, executed in plan 0023.
- **Live deployment** — 0027, 0028, executed in plan 0022.

### 2.2 Canonical-owner matrix (condensed)

| Family | Canonical owner | Strategy | Root gap |
|---|---|---|---|
| Normal CDF / erf (7 copies) | `tantra-core::analytics::distribution` + one `erf` | delete copies, bind via wheel/WASM | 0015 |
| Options pricing (BS/IV/greeks) | `tantra-market-pricing` | wheel + WASM; Python and TS consume | 0015 |
| Indicators / studies | Python `tantra_library`; Rust `tantra-market-indicators` as streaming twin | golden parity vectors; retire TS/SDK copies | 0016 |
| Position/lot/account/product models | `tantra-core` DTOs + `tantra-ledger-portfolio` | one model; others map | 0014 |
| Calendars / holidays | `tantra-core::TradingCalendar` | delete `MarketCalendar`, reader copies | 0019 |
| Instrument master / symbology | `tantra-core` ports + `tantra-market-store` | one resolver via wheel | 0019 |
| Broker integrations | Rust exec/market crates | Python adapters conform or delegate | 0017 |
| Fill / simulation | `tantra-exec-paper` | py via wheel; delete `l2_sim` | 0021 |
| Pre-trade checks | `tantra-risk` | remove Python and router fallbacks | 0013 |
| Audit trails | `tantra-exec-audit` hash chain | persistence audit wraps chain entry | 0023 |
| OpenAPI and clients | `openapi.v2.json` from `tantra-runtime-api-rest` | generate clients; CI drift check | 0022 |
| Corporate actions | core types, `tantra-market-normalizer` + ledger | data consumes via wheel | 0019 |
| Lakehouse manifest/ref | `tantra-market-store` | atomic ref CAS, byte-compat fixtures | 0018 |
| Performance/risk metrics | `tantra-core::analytics` | retire float Python/TS copies | 0015 |
| PriceBand | `tantra-core` | `pub use` in finance; Result constructor | 0014 |
| Config / env loading | `tantra-runtime-config` | one `resolve_runtime()`; drop legacy prefixes | 0028 |

### 2.3 Waves

**Wave 0 — stop the bleeding** (small, high-leverage fixes; no feature work lands before the gate)
1. Data: ~~[tantra-data 0027](../../tantra-data/docs/gaps/README.md#closed-gaps)~~ *(closed 2026-11-25)*; freeze `gc` until [0029](../../tantra-data/docs/gaps/0029-gc-reachability-and-grace.md) lands.
2. Orders: [exec 0004](../../tantra-exec/docs/gaps/0004-idempotent-submit-and-outcome-unknown.md) and [adapters 0008](../../tantra-adapters/docs/gaps/0008-order-idempotency-and-replay.md) — send client order ids; never auto-retry order POSTs.
3. Secrets: [market 0010](../../tantra-market/docs/gaps/0010-ws-client-resilience-and-token-logging.md) — stop logging tokens.
4. Serving: [runtime 0020](../../tantra-runtime/docs/gaps/0020-fail-closed-bind-and-cors.md) and [0028](../../tantra-runtime/docs/gaps/0028-strategy-crate-concrete-executor-and-nested-runtime.md).
5. Risk: [risk 0006](../../tantra-risk/docs/gaps/0006-fail-closed-reference-data.md) and [0007](../../tantra-risk/docs/gaps/0007-modify-order-bypasses-halts.md).
6. Agent: [agent 0011](../../tantra-agent/docs/gaps/0011-mcp-stub-tools-fabricate-results.md) and [0012](../../tantra-agent/docs/gaps/0012-propose-trade-untrusted-ai-boundary.md).
7. Fabricated data: [ui-web 0079](../../tantra-ui-web/docs/gaps/0079-option-chain-fabricated-fields.md) and [ui 0008](../../tantra-ui/docs/gaps/0008-synthetic-bars-in-run-tune-suggest.md) — remove or label.
8. Root: [0024](../gaps/0024-no-ci-for-rust-repos.md) and [0025](../gaps/0025-reproducible-builds-lockfiles-toolchain.md) — CI and lockfiles protect everything after.

**Gate**: no known path loses data, double-submits an order, logs a credential or presents fabricated data as real; CI runs on every Rust repo; `Cargo.lock` tracked.

**Wave 1 — correctness and durability**
1. Ledger 0014–0019 (corporate-action scoping, `apply_fill` side, exec-id dedupe).
2. Risk 0008–0010.
3. Exec 0005–0009 (durable order-id map, reconcile, secret types).
4. Runtime 0021, 0026, 0029–0031.
5. Strategies 0009, 0010 (stops leave `SimulatedContext`; order idempotency key).
6. FFI 0003 (Python `tantra.risk` reaches the compiled `RiskEngine`).

**Gate**: per-repo gates green (`cargo fmt --check`, `cargo clippy --all-targets -- -D warnings`, `make check`, targeted `cargo test -p <crate> --test <bin> --profile prod`, `make prod`; Python `ruff`, `mypy --strict`, `pytest -q`); restart-safe order state demonstrated.

**Wave 2 — de-duplication and contracts**
Root [0014](../gaps/0014-unified-financial-enums-and-position-model.md)–[0019](../gaps/0019-calendar-instrument-master-corporate-actions-sources.md), [0021](../gaps/0021-simulation-fill-model-unification.md), [0022](../gaps/0022-canonical-openapi-and-generated-clients.md), [0029](../gaps/0029-generated-artifact-drift.md), sequenced with 0019 P4.x (see §3).

**Gate**: each family in §2.2 has one owner and no surviving copy; golden-parity and OpenAPI drift checks run in CI.

**Wave 3 — platform**: root plans [0022](0022-future-deployment-architecture.md) (containers, HA, observability, secrets, live gateway 0027, config 0028) and [0023](0023-build-ci-release-engineering.md) (shared target, versioning, licensing 0026, SBOM).

**Gate**: reproducible build and release of every repo; documented deployment mode runs end to end.

## 3. Relationship to Other Plans

Overlap with root plan 0019 (0019 owns the code move; 0021 owns the correctness gap beside it):

| 0019 item | This plan | Note |
|---|---|---|
| P2.7 persistence wiring | runtime 0021 | wire once; durable order state is the acceptance test |
| P4.1 / P4.2 cost tables, analytics | root 0015 | analytics home first, then dedupe CDF/metrics |
| P4.5 Python models to wheel | root 0014 | one position/lot model |
| P2.1 sim clone | root 0021 | extends into Python harnesses |
| P2.4 / P2.5 adapters | root 0017 | safeguards must carry client order ids |
| P4.6 `make verify-architecture` | root 0024 / 0029 | hook drift checks into the same CI job |
| P5.1 `tantra-serve` | runtime 0026 | fail-closed serving requirements apply |

Dependencies of active feature plans:
- 0008 (TSG) and 0009 (Qullamaggie) live trading need root 0010, 0013 and 0027.
- 0017 / 0018 (options) need root 0015 and ui-web 0079.
- 0011 (lakehouse) needs root 0018.
- 0014 (experimental analysis) needs root 0020.
- Designs 0005 (agent orchestration over ACP) and 0006 (runtime API surface) stay in force; wave 1 runtime items must not regress 0006 R0–R3.

## 4. Exit Criteria

1. All 5 critical gaps closed and recorded in their repo indices.
2. Zero fabricated-data paths: unavailable capability returns `PortError::unavailable` with a filed gap.
3. Every order path (REST, MCP, CLI, Python, strategies) carries an idempotency key; no order POST is auto-retried.
4. One shared, fail-closed risk state gates every entry point.
5. CI green in all 16 repos; lockfiles and toolchain pinned.
6. Root and per-repo indices and `.agents/HANDOFF.md` updated per `.agents/rules/gap-tracking.md`; closed documents removed.
