# 0003 — Architectural Survey: Coupling, Interfaces, Scalability, Modularity & Security

**Status**: Proposed (architecture & security audit) — filed 2026-11-13  
**Scope**: Full `tantra-labs` superproject (14 Git submodules + `tantra-ui-web`, spanning 9 Rust workspaces / ~60+ crates, 4 Python packages, and a Next.js/TypeScript + WASM web frontend).  
**Method**: Direct verification of `Cargo.toml`, `pyproject.toml`, `package.json`, Rust/Python/TypeScript sources, and workspace invariants against `docs/design/architecture.md` and `docs/ddd-conflict.md`.

---

## 0. Executive Scorecard

| Dimension | Rating | Verdict |
|---|---|---|
| **Loose Coupling** | **Fair (B-)** | Clean intended L0–L6 DAG, undermined by 1 cross-repo cycle (`tantra-market` ↔ `tantra-agent`), an upward L1→L2 edge, concrete broker wiring inside pure strategy dispatch, and unversioned UI/REST glue. |
| **Interface-First Design** | **Strong (A-)** | Strong hexagonal ports (`tantra-core/src/ports.rs`, `BrokerExecutor`, `CredentialStore`, `AgentTool`, Python `Protocol`s), weakened by sync-vs-async trait drift, stringly-typed `BrokerAdapter`, and concrete store types in REST `AppState`. |
| **Scalability** | **Moderate (C+)** | Bounded supervised actors, 15µs zero-alloc risk hot path, Arrow C-Stream FFI, and SQLx/WAL pooling exist, but `unbounded_channel` in 7 WS producers, blocking `std::fs` + global `std::sync::Mutex` on Tokio threads, and `to_bytes(..., usize::MAX)` limit throughput and horizontal scale. |
| **Modularity** | **Good (B)** | Clear bounded-context crates and recent facade standardization (`docs/design/0001-crate-topology-audit-and-target.md`), but `Zero-I/O`/`Zero-Floats` invariants leak in `tantra-market-core`/`tantra-market-finance`/`tantra-risk`, and two parallel UI stacks (`tantra-ui` + `tantra-ui-web`) create duplication. |
| **Security** | **Needs Hardening (C-)** | Strong AI decision guardrails, tamper-evident hash chain, and parameterized SQL, undermined by a **critical JWT-only auth bypass** in REST middleware, IDOR on `/ws/chat`, keyless `POST /orders` idempotency collision, unzeroized plaintext secrets, and custom crypto primitives. |

---

## 1. Loose Coupling

### 1.1 Intended Architecture
`docs/design/architecture.md` and `docs/ddd-conflict.md` prescribe a strict acyclic tier DAG:

```text
L0 (tantra-core)
  ← L1 (tantra-risk, tantra-ledger)
    ← L2 (tantra-market, tantra-exec)
      ← L3 (tantra-agent, tantra-runtime)
        ← L4 (tantra-ffi)
          ← L5 (tantra-ui)
            ← L6 (Python SDK / data / adapters / examples)
```

### 1.2 Verified Coupling Violations

1. **Cross-Repo Dependency Cycle (`tantra-market` ↔ `tantra-agent`)**:
   - **L2 → L3 upward edge**: `tantra-market/crates/tantra-market-store/Cargo.toml:9` depends on `tantra-agent-analytics` solely to serialize `PerformanceReport` in its export writers (`src/export/{writer,json,csv,markdown}.rs`).
   - **L3 → L2 reverse edge**: `tantra-agent/crates/tantra-agent-mcp/Cargo.toml:22` depends on `tantra-market-pricing` (imported directly at `tantra-agent/crates/tantra-agent-mcp/src/tools.rs:34`).
2. **Broken Tier Rules in `tantra-agent`**:
   - `tantra-agent/crates/tantra-agent-mcp/Cargo.toml:21-22` depends on both `tantra-ledger-allocation` and `tantra-market-pricing`, failing Rules R1 (`!dep.starts_with("tantra-market")`) and R4 (`only tantra-agent-chat-tools may depend on tantra-ledger`) verified by `tantra-agent/crates/tantra-agent-chat/tests/dependency_rules.rs:33-90`.
3. **Upward L1 → L2 Dependency**:
   - `tantra-ledger/crates/tantra-ledger-journal/Cargo.toml:11` depends on `tantra-market-finance` rather than consuming shared fee/schedule DTOs from `tantra-core` or an injected port.
