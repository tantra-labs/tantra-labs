# 0007 — Standalone Paper Trading Exchange (Real-Exchange Mimic)

**Status**: **IMPLEMENTED — all four phases (P0–P4) shipped 2026-11-16**.
P0 matching core (`tantra-exec` plan 0003), P1 runtime wiring (`tantra-runtime` plan 0005),
P2 Python SDK (`tantra-ffi` plan 0003), P3 CSR/WASM (`tantra-ui` plan 0008), P4 golden
parity suite + docs (T14.14/T14.15) — all green; the T14 gate (byte-identical fills across
backtest / paper / Python / WASM on one golden vector) passes.
**Track**: T14 · **Phase**: 3–6 (execution, runtime, SDK, UI)
**Owning repos**: `tantra-exec` (matching core), `tantra-runtime` (wiring + daemon),
`tantra-ffi` (Python SDK surface), `tantra-ui` (CSR/WASM + web)
**Per-repo plans**:
- [`tantra-exec/docs/plans/0003-*.md`](../../tantra-exec/docs/plans/0003-paper-exchange-matching-core.md) — P0 matching core
- [`tantra-runtime/docs/plans/0005-*.md`](../../tantra-runtime/docs/plans/0005-paper-exchange-runtime-wiring.md) — P1/P2 wiring + backtest unification
- [`tantra-ffi/docs/plans/0003-*.md`](../../tantra-ffi/docs/plans/0003-python-sdk-paper-exchange-embedding.md) — P3 Python SDK
- [`tantra-ui/docs/plans/0008-*.md`](../../tantra-ui/docs/plans/0008-paper-exchange-csr-web-embedding.md) — P4 CSR/WASM + web

---

## Why

Tantra today has **no single paper trading exchange**. Instead it has **three disconnected
simulators** with different fill semantics and no shared order book:

| # | Simulator | Location | Fill semantics | Book? |
|---|-----------|----------|----------------|-------|
| A | `PaperAdapter` | `tantra-runtime-strategy::dispatch` | fills at limit price or last-known market price, full fill, deterministic | ❌ |
| B | `NextOpenSim` | `tantra-runtime-api-rest::exec` | fills at next bar open; **market-orders only, long-only** | ❌ |
| C | L2 `OrderBook` | `tantra-runtime-backtest::sim::l2_book` | price-time priority, market+limit, VWAP fill, participation caps, latency, worst-price slippage | ✅ (backtest-only) |

Consequences:
- **Research-live parity is already a stated invariant** (AGENTS §4.3.3; the backtest engine
  drives the same `StrategyRunner` as live/paper), yet the *fill engine* differs per mode —
  backtest uses (C), paper uses (A), REST uses (B). Fills are not byte-identical across modes.
- The REST paper path rejects limit orders and shorts (`unsupported_order_type`,
  `no_position: the simulator is long-only` — `api-rest/src/exec.rs`).
- No order lifecycle (working / partial / cancelled / rejected / stop-triggered), no resting
  depth, no real-time fill push to UI/WS. A strategy running on paper today cannot behave like
  it does on a real exchange.
- `tantra-exec`'s `BrokerExecutor` docs already name "Paper/Sim" as a first-class implementor,
  and runtime gap `0008` records the dual-port boundary (`BrokerAdapter` sync sim port vs
  `BrokerExecutor` async wire port) with "lift `BrokerAdapter` into `tantra-exec-core`"
  (option 2) as its documented close event.

