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

## Verify your install

Run these six checks in order. If all of them print without an error, your
environment is ready — you will not be blocked by tooling at any later point in
the book.

```bash
# 1. Python version (must be 3.12.x)
python --version
```

```bash
# 2. Every wheel surface imports
python -c "from tantra import Strategy, Parameter, run"
python -c "from tantra_examples import synthetic_bars, SampleInstruments, trending_bars, Backtest, RSI, SMA, walk_forward_optimize"
python -c "from tantra.options import bs_price, bs_greeks, implied_volatility"
python -c "from tantra.quant import returns, mean, std_dev, covariance_matrix, ols"
python -c "from tantra.paper import PaperSession; from tantra.instrument import InstrumentId"
python -c "from tantra.portfolio_strategy import build_portfolio_strategy, EqualWeight, TopN, momentum, low_volatility, MonthlyFirstSession, NamedUniverse, InverseVolatility, DriftBand"
python -c "from tantra.screener import load_catalog, MetricCatalog"
```

```bash
# 3. Synthetic data is deterministic: 250 bars, and the last close is a Decimal
python -c "from tantra_examples import synthetic_bars, SampleInstruments; b = synthetic_bars(SampleInstruments.NIFTY50, days=250, seed=42, base_price_paise=24_000); print('bars:', len(b), '| last close:', b[-1].close)"
```

```bash
# 4. Indicators stream Decimal values and return None until warmed up
python - <<'PY'
from tantra_examples import synthetic_bars, SampleInstruments
from tantra.indicators import SMA, RSI
bars = synthetic_bars(SampleInstruments.NIFTY50, days=250, seed=42, base_price_paise=24_000)
sma = SMA(20)
rsi = RSI(14)
for bar in bars:
    sma.add(bar.close)
    rsi.add(bar.close)
print("last close:", bars[-1].close)
print("SMA-20:", sma.value())
print("RSI-14:", rsi.value())
PY
```

```bash
# 5. Paper trading fills an order against a market price
python - <<'PY'
from decimal import Decimal
from tantra.paper import PaperSession
from tantra.instrument import InstrumentId
session = PaperSession(cash=Decimal("1000000"), seed=7)
inst = InstrumentId("RELIANCE", "NSE")
session.set_market_price(inst, Decimal("2400"))
session.place_order(inst, "BUY", Decimal("10"), order_type="LIMIT", limit_price=Decimal("2400"))
session.advance_to("2023-11-14T22:14:00Z")
print("cash:", session.cash())
print("positions:", session.positions())
print("fills:", session.fills())
PY
```

```bash
# 6. The strategy surface runs a backtest end-to-end
python - <<'PY'
from tantra_examples import synthetic_bars, SampleInstruments
from tantra import Strategy, run
class Demo(Strategy):
    def on_bar(self, bar):
        self.buy("NSE:RELIANCE-EQ", 1)
bars = synthetic_bars(SampleInstruments.NIFTY50, days=250, seed=42, base_price_paise=24_000)
result = run(Demo(), bars)
print("bars_processed:", result.bars_processed)
print("orders_filled:", result.orders_filled)
PY
```

**Expected result of the six checks:** check 3 prints `bars: 250` and a Decimal
last close (the same number for every learner, thanks to `seed=42`); check 4
prints Decimal `SMA-20` and `RSI-14` values — not `None` — because 250 bars are
well past the 20/14 warm-up lengths; check 5 prints cash reduced from
`Decimal("1000000")`, one filled position, and one fill; check 6 prints
`bars_processed: 250` and an `orders_filled` count.

> **Determinism is the point.** Fix `seed` and `base_price_paise` exactly as the
> lab says, and every learner's screen shows the same bars. If a lab output is
> "expected to match", it matches because of those two arguments.

## Common install problems and fixes

1. **`maturin: command not found`** — `maturin` is the build tool for the Rust
   wheel. Install it with `pip install maturin`, or ask a mentor for a prebuilt
   wheel and install that (`pip install <path>/tantra-….whl`). You never need
   the Rust toolchain to run labs.
2. **`ModuleNotFoundError: No module named 'tantra'`** — you are in a different
   Python environment from the one where you installed. Run `which python` and
   `pip show tantra`; install into the *same* interpreter
   (`python -m pip install -e .` inside `tantra-ffi`) and re-run the checks.
