# Tantra Platform & Lab Environment

Every hands-on exercise in this book runs on the **Tantra platform** — the
open-source quantitative trading stack that lives in this workspace. It is fully
offline, deterministic, and uses **exact Decimal arithmetic** (no floats for
money or prices).

## What you install

```bash
# 1. Build/install the `tantra` Python wheel (Tier 4 FFI bridge)
cd tantra-ffi
maturin develop            # or: pip install -e . if a wheel is available

# 2. Install the learning-path examples package
cd tantra-examples
pip install -e .           # provides tantra_examples (synthetic data, SDK helpers)

# 3. (Optional) run the platform CLI
python -m tantra.cli --help
```

> If `maturin` is unavailable, ask a mentor for a prebuilt wheel. All lab code in
> this book is written against the **wheel surfaces** shown below.

## The five surfaces you will use

| Surface | What it gives you | Import |
|---|---|---|
| **Synthetic data** | Deterministic OHLCV bars (NIFTY, BANKNIFTY, RELIANCE, INFY, TCS) | `from tantra_examples import synthetic_bars, SampleInstruments` |
| **Indicators** | Streaming Decimal indicators (SMA/EMA/RSI/ATR/MACD/Bollinger/Ichimoku/…) | `from tantra.indicators import SMA, RSI, Atr, Bollinger, Macd, Ichimoku` |
| **Paper trading** | Deterministic `PaperSession` on the native engine | `from tantra.paper import PaperSession` |
| **Backtesting** | `Strategy` + `run()` with SEBI pre-trade risk gate | `from tantra import Strategy, run` |
| **Quant & options** | `returns`, `mean`, `std_dev`, `covariance_matrix`, `ols`, Black-Scholes | `from tantra.quant import …`; `from tantra.options import bs_price, bs_greeks` |

## First-lab smoke test

Copy `tantra-examples/examples/01_loading_data.py` and run it. You should see a
summary dict with `bars_generated: 250` and `monotonic_ts: True`. If that works,
your environment is ready.

## Lab conventions used in this book

- Every **Tantra Lab** block is a complete, runnable script (or a clearly marked
  snippet) tested against the wheel surface.
- Prices are always `Decimal`; never use `float` for a price, quantity, fee, or
  balance (workspace Zero-Floats policy).
- Determinism: fix a `seed` and a `base_price_paise` so every learner sees the
  same bars and can compare outputs.

## Where the example scripts live

The numbered learning path is the official companion to this book:

```text
tantra-examples/examples/
├── 01_loading_data.py            # bars to CSV round-trip
├── 02_indicators.py              # SMA cross + RSI in Decimal
├── 07_turtle_breakout_backtest.py
├── basic/06_paper_trading.py     # PaperSession round-trip
├── backtesting/01_first_backtest.py
├── options/01_option_chain.py, 02_greeks_calculation.py
├── screening/01_multibagger_screener.py
└── strategies/02_with_indicators.py, 04_risk_management.py
```

Each module chapter links the lab to the relevant example script.

## Zero-Floats reminders

- `f32`/`f64` and Python `float` are **forbidden** for prices, quantities,
  balances, fees, and margin math.
- Indicators in this wheel accept `Decimal` and return `Decimal | None` until
  warmed up — handle `None` explicitly in every lab.
