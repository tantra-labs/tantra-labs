# `vyapaar-examples` — DDD Architecture & Reference Learning Path

## 1. Bounded Context & Responsibility
`vyapaar-examples` (Tier 6D, ported from `honba-examples`) provides deterministic, offline-runnable educational scripts demonstrating Indian equities, NSE/NFO options microstructure, factor models, walk-forward optimization (WFO), Deflated Sharpe Ratio (DSR), and the autonomous AI research loop.

## 2. Architectural Invariants
* **Offline & Deterministic by Default**: Every example runs out-of-the-box with synthetic/fixture data and `ScriptedFakeLlm` without requiring live broker credentials.
* **Strict Zero-Floats in Financial Math**: All prices, quantities, and fees use `decimal.Decimal`.
* **Mandatory `Pitfalls::` Docstring Section**: Every numbered script (`NN_snake_case.py`) documents real-world Indian market pitfalls (STT traps, freeze limits, T+1 settlement, look-ahead bias).
