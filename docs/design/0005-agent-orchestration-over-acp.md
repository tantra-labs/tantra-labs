# 0005 — Agent Orchestration over ACP: Orchestrator + Specialist Sub-Agents

**Status**: Proposed. Design agreed (option B), implementation starts next session. Dated 2026-11-21.
**Scope**: How one user request ("analyze NSE:NIFTY50 1W options expiring next week") is planned,
split across specialist agents, resolved into exact instruments, analysed with tools and
presented in the client's right pane, all over the ACP agent protocol. This spans `tantra-core`,
`tantra-data`, `tantra-market`, `tantra-agent`, `tantra-runtime`, `tantra-ui` and (later)
`tantra-ui-web`.
**Builds on**: agent plan 0019 (ACP, Phases 0–3 for the TUI done), agent plan 0020
(`present_view` / `DisplayBlock::View`), ui plan 0010 (dynamic right pane), runtime
`GET /api/v1/acp` (`756d267`).

---

## 1. Problem

The ACP pipeline works end to end: TUI → `AcpClient` → runtime `/api/v1/acp` → `AgentHost` →
`run_turn` → tools → `DisplayBlock`s → right pane. But a realistic analysis request still fails,
for three separate reasons.

1. **Nobody resolves the instruments.** "NIFTY50 1W options expiring next week" means:
   - the underlying `NIFTY 50` index;
   - the next weekly expiry (a Tuesday since NSE's Sep 2025 change, moved earlier on exchange
     holidays);
   - a strike window around spot;
   - and exact contract symbols.

   Today the TUI guesses `NSE:NIFTY50-INDEX` with a regex (`tantra-tui/src/analysis.rs`
   `detect_instruments`). The LLM has no deterministic tool for expiry dates or contract
   symbology, so it can only improvise names, which fabricates them.
2. **The data isn't there.** The runtime instrument master has 3,768 instruments, all
   `kind: equity`. There are no indices and no NFO futures or options, and no index bars.
   `options_chain` is answered by `tantra-market-store::chain::InstrumentChainReader`, which
   derives contracts from that equity-only master, so it returns no contracts for NIFTY.
   `GET /api/v2/bars/NIFTY50-INDEX.NSE` returns `not_found`. NSE's live option-chain endpoint
   is behind an Akamai JS challenge (`tantra-data` gap 0016 notes).
3. **One flat agent doesn't scale.** A single `run_turn` loop with every runtime tool (about
   40 read-only tools plus trade, alert and strategy tools) has to plan, resolve, fetch,
   analyse and present by itself. Small or local models lose the thread after a few rounds
   (`TurnConfig.max_rounds`). Adding capabilities means making one prompt bigger and bigger.

## 2. Decision

**Option B: an orchestrator plus specialist sub-agents, all inside the ACP host, with a
collapsible execution mode.**

| Option | Summary | Verdict |
|---|---|---|
| A | One host agent with more deterministic tools | Simple and cheapest in LLM rounds, but doesn't scale with capabilities. |
| **B** | Orchestrator that delegates to specialist agents exposed as tools | **Chosen**: flexible, composable, and specialists are reusable (MCP, CLI, web). |
| C | Several ACP agents coordinated by the client | Rejected: the client becomes the brain, and TUI, web and Python SDK would each reimplement orchestration. |

The key design point is that **specialists are data, not code paths**. A specialist is an
`AgentSpec` (prompt, tool allowlist, model, budgets, typed output). The same specs run in two
`CoordinationMode`s, chosen per model in `tantra.jsonc`:

- `delegate` (B): the orchestrator calls `delegate_<specialist>` tools. Each runs a nested,
  budgeted `run_turn` with only that specialist's tools and returns a typed result. Use this on
  capable hosted or fast GPU models.
- `inline` (A-shaped): the specialists' tool allowlists and short prompt fragments are merged
  into one orchestrator loop, with no nested LLM calls. Use this on the local CPU model
  (Qwen3-30B-A3B, about 1–5 tok/s, where each extra LLM round costs tens of seconds).

So B is the architecture, and the local-model latency problem becomes a configuration
choice, not a redesign.

## 3. Request flow (worked example)

`analyze NSE:NIFTY50 1W options expiring next week`

```
client (TUI/web)            runtime ACP host                                   tools / data
───────────────            ─────────────────────────────────────────────      ───────────────
session/prompt  ───────▶  orchestrator (plan step: classify + plan)
                           ├─ ACP plan update: [resolve, fetch, analyze, present]
                           ├─ delegate_resolver ─────▶ resolver agent
                           │     fo_contracts(NIFTY, horizon=1W, strikes=±10)  → calendar + contract master
                           │     market_search / instrument lookup              → instrument master
                           │  ◀── ResolvedInstruments{underlying, expiry, contracts[], spot_ref}
                           ├─ delegate_options_analyst(resolved) ─▶ options agent
                           │     options_chain(expiry) · oi_walls · level_map · studies
                           │  ◀── OptionsAnalysis{walls, max_pain, pcr, iv_skew, expected_move, refs}
                           └─ present_view(kind=options, symbols=resolved, include_tools=[…])
session/update  ◀───────  tool_call / tool_call_update (+ _meta.tantra.{agent,parent_call_id,blocks})
                           plan updates (status per step)
PromptResponse  ◀───────  stopReason=end_turn
right pane: Plan + Options view (resolved contracts, not regex guesses)
```

