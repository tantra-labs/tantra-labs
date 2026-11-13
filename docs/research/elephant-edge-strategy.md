# Elephant Edge Strategy — Research Report

**Scope:** Intraday price-action + smart-money (institutional / market-maker) support–resistance system for Indian indices/stocks, typically anchored after the first 1-minute candle of the session, plus a concrete plan to strengthen it with option-chain, open-interest, dealer-positioning (GEX), and the **mid-month (15th $\pm$ 1 day) institutional reversal cycle**.

**Date:** 2026-11-13
**Status:** Research / design input — not a trading recommendation.

---

## 1. What "Elephant Edge" actually is

The name is used across three related lineages in the retail and quantitative trading communities:

1. **AlgoBing "Elephant Edge"** (TradingView, invite-only) — the dominant commercial automated reference. An advanced *intraday support/resistance* indicator + strategy that maps S/R zones, filters price action at those zones, and automates entries/exits. Intraday-only (1–15 min charts).
2. **Tanisha Garg / Elephant Club ("Elephant Edge" v1, v2, v3)** — the widely taught discretionary/rule-based Indian index-options methodology. Popularized the **"Plus-Two" candle confirmation rule**, the **6-candle time-stop** (to prevent options theta decay in sideways chop), **asymmetric 3R / 4R / 5R payout milestones**, the **mid-month (15th $\pm$ 1 day) cycle reversal rule**, and the progression from **v1** (1-min opening anchor + ATR/Fibonacci zone expansion) → **v2 (2.0)** (RSI momentum confirmation, minimum 50% candle-body ratio, "No-Trade / Avoid Mid-Zone" chop filter, Plus-Two confirmation, mid-month reversal awareness) → **v3** (modular strike-grid snapping, multi-timeframe 15m/5m/1m confluence, automated 2R/3R/4R/5R target visualizers).
3. **Oliver Velez's "elephant bar" concept** — a candle with a very large solid body (≈50–70%+ of the candle range, range ≥ 1.5×ATR) and small wicks. This is the *institutional footprint* idea behind the name: institutions split large orders, so a fat-bodied expansion candle is their unavoidable signature (*"an elephant cannot sneak into a swimming pool without displacing water"*). A green elephant bar = heavy institutional buying; a red one = heavy selling.

The user's description — "two support and two resistance zones from the 1m candle close of everyday, with 3R and 4R/5R targets, plus mid-month 15th $\pm$ 1 day reversals" — combines the **Level 1–4 zone architecture** (AlgoBing session-range percentiles and/or v1/v2 Fibonacci-ATR 1.618× / 2.618× range extensions from the 09:16 IST 1-min close) with the **Elephant Club R-multiple & mid-month institutional cycle discipline**.

---

## 2. How the base system works (modules & evolution)

### Module 1 — Elephant Edge S/R zones (dynamic, session-based)
This is the core module and the source of the "two supports / two resistances" ($S_1, S_2$ and $R_1, R_2$), implemented in two complementary ways across versions:

```
                  =============================  Resistance Zone 2 (R2)  [Deep Supply / Blow-off]
                  -----------------------------

                  =============================  Resistance Zone 1 (R1)  [Primary Hurdle / 3R Target]
                  -----------------------------
                                ▲
                                │  Range Expansion (25/35 & 63/74 Percentiles
                                │  OR 1.618x / 2.618x 1-min Anchor Range)
                                ▼
         [ 09:15-09:16 1-min Candle Anchor ] ---> Session Equilibrium (C_1min)
                                ▲
                                │  (Avoid / Chop Mid-Zone between S1 and R1)
                                ▼
                  -----------------------------
                  =============================  Support Zone 1 (S1)     [Primary Demand / 3R Target]

                  -----------------------------
                  =============================  Support Zone 2 (S2)     [Deep Liquidity / Panic Flush]
```

