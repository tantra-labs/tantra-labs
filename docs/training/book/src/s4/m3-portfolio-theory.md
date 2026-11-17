# M3 — Portfolio Theory: Markowitz, CAL, SML & CML

> **Weeks 53–54 · 20 hrs · PLO-8 · Core:** IFMC items 26, 29–30; NIFM Ch 37; PGP T2-202

## Learning outcomes

- Compute portfolio expected return and variance for two or more assets.
- Explain diversification and the efficient frontier.
- Derive the CAL, CML, and SML lines and the capital-market line intuition.
- Use the Markowitz mean-variance framework.

## Lesson 3.1 — Portfolio return and variance

For two assets with weights `w1, w2`:

```
E(Rp) = w1·E(R1) + w2·E(R2)
Var(Rp) = w1²σ1² + w2²σ2² + 2·w1·w2·Cov(1,2)
```

- The magic of diversification: `Cov < σ1σ2` makes portfolio σ < weighted σ.

## Lesson 3.2 — The efficient frontier (Markowitz)

- For each return, the minimum-σ portfolio; the frontier is the upper envelope.
- Dominance: no rational investor holds a portfolio *below* the frontier.

## Lesson 3.3 — CAL, CML and SML

- **CAL** (Capital Allocation Line): mixing a risky portfolio with the risk-free
  asset; slope = Sharpe ratio.
- **CML** (Capital Market Line): the CAL for the market portfolio when all
  investors hold the same risky portfolio.
- **SML** (Security Market Line): from CAPM, plots `E(R) vs β` — *every* fairly
  priced asset sits on it; assets above are undervalued (alpha).

## Lesson 3.4 — Behavioral finance overlay

- Why real investors deviate: loss aversion, herding, overconfidence
  (bridges S2-M7 psychology into portfolio decisions).

## Tantra Lab 3 — Two-asset frontier

```python
from decimal import Decimal
from tantra.quant import returns, mean, std_dev, covariance_matrix
from tantra_examples import SampleInstruments, synthetic_bars

a = returns([b.close for b in synthetic_bars(SampleInstruments.RELIANCE, days=250, seed=1)])
b = returns([b.close for b in synthetic_bars(SampleInstruments.TCS,      days=250, seed=2)])

w = Decimal("0.5")
rp = w * mean(a) + (Decimal(1) - w) * mean(b)
cov = covariance_matrix([[x, y] for x, y in zip(a, b)])[0][1]
varp = (w**2) * (std_dev(a) ** 2) + ((Decimal(1) - w) ** 2) * (std_dev(b) ** 2) + 2 * w * (Decimal(1) - w) * cov
print("Rp:", rp, "σp:", varp.sqrt())
```

**Task:** sweep `w` from 0 to 1 in steps of 0.1, plot the frontier curve, and
identify the minimum-variance portfolio. Read
`tantra-examples/examples/12_portfolio_allocation.py` for the full machinery.

## Assessment

- Portfolio-theory worksheet + frontier chart.
- Quiz: CAL/CML/SML differences.

**Next:** [M4 — Performance Measurement](m4-performance-measurement.md)
