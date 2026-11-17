# M4 — Performance Measurement

> **Weeks 54–55 · 12 hrs · PLO-8 · Core:** IFMC item 38; PGP T4(PM)-401/402

## Learning outcomes

- Compute Sharpe, Treynor, and Jensen's alpha.
- Choose the right measure for the right context.
- Read a fund/strategy scorecard and explain it to a client.

## Lesson 4.1 — Sharpe ratio

```
Sharpe = (Rp − Rf) / σp
```

- Reward per unit of **total risk**. Best for comparing well-diversified
  portfolios. Note: the S2-M6 CML slope is a Sharpe ratio.

## Lesson 4.2 — Treynor ratio

```
Treynor = (Rp − Rf) / βp
```

- Reward per unit of **systematic risk**. Best for concentrated/undiversified
  portfolios.

## Lesson 4.3 — Jensen's alpha & beta

```
α = Rp − [Rf + βp·(Rm − Rf)]      (from CAPM / SML)
```

- `α > 0`: the manager earned more than CAPM predicted for its beta.
- `β`: exposure to the market; the SML coordinate.

## Lesson 4.4 — Choosing measures

| Question | Measure |
|---|---|
| Is the portfolio diversified? | Sharpe |
| Is it a focused/concentrated book? | Treynor |
| Did the manager beat CAPM? | Jensen's α |
| Total return vs index? | Information ratio (extension) |

## Tantra Lab 4 — Sharpe & Treynor from the wheel

```python
from decimal import Decimal
from tantra.quant import returns, mean, std_dev
from tantra_examples import SampleInstruments, synthetic_bars

# Compute Sharpe = (Rp - Rf) / σp exactly in Decimal.
# (The wheel's optimizer.sharpe_sortino_dd is a *fitness aggregator*, not a
#  Sharpe-from-returns function — do the ratio yourself.)
def sharpe(rets: list[Decimal], rf: Decimal) -> Decimal:
    return (mean(rets) - rf) / std_dev(rets)

rets = returns([b.close for b in synthetic_bars(SampleInstruments.NIFTY50, days=250, seed=42)])
print("Sharpe (daily):", sharpe(rets, Decimal("0.0001")))
```

**Task:** extend the script for Treynor (`(Rp − Rf)/β` using the beta from
S4-M2) and Jensen's alpha (`Rp − [Rf + β(Rm − Rf)]`). Score three mutual funds
(or three synthetic strategies) with Sharpe, Treynor, and alpha; build a
comparison table in Excel; write which fund you'd recommend and why. Read
`mutual_funds/04_portfolio_optimization.py` for the full scoring pipeline.

## Assessment

- Fund-scorecard assignment (3 funds).
- Quiz: measure selection.

**Next:** [M5 — Derivatives: Forwards & Futures](m5-forwards-futures.md)