4. **Concrete Broker Implementation Coupled into Strategy Engine**:
   - `tantra-runtime/crates/tantra-runtime-strategy/src/dispatch.rs:15-19, 555-563` directly imports `ZerodhaExecutor` (`tantra-exec-zerodha`) and constructs an internal `tokio::runtime::Runtime` inside a crate documented as Zero-I/O in `docs/design/architecture.md`.
5. **Ad-hoc UI ↔ Backend Coupling**:
   - `tantra-ui-web/src/lib/tantra-runtime-client.ts:23-27` issues unversioned REST fetches instead of consuming generated OpenAPI/TypeScript contracts against `/v1` or `/v2`.
   - `tantra-ui-web/src/app/api/chat/route.ts:56-58` hardcodes backend `/ws/chat` WebSocket-to-SSE translation in Next.js server routes.

---

## 2. Interface-First Design

### 2.1 Strengths
- **Canonical Hexagonal Ports (`L0`)**: `tantra-core/src/ports.rs` defines object-safe traits (`BarReader`, `TickReader`, `QuoteReader`, `DepthReader`, `MarketDataConnector`, `InstrumentMaster`, `ExecutionGateway`, `PositionSizer`, `TradingCalendar`) wired as `Arc<dyn Trait>` at composition roots.
- **Execution & Auth Abstractions**: `tantra-exec/crates/tantra-exec-core/src/lib.rs` defines `BrokerExecutor` and `ExecutionStream` with composable decorators (`RateLimitedBroker`, `RiskGatedExecutor`) and table-driven `BrokerEnumMap`. `tantra-exec-auth` decouples secrets via `CredentialStore` (`EnvCredentialStore`, `MemoryCredentialStore`, `KeyringCredentialStore` in `credentials.rs`) and HTTP transport via `AuthHttpClient` (`login.rs:74-77`).
- **Agent Tool & Port Isolation**: `tantra-agent-tools/src/lib.rs` keeps `AgentTool` pure, while `tantra-agent-chat-tools` defines explicit hexagonal `ports::*` traits; `tantra-runtime-api-rest/src/chat.rs:56-105` explicitly surfaces `PortError::unavailable` instead of faking empty answers.
- **Python Structural Protocols**: `tantra-adapters/tantra_adapters/common/protocols.py:11-87` defines `@runtime_checkable` `HttpTransport`, `WebSocketTransport`, and `Adapter` protocols injected into `BaseRestAdapter` (`tantra_adapters/common/base.py:15-44`).

### 2.2 Gaps & Contract Drift
- **Sync vs. Async Port Split**: `tantra-core/src/ports.rs` traits are synchronous, forcing downstream crates (`tantra-exec-core`, `tantra-agent-chat-tools`, `tantra-runtime-api-rest/src/market_feed.rs`) to declare parallel `#[async_trait]` contracts.
- **Stringly-Typed Adapter Trait**: `BrokerAdapter` in `tantra-runtime/crates/tantra-runtime-strategy/src/dispatch.rs:28-37` returns `Result<String, String>`, erasing typed `BrokerError` variants (`RateLimited`, `Timeout`, `Auth`).
- **Divergent REST Order DTOs**: `tantra-runtime/crates/tantra-runtime-api-rest/src/orders.rs:35-50` documents local redefinitions of `Order`, `OrderStatus`, `OrderType`, and `RejectReason` diverging from `tantra_core::order` wire shapes (e.g., lowercase `buy`/`sell` and JSON numbers via `f64` conversion at `orders.rs:331-335`), while hardcoding `REST_ALGO_ID = "rest-api"` (`orders.rs:77`).
- **Concrete Stores in `AppState`**: `tantra-runtime/crates/tantra-runtime-api-rest/src/state.rs:27-101` uses `Arc<dyn Trait>` for market readers, yet binds concrete store types for `ProfileStore`, `PortfolioStore`, `OrderLedger`, `ApprovalQueue`, and `JournalStore`.
- **Polymorphism Leak in Python SDK**: `tantra-strategies/tantra_strategies/sdk/strategy.py:140` checks `if isinstance(context, SimulatedContext)` instead of dispatching through a `StrategyContext` protocol.
- **Empty Legacy Artifact**: `tantra-adapters/tantra_adapters/base.py` is an empty (0-byte) file left alongside `tantra_adapters/common/base.py`.

---

## 3. Scalability

