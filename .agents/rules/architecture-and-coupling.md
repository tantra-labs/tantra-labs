# Rule: Architecture & Loose Coupling (binding)

**Status: binding for every orchestrator, subagent, and PR across all `tantra-labs` repositories.**

## 1. Strict Layered Dependency DAG (L0–L6)

Dependencies must flow strictly downward toward `tantra-core`:

| Tier | Repositories | Allowed Dependency Targets |
|---|---|---|
| **L0** | `tantra-core` | External foundational crates only (`rust_decimal`, `chrono`, `serde`, `schemars`, `thiserror`) |
| **L1** | `tantra-risk`, `tantra-ledger` | L0 (`tantra-core`) only |
| **L2** | `tantra-market`, `tantra-exec` | L0–L1 (never L3+!) |
| **L3** | `tantra-agent`, `tantra-runtime` | L0–L2 (subject to Agent Rules R1–R4) |
| **L4** | `tantra-ffi` | L0–L3 |
| **L5** | `tantra-ui`, `vyapaar-ui-web` | L0–L4 API/WASM contracts or HTTP/WS clients |
| **L6** | `tantra-strategies`, `tantra-adapters`, `tantra-data`, `tantra-examples`, `tantra-docs` | L4 (`tantra` PyPI FFI) or documented public HTTP/WS APIs |

## 2. Hard Coupling Bans

1. **Zero Cross-Repo Cycles & Zero Upward Edges**:
   - **FORBIDDEN**: L2 crates importing L3 crates (e.g., `tantra-market-store` must NOT depend on `tantra-agent-analytics`). Shared DTOs belong in `tantra-core` or a dedicated L1/port trait.
   - **FORBIDDEN**: L1 crates importing L2 crates (e.g., `tantra-ledger-journal` must NOT depend on `tantra-market-finance`).
2. **Enforce Agent Workspace Rules (`tantra-agent-chat/tests/dependency_rules.rs`)**:
   - **R1**: No `tantra-agent-*` crate may depend on `tantra-runtime-*`, `tantra-exec-*`, or `tantra-market-*`.
   - **R2**: `tantra-agent-chat` / `tantra-agent-chat-tools` and `tantra-agent-trader-loop` must remain mutually decoupled.
   - **R3**: `tantra-agent-tools` must never depend on `tokio`, `async-trait`, `reqwest`, or `sqlx`.
   - **R4**: Only `tantra-agent-chat-tools` may depend on `tantra-ledger-*` inside Tier 3A. Any MCP wiring that needs allocation or market pricing belongs in the application composition layer (`tantra-runtime`), not `tantra-agent-mcp`.
3. **No Concrete Executors in Strategy / Domain Crates**:
   - Strategy and orchestration crates (such as `tantra-runtime-strategy`) must NEVER depend directly on concrete broker adapters (e.g., `tantra-exec-zerodha::ZerodhaExecutor`). Inject `Arc<dyn BrokerExecutor>` / `ExecutionGateway` from the binary composition root.
4. **Workspace Facade Convention (`docs/design/0001` §4.2)**:
   - Every multi-crate workspace exposes one repo-named thin re-export facade crate (`tantra-market`, `tantra-exec`, `tantra-runtime`, `tantra-ffi`, `tantra-ui`). Do not add stub crates or re-export shims inside downstream workspaces.
5. **Versioned UI ↔ Backend Contracts**:
   - Frontend clients (`vyapaar-ui-web`, `tantra-ui`) must target versioned REST (`/v1`, `/v2`) and WebSocket contracts derived from `tantra-core` / `tantra-runtime-api` schemas (`schemars`), never ad-hoc unversioned endpoints.
   - Do not shell out to generated Python scripts from Rust CLIs (`tantra-cli`) to run backtests; invoke `tantra-runtime` / `tantra-ffi` directly.