In `inline` mode the same steps happen inside one loop. The plan update and typed results are
identical, and only the nesting disappears.

## 4. Components

### 4.1 Deterministic resolution (no LLM)
- **`tantra-core::fo` (new, pure, wasm-clean)**:
  - `ExpiryCalendar` for NSE index and stock F&O: weekly and monthly rules, effective-date rule
    versions (the Sep 2025 Tuesday cutover), and holiday shift to the previous trading day.
  - Holidays are passed in as data (`&[NaiveDate]`). Core does no I/O and reads no clock: the
    caller passes `as_of`.
  - `ContractSymbol` builders for NSE trading symbols: monthly futures, monthly options, and
    weekly options with the day-coded date and month code 1–9, O, N, D.
  - Golden vectors in `tests/`.
- **Agent tool `fo_contracts`** (`tantra-agent-chat-tools`, ReadOnly, pure over a
  `ContractMasterPort`):
  - input `{underlying, horizon: "0D"|"1W"|"2W"|"1M"|date, strikes: {around: "spot"|price,
    count}, kinds}`;
  - output `ResolvedInstruments` with canonical `InstrumentId`s, expiry, lot size, tick, and a
    `source` field (`master` for listed contracts, `calendar` for computed but not
    master-confirmed).
  - It never fabricates. A computed-but-unlisted contract is labelled `calendar`, and the
    model is told it is unconfirmed.

### 4.2 Data (blocked today; the prerequisite for real answers)
- **`tantra-data`**: an F&O contract master (NFO futures and options, index and stock
  underlyings, lot sizes, expiries), an index instrument list (`NIFTY 50`, `NIFTY BANK`,
  `FINNIFTY`, …) and index daily bars into Lakehouse v3. The source is an open decision (§8);
  candidates are broker instrument dumps (Zerodha, Dhan) or NSE bhavcopy archives. This needs a
  new gap in the provider repo.
- **`tantra-market-store`**: the instrument master and `InstrumentChainReader` read the
  derivatives master, so `options_chain` returns listed contracts and bars resolve for indices.
- **`tantra-runtime`**: `FeedMarketReader` and `/api/v2/bars` serve them, and they back
  `ContractMasterPort`.

### 4.3 Agent specs and delegation
- **`tantra-agent-core`**: `AgentSpec { id, description, system_prompt, tools: Vec<String>
  /*allowlist*/, model: Option<String>, budget: AgentBudget { max_rounds, max_output_tokens,
  wall_clock }, output: OutputContract /*JSON schema id*/ }`.
  - Typed handoff DTOs (`ResolvedInstruments`, `OptionsAnalysis`, `MarketSnapshot`,
    `StrategyFinding`) with `schemars` and `deny_unknown_fields`.
  - Specialist output is untrusted LLM data, so it is parsed strictly, like `Decision`.
