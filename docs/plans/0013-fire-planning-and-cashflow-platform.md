# 0013 — FIRE Planning, Cashflow & Retirement Simulation Platform (`Elicherla01/fireapp` Full-Stack Incorporation)

**Status**: Proposed (2026-11-18) — Track **T19**

Source inspiration: [`Elicherla01/fireapp`](https://github.com/Elicherla01/fireapp/tree/main) ("FIRE Works" — Next.js 15 / React 19 / Radix UI interactive financial independence simulator).
Decision: incorporate **natively from L5 UI down to L1 (`tantra-ledger`)**, leaving **`tantra-core` (L0) completely untouched** (FIRE retirement/wealth planning is an allocation/performance domain concern, not a core market/order-execution kernel primitive — it reuses existing `tantra_core::{Money, Currency}` and `SplitMix64` as read-only inputs). Obeys every `tantra-labs` invariant (strict L0–L6 DAG, **Zero-Floats** `Decimal` / `decimal.js`, Zero-I/O & Zero-Clock domain cores, `Caller`-scoped revision-CAS persistence, OpenAPI 3.1 schema generation, WASM precision kernel, and Agent Rules R1–R4).

---

## 0. Executive Summary & Objective

`fireapp` provides a clean 6-step Financial Independence & Early Retirement (FIRE) workflow tuned for Indian investors (30× / 33× multipliers vs US 25×, INR Lakh/Crore formatting, itemized vs lump-sum expenses, annual salary SIP step-up, Nominal vs Real compounding chart, 5 FIRE archetypes, 3-bucket post-FIRE cashflow simulator, and "Engineer's 3 Pillars" linking equity momentum compounding, automated OTM theta cashflow, and quantitative risk stops).

In its standalone form, `fireapp` is purely ephemeral browser JS (`f64` `number` / `Math.pow`), manually re-typed net worth, static text for the 3 Pillars, deterministic constant CAGR (no sequence-of-returns stress), and zero tax/cost awareness.

Incorporating `fireapp` across `tantra-labs` elevates it from a standalone calculator into a **closed-loop, portfolio-grounded, risk-tested wealth & cashflow subsystem**:
- **Single deterministic Decimal kernel** in **`tantra-ledger-allocation`** (`L1`, Zero-I/O, Zero-Clock, `wasm32`-clean — shared by REST, Python FFI, Rust WASM/TUI/CLI, MCP/chat tools, and Next.js Web WASM) with **zero changes to `tantra-core`**.
- **Real portfolio & tax grounding**: one-click hydration of starting corpus, equity/debt/options margin splits, and realized `greeks.theta` from live `PortfolioStore` / `PortfolioSnapshot`, plus Indian Finance Act 2025 STCG (20%) / LTCG (12.5% above ₹1.25L) tax drag and block-bootstrap Sequence-of-Returns Risk (SoRR) failure probability.
- **Persistent multi-plan UX**: per-user revision-CAS `fire_plans` synced via `ProfileStore`, surfaced across `tantra-ui-web` (`/fire`, Workspace Tab, and Portfolio Detail → **FIRE Runway** tab), `tantra-ui` (Leptos CSR / TUI / `tantra fire` CLI), and `tantra-agent` chat/MCP tools.

---

## 1. Source Analysis & Architectural Re-Engineering

### 1.1 Capabilities Harvested from `Elicherla01/fireapp`
1. **Expenses Engine**: Itemized breakdown across `Essentials`, `Security`, `Discretionary` (9 India-calibrated defaults + add/remove custom items + proportion bar) vs Quick Total lump sum.
2. **India-Calibrated Multiplier & SWR Matrix**: `25×` (4.00% SWR US Trinity), `30×` (3.33% SWR India recommended), `33×` (3.00% SWR 40y horizon), `40×` (2.50% SWR Fat FIRE), continuous slider `20×–50×`.
3. **Monthly Discrete Compounding & Crossover Engine**:
   - Monthly step iteration ($\text{Corpus}_t = \text{Corpus}_{t-1} \cdot (1 + r/12) + \text{SIP}_y$), annual step-up ($\text{SIP}_{y+1} = \text{SIP}_y \cdot (1 + \text{stepUp})$), intra-year inflation-adjusted target crossover detection `(years_to_fire, fire_age, fire_corpus_at_achieve)`.
4. **Interactive Compounding Chart + Math Disclosure**: Accumulated Portfolio vs Invested Principal vs Inflation-Adjusted Target, **Nominal (₹ Future) vs Real (Today's ₹)** toggle, crossover milestone callout, and Formula/Assumptions/"Hockey Stick" disclosure accordion.
5. **5 FIRE Archetypes**: Lean (`0.75×` burn @ `22×`), Standard (`1.00×` @ active multiplier), Fat (`1.35×` burn @ `40×`), Coast FIRE (corpus needed today at real spread $r - i$ to reach target by age 58), Barista FIRE (assuming 40% active consulting coverage).
6. **Post-FIRE 3-Bucket Cashflow & 3 Pillars**: Equities (`1.2%` dividend/yield), Debt/Arbitrage Runway (`6.8%` post-tax yield), Options Theta Margin (`1.5%/mo` cashflow), plus references to Stage-2/VCP equity leaders, OTM strangles/covered calls, and 1–2% per-trade stop risk.
7. **Career Persona Presets**: Young Engineer (26y), Tech Lead / Staff (35y), Director / Principal (44y), Coast FIRE Aspirant (32y) + one-click clipboard summary export.

### 1.2 Architectural Upgrades Required by `tantra-labs` Governance
1. **Protect `tantra-core` (Zero L0 Changes)**: Place all FIRE planning domain models (`FirePlanConfig`, `FireSimulationReport`, `FireArchetypeCard`, `CashflowBucketConfig`, `SorStressResult`), glidepaths, and SWR sustainability metrics in **L1 (`tantra-ledger`)**. Re-use existing `tantra_core::{Money, Currency}` and `tantra_core::analytics::distribution::SplitMix64` directly without adding personal-finance bloat to `tantra-core`.
2. **Zero-Floats Compliance**: Replace every JS `number` / `f64` monetary or rate calculation with `rust_decimal::Decimal` (`tantra-ledger`), string-encoded JSON decimals across the WASM/OpenAPI boundary, `decimal.js` in TypeScript, and `decimal.Decimal` in Python.
3. **L1 Purity & Explicit Clock/Defaults**: Keep `tantra-ledger-allocation::fire` and `tantra-ledger-performance::swr` Zero-I/O, Zero-Clock, and jurisdiction-neutral at the type level; parameterize tax/SWR/persona presets cleanly (`India` Finance Act 2025 defaults live as named preset constructors rather than hardcoded magic constants).
4. **Real Ledger, Tax & SoRR Integration**:
   - Re-use `tantra_core::analytics::distribution::SplitMix64` for deterministic seeded Sequence-of-Returns bootstrap simulation across post-FIRE withdrawal years (`sorr_survival_pct`, percentile bands).
   - Integrate Finance Act 2025 STCG/LTCG drag when comparing nominal gross CAGR vs post-tax net CAGR.
   - Connect "Engineer's 3 Pillars" directly to real `tantra-strategies` (`alpha30`, `options.py` theta strangles) backtest outputs and `tantra-risk` position sizing / stop limits.
5. **Bounded Persistence & Auth**: Store per-user `FirePlanConfig` records inside `ProfileStore` (CAS revision check, size/count caps, strict `Caller` isolation). Never trust unauthenticated mutations.

---

## 2. Per-Repo Plan Index (Full Stack L1 → L6)

| Tier | Capability | Provider Plan |
|---|---|---|
| **L1** | Canonical `Decimal` FIRE domain types & engine (`tantra-ledger-allocation::fire` + `fire_buckets` glidepaths) and SWR sustainability metrics (`tantra-ledger-performance::swr`), golden & proptest suites (`wasm32`-clean) | [`tantra-ledger` plan 0006](../../tantra-ledger/docs/plans/0006-fire-bucket-glidepath-and-swr-metrics.md) |
| **L3A** | `tantra-runtime-api::fire` OpenAPI (`schemars`) wire DTOs, `Profile.fire_plans` CAS persistence (`MAX_FIRE_PLANS`), `/api/{v1,v2}/planning/fire/simulate`, `/api/{v1,v2}/planning/fire/from-portfolio/{account}`, live ledger/Greeks/tax/backtest seeding, OpenAPI regen, MCP wiring | [`tantra-runtime` plan 0008](../../tantra-runtime/docs/plans/0008-fire-planning-persistence-and-rest-api.md) |
| **L3B** | ReadOnly `fire_simulate` & `fire_portfolio_check` tools (`tantra-agent-chat-tools`), MCP gateway tools (`tantra-agent-mcp` using `tantra-ledger-allocation` per existing Rule R4), AI Wealth/FIRE Copilot persona grounding (strict R1–R4 compliance) | [`tantra-agent` plan 0015](../../tantra-agent/docs/plans/0015-fire-planning-chat-and-mcp-tools.md) |
| **L4** | Codegen `tantra.wire.fire` + PyO3 `tantra.fire` wheel module over `tantra-ledger-allocation::fire` (`simulate_fire_runway`, `calculate_fire_archetypes`, `simulate_post_fire_cashflow`, `run_sor_stress`) | [`tantra-ffi` plan 0005](../../tantra-ffi/docs/plans/0005-fire-planning-python-bindings.md) |
| **L5B** | `vyapaar-ui-web-wasm` bindings (`tantra-ledger-allocation`) + Next.js `/fire` route, Workspace `"fire"` tab, `PortfolioDetailScreen` **FIRE Runway** tab, full `fireapp` 6-step parity + live portfolio sync + theme tokens | [`tantra-ui-web` plan 0015](../../tantra-ui-web/docs/plans/0015-fire-works-simulator-and-cashflow-ui.md) |
| **L5A** | `tantra-ui-core` `FirePlannerViewModel`, `tantra-ui-app` `AppRoute::Fire` Leptos view, `tantra fire` CLI (`DisplayBlock`), TUI FIRE panel (consuming `tantra-ledger-allocation::fire`) | [`tantra-ui` plan 0009](../../tantra-ui/docs/plans/0009-fire-planning-workstation-cli-tui-wasm.md) |
| **L6** | Pillar 1 (`alpha30`/Stage-2) + Pillar 2 (OTM theta strangles) strategy templates & FIRE backtest cashflow bridge | [`tantra-strategies` plan 0004](../../tantra-strategies/docs/plans/0004-fire-cashflow-theta-and-compounding-templates.md) |

> **Note on `tantra-core` (L0), `tantra-market` / `tantra-exec` (L2), and `tantra-risk` (L1)**: **Zero edits required** in `tantra-core`, L2, or `tantra-risk`. `tantra-core` remains strictly limited to foundational market/trading primitives (`Money`, `Currency`, `SplitMix64`); Pillar 1–3 signals/theta/stop enforcement already exist in `tantra-market`, `tantra-exec`, and `tantra-risk`.

---

## 3. Bottom-Up Build Order (Track T19)

| Phase | Track ID | Tier | Deliverable | Depends on |
|---|---|---|---|---|
| **P0** | **T19.1** | L1 | `tantra-ledger` `0006`: `tantra-ledger-allocation::{fire, fire_buckets}` (`Decimal` engine, 5 archetypes, 3-bucket cashflow & glidepaths, `SplitMix64` SoRR bootstrap, golden + proptest) & `tantra-ledger-performance::swr` | — |
| **P1** | **T19.2** | L3A | `tantra-runtime` `0008`: `tantra-runtime-api::fire` (`schemars`), `Profile.fire_plans`, `/api/{v1,v2}/planning/fire/{plans,simulate,from-portfolio}`, OpenAPI regen | P0 |
| **P2** | **T19.3** | L3B | `tantra-agent` `0015`: `fire_simulate` + `fire_portfolio_check` (`tantra-agent-chat-tools`), MCP gateway tools (`tantra-agent-mcp`), R1–R4 tests | P0, P1 ports |
| **P3** | **T19.4** | L4 | `tantra-ffi` `0005`: `tantra.wire.fire` codegen + `tantra.fire` PyO3 surface + parity tests | P0 |
| **P4** | **T19.5** | L5B | `tantra-ui-web` `0015`: `vyapaar-ui-web-wasm` (`tantra-ledger-allocation`) + `/fire`, workspace tab, portfolio tab, full UI | P0, P1 (OpenAPI) |
| **P5** | **T19.6** | L5A | `tantra-ui` `0009`: `tantra-ui-core`, `AppRoute::Fire` (Leptos), `tantra fire` (CLI), TUI tab | P0, P1 |
| **P6** | **T19.7** | L6 | `tantra-strategies` `0004`: Pillar 1 & 2 FIRE cashflow templates + empirical CAGR/theta export | P0, P3 |

---

## 4. Verification & Acceptance Gate

Every tier must pass its canonical verification matrix before cleanup per `.agents/rules/gap-tracking.md` §4:
- **Zero-Floats & `tantra-core` untouched audit**: `rg '\\bf(32|64)\\b' tantra-ledger/crates/tantra-ledger-{allocation,performance}/src/` returns zero matches; `git -C tantra-core status` remains clean; Web UI monetary state uses `decimal.js` and string-serialized WASM calls.
- **Cross-layer parity**: One canonical golden fixture (`fire_golden.json`) produces byte-identical `Decimal` projections across `tantra-ledger-allocation` Rust tests, `tantra-runtime` REST `/planning/fire/simulate`, `tantra-ffi` `tantra.fire`, and `vyapaar-ui-web-wasm`.
- **Rust gate**: `cargo fmt --check`, `cargo clippy --workspace --all-targets --profile prod -- -D warnings`, targeted `cargo test --profile prod`, `cargo check -p ... --target wasm32-unknown-unknown`, `make prod`.
- **Web UI gate**: `npx tsc --noEmit`, `npm run lint`, `npx vitest run`, `npm run build`.
- **Python gate**: `ruff check . && ruff format --check .`, `mypy --strict`, `pytest -q`.