### 3.1 Strengths
- **Bounded Actor Pipeline**: `tantra-runtime/crates/tantra-runtime-actors/src/supervisor.rs:70-131` wires `MarketDataActor` → `StrategyActor` → `PositionSizingActor` → `RiskActor` → `ExecutionActor` over bounded `tokio::sync::mpsc::channel(channel_capacity)`. `MarketDataActor` (`market_data.rs:18-69`) supports `Passthrough`, `CoalesceLatest`, `DropNewest`, and `DropOldest` backpressure policies.
- **GIL-Isolated Python & Zero-Copy FFI**:
  - `PythonStrategyActor` (`tantra-runtime-actors/src/python.rs:87-118`) executes Python strategies on a dedicated OS thread over bounded channels with `CancellationToken` deadlines and protective fail-safe halts.
  - `tantra-ffi-py/src/runner.rs:168-207` releases the GIL (`py.detach`) around pure-Rust batch aggregation, and `arrow_bridge.rs` exports `RecordBatch` streams via Apache Arrow C Stream `PyCapsule` (`Decimal128(38, 8)`).
- **Database Pooling & Broker Rate Protection**: `tantra-runtime-persistence/src/lib.rs:77-98` configures `PgPoolOptions(max_connections=16)` and SQLite WAL with `busy_timeout(5s)`. `ExecutionActor::with_exec_stack` (`execution.rs:85-94`) wraps brokers in `RateLimitedBroker` + `RiskGatedExecutor`.

### 3.2 Bottlenecks & Operational Hazards
1. **Unbounded Channels on Streaming Producers**: `mpsc::unbounded_channel` is used in 7 producers (`tantra-agent-mcp/src/transport.rs:158` for SSE, `tantra-market-core/src/ws_client.rs:325`, `tantra-market-{dhan,zerodha}`, and `tantra-exec-{zerodha,upstox,angelone}`), risking unbounded heap growth when downstream consumers lag.
2. **Blocking `std::fs` & Global `std::sync::Mutex` on Tokio Threads**:
   - `tantra-runtime-api-rest/src/auth.rs:188-235, 498-521` performs synchronous `fs::metadata`/`fs::read_to_string` under `std::sync::RwLock` and synchronous `OpenOptions::open` + `write_all` on every authenticated request (`AuthLayer::audit`).
   - `profile_store.rs:74-149` and `portfolio_store.rs:164-239` serialize **all** users behind a single global `std::sync::Mutex<()>` performing sync file writes + `fsync` on Tokio workers, with no cross-process locking (single-instance only).
3. **Ephemeral In-Memory Operational State**: `OrderLedger` (`orders.rs:361-366`), `ApprovalQueue` (`approval.rs:27-34`), and `StrategyCatalog` live strictly in memory (`state.rs:77` confirms restarts empty `orders`), preventing horizontal scaling and crash recovery.
4. **Nested `Runtime::block_on` Panic Hazard**: `tantra-runtime-strategy/src/dispatch.rs:640-664` invokes `runtime.block_on(...)`, which panics if executed inside an async Tokio worker context.
5. **Unbounded Body Buffering & WS Leaks**:
   - `tantra-runtime-api-rest/src/lib.rs:224` and `v2.rs:33` buffer responses via `axum::body::to_bytes(body, usize::MAX)`.
   - `ws.rs:200-304` stores unbounded `subscribed` / `previous_prices` per WebSocket connection; `tantra-ui-web/src/app/api/chat/route.ts:168-171` does not close the backend WS in `ReadableStream.cancel()`, leaking backend LLM turns on client abort.

---

## 4. Modularity

### 4.1 Strengths
- **Bounded-Context Submodules**: Clean domain splits across `tantra-core`, `tantra-risk`, `tantra-ledger` (`oms`, `portfolio`, `journal`, `allocation`, `performance`), `tantra-market`, `tantra-exec`, `tantra-agent`, `tantra-runtime`, `tantra-ffi`, and `tantra-ui`.
- **Topology Consolidation**: Following `docs/design/0001-crate-topology-audit-and-target.md`, duplicate/stub crates were pruned (e.g., `tantra-ledger-oms/Cargo.toml` is clean of `tokio`) and repo-named facade crates were standardized.

### 4.2 Invariant Leaks & Duplication
- **Zero-I/O & Zero-Floats Violations**:
  - `tantra-market-core` mixes pure feed abstractions/coalescing with `tokio` WebSocket I/O (`ws_client.rs`) and `Utc::now`/`Instant::now` after absorbing `tantra-market-feed`.
  - `tantra-market-finance/src/costs.rs:14-91` computes `Charge.amount` and `CostSchedule::compute_costs` using `f64` alongside `Decimal`-based `india::costs`; `f64` money/price fields also appear in `portfolio_store.rs:118` (`leverage`), `ws.rs:33-73`, and `orders.rs:704-713`.
  - `tantra-risk/src/engine.rs` calls `Instant::now()`, and `tantra-exec-router/src/lib.rs:110` calls `Utc::now()` instead of accepting an injected clock (compare `AuditJournal::append` in `tantra-exec-audit/src/journal.rs:27-28`, which injects `DateTime<Utc>`).
