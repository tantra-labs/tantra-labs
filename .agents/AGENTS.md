# Tantra Labs Ecosystem Instructions & Agent Governance (`.agents/AGENTS.md`)

This is the canonical instruction file for AI coding agents, autonomous researchers, and software engineers across the **Tantra Labs (व्यापार)** ecosystem. All autonomous tools (Claude, Gemini, Antigravity, OpenCode, Cursor, Codex) and subagents must strictly adhere to the architecture, project settings, checklists, and binding rules in `.agents/`.

> **Structured Governance**: Machine-readable project settings live in `.agents/config/project-settings.json`. Granular binding rules live in `.agents/rules/` (automatically inherited by all 14 submodules via `<repo>/.agents/rules -> ../../.agents/rules`). Mandatory review and pre-commit checklists live in `.agents/checklists/`.

---

## 1. `.agents/` Folder Structure & Compatibility Standard

### 1.1 Canonical Directory Layout
All autonomous tooling, prompts, settings, checklists, and handoff state live in `.agents/` at the workspace root (and per-repo `.agents/`):

```text
tantra-labs/
├── .agents/
│   ├── README.md                              <-- Structure map & agent load order
│   ├── AGENTS.md                              <-- Master instructions (synced with /AGENTS.md)
│   ├── HANDOFF.md                             <-- Active cross-repo handoff state
│   ├── settings.json                          <-- Tool allow/deny permissions
│   ├── scheduled_tasks.lock                   <-- Runtime scheduler lockfile
│   ├── config/
│   │   ├── config.json                        <-- Sandbox & CLI command policy
│   │   └── project-settings.json              <-- Pinned settings (design, coding, testing, security, CI)
│   ├── rules/                                 <-- Binding rules shared across all submodules
│   │   ├── architecture-and-coupling.md       <-- Tier DAG (L0–L6), cycle bans, UI/REST decoupling
│   │   ├── interface-first-and-modularity.md  <-- Trait/Protocol ports, Zero-I/O, Zero-Floats, clock injection
│   │   ├── coding-and-ddd.md                  <-- Rust/Python/TS coding standards, DDD, naming hygiene
│   │   ├── testing-and-verification.md        <-- Parallel tests/, TDD, proptest/golden vectors, CI gates
│   │   ├── scalability-and-concurrency.md     <-- Bounded channels, async I/O, persistence, memory bounds
│   │   ├── security-and-secrets.md            <-- Fail-closed auth, Caller scoping, crypto, SQL/eval safety
│   │   ├── build-discipline.md                <-- Canonical `prod` profile invariant
│   │   ├── gap-tracking.md                    <-- Plan/gap filing & cleanup lifecycle
│   │   ├── handoff-hygiene.md                 <-- HANDOFF trimming discipline
│   │   ├── no-recon.md                        <-- Subagent zero-recon enforcement
│   │   └── subagent-discipline.md             <-- Max 2 concurrent subagents, self-contained prompts
│   ├── checklists/
│   │   ├── design-review.md                   <-- Pre-implementation architecture/security gate
│   │   └── pre-commit-gate.md                 <-- End-of-turn verification checklist
│   └── skills/system/run-workflow/SKILL.md    <-- Workflow orchestration skill
├── .claude -> .agents                         <-- Vendor compatibility symlink
├── .gemini -> .agents                         <-- Vendor compatibility symlink
└── AGENTS.md                                  <-- Mirrored root entrypoint
```

* **Zero Vendor Duplication**: Standalone `.claude`, `.gemini`, `.cursor`, or `.vscode` directories with duplicate prompts or state are **strictly forbidden**. Vendor compatibility is maintained solely via symlinks (`.claude -> .agents`, `.gemini -> .agents`).
* **Submodule Rule Inheritance**: Every submodule mounts `.agents/rules -> ../../.agents/rules` so updates to `.agents/rules/` enforce consistency workspace-wide.

### 1.2 Inter-Agent Handoff Protocol (`HANDOFF.md`)
* Active batches maintain `.agents/HANDOFF.md` recording: (1) Phase/Slice Status, (2) Decisions & Discoveries, (3) Immediate Next Step, (4) Operating Invariants.
* Keeping `HANDOFF.md` current and concise (trimming resolved/closed/superseded items in the same edit) is binding per `.agents/rules/handoff-hygiene.md`.

---

## 2. Architecture, Bounded Contexts & Coupling Rules

Full rules: `.agents/rules/architecture-and-coupling.md` & `.agents/config/project-settings.json`.

