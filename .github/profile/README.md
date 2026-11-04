# Vyapaar Labs (व्यापार)

**Autonomous, high-throughput, AI-native algorithmic trading and quantitative research platform retargeted for Indian markets (NSE/BSE).**

---

### 🌐 Welcome to Vyapaar Labs

Vyapaar Labs develops institutional-grade open-source quantitative trading infrastructure combining:
- **Zero-I/O Rust Core** for deterministic order management, tax-lot accounting, and double-entry ledgers.
- **Sub-15 µs Regulatory Risk Gating** strictly enforcing SEBI Algo IDs, Order-to-Trade Ratio (OTR) circuit breakers, and scrip price bands.
- **AI Brain & Autonomous Agent Loop** integrating local/cloud LLMs with an MCP tool gateway and embedded Typst research report compiler.
- **Dual Workstation Experience**: Single static binary terminal chat/assistant (`vyapaar ask`, `vyapaar tui`) and high-density WASM studio (`vyapaar-ui`).

### 📦 Key Ecosystem Repositories

- **Core & Domain Engines**:
  - [`vyapaar-core`](https://github.com/vyapaar-labs/vyapaar-core): Canonical types, fixed-point Decimal arithmetic, OpenAPI schemas.
  - [`vyapaar-ledger`](https://github.com/vyapaar-labs/vyapaar-ledger): Pure OMS state machine, FIFO tax-lots, double-entry general ledger.
  - [`vyapaar-risk`](https://github.com/vyapaar-labs/vyapaar-risk): Synchronous regulatory pre-trade risk engine and kill-switch.
  - [`vyapaar-market`](https://github.com/vyapaar-labs/vyapaar-market): High-throughput tick coalescing, 100+ indicators, multi-broker WebSockets.
  - [`vyapaar-exec`](https://github.com/vyapaar-labs/vyapaar-exec): First-party broker execution, smart router, headless TOTP auth.
  - [`vyapaar-runtime`](https://github.com/vyapaar-labs/vyapaar-runtime): Tokio actor pipeline, backtester, Axum REST/WS API, cron jobs.
  - [`vyapaar-brain`](https://github.com/vyapaar-labs/vyapaar-brain): AI research loop, LLM providers, MCP server, Typst PDF generator.
  - [`vyapaar-ffi`](https://github.com/vyapaar-labs/vyapaar-ffi): PyO3 FFI compiling the `vyapaar` PyPI wheel.
- **Workstations & Interfaces**:
  - [`vyapaar-ui`](https://github.com/vyapaar-labs/vyapaar-ui): WASM Strategy Studio, Institutional Screener, Ratatui TUI, and CLI binary.
  - [`vyapaar-fe`](https://github.com/vyapaar-labs/vyapaar-fe): TypeScript Dockview modular web desktop.
- **Strategies, Data & Learning**:
  - [`vyapaar-strategies`](https://github.com/vyapaar-labs/vyapaar-strategies): Production Python strategy catalog.
  - [`vyapaar-adapters`](https://github.com/vyapaar-labs/vyapaar-adapters): Community broker adapters (Dhan, Zerodha, Upstox, Angel One, Fyers).
  - [`vyapaar-data`](https://github.com/vyapaar-labs/vyapaar-data): DuckDB + Parquet financial data lakehouse and corporate actions.
  - [`vyapaar-examples`](https://github.com/vyapaar-labs/vyapaar-examples): Hands-on learning path and strategy verification scripts.
  - [`vyapaar-docs`](https://github.com/vyapaar-labs/vyapaar-docs): Architecture docs, guides, and tutorials.

---
*Maintained with ❤️ by the Vyapaar Labs Core Team.*