- **Remaining Inline Test Violation**: `tantra-agent/crates/tantra-agent-analytics/src/volatility.rs:313` still contains `#[cfg(test)]` in `src/` contrary to `AGENTS.md` §3.2 (`tantra-ledger` is clean).
- **Dual UI Ecosystems & Legacy Leftovers**: Both `tantra-ui` (incomplete `tantra-ui-app` + `tantra-cli/src/backtest_gen.rs:194-203`, which writes Python scripts to CWD and spawns `python3`) and `tantra-ui-web` coexist. Legacy `HONBA_*` env vars (`tantra-exec-auth/src/credentials.rs:36`), `"honba"` default JWT issuer (`bootstrap.rs:185`), and redundant routers (`ExecRouter`/`SmartOrderRouter` alongside `ResilientRouter` in `tantra-exec-router/src/sor.rs:3`) remain.

---

## 5. Security

### 5.1 Existing Controls
- **Untrusted AI Guardrails**: `tantra-agent-core/src/decision.rs` parses LLM responses into closed enums (`#[serde(deny_unknown_fields)]`), enforces `allowed_universe`, validates SEBI algo IDs and price collars, and requires `RiskEngine::check_decision`. `tantra-agent-chat/src/permission.rs` excludes trade execution and file writes from `ToolRisk`; `tantra-agent-plugins` is declarative-only.
- **Tamper-Evident Audit WAL**: `tantra-exec-audit/src/hash_chain.rs` + `journal.rs` implement an injective-escaped SHA-256 hash chain flushed with `sync_data()`.
- **Input Validation & Parameterized Queries**: `profile_store.rs` and `portfolio_store.rs` enforce strict `[A-Za-z0-9_-]` `user_id` sanitization and size limits; `tantra-runtime-persistence` and `tantra-data/tantra_data/adapters/duckdb_store.py:180-225` use parameterized SQL bindings. `tantra-examples/tantra_examples/screening/nl_support.py:303-325` AST-allowlists nodes/constants/metrics before `eval`.

### 5.2 Critical & High Vulnerabilities

| Severity | Location | Finding & Impact |
|---|---|---|
| **CRITICAL** | `tantra-runtime/crates/tantra-runtime-api-rest/src/lib.rs:296-307`, `bootstrap.rs:193, 500` | **JWT-only Auth Bypass**: `api_router_with_config` wraps routes with `auth_middleware` **only** inside `if let Some(tokens_file) = &config.auth.tokens_file`. Configuring `--jwt-secret` or `--jwt-rsa-key` without `--tokens-file` causes `ServeAuthConfig::is_enabled()` to return `true` (suppressing the warning) while **never mounting auth middleware**, leaving orders, approvals, and kill-switch endpoints unauthenticated as `DEFAULT_USER_ID`. |
| **HIGH** | `tantra-runtime/crates/tantra-runtime-api-rest/src/bootstrap.rs:500`, `caller.rs:38` | **Unauthenticated Default Mode**: Binding to non-loopback interfaces (e.g., `0.0.0.0`) with no auth config logs a warning to `stderr` instead of failing closed. |
| **HIGH** | `tantra-runtime/crates/tantra-runtime-api-rest/src/chat.rs:225-256`, `tantra-ui-web/src/app/api/chat/route.ts:73` | **WebSocket Chat IDOR & Missing Auth Forwarding**: `chat_ws_handler` does not extract `Caller` and keys `SessionScope` solely off `?workspace=<id>`, letting any authenticated user hijack another tenant's chat workspace. Meanwhile `route.ts` opens upstream WebSockets without forwarding Bearer credentials. |
| **HIGH** | `tantra-runtime/crates/tantra-runtime-api-rest/src/v1.rs:130`, `orders.rs:906-916` | **Keyless `POST /orders` Idempotency Collision**: `v1::post_orders` supplies constant `"rest"` as `order_id` when `client_order_id` is absent; subsequent keyless placements collide on `"rest"` in `state.orders` and replay the first order. |

