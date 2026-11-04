# `vyapaar-brain` — TDD & Engineering Roadmap

## Milestone 1: Core AI Contracts, Prompting & SHA-256 Replay (P0)
- [ ] Port `vyapaar-brain-core`, `vyapaar-brain-prompt`, and `vyapaar-brain-replay` from `honba-nou`.
- [ ] Verify SHA-256 deterministic replay and `Decision` grounding tests.

## Milestone 2: LLM Providers, Agent, Trader Loop & Genetic Engine (P0)
- [ ] Port `vyapaar-brain-llm`, `vyapaar-brain-agent`, `vyapaar-brain-trader-loop`, `vyapaar-brain-research`, `vyapaar-brain-analytics`, `vyapaar-brain-genetic` (from `honba-nou-genetic-engine`), and `vyapaar-brain-mcp`.

## Milestone 3: Agent Tools, Plugins & Typst Report Compiler (P1)
- [ ] Implement `vyapaar-brain-tools` (`AgentTool` trait + built-in market/portfolio/screener query tools).
- [ ] Implement `vyapaar-brain-plugins` (`PluginManifest`, `PluginRegistry` with deterministic validation).
- [ ] Implement `vyapaar-brain-report` (`ResearchReport`, Typst/Markdown tearsheet renderer with `Decimal` metrics).
