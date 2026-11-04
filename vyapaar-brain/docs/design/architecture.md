# `vyapaar-brain` — DDD Architecture & AI Brain Bounded Context

## 1. Bounded Context & Safety Guardrails
`vyapaar-brain` (Tier 3A, evolved from `honba-nou`) is the **AI Reasoning & Autonomous Research Bounded Context**. Per the NoFX Untrusted AI Principle:
* LLMs are treated strictly as untrusted signal/decision proposers.
* Every LLM completion is parsed into `vyapaar_core::Decision` (`#[serde(deny_unknown_fields)]`), grounded against real-time `PriceBand`s, and clamped by `vyapaar_risk::RiskEngine`.
* Every prompt, seed, temperature, and completion is SHA-256 hashed (`vyapaar-brain-replay`) for deterministic backtest replay.

## 2. Sub-Crate Topology (13 Crates)

| Sub-Crate | Responsibility |
| :--- | :--- |
| `vyapaar-brain-core` | Shared AI traits (`LlmProvider`, `PromptBuilder`, `DecisionValidator`), audit envelope, and grounding checks. |
| `vyapaar-brain-prompt` | Versioned prompt templates, market/portfolio context serializers, token budgeters. |
| `vyapaar-brain-replay` | Content-addressed SHA-256 prompt/completion cassette archive and deterministic offline replayer. |
| `vyapaar-brain-llm` | Cloud & local LLM adapters (Anthropic Claude, OpenAI, Gemini, Ollama/vLLM, `ScriptedFakeLlm`). |
| `vyapaar-brain-agent` | Multi-step reasoning agent state machine and memory context. |
| `vyapaar-brain-trader-loop` | Event-driven AI trader loop connecting `LlmProvider` → `DecisionValidator` → `vyapaar_risk::RiskEngine`. |
| `vyapaar-brain-research` | Autonomous hypothesis generation, factor discovery, and walk-forward experiment loop. |
| `vyapaar-brain-analytics` | Performance attribution, Deflated Sharpe Ratio (DSR), regime classification, and drawdown analytics. |
| `vyapaar-brain-genetic` | StockSharp Odysseus-style genetic programming & rule-tree strategy synthesizer. |
| `vyapaar-brain-mcp` | Model Context Protocol (`rmcp`) server exposing market, portfolio, and backtest tools to external AI clients. |
| `vyapaar-brain-tools` **[NEW]** | Typed `AgentTool` registry for screener queries, regime checks, and risk inspection. |
| `vyapaar-brain-plugins` **[NEW]**| Extensible plugin manifest (`PluginManifest`) and capability loader for custom research skills. |
| `vyapaar-brain-report` **[NEW]** | Embedded Typst / Markdown quantitative research tearsheet & PDF report generator. |
