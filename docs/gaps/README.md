# Gaps Index — `tantra-labs` (root)

Root-level gaps tracked per `.agents/rules/gap-tracking.md`. Each gap documents an individual
stub, duplicate, or missing feature at the workspace level. Gaps whose root cause lives in a
provider submodule are filed here for cross-repo visibility and cite the provider repo; the
provider repo's own `docs/gaps/README.md` is the implementation tracker.

## Open Gaps

| # | Title | Provider Repo / Scope | Filed |
|---|-------|-----------------------|-------|
| [0001](0001-market-broker-feed-stubs.md) | Real broker WS feed crates (`zerodha`, `upstox`, `fyers`, `angelone`, `dhan`) — **feature tracker, 2 of 5 shipped 2026-11-13**: `tantra-market-dhan` (DhanHQ v2) and `tantra-market-zerodha` (Kite Connect 3) are real; `upstox`, `fyers`, `angelone` are re-added as real crates when their wire protocols are implemented (task T3.3) | `tantra-market` | 2026-11-12 |
| [0010](0010-order-idempotency-end-to-end.md) | End-to-end order idempotency and unknown-outcome handling: client order id never reaches brokers; failover/transport replay double-submits; fills lack exec id | `tantra-exec` (consumers: `tantra-core`, `tantra-ledger`, `tantra-adapters`, `tantra-strategies`) | 2026-11-23 |
| [0011](0011-secrets-leak-debug-logs-urls.md) | Credentials and tokens leak via `Debug`, logs and URLs across Rust and Python | `tantra-exec` secret types (consumers: `tantra-market`, `tantra-runtime`, `tantra-agent`, `tantra-adapters`) | 2026-11-23 |
| [0012](0012-fabricated-data-presented-as-real.md) | Fabricated or synthetic data presented as real (violates `PortError::unavailable` rule) | `tantra-core` (consumers: `tantra-runtime`, `tantra-agent`, `tantra-ui`, `tantra-ui-web`, `tantra-adapters`, `tantra-ffi`) | 2026-11-23 |
| [0013](0013-risk-gate-single-shared-fail-closed.md) | Pre-trade risk gate is not single, shared or fail-closed; Python/LLM/strategy paths bypass it | `tantra-risk` (consumers: `tantra-runtime`, `tantra-agent`, `tantra-ffi`, `tantra-strategies`, `tantra-adapters`) | 2026-11-23 |
| [0014](0014-unified-financial-enums-and-position-model.md) | Unified financial enums and position model (three `Product` enums, five-plus position models) | `tantra-core` (consumers: `tantra-ledger`, `tantra-exec`, `tantra-runtime`, `tantra-ffi`) | 2026-11-23 |
| [0015](0015-pricing-and-quant-math-single-source.md) | Pricing and quant math single source (erf/CDF x7, BS/IV/greeks in Rust/Python/TS, metrics) | `tantra-core` / `tantra-market` (consumers: `tantra-agent`, `tantra-ui`, `tantra-ui-web`, `tantra-ffi`, `tantra-examples`) | 2026-11-23 |
| [0016](0016-indicator-golden-parity-suite.md) | Indicator and study golden-parity suite (`tantra_library` vs `tantra-market-indicators`); retire TS/SDK copies | `tantra-strategies` (consumers: `tantra-market`, `tantra-ffi`, `tantra-ui-web`) | 2026-11-23 |
| [0017](0017-broker-integration-consolidation.md) | Broker integration consolidation (Rust exec vs Python adapters vs wheel kit; one Kite WS client) | `tantra-exec` / `tantra-ffi` (consumers: `tantra-adapters`, `tantra-market`) | 2026-11-23 |
| [0018](0018-lakehouse-manifest-ref-contract.md) | Lakehouse manifest/ref contract: atomic ref CAS, single-writer protocol, Rust/Python byte-compat fixtures | `tantra-data` / `tantra-market` (consumers: `tantra-strategies`, `tantra-ffi`, `tantra-core`) | 2026-11-23 |
| [0019](0019-calendar-instrument-master-corporate-actions-sources.md) | Calendar, instrument master and corporate-action single sources | `tantra-core` (consumers: `tantra-ledger`, `tantra-market`, `tantra-data`, `tantra-adapters`) | 2026-11-23 |
| [0020](0020-time-semantics-ist-trading-day.md) | Time semantics: IST trading day vs UTC, naive datetimes, `date.today()`, missing day rollover | `tantra-core` (consumers: `tantra-risk`, `tantra-ledger`, `tantra-runtime`, `tantra-adapters`, `tantra-data`, `tantra-ui-web`) | 2026-11-23 |
| [0021](0021-simulation-fill-model-unification.md) | Simulation and fill-model unification for Python research harnesses (beyond 0019 P2.1) | `tantra-exec` (consumers: `tantra-ffi`, `tantra-strategies`, `tantra-examples`) | 2026-11-23 |
| [0022](0022-canonical-openapi-and-generated-clients.md) | One canonical OpenAPI document and generated Rust/Python/TS clients | `tantra-runtime` (consumers: `tantra-ffi`, `tantra-ui-web`, `tantra-examples`, `tantra-market`, `tantra-docs`) | 2026-11-23 |
| [0023](0023-tamper-evident-audit-trail-unification.md) | Tamper-evident audit trail unification for SEBI retention | `tantra-exec` (consumers: `tantra-runtime`, `tantra-risk`, `tantra-ledger`) | 2026-11-23 |
| [0024](0024-no-ci-for-rust-repos.md) | No CI for the seven Rust repos; existing pipelines cannot resolve sibling path dependencies | workspace root (consumers: all Rust repos, `tantra-ffi`, `tantra-ui`) | 2026-11-23 |
| [0025](0025-reproducible-builds-lockfiles-toolchain.md) | Reproducible builds: untracked `Cargo.lock`, no toolchain pin, no Python lockfiles | workspace root (consumers: all repos) | 2026-11-23 |
| [0026](0026-licensing-files-and-attribution.md) | Licensing: no LICENSE files, mixed declared licences, third-party attribution | workspace root (consumers: all repos, `tantra-strategies`) | 2026-11-23 |
| [0027](0027-live-broker-session-gateway-and-static-egress.md) | Live-broker session gateway (singleton per API key) and static egress IP | `tantra-exec` (consumers: `tantra-core`, `tantra-runtime`, `tantra-market`, `tantra-adapters`, `tantra-agent`, `tantra-ui`) | 2026-11-23 |
| [0028](0028-configuration-contract-and-legacy-env.md) | Configuration contract: central registry; legacy `HONBA_`/`QUANTCEPT_`/`VYAAPAAR_` env names | `tantra-core` (consumers: `tantra-agent`, `tantra-ui`, `tantra-ffi`, `tantra-exec`, `tantra-examples`, `tantra-adapters`, `tantra-data`, `tantra-ui-web`) | 2026-11-23 |
| [0029](0029-generated-artifact-drift.md) | Generated-artifact drift: duplicate schemas, committed WASM, no regeneration check | `tantra-core`, `tantra-runtime` (consumers: `tantra-ffi`, `tantra-ui-web`) | 2026-11-23 |

