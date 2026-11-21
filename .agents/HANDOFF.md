# HANDOFF — tantra-labs

**Status**: Bottoms-up Fincept/Quantcept gap-closing build order
(`docs/future-work-bottoms-up-build-order.md`) — Layers 0, 1, 2, 2b, 3, 4, 5, 6 GREEN;
Level 7 (`tantra-data/0002`, filings breadth) superseded: filings ingestion + the
`tantra-data` → Rust bridge for filings/corporate actions are both landed (T5 track,
2026-11-13). Agent-side **plan 0006 (MCP/chat tool catalog expansion) is complete**;
follow-on breadth tracked under agent plan 0007. **T14 (Standalone Paper Trading
Exchange, root plan 0007) COMPLETE 2026-11-16** — all four phases (P0 matching core,
P1 runtime wiring, P2 Python SDK `tantra.paper`, P3 CSR/WASM, P4 golden parity + docs)
shipped; the T14 gate (byte-identical fills across backtest / paper / Python / WASM on
one golden vector) passes. **T12 (Elephant Edge EE+ platform, root plan 0005) —
T12.1–T12.10 COMPLETE 2026-11-17** (Studio view `013a5d6` + synthetic-OCO `fc4a5a6` +
FIFO bracket P&L `697b428` landed). **T18 (remaining-gap independent fixes, root plan 0012)
T18.1–T18.6 COMPLETE 2026-11-17** (data 0015/0023/0024, runtime 0009/0010, strategies 0007
closed). **T17 (Unified Lakehouse v3, root plan 0011) Phases 1–2 COMPLETE 2026-11-17**
(tantra-data plan 0009 A–C: CAS + `catalog.duckdb` manifest + `tantra-catalog` CLI; gap 0025
closed). Implemented plan/gap docs from T13–T15 cleaned up per gap-tracking §4 (2026-11-16).
**Next unstarted work**: root plan 0009 (Qullamaggie, T16.0 – close the 9 unverified code
checks first), then the Lakehouse v3 Rust consumers (T17.3 `tantra-market` 0008 + T17.4
`tantra-runtime` 0011).
Date: 2026-11-17 · Workspace: `tantra-labs`
Playbook: `docs/future-work-bottoms-up-build-order.md` (execution order, by crate dependency
depth). The repo-migration (`honba-*` → `tantra-*`, Tier 0–6) that used to be this file's whole
subject is complete and long superseded — see "Prior work" below.

## Latest Batch — TUI Trading-R1 look + split-screen analysis page, COMPLETE 2026-11-21

- `tantra-ui` (`b65c228`…`a5bfeca`): `tantra-tui` adopts the Trading-R1 (Apache-2.0) look —
  theme tokens (`theme.rs`), welcome screen, rounded panes, grouped palette; after the first
  query the Agent view splits 40/60 into chat + `analysis_view` (ticker strip, price chart,
  spread/position, backtest, one card per tool `DisplayBlock`). The TUI now drives
  `tantra_agent_chat::run_turn` (tools execute; non-read-only tools need `/auto`).
- `tantra-agent` (`db826c1`): `SessionEvent::ToolFinished` carries `blocks: Vec<DisplayBlock>`.
- **Open**: `tantra-agent/docs/gaps/0009` — Chart cards can't resolve `$tantra/ref` series.

## Active Batch — LLM gateway config + one agent protocol (ACP), IN PROGRESS 2026-11-21

- **Provider config (done)**: every LLM is an OpenAI-compatible endpoint declared in an
  opencode-shaped `tantra.jsonc` (root file → `local/qwen3-30b-a3b` on llama-server :8080);
  schema `tantra-agent/docs/design/provider-config.md`. Candle GGUF provider, the per-model
  format layer and all `TANTRA_GGUF_*`/`TANTRA_LLM_*` env vars are removed — agent `06657e3`,
  runtime `4afe41a` (`ChatRuntime::from_config`), ui `44d5a9c` (`--model`/`--config`).
- **ACP (agent plan 0019)**:
  - Phase 1 is the crate (`be8b063`).
  - Phase 2 is runtime `GET /api/v1/acp` (`756d267`): it serves the full chat tool set plus
    `present_view`, requires auth, and is capped at 64 connections with 1 MiB frames.
  - Phase 3 for the TUI (ui `86d35ee`, agent `c91301a` `connect_ws`): the TUI is embedded by
    default; `tantra --server ws://127.0.0.1:8000/api/v1/acp --token-file PATH` connects to the
    runtime instead. `/model` lists or switches models, and `/auto` toggles approval live.
  - **Next**: `tantra ask` on `AcpClient`, Phase 4 web BFF, Phase 5 Python SDK, and Phase 6
    retire `/ws/chat`.
  - Follow-ups: caller-scoped ACP session store; drain buffered output on disconnect.
- **Runtime API surface (design `docs/design/0006-runtime-api-surface.md`, proposed)**:
  - Target: one enveloped `/api/v2` contract built from a route registry (route, scope and OpenAPI
    in one place), deny-by-default auth, one `/stream` WS plus `/acp`, and generated clients.
  - **R0 first**: runtime gap 0012. `/ws/live` (can place paper orders), the `/trade-journal/*`
    writes and `/market-data/*` are unauthenticated even with auth on.
- **Next session: agent orchestration (design `docs/design/0005-agent-orchestration-over-acp.md`)**:
  - Option B: an orchestrator plus specialist sub-agents (`AgentSpec`), with `coordination: inline|delegate`
    set per model in `tantra.jsonc`.
  - Start with P0, the `tantra-core::fo` NSE expiry calendar and contract symbols, then P1, the
    `fo_contracts` tool.
  - Blocker for real answers: the runtime instrument master is equity-only (3,768). It has no
    index or NFO contracts and no index bars, so `options_chain` for NIFTY is empty (P2; the data
    source is NSE bhavcopy).
  - Design §8 decisions: bhavcopy for EOD data; a deterministic pre-planner plus LLM override for intent;
    per-agent models are configurable but all route to local for now (so `inline`); clients get step
    summaries for the chain-of-thought UI, not raw refs.
- **Dynamic TUI right pane (ui plan 0010, `25bbfc0`, `cdf681e`)**:
  - `/help`, informational commands, and the strategy/backtest/positions views open panes, kept
    as tabs (Alt+←/→ to switch, Alt+x to close, `/pane`).
  - Agent queries open Analysis. The agent's `present_view` tool (agent plan 0020, `9859f6f`;
    `DisplayBlock::View`) opens the layout it composes.
- **Open**: `tantra-docs` still documents the removed env vars (ai/, user-guide/, api/rest.md);
  `tantra-cli` `test_run_ask_backtest_synthesis` needs the `tantra` wheel (`maturin develop`).
- Local model: CPU-only (`--device none`; Vulkan on the 680M hits `ErrorDeviceLost`); decode
  is RAM-bound — ~1 tok/s while the machine swaps, needs ~20 GB free for Qwen3-30B.

## Latest Batch — Architectural-analysis unification (T21/T22 cross-repo), COMPLETE 2026-11-20

Source: `docs/plans/Here is an architectural analysis of the.md` (§2 strategies duplication, §3 cross-repo
design changes). All landed with per-repo commits (details in each repo's HANDOFF / plan indices):
- **strategies**: single Decimal indicator kernel; EE+/ORB-15 in `tantra_library`; gap 0008 closed (OCO
  intrabar brackets); PR recipes emit `OverlayScene` + runnable `catalog_steps`; `WheelSdkBridge`; legacy
  `catalog/` retired; generic `scene_projection` + MCP `overlay_scene`; `LakehouseBarSource`.
- **data**: gap 0026 closed (`LakehouseBarReader`, pinned commit, closed bars, Decimal).
- **market**: ATR/CMO in `rust_decimal`, golden parity with `tantra_library` (gap 0009 rows; gap stays open).
- **runtime**: plan 0010 implemented — `LibraryMcpClient` + canonical `/api/v2/studies/*` (library,
  compute, signal-study, experimental-analysis aliases; legacy paths RFC 8594-deprecated); **security fix**:
  auth now fail-closed on JWT-only configs (`config.auth.is_enabled()`).
- **agent**: plan 0017 implemented — `IndicatorLibraryPort`, library-backed `IndicatorCatalog`,
  `tantra_library_*` MCP proxy over runtime REST (`TANTRA_RUNTIME_URL`).
- **ui / ui-web**: generic `OverlayScenePrimitive` replaces `ElephantZonesPrimitive`; `/api/v2/studies`
  client; Python↔Rust `OverlayScene` wire contract test + TUI projection of library scenes.
- **Follow-ups closed 2026-11-20**: wasm32 build (core `601ba3f`, getrandom `wasm_js`); `pr_trend_pullback`
  engine e2e test + WheelSdkBridge epoch-ns timestamp crash fix (strategies `e2c6da4`); `pane:` sub-pane strip
  (ui-web `73ecd1e`); Indicator Lab tab + `/api/v2/studies` client wire fix `ts`/`id` (ui-web `40b9210`, plan 0017).
- **T21.6 COMPLETE 2026-11-21** (agent plan 0018): `StrategyLoopPort` + 4 ReadOnly tools (`strategy_loop_eval`/`_sweep`,
  `strategy_hedge_recommend`, `chart_scene_annotate`) in chat-tools + MCP; `DisplayBlock::OverlayScene`; runtime chat
  wires them in-process (`RuntimeStrategyLoopPort`, late-bound `Weak<AppState>`); CLI/TUI render the block; docs page.
- **T21.5 COMPLETE 2026-11-21** (ui-web `4b5618b`, `8a1c7c9`): Strategy Loop & Hedge Workbench, layer pills, hint
  inspector, scene bus, ChatRail Render on Chart. Agent fixes on the way: `ToolDisplay` adjacent tagging (`af78bc2` —
  successful `tool_finished` events were being dropped), slimmed loop payloads under the 64 KiB tool cap (`7ffc079`).
- **Live check 2026-11-21**: generic scene renderer (EE zones), `pane:` sub-pane strip (+ time-axis fix ui-web `1e87572`)
  and strip removal verified in Chrome; Indicator Lab tab renders with honest error states. Library / strategy-loop
  data paths NOT exercised: the user's runtime on :8000 is a pre-library binary (404 on `/studies/library/*`).
- **Next**: relaunch `tantra serve` with the current `tantra-ui/target/prod/tantra` (set `TANTRA_LIBRARY_MCP_CMD` /
  `_ARGS` for `tantra-library-mcp`), then exercise Indicator Lab compute, workbench evaluate, and chat Render on Chart.
  tantra-strategies tests need `PYTHONPATH=../tantra-ffi/python:../tantra-examples:../tantra-data/src:.`.

## Latest Batch — Reading-List study book (`docs/reading-list/`) docs-only, COMPLETE 2026-11-17

Docs-only (no Rust/Python touched). New mdBook `docs/reading-list/` — "The Investor's
Study": merges the curated 126-title investing library (`/tmp/opencode/some-investment-books`,
124 file-collection titles + 2 user-requested Bulkowski *Evolution of a Trader* volumes)
into a **macro→micro** curriculum, 8 parts / **24 chapters** (Parts VII & VIII split from
single chapters into 2 each — Wizards interviews / Legends, crashes & cautionary tales;
mispriced markets / macro, fiction & leisure) + 6 appendices (annotated catalog,
reading plans, ratings index, duplicates archive, the source README's original curated
categorized reading list, and **Appendix F: the Wiley Little Books, Big Profits series**
catalogued from `little-books-asia.pdf` — ~31 titles with topics/summaries mapped to
chapters). **AI study-companion layer** per user request: every book annotation carries a
"Model refresh" note + a dedicated `ai-companion.md` prompt template for having larger
models expand older editions from their training data (e.g. Natenberg 1994→2013, Edwards &
Magee 9th ed. 2007→10th ed. 2012, Bulkowski 2nd ed. 2005→3rd ed. 2016). Chapters authored
by 14 subagents (7 waves, ≤2 concurrent) against a binding `CONTENT-SPEC.md` + exemplar
chapter; zero fabricated facts (6 unverifiable authors/editions deliberately left "—"
with AI-fill-in notes). Gate: `mdbook build docs/reading-list` clean, 307/307 internal
links resolve, `docs/training/README.md` index row added. Uncommitted (working tree).

## Latest Batch — Lakehouse v3 storage-taxonomy redesign (tantra-data plan 0009 / ADR 0004) COMPLETE

Date: 2026-11-17. **Design docs restored first**: the root rebase's submodule resolution had
dropped the upstream design commits (`d93536c`/`840ad99`/`339df08`) — cherry-picked back onto the
local branches (`5382cda` data, `f92be45` market, `8e84fc7` runtime) and root pointers advanced
(`f551c36`). Then implemented the phased redesign (subagents, A+B parallel then C):
- **Phase A** (`ee802e9`): `domain/lakehouse.py` types (`CatalogRef`/`CommitRecord`/`ManifestEntry`/
  `InstrumentAlias`) + `CatalogRepository` ref surface (`resolve_ref`/`commit`/`tag`,
  `as_of_ref="main"`).
- **Phase B** (`398eeb7`): CAS writer (`objects/sha256/<ab>/<sha>.parquet`, Zstd, 100K row-groups,
  `(instrument_uid, ts)` sort, Decimal128, atomic promote, dedup) + `catalog.duckdb` manifest
  (`commits`/`manifest_entries`/`refs`/`instrument_aliases`, staging→main fast-forward, tags,
  `reference/aliases` rename resolution) + dual-read `ParquetCatalog`/`LakehouseBridgeExporter`.