### 2.1 Strict Tier DAG (L0–L6) & Workspace Taxonomy

| Tier | Subsystem | Directory | Language | Bounded Context & Responsibility |
|---|---|---|---|---|
| **L0** | **Kernel** | `tantra-core/` | Rust | Canonical value objects (`Price`, `Quantity`, `Money`), wire contracts, OpenAPI 3.1 `schemars` schemas, `ports.rs`, and `Decision`. |
| **L1** | **Heart** | `tantra-ledger/` | Rust | OMS state machine (`oms`), FIFO tax-lot accounting (`portfolio`), double-entry ledger (`journal`), allocation, performance. |
| **L1** | **Gate** | `tantra-risk/` | Rust | Sub-15 µs pre-trade risk engine (SEBI algo ID, OTR circuit breakers, price bands, reduce-only, freeze limits). |
| **L2** | **Eye** | `tantra-market/` | Rust | Multi-broker binary WebSockets, tick coalescing, 100+ StockSharp indicators, pricing, finance cost schedules, Parquet lakehouse. |
| **L2** | **Hand** | `tantra-exec/` | Rust | Token-bucket rate limiter, freeze slicer, headless TOTP auth, Smart Order Router (`ResilientRouter`), hash-chained fsynced audit WAL. |
| **L3** | **Agent** | `tantra-agent/` | Rust + Python | Autonomous research loop, MCP server, prompt replayer, chat tools, analytics, Odysseus genetic synthesizer. |
| **L3** | **House** | `tantra-runtime/` | Rust (Tokio) | Supervised actor pipeline, REST/WS API server, Strategy Tester (`backtest`), persistence (SQLx), Strategy Enhancer. |
| **L4** | **Soul** | `tantra-ffi/` | Rust (PyO3) | `tantra` PyPI wheel, Arrow C-Stream `PyCapsule` zero-copy bridge, GIL-safe `StrategyRunner`. |
| **L5** | **Face** | `tantra-ui/`, `vyapaar-ui-web/` | Rust / TS | CLI, TUI, WASM Studio (`tantra-ui`), and Next.js web application (`vyapaar-ui-web`). |
| **L6** | **Python** | `tantra-strategies/`, `tantra-adapters/`, `tantra-data/`, `tantra-examples/`, `tantra-docs/` | Python / DuckDB / MD | Strategy SDK, broker ACL adapters, DuckDB/Parquet lakehouse, learning examples, MkDocs documentation. |

### 2.2 Non-Negotiable Coupling Invariants
* **DAG Only — Zero Cycles / Zero Upward Edges**: Dependencies flow strictly `L6 → L5 → L4 → L3 → L2 → L1 → L0`. Never introduce cross-repo cycles (e.g., `tantra-market` ↔ `tantra-agent`) or upward edges (`tantra-ledger` → `tantra-market`).
* **Agent Tier Rules R1–R4**: Preserved as CI tests in `tantra-agent/crates/tantra-agent-chat/tests/dependency_rules.rs` (no `tantra-runtime-*`/`tantra-exec-*`/`tantra-market-*` deps in `tantra-agent-*`; chat and trader-loop isolated; `tantra-agent-tools` pure; only `tantra-agent-chat-tools` may depend on `tantra-ledger-*`).
* **No Concrete Brokers in Strategy Code**: Strategy/orchestration crates (`tantra-runtime-strategy`) inject `Arc<dyn BrokerExecutor>` / ports; never wire concrete executors (`ZerodhaExecutor`) or spawn `tokio::runtime::Runtime` inside strategy dispatch.
* **Facade Convention (`docs/design/0001` §4.2)**: Each multi-crate workspace exposes one repo-named thin re-export facade crate; avoid stub crates or downstream re-export shims.

### 2.3 Event-Driven Pipeline
```mermaid
flowchart LR
    MarketEvent["MarketEvent (Ticks / Bars)"] --> Feed["tantra-market (Feed)"]
    Feed --> SignalEvent["SignalEvent (Indicators / Alpha)"]
    SignalEvent --> Strategy["Strategy / AI (tantra-agent)"]
    Strategy --> OrderEvent["OrderEvent (Order Request)"]
    OrderEvent --> Risk["tantra-risk (Pre-Trade Gate)"]
    Risk --> Router["tantra-exec (Execution Router)"]
    Router --> FillEvent["FillEvent (Exchange Execution)"]
    FillEvent --> OMS["tantra-ledger (OMS State Machine)"]
    OMS --> LedgerEvent["LedgerEvent (Double-Entry FIFO Ledger)"]
```