## Closed Gaps

| # | Title | Closed In |
|---|-------|-----------|
| 0009 | Stale `docs/plans/README.md` rows `0015`/`0016` showing implemented T21.5–T21.6 / T22.6–T22.8 tracks as "planned" | Closed 2026-11-24: moved plans `0015` (T21.1–T21.6) and `0016` (T22.1–T22.8; `data 0026` & `strategies 0008` closed) to Implemented Plans in `docs/plans/README.md`, noting `tantra-ui-web` gap `0078` remains open for Playwright tests; obsolete `Here is an architectural analysis of the.md` already retired |
| 0002 | Real `tantra-market-feed` / `tantra-market-loaders` implementations — **feature tracker**: the empty stub crates were removed 2026-11-13 (plan 0003); `MarketDataFeed` stays in `core`, lakehouse in `store` (task T3.4) | Closed 2026-11-13 (T3.4): feed traits in `tantra-market-core`, lakehouse/loaders in `tantra-market-store`, and real `MarketDataFeed` implementations exist on top of core (`dhan` `fb82571`, `zerodha` `ad79205`) |
| 0006 | `tantra-exec-angelone` stub | Closed 2026-11-13 (T4.11): real SmartAPI 2.0 `BrokerExecutor` adapter (`tantra-exec` `2258bbb`) — REST executor + SmartStream order feed + `BrokerEnumMap` wire tables + exact-decimal payloads; gap `tantra-exec` 0001 closed |
| 0003 | `tantra-runtime/tantra-indicators` exact duplicate of `tantra-market-indicators` | Deleted 2026-11-13 (plan 0003 Phase 2) — nothing imported it |
| 0004 | `tantra-runtime/tantra-runtime-feed` re-export shim over `tantra-market-store` | Absorbed into `tantra-runtime-api-rest::market_feed` module 2026-11-13 (plan 0003 Phase 2); shim crate deleted, all 25 import sites re-pointed |
| 0005 | `tantra-runtime-market` and `tantra-runtime-test-utils` empty stubs (legacy `honba` names) | Deleted 2026-11-13 (plan 0003 Phase 2) — declared-but-unused in `tantra-runtime-strategy` / `api-rest` |
| 0007 | Facade-crate convention inconsistent across Rust repos | Pinned as ADR + facades added (`tantra-market`, `tantra-exec`, `tantra-runtime`, `tantra-ffi`, `tantra-ui`) 2026-11-13 (plan 0003 Phase 4); see `docs/design/0001-crate-topology-audit-and-target.md` §4.2 |
| 0008 | `tantra-runtime` `workspace.dependencies` legacy honba aliases (`tantra-api`, `tantra-api-rest`, `tantra-backtest`, `tantra-actors`) | Removed 2026-11-13 (plan 0003 Phase 4) — nothing consumed them; `tantra-ffi` unused `tantra-market-*` deps removed in the same batch |

## Related

- [`docs/plans/README.md`](../plans/README.md) — the Implemented table records plan 0003
  (crate-topology consolidation) with its closing batch.
- [`docs/design/0001-crate-topology-audit-and-target.md`](../design/0001-crate-topology-audit-and-target.md)
  — full audit and target arrangement (incl. the pinned facade convention, §4.2).
