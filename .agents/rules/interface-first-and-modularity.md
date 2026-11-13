# Rule: Interface-First Design & Modularity (binding)

**Status: binding for every orchestrator, subagent, and PR across all `tantra-labs` repositories.**

## 1. Interface-First Contract Design

1. **Define Ports Before Implementations**:
   - Rust: Define object-safe `trait` ports in `tantra-core/src/ports.rs` or crate-local `ports` modules before implementing concrete adapters; inject via `Arc<dyn Trait>` or generic bounds at composition roots (`bootstrap.rs`, `supervisor.rs`).
   - Python: Define `@runtime_checkable` `typing.Protocol` (or `ABC`) interfaces (e.g., `HttpTransport`, `WebSocketTransport`, `Adapter`, `StrategyContext`).
2. **Never Leak Concrete Types Across Interfaces**:
   - **FORBIDDEN**: `isinstance(context, SimulatedContext)` or downcasting trait objects to branch behavior. Add the required capability as a method on the `Protocol` / `trait`.
   - **FORBIDDEN**: Binding REST/runtime `AppState` fields exclusively to concrete filesystem/in-memory stores when persistence backends may vary; place stores behind repository/port traits.
3. **Typed Error Contracts**:
   - Port/adapter traits must return typed error enums (`BrokerError`, `PortError`, `ReaderError`), **never** stringly-typed `Result<_, String>`.
   - Missing upstream capabilities must return explicit `PortError::unavailable(...)` (paired with a filed `docs/gaps/XXXX-*.md`), **never** silent empty vectors or fake defaults.
4. **Canonical Sync/Async Boundary**:
   - Keep `tantra-core/src/ports.rs` synchronous and I/O-free; wrap async network/storage drivers at L2/L3 port boundaries rather than redefining divergent wire DTOs.
   - Do **not** fork `Order`, `OrderStatus`, `OrderType`, or `RejectReason` locally in handlers with divergent semantics from `tantra_core::order` unless explicitly isolated behind a documented versioned API serializer.

## 2. Domain Purity & Retargetability

1. **Zero-I/O Crates**:
   - `tantra-core`, `tantra-ledger`, `tantra-risk`, `tantra-runtime-strategy`, and `tantra-agent-tools` must contain **zero** network sockets, filesystem calls (`std::fs`, `tokio::fs`), database clients, or `tokio::runtime::Runtime` creation.
   - Network WebSocket clients and reconnect loops belong in feed/adapter modules/crates, never mixed with pure domain types or tick-coalescing logic.
2. **Zero-Clock Determinism**:
   - Domain engines, risk checks, routers, and audit journals must accept explicit `DateTime<Utc>` / timestamp parameters from their caller/adapter boundary.
   - **FORBIDDEN in domain `src/`**: `Utc::now()`, `SystemTime::now()`, or `Instant::now()`.
3. **Zero-Floats Financial Invariant**:
   - **FORBIDDEN** in prices, quantities, balances, positions, PnL, slippage, fees, statutory charges, price collars, or margin calculations: `f32`, `f64`, and Python `float` (including `Decimal::to_f64()` before financial serialization/arithmetic).
   - Always use `rust_decimal::Decimal` (Rust), `decimal.Decimal` (Python), and `Decimal128(38, 8)` (Arrow).
4. **WASM & Cross-Arch Targetability**:
   - Compute crates (`tantra-core`, `tantra-market-indicators`, `tantra-ledger-portfolio`, `tantra-ui-core`) must remain `wasm32-unknown-unknown`-compatible and free of OS threads/syscalls.
