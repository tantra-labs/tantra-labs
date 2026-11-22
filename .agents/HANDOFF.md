# HANDOFF — tantra-labs

**Status**: Bottoms-up Fincept/Quantcept gap-closing build order
(`docs/future-work-bottoms-up-build-order.md`) — Layers 0–6 GREEN.
**Latest landed**: **Root Plan `0020` Dockview + VibePrompt UI + Multi-Font System & Backend Gap Closures (`tantra-ui-web`, `tantra-agent` gap `0010`, `tantra-runtime` gap `0014`, `tantra-ui` `CodeDiff`) COMPLETE 2026-11-22**; T21/T22 cross-repo architectural unification (`2026-11-20`); T14 Paper Exchange, T12 EE+, T18 fixes, and T17 Lakehouse v3 Phases 1–3.
Date: 2026-11-22 · Workspace: `tantra-labs`
Playbook: `docs/future-work-bottoms-up-build-order.md`

## Latest Batch — Root Plan `0020` Full Stack (UI Dockview/Fonts + Upstream Agent/Runtime/TUI Gaps), COMPLETE 2026-11-22

Executed Phases 0–4 of `docs/plans/0020-dockview-vibeprompts-ui-web-migration.md`, follow-on UX polish (`b191310` + working tree), and closed upstream gaps `tantra-agent` `0010` and `tantra-runtime` `0014`:
- **`tantra-ui-web` (`b191310` + verified working tree)**:
  - **Shell & Iconography**: `dockview-react@8.9.1` workstation, top-bar `WidgetCatalogMenu` launcher + `X` tab close (right activator rail removed), 4 presets, `v1→v2` layout migration, `CommandPalette` Dockview dispatch, `(app)/*` redirects, **353** SVG taxonomy icons (`TantraIcon`/`IconButton` across `chart-controls.ts`, toolbars, switcher).
  - **VibePrompt `agent/*` Pane & Thread Sync**: `AgentPane` (`AgentTurnCard`, `AgentRunTrace`, `PromptBudgetBar`, `StrategyDiffCard`, `ToolPayloadTree`), server `/api/v2/chat/threads` sync (`chat-threads-sync.ts`, `chat-threads-store.ts`) + native `thought_delta`/`token_usage`/`raw_input`/`raw_output`/`code_diff` hydration (`src/app/api/chat/route.ts`), and consolidated duplicate `ResearchTabContent` into `agent-copilot` (`Quant Copilot`, 24 `DOCK_PANEL_KINDS`; legacy `?open=research` redirects preserved).
  - **Multi-Font System & Built-in Per-Widget Selectors**: Global `SettingsModal` Appearance backing font groups (`Sans`: `Open Sans`/`Fira Sans`/`IBM Plex Sans`; `Serif`: `IBM Plex Serif`/`Merriweather`/`Lora`; `Sans Serif`: `Roboto`/`Roboto Condensed`/`Inter`; `Mono`: `Cousine`/`Ubuntu Mono`/`Roboto Mono` in `src/lib/appearance.ts` + `src/app/layout.tsx`) and built-in `<WidgetFontSelect />` (`Sans | Serif | Sans Serif | Mono`, persisted via `src/lib/widget-fonts.ts`) wired into all 24 panel organisms. Verified: `npx tsc --noEmit`, `npm run lint`, `npm test` (126/126 across 35 suites), `npm run build`, and `npm run check:api-contract` (OpenAPI in sync) all GREEN.
- **Upstream Gaps Closed & Verified**:
  - **`tantra-agent` (gap `0010` CLOSED)**: Added `DisplayBlock::CodeDiff`/`CodeDiffHunk` & `SessionStore` single/update/archive/delete methods (`tantra-agent-core`), `ChatStreamEvent::{ThinkingDelta,Usage}` (`tantra-agent-llm`), and `SessionEvent::{ThinkingDelta,Usage}`, `ToolStarted::raw_input`, `ToolFinished::raw_output`, and `CodeDiff` extraction (`tantra-agent-chat`); `fmt --check`, `clippy -D warnings`, targeted suites, and `make prod` green.
  - **`tantra-runtime` (gap `0014` CLOSED)**: Implemented `SqlxSessionStore` session lifecycle CRUD (`tantra-runtime-persistence/src/sessions.rs`), caller/workspace-scoped `/api/v2/chat/threads` CRUD (`chat_threads.rs`, `v2.rs`), `/ws/chat` structured trace forwarding & `thread_id` ownership check (`chat.rs`), and regenerated `openapi.rs`/`schema/openapi.v2.json`; `chat_ws_gap0014` (4), auth/openapi/version conformance suites, `tantra-runtime-persistence`, `fmt --check`, `clippy -D warnings`, `make check`, and `make prod` green.
  - **`tantra-ui` (verified)**: Added `DisplayBlock::CodeDiff` rendering to `tantra-cli::block_render` and `tantra-tui::{result_block,analysis_view}`; `fmt --check`, `clippy -D warnings`, targeted `tantra-tui` tests (16), `make check`, and `make prod` green.

## Latest Batch — Architectural-analysis unification (T21/T22 cross-repo), COMPLETE 2026-11-20