---

## 3. Interface-First Design, Modularity & Domain Purity

Full rules: `.agents/rules/interface-first-and-modularity.md` and `.agents/rules/coding-and-ddd.md`.

* **Interface-First Ports**: Define Rust `trait` ports or Python `@runtime_checkable Protocol` interfaces before implementations (`tantra-core/src/ports.rs`, `BrokerExecutor`, `CredentialStore`, `HttpTransport`, `WebSocketTransport`). Never branch on concrete types (`isinstance(context, SimulatedContext)`) or return stringly-typed `Result<_, String>` across adapters.
* **Single Source of Truth DTOs**: Shared wire contracts and OpenAPI 3.1 schemas derive from `tantra-core` via `schemars`; avoid diverging local `Order` / `OrderStatus` models or ad-hoc unversioned REST client calls.
* **Zero-I/O & Zero-Clock Purity**: Core domain crates (`tantra-core`, `tantra-ledger`, `tantra-risk`, `tantra-runtime-strategy`, `tantra-agent-tools`) contain zero network/disk/DB I/O and never query `Utc::now()`, `SystemTime::now()`, or `Instant::now()`. Inject explicit timestamps at the adapter boundary.
* **Zero-Floats Policy**: `f32`, `f64`, and Python `float` are **strictly forbidden** for prices, quantities, balances, fees, statutory taxes, price collars, and margin math. Use `rust_decimal::Decimal` / `decimal.Decimal` / Arrow `Decimal128(38, 8)`.
* **WASM & Cross-Arch Targetability**: Compute crates (`tantra-core`, `tantra-market-indicators`, `tantra-ledger-portfolio`, `tantra-ui-core`) must compile cleanly to `wasm32-unknown-unknown`, `x86_64`, and `aarch64`.
* **DDD & Naming Hygiene**: Rich aggregates (`OrderStateMachine`, `Portfolio`, `RiskEngine`) over property bags; explicit `PortError::unavailable` instead of fake empty responses; canonical `tantra`/`TANTRA_` naming (no new `honba`/`vyapaar` symbols).

---

## 4. Testing, TDD & Verification Standards

Full rules: `.agents/rules/testing-and-verification.md` & `.agents/checklists/pre-commit-gate.md`.

* **Parallel Test Directory Rule (ZERO EXCEPTIONS)**: All tests live in `tests/` parallel to `src/` (Rust crates and Python packages). Inline `#[test]` or `#[cfg(test)] mod tests` blocks in `src/**/*.rs` are **strictly forbidden**.
* **TDD (Red → Green → Refactor)**: Write failing contract/security/regression tests in `tests/` before modifying `src/`.
* **Property & Golden Vectors**: Use `proptest` (Rust) / `hypothesis` (Python) for numeric/FIFO/quantization invariants, and golden byte/JSON/Arrow vectors for broker protocols, statutory fees, FFI parity, and LLM prompt replay.
* **Canonical Verification Matrix**:
  - **Rust**: `cargo fmt --check`, `cargo clippy --workspace --all-targets --profile prod -- -D warnings`, `make check`, `make test`, `make prod` (note: if `tantra-runtime-api-rest` hits 15 GiB LTO OOM on full test-bin link, run `make check` + targeted test binaries).
  - **Python**: `ruff check . && ruff format --check .`, `mypy --strict`, `pytest -v`.
  - **FFI (`tantra-ffi`)**: `cargo check --workspace --profile prod`, `maturin develop --profile prod`, `pytest -q`.
  - **Web (`vyapaar-ui-web`)**: `npx tsc --noEmit`, `npm run lint`, `npx vitest run`, `npm run build`.
  - **Docs (`tantra-docs`)**: `mkdocs build --strict`.

---

## 5. Scalability, Concurrency & Resource Bounds

Full rules: `.agents/rules/scalability-and-concurrency.md`.

* **Bounded Channels Only**: Never use `tokio::sync::mpsc::unbounded_channel` in feeds, broker sockets, SSE, or actors. Use bounded channels with explicit `BackpressurePolicy`.
* **No Sync I/O or Global `std::sync::Mutex` on Tokio**: Never run sync `std::fs` or hold global `std::sync::Mutex` locks inside Axum handlers, auth middleware, or Tokio actors; use `tokio::fs`, SQLx pools, or sharded async locks.
* **No Nested `Runtime::block_on`**: Never build a Tokio `Runtime` and call `block_on` inside strategy/library code.
* **Bounded Payloads & Persistent State**: Cap `axum::body::to_bytes` reads and per-socket WS maps; close upstream WebSockets on Next.js `ReadableStream.cancel()`; persist `OrderLedger`, `ApprovalQueue`, and `TradingState` via `tantra-runtime-persistence`.