**The ask**: one real-exchange-mimicking paper trading exchange that
1. mimics a real exchange (order book, price-time priority, partial fills, order lifecycle);
2. runs independently as its own server/daemon (`paper serve` mode);
3. is the *shared* fill engine behind the simulator *and* the backtester (replacing A, B, and
   the backtest's private book C with one engine);
4. is one place serving **strategies, UI, web, and examples**, and is embeddable into
   - the **Python SDK** (`tantra` wheel, via `tantra-ffi`), and
   - **CSR / web UI** (browser-side via `wasm32` bindings, and the server-backed web app).

This plan **is not a greenfield exchange** — the matching core already exists as
`tantra-runtime-backtest::sim::l2_book::OrderBook`. The work is to promote it into a
first-class, event-driven, real-time-capable matching engine, place it in the Execution
bounded context, and make it the one fill engine every consumer drives.

---

## Target architecture

```
                 ┌────────────────────────────────────────────────────┐
   market feed   │  PAPER EXCHANGE (tantra-exec)                      │
 ─ ticks/bars ─▶ │  · per-instrument OrderBook (price-time priority)  │──▶ Fill/Cancel/
 ─ L2 depth   ─▶ │  · order lifecycle: working/partial/filled/        │    Reject events
                 │    cancelled/rejected/stop-triggered               │
   orders        │  · market/limit/stop/IOC/GTD, both sides           │──▶ depth snapshots
 ─ submit ─────▶ │  · participation caps, latency, slippage, MIS sq-o │    (L2 stream)
 ─ cancel ─────▶ │  · zero-I/O, Decimal-only, timestamp-deterministic │
                 └───────────────┬────────────────────────────────────┘
                    wasm32 ✓     │  implements BrokerExecutor (async) + sync sim port
                                 │  (closes runtime gap 0008, option 2)
          ┌──────────────────────┴───────────────────────┐
          ▼                                              ▼
   ┌──────────────────────────┐                  ┌──────────────────────────┐
   │  Runtime (House)         │                  │  Embeddings               │
   │  · strategy dispatch     │                  │  · Python SDK (tantra-ffi)│
   │  · REST /orders, /ws     │                  │  · CSR/WASM (tantra-ui)   │
   │  · backtest (replay)     │                  │  · examples (both)        │
   │  · paper serve daemon    │                  └──────────────────────────┘
   └──────────────────────────┘
```

**One engine, four drivers**: the same `PaperExchange` is driven by (i) the strategy
`Dispatcher`, (ii) the REST `/orders` route, (iii) the backtest engine on historical bars, and
(iv) the Python SDK / WASM via bindings. Because every transition is timestamp-stamped and the
core is zero-I/O, replaying the same event tape produces byte-identical fills in backtest,
paper, Python, and the browser.

---

## Phases & tasks

### P0 — Matching core (`tantra-exec`, new crate `tantra-exec-paper`)

| # | Task | Scope | Status |
|---|------|-------|--------|
| T14.1 | Extract `sim::l2_book::OrderBook` + `sim/{latency,slippage,mis}` into `tantra-exec-paper` as a pure matching crate (zero-I/O, Decimal, `wasm32`-targetable), keeping existing backtest behavior green | `tantra-exec` | Proposed |
| T14.2 | Add order lifecycle + events: `Working`/`PartialFill`/`Filled`/`Cancelled`/`Rejected`/`StopTriggered`, submit/cancel/amend, `OrderSide` both directions, `TimeInForce` (Day/IOC/GTD), stop (StopLimit/StopMarket) | `tantra-exec-paper` | Proposed |
| T14.3 | Account isolation: per-`AccountId` cash, positions, orders; statutory fees via `tantra-market-finance`, FIFO settlement via `tantra-ledger-portfolio` | `tantra-exec-paper` | Proposed |
| T14.4 | Implement `BrokerExecutor` (async) on `PaperExchangeExecutor`; lift the sync `BrokerAdapter` port into `tantra-exec-core` (closes runtime gap 0008 option 2); parity test `test_identical_fills_paper_vs_backtest` | `tantra-exec` + `tantra-runtime` | Proposed |

### P1 — Runtime wiring (`tantra-runtime`) — ✅ COMPLETE 2026-11-16

| # | Task | Scope | Status |
|---|------|-------|--------|
| T14.5 | Replace `NextOpenSim` behind `/orders` with the paper exchange; limit/stop/short support; fills pushed on market advance | `tantra-runtime-api-rest` | ✅ `027ebac` |
| T14.6 | Re-implement `PaperAdapter` as a thin driver over the exchange (delete its inline fill math); `ZerodhaKiteAdapter`/`AngelOneSmartApiAdapter` sim-scaffolds delegate to the exchange too | `tantra-runtime-strategy::dispatch` | ✅ `a9d1d96` |
| T14.7 | Add `/ws/live` order/fill/depth/position push (bidirectional), wired to the exchange's event stream | `tantra-runtime-api-rest::ws` | ✅ `18be257` |
| T14.8 | Backtest unification: the backtest engine drives the exchange on historical bars for its fills (replaces its inline book C); byte-identical parity vs paper on golden vectors | `tantra-runtime-backtest` | ✅ `a1cbeda` (L2 adverse-fill restore = follow-on) |
| T14.9 | Standalone `paper serve` daemon mode (independent process; replay-tape or live broker feed via `tantra-market-dhan`/`zerodha`; trading calendar + MIS 15:20 square-off) | `tantra-runtime-api-rest` / new bin | ✅ `f70e0e2` (replay-tape + MIS shipped; live feed + calendar gate = follow-ons) |

### P2 — Python SDK embedding (`tantra-ffi`) — ✅ COMPLETE 2026-11-16

| # | Task | Scope | Status |
|---|------|-------|--------|
| T14.10 | Wheel surface `tantra.paper`: PyO3 bindings for the exchange (`PaperExchange` session: `place_order`/`cancel_order`/`amend_order`, `depth`, `fills`, `positions`, `equity`); Arrow zero-copy for bar/depth/fill batches; GIL released during engine steps (`py.allow_threads`) | `tantra-ffi` | ✅ `c7e90a5` |
| T14.11 | Deterministic seeded session mode for examples (no broker credentials); `tantra-examples` + `tantra-strategies` examples run against the wheel engine | `tantra-ffi` + `tantra-examples` + `tantra-strategies` | ✅ `8189fb1` + `13cbae0` |

### P3 — CSR / WASM + web embedding (`tantra-ui`) — ✅ COMPLETE 2026-11-16

| # | Task | Scope | Status |
|---|------|-------|--------|
| T14.12 | `tantra-ui-api-wasm` pure bindings for the exchange core (single-user, in-browser paper session; same engine → same fills as server); compile check `wasm32-unknown-unknown` | `tantra-ui-api-wasm` | ✅ `fad62c3` |
| T14.13 | `tantra-ui-app` (Leptos 0.8 CSR) paper-trading panel + order ticket; connect to server REST `/orders` + `/ws/live`; TUI paper panel parity | `tantra-ui-app`, `tantra-tui` | ✅ `768b375`/`4b2a207`/`b54d2b6` |

### P4 — Verification & docs — ✅ COMPLETE 2026-11-16

| # | Task | Scope | Status |
|---|------|-------|--------|
| T14.14 | Golden vector parity suite (`tests/golden/*.json`): identical fills across backtest / paper / Python wheel / WASM; `make test` (prod profile), clippy/fmt green, ruff + mypy for Python repos | all | ✅ `5714ee2`/`5bbd743`/`898f61c` |
| T14.15 | Docs: paper-trading guide in `tantra-docs` (run a paper session via CLI, REST, Python, and the web app) | `tantra-docs` | ✅ `1157674` |

---

## Non-goals (scope guards)

- The exchange is the **execution-simulation layer only**. It does not absorb the backtest
  *analytics* (sweeps, enhancer, WFO/DSR, statistical gates) or the jobs engine — those stay in
  `tantra-runtime`.
- It does not replace live broker execution — real wire transport stays on
  `tantra_exec_core::BrokerExecutor` implementations (Zerodha/Angel One); the paper exchange is
  the deterministic venue alongside them.
- No floats enter the engine (`Decimal` everywhere), per the binding zero-floats policy.

## Verification

Per slice: TDD (failing test in `tests/` first), `cargo check --workspace --profile prod`,
`cargo test --workspace --profile prod`, `cargo clippy --all-targets -- -D warnings`,
`cargo fmt --check`; Python repos `ruff check . && ruff format --check .`, `pyright`,
`pytest -q`. The end-to-end gate is T14.14: one golden event tape → byte-identical fills in all
four embeddings.