- **Method 1A — Historical Session-Range Percentiles (AlgoBing):**
  - Tracks **historical intraday session ranges** (prior N sessions' price expansion behavior).
  - Computes **percentile distances** of price movement from the session open, from that history.
  - Projects the zones **symmetrically above and below the current session open / 1-min anchor**.
  - Documented default bands (user-configurable): **Level 1–2 (support $S_1, S_2$) ≈ 25th / 35th percentiles**, **Level 3–4 (resistance $R_1, R_2$) ≈ 63rd / 74th percentiles**.
- **Method 1B — 1-Min Anchor Volatility / Fibonacci Projection (v1/v2 clones):**
  - Locks the **first 1-minute candle close ($C_{1\text{min}}$ at 09:16:00 IST)** and effective range $\text{Range}_1 = \max(H_1 - L_1, \text{ATR}_{14})$.
  - Computes zone centers at **$1.618 \times \text{Range}_1$ ($S_1, R_1$)** and **$2.618 \times \text{Range}_1$ ($S_2, R_2$)** around $C_{1\text{min}}$, with zone thickness $\text{Buffer} = \max(0.382 \times \text{Range}_1, 0.25 \times \text{ATR}_{14})$.
- In both methods, zones are drawn as **bands (colored boxes), not single lines**, are **session-fixed** (reset every day), and **expand/contract automatically** with changing volatility.

### Module 2 — Previous-Day OHLC zones
- Plots prior day Open / High / Low / Close (PDH / PDL / PDC) as fixed intraday reference lines.
- Rationale: widely watched by traders and institutions → common reaction, balance, or stop-hunt decision points.
- Optional **candle-touch filter**: entry allowed only if a candle actually pierces one of these levels (e.g., long only after price trades below yesterday's close/low and recovers).

### Module 3 — Strike-price / round-number zones (F&O)
- Plots horizontal levels at fixed **strike intervals** (e.g., every 50 points on Nifty, 100 points on Bank Nifty) around the session open.
- Rationale: round numbers and standard option strikes are **liquidity clusters / psychological levels**.
- `touchLower` / `touchUpper` flags: a buy is valid only if a candle pierced the *lower* strike band; a sell only if it pierced the *upper* band. The strategy then either breaks out of the band or rebounds off it.
- **Important:** this module approximates strikes *geometrically* — it does **not** read actual option open interest. That is exactly the weakness the strengthening plan in §4 addresses (snapping zones to actual OI walls).

### Version evolution (v1 → v2 → v3)

| Feature | Elephant Edge v1 | Elephant Edge v2 (2.0) | Elephant Edge v3 / EE+ |
| :--- | :--- | :--- | :--- |
| **Primary Logic** | 1-min Opening Candle + ATR/Percentile Zone expansion. | Added false-breakout filters, "Avoid / Chop Mid-Zone", & **15th $\pm$ 1 day mid-month reversal window**. | Full modular suite with strike-wall snapping, mid-month cycle pivot, & automated R-target visualizers. |
| **Noise Filtering** | Basic ATR threshold for Elephant Bars ($> 1.5 \times \text{ATR}$). | Momentum confirmation (RSI > 60 / < 40) + Minimum 50% candle body ratio. | Multi-timeframe confluence (15m macro trend + 5m confirmation + 1m execution). |
| **Trap Avoidance** | High failure rate on sideways/low-volatility days. | Introduces **"Plus-Two" candle confirmation** and **6-Candle time-stop**. | Volatility contraction detection + Option-Chain $\Delta\text{OI}$ / GEX / FII-cycle gating. |

### Entry, exit, and R-multiple mechanics (3R, 4R, 5R)
- **Entry types:** Breakout (1), Reversal/Rejection (2), or Retest (3); Buy-only / Sell-only / Both; optional "alternate mode" (forces long/short alternation).
- **"Plus-Two" confirmation rule:** After an Elephant Bar breaks a zone, require 1–2 follow-through candles sustaining outside the zone boundary before triggering, filtering out early-morning fakeouts.
- **Candle-structure validation:** Marubozu / Elephant Bar detection (body ≥ 50–60% of range, range ≥ 1.5×ATR), hammer/shooting-star wicks (wick:body ratio), Doji avoidance, all auto-scaling with volatility.
- **Volume & Order-Flow participation:** highlights/rewards candles near zones that occur on a volume spike ($\ge 1.5\times$ 20-bar average) and strong Cumulative Volume Delta ($|\text{CVD}| \ge 65\%$ of bar volume) so liquidity-vacuum bars are rejected.
- **Standardized $1R$ Risk & Asymmetric Payouts ($3R, 4R, 5R$):**
  - Initial Stop Loss ($\text{SL}$) is anchored strictly **outside the outer zone boundary + buffer** ($1R = |\text{Entry} - \text{SL}_{\text{zone}}|$).
  - **$3R$ Milestone (Base Intraday Target):** The geometric spacing between $S_1 \leftrightarrow R_1$ or $R_1 \leftrightarrow R_2$ is calibrated to yield $\approx 3R$. Book 50–75% of the position at $3R$ and trail the remaining stop to breakeven.
  - **$4R / 5R$ Milestones (Trend / Squeeze Runners):** Extended targets achieved on short-gamma / short-covering trend days by trailing the stop along ATR or newly formed zones.
- **The "6-Candle Rule" (Time-Stop):** If an open trade fails to reach $\ge 0.5R\text{--}1.0R$ progress within 6 bars (e.g., 30 minutes on a 5-min chart), scratch/exit at market to protect option buyers from theta decay.
- **Timing:** entry window (e.g., 09:20–14:30 IST, avoiding the 09:15–09:16 opening tick noise), square-off window (15:10–15:15 IST), max trades/day.

### Where the "first 1m candle" rule comes from
During the first 60 seconds (09:15:00–09:16:00 IST), uncalibrated retail market orders collide with institutional pre-market VWAP/iceberg execution algorithms:
- **Institutional Absorption (Accumulation):** Retail panic-sells a gap down, while institutions absorb all market sells into passive buy icebergs → long lower wick or high close.
- **Institutional Distribution:** Retail euphoria buys a gap up, while institutional algos unload inventory → rejection upper wick.
The close at **09:16:00 IST** represents the **first true equilibrium price cleared by institutional smart money** after digesting overnight gap noise.

---

## 3. The smart-money reasoning (who we are tracking)

```
┌──────────────────────────────────────────────────────────────────────────────────┐
│                             MARKET PARTICIPANT DYNAMICS                          │
├──────────────────────────────────────────────────────────────────────────────────┤
│ 1. Institutional Option Sellers (Prop Desks & High-Frequency Market Makers)      │
│    - Role: Provide liquidity, collect theta, delta/gamma hedge in futures/cash.  │
│    - Behavior: Defend strike barriers (Heavy Call/Put OI).                       │
│    - Impact: They establish the S1, S2, R1, R2 Elephant Zones.                   │
├──────────────────────────────────────────────────────────────────────────────────┤
│ 2. Directional Smart Money (FIIs, Institutional Asset Managers, Quant Funds)      │
│    - Role: Initiate large multi-day or aggressive intraday directional campaigns. │
│    - Behavior: Absorb supply at demand zones; force short-covering squeezes.     │
│    - Impact: They create the Elephant Breakout Bars and trigger 3R - 5R runs.    │
├──────────────────────────────────────────────────────────────────────────────────┤
│ 3. Retail Participants ("Dumb Money" / Liquidity Providers to Smart Money)       │
│    - Role: 85%+ are net option buyers; trade emotional breakout chasing.         │
│    - Behavior: Cluster stop-losses at obvious wicks and previous day highs/lows.  │
│    - Impact: Their stop orders serve as exit/entry liquidity for institutional   │
│              accumulation and distribution (Stop Hunts / Traps).                 │
└──────────────────────────────────────────────────────────────────────────────────┘
```

### Core failure modes of pure price-action Elephant Edge (without OI/GEX)

| Failure Mode | Pure Price-Action Behavior | Underlying Derivatives Reality |
| :--- | :--- | :--- |
| **False Breakout Trap at $R_1$** | Large Elephant candle closes above $R_1$; triggers a long breakout signal. | Call writers aggressively add contracts at the strike ($\Delta \text{OI}_{\text{Call}} \gg 0$). Dealers absorb buying; market reverses into a bull trap. |
| **Zone Drift (Strike Mismatch)** | Mathematical projection places $R_1$ at e.g. 24,037 based on ATR/percentiles. | Real institutional liquidity sits at the round strike 24,000 or 24,050. Entry and SL are misaligned with the actual wall. |
| **Failed $3R/5R$ Momentum Runs** | Indicator forecasts an expansion to $4R$ or $5R$; price stalls at $1.2R$. | Net dealer gamma is strongly positive ($\text{GEX} > 0$) and no short-covering exists to fuel the expansion. |
| **Premature Stop-Out at $S_1$** | Price wicks 5 points below $S_1$, hitting SL, then reverses sharply higher. | Dealers conducted a liquidity sweep into the strike's option-premium buffer before defending heavy Put OI. |

---

## 4. Strengthening with option chain, open interest, dealer positioning, and the Mid-Month (15th $\pm$ 1 day) Reversal Cycle

The stock indicator's strike module is geometric only. The real strength comes from overlaying **actual derivatives positioning** and **institutional calendar cycles**.

```
+-----------------------------------------------------------------------------------+
|                           ELEPHANT EDGE + OI ENGINE                               |
+-----------------------------------------------------------------------------------+
|  1-Min Opening Anchor (09:16 IST)  +  Option Chain Snapshot (Strikes, OI, GEX)     |
+-----------------------------------------------------------------------------------+
                                         │
        ┌────────────────────────────────┼────────────────────────────────┐
        ▼                                ▼                                ▼
[ Dynamic Zone Snapping ]       [ Regime Filter (GEX) ]        [ Mid-Month Cycle Gate ]
Snap R1/R2 to Max Call OI       Positive Gamma: Mean-Revert    Date in 15th ± 1d Window
Snap S1/S2 to Max Put OI        Negative Gamma: Breakout       + 1st-Half Stretch >= 2.5 ATR
        │                                │                                │
        └────────────────────────────────┼────────────────────────────────┘
                                         ▼
                        [ Execution & Validation Engine ]
                  - Plus-Two Rule + Delta-OI Velocity Check
                  - Short-Covering Confirmation for 3R / 5R Extensions
                  - Rejection Confirmation via Heavy Premium Writing
                  - 6-Candle Stagnation Time-Stop
```

### Layer A — Dynamic Strike Snapping & OI Walls (real strike-based S/R)
- **Highest Call OI strike above spot = resistance; highest Put OI strike below spot = support.**
- Mechanism: option writers defend these strikes; as spot approaches a put wall, put sellers' delta-hedging **buys** futures (creating a floor); near a call wall, call sellers' hedging **sells** futures (creating a ceiling).
- **Dynamic Zone Snapping:** When an Elephant zone ($R_1, R_2, S_1, S_2$) falls within $\pm 1\text{--}1.5$ strike intervals of a major Call/Put OI wall, **snap the zone center to the OI wall strike** and set the band thickness to encompass the strike $\pm$ dealer hedging buffer.
- For intraday: use the **nearest weekly expiry**; take the **top-2 call OI strikes above spot and top-2 put OI strikes below spot** → this directly gives the "two resistance / two support" analogue in strike space.

### Layer B — Change in OI ($\Delta\text{OI}$): breakout squeeze vs trap gatekeeper
Static OI is a stale photograph; the intraday question is whether a wall is being **reinforced (defended) or abandoned (squeezed)**:

```
                             [ Resistance Zone 2 (R2) ]
                                         ▲
                                         │  (Institutions forced to hedge)
                                         │  Short-Covering Velocity -> 4R / 5R
                             [ Resistance Zone 1 (R1) ]
                  ▲                      ▲
                  │ Price Breakthrough   │ Call OI Drops (Writers Flee: Delta-OI < 0)
                  │                      │
       ========================================================================
                      INSTITUTIONAL SUPPLY WALL (Strike K = Max Call OI)
       ========================================================================
                  ▲                      ▲
                  │ Price Touches Zone   │ Call OI Surges (Writers Defend: Delta-OI > 0)
                  │                      │
                             [ Rejection back to Mid / S1 (3R) ]
```

- Classify by the 4-scenario OI + price matrix:
  - OI ↑ + premium ↑ = **long build-up** (bullish directional buying)
  - OI ↑ + premium ↓ = **short build-up / writing** (defensive — wall being actively reinforced)
  - OI ↓ + premium ↓ = **long unwinding**
  - OI ↓ + premium ↑ = **short covering** (writers capitulating — wall dissolving)
- **Actionable Gatekeeper Rules:**
  - **Zone Reversal (Fading $S_1 / R_1$ for $3R$):** Require $\Delta\text{OI}_{\text{Put}} > 0$ at $S_1$ (Put writers defending floor) or $\Delta\text{OI}_{\text{Call}} > 0$ at $R_1$ (Call writers capping upside).
  - **Zone Breakout (Targeting $4R / 5R$ runners):** Require **short-covering ($\Delta\text{OI}_{\text{Call}} < 0$ at $R_1$ for bull breakouts; $\Delta\text{OI}_{\text{Put}} < 0$ at $S_1$ for bear breakdowns)**. If $\Delta\text{OI}_{\text{Call}} > 0$ during an upside breakout, flag it as a **retail bull trap** and skip/fade.

### Layer C — Local Range Put-Call Ratio (sentiment overlay)
- Rather than only total chain PCR (which can be skewed by deep OTM tail hedges), compute **Local Range PCR** across strikes bounded by $[S_2, R_2]$:
  $$\text{PCR}_{\text{Local}} = \frac{\sum_{k \in [S_2, R_2]} \text{Put OI}_k}{\sum_{k \in [S_2, R_2]} \text{Call OI}_k}$$
- **$\text{PCR}_{\text{Local}} > 1.25$:** Put-writing dominance → firmer support ($S_1$ reversals & $R_1$ breakouts favored).
- **$\text{PCR}_{\text{Local}} < 0.75$:** Call-writing dominance → overhead supply dominates ($R_1$ reversals & $S_1$ breakdowns favored).
- **Volume PCR & PCR Divergence:** Intraday Volume PCR leads OI PCR; if price makes higher highs toward $R_1$ while $\text{PCR}_{\text{Local}}$ drops, a reversal at $R_1$ is high-probability.

### Layer D — Max pain & Intraday Max-Pain Migration (expiry-day magnet)
- The strike where option buyers as a group lose the most at expiry (where writers collect the most premium).
- Reliability is **time-of-day dependent** on expiry day: weak 09:15–12:00 (external drivers dominate), moderate 12:00–14:00, growing 14:00–15:00, strong 15:00–15:30.
- **Intraday Max-Pain Migration:** If the calculated Max Pain strike shifts upward during the morning session, Smart Money is actively migrating its defensive floor higher, confirming accumulation.

### Layer E — Gamma exposure / dealer positioning (the true market-maker layer)
This is the most direct expression of "smart-money / market maker" behavior and the biggest upgrade to the concept:

- **GEX** estimates the aggregate delta-hedging flow dealers must execute per point of underlying move:
  $$\text{Dealer GEX} = \sum_{i} \left(\text{OI}_{\text{Call}, i} \times \Gamma_i - \text{OI}_{\text{Put}, i} \times \Gamma_i\right) \times \text{LotSize} \times S^2$$
- **Long-gamma regime (net GEX > 0):** dealers buy dips / sell rallies → ranges compress, price **pins** near heavily-traded strikes → *mean-reversion* setups at walls are favored (cap targets at $2R\text{--}3R$); breakout trades fail.
- **Short-gamma regime (net GEX < 0):** dealers' hedging amplifies moves → trend days, breakouts follow through, walls break cleanly → *momentum/breakout* setups favored (unlock $4R\text{--}5R$ runner targets); fading the move is how accounts die.
- **Gamma flip level** = spot where net GEX crosses zero. Above it: pin/mean-revert behavior. Below it: trend/amplify behavior. This single number is a regime switch for the whole day's game plan.
- **Call wall / put wall** (largest *gamma* concentration, not raw OI) behave as stronger S/R than raw OI walls because hedging flow is heaviest there.
- **Caveats:** GEX is a *model*, not a disclosure (dealer inventory is assumed, typically "dealers are short calls / long puts"), different platforms can disagree on sign/levels; OI refreshes are delayed/provisional intraday, official at EOD; the map is redrawn daily (hourly on heavy expiry sessions). Always demand confluence with price behavior before trading a gamma level.

### Layer F — IV / IV skew (volatility calibration)
- **ATM IV / India VIX** → expected daily move (≈ spot × IV/√252, or an ATM straddle price). Use it to (a) set zone widths, (b) validate that a $3R\text{--}5R$ target distance is achievable within the session's expected move, (c) skip days where the expected move is too small to overcome costs.
- **IV skew:** steep put skew = downside strikes more defended (support premium); call skew = upside defended. Skew tells you which side of the chain is "backing" your levels.

### Layer G — Futures, CVD & Participant Flows (FII / Pro vs Client)
- **Cumulative Volume Delta (CVD):** Verify that an Elephant Bar has true aggressive order-book participation ($|\text{Buy Vol} - \text{Sell Vol}| \ge 0.65 \times \text{Total Vol}$) rather than a thin liquidity vacuum.
- **Participant-Wise OI (FII & Pro vs Client):** NSE discloses category-wise positioning (FII, Prop Desks, DII, Retail Clients). Align intraday bias with net FII + Pro index-futures and index-options positioning.
- **GIFT Nifty** (early session) as a leading read before/at the open.

### Layer H — The Mid-Month (15th $\pm$ 1 Day) Institutional Reversal Cycle (EE v2 / v3)
In Elephant Edge v2 and v3, the **14th–16th of every calendar month** ($15 \pm 1$ day) is flagged as a **high-probability macro/swing & intraday reversal window**. This is not superstition; it is the confluence of **five structural institutional and derivatives mechanics**:

1. **Monthly Options Half-Life & Theta Inflection ($\approx 14$ DTE):**
   - Indian monthly F&O contracts expire on the last Thursday of the month. Around the 15th, the monthly contract hits its **halfway mark ($\approx 12\text{--}15$ Days to Expiry)**.
   - On the Black-Scholes theta curve ($\Theta \propto -1/\sqrt{T}$), time decay transitions from linear to **exponential acceleration** right at the 15-day mark. Institutional option writers rotate from wide, passive monthly strangles into aggressive directional defense or unwind losing first-half hedges, triggering sharp trend reversals.
2. **FII Index-Futures Mid-Month Inventory Reset (Long-Short Ratio Extremes):**
   - Foreign Institutional Investors (FIIs) typically run 10–12 trading-day directional campaigns starting from the beginning of the new monthly series (1st of the month).
   - By the **14th–16th**, if the market has trended one-way since the 1st, the **FII Index Futures Long-to-Short Ratio** reaches historical extremes ($\ge 75\text{--}80\%$ net long at tops, or $\le 15\text{--}20\%$ net long at bottoms). Institutions use the mid-month liquidity window to book profits on the first-half trend and reverse positioning for the second half of the series.
3. **DII Domestic SIP Liquidity Deployment Wave (10th–15th Cycle):**
   - In India, automated retail Systematic Investment Plan (SIP) bank mandates cluster in two monthly waves: the **1st–5th** and the **10th–15th** (post-salary credit).
   - Domestic Mutual Funds (DIIs) accumulate tens of thousands of crores of cash between the 10th and 14th and deploy it into index heavyweights around the **14th–16th** to prevent cash drag—routinely absorbing FII selling and forging major mid-month bottoms.
4. **Global Macro & US OPEX / VIX Expiration Alignment:**
   - The **12th–16th** of every month coincides with **US CPI / PPI inflation prints**, **Indian WPI/CPI releases**, **Indian Corporates' Advance Tax outflows** (15th of Mar/Jun/Sep/Dec), and the **Wednesday VIX expiration / Friday US Monthly OPEX** (3rd Friday falls between the 15th and 21st). Global macro quant funds rebalance their Emerging Market (EM) baskets in this exact 3-day window.
5. **W.D. Gann 15-Day / 15-Degree Solar Cycle:**
   - In Gann time-cycle geometry (widely embedded in Indian trading systems), 15 calendar days = $15^\circ$ of solar longitude = half of a 30-day cycle, acting as a primary geometric "Time Cluster" pivot where price-time squaring triggers reversals.

#### How to Instrument the 15th $\pm$ 1 Day Window to Strengthen EE+:

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                 MID-MONTH (15th ± 1 DAY) REVERSAL GATEKEEPER                 │
├──────────────────────────────────────────────────────────────────────────────┤
│ 1. Calendar Check: Is session date in [14, 16] (or nearest trading day)?     │
│ 2. First-Half Trend Stretch: |Close(t) - Open(Month)| / ATR_Daily(14) >= 2.5 │
│ 3. Smart-Money Exhaustion: FII Futures L/S >= 0.75 (or <= 0.25)              │
│                            OR Dominant Monthly OI Wall begins unwinding      │
└──────────────────────────────────────┬───────────────────────────────────────┘
                                       │
                  ┌────────────────────┴────────────────────┐
                  ▼                                         ▼
     [ Counter-Trend Signal at Zone ]          [ Late Trend-Continuation ]
     (e.g. Bearish at R1/R2 after rally,       (e.g. Buying R2 breakout on 15th
      or Bullish at S1/S2 after selloff)        after a 2-week non-stop rally)
                  │                                         │
   - Boost Confluence Score: +1              - Penalize Confluence Score: -1
   - Upgrade Target: Unlock 4R-5R Runner     - Flag as "Mid-Month Exhaustion Trap"
     (V-shaped institutional unwinding)        (Skip or require strict short-covering)
```

Do **not** blindly reverse on the 15th; use a **3-Factor Mid-Month Reversal Gate**:
- **Condition 1 — First-Half Trend Extension:** Measure the 10-trading-day directional displacement from the 1st of the month to day $t \in [14, 16]$:
  $$\text{Stretch}_{1\to 15} = \frac{C_{t} - O_{\text{month}}}{\text{ATR}_{\text{Daily}, 14}}$$
  Require $|\text{Stretch}_{1\to 15}| \ge 2.5$ (market is genuinely overextended in one direction into mid-month).
- **Condition 2 — Institutional Positioning Extreme:** FII Index Futures Long-Short Ratio is $\ge 0.75$ (crowded long → look for bearish reversal at $R_1/R_2$) or $\le 0.25$ (crowded short → look for bullish reversal at $S_1/S_2$), OR monthly OI Wall unwinding ($\Delta\text{OI} < 0$) begins at the dominant trend strike.
- **Condition 3 — Price-Action Trigger on the Level Map:**
  - When $t \in [14, 16]$ (adjusted to nearest trading day if the 15th is a weekend/holiday) and Conditions 1 & 2 hold:
  - **Boost Confluence Score (+1)** for **counter-trend Reversal setups at $R_2 / R_1$** (after an up-trend from the 1st) or **$S_1 / S_2$** (after a down-trend from the 1st), and **for Role-Reversal Breakouts** in the new reversed direction.
  - **Unlock Extended $4R\text{--}5R$ Runner Targets** on the counter-trend reversal leg, because mid-month institutional unwinding drives multi-session V-shaped reversals rather than small mean-reverting bounces.
  - **Penalize (-1 score) late trend-continuation breakouts** at $R_2$ (after a 2-week rally) or $S_2$ (after a 2-week selloff) during the 14th–16th window to avoid buying the exact top or selling the exact bottom of the monthly cycle.

---

## 5. Recommended fusion model (Elephant Edge + options & cycle stack)

```
                      [ Bar Completes at Zone S1/S2 or R1/R2 ]
                                      │
          Is it an Elephant / Trigger Bar? (Body >= 50-60%, Range > 1.5x ATR)
                                      │
                         ┌────────────┴────────────┐
                         ▼                         ▼
                        YES                        NO
                         │                         │
            Does Volume / CVD confirm?       Skip / Inactive
           (Vol >= 1.5x Avg, |CVD| >= 65%)
                         │
                         ▼
        Check Institutional Option Chain & Cycle Behavior:
                         │
       ┌─────────────────┴─────────────────┐
       ▼                                   ▼
 [ Breakout Scenario ]             [ Rejection / Reversal Scenario ]
 (Price crosses Zone Edge          (Price wicks into Zone +
  + Plus-Two Bar Confirmation)      Score >= 3 Confluence)
       │                                   │
 Is Delta-OI Unwinding (< 0)?      Is Delta-OI Accumulating (> 0)
 & Not Late Mid-Month Exhaustion?  OR Active Mid-Month (15th ± 1d) Reversal?
       │                                   │
       ├─► YES: Smart Money Squeeze        ├─► YES: Institutional Wall Defended
       │   - Enter Breakout                │   - Enter Zone Reversal
       │   - SL: Opposite Edge of Zone     │   - SL: Outer Edge of Zone + Buffer
       │   - Target: 3R Partial -> 4R-5R   │   - Target: 3R (or 4R-5R on 15th ± 1d)
       │                                   │
       └─► NO: Bull / Bear Trap Setup      └─► NO: Absorption Failure
           - Do NOT chase breakout             - Stand aside
```

A **confluence-scoring** system rather than "indicator on top of indicator":

1. **Base map:** Elephant zones ($S_1, S_2, R_1, R_2$ from §2 Module 1) anchored on the session open / first 1-min candle close (09:16 IST) and snapped to nearest strike walls where applicable.
2. **Overlay levels:** top-2 CE OI strikes (resistance), top-2 PE OI strikes (support), PDH/PDL, gamma flip level, max pain (on expiry), and Order Blocks.
3. **Score each level (0–4, clamped):**
   - +1 if an Elephant zone aligns with an OI wall, gamma wall, PDH/PDL, or Order Block (cluster).
   - +1 if that wall matches the required $\Delta\text{OI}$ dynamic (*building* $\Delta\text{OI} > 0$ for reversal trades; *unwinding / short-covering* $\Delta\text{OI} < 0$ for breakout trades).
   - +1 if Local Range PCR / IV skew supports the direction of the trade at that level.
   - +1 if the dealer-gamma regime (or the **15th $\pm$ 1 day Mid-Month Reversal Gate** when first-half stretch $\ge 2.5\times\text{ATR}_{\text{D}}$) agrees with the planned play.
   - -1 penalty on late trend-exhaustion breakouts during the 14th–16th mid-month reversal window after a sustained 2-week directional stretch.
4. **Trigger:** require a clean price-action confirmation at the level (Elephant marubozu / hammer / engulfing + volume spike $\ge 1.5\times$ + optional Plus-Two candle confirmation), not a bare touch. Take **first-touch** reactions at high-scoring levels; treat repeated touches as weakening.
5. **Risk & Asymmetric Targets ($3R / 4R / 5R$):** stop beyond the level *cluster* ± buffer ($1R$); book partial profit at **$3R$** (or next major confluence zone) and trail SL to breakeven; hold runner for **$4R\text{--}5R$** in short-gamma / short-covering regimes or confirmed **mid-month (15th $\pm$ 1 day) cycle reversals**; enforce the **6-candle time-stop** if price stagnates; sanity-check $R$-targets against the IV-implied expected move.
6. **Discipline:** entry time window (09:20–14:30 IST), Avoid/Chop Mid-Zone filter, max trades/day, mandatory square-off before close (15:10 IST).

**Concrete Smart-Money Execution Matrix:**

```
+---------------------------------------------------------------------------------------------------+
|                                  SMART MONEY VERIFICATION MATRIX                                  |
+-----------------------------------+-----------------------------------+---------------------------+
| Signal at Zone                    | Option Chain & Cycle Telemetry    | Actionable Execution      |
+-----------------------------------+-----------------------------------+---------------------------+
| Bullish Rejection at S1 (Demand)  | Put OI expanding (Delta-Put > 0)  | CONFIRMED LONG REVERSAL   |
|                                   | Local PCR > 1.0, GEX > 0          | Target: 3R (R1 / Mid)     |
+-----------------------------------+-----------------------------------+---------------------------+
| Mid-Month (15th ± 1d) Reversal    | Date in [14, 16], Stretch >= 2.5x | HIGH-CONVICTION REVERSAL  |
| at S1/S2 or R1/R2                 | FII L/S extreme or OI unwinding   | Target: 3R -> 4R-5R Runner|
+-----------------------------------+-----------------------------------+---------------------------+
| Bullish Bar at S1 (Demand)        | Put OI unwinding (Delta-Put < 0)  | DO NOT BUY (False Floor)  |
|                                   | Local PCR < 0.70                  | Skip / Stand Aside        |
+-----------------------------------+-----------------------------------+---------------------------+
| Breakout above R1 (Supply)        | Call OI unwinding (Delta-Call < 0)| CONFIRMED BREAKOUT LONG   |
| (+ Plus-Two Confirmation)         | GEX < 0 (Short-Gamma Squeeze)     | Target: 3R -> 4R-5R Runner|
+-----------------------------------+-----------------------------------+---------------------------+
| Breakout above R1 (Supply)        | Call OI expanding (Delta-Call > 0)| DO NOT BUY BREAKOUT       |
|                                   | OR late rally into 15th ± 1d      | (Bull Trap; Fade on Reject|
+-----------------------------------+-----------------------------------+---------------------------+
| Stagnation after Entry (6 Bars)   | Price within ±0.5R after 6 bars   | EXECUTE 6-CANDLE TIME STOP|
|                                   | GEX heavily positive (Pinning)    | Exit at Market / Breakeven|
+-----------------------------------+-----------------------------------+---------------------------+
```

---

## 6. End-to-End Platform Architecture & Reference Implementation

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ 1. DATA & MARKET INGESTION (tantra-market & tantra-data)                    │
│    - 1-min & 5-min OHLCV Bar stream + NseTradingCalendar (mid-month window) │
│    - NSE Live Option Chain & Lakehouse (Strikes, OI, Delta-OI, GEX, FII)    │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ 2. DOMAIN & INDICATOR ENGINE (tantra-core & tantra-market-indicators)       │
│    - LevelMap, SmartMoneyZone, GammaExposure, OrderBlock, StopProtection    │
│    - ElephantZones (Percentiles + 1.618x/2.618x 1-min Anchor + OI Snapping) │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ 3. STRATEGY & RISK ENGINE (tantra-strategies, tantra-risk, tantra-exec/oms) │
│    - ElephantEdgeStrategy: 0-4 Confluence Score + Mid-Month 15th ± 1d Gate  │
│    - Plus-Two Rule, 6-Candle Time-Stop, 3R Partial / 4R-5R Runner Brackets  │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │ WebSocket / REST / WASM FFI
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ 4. PRESENTATION & AGENT LAYER (tantra-ui, tantra-ui-charts, tantra-agent)   │
│    - Level-Map Canvas (Shaded R1/R2 & S1/S2 bands, SL/TSL/3R/5R lines)      │
│    - Regime & Mid-Month Reversal Badge + ReadOnly level_map/oi_walls tools  │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Reference Pine Script v5 Architecture (1-Min Anchor + R1/R2/S1/S2 Zones + 3R/5R Projections)

For parity verification against TradingView charts, the following Pine Script v5 reference captures the 1-minute opening anchor, 2 resistance / 2 support zones, and 3R / 5R target lines:

```pinescript
//@version=5
indicator("Elephant Edge Strategy Engine (Reference)", overlay=true, max_boxes_count=500, max_labels_count=500)

// --- INPUTS ---
grp_setup   = "Elephant Edge Anchor Settings"
mult_r1     = input.float(1.618, title="R1/S1 Multiplier", group=grp_setup)
mult_r2     = input.float(2.618, title="R2/S2 Multiplier", group=grp_setup)
zone_ratio  = input.float(0.382, title="Zone Thickness Ratio", group=grp_setup)

grp_targets = "Risk & Target Multipliers"
risk_rr3    = input.float(3.0, title="Target 1 (3R Multiple)", group=grp_targets)
risk_rr5    = input.float(5.0, title="Target 2 (5R Multiple)", group=grp_targets)

// --- SESSION & 1-MIN ANCHOR LATCH ---
var float day_open_close = na
var float day_anchor_rng = na
var bool  first_bar_done = false

is_new_day = ta.change(time("D")) != 0

if is_new_day
    first_bar_done := false
    day_open_close := na
    day_anchor_rng := na

if not first_bar_done
    day_open_close := close
    day_anchor_rng := math.max(high - low, ta.atr(14))
    first_bar_done := true

// --- ZONE CALCULATIONS ---
zone_buf  = day_anchor_rng * zone_ratio
r1_center = day_open_close + (day_anchor_rng * mult_r1)
r2_center = day_open_close + (day_anchor_rng * mult_r2)
s1_center = day_open_close - (day_anchor_rng * mult_r1)
s2_center = day_open_close - (day_anchor_rng * mult_r2)

// --- ASYMMETRIC R-MULTIPLE PROJECTIONS ---
risk_unit = math.abs((r1_center - zone_buf) - day_open_close)
bull_3r   = day_open_close + (risk_unit * risk_rr3)
bull_5r   = day_open_close + (risk_unit * risk_rr5)
bear_3r   = day_open_close - (risk_unit * risk_rr3)
bear_5r   = day_open_close - (risk_unit * risk_rr5)

plot(bull_3r, title="Bull 3R Target", color=color.purple, style=plot.style_circles)
plot(bull_5r, title="Bull 5R Target", color=color.blue,   style=plot.style_circles)
plot(bear_3r, title="Bear 3R Target", color=color.purple, style=plot.style_circles)
plot(bear_5r, title="Bear 5R Target", color=color.blue,   style=plot.style_circles)
```

---

## 7. Data sources & practical notes for systematic implementation

- **NSE public option chain** (strike-wise OI, ΔOI, volume, IV, LTP) — snapshot every 3–5 minutes intraday; official file at EOD. This is sufficient to compute OI walls, ΔOI matrix, Local PCR, max pain, and per-strike GEX (Black-76 gamma × OI × lot size × spot scaling).
- **India VIX**, **FII/DII/Pro index futures & options OI** (NSE public participant-wise OI files — already scoped in `tantra-data` gap 0013), **GIFT Nifty** for the early read.
- **Trading Calendar & Mid-Month Window:** `mid_month_window` (dates 14–16, shifted to the nearest trading session via `NseTradingCalendar` when the 15th falls on a weekend/holiday) combined with rolling 10-day daily ATR stretch.
- **Freshness rule:** OI levels move intraday — recompute the overlay every 5–15 minutes; never trade an overnight OI wall as if it were current.
- **Expiry rollover:** the nearest weekly expiry changes each week (Nifty: Thursday; Bank Nifty: Wednesday) — the chain and its walls shift; use the *correct* expiry and watch the roll.
- **Validation discipline:** percentile-lookback windows and exact defaults of commercial scripts are not public — the only way to trust any variant is to backtest it on your own data (golden-vector parity, in the Tantra sense) before going live. Cost, slippage, and STT matter a lot at intraday scale.

---

## 8. Honest assessment & caveats

- **Proprietary sources:** commercial scripts (AlgoBing, Elephant Club invite-only scripts) are closed-source. Everything above is reconstructed from public documentation, trading rules, and open community implementations.
- **What likely carries the real edge** (independently testable): (1) volatility-adaptive levels anchored on the 09:16 post-open equilibrium instead of fixed static pivots, (2) confluence + strike-snapping between price-derived levels and live option-chain OI walls, (3) $\Delta\text{OI}$ short-covering vs writing differentiation to separate $4R\text{--}5R$ squeezes from bull/bear traps, (4) mid-month (15th $\pm$ 1 day) institutional cycle awareness gated by actual 2-week trend stretch and FII positioning extremes (never traded as a blind calendar date), and (5) strict risk/time discipline (Plus-Two rule, 6-candle time-stop, mandatory SL).
- **GEX caveats:** estimate, not fact; dealer-side assumption differs across vendors; intraday OI is provisional. Use GEX for regime classification and wall ranking, not as a point-level price target.
- **Not a recommendation:** this is a research synthesis for building/testing a systematic intraday strategy, not investment advice.

---

## Appendix — Quick level-map checklist for a session

1. **Pre-open Calendar & Cycle Check:** Is today within the **15th $\pm$ 1 day mid-month window**? If yes, compute the month-to-date directional stretch ($\text{Stretch}_{1\to 15}$) and check FII Index Futures Long-Short Ratio for exhaustion extremes.
2. **09:15–09:16:** Let the first 1-min candle close → record session open, $C_{1\text{min}}$, and first-candle high-low range.
3. **Compute Elephant zones ($S_1, S_2, R_1, R_2$)** from the opening anchor.
4. **Pull the option chain (nearest weekly expiry):** top-2 CE OI above spot, top-2 PE OI below spot; snap adjacent Elephant zones to strike walls; note $\Delta\text{OI}$ sign, Local PCR, max pain, and gamma regime & flip.
5. **Mark PDH / PDL / previous close** and active Order Blocks on the chart.
6. **Cluster-map:** mark all levels that coincide; score 0–4 (applying the mid-month reversal boost/penalty if inside the 14th–16th window).
7. **Execute:** Trade only at score ≥ 3 levels with a clean reaction candle + volume (+ Plus-Two confirmation on breakouts), first-touch preference, inside the entry window (09:20–14:30).
8. **Manage Risk:** Anchor SL beyond the zone cluster ($1R$); book partial at $3R$, trail runner for $4R\text{--}5R$ on short-gamma/squeeze or confirmed mid-month reversal setups; exit after 6 stagnant candles; square off by 15:10 IST.
