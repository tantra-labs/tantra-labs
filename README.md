# Tantra Labs (व्यापार)

**Autonomous, high-throughput, AI-native algorithmic trading and quantitative research platform retargeted for Indian markets (NSE/BSE).**

`tantra-labs` is an integrated ecosystem synthesizing high-performance Rust execution engines, pre-trade regulatory risk gating (<15µs), multi-broker market connectivity, zero-copy Arrow memory bridges, and an AI agent brain with local/cloud LLM backends, Ratatui terminal workstation, and WASM studio.

---

## 🏛️ Repository Topology & Subsystems

| Subsystem Repo | Type | Purpose & Scope |
| :--- | :--- | :--- |
| [`tantra-core`](./tantra-core) | Rust | **Shared Kernel**: Canonical `Decimal` value objects (`Price`, `Quantity`, `Money`), `InstrumentId`, `Tick`, `Order`, `Decision`, OpenAPI schemas. |
| [`tantra-ledger`](./tantra-ledger) | Rust | **Domain Heart (Zero-I/O)**: Order Management System (`oms`), FIFO tax-lot tracking (`portfolio`), double-entry general ledger (`journal`). |
| [`tantra-risk`](./tantra-risk) | Rust | **Regulatory Risk Gate**: Sub-15 µs pre-trade risk engine (SEBI algo ID, OTR circuit breakers, scrip price bands, freeze limits, kill-switch). |
| [`tantra-market`](./tantra-market) | Rust | **Market Data**: Multi-broker binary WebSockets (Zerodha, Upstox, Angel One, Fyers), tick coalescing, 100+ indicators, Parquet loaders, macro/finance series. |
| [`tantra-exec`](./tantra-exec) | Rust | **Execution Gateway**: First-party broker executors, headless TOTP auth, freeze slicer, Smart Order Router (SOR), hash-chained fsynced audit journal (JSONL segment WAL). |
| [`tantra-runtime`](./tantra-runtime) | Rust | **Central Runtime & Automation**: Tokio actor pipeline, event-driven backtester, strategy enhancer (GA/WFO), Axum REST/WS API, cron/background jobs, SQLite & git2 snapshots. |
| [`tantra-agent`](./tantra-agent) | Rust | **AI Agent & Agent Engine**: Local/cloud LLMs (Anthropic/OpenAI), trader loop, prompt replay, genetic synthesizer, MCP (`rmcp`), agent tools, plugin marketplace, embedded Typst reports. |
| [`tantra-ffi`](./tantra-ffi) | Rust (PyO3) | **Python FFI Bridge**: Apache Arrow zero-copy memory bridge and smart GIL management. Builds the `tantra` PyPI wheel. |
| [`tantra-ui`](./tantra-ui) | Rust (WASM + TUI) | **Unified Workstations**: WASM/Native Shell Strategy Studio & Screener (`ui-app`), `openalgo-charts-rs`, Ratatui Terminal UI (`tantra-tui`), CLI binary (`tantra-cli`), tree-sitter highlighter. |
| [`tantra-strategies`](./tantra-strategies) | Python | **Production Strategies**: Catalog of institutional strategies (Quoting, Arbitrage, TWAP/VWAP slicers, Turtle breakout, Risk Parity). |
| [`tantra-adapters`](./tantra-adapters) | Python | **Broker SDK**: Pluggable Python community broker connectors (Dhan, Zerodha, Upstox, Angel One, Fyers, Kotak, IIFL). |
| [`tantra-data`](./tantra-data) | Python + DuckDB | **Data Lakehouse**: Point-in-time corporate actions, splits, dividends, coverage ledgers, Parquet catalog, data ingestion sidecars. |
| [`tantra-examples`](./tantra-examples) | Python | **Learning Path**: Runnable reference scripts for Indian equities, options, factor models, and backtesting. |
| [`tantra-docs`](./tantra-docs) | Markdown | **Documentation**: Comprehensive architecture, API references, tutorials, and user guides built via MkDocs Material. |

---

## 🚀 Superproject Structure

`tantra-labs` serves as the superproject repository tracking each subsystem as an autonomous Git submodule while allowing atomic cross-subsystem orchestration:

```bash
# Clone with all submodules
git clone --recurse-submodules https://github.com/tantra-labs/tantra-labs.git
cd tantra-labs

# Build all Rust production targets
make prod

# Run test suites across all workspaces
make test
```

## 📜 Invariants & Philosophy

1. **Zero-I/O Domain Purity**: `tantra-ledger` and `tantra-risk` have zero network, database, or disk I/O.
2. **Strict Zero-Floats**: `rust_decimal::Decimal` and Python `decimal.Decimal` are strictly enforced across all prices, quantities, and balances.
3. **SEBI Regulatory First-Class**: Algo ID tracking, Order-to-Trade Ratio (OTR) circuit breakers, and price band validation are mandatory.
4. **Dual Workstations**: Single static binary terminal chat/assistant (`tantra ask`, `tantra tui`) and high-density WASM canvas (`tantra-ui`).