---

## 6. Security, Auth & Secrets Hygiene

Full rules: `.agents/rules/security-and-secrets.md`.

* **Fail-Closed Auth**: Mount `auth_middleware` whenever `config.auth.is_enabled()` (both `tokens_file` **and** JWT validators — never gate on `tokens_file` alone). Fail startup on unauthenticated non-loopback binds unless explicitly overridden.
* **Tenant Isolation & Idempotency**: Extract `Caller` on `/ws/chat`, `/profile`, `/portfolio`, and user routes to scope sessions by `(caller_id, workspace)`. Propagate `Authorization` headers through BFF proxies. Never default keyless `POST /orders` to a constant `"rest"` idempotency key.
* **Audited Crypto & Secret Hygiene**: Use `sha2`, `hmac`, `subtle::ConstantTimeEq`, and full `jsonwebtoken` claim validation (`exp`, `nbf`, `aud`, `iss`) — zero hand-rolled crypto. Redact `Debug` and apply `ZeroizeOnDrop` on `BrokerCredentials`/`SessionTokens`.
* **Injection & CORS Safety**: Parameterized SQL only (`$1`/`?` — even for DuckDB `read_parquet` paths); avoid `eval()` on user expressions and prompt interpolation into generated Python/shell code; allow `AUTHORIZATION` in authenticated CORS headers; verify trusted proxy CIDRs before trusting `X-Forwarded-For`.
* **Untrusted AI Principle**: AI signals deserialize into closed `Decision` (`deny_unknown_fields`) and pass `RiskEngine` unconditionally.

---

## 7. Open-Source Quant Inheritance & Rust/Python Split

* **Jesse**: Declarative `Strategy` / `Parameter(...)` ergonomics and validation metrics.
* **QuantDinger & Lean**: Separation of Data, Alpha, Portfolio Construction, Execution, and Risk models.
* **NautilusTrader**: Actor-based Tokio core, deterministic clock injection, research-live parity, double-entry FIFO ledger.
* **StockSharp**: 100+ streaming indicators, TWAP/VWAP/Iceberg slicers, Odysseus genetic rule builder.
* **NoFX**: Untrusted AI signal generator + closed `Decision` grammar + non-bypassable risk gate + SHA-256 prompt replay.
* **Rust/Python Split**: Rust handles WebSockets, coalescing, sub-15µs `RiskEngine`, OMS, execution routing, and double-entry ledger; `tantra-ffi` bridges via PyO3 (`py.detach` around Rust batch work) and zero-copy Apache Arrow `PyCapsule`; Python handles strategy authoring, ML/AI models, and DuckDB/Polars research.

---

## 8. Binding Operational Rules

Every orchestrator session and spawned subagent across all `tantra-labs` repositories obeys `.agents/rules/`:

1. **Build & Profile Discipline** (`.agents/rules/build-discipline.md`): Canonical profile is always `prod` (`target/prod`). Never run bare `cargo build`, `cargo build --release`, or `cargo test --release`. Run `make prod` before finishing any Rust-modifying turn.
2. **Subagent Discipline** (`.agents/rules/subagent-discipline.md`): Maximum **2 subagents alive simultaneously**; prompts must be self-contained with verified paths, signatures, designs, and verify commands.
3. **Subagent Zero-Recon** (`.agents/rules/no-recon.md`): Subagents execute write-first (~10–15 step budget, at most 2 verification reads); if a required fact is missing, stop and return one precise question.
4. **Plan & Gap Tracking** (`.agents/rules/gap-tracking.md`): Any stub, mock, or hardcoded workaround must file `docs/{gaps,plans}/XXXX-*.md` in the **upstream provider repo**, cite it in code and commit message, and remove + index closed items upon completion.
5. **HANDOFF.md Hygiene** (`.agents/rules/handoff-hygiene.md`): Update `.agents/HANDOFF.md` in the same change that modifies status, discoveries, next steps, or invariants, and trim stale/closed/superseded items immediately.
6. **Review Checklists**: Run `.agents/checklists/design-review.md` before architectural/interface changes and `.agents/checklists/pre-commit-gate.md` before completing any turn.
