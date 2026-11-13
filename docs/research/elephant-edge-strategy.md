# Elephant Edge Strategy — Research Report

**Scope:** Intraday price-action + smart-money (institutional / market-maker) support–resistance system for Indian indices/stocks, typically anchored after the first 1-minute candle of the session, plus a concrete plan to strengthen it with option-chain, open-interest, and dealer-positioning (GEX) data.

**Date:** 2026-11-13
**Status:** Research / design input — not a trading recommendation.

---

## 1. What "Elephant Edge" actually is

The name is used for two related but distinct things that are frequently conflated:

1. **AlgoBing "Elephant Edge"** (TradingView, invite-only) — the dominant commercial reference. An advanced *intraday support/resistance* indicator + strategy that maps S/R zones, filters price action at those zones, and automates entries/exits. Intraday-only (1–15 min charts).
2. **Oliver Velez's "elephant bar" concept** — a candle with a very large solid body (≈70%+ of the candle range) and small wicks. This is the *institutional footprint* idea behind the name: institutions split large orders, so a fat-bodied candle is their unavoidable signature ("an elephant cannot hide in a mouse hole"). A green elephant bar = heavy institutional buying; a red one = heavy selling. This is the "smart money" reasoning in the user's description.

The user's description — "two support and two resistance levels, usually done after the first 1m candle of the day" — matches the **Level 1–4 percentile configuration** of the AlgoBing system (two lower-percentile support zones + two upper-percentile resistance zones), with levels being read after the opening candle sets the day's anchor.

---

## 2. How the AlgoBing system works (three modules)

### Module 1 — Elephant Edge S/R zones (dynamic, session-based)
This is the core module and the source of the "two supports / two resistances":