### 5.3 Medium Security & Hygiene Gaps
- **`X-Forwarded-For` Spoofing**: `auth.rs:691-702` blindly trusts `X-Forwarded-For` without a trusted-proxy CIDR check, allowing audit IP forgery.
- **CORS Header Mismatch**: `lib.rs:346` allows `CONTENT_TYPE` but omits `AUTHORIZATION`.
- **Plaintext Secret Hygiene**: `BrokerCredentials` (`tantra-exec-auth/src/credentials.rs:57-78`) and `SessionTokens` (`tokens.rs:18-28`) derive `Debug` and `Serialize` over plaintext secrets (`api_secret`, `password`, `totp_seed`, `access_token`) with no redaction or `zeroize` on drop.
- **Custom Crypto & Weak JWT Validation**: `tantra-exec-auth/src/crypto.rs` hand-rolls SHA-1/SHA-256/HMAC instead of using `sha2`/`hmac`; `auth.rs:92` compares token hashes with `==` rather than constant-time comparison, and `auth.rs:770-815` disables `jsonwebtoken`'s built-in `validate_exp`/`validate_aud`/`required_spec_claims`.
- **Code-Gen & DuckDB Surfaces**: `tantra-cli/src/backtest_gen.rs:194-203` interpolates raw prompts into Python `"""` docstrings executed via `python3`; `tantra_examples/screening/paths.py:109` interpolates file paths into DuckDB SQL `read_parquet('{any_parquet}')`; `nl_support.py:325` can replace AST-checked `eval()` with a pure AST interpreter.

---

## 6. Prioritized Remediation Roadmap

### P0 — Immediate Security & Correctness
1. **Fix JWT-only Auth Bypass**: Attach `auth_middleware` in `tantra-runtime-api-rest/src/lib.rs:296-307` whenever `config.auth.is_enabled()` (tokens file **or** JWT keys), and fail closed on non-loopback binds without auth unless explicitly overridden.
2. **Fix Keyless `POST /orders` Collision**: Generate a unique UUID/monotonic idempotency key per keyless placement in `v1.rs:130` instead of constant `"rest"`.
3. **Scope `/ws/chat` by `Caller` & Forward Auth**: Extract `Caller` in `chat_ws_handler` to namespace `SessionScope` by `(caller_id, workspace)`, forward Bearer headers in `tantra-ui-web/src/app/api/chat/route.ts`, and close the upstream WS on `ReadableStream.cancel()`.
4. **Harden Crypto, JWT & Secrets**: Replace custom hashes/HMAC in `tantra-exec-auth/src/crypto.rs` with `sha2`/`hmac`, use `subtle::ConstantTimeEq` in `auth.rs`, re-enable `jsonwebtoken` validation flags, add `AUTHORIZATION` to CORS, and redact `Debug` + implement `ZeroizeOnDrop` on `BrokerCredentials`/`SessionTokens`.

### P1 — Architectural Decoupling & Domain Purity
5. **Break Cross-Repo Cycles & Enforce CI Dependency Rules**:
   - Move `PerformanceReport` (or an export trait) into `tantra-core`/`tantra-ledger-performance` to remove `tantra-agent-analytics` from `tantra-market-store`.
   - Move allocation/pricing MCP tool wiring into a runtime/composition crate so `tantra-agent-mcp` satisfies `dependency_rules.rs` R1 & R4.
   - Extract shared cost DTOs out of `tantra-market-finance` to eliminate `tantra-ledger-journal`'s L1→L2 upward dependency.
6. **Decouple `tantra-runtime-strategy`**: Inject `Arc<dyn BrokerExecutor>` (or a typed `ExecutionPort`) into `dispatch.rs` and eliminate `ZerodhaExecutor` + `Runtime::block_on`.
7. **Purify Domain Crates**: Move `WsClient` out of `tantra-market-core`, replace `f64` in `tantra-market-finance/src/costs.rs` with `Decimal`, inject clocks into `tantra-risk`/`tantra-exec-router`, and move `volatility.rs:313` tests into `tests/`.

### P2 — Scalability & Modularity Cleanup
8. **Bound Channels & Eliminate Sync I/O on Async Workers**: Replace all 7 `unbounded_channel` sites with bounded channels + explicit backpressure; move `auth.rs`, `profile_store.rs`, and `portfolio_store.rs` off global `std::sync::Mutex` + sync `std::fs` onto async storage / SQLx.
9. **Persist Runtime State & Bound Payloads**: Back `OrderLedger`, `ApprovalQueue`, and `TradingState` with `tantra-runtime-persistence`; cap `axum::body::to_bytes` and per-socket WS subscription maps.
10. **Converge UI Contracts & Retire Legacy Shims**: Generate OpenAPI/TS types for `tantra-ui-web`, remove `tantra_adapters/base.py`, `HONBA_*` defaults, and legacy `ExecRouter`, and route `tantra-cli` backtests directly through `tantra-runtime`/`tantra-ffi`.
