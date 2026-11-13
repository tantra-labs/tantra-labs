# Rule: Scalability, Concurrency & Resource Bounds (binding)

**Status: binding for every orchestrator, subagent, and PR across all `tantra-labs` repositories.**

## 1. Bounded Channels & Backpressure

- **STRICTLY FORBIDDEN**: `tokio::sync::mpsc::unbounded_channel` in WebSocket clients, SSE transports, market feeds, execution streams, or actor pipelines.
- Always use bounded `mpsc::channel(capacity)` or `broadcast::channel(capacity)` paired with an explicit `BackpressurePolicy` (`CoalesceLatest`, `DropNewest`, `DropOldest`, or structured 429/backpressure errors).

## 2. Async Runtime Purity (Tokio Workers)

1. **No Blocking I/O on Tokio Worker Threads**:
   - **FORBIDDEN** inside Axum handlers, Tokio tasks, or auth middleware: synchronous `std::fs` metadata/reads/writes/`fsync`, or blocking SQLite/HTTP calls.
   - Use async `tokio::fs`, buffered async audit channels, or SQLx pools (`PgPool`/`SqlitePool`), or explicitly offload unavoidable blocking work to `tokio::task::spawn_blocking` with bounded concurrency.
2. **No Global `std::sync::Mutex` Across Request Paths**:
   - Do **not** wrap shared HTTP/store directories or hot-path caches in a single global `std::sync::Mutex<()>` (or hold `std::sync::RwLock` across file I/O). Use `tokio::sync` locks, lock-free/sharded per-key state (`DashMap` / keyed locks), or transactional DB storage.
3. **No Nested `Runtime::block_on`**:
   - **FORBIDDEN**: Constructing a `tokio::runtime::Runtime` inside library/dispatch methods and calling `runtime.block_on(...)` (panics if called from an async context). Expose `async fn` natively or invert I/O to the caller.

## 3. Bounded Memory & Connection Lifecycle

- **HTTP Body Limits**: Never call `axum::body::to_bytes(body, usize::MAX)`. Always pass an explicit byte cap (e.g., 1–4 MiB) appropriate to the endpoint.
- **WebSocket Per-Connection Caps**: Bound `subscribed` symbol sets, price caches, and outbound queues per socket; evict cleanly on disconnect.
- **Proxy Stream Cleanup**: Next.js / BFF streaming proxies (`ReadableStream`) must close upstream WebSockets and abort backend tasks in `cancel()` when the client disconnects.

## 4. Persistent Operational State & Python Isolation

- **Restart-Safe Trading State**: Order ledgers, approval queues, and trading halt states (`OrderLedger`, `ApprovalQueue`, `TradingState`) must be backed by `tantra-runtime-persistence` (SQLite WAL / PostgreSQL), never purely in-memory maps that vanish on restart or prevent multi-instance scaling.
- **Python Boundary**: Run long-lived Python strategies on isolated OS threads (`PythonStrategyActor`) with `CancellationToken` deadlines; release the GIL (`py.detach`) for Rust batch work and use Arrow C-Stream `PyCapsule` for tabular market data.