Source: `docs/plans/Here is an architectural analysis of the.md` (§2 strategies duplication, §3 cross-repo design changes). All landed with per-repo commits:
- **strategies**: single Decimal indicator kernel; EE+/ORB-15 in `tantra_library`; gap 0008 closed; PR recipes emit `OverlayScene` + runnable `catalog_steps`; `WheelSdkBridge`; legacy `catalog/` retired; `LakehouseBarSource`.
- **data / market**: data gap 0026 closed (`LakehouseBarReader`); market ATR/CMO in `rust_decimal` (gap 0009 stays open).
- **runtime / agent**: runtime plan 0010 (`/api/v2/studies/*`, fail-closed JWT auth); agent plan 0017 (`IndicatorLibraryPort`, `tantra_library_*` MCP proxy).
- **ui / ui-web**: generic `OverlayScenePrimitive`; `/api/v2/studies` client; `wasm32` fix (`core 601ba3f`); Indicator Lab (`ui-web 40b9210`, plan 0017).
- **Next**: T21.6 (`StrategyLoopPort` + `DisplayBlock::Scene` in `tantra-agent`, file as agent plan 0018); live browser check of `OverlayScene` + Indicator Lab + Dockview `DockviewWorkspace`.
  `tantra-strategies` tests need `PYTHONPATH=../tantra-ffi/python:../tantra-examples:../tantra-data/src:.`.

## Latest Batch — Lakehouse v3 (root plan 0011) Phases 1–3 COMPLETE 2026-11-18

- **`tantra-data`** (`plan 0009` A–C: `ee802e9`/`398eeb7`/`d64c877`, gap `0025` closed): CAS (`objects/sha256`), `catalog.duckdb`, `trees/` export, `tantra-catalog` CLI.
- **`tantra-market`** (gap `0008` closed) + **`tantra-runtime`** (gap `0011` closed): `ManifestResolver`, `Lakehouse::compact_v3`, `CatalogInstrumentMaster` Decimal128, `CatalogLoader` snapshot pinning & RowGroup pruning, `BacktestRequest.data_ref`. Phase 4 (legacy fallback removal) remains.

## Prior batches (2026-11-06..2026-11-17, collapsed per `.agents/rules/handoff-hygiene.md`)

- **Reading-List study book (`docs/reading-list/`, 2026-11-17)**: 24 chapters + 6 appendices + AI study-companion templates (`mdbook build docs/reading-list` clean).
- **T12.9 Studio + T18 independent-fixes + EE+ platform (2026-11-17)**: `tantra-ui` `013a5d6`; T18.1–T18.6 (`data` 0015/0023/0024, `runtime` 0009/0010, `strategies` 0007 closed); TradePlanner/TradeManager/OCO/FIFO bracket PnL (`core` 08dffea, `ledger` ff73eaa/697b428, `exec` fc4a5a6).
- **T14 Standalone Paper Exchange (2026-11-16, root plan 0007)**: `tantra-exec-paper`, runtime `/orders` + `/ws/live` + `paper serve`, wheel `tantra.paper`, WASM/UI/TUI/CLI, cross-language golden parity, `tantra-docs` user/paper guides.
- **T13 `_kernel` dismantle & single `.venv` (2026-11-16, root plan 0006)**: wheel `tantra.{portfolio,risk,options,metrics,calendar}`, `tantra_examples/harness/`, all 8 `tantra-examples` gaps closed.
- **T0–T9 foundations (2026-11-12..2026-11-15)**: platform rename (`honba-*` → `tantra-*`), crate topology consolidation (plan 0003), risk controls (plan 0002), ledger settlement & FIFO corporate actions (plan 0005), data/market readers (T3/T5/T7), OpenAPI v2 spec, `tantra-strategies` ticks/live/baskets (T8).

## Immediate Next Step
1. **Browser smoke QA (`tantra-ui-web` plan `0020`)**: Verify `/workspace` Dockview layout switching, `WidgetCatalogMenu`, per-widget `<WidgetFontSelect />` + `SettingsModal` fonts, `(app)/*` redirects, and `AgentPane` streaming/thread sync against a running `tantra serve` runtime; commit the pending working trees across `tantra-ui-web`, `tantra-agent`, `tantra-runtime`, `tantra-ui`, and root `tantra-labs` when ready.
2. **Remaining chat/runtime gaps**: Implement `tantra-runtime/docs/gaps/0013` (per-caller journal & paper account), `tantra-agent/docs/gaps/0009` (`DisplayBlock::Chart` series refs), and T21.6 (`StrategyLoopPort`).
3. **Active cross-repo roadmaps**: `docs/plans/0009` (Qullamaggie), `docs/plans/0008` (Trade Signal Generator), `docs/plans/0010` (Screener/QVM P2–P9), `docs/plans/0019` (Codebase audit & unwired subsystem wiring), and T3.3 remaining feeds (`upstox`/`fyers`/`angelone`).

## Operating Invariants
- Toolchain: `cargo 1.97.1` / `rustc 1.97.1`; edition 2024, `rust-version = "1.85"`.
- Zero inline `#[test]` / `#[cfg(test)]` in `src/**/*.rs` (Parallel Test Directory Rule, `.agents/rules/testing-and-verification.md` & `AGENTS.md` §4).
- Wire compatibility: `Price`/`Quantity` remain string-encoded decimals (`serde-with-str`); `-0.00` parses to `Decimal::ZERO` semantics.
- All `.agents/rules/` (`architecture-and-coupling`, `interface-first-and-modularity`, `coding-and-ddd`, `testing-and-verification`, `scalability-and-concurrency`, `security-and-secrets`, `build-discipline`, `gap-tracking`, `handoff-hygiene`, `no-recon`, `subagent-discipline`), `.agents/config/project-settings.json`, and `.agents/checklists/` are binding workspace-wide.
- Plan & Gap discipline: cite upstream `docs/{plans,gaps}/XXXX-*.md` at stubs/fallbacks; clean up completed docs and update indexes on closure.
