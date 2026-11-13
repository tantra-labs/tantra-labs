# Checklist: Design & Architecture Review Gate

Run this checklist before writing implementation code for new crates, cross-repo features, traits, REST/WS endpoints, or broker/LLM integrations.

## 1. Architecture & Loose Coupling
- [ ] **DAG Preserved**: New `Cargo.toml` / Python dependencies point strictly downward (`L6 → L5 → L4 → L3 → L2 → L1 → L0`), with zero cross-repo cycles.
- [ ] **Agent Rules Hold**: `tantra-agent-*` adds no edges violating `tantra-agent-chat/tests/dependency_rules.rs` (R1–R4).
- [ ] **No Concrete Leaks**: Domain/strategy crates depend on traits (`ExecutionGateway`, `BrokerExecutor`, `MarketReader`), never concrete brokers (`ZerodhaExecutor`, etc.).
- [ ] **Wire Contract Ownership**: Shared DTOs and OpenAPI schemas originate in `tantra-core` or `tantra-runtime-api` (`schemars`), not duplicated ad-hoc per handler/client.

## 2. Interface-First & Modularity
- [ ] **Traits/Protocols Defined First**: New capabilities start with a Rust `trait` (or Python `Protocol`) and typed error enum before concrete adapters.
- [ ] **Zero-I/O & Zero-Clock**: Pure domain modules (`tantra-core`, `tantra-ledger`, `tantra-risk`, `tantra-runtime-strategy`, `tantra-agent-tools`) contain no network, filesystem, `Utc::now()`, `Instant::now()`, or internal `tokio::runtime::Runtime`.
- [ ] **Zero-Floats**: All prices, quantities, balances, fees, taxes, and collars use `rust_decimal::Decimal` / `decimal.Decimal` — zero `f32`/`f64`/`float`.
- [ ] **Explicit Unavailability**: Missing upstream capabilities return explicit errors (`PortError::unavailable`) and file a provider gap (`rules/gap-tracking.md`).

## 3. Scalability & Concurrency
- [ ] **Bounded Queues**: Channels use `mpsc::channel(capacity)` or `broadcast::channel(capacity)` with documented overflow policy (drop, coalesce, reject) — zero `unbounded_channel`.
- [ ] **Non-Blocking Async**: Async handlers/actors never perform sync `std::fs`, hold `std::sync::Mutex` across work, or call `Runtime::block_on`.
- [ ] **Persistence & Bounds**: Operational state survives restarts cleanly; HTTP body reads and per-socket maps have explicit size caps.

## 4. Security
- [ ] **Fail-Closed Auth & Isolation**: Protected routes enforce auth for every configured credential mode (`tokens_file` and JWT); per-user state/WS sessions scope strictly by authenticated `Caller`.
- [ ] **Unique Idempotency**: Order placement never uses constant fallback keys when `client_order_id` is absent.
- [ ] **Secrets & Crypto**: Secret structs redact `Debug` and zeroize on drop; only audited crates (`sha2`, `hmac`, `subtle`, `jsonwebtoken`) are used; SQL uses bind parameters (`$1`/`?`).
