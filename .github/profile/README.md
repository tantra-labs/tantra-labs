# Tantra Labs (व्यापार)

**Autonomous, high-throughput, AI-native algorithmic trading and quantitative research platform retargeted for Indian markets (NSE/BSE).**

---

### 🌐 Welcome to Tantra Labs

Tantra Labs develops institutional-grade open-source quantitative trading infrastructure combining:
- **Zero-I/O Rust Core** for deterministic order management, tax-lot accounting, and double-entry ledgers.
- **Sub-15 µs Regulatory Risk Gating** strictly enforcing SEBI Algo IDs, Order-to-Trade Ratio (OTR) circuit breakers, and scrip price bands.
- **AI Agent & Autonomous Agent Loop** integrating local/cloud LLMs with an MCP tool gateway and embedded Typst research report compiler.
- **Dual Workstation Experience**: Single static binary terminal chat/assistant (`tantra ask`, `tantra tui`) and high-density WASM studio (`tantra-ui`).

### 📦 Key Ecosystem Repositories

- **Core & Domain Engines**:
  - [`tantra-core`](https://github.com/tantra-labs/tantra-core): Canonical types, fixed-point Decimal arithmetic, OpenAPI schemas.
  - [`tantra-ledger`](https://github.com/tantra-labs/tantra-ledger): Pure OMS state machine, FIFO tax-lots, double-entry general ledger.
  - [`tantra-risk`](https://github.com/tantra-labs/tantra-risk): Synchronous regulatory pre-trade risk engine and kill-switch.
  - [`tantra-market`](https://github.com/tantra-labs/tantra-market): High-throughput tick coalescing, 100+ indicators, multi-broker WebSockets.
  - [`tantra-exec`](https://github.com/tantra-labs/tantra-exec): First-party broker execution, smart router, headless TOTP auth.
  - [`tantra-runtime`](https://github.com/tantra-labs/tantra-runtime): Tokio actor pipeline, backtester, Axum REST/WS API, cron jobs.
  - [`tantra-agent`](https://github.com/tantra-labs/tantra-agent): AI research loop, LLM providers, MCP server, Typst PDF generator.
  - [`tantra-ffi`](https://github.com/tantra-labs/tantra-ffi): PyO3 FFI compiling the `tantra` PyPI wheel.
- **Workstations & Interfaces**:
  - [`tantra-ui`](https://github.com/tantra-labs/tantra-ui): WASM Strategy Studio, Institutional Screener, Ratatui TUI, and CLI binary.
  - [`tantra-fe`](https://github.com/tantra-labs/tantra-fe): TypeScript Dockview modular web desktop.
- **Strategies, Data & Learning**:
  - [`tantra-strategies`](https://github.com/tantra-labs/tantra-strategies): Production Python strategy catalog.
  - [`tantra-adapters`](https://github.com/tantra-labs/tantra-adapters): Community broker adapters (Dhan, Zerodha, Upstox, Angel One, Fyers).
  - [`tantra-data`](https://github.com/tantra-labs/tantra-data): DuckDB + Parquet financial data lakehouse and corporate actions.
  - [`tantra-examples`](https://github.com/tantra-labs/tantra-examples): Hands-on learning path and strategy verification scripts.
  - [`tantra-docs`](https://github.com/tantra-labs/tantra-docs): Architecture docs, guides, and tutorials.

---
*Maintained with ❤️ by the Tantra Labs Core Team.*