3. **`ImportError` on a submodule like `tantra.options`** — you are on an older
   wheel that predates that surface. Rebuild (`maturin develop` in `tantra-ffi`)
   or reinstall `tantra-examples`, then re-run check 2. Record `tantra.__version__`
   in your journal when a lab behaves unexpectedly.
4. **A `TypeError`, or an indicator that never warms up** — you passed a `float`
   like `100.5` where the wheel expects `Decimal("100.5")`. Check `type(price)`.
   Prices, quantities, fees, and balances are always `Decimal` in this wheel.
5. **My indicator prints `None` for the first bars — is it broken?** No. These
   are *streaming* indicators: `SMA(20)` needs 20 prices before it can return a
   value, and it returns `None` until then. Handle `None` explicitly in every lab
   (the labs show you how) and do not treat it as a bug.
6. **My numbers differ from a lab in the book** — determinism comes from the two
   arguments, not from luck. A lab that prints 250 bars for
   `seed=42, base_price_paise=24_000` prints the same 250 bars for every
   learner; if yours differ, check the arguments before you check the wheel.

## Lab conventions used in this book

- Every **Tantra Lab** block is a complete, runnable script (or a clearly marked
  snippet) tested against the wheel surface.
- Prices are always `Decimal`; never use `float` for a price, quantity, fee, or
  balance (workspace Zero-Floats policy).
- Determinism: fix a `seed` and a `base_price_paise` so every learner sees the
  same bars and can compare outputs.

## The lab workflow

Every lab in this book follows the same four steps — internalise them once and
every lab from S1-M2 to the S5 capstone runs the same way:

1. **Run.** Execute the lab script (or its linked example script) exactly as
   written. Copy the terminal output into your journal before touching anything.
2. **Inspect.** For each line of output, write one sentence saying what it means.
   Then re-run once with a *changed parameter* (for example, `SMA(20)` →
   `SMA(50)`) and note what changed. This re-run is where the learning happens.
3. **Journal.** Record: date, lab/script name, output (exact Decimal values, or
   an approximation marked with `≈`), one lesson, and one open question. Keep an
   entry under half a page — the habit matters more than the prose.
4. **Hand in.** When a lab's "Hand-in checklist" appears, submit the output, the
   journal entry, and the answers to the questions it lists.

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

## Directory map: wheel surfaces vs example scripts

Use this table to jump between a wheel surface and the scripts that exercise it.
All imports below are the verified surfaces used throughout the book.

| Wheel surface | Verified imports | Example scripts that exercise it |
|---|---|---|
| Synthetic data | `from tantra_examples import synthetic_bars, SampleInstruments, trending_bars` | `examples/01_loading_data.py`, `examples/02_indicators.py` |
| Indicators | `from tantra.indicators import SMA, EMA, RSI, Macd, Bollinger, Atr, Ichimoku, Adx, Donchian` | `examples/02_indicators.py`, `strategies/02_with_indicators.py` |
| Strategy + backtest | `from tantra import Strategy, Parameter, run` | `backtesting/01_first_backtest.py`, `examples/07_turtle_breakout_backtest.py`, `backtesting/04_walk_forward.py`, `examples/10_walkforward_optimization.py` |
| Paper trading | `from tantra.paper import PaperSession`; `from tantra.instrument import InstrumentId` | `basic/06_paper_trading.py` |
| Quant helpers | `from tantra.quant import returns, mean, std_dev, covariance_matrix, ols` | `backtesting/05_monte_carlo.py`, `examples/15_fama_macbeth_factor_regression.py` |
| Options | `from tantra.options import bs_price, bs_greeks, implied_volatility` | `options/01_option_chain.py`, `options/02_greeks_calculation.py`, `options/03_backtest_straddle.py` |
| Portfolio strategy | `from tantra.portfolio_strategy import build_portfolio_strategy, EqualWeight, TopN, momentum, low_volatility, MonthlyFirstSession, NamedUniverse, InverseVolatility, DriftBand` | `mutual_funds/04_portfolio_optimization.py` |
| Screener | `from tantra.screener import load_catalog, MetricCatalog` | `screening/01_multibagger_screener.py`, `screening/04_intelligent_investor_screener.py`, `screening/05_net_net_screener.py` |

## Zero-Floats reminders

- `f32`/`f64` and Python `float` are **forbidden** for prices, quantities,
  balances, fees, and margin math.
- Indicators in this wheel accept `Decimal` and return `Decimal | None` until
  warmed up — handle `None` explicitly in every lab.