- **Phase C** (`d64c877`): `tantra-catalog` CLI (`status`/`log`/`tag`/`verify`/`compact`/`gc`/
  `materialize-views`/`migrate-v3`) with verified 100% bar + Decimal parity. Gap `0025` closed
  (`1534a62`); plan `0009` Implemented; HANDOFF updated (`8846bfc`). 359 tests green (5 env skips).
- **Cross-repo Phase 3 (Rust) remains**: `tantra-market` gap `0008` (ManifestResolver, compaction,
  `CatalogInstrumentMaster` Decimal migration) + `tantra-runtime` gap `0011` (`CatalogLoader`
  `data_ref`/`commit_sha` pinning) — tracked as T17.3/T17.4.

## Latest Batch — T12.9 Studio + T18 independent-fixes track COMPLETE 2026-11-17 (post-rebase)

Date: 2026-11-17. Root `git pull` rebase onto `b4c4edf` **resolved** (upstream took plan
`0011`/track `T17` for the Unified Lakehouse v3 catalog; local remaining-gap plan renumbered
`0011`→`0012`, track `T17`→`T18` per the `df37955` precedent; submodule gitlinks advanced to
today's heads). Then executed the remaining batch slices (one per wave, ≤2 subagents):
- **T12.9 complete** (`tantra-ui` `013a5d6`): EE+ Strategy Studio view layer — `studio_ee`
  helpers (level-map canvas, signals/stops/positioning), TUI positioning tab, CLI `elephant`
  report (plan 0006 Phases 2–4). Chart primitives (gap 0007) had landed earlier.
- **T18.1 data 0015** (`39cdef1`/`f79d368` + runtime `d876fac`): NSE trading-holiday provider
  + DuckDB store + bridge; `NseTradingCalendar` reads the data root (seed table stays as the
  documented offline fallback).
- **T18.2 runtime 0009** (`432c302` + agent `91629e2`): `/ws/chat` per-turn `model` override +
  multimodal image attachments (`MessagePart::Image`, base64 end-to-end); text-only providers
  return an honest capability notice.
- **T18.3 runtime 0010** (`0f5f4ac`/`b1f0541` + docs `344a685`): `QuoteTick` session summary
  fields (`last_price`/`day_high`/`day_low`/`prev_close`/`volume`, all optional); OpenAPI regen;
  `dayHigh`/`dayLow` mapping tracked in `tantra-ui-web` (repo not checked out).
- **T18.4 data 0023** (`5f93f78` + examples `af39796`): `DuckDbMutualFundsStore` (holdings
  lookthrough, NAV/AUM/TER, overlap); MF screener un-skipped — last examples skip removed
  (1027 passed / 0 skipped).
- **T18.5 data 0024** (`282f4a9`): BSE shareholding + NSE pledge/PIT **verified live**; domain
  + store + reader + Parquet bridge; SAST + analyst estimates kept open-and-documented (no
  licensable source verified).
- **T18.6 strategies 0007** (`4437afa` + examples `e1e2a2b`): runnable `EqualWeight` +
  `Alpha30Factor` catalog strategies; `test_07_alpha30_backtest` un-skipped.
- **Plan 0005 P2+P3 placement decision** (user-directed): `TradeManager` state machine →
  `tantra-ledger-oms` (`ff73eaa`, 15 tests + proptest); canonical TOML presets →
  `tantra-runtime-config` (`6649737`, 5 tests incl. golden); `tantra-core` stays P1-only
  (`08dffea`, `SCHEMA_VERSION` back to 10).
- **T12.5/12.7 follow-ons landed**: runtime synthetic-OCO on exec `BracketTracker`
  (`fc4a5a6`, `SyntheticOco`/`dispatch_bracket`, 8 tests); `portfolio.apply_bracket_exits`
  FIFO bracket P&L (`697b428`, 8 tests).
- **NSE option-chain verification** (`40cc389`): legacy `option-chain-indices` is a dead
  endpoint (404); current `option-chain-v3` is Akamai JS-sensor-gated (200-empty) — live stays
  **unverifiable in this sandbox**, honestly documented with `LIVE_VERIFICATION`, never
  fabricated.
- **Gate**: per-repo `cargo fmt --check` + `clippy -D warnings` + targeted `test --profile prod`
  green (ledger, runtime, runtime-config, core); data/examples ruff + format + `pytest -q` green;
  ui per-crate tests green. **Not pushed** (user directive: no `make push` this turn).

## Latest Batch — T12 track: Elephant Edge (EE+) platform (root plan 0005)

Date: 2026-11-17. Executed T12.1–T12.8 with subagents (one slice per wave, ≤2 concurrent,
dependency-ordered: core → market/data/strategies → exec/risk/ledger → agent/ui). All commits
local (not pushed):
- **T12.1 core plan 0003** (`94f3e96`): `src/{levels,options,order_blocks,signals}.rs` —
  `LevelKind/LevelSide/Level/LevelMap/LevelId`, `OptionChainSnapshot/StrikePositioning/
  GammaExposure+gamma_flip_strike`, `OrderBlock`, `SignalKind/StrategySignal→Signal/
  PositionIntent`; `SCHEMA_VERSION` v9; golden vectors + proptests. (wasm32 check is
  pre-existing-broken in this env via `getrandom`/uuid — verified on the base commit.)
- **T12.3 data 0016** (`9969337`): `DuckDbOptionChainStore` + `domain/option_chain.py`
  (`compute_gamma_exposure`) + `OptionsChainReader` port + NSE `option-chain-indices`
  provider (live-with-fixture fallback; live endpoint returns HTTP 404 in sandbox —
  documented, never fabricated) + `ingest_option_chain` CLI + `bridge_exporter`
  `option_chain/{expiry}/*.parquet` + `gex_series.parquet` (Decimal128); 23 tests.
- **T12.2 market 0005** (`44528ba`): `ElephantZones`/`OiLevels`/`GammaProfile`/`OrderBlock`
  streaming indicators in `tantra-market-indicators` (Decimal-only; `chrono-tz` added).
- **T12.4 strategies 0001** (`adcb8d9`): `strategies/elephant_edge.py` `ElephantEdgeStrategy`
  — level-map + fallback, 0–4 confluence scoring, signals (+Plus-Two, ΔOI trap), SL/TSL
  (3R/5R, 6-candle time-stop, ATR/swing trail), positioning; 35 unit + sim integration
  tests; suite 218 passed.
- **T12.6 risk 0005** (`e9f8148`): `trade_plan_gate` (`validate_trade_plan` + no-widening
  `validate_stop_update`), new `RiskRefusal`s, `SizingRiskRefusal` weight/ADV caps +
  multi-currency fmt fix; 21 new tests.
- **T12.5 exec 0003** (`292185b`): `BracketOrderSpec/BracketTicket/StopUpdate/
  BracketCapabilities` + `BracketTracker` (deterministic, `{bracket}#stop` ids),
  `BrokerExecutor::submit_bracket/modify_stop` (non-breaking) + mock; 18 new tests.
- **T12.7 ledger 0012** (`1e296d7`): `BracketOrder` aggregate + `BracketEvent`s +
  `OmsSnapshot.open_brackets`; 17 new tests (55 oms total). **Fixed a core-caused break**:
  `tantra-ledger/crates/tantra-ledger/src/sizing.rs` `RiskBudget{..}` literal needed the new
  `max_weight_pct`/`max_adv_pct` fields — ledger workspace clippy green.
- **T12.8 agent 0011** (`e5a5ed4` + runtime): `level_map`/`oi_walls` ReadOnly tools
  (catalogue 32→34) + `MarketReader` port methods; runtime `FeedMarketReader` honest stubs
  + seedable `RuntimeMarketReader` setters.
- **T12.9 partial** (`f597915`): ui gap 0007 chart primitives `LevelLine/ZoneBand/
  SignalMarker/StopLine` (wasm32 green); the Studio view layer (ui plan 0006) remains.
- **Cleanup per gap-tracking §4**: closed core 0002 + plan 0003, market 0005, data 0016,
  strategies plan 0001, exec 0003, risk 0005, ledger 0012, agent plan 0011, ui 0007 (docs
  removed, indexes updated with closing commits); task list T12 rows + per-repo summary +
  root plans index (0005 → Active) + HANDOFF updated. Core plan 0005 P1 (TradePlanner —
  `trade_plan.rs`/`chart_pattern.rs`/`RiskBudget` weight-ADV, `SCHEMA_VERSION` v10) landed
  as the exec/risk/ledger prerequisite (P2 TradeManager + P3 presets remain).
- **Follow-ons recorded**: ui plan 0006 Studio view; runtime synthetic-OCO wiring (exec);
  `portfolio.apply_fill` FIFO bracket P&L (ledger); NSE option-chain live verification (data
  0016).

## Latest Batch — docs cleanup of implemented plans/gaps + consolidated gap plan (root 0012 / T18)

Date: 2026-11-16. Docs-only (no Rust/Python touched). Two deliverables:
- **Gap scrape + new master plan**: every open gap doc in the workspace snapshotted into new
  root plan `docs/plans/0012-remaining-gap-closure-and-independent-fixes.md` (15 gaps; 9 tracked
  by existing master plans — T12 EE+, T16 Qullamaggie, plan 0008 TSG, plan 0010 Screener, T3.3
  feeds — and **6 unclaimed gaps moved to new T18 track**: data 0015 NSE holiday provider,
  runtime 0009 chat-WS model/multimodal, runtime 0010 QuoteTick session fields, data 0023 MF
  store surface, data 0024 shareholding/SAST, strategies 0007 runnable catalog strategies).
  T18 rows added to `docs/task-list-tracks-and-phases.md`; plans index + per-repo summary
  refreshed to the scrape. (Renumbered from `0011`/T17 on the 2026-11-17 pull rebase — upstream
  `b4c4edf` took `0011`/T17 for the Lakehouse v3 catalog, per the `df37955` precedent.)
- **Implemented-doc cleanup** (gap-tracking §4): removed 14 implemented plan/gap docs and
  unlinked their index rows — root `0006` (T13 `_kernel` dismantle) + `0007` (T14 paper
  exchange); `tantra-adapters` 0003/0004; `tantra-docs` 0004/0005; `tantra-examples` 0003/0004;
  `tantra-ffi` 0002/0003; `tantra-runtime` plan 0005 + gap 0008 (closed); `tantra-ui` 0008;
  `tantra-exec` 0003 (moved Active → Implemented). Task-list T13/T14/T15 "Source" links re-pointed
  to the per-repo README indexes; runtime plan-0005 row records the D4/D5 follow-on closures.
- **Gate**: link sweep — no remaining references to any deleted doc in `docs/`, per-repo
  `docs/plans|gaps/` indexes, or task list. All changes committed per repo (local, not pushed);
  root submodule pointers advanced.

## Latest Batch — T14.16 docs: headless user guide + installation rewrite

Date: 2026-11-16. Docs-only (`tantra-docs` + root task list; no Rust/Python
touched):
- **Headless user guide** (`tantra-docs/docs/user-guide/`, docs plan 0005 →
  Implemented): `index.md` (four headless surfaces — CLI, REST API, Python
  SDK, AI/MCP — with a "web UI is not your daily driver yet" banner),
  `cli.md` (full `tantra` command reference grounded in `tantra-ui`
  `tantra-cli/src/args.rs`), `rest-api.md` (`tantra serve` + curl workflows;
  wire reference stays `api/rest.md`), `python.md` (`Tantra.backtest` session
  orchestrator, indicators, wheel CLI, data sources), `ai.md` (LLM backends
  `TANTRA_GGUF_PATH` / `TANTRA_LLM_BASE_URL`/`TANTRA_LLM_MODEL`/
  `TANTRA_LLM_API_KEY`, `ask`/`chat`/`tools`/`mcp config`/`jobs`).
- **Installation + first-backtest + loading-data rewritten** against reality:
  superproject `git clone --recurse-submodules` + `make prepare` (single
  venv + maturin wheel) + `make prod` (canonical prod profile; binary at
  `tantra-ui/target/prod/tantra`); first backtest now uses the real
  `Tantra.backtest(...).run()` on synthetic `trending_bars` (the old page
  taught the non-existent `Strategy.backtest` / `result.print_report()`);
  loading-data dropped the non-existent `tantra data load` for
  synthetic / lakehouse (`tantra-data`) / Parquet (`SYMBOL.EXCHANGE.parquet`
  for `tantra serve`).
- Paper trading was **already documented** by commit `1157674` (T14.15,
  `docs/paper-trading/`, plan 0004 Implemented) — the user guide cross-links
  it instead of duplicating.
- Gate: `mkdocs build --strict` green (only the known informational
  `docs/plans/*`-outside-nav warnings). Root task list: T14.15 ✅ + T14.16 ✅;
  docs plans index: 0004 + 0005 Implemented. tantra-docs HANDOFF updated.
- **Not committed yet**: all of the above is uncommitted working tree in the
  `tantra-docs` submodule (root submodule pointer unchanged).

## Latest Batch — T15.5 follow-on: provisioning seam wired into screeners + env rename

Date: 2026-11-16. Two cross-repo changes (`tantra-examples` + `tantra-ffi`), no Rust touched:
- **Plan 0004 per-example runtime prompt shipped** (`tantra-examples`): `ScreenerCLIExample`
  now offers the interactive download / dummy / Monte-Carlo choice via `provision_catalog()`
  → `provision.seam.ensure_data_root` when the catalog is absent, then re-runs against the
  provisioned root. Piped runs (stdin not a TTY) print guidance and stop — no prompt in
  pipelines, stdout stream stays pure. `--data-dir` now accepts a data root or the catalog
  dir; the missing-catalog error message was fixed (it named a nonexistent `--catalog-dir`).
- **Data-root env var renamed `VYAAPAAR_DATA_DIR` → `TANTRA_DATA_DIR`** across the wheel
  (`tantra-ffi` `tantra.store` `DATA_DIR_ENV`), `tantra_examples/screening/paths.py`,
  `tantra_examples/provision/layout.py` and all tests in both repos (resolution semantics
  unchanged; the old name survives only in git history).
- **Gate**: `tantra-examples/tests/unit` **1018 passed / 1 skipped** (skip = tantra-data gap
  0023 mutual_funds store surface); `tantra-ffi` `test_store.py` 18 passed; ruff clean on the
  changed examples code; mypy clean on `provision/` + the changed files.

## Latest Batch — unit suite fully green (967 passed / 1 skipped) + provisioning scope

Date: 2026-11-16.
- **All 51 unit-suite skips fixed in `tantra-examples`** (`tests/unit` **967 passed / 1 skipped**,
  from 916 passed / 51 skipped; ruff clean; integration green). Roots fixed: optional deps
  (`numpy`/`scipy` into the wheel venv + a Decimal-quantize fix in `tantra_data.loaders.amfi.nav_bars`
  + a float-cast at the numpy boundary in `04_portfolio_optimization`); `test_screening_import`
  reworked via a `sys.meta_path` blocker; the **tantra-strategies catalog** shipped its missing
  `registry.json` + `tools/validate_chain.py` (28 pipeline chain/manifest tests un-skipped); the
  1D NSE catalog tests got a canonical synthetic lakehouse (`tests/unit/synthetic_lakehouse.py`,
  price catalog + `fundamentals.duckdb`) behind the `TANTRA_DATA_DIR` seam. A wheel-API
  regression in `06_multi_broker_dispatch` (paper mocks now `replace=True`) and two integration
  suites re-gated on their true prerequisites. **1 remaining skip is honest**: the MF screener
  needs `tantra_data.store.mutual_funds`, which the provider hasn't shipped — **filed
  `tantra-data` gap 0023**.
- **Data-provisioning microservice scoped (plan, no implementation)**: per user direction
  ("ask for download, with a choice of dummy or Monte-Carlo data"), `tantra-examples` plan 0004
  scopes an HTTP microservice offering `download` (delegates to tantra-data ingest CLIs) / `dummy`
  (fold of `synthetic_lakehouse.py` — one canonical synthetic source) / `monte-carlo`
  (truly random unless seeded) for all three datasets (NSE 1D catalog, fundamentals,
  mutual_funds). No new CLI.

## Latest Batch — T13 COMPLETE + single workspace venv

Date: 2026-11-16.
- **T13 track complete (root plan 0006 Implemented)** — dismantled the `_kernel` shared harness:
  - **Thrust A (T13.1–T13.5, `tantra-ffi` plan 0002 Implemented)**: wheel
    `tantra.portfolio`/`risk`/`options`/`metrics`/`calendar` shipped (`9b354d5`/`3d5a1ac`/
    `f210c8a`/`119061a`; 52 new wheel tests; 480 suite passed; ruff-clean). The six `_kernel`
    domain modules deleted and all consumers retargeted to the wheel in `tantra-examples`
    `25cb5df` (Thrust A).
  - **Thrust B (T13.6, `tantra-examples` plan 0003 Implemented)**: harness renamed
    `_kernel/` → `tantra_examples/harness/` (`1acabfb`), facade rewritten (harness names only,
    no wheel re-exports), all ~60 `_kernel.*` import sites retargeted, `_kernel/` deleted
    repo-wide, docs swept (`3c2e5ae` + `80134a8`).
  - **Gate (T13.7)**: wheel 480 passed; examples `tests/unit` 909 passed / 51 skipped, **zero new
    failures** (see the ⚠️ note below for the 6 pre-existing env failures); ruff check + format
    clean; 6 example import-smokes pass. Follow-on candidates recorded in the plan
    (runner→wheel session, service→tantra_data, testing→wheel replay helper, `fills_equity_curve`
    Decimal end-to-end). Root plan 0006 → Implemented; per-repo plan indexes + task list + HANDOFFs
    updated. All commits local (not pushed).
  - ⚠️ **Pre-existing env failure (unchanged by T13; verified on pre-T13 `1d89fd9`)**: the
    workspace root `.venv` now installs `tantra-adapters`, whose real broker entry points
    (`zerodha`/`angelone`/…) bypass `examples/production/06_multi_broker_dispatch.py`'s
    `register_adapter(…, PaperBrokerAdapter)` paper fallback, so its `resolve_adapter(broker,
    config=…)` calls the real factory and fails (`BaseRestAdapter.__init__` rejects the `config`
    kwarg) — 6 `test_06_multi_broker_dispatch` failures. Pre-existing cross-repo contract gap
    (wheel `AdapterRegistry.create(name, **config)` ↔ `tantra-adapters` real constructors);
    run-order dependent (can pass if an earlier test registers a compatible factory). Tracked
    for a fix in a future batch (candidate: the example should wrap the real adapter or the
    facade should map `config=` per factory).
- **Single venv (2026-11-16)**: one Python env at the workspace root `.venv`; every
  Python repo (`tantra-ffi/adapters/data/strategies/examples/docs`) now has a
  git-ignored `.venv` symlink → `../.venv` (root Makefile `make prepare` provisions:
  tooling → symlinks → `maturin develop` wheel → editable installs → docs deps;
  `make venv-link` recreates just the symlinks). `make prepare` **must create the
  symlinks before** `maturin develop` — maturin auto-detects `.venv` from the CWD and
  otherwise installs into a stale per-repo venv. Verified: ffi wheel suite (496) and
  adapters suite green through the symlinks; `mkdocs build --strict` green.

## Latest Batch — T14 COMPLETE (Standalone Paper Trading Exchange)

Date: 2026-11-16. Root plan `docs/plans/0007` → Implemented; all 16 tasks green, all
commits local (not pushed):
- **P0 matching core** (`tantra-exec` plan 0003, `2fa2fe3`): new crate `tantra-exec-paper`
  — ported `sim/{l2_book,latency,slippage,mis}` + `lifecycle.rs` + `paper.rs`
  (`PaperExchange` aggregate: submit/cancel/amend, IOC, GTD, stop trigger, price-time
  priority, per-`AccountId` cash/positions via pluggable `FillCostFn`) + `executor.rs`
  (`PaperExchangeExecutor` on `BrokerExecutor` + sync `SimExecutionPort` lifted into
  `tantra-exec-core` — closes runtime gap 0008 option 2). E1–E9: 18+ tests, wasm32 check
  green.
- **P1 runtime wiring** (`tantra-runtime` plan 0005, `027ebac`/`a9d1d96`/`18be257`/
  `a1cbeda`/`f70e0e2`): REST `/orders` on the exchange (`NextOpenSim` deleted), strategy
  sim adapters delegate to a per-adapter `PaperExchange`, `/ws/live` push, backtest drives
  the exchange (golden parity), `paper serve` daemon. Deviations recorded: L2 adverse-fill
  restore + live feed/calendar gate = follow-ons.
- **P2 Python SDK** (`tantra-ffi` plan 0003, `c7e90a5`): wheel `tantra.paper` —
  `PaperExchange` pyclass (seeded, GIL-released engine steps) + `PaperSession` facade +
  `wire.py::fills_wire`; `l2_sim` `backend="native"` resolves to the compiled engine
  (no more `NotImplementedError`; coincident-tape parity only — the golden vector is the
  cross-language oracle); codegen `.pyi` regenerated. Examples: `tantra-examples`
  `8189fb1` (`examples/basic/06_paper_trading.py`, 6 tests), `tantra-strategies`
  `13cbae0`. ffi pytest 490 passed.
- **P3 CSR/WASM** (`tantra-ui` plan 0008, `fad62c3`/`768b375`/`4b2a207`/`b54d2b6`/
  `870b27b`): `tantra-ui-api-wasm::paper` `PaperSession` (wasm32 check green), CSR
  `PaperPanel` (`AppRoute::Paper`, embedded + server modes), TUI `/positions` live-stream
  paper panel, `tantra paper --mode embedded|server` CLI. ui test suites green (OOM
  workaround: run per-crate `-j 1` under prod LTO).
- **P4 parity + docs** (T14.14/T14.15): one canonical `paper_golden.json` byte-identical
  in `tantra-exec` `5714ee2` (+`tests/golden_parity_tests.rs`), `tantra-ui` `5bbd743`,
  `tantra-ffi` `898f61c` (+cross-embedding byte-identity test); E9 backtest↔paper 4/4
  green; `tantra-docs` `1157674` — `docs/paper-trading/{index,python,cli,rest-ws,web}.md`,
  `mkdocs build --strict` green. (Concurrent docs track also landed `c459aba` — headless
  user guide, docs plan 0005, T14.16.)
- **Follow-ons closed 2026-11-16**: runtime L2 adverse-fill restored on the exchange venue
  (`tantra-runtime` `edeb0a8`; `tests/adverse_fill_l2_tests.rs`, parity suites unchanged);
  `paper serve` NSE trading-calendar gate + live-feed seam (`tantra-runtime` `3447cc7`;
  MIS square-off gated on `NseTradingCalendar::is_trading_day`; `--feed live` channel seam,
  real broker WS stays `tantra-market` gap 0003); ffi GTD facade (`submit_order_gtd` +
  `gtd_until` on `PaperSession`) + l2_sim native golden-tape parity & permanent scope note
  (`tantra-ffi` `930a6bf`/`7dc2419`; pytest 493). Docs: `10cae72` (runtime), `d99e12c` (ffi).
- **Immediate next step**: T14 track and its follow-ons are fully closed. No new track is
  approved; the next unstarted master plan is root 0005 (EE+ platform) whose per-repo
  plans/gaps are already filed.

## Prior work — T12.10 (docs slice of the EE+ platform track)

Date: 2026-11-15. `tantra-docs` only: the EE+ strategy guide gained
`docs/strategies/elephant-edge/reference.md` — the missing plan-0003 page 6 (parameter
reference, declarative `Parameter` + `config.toml` configuration example, illustrative
worked session walk-through on the shipped gap-0006 SDK models). Nav + index + cross-links
wired; `mkdocs build --strict` green. Cross-repo EE+ deps stay open and are tracked in
their own repos — T12.4 strategy engine (`tantra-strategies` plan 0001), T12.9 Studio
(`tantra-ui` plan 0006), T12.8 `level_map`/`oi_walls` chat tools (`tantra-agent` plan
0011); the guide's "planned" banners drop when those land. Task list: T12.10 Done.

## Prior work — T13 planning (docs only, superseded by the T13 COMPLETE entry above)

Date: 2026-11-15. Per user direction ("create a new set of plan(s) to achieve this… may call it
Track 13"): root master plan `docs/plans/0006-dismantle-kernel-harness.md` + per-repo plans
(`tantra-ffi/docs/plans/0002-*.md` Thrust A, `tantra-examples/docs/plans/0003-*.md` Thrust B)
were filed (Proposed), T13.1–T13.7 added to the task list, indexes/HANDOFFs updated. **All
executed 2026-11-16 — see the Latest Batch entry above.**

## Previous Batch — gap-closure program COMPLETE (all 8 tantra-examples gaps closed)

Date: 2026-11-15. Per user direction ("use subagents to close the remaining one by one",
full program): the 5 remaining `tantra-examples` gaps (0002/0003/0004/0007/0008) were closed
**one per wave** (sequential — their downstream closures touch overlapping example files),
each subagent shipping the upstream wheel/`tantra_data` surface first, then deleting the
mirror and retargeting consumers:
- **0007** — wheel `tantra.adapters` (`tantra-ffi` `437eddf`); `_kernel/adapters/` deleted +
  18 consumers retargeted (`tantra-examples` `6b4e86c`); snippets `9433aa0`.
- **0003** — `tantra_data.loaders.{amfi,nse,yfinance}` + `domain.quantity` (`tantra-data`
  `54d5b34`); wheel `tantra.screener` (`tantra-ffi` `07b4956`); `_kernel/{data,screener}` +
  `amfi.py` + `bhavcopy.py` deleted + 32 files retargeted (`eef65a5`). `TANTRA_DATA_DIR`
  seam kept. Env provisioned: `tantra_data`+`polars` into `tantra-ffi/.venv`.
- **0004** — wheel `tantra.display` + `tantra.markets.india`(costs/settlement) +
  `tantra.markets.india.universes` + `tantra.cli.data` (`tantra-ffi` `e5f40b3` + `723c9c0`);
  display/universe/cli mirrors + `_kernel/markets/india/` + `_kernel/cli/` deleted
  (`e816185`). `output.py`/`screener_cli.py`/`cli.py` retained as harness; `tantra.client`
  (REST) deferred.
- **0002** — wheel `tantra.ai` (ask/decision/knowledge/llm.provider) (`tantra-ffi`
  `4d570b4`); `_kernel/ai/`+`fake_llm.py`+`decision_guard.py` deleted; **4 design-only
  scripts un-skipped and runnable** (`5de0436`); `nl_support.py` retained as screener
  harness.
- **0008** — wheel `tantra.backtest.session` (`Tantra.backtest`: next-open fills, NSE
  delivery costs, T+1 settlement) (`tantra-ffi` `2d9214e`, incl. wiring `resolve_fill_costs`
  + `make_simulator` settlement to `tantra.markets.india` and defaulting `algo_analytics`
  `runner=None` to the session); `_kernel/session.py` deleted (`bd469dd`). Final doc sweep
  `bfbcad1` (cascade map all-closed; production/backtesting README snippets retargeted).
- **Unit suite: 916 passed / 51 skipped, exit 0** — the 73 pre-existing float-rooted failures
  and 3 errors were fixed in a follow-up batch (2026-11-15): examples + tests Decimal-canonicalized
  against the wheel (float literals → `decimal.Decimal`; jsonable decimal-string assertions;
  `default=str` for determinism tests), `fills_equity_curve` + `safe_eval_predicate` made exact
  Decimal, and the stale `backtest_parity_golden.json` regenerated. Wheel suite: 464 passed.
  The `_kernel/` mirror is fully dismantled;
  only the shared harness remains (`calendar/config/evaluator/greeks/loader/log/manifest/
  option/portfolio/ports/risk/runner/service/testing` + `portfolio`).
- **Workspace `tantra-examples` open gaps: 0** (all 8 closed). All work committed locally,
  not pushed.

## Previous Batch — ex 0006 CLOSED (cascade root)

Date: 2026-11-15. The Decimal-canonical `tantra` wheel kernel-domain layer shipped (money/
position/trade/instrument/entities, bar, tick, order, order_state, execution, indicators 74,
base/context, declarative, portfolio_strategy, wire, store, coverage, backtest sims);
`tantra-examples` retargeted every `_kernel.*` consumer to the wheel and deleted the
ex-0006-owned mirror (−12,170 lines); gap doc 0006 removed, indexes + cascade map → Closed.
Suite: 838→841 passed, 72 pre-existing float-rooted failures, 3 environmental errors, 50→41
skipped — no new failures. The remaining `_kernel/` files are the other gaps' mirrors
(0002 `ai/`, 0003 `data/`+`screener/`, 0004 `markets/india/`+`cli/`, 0007 `adapters/` (now
closed), 0008 `session.py`) + the shared harness — all built on the wheel. Commit: `d4b9f82`.

## Latest Batch — T9.3 + T9.7 closed; T9.8 (kernel-domain root) started

Date: 2026-11-15. Executed "all 8 (T9.3–T9.10), starting at the root", per the user's scope
decision. **Local commits only (not pushed).** 2 repos touched:
- **Wheel surfaces shipped** (`tantra-ffi` `d79d31b` + `6ac14dd`): `tantra.algo_analytics`
  (walk-forward/folds/monte-carlo/plateau/deflated-sharpe, with an injected backtest runner —
  no session orchestrator yet, raises loudly), `tantra.quant` (returns/mean/std-dev/covariance/
  solver/OLS), `tantra.optimizer` (Pareto helpers), `tantra.sizing` freeze-slicing
  (`freeze_limit_qty`/`slice_order`/`verify_slices`), and the **ex 0006 root slice**: Decimal-
  canonical `tantra.{money,position,trade,instrument,entities}` (the `_kernel` mirrors are
  float-based and conflict with the zero-floats policy — the wheel surface is a Decimal
  re-implementation, not a verbatim promotion). 83 wheel tests green (2 pre-existing
  stale-wheel `test_risk.py` failures untouched).
- **Gaps 0001 + 0005 closed** (`tantra-examples` `4bc6c4f`, −2014 lines): the mirrors
  (`optimizer/algo_analytics/` + `quant.py`; the `options/__init__.py` freeze block) deleted,
  every consumer retargeted to the wheel (04/05/10/12, optimizer 01/02/03, options 06/07,
  stocksharp 02, flat 12/14/15, tests + `docs/reference/*`), gap docs 0001/0005 removed and
  README → Closed. Suite green except one pre-existing environmental failure
  (`test_mutual_fund_screener_execution` needs the 1D NSE catalog); ruff clean (pre-existing
  I001/SIM102 fixed).
- **ex 0006 verified as the root of an 8-gap dependency cascade**: verified map written to
  `tantra-examples/docs/design/gap-cascade-kernel-mirror.md`; blocker analysis added to gap
  docs 0002/0003/0004/0006/0007/0008 (all `open — blocked` except 0006 `in progress`).
  Remaining ex 0006 slices: Decimal `bar`, `indicators` (87 files), `execution`/`order_state`,
  `portfolio_strategy`, `session`, `wire`, `store`, `backtest` sims — multi-week.
- Task list updated: T9.3 ✅ + T9.7 ✅, T9.8 🔶, T9.4/5/6/9/10 blocked; `tantra-examples` open
  gaps 8 → 6; phase-5 open 8 → 6; total 36 → 34.

## Latest Batch — T9.1 (ffi CLI) + T12.4 SDK prerequisite (strategies gap 0006)

Date: 2026-11-14. 2 subagents in one wave (self-contained prompts, independent repos):
- **T9.1 / ffi gap 0001 closed** (`tantra-ffi` `a9204a1`) — `python/tantra/cli.py` `backtest`
  subcommand is now real: loads a bars-JSON fixture, builds `_tantra.Bar`s, delegates to
  `tantra.strategy.run(...)`, prints the `BacktestResult.summary()`; optional
  `--strategy MODULE:CLASS` (importlib + `Strategy` subclass guard) with a built-in SMA 3/8
  cross default (`_SmaCrossStrategy`, Decimal-safe, limit orders at close); `--algo-id`.
  `serve`/`stub` placeholder subcommands **removed** per gap-tracking §4 (no serving surface
  exists in the repo). 7 new CLI tests (`python/tests/test_cli.py`); gap doc deleted, index →
  Closed, HANDOFF updated. `tantra-ffi` open gaps 1 → 0.
- **T12.4 first SDK prerequisite / strategies gap 0006 closed** (`tantra-strategies` `53bd2e0`,
  plan 0001 §7 shipped) — new `sdk/stop_protection.py` (`StopProtection`/`TrailMode`/`StopUpdate`)
  + `sdk/levels.py` (`Level`/`LevelMap`/`StrategySignal`/`PositionIntent`/`OptionLeg`/
  `OptionsSnapshot`, frozen Decimal dataclasses mirroring `tantra-core` plan 0003 1:1);
  `Strategy.stop_loss`/`trail_stop`/`_emit_stop_update` + `on_stop_update` hook;
  `StrategyContext.level_map()`/`options_snapshot()` extended onto the protocol with seedable
  `SimulatedContext` stores and honest `LevelsUnavailable`/`OptionsUnavailable` degradation on
  unseeded/live contexts citing market 0005 / data 0016. 17 new tests (181 total) incl.
  `tests/golden/stop_trail_golden.json` golden vectors + the EE+-style seeded-sim SL/TSL
  integration test; ruff + format clean, mypy at baseline (2 minimal fakes in
  `tests/sdk/test_live_context.py`/`test_tick_dispatch.py` extended with honest raisers to stay
  protocol-conformant). Gap doc deleted, index → Closed (none open), plan 0001 status/§1/§7
  updated. `tantra-strategies` open gaps 1 → 0.
- **T9.3–T9.10 (`tantra-examples` gaps 0001–0008) stay open — blocked**: each is "delete the
  mirror once the upstream ships its wheel surface" (`tantra-runtime` enhancer, `tantra-agent`,
  `tantra-data`, `tantra-exec` freeze slicer, `tantra-adapters`, `tantra-ffi` session
  orchestrator) and none of those surfaces shipped this batch.
- Task list + per-repo summary updated: phase-5 open 9 → 8, total 37 → 36, `tantra-ffi` open
  gaps 1 → 0, `tantra-strategies` open gaps 1 → 0.

## Latest Batch — T8 track complete (strategies; gaps 0001–0005 closed)

Date: 2026-11-14. Executed the full T8 track from `docs/task-list-tracks-and-phases.md`
in `tantra-strategies` (2 waves × 1 subagent, self-contained prompts; commits `5c2049d`
code + `a7dd055` docs):
- **T8.1 (gap 0001)** — canonical `Tick` model (`sdk/tick.py`, exact Decimal) +
  `Strategy.run_ticks` / `SimulatedContext.run_ticks` (`feed_tick` + per-tick outbox
  drain, same deterministic clock as bars); `Strategy.run`/`run_ticks` duck-type the
  drive loop so any context with `run`/`run_ticks` drives itself.
- **T8.2 (gap 0002, High)** — `LiveContext` (`sdk/live.py`) over `MarketDataFeed` /
  `ExecutionGateway` runtime-checkable protocol seams (canonical Rust traits remain
  `tantra-market` / `tantra-exec`); sim/live parity tests (same strategy + bars →
  identical order streams).
- **T8.3 (gap 0003)** — `tools/run_step.py` executes every `catalog/**/step.toml`
  through `SimulatedContext` on a deterministic 45-bar series; proves runnable +
  run-to-run deterministic (CLI + smoke tests).
- **T8.4 (gap 0004)** — `manifest/basket_run.py` reference run loop: `resolve_manifest`
  → `instantiate()` → `SimulatedContext` under the optimized capital slice; enforces
  the basket `RiskBudget` via `RiskBudgetViolation` (notional position fraction +
  average-cost realized PnL).
- **T8.5 (gap 0005)** — `optimize_allocations` cap math in `manifest/basket.py`
  (`max_position_fraction` total + per-member, `max_loss` bounds total deployment);
  a full `tantra-ledger-allocation` objective optimizer remains cross-repo.
- Gates: 164 tests green (31 new), `ruff check` + `ruff format --check` clean (incl.
  3 pre-existing md-format failures fixed), `validate_catalog.py` 10/10,
  `validate_manifests.py` 3/3, `tools/run_step.py` 10/10 ok. Gap docs 0001–0005
  removed, indexes + task list updated; `tantra-strategies` open gaps 6 → 1 (0006
  EE+ SDK surface); phase-5 open 14 → 9; total 42 → 37. Root submodule pointer bumped.

## Latest Batch — T0.7, T6.9, T7.7, T4.9, T4.10 closed (2026-11-14)

Closed the remaining decision/upstream items of Tracks 1–7:
- **T0.7 (core gap 0001 + plan 0002) closed** (`9af413e`) — Phase-A audit decision: no 1:1
  delegation sites (streaming f64 indicators / f64 statistical gates vs batch-Decimal quant);
  verdict in `tantra-core/docs/design/code-quant.md`.
- **T6.9 architectural rules resolved** (`445a94f`) — `test_architectural_dependency_rules` was
  red on two intentional `tantra-agent-mcp` compute edges; R1 + R4 widened
  (`→ tantra-market-pricing`, `→ tantra-ledger-allocation`), rules updated, test green.
- **T7.7 fully closed (gap 0007 retired)** — items 10 + 14–16 landed with real data:
  - **Item 10 (L2 depth)**: exact-Decimal `DepthSnapshot`, `LiveQuoteStore::put_depth`,
    parquet depth ticks (`write_depth_file`), `FeedMarketReader::with_depth_reader` +
    real `market_depth` + `liquidity_imbalance_pct` (market `4d9e62c`, runtime `922bc5d`).
  - **Items 14–16 (fundamentals/MF/IPO)**: `tantra-data` 0020 (`d94230c`, yfinance verified
    live), 0021 (`17c5b94`, AMFI verified live — 14,214 schemes/NAV/returns), 0022
    (`17c5b94`, NSE IPO verified live — 1,492 issues) → `FundamentalsProjectionReader`
    (`a8b0c05`) + `FundsIposProjectionReader` (`9f8b04c`) → `FeedFundamentalReader`/
    `FeedFundReader`/`FeedIpoReader` wired (`37db5b8`/`f752334`). **Fund *holdings* have no
    verified free source** — `fund_holdings` keeps its gap citation (documented, never
    fabricated). Gaps 0020–0022 + 0007 retired; T7 track complete.
- **T4.10 (adapters plan 0004) Implemented** (`0b9636e`) — pooled transport (2.40×
  throughput), bounded 429 backoff/retry + `Retry-After`, 401 token-refresh path, redacted
  call-summary logging, 5,000-case fuzz (0 crashes); 39 new tests (173 total).
- **T4.9 (adapters plan 0003) Implemented** (`faf0563`) — Python ↔ Rust canonical contract
  alignment (`common/contract.py` encoders, serde-tagged `Tick` envelope, UPPERCASE
  `OrderSide`, decimal-string wire), deterministic fixture replay; boundary per plan 0001
  (Python = dev/research path; production routing stays Rust). 16 new tests (189 total).

## Latest Batch — runtime gap 0007 items 1–5, 11, 12 closed (3 waves, 2 subagents max)

Date: 2026-11-14. Executed the recommended close order for
`tantra-runtime/docs/gaps/0007-chat-market-reader-approximations-and-missing-sources.md`:
- **Wave 1 (parallel)**: `tantra-data` bridge exports for institutional flows / delivery /
  economic calendar (gaps 0017/0019/0018 closed — exporter + CLI + 14 tests, `pytest` 144
  green); `tantra-market-store` 3 projection readers + `LiveQuoteStore::put_trade` +
  `ports::TradeReader`/`TradeSnapshot` + `wire::Instrument.display_name` catalog column (59
  store tests green on prod).
- **Wave 2**: `tantra-runtime` wiring — `FeedMarketReader` `with_institutional_flows` /
  `with_delivery` / `with_economic_calendar` / `with_trade_reader`, real `institutional_flows` /
  `delivery_stats` / `macro_series`, `indicators` over `tantra-market-indicators` (12 named
  indicator families → exact Decimal), `quote` last-print/day-volume plumbing (honest midpoint
  fallback when unwired), display-name search, `FeedSnapshotSource` `with_risk_engine` +
  `with_regime` (20-SMA classifier, `TANTRA_REGIME_INSTRUMENT`); 8 new runtime tests, fmt /
  clippy / check / targeted tests green.
- **Docs cleanup (§4)**: tantra-data gaps 0017/0018/0019 docs removed + index → Closed;
  runtime gap 0007 rewritten (items 1–5, 11, 12 closed); gap/plan indexes + task list T7 rows +
  tantra-data/runtime HANDOFFs updated. Items **10 (L2 depth ← `tantra-market` 0006)** and
  **14–16 (fundamentals/MF/IPO ← `tantra-data` 0020–0022, vendor procurement)** remain
  upstream-blocked (verified, unchanged by design); live trade feed remains plumbing-only (real
  broker feed tracked by `tantra-market` gap 0003 / root `docs/gaps/0001`).

## Latest Batch — T7 remaining (runtime; gap 0006 closed, 0007 items 8/9/17/18/19 closed)

Date: 2026-11-14. Completed the runtime-side T7 items that were not upstream-blocked:
- **Gap 0006 closed (portfolio-backed tools)** — design decision recorded in
  `tantra-runtime/docs/design/code-shared-ledger.md`: `AppState.shared_ledger` =
  `tantra-runtime_api::SharedLedger` (the four in-memory `tantra-ledger` repositories +
  matched-lot history, mutex-backed, `&self` `record_*` methods + the four repository trait
  impls). The REST order flow opens the default `rest-api` account and records every approved
  order; the embedded sim records every fill (buy opens a FIFO lot, sell matches, cash
  adjusts). `StubPortfolioReader` removed; `LedgerPortfolioReader` + `FeedTaxReportReader`
  (0007 item 19) wired from it.
- **0007 items 17/18 closed** — `FeedTradeIntentSink` enqueues validated intents into the
  `FileJobRegistry` as `PendingApproval` (`x-papertrading` flag); `FeedStrategyStore` in-memory
  CRUD. **Item 9 closed** — `with_corporate_actions` wired into the chat market reader
  (composable builders). Item 8 (options_chain) already closed via T3.1; 0007 doc now records
  it. At this point items 1–5, 10–12, 14–16 were still upstream-blocked — subsequently closed
  in the next batch (items 1–5, 11, 12; see the Latest Batch section above).
- **Verification**: fmt/clippy/check green; new tests `shared_ledger_tests` (6) +
  `chat_remaining_t7_tests` (3); existing orders/chat/session/trading-state binaries green.
- **Cleanup**: gap 0006 doc removed (index → Closed); gap 0007 rewritten; task list T7 rows +
  runtime HANDOFF updated. Commit: `tantra-runtime` (this batch); root submodule pointer.

## Latest Batch — T7 track (runtime REST API & chat tools)

Date: 2026-11-14. Executed the T7 track from `docs/task-list-tracks-and-phases.md`
(T7.1–T7.6, T7.8 + T7.7 items 6/7/13):
- **T7.2 + T7.3 (plan 0004 Phases 4–5, Implemented)** — block/bulk deals real data:
  `tantra-data` `export_block_deals` + `--dataset block-deals` CLI (`ce7c392`);
  `tantra-market-store::BlockDealsProjectionReader` (`02fc20e`/`84d1e99`);
  `FeedMarketReader::with_block_deals` + real `block_deals` read, `AppState.block_deals` +
  `with_block_deals`, `GET /market-data/block-deals` route + openapi entry + tests (`b561e12`).
  Upstream data 0005 (T5.3) was the blocker; it closed 2026-11-13, unblocking this.
- **T7.4 (gap 0004 closed)** — `Profile.watchlists` values → `Watchlist { name,
  instrument_ids }` (legacy bare-array deserializer preserves stored profiles), new opaque
  `portfolios`/`risk_profiles`/`workspaces` fields + `MAX_*` limits + tests (`53e917a`,
  stack-overflow fix `ad84499`, fmt `7a45a14`).
- **T7.5 (gap 0005 closed)** — OpenAPI 3.1 spec completed: all 68 v1 route paths (86
  method/path pairs) + 21 component schemas + `v2_json()` static artifact
  (`schema/openapi.v2.json`) + `tests/openapi_conformance.rs` (`021f965`/`967fd15`/`085461b`).
- **T7.6 session-persistence half (gap 0006 half-closed)** — `AppState.database` +
  `with_database`; `prepare_server` now async; `SqlxSessionStore` when `TANTRA_DATABASE_URL`
  set, in-memory fallback otherwise; `tests/session_persistence_tests.rs` (`933c53a`).
  **Portfolio-backed tools remain** (need a ledger-repo handle in AppState).
- **T7.7 items 7 + 13** — news bridge (`export_news` `4bb1c75`, `NewsProjectionReader`
  `c88db45`, `FeedContentReader::with_news` + real `news_search`) and oi_buildup
  (`FeedMarketReader::with_oi_store` + `ParquetOpenInterestStore` + `BuildupAnalyzer`) —
  `776d145`. Gap 0007 items 6/7/13 closed; remaining items upstream-blocked.
- **T7.8 (gap 0008)** — documented decision recorded: option 1 "keep `BrokerAdapter` as the
  runtime's deterministic sim port"; closes when option 2 (lift into exec-core) lands.
- **Cleanup per gap-tracking §4**: gaps 0004/0005 closed (docs removed, indexes updated),
  plan 0004 → Implemented (doc removed); gap 0006/0007/0008 statuses updated; task list T7
  rows updated. **Commits**: data `ce7c392`/`4bb1c75`, market `02fc20e`/`84d1e99`/`c88db45`,
  runtime `b561e12`/`53e917a`/`ad84499`/`7a45a14`/`021f965`/`776d145`/`933c53a`/`f2c44e4`.
  All pushed.

## Latest Batch — T6 track complete (agent & MCP ecosystem; plans 0007, 0009, 0010)

Date: 2026-11-14. Executed the T6 track from `docs/task-list-tracks-and-phases.md`
(T6.1–T6.7, T6.9, T6.11 done; **T6.12 plan 0010 smart-money suite now complete**):
- **T6.1/2** — `UserMemory` with per-profile budgeters + recall renderers (`tantra-agent` base
  crate `memory::user`) + prompt cache-hit/miss regression tests (agent-core `prompt_cache_tests`,
  agent-prompt `renderer_cache_tests`).
- **T6.3** — runtime↔agent monitor scheduler bridge: `MonitorSchedulerBridge` in
  `tantra-runtime-persistence` over the agent `JobScheduler`/`JobStore` ports (6 tests).
- **T6.4 + T6.11 Ph 15/17** — MCP stdio client (`McpClient` + `mcp_stdio_server` bin, process
  tests) + `_jq` response filter (`serde_json_path`, filters the envelope, first match → `data`).
- **T6.5** — `ResearchNote` (Typst/Markdown) + research-loop integration.
- **T6.9** — Track-4 engines: HMM regimes (Baum-Welch + Viterbi), CUSUM changepoint,
  Clayton/Gumbel copulas, permutation tests, MPO (`tantra-ledger-allocation`); 5 MCP gateway
  tools; stale HRP-unimplemented test fixed.
- **T6.6** — verified already shipped (Track-1 engines). **T6.7** — Track-2 chat tools
  (`market_depth`/`institutional_flows`/`economic_calendar`, catalogue 19→22, new `CalendarReader`
  port) + runtime wiring with honest `PortError::unavailable` stubs citing newly-filed upstream gaps.
- **T6.12 (plan 0010, Implemented)** — remaining smart-money suite: `delivery_analysis` +
  `oi_buildup` ReadOnly chat tools (catalogue 22→24; `DeliveryBar`/`OiBuildupSnapshot` DTOs +
  `MarketReader::delivery_stats`/`oi_buildup`, exact Decimal), runtime wiring (`FeedMarketReader`
  stubs + seedable `RuntimeMarketReader` `set_delivery_stats`/`set_oi_buildup` + tests), and the
  composite-signal strategy `CompositeSignalStrategy` + pure `compute_composite_signal` in
  `tantra-strategies` (14 tests). Real-data wiring remains tracked by `tantra-data` 0017/0019,
  `tantra-market` 0006, runtime gap 0007 item 13.
- **T6.8 (plan 0007 Track 3 — tool surface)** — fundamentals / mutual funds / IPO chat tools:
  3 new ports (`FundamentalReader`/`FundReader`/`IpoReader`) + 6 ReadOnly tools
  (`fundamental_ratios`/`financial_statements`/`fund_search`/`fund_holdings`/`ipo_calendar`/
  `ipo_subscription`), catalogue 24→30; runtime `FeedFundamentalReader`/`FeedFundReader`/
  `FeedIpoReader` stubs citing new `tantra-data` gaps 0020–0022 (data ingestion not started
  anywhere). `register_read_only_tools` gained 3 reader params.
- **T6.10 (plan 0007 Track 5 — tool surface)** — safe trade intent / strategy CRUD / tax:
  `TradeIntentSink` port + `propose_trade` LocalWrite tool (closed `Decision::PlaceOrder`,
  NoFX approval queue pattern), `StrategyStore` port + `strategy_manage` LocalWrite tool,
  `TaxReportReader` port + pure STCG/LTCG tax math (`compute_capital_gains`: STCG 20% flat,
  LTCG 12.5% over ₹1.25L exemption) + `tax_report`/`ledger_statement` ReadOnly tools with
  markdown statements; catalogue 30→32 + 2 trade tools; runtime `FeedTradeIntentSink`/
  `FeedStrategyStore`/`FeedTaxReportReader` stubs citing gap 0007 items 17–19. **T6 track
  complete.**
- **New upstream gaps filed**: `tantra-data` 0019 (delivery-% Rust bridge), 0020
  (fundamentals ingestion), 0021 (mutual-fund data ingestion), 0022 (IPO data ingestion).
- **Cleanup per gap-tracking §4**: agent gaps 0003–0008 + ledger gap 0013 closed (docs removed,
  indexes updated); agent plans 0009 + 0010 → Implemented; plan 0007 all 6 tracks' tool surfaces
  shipped (data/wiring tracked by gaps + runtime gap 0007 items 13–19). `tantra-agent` open gaps 0.
  Task list updated (phase-4 open 20 → 10 → 9 → 8 → 7, total 56 → 47 → 46 → 45 → 44).
- **Commits**: agent `7f9d480` (T6.1/2/4/5 + _jq), `95ec800` (T6.9), `150bcae` (T6.7); runtime
  `634de2c` (T6.3), `c0e3a27` (T6.7 wiring); ledger `126087f` (MPO); market `bb997f3`;
  data `d248240`; root `ec03932`/`2930b06`. T6.12 commits agent `d8a36b1`, runtime `a305f03`,
  data `5a83b20`, strategies `6b1a90f`, root `f1e1707`; T6.8 commits agent `97b6a5f`, runtime
  `aee1a54`, data `a3223a0`, root `16889d7`; T6.10 commit SHAs follow this batch's per-repo
  commits. All pushed.

## Latest Batch — T17.3–T17.4 complete: Lakehouse v3 Rust support & `tantra serve` snapshot pinning

Date: 2026-11-18. Completed Phase 3 of root plan `0011` (`docs/plans/0011-unified-data-catalog-lakehouse-v3.md`):
- **`tantra-data` (`ManifestStore`)**: Added atomic `{root}/trees/{tree_hash}.json` export and rollback cleanup (`tantra_data/adapters/manifest_store.py`, `tests/test_cas_manifest.py` 13/13 passed, ruff clean).
- **`tantra-market` (`tantra-market` gap `0008` closed)**: Added [`ManifestResolver`](../tantra-market/crates/tantra-market-store/src/manifest.rs) (`refs/{heads,tags}/*`, `commits/*.json`, `trees/*.json`, `objects/sha256`, `views/` fallback on `main`, `reference/aliases` continuity, `arrow_utf8_array` `Utf8`/`LargeUtf8` decoding), post-close CAS compaction (`Lakehouse::compact_v3`), `CatalogInstrumentMaster` `Decimal128(18, 4)` schema migration (`open_legacy_float64` opt-in), `ParquetOpenInterestStore` (`derivatives/open_interest`), and wired all 9 projection readers (`block_deals`, `corporate_actions`, `delivery`, `economic_calendar`, `filings`, `fundamentals`, `funds_ipos`, `institutional_flows`, `news`). Verified `lakehouse_v3` (3) + `instruments` (5) + `chain_oi_tests` (10) + doctests (2) + `fmt --check` + `clippy -D warnings` + `make prod`.
- **`tantra-runtime` (`tantra-runtime` gap `0011` closed + `tantra serve` v3)**:
  - `tantra-runtime-backtest`: `CatalogLoader` (`with_ref`, `with_legacy_fallback`, `resolved_commit`, `load_bars_with_stats`, O(|aliases|) `reference/aliases` rename continuity `ZOMATO → ETERNAL`, Parquet `(instrument_uid, ts)` RowGroup min/max statistics pruning, single-pass `load_v3_bars_grouped`, `CatalogVerificationReport` commit metadata); `NseTradingCalendar::from_data_root_at`.
  - `tantra-runtime-api` + `tantra-runtime-api-rest`: `BacktestRequest.data_ref` (422 on empty), `RunManifest.{data_commit_sha, data_as_of_ist}`, `load_lakehouse_v3`, `AppState::has_lakehouse_v3` / `from_lakehouse_v3` (and `has_catalog` ignores placeholder `.gitkeep`), `prepare_server` v3→catalog→parquet detection, `BacktestExecutor` pinned execution + cache-key partitioning + `data_ref_not_found` mapping.
  - Verified live read-only smoke test against `tantra-data/data/` (`commit=1f161caa...`, 3,768 instruments, RowGroup pruning 2/18 on `RELIANCE`), `tantra-runtime-api` (28), `tantra-runtime-backtest` (19), `tantra-runtime-api-rest` (88 tests across 9 suites incl. `lakehouse_v3_serve` and `openapi_conformance`), `fmt --check` + `clippy -D warnings` + `make prod`.
- **Docs**: Closed `tantra-market` gap `0008` and `tantra-runtime` gap `0011` per `.agents/rules/gap-tracking.md` §4, updated `docs/plans/0011-...md`, `docs/plans/README.md`, and `docs/task-list-tracks-and-phases.md`. Phase 4 (legacy fallback removal) remains.

## Latest Batch — Elephant Edge (EE+) strategy platform docs (research + plans/gaps)

Date: 2026-11-13. Research + documentation batch (no code changes):
- **Research**: `docs/research/elephant-edge-strategy.md` — Elephant Edge intraday strategy
  (AlgoBing percentile-zone S/R + Velez "elephant bar" institutional footprint), the two-support/
  two-resistance session-open-anchored levels, and the strengthening stack (OI walls, ΔOI
  build-up, PCR, max pain, **gamma exposure / dealer positioning**, IV, futures flows) +
  Order-Blocks fusion model.
- **Master plan**: root `docs/plans/0005-elephant-edge-strategy-platform.md` (proposed) — 6
  phases across 10 repos; strategy contract (level map → buy/sell signals → SL/TSL → positioning,
  zero floats, regime gate, research-live parity).
- **Per-repo filings** (all proposed/open): `tantra-strategies` plan 0001 (the EE+ strategy spec —
  signals, SL/TSL, positioning, Order Blocks, declarative parameters) + gap 0006 (SDK lacks
  stop-protection primitives & options/level-map context); `tantra-core` plan 0003 + gap 0002
  (level-map/options/gamma/stop/signal kernel types); `tantra-market` gap 0005 (Elephant-zone /
  OI-wall / gamma / Order-Block indicators — chain+OI plumbing gaps 0001/0002 already closed);
  `tantra-data` gap 0016 (intraday option-chain snapshot lakehouse + point-in-time GEX);
  `tantra-exec` gap 0003 (bracket-order SL/TSL execution — note: **exec gap 0001 Angel One is
  CLOSED** per `2258bbb`, summary row updated); `tantra-risk` gap 0005 (stop-protection
  validation, mandatory SL + no-widening TSL); `tantra-ledger` gap 0012 (bracket OMS lifecycle);
  `tantra-agent` plan 0011 (`level_map`/`oi_walls` chat tools, cites plan 0010);
  `tantra-ui` plan 0006 (EE+ Strategy Studio) + gap 0007 (chart level/zone/annotation
  primitives); `tantra-docs` plan 0003 (user guide).
- **Indexes updated in the same change**: per-repo `docs/{plans,gaps}/README.md` tables (root
  plans 0001 + 0005 active; core 0002+0003; strategies 0001; agent 0011; ui 0006; docs 0003;
  gaps core 0002, market 0005, data 0016, exec 0003, risk 0005, ledger 0012, ui 0007,
  strategies 0006) and the derived `docs/task-list-tracks-and-phases.md` (**new T12 track**,
  T12.1–T12.10 + per-repo summary refresh).
- **No build needed** (docs-only batch; no Rust/Python code touched).

## Latest Batch — T5 track complete (data lakehouse & ingestion)

Date: 2026-11-13. Executed the full T5 track from `docs/task-list-tracks-and-phases.md` in
`tantra-data` (plans 0003–0006 → Implemented) + the two cross-repo Rust bridges:
- **T5.1/T5.2 (calendar)** — vendor decided & verified live: **Forex Factory weekly JSON**
  (`nfs.faireconomy.media/ff_calendar_thisweek.json`, free, machine-readable). New
  `providers/forex_factory.py` (parse/rows/fetch/ingest) + `cli/ingest_calendar.py`;
  `providers/calendar.py::default_calendar_rows()` = live-with-stub-fallback. Gaps 0010/0012 closed.
- **T5.3 (block/bulk deals)** — NSE archives `block.csv`/`bulk.csv` verified live;
  `BlockDeal` domain + `providers/block_deals.py` + `DuckDbBlockDealsStore` +
  `PythonBlockDealsReader`. Gap 0005 closed → unblocks runtime T7.2.
- **T5.4 (news)** — Moneycontrol RSS verified live; `NewsArticle` domain +
  `providers/news.py` (RFC 2822→UTC, ISO-8859-1) + `DuckDbNewsStore` + `PythonNewsReader`.
  Gap 0006 closed → unblocks chat `news_search`.
- **T5.5/T5.6 (Rust bridges, one bridge two datasets)** — `tantra-data` projection writers
  (`service/bridge_exporter.py` → `{root}/catalog/filings|corporate_actions/*.parquet`,
  exact Decimal128); `tantra-market-store` readers `FilingsProjectionReader` +
  `CorporateActionsProjectionReader` (`b040f68`); `tantra-runtime` wiring
  `FeedContentReader::with_filings` + `FeedMarketReader::with_corporate_actions` +
  `ChatRuntime::from_env(data_root)` (`db60aaa`, 4 new tests, clippy all-targets clean).
  Gaps 0007/0008 closed → chat `filings_search`/`corporate_actions` unblocked.
- **T5.7 (catalog backfill)** — `cli/ingest_catalog.py`; **fixed `providers/bhavcopy.py` to
  tolerate the live NSE header** (DATE1/AVG_PRICE/TTL_TRD_QNTY/DELIV_QTY/DELIV_PER,
  whitespace-padded, `-` delivery) — the old parser raised KeyError on live files. Gap 0004 closed.
- **T5.8 (corporate-actions ingestion)** — NSE `corporates-corporateActions` JSON provider →
  `Split`/`Bonus`/`Dividend`/`Rights` through `DuckDbCorporateActionsStore` (face-value-aware
  rights pricing). Gap 0009 closed.
- **T5.9 (FII/DII)** — NSE `fiidiiTradeReact` verified live; `InstitutionalFlow` domain +
  `providers/institutional_flow.py` (curl_cffi) + store + reader. Gap 0013 closed.
- **T5.10 (delivery %)** — `DeliveryRecord` domain + `providers/delivery.py` (live + legacy
  bhavcopy headers, exact Decimal pct). Gap 0014 closed.
- **Verified**: 86 → 134 tests green (48 new), ruff + mypy clean; `tantra-market-store`
  3 new tests; `tantra-runtime` check/fmt/clippy `--all-targets` clean + 4 new tests (no
  OOM this time). **Pre-existing mypy errors fixed** along the way (protocol `interval`
  param, `FilingType` type, screener/market-reader casts).
- **Cleanup per gap-tracking §4**: 10 gap docs + 4 plan docs removed; indexes + task list
  updated (`tantra-data` open gaps 11 → 2: 0015 holiday provider, 0016 EE+; total 67 → 56).
  Commits: `tantra-data` `3a6b247` `7af9a81` `cd9fea6` `3245b3b` `a15ef31`;
  `tantra-market` `b040f68`; `tantra-runtime` `db60aaa`; root `ace2e93`.

## Latest Batch — T4.1–T4.8 + T4.11 (broker adapters & execution)

Date: 2026-11-13. Executed the T4 track from `docs/task-list-tracks-and-phases.md`:
- **T4.1–T4.8 (plan 0002, Implemented)** in `tantra-adapters` (`fcd94bc`):
  - Phase A (gaps 0001–0003): contract tests for all 7 brokers (5 new test
    files mirroring `test_dhan.py`); real `get_bars` returning `list[Bar]`
    honoring `interval`/`days` for all 7 (per-broker historical endpoints);
    `cancel_order` parses the broker response into canonical `Order`.
  - Phase B (gaps 0004–0005): `WebSocketTransport` protocol +
    `MockWebSocketTransport` in-memory mock + per-broker
    `subscribe_ticks(instruments, callback)` → new canonical `Tick` model;
    `common/auth.py` with stdlib RFC 6238 TOTP + `login_zerodha`/
    `login_angelone`/`login_upstox` + `SessionState` expiry.
  - Phase C (gaps 0006–0007): `PaperBroker` order-book depth / partial fills /
    slippage / latency / seeded risk-limit rejection (defaults stay
    deterministic); `AdapterConfig.from_toml` (tomllib) + 5 missing
    `configs/*.toml` templates + parse tests.
  - Phase D: public exports from `common/__init__.py`, typed
    `MockTransportError`, fully-typed `Adapter` protocol + Protocol-typed
    `RecordingAdapter.inner`, `client_order_id` idempotency echo on
    `Order.meta`.
  - Verification: 44 → 134 tests green, `ruff check` + `ruff format --check`
    clean (incl. pre-existing `code-public-api.md`), `mypy --strict` clean.
- **T4.11 (gap 0001, closed)** in `tantra-exec` (`2258bbb`): SmartAPI 2.0
  `BrokerExecutor` adapter — REST place/modify/cancel/order book/positions/
  margins/health, SmartStream order feed → `ExecutionStream`, `BrokerEnumMap`
  wire tables, error mapping, `rate_limited()` (10/s), `SessionTokens` expiry;
  40 new tests, clippy `-D warnings` clean; gap/plan docs closed per repo
  (`e36f64c`).
- T4.9/T4.10 remain **Proposed** (adapters plans 0003/0004 — not approved).
- Cleanup per gap-tracking §4: adapters gaps 0001–0007 + plan 0002 closed
  (docs removed, indexes + task list updated); exec gap 0001 + plan 0002
  retired. Workspace total 71 → 67, phase-3 open 11 → 2 (both Proposed).

## Previous Batch — T3.1–T3.4 (market data & options infrastructure)

Date: 2026-11-13. Executed the T3 track from `docs/task-list-tracks-and-phases.md`:
- **T3.1 (gap 0001, closed)** options-chain enumeration/reader: `InstrumentMaster::list_chain`
  (by underlying, ordered expiry→strike→option type) on `CatalogInstrumentMaster`/`DatasetReader`,
  `ChainReader` port + `InstrumentChainReader` joining quotes + optional OI, exact-Decimal
  `ChainContract` (never f64). Wired into `tantra-runtime-api-rest::FeedMarketReader`:
  `options_chain` now reads the real chain (midpoint last-price, calendar-day expiry filter,
  500 cap); a master that cannot enumerate still maps to `PortError::unavailable`. Commits:
  `tantra-market` `b1b085e`, `tantra-runtime` `39ff389`.
- **T3.2 (gap 0002, closed)** OI time-series + four-quadrant buildup: `OpenInterestStore`
  port, `InMemoryOpenInterestStore` + `ParquetOpenInterestStore` (`{root}/open_interest/YYYY-MM-DD.parquet`,
  exact Decimal128 `Quantity`), `classify_buildup` (long/short buildup, short covering, long
  unwinding) + `BuildupAnalyzer` over OI store + daily bars. Commit `b1b085e`.
- **T3.3 (gap 0003, 2 of 5 shipped)** real broker WS feeds on `tantra-market-core`'s
  `WsClient`/`SymbolMapper`/`ReconnectionManager`: `tantra-market-dhan` (DhanHQ v2: JSON
  requests, LE binary ticker/quote/OI/prev-close/full/disconnect packets; REST LTP snapshot)
  `fb82571`; `tantra-market-zerodha` (Kite Connect 3: binary frames, ltp 8/quote 44/full 184,
  index 28/32; mode-per-token dispatch; REST LTP snapshot) `ad79205`. Both golden-byte tested
  (18 tests across the two crates), prices rounded to exact Decimal at the adapter boundary.
  **Remaining**: upstox, fyers, angelone re-added only when their wire protocols are real
  (fyers' raw subscribe request must be captured from the official SDK).
- **T3.4 (gap 0004 = root 0002, closed)**: feed traits in core, lakehouse/loaders in store,
  real `MarketDataFeed` impls now exist on top of core.
- Verification: market workspace check/fmt/clippy green; store 10 + dhan 10 + zerodha 8 new
  tests green; runtime api-rest chat_market_reader_tests 12 green. Live verification against
  Dhan credentials is the manual follow-on.
- Cleanup per gap-tracking §4: market gaps 0001/0002/0004 + root 0002 closed (docs removed,
  indexes + task list updated; total 74 → 71, market open gaps 4 → 1).

## Previous Batch — T2.7–T2.11 complete (tantra-ledger plan 0005)

Date: 2026-11-13. Executed the remaining T2 rows from `docs/task-list-tracks-and-phases.md`
(`tantra-ledger` settlement & statutory-fee consolidation; approved at the start of this
session, plan 0005 → Ready → Implemented):
- **T2.7** `ClearingCalendar::new()` is an empty weekend-only calendar — the hardcoded NSE
  2024–26 holiday table is gone (gap 0007). Decision recorded: `tantra-data` **owns** the
  NSE trading-holiday data (new upstream gap `tantra-data/docs/gaps/0015-*`, filed `5e873fe`);
  `tantra-runtime-backtest::NseTradingCalendar` is the **consumer & provider of
  `ClearingCalendar`** (injects via `with_holidays`).
- **T2.8** Per-lot corporate actions: `adjust_lot_for_split/bonus/demerger` +
  `reduce_lot_for_demerger` + `AccountState::apply_corporate_actions_to_lots` — positions are
  rebuilt as projections over the lot book, so FIFO `match_lots` realizes the correct per-lot
  cost basis after split/bonus/demerger (gap 0008).
- **T2.9** Per-segment (NFO/MCX/CDS) exchange turnover tables in
  `tantra-market-finance::india::costs::segments` (exact Decimal, from the researched
  circulars: NSE/FA/73061 eff. 2026-03-01, MCX/F&A/631/2024, NSE/FA/64232). `compute_charges`
  looks the segment rate up; the NSE cash-segment fallback is gone (gap 0009). `stt_charge`
  updated to the Finance Act 2026 rates (futures sell 0.05%, options sell 0.15% of premium).
  **Cross-repo dep added**: `tantra-ledger-journal` → `tantra-market-finance` (workspace dep).
- **T2.10** Golden contract-note framework now validates the **canonical** track:
  `GoldenTestRunner::compare_trade` calls `compute_charges`; the five sample fixtures were
  re-based onto the canonical track and the report passes at the 1-paise tolerance (gap 0010).
- **T2.11** OMS context canvas wired: `validate_order_against_context` (notional /
  configured qty / price collar vs `MarketData` / daily loss vs `PortfolioRiskState`),
  `OrderStateMachine::submit_order_with_context`, and a maintained `snapshot()` feeding
  `OmsSnapshot` (gap 0011).
- **Researched tariff data** (exchanges + top-5 discount-broker brokerage) captured in the
  plan appendix; the ledger's per-segment implementation pulls the exchange rates from
  `tantra-market-finance` instead of hardcoding them.
- Verification: ledger workspace **250+ tests green** (portfolio 47, journal 50, oms 38,
  allocation 32, performance 45, facade 4); `fmt --check` + `clippy -D warnings` clean on
  ledger + market; runtime-backtest + agent workspaces re-checked green; `grep Utc::now
  crates/*/src/` returns nothing; no production `src/` code calls the legacy fee track; no
  hardcoded holiday table remains in the domain crate. Commits: `tantra-ledger` `437e6af`,
  `tantra-market` `cbeb045`, `tantra-data` `5e873fe`. Gaps 0007–0011 + plan 0005 closed;
  indexes + task list updated (phase-1 open 8 → 3, total 79 → 74).

## Previous Batch — T2.1–T2.6 complete (tantra-ledger plans 0003–0004, gaps 0001–0006)

Collapsed per `.agents/rules/handoff-hygiene.md` (full detail in git history):
Date: 2026-11-13. HRP + Black-Litterman allocation objectives, exact bounded-simplex
projection, discrete whole-lot allocation, zero-clock `MetricsInput`, edge-score v2. Ledger
200 → 250 tests green; commits `tantra-ledger` `9f8ec22` + `f90f192`, `tantra-runtime`
`eee9d21`.

## Latest Batch — T1 track complete (tantra-risk plan 0002, gaps 0001–0004)

Date: 2026-11-13. Executed the full T1 track from `docs/task-list-tracks-and-phases.md`
(risk 0001–0004 → `tantra-risk/docs/plans/0002`):
- **T1.2 (High)** reduce-only now enforced on **every** check path: order-opening BUYs refused
  on `evaluate_core_checks` + `check_order_fast_checks` (`ReduceOnlyViolation`), modifies and
  new position sizing refused, reducing SELLs + cancels pass. `check_decision` +
  `validate_sizing_request` covered.
- **T1.1** `price_collar_bps` enforced on both paths (new `RiskRefusal::PriceCollarViolation`):
  market orders whose worst-case band-edge fill exceeds `reference ± collar` are refused.
- **T1.3** `check_order_fast` brought to parity: per-scrip OTR record-and-check before approval,
  warning-zone logging, cooldown auto-resume.
- **T1.4** `window_otr_1min/5min` now read `OtrConfig::{window_1min_ms, window_5min_ms}`; the
  engine enforces the configured short-term window (5-min stays analysis-only).
- **API change**: `check_order_fast` gains required `side: OrderSide` — FFI updated in lockstep
  (pyclass, codegen stub, `_tantra.pyi`, `test_risk.py` + new reduce-only test; `cargo check` green).
- **Decision recorded**: the reduce-only position-free approximation (SELL=reduce) and the
  two-layer contract with the runtime REST layer (ADR 0018 `state_refusal`) are documented in
  `docs/design/0002-reduce-only-contract.md` (root) and
  `tantra-risk/docs/design/code-reduce-only.md` — not just HANDOFF.
- TDD: 15 new tests in `tantra-risk/tests/plan0002_tests.rs`; all 80 tests green, clippy `-D warnings`
  clean, fmt clean. Commits: `tantra-risk` `9a0bc59` (impl), docs+indexes follow in the same repo.
  Gap docs 0001–0004 + plan 0002 retired to Closed/Implemented; workspace task list updated
  (phase-1 open count 18 → 14, total 89 → 85).

## Latest Batch — T0 track complete (crate-topology consolidation, plan 0003)

Date: 2026-11-13. Executed the full T0 track from `docs/task-list-tracks-and-phases.md`
(= root plan 0003 + agent plan 0008 + ffi gap 0002 + core plan 0002 Phase A):
- **T0.1** `tantra-market` 14→8 crates: deleted 7 stub crates (feed, loaders, zerodha, upstox,
  fyers, angelone, dhan); pruned market/runtime/agent/ffi `workspace.dependencies`. Gaps 0001/0002
  stay open as **feature trackers** for the real feeds (T3.3/T3.4).
- **T0.2** `tantra-runtime` 14→11 crates: deleted `tantra-indicators` dup + `runtime-market` +
  `test-utils` stubs; absorbed `tantra-runtime-feed` shim into new
  `tantra-runtime-api-rest::market_feed` module (25 src+test files re-pointed; `tantra-market-store`
  is now a direct dep of api-rest). `tantra-runtime-strategy` dev-deps pruned (unused).
- **T0.3** `tantra-exec-angelone` **decision: implement** (kept; real SmartAPI adapter tracked by
  exec plan 0002 / T4.11).
- **T0.4** Pinned the facade-crate convention (ADR in `docs/design/0001` §4.2); added facades
  `tantra-market`, `tantra-exec`, `tantra-runtime`, `tantra-ffi`, `tantra-ui` (thin re-export
  crates; added to each workspace members + deps).
- **T0.5** Removed runtime legacy honba aliases (`tantra-api(-rest)`, `tantra-backtest`,
  `tantra-actors`) + ffi unused `tantra-market-*` deps.
- **T0.6** All 9 Rust workspaces: `cargo check --workspace --profile prod` + `fmt --check` +
  `clippy -- -D warnings` green; `market` (243 tests + doctests) and `exec` (200+ tests) full
  `test --profile prod` green; agent `ref_store_tests` (4) + `verify_tests` (10) green; runtime
  api-rest `market_data` test binary compiles. **Known env limits (pre-existing):** runtime
  api-rest test-bin compile OOMs (SIGKILL) under the prod-LTO profile on this 15 GiB box —
  `check` + one test binary is the practical verification; `tantra-ffi-py` cdylib **link** fails
  with `rust-lld: unable to find library -lpython3.12` (only `libpython3.12.so.1.0` exists on
  this box, no dev symlink) — untouched by this batch, `cargo check` for the workspace is green.
- **T0.7** Phase A audit (plan 0002): **no 1:1 delegation sites** — `market-indicators` is
  streaming f64, `agent-analytics` f64 statistical; quant is Decimal-batch. Delegation matrix +
  verdict recorded in `tantra-core/docs/design/code-quant.md`; gap 0001 stays open as
  verify-on-future-work.
- **T0.8** Moved inline tests out of `ref_store.rs` + `verify/mod.rs` into
  `tests/ref_store_tests.rs` (new) + `tests/verify_tests.rs` (existing) — plan 0008 implemented.
- Cleanup per gap-tracking §4: deleted closed gap docs (root 0003/0004/0005/0007/0008,
  ffi 0002, agent 0001) + plan docs (root 0003, agent 0008); updated all indexes + the task list.
  Plan 0003 recorded in root `docs/plans/README.md` Implemented. No Python changes.

## Previous Batch — consolidated track/phase task list

Date: 2026-11-13. Created `docs/task-list-tracks-and-phases.md`: a single execution-ordered
task list derived from the live per-repo `docs/{plans,gaps}/README.md` indexes — **89 open tasks
across 15 repos**, organized into 12 tracks (T0 topology/hygiene → T11 docs) and 7 phases
(Phase 0 topology → Phase 6 UI/docs), with per-row links to the governing plan/gap, statuses,
and dependency/blocking edges. Source of truth remains the per-repo indexes; the task list is a
derived view that must be updated in the same change as any index cleanup. Linked from
`docs/plans/README.md` (Related). No code changes.

## Previous Batch — re-write `tantra-runtime`/`tantra-ui` docs (dismantle roadmap into design/gaps/plans)

Date: 2026-11-13. Dismantled `docs/roadmap/` in both repos and re-wrote
`docs/{design,gaps,plans}` to reflect the source code (same pattern as the
`tantra-risk`/`tantra-strategies`/`tantra-ledger`/`tantra-market`/`tantra-ffi` batches):
- `tantra-runtime`: `roadmap.md` + `migration-verification.md` removed → new
  `docs/design/implementation-record.md` (migration M1–M3 + subsequent landings table).
  `architecture.md` §5 gaps/plans snapshot corrected to source: plan 0003 (trade-journal +
  market-reference REST endpoints) is **implemented** (all routes registered in `v1.rs`;
  market-reference handlers serve sample stores pending the `tantra-data` → Rust FFI bridge) —
  moved to Implemented, doc removed per gap-tracking rule §4; gaps index gained previously-missing
  gap 0005; gap 0007 item 7 corrected to `ContentReader::filings` method name (chat tool is
  `filings_search`); gap 0005 corrected 10→9 report routes. No code changes.
- `tantra-ui`: `roadmap.md` removed → `docs/design/implementation-record.md`; stale 20-line
  `architecture.md` rewritten source-verified (9-crate map; corrected the false "Leptos 0.8
  CSR app" / "REST+WS client" / "canvas rendering engine" claims — ui-app is feature-state
  models only, ui-client is an in-memory push bus, ui-charts is geometry-only); new per-crate
  `code-{cli,tui,highlight,ui-core,ui-app,ui-api-wasm,ui-charts,ui-client,ui-assets}.md` +
  `code-migration-map.md`. First four open gaps filed (0003 canned CLI reports, 0004 no view
  layer, 0005 TUI placeholder tabs/hardcoded watchlist, 0006 scan fixture universe). Plans
  README corrected (plan 0005 SHAs `2cda245`/`acdc137` no longer exist after the rename history
  rewrite; plan 0001 stale "blocked upstream" claim removed — Ask/Chat/Tui wired). No code
  changes. Committed per-repo. All gap claims source-verified at filing time.

## Previous Batch — platform rename to Tantra (plan 0004)

Date: 2026-11-12. Completed the full platform rename to `tantra` (org/repos/crates/
Python packages/docs) per plan 0004 (now closed, recorded Implemented in
`docs/plans/README.md`):
- All 14 submodules renamed (`crates/*`, package dirs, docs) and committed
  (`tantra-core` 54da11d → `tantra-examples` 792e4b8); root submodule paths, `.gitmodules`
  (URLs → `tantra-labs/tantra-*`), Makefile `REPOS`, and `scripts/create-remote-repos.sh`
  updated. `origin` remotes point at `tantra-labs` (root included).
- History identity rewritten: every commit authored/committed with the former AMD corporate
  email (`Premachandra.Mallappa@amd.com`) is now `Prem Mallappa <dev.prem.mallappa@gmail.com>`;
  root cause fixed — the `~/.config/git/config.amd` include previously overrode `user.email`
  (its `[user]` block was removed); global git `user.email` is `dev.prem.mallappa@gmail.com`.
- Gates: `make check` green on all 9 Rust workspaces; Rust/Python test suites NOT re-run to
  completion (env: `prod`-profile LTO test compiles OOM on 15 GiB box).
- Pre-existing, non-rename failures observed: agent `test_architectural_dependency_rules` R4
  (`tantra-agent-mcp` → `tantra-ledger-allocation`, from agent `28629d0`); runtime test-bin
  compiles OOM (SIGKILL). Both predate the rename.

## Previous Batch — re-write `tantra-risk`/`tantra-strategies` docs (dismantle roadmap into design/gaps/plans)

Date: 2026-11-12. Dismantled `docs/roadmap/` in both repos and re-wrote
`docs/{design,gaps,plans}` to reflect the source code (same pattern as the earlier
`tantra-ledger`/`tantra-ffi`/`tantra-market` batches):
- `tantra-risk`: rewritten `architecture.md` + all `code-*.md` design docs to match actual
  source (removed fake `algo_id` regex, fake `risk_refusals`/`risk_approvals`/`algo_halted`/
  `kill_switch_activated` metrics, non-existent `global_kill_switch()` method, and the
  `Emergency` tool hint). Created first-ever `docs/gaps/` (0001 `price_collar_bps` unenforced,
  0002 reduce-only not enforced, 0003 `check_order_fast` scrip-OTR/warning/cooldown divergence,
  0004 `OtrConfig` window knobs never read) + `docs/plans/0002-close-declared-unenforced-risk-controls.md`
  collecting them; `implementation-record.md` added; `roadmap/` removed.
- `tantra-strategies`: rewritten `architecture.md` + `code-{sdk,strategies,manifest,migration-map}.md`
  (dropped nonexistent `stop_loss()` helper, documented `on_tick` as an undispatched stub).
  Created first-ever `docs/gaps/` (0001 `on_tick` never dispatched, 0002 no live `StrategyContext`
  in-repo, 0003 catalog step.toml is declarative-only, 0004 no `BasketManifest` run loop, 0005
  `RiskBudget` is a Phase-1 simple cap) + `implementation-record.md`; `roadmap/` removed.
- `tantra-ledger`: already dismantled (commit `06df5ad`, 2026-11-12) — verified current, no changes.
- No code changes; committed per-repo. All gap claims source-verified (grep) at filing time.

## Prior batches (collapsed per `.agents/rules/handoff-hygiene.md`)

- **Resolve rebase conflicts (tantra-agent, tantra-data, tantra-adapters, tantra-market, 2026-11-12)**:
  agent plan renumbering to 0008/0009/0010 + data gaps 0013/0014; adapters rebased to `8d7c440` (plan 0002
  folded, gaps 0001–0007 refreshed); market `87ed5aa`; `pytest` green (adapters 44, data 86).
- **`tantra-ffi`/`tantra-market` docs (dismantle roadmap, 2026-11-12)**: per-module `code-*.md`
  design docs + first-ever `docs/gaps/` (market 0003/0004 cross-ref root gaps 0001/0002; ffi 0001 CLI
  subcommand stubs, 0002 unused `tantra-market-*` deps); `roadmap/` removed in both; committed per-repo.
- **Crate topology audit & consolidation docs (2026-11-12)**: root `docs/design/0001-crate-topology-audit-and-target.md`
  (72 → ~60 target), `docs/plans/0003-crate-topology-consolidation.md` (5-phase plan), `docs/gaps/0001`–`0008`
  (market broker WS stubs, feed/loaders stubs, runtime indicator duplicate, runtime-feed shim, runtime
  market/test-utils stubs, exec-angelone stub, facade-convention inconsistency, runtime legacy honba aliases).
- **Adapters documentation sync (tantra-adapters + tantra-docs, 2026-11-12)**:
  per-module design docs, gaps 0001–0007 refreshed; `tantra-docs` updated.

- **Plan 0006 Phase 4 (2026-11-12)** — `options_chain`/`corporate_actions` chat
  tools; research re-verified upstream first (`tantra-market` had no chain
  reader; `tantra-data` corporate-actions reader exists Python-side). Gaps
  filed before tool code: `tantra-market/docs/gaps/0001-options-chain-reader.md`,
  `tantra-data/docs/gaps/0008-corporate-actions-rust-bridge.md` + `0009`.
  Landed: `OptionContract`/`OptionsChain`/`CorporateAction` DTOs,
  `MarketReader::options_chain`/`corporate_actions`, 2 ReadOnly tools
  (catalogue **17 → 19**), honest `FeedMarketReader` stubs + seedable
  `RuntimeMarketReader` stores. **Plan 0006 complete (Phases 1–4)**, doc
  retired to agent `docs/plans/README.md` Implemented table; follow-on breadth
  under agent plan 0007. Commits: agent `127597d`+`a0817a6`, runtime `bcd1c76`,
  market `d4e3c76`, data `0bc5edd`. All gates re-verified 2026-11-12 (fmt /
  clippy `-D warnings` / `cargo test --workspace --profile prod` 0 failed /
  fresh `make prod` each).
- **Plan 0006 Phase 3 (2026-11-12)** — `news_search`/`filings_search` via new
  `ContentReader` port (catalogue 15 → 17); gaps `tantra-data/docs/gaps/0006`+`0007`
  filed. Commits: agent `98c66c2`, runtime `96e878f`, data `3ee4005`.
- **Plan 0006 Phases 1–2 (2026-11-11)** — `BlockDealsTool` (`MarketReader::block_deals`,
  honest runtime stub citing `tantra-data` gap 0005, runtime plan 0004 Phases 1–3)
  and `PriceAlertTool` CRUD (`AlertReader`/`AlertWriter`, `price_alert_list`/`price_alert`,
  `Profile.alerts` storage). Catalogue 14 → 15 read-only + 2 alert tools
  (agent `a72689c`, runtime `d54f140`).
- **Fincept/Quantcept gap-closure batch (2026-11-06)** — Layers 0–6 GREEN
  (per-layer table with commits in this file's git history; `tantra-core` 9ce4880,
  `tantra-ledger` b35a314, `tantra-risk` 5b00cda, `tantra-market` ddb5c3f+1983512,
  `tantra-exec` 2675c07+ed3a6b3, `tantra-strategies` 207a70c, `tantra-agent` 36b0d53/1f9fb13/
  51b024d/236f8eb/5470e7b, `tantra-ui` 2cda245+acdc137, `tantra-examples` 552c873,
  `tantra-docs` 1267490). Key decisions preserved: core enables rust_decimal `maths`;
  `BrokerEnumMap<T>` table-driven wire mapping (Layer 2); **crypto execution NO-GO** (fresh
  scope review required to revisit); Python adapters dev/research-only; forecast/panel compute
  f64-internal with exact-Decimal boundaries; duplicate `LlmProvider` in agent-core deleted in
  favor of `tantra-agent-llm`; 0004 Phase 4 local SLM deferred by design. Session also landed
  `tantra-ledger` plan 0002 (`tantra-ledger-performance`, 2a3a04e), `tantra-data` gaps
  0001+0002 (261d646), `tantra-runtime` plan 0003 (trade-journal + market-reference endpoints;
  sample stores pending the `tantra-data` → Rust FFI bridge).

## Prior work (collapsed per `.agents/rules/handoff-hygiene.md`)

- **Tier 0–6 repo migration** (`honba-*` → `tantra-*` submodules, incl. Tier 4 `tantra-ffi`'s
  codegen/PyO3/Arrow bridge/Python SDK): complete. Full per-tier detail (gate reports, slice
  tables, Tier-0-specific design notes) lived here until 2026-11-06; trimmed now that it's long
  superseded by Tiers 5–6 and this file's current "Latest Batch" above. See commits
  `feat(tier-0)` through `feat(tier-6)` in this repo's git log for the full record; the migration
  guide that used to be this file's "Playbook" pointer was retired in `4b5d9f9`.
- **Submodule updates (2026-11-09)**:
  - `tantra-examples`: All 9 stages (0–8) of `honba-examples` staged port landed (`docs/plans/0002` Implemented); full test suite (922 passed, 70 skipped), master index `examples/README.md`, and docs completed.
  - `tantra-runtime`: **PLAN-0001 complete (Stages 1–4)** — RunId/`FileJournalWriter`/recovery (`60a5bd9`), bounded worker pool with 429 backpressure + `FileJobRegistry` (approvals queue, fencing leases, budgets) + Vixie cron scheduler + broker dispatch behind the SEBI risk gate (`46817a0`); plan/gap docs retired (`4bd4ef5`). Remaining open: GAP-0003 (broker wire transports), PLAN-0002 (statistical gates).
  - `tantra-ui`: **PLAN-0001 Stage 4 CLI half landed** — `tantra jobs run/tick/logs` on the runtime pool + per-run journals (`tantra jobs add ... -> tick -> journal verified` acceptance suite, 11 e2e tests) + agent tool-call journals + approvals gating (`0b9241d`); clippy-driven fixups (breach-first refusal for PendingApproval jobs) follow-up. Open: ui-core trade rows (`tantra-ui/docs/gaps/0002`).

## Immediate Next Step
- **Trade signal generator (root plan 0008, proposed 2026-11-15)** — docs only; build order core 0005 (planner + manager) ∥ market gap 0007 (ADR%/Chandelier) → ffi 0004 → strategies 0003 → runtime 0006 → agent 0014. `strategy_suggest` remains a stub until agent 0014.
- **Screener taxonomy / QVM / group alerts (root plan 0010, proposed 2026-11-15)** — docs only so far; build order P1 `tantra-core` 0004 → P2–P4 `tantra-data` 0007/0008 → P5 strategies 0002 → P6 runtime 0007 → P7 agent 0013 → P8 examples 0005. Research: `docs/research/trendlyne-screener-alerts-mcp.md`.
0. **T9.8 (ex 0006 kernel-domain root, in progress)** — continue the Decimal-canonical wheel
   slices bottom-up: `bar` (Decimal) → `order_state`/`execution` → `indicators` (87 files) →
   `portfolio_strategy`/`wire`/`store`/`backtest` sims, then re-point the `_kernel` modules
   to re-export from the wheel and delete the mirror. Map: `tantra-examples/docs/design/
   gap-cascade-kernel-mirror.md`. Then ex 0004 (display/universes/india), ex 0003 (data
   re-point), ex 0002 (ai), ex 0007 (adapters framework), ex 0008 (session).
1. **EE+ (root plan 0005, proposed)** — the SDK prerequisite of T12.4 (strategies gap 0006) is
   **closed 2026-11-14** (`stop_loss`/`trail_stop`/`on_stop_update` + `level_map()`/
   `options_snapshot()` context surface shipped). Remaining dependency order: T12.1 kernel domain
   types (`tantra-core` plan 0003) → T12.2 indicators (`tantra-market` gap 0005) → T12.3
   chain-snapshot lakehouse (`tantra-data` gap 0016) → T12.4 EE+ strategy itself
   (`tantra-strategies` plan 0001) → T12.5–T12.7 execution/risk/OMS (exec 0003, risk 0005,
   ledger 0012) → T12.8/T12.9 agent/UI (agent 0011, ui 0006/gap 0007). **Docs (T12.10) DONE
   2026-11-15** — `tantra-docs` guide + `reference.md` shipped; its "planned" banners drop
   when T12.4/T12.8/T12.9 land. See the T12 track in `docs/task-list-tracks-and-phases.md`.
1. **T7 complete (2026-11-14)** — gap 0007 (all 19 items) + T4.9/T4.10 + T0.7 + T6.9 closed;
   items 10/14–16 were the last open (L2 depth, fundamentals/MF/IPO) and landed with real
   data. Only runtime gap 0008 stays open by design (documented architecture decision option
   1, not a stub); it closes only if option 2 (lift `BrokerAdapter` into `tantra-exec-core`)
   ever executes. Fund *holdings* remain unsourced (documented in `tantra-data` 0021 closed
   row; never fabricated).
2. T3.3 remaining: capture the Fyers v3 subscribe request from the official SDK and implement
   the `upstox`/`fyers`/`angelone` feed crates mirroring `dhan`/`zerodha`; live-verify the Dhan
   (and Kite) feeds against the Dhan credentials.
3. `tantra-data/docs/gaps/0015-nse-trading-holiday-provider.md` — wire the runtime
   `NseTradingCalendar` to tantra-data's holiday ingestion once it ships.
4. T4 follow-ons (both Proposed, not approved): `tantra-adapters` plan 0003 (cross-repo
   integration Python ↔ Rust core) and plan 0004 (production hardening: rate limits, pooling,
   token refresh).
5. Remaining per-repo follow-ups (non-blocking, tracked in each repo's HANDOFF / `docs/gaps/`):
   - **4B Phase 4 (local SLM)** — deferred by design; prerequisite is the Phase-3 golden fixture set accumulating via live OmniRoute runs (`TANTRA_WRITE_FIXTURES=1`), then model licensing/fine-tuning/quantization per `0005`.
   - **0001 Phase 1** (`tantra_search_tools`/`tantra_describe_tool` two-tier gateway) — the forecast engine is currently discoverable via `tools/list` only; once the gateway lands, add the `forecast` category to its category enum.
   - **`tantra-ui`** — Leptos view layer for `tantra-ui-app`, wire CLI `ask`/`scan` (gap `tantra-ui/docs/gaps/0001`), TUI `run()` event loop.
   - Layer 3's `BasketManifest` consumption lands in `tantra-runtime-backtest` (catalog.rs/engine.rs) as a separate future slice, per the plan's scope note.

## Operating Invariants
- Toolchain: `cargo 1.97.1` / `rustc 1.97.1`; edition 2024, `rust-version = "1.85"`.
- Zero inline `#[test]` / `#[cfg(test)]` in `src/**/*.rs` (Parallel Test Directory Rule, `.agents/rules/testing-and-verification.md` & `AGENTS.md` §4).
- Wire compatibility: `Price`/`Quantity` remain string-encoded decimals (`serde-with-str`); `-0.00` parses to `Decimal::ZERO` semantics (not negative-strict), matching upstream rust_decimal behavior.
- All rules in `.agents/rules/` (`architecture-and-coupling`, `interface-first-and-modularity`, `coding-and-ddd`, `testing-and-verification`, `scalability-and-concurrency`, `security-and-secrets`, `build-discipline`, `gap-tracking`, `handoff-hygiene`, `no-recon`, `subagent-discipline`), `.agents/config/project-settings.json`, and `.agents/checklists/` are binding workspace-wide — see `AGENTS.md` §8.
- Plan & Gap discipline: when implementing a plan or gap, any hardcoded/stubbed/sample data used requires filing a `docs/{plans,gaps}/XXXX-*.md` in the respective provider repo (gaps = individual features, plans = collections of gaps). When implemented, the document is cleaned up from active `docs/{plans,gaps}/` and recorded in the repo's index.