- Tracks **historical intraday session ranges** (prior sessions' price expansion behavior).
- Computes **percentile distances** of price movement from the session open, from that history.
- Projects the zones **symmetrically above and below the current session open**.
- Documented default bands (user-configurable): **Level 1–2 (support) ≈ 25th / 35th percentiles**, **Level 3–4 (resistance) ≈ 63rd / 74th percentiles**.
- Zones are drawn as **bands (colored boxes), not single lines**, are **session-fixed** (reset every day), and **expand/contract automatically** with changing volatility (because the underlying percentiles come from realized session ranges).
- Lower-percentile zones are treated as potential support reaction areas; upper-percentile zones as potential resistance.

**Mechanically**, this is a volatility-adaptive Opening-Range concept: instead of using a fixed "X points from open", it uses *percentile distances derived from the distribution of past session expansion*. On high-volatility regimes the levels sit far from the open; on low-volatility days they hug it.

### Module 2 — Previous-Day OHLC zones
- Plots prior day Open / High / Low / Close as fixed intraday reference lines.
- Rationale: widely watched by traders and institutions → common reaction, balance, or decision points.
- Optional **candle-touch filter**: entry allowed only if a candle actually pierces one of these levels (e.g., long only after price trades below yesterday's close/low and recovers).

### Module 3 — Strike-price / round-number zones (F&O)
- Plots horizontal levels at fixed **strike intervals** (e.g., every 50/100 points) around the session open.
- Rationale: round numbers and standard option strikes are **liquidity clusters / psychological levels**.
- `touchLower` / `touchUpper` flags: a buy is valid only if a candle pierced the *lower* strike band; a sell only if it pierced the *upper* band. The strategy then either breaks out of the band or rebounds off it.
- **Important:** this module approximates strikes *geometrically* — it does **not** read actual option open interest. That is exactly the weakness the strengthening plan in §4 addresses.

### Entry / exit mechanics (as documented by the vendor)
- **Entry types:** Breakout (1) or Crossover (2); Buy-only / Sell-only / Both; optional "alternate mode" (forces long/short alternation).
- **Zone-touch filters:** same-bar hit of a support/resistance level required before entry is allowed.
- **Candle-structure validation:** Marubozu detection (large body, small wicks — the "elephant" signature), min/max candle-size limits, body-size limits, Doji detection, hammer wicks (wick:body ratio), all auto-scaling with volatility.
- **Volume participation validation:** highlights/rewards candles near zones that occur on a volume spike relative to recent candles.
- **Context:** daily pivot plotted as a session-fixed reference.
- **Timing:** entry window (e.g., 09:15–14:30), exit window (e.g., 15:10–15:30), max trades/day.
- **SL/Target:** fixed points, candle high/low, percentage, risk–reward multiple, or ATR trailing.
- **Execution:** buy order placed just above the trigger candle high + buffer, sell just below its low (breakout-style execution).
- Vendor claims **no repaint** (levels/signals computed from closed bars; entries fire on the live bar when conditions confirm).

### Where the "first 1m candle" rule comes from
The indicator anchors on the *session open* + historical percentiles, but the widely-circulated manual practice is: **after the first 1-minute candle at 09:15 closes, draw the day's structure** — the candle's open/high/low plus the Elephant percentile zones projected from the open. Variants use the first 2-min candle (Velez: 09:15–09:17) or first 5-min candle. The "two supports + two resistances" wording maps to Level 1–4 (25/35 support, 63/74 resistance). The first candle condenses the most information of the day (overnight news, pending orders, gap resolution all price in at the open), which is why it is used as the daily anchor.

---

## 3. The smart-money reasoning (why the levels should matter)

- **Institutions trade in size** and split orders; their footprint shows up as wide-range, small-wick candles (elephant bars) and as *clusters of resting orders* at price levels they defend.
- **Where do their resting orders cluster?** (a) at the edges of the prior session's expansion (where they ran out of inventory yesterday — hence the percentile zones); (b) at round/strike numbers and OI walls (where option writers and hedgers place defense orders); (c) at previous-day H/L/C (stop and breakout clusters).
- **The price-action filter is the "confirmation of participation":** rather than trading a level touch alone, the system wants a *clean reaction candle* (marubozu / hammer / doji) *with volume* at a zone — evidence that the big supply/demand actually showed up at that price.

This makes the strategy structurally: *volatility-adaptive level map (context) + institutional-footprint confirmation (trigger) + time/trade-count discipline (filters)*.

---

## 4. Strengthening with option chain, open interest, and dealer positioning

The stock indicator's strike module is geometric only. The real strength comes from overlaying **actual derivatives positioning**. These layers are ordered by difficulty of implementation and by how directly they express "market-maker / institutional" behavior.

### Layer A — OI walls: real strike-based S/R (the direct upgrade)
- **Highest Call OI strike above spot = resistance; highest Put OI strike below spot = support.**
- Mechanism: option writers defend these strikes; as spot approaches a put wall, put sellers' delta-hedging **buys** futures (creating a floor); near a call wall, call sellers' hedging **sells** futures (creating a ceiling).
- For intraday: use the **nearest weekly expiry**; take the **top-2 call OI strikes above spot and top-2 put OI strikes below spot** → this directly gives the "two resistance / two support" analogue in strike space.
- Treat as zones (±1 strike), not single levels.

### Layer B — Change in OI: level freshness (build-up vs unwinding)
Static OI is a stale photograph; the intraday question is whether a wall is being **reinforced or abandoned**:
- **Rising OI at a wall** = writers adding → level *strengthening*.
- **Falling OI at a wall** = unwinding → level *weakening* (do not trust it).
- Classify by price action of the premium (the 4-scenario OI matrix):
  - OI ↑ + premium ↑ = **long build-up** (bullish)
  - OI ↑ + premium ↓ = **short build-up / writing** (defensive — level being defended)
  - OI ↓ + premium ↓ = **long unwinding**
  - OI ↓ + premium ↑ = **short covering** (wall dissolving)
- Rule: *only trade an OI wall while the strike's OI is still growing intraday.*

### Layer C — Put-Call Ratio (sentiment overlay)
- **OI PCR > ~1** (more puts outstanding) = put-writing defense → firmer support; **PCR < ~0.7** = call-heavy → resistances are harder.
- **Volume PCR** gives the intraday shift earlier than OI PCR.
- Use as a *directional tilt*, never a standalone signal.

### Layer D — Max pain (expiry-day magnet)
- The strike where option buyers as a group lose the most at expiry (where writers collect the most premium).
- Reliability is **time-of-day dependent** on expiry day: weak 09:15–12:00 (external drivers dominate), moderate 12:00–14:00, growing 14:00–15:00, strong 15:00–15:30.
- **Strong pin** when max pain coincides with the highest put OI strike. Use it as a *target/context level* in the last 2–3 sessions of an expiry, not as a morning S/R.

### Layer E — Gamma exposure / dealer positioning (the true market-maker layer)
This is the most direct expression of "smart-money / market maker" behavior and the biggest upgrade to the concept:

- **GEX** estimates the aggregate delta-hedging flow dealers must execute per point of underlying move, built from OI × option gamma × price scaling. Dealers are hedgers, not directional speculators — their flow is *mechanical*, which is exactly why it is readable.
- **Long-gamma regime (net GEX > 0):** dealers buy dips / sell rallies → ranges compress, price **pins** near heavily-traded strikes → *mean-reversion* setups at walls are favored; breakout trades fail.
- **Short-gamma regime (net GEX < 0):** dealers' hedging amplifies moves → trend days, breakouts follow through, walls break cleanly → *momentum/breakout* setups favored; fading the move is how accounts die.
- **Gamma flip level** = spot where net GEX crosses zero. Above it: pin/mean-revert behavior. Below it: trend/amplify behavior. This single number is a regime switch for the whole day's game plan.
- **Call wall / put wall** (largest *gamma* concentration, not raw OI) behave as stronger S/R than raw OI walls because hedging flow is heaviest there.
- **Caveats:** GEX is a *model*, not a disclosure (dealer inventory is assumed, typically "dealers are short calls / long puts"), different platforms can disagree on sign/levels; OI refreshes are delayed/provisional intraday, official at EOD; the map is redrawn daily (hourly on heavy expiry sessions). Always demand confluence with price behavior before trading a gamma level.

### Layer F — IV / IV skew (volatility calibration)
- **ATM IV / India VIX** → expected daily move (≈ spot × IV/√252, or an ATM straddle price). Use it to (a) set zone widths, (b) validate that a target-to-stop distance is achievable, (c) skip days where the expected move is too small to overcome costs.
- **IV skew:** steep put skew = downside strikes more defended (support premium); call skew = upside defended. Skew tells you which side of the chain is "backing" your levels.

### Layer G — Futures & flows (directional context)
- **Index futures basis** (premium/discount vs spot) and **FII/DII index-futures OI** as a directional tilt.
- **GIFT Nifty** (early session) as a leading read before/at the open — if GIFT Nifty rejects a level before spot reaches it, respect the spot level more.

---

## 5. Recommended fusion model (Elephant Edge + options stack)

A **confluence-scoring** system rather than "indicator on top of indicator":

1. **Base map:** Elephant percentile zones (2S + 2R from §2 Module 1) anchored on the session open / first 1-min candle.
2. **Overlay levels:** top-2 CE OI strikes (resistance), top-2 PE OI strikes (support), PDH/PDL, gamma flip level, max pain (on expiry).
3. **Score each level (0–4):**
   - +1 if an Elephant zone aligns with an OI wall or PDH/PDL (cluster).
   - +1 if that wall is *building* (positive ΔOI intraday).
   - +1 if PCR / IV skew supports the direction of the trade at that level.
   - +1 if the dealer-gamma regime agrees with the planned play (long-gamma → take the *reaction* at the wall; short-gamma → only take the *break* of the wall).
4. **Trigger:** require a clean price-action confirmation at the level (marubozu / hammer / engulfing + volume participation), not a bare touch. Take **first-touch** reactions at high-scoring levels; treat repeated touches as weakening.
5. **Risk:** stop beyond the level *cluster* ± buffer; target = next confluence level; sanity-check the R:R against the IV-implied expected move.
6. **Discipline:** entry time window, max trades/day, square off before the close — unchanged from the base strategy.

**Regime table (quick reference):**

| Regime | Dealer gamma | Behavior at walls | Preferred play |
| :--- | :--- | :--- | :--- |
| Pin / range | Long (positive) | Walls hold, price drifts to pin | Mean-reversion: fade extremes, target center |
| Trend / expand | Short (negative) | Walls break and become floors/ceilings | Breakout & retest of broken walls |
| Expiry day | Mixed → pins | Max-pain gravity 14:00–15:30 | Use max pain as final-hour target |

---

## 6. Data sources & practical notes for systematic implementation

- **NSE public option chain** (strike-wise OI, ΔOI, volume, IV, LTP) — snapshot every few minutes intraday; official file at EOD. This is sufficient to compute OI walls, ΔOI matrix, PCR, max pain, and per-strike GEX (Black-76 gamma × OI × lot size × spot scaling).
- **India VIX**, **FII/DII index futures OI** (NSE public files), **GIFT Nifty** for the early read.
- **Freshness rule:** OI levels move intraday — recompute the overlay every 5–15 minutes; never trade an overnight OI wall as if it were current.
- **Expiry rollover:** the nearest weekly expiry changes each week (Nifty: Thursday; Bank Nifty: Wednesday) — the chain and its walls shift; use the *correct* expiry and watch the roll.
- **Validation discipline:** percentile-lookback windows and exact defaults of the proprietary script are not public — the only way to trust any variant is to backtest it on your own data (golden-vector parity, in the Tantra sense) before going live. Cost, slippage, and STT matter a lot at intraday scale.

---

## 7. Honest assessment & caveats

- **Proprietary source:** the AlgoBing script is invite-only (~₹2,999–7,999 for 3–12 months); source code is not available. Everything above is reconstructed from the vendor's own documentation and the TradingView page. The percentile default bands (25/35, 63/74) and the module structure are documented; the exact historical lookback and interpolation method are not.
- **What likely carries the real edge** (independently testable): (1) volatility-adaptive levels instead of fixed ATR multiples, (2) confluence between price-derived levels and derivatives positioning, (3) institutional-footprint price-action confirmation + time/trade-count discipline. None of these require the paid script.
- **The option-chain overlay (Layers A–G) is a strict improvement** over the base design because the base strike module is purely geometric — it never looks at actual OI, so it cannot know which strikes are *being defended*.
- **GEX caveats:** estimate, not fact; dealer-side assumption differs across vendors; intraday OI is provisional. Use GEX for regime classification and wall ranking, not as a point-level price target.
- **Not a recommendation:** this is a research synthesis for building/testing a systematic intraday strategy, not investment advice.

---

## Appendix — Quick level-map checklist for a session

1. 09:15: let the first 1-min candle close → record session open / first-candle high-low.
2. Compute Elephant percentile zones (2S / 2R) from the session-open anchor.
3. Pull the option chain (nearest weekly expiry): top-2 CE OI above spot, top-2 PE OI below spot; note ΔOI sign at those strikes; PCR; max pain; gamma regime & flip.
4. Mark PDH / PDL / previous close on the chart.
5. Cluster-map: mark all levels that coincide; score 0–4.
6. Trade only at score ≥ 3 levels with a clean reaction candle + volume, first-touch preference, in the entry window.
7. Target = next confluence level; stop = beyond the level cluster; square off before close.