- **`tantra-agent-chat`**: `DelegateTool` (one per spec) runs a nested `run_turn`. It gets:
  - a restricted `ToolSet` (the allowlist ∩ the host tools);
  - a child `CancellationToken`;
  - the host permission flow (no escalation past the client's `/auto`);
  - its own budget.

  It returns the validated typed output plus refs. `CoordinationMode::{Delegate, Inline}`
  builds either the delegating orchestrator or the merged inline toolset and prompt from the
  same specs. Dependency rules R1–R4 hold, because it uses only `ToolSet` and ports already in
  `tantra-agent-chat`.
- **Turn blackboard (refs, not payloads)**: large tool outputs (chains, bars) are stored per
  turn under `$tantra/ref/...` ids, and specialists pass refs between each other. This also
  fixes agent gap 0009, where Chart `series_ref` can't be resolved by clients, if the
  blackboard is readable through an ACP ext method (`_tantra/ref/get`).

### 4.4 ACP mapping (extends agent plan 0019's table)

| Tantra | ACP |
|---|---|
| orchestrator plan | `session/update` `plan` (`Plan{entries: PlanEntry{content, priority, status}}`, ACP v1 schema) |
| specialist call | `tool_call` with `_meta.tantra.agent = "<spec id>"` and kind `think` |
| specialist's inner tool calls | `tool_call` with `_meta.tantra.parent_call_id` (clients render them nested) |
| typed handoff | `tool_call_update` content (summary) + `_meta.tantra.result` (typed JSON) + `_meta.tantra.blocks` |
| cancel | `session/cancel` cancels the whole tree via child tokens |
| mode / model per spec | `tantra.jsonc` (`coordination`, `agents.<id>.model`); clients see models via `_meta.tantra.models` |

### 4.5 Clients
- **TUI**:
  - a **Plan** pane (step list with status);
  - nested tool rows in the transcript;
  - focus and Price card follow `ResolvedInstruments` / `present_view.symbols`. This replaces
    regex `detect_instruments`, which stays only as a pre-turn hint.
- **Web** (agent plan 0019 Phase 4): the same ACP stream, Plan panel, nested steps.

### 4.6 Initial specialist set

| Spec | Tools (allowlist) | Output |
|---|---|---|
| `resolver` | `fo_contracts`, `market_search`, instrument lookup | `ResolvedInstruments` |
| `options_analyst` | `options_chain`, `oi_walls`, `level_map`, studies/library tools | `OptionsAnalysis` |
| `market_analyst` | `market_history`, `market_indicators`, `tantra_library_*`, `tantra_signal_study` | `MarketSnapshot` |
| `strategist` | `strategy_loop_eval/sweep`, `strategy_hedge_recommend` | `StrategyFinding` |
| orchestrator | `delegate_*`, `present_view` | the final answer + one `present_view` |

## 5. Configuration (`tantra.jsonc`)

```jsonc
{
  "model": "local/qwen3-30b-a3b",
  "agents": {
    "coordination": "inline",            // "inline" | "delegate"
    "resolver":        { "model": "local/qwen3-30b-a3b", "max_rounds": 3 },
    "options_analyst": { "max_rounds": 4 }
  }
}
```

Defaults: `inline` for local providers and `delegate` for hosted ones. There are no env vars,
per the provider-config rule in `tantra-agent/docs/design/provider-config.md`.

## 6. Invariants
- **Untrusted AI**: every specialist output is strictly deserialized. `present_view` keeps its
  closed `ViewKind`. Trade-capable tools are never in a specialist allowlist by default; they go
  through the host permission flow and `RiskEngine`.
- **No fabrication**:
  - instruments come from `fo_contracts` or the master, with `source` labelled;
  - prices come from tools, never from the model;
  - missing data surfaces as `PortError::unavailable`, citing a gap.
- **Determinism and replay**: calendar and symbology are pure with golden vectors. Specialist
  prompts and seeds go through the prompt replayer, and scenario transcripts are golden tests.
- **Bounds**: per-spec `max_rounds` and wall-clock limits, plus a nesting depth of 1 (a
  specialist can't delegate). Channels stay bounded.

## 7. Implementation phases (next session onward)

| Phase | Repo(s) | Deliverable | Verify |
|---|---|---|---|
| P0 | `tantra-core` | `fo` module: `ExpiryCalendar` (rule versions, holiday shift) and `ContractSymbol` | golden vectors, proptest on calendar invariants, wasm32 check |
| P1 | `tantra-agent-chat-tools`, `-mcp` | `fo_contracts` over `ContractMasterPort` (calendar-only fallback labelled) | unit + MCP tests |
| P2 | `tantra-data` → `tantra-market` → `tantra-runtime` | F&O contract master, index instruments and bars; chain reader on the derivatives master | pytest, store tests, `/api/v2/bars` for the index, `options_chain` non-empty |
| P3 | `tantra-agent-core`, `tantra-agent-chat` | `AgentSpec`, handoff DTOs, `DelegateTool`, `CoordinationMode`, turn blackboard | scripted-LLM tests for both modes, dependency rules |
| P4 | `tantra-agent-acp`, `tantra-runtime` | plan updates, nested `tool_call` meta, specialist registry from `tantra.jsonc` | golden ACP transcripts, `acp_ws` through the real router |
| P5 | `tantra-ui` | Plan pane, nested rows, focus from resolved instruments (regex demoted to a hint) | TUI tests, live run of the NIFTY scenario |
| P6 | all | scenario evals: the NIFTY weekly options, BANKNIFTY monthly and stock F&O prompts, in both modes on the local model | replay goldens; rounds and latency budgets met |

P0–P1 can ship before the data (P2): the resolver then returns `source: calendar` contracts and
says the chain is unavailable, instead of guessing.

## 8. Open decisions
1. **F&O data source**: broker instrument dumps (Zerodha or Dhan, which need credentials) or
   NSE bhavcopy archives (public, end of day). This decides P2's adapter and refresh cadence.
2. **Intent parsing**: LLM-only, or a deterministic query pre-planner ("1W", "next expiry",
   "ATM ±10") that the orchestrator may override.
3. **Per-specialist models**: allow a small fast model for `resolver` while a larger one
   analyses (needs several providers loaded locally, which costs RAM).
4. **Blackboard exposure**: whether clients may fetch `$tantra/ref/...` (fixes agent gap 0009)
   and how it is scoped per caller and session.
