# `vyapaar-brain` — Subagent Migration & DDD Refactoring Guide

> **Tier**: Tier 3A (Depends on `vyapaar-core` and `vyapaar-risk`)
> **Source**: `/home/pmallapp/Devel/Finance/honba-workspace/honba-nou`
> **Target**: `/home/pmallapp/Devel/Finance/vyapaar-labs/vyapaar-brain`

---

## 1. Sub-Crate Mapping Table

| Source Crate (`honba-nou/crates/`) | Target Crate (`vyapaar-brain/crates/`) | Notes |
| :--- | :--- | :--- |
| `honba-nou-core` | `vyapaar-brain-core` | Port core AI traits and grounding validators. |
| `honba-nou-prompt` | `vyapaar-brain-prompt` | Port prompt templates and context builders. |
| `honba-nou-replay` | `vyapaar-brain-replay` | Port SHA-256 cassette store and replayer. |
| `honba-nou-llm` | `vyapaar-brain-llm` | Port LLM client adapters and `ScriptedFakeLlm`. |
| `honba-nou-agent` | `vyapaar-brain-agent` | Port agent state machine. |
| `honba-nou-trader-loop` | `vyapaar-brain-trader-loop` | Wire to `vyapaar_risk::RiskEngine`. |
| `honba-nou-research` | `vyapaar-brain-research` | Port autonomous research loop. |
| `honba-nou-analytics` | `vyapaar-brain-analytics` | Port attribution and statistical analytics. |
| `honba-nou-genetic-engine` | `vyapaar-brain-genetic` | Note crate rename: `-genetic-engine` → `-genetic`. |
| `honba-nou-mcp` | `vyapaar-brain-mcp` | Port MCP server and JSON-RPC tool handlers. |
| *(New Crate)* | `vyapaar-brain-tools` | Implement pure `AgentTool` trait, `ToolCall`, `ToolOutput`, and `ToolRegistry` with unit tests in `tests/`. |
| *(New Crate)* | `vyapaar-brain-plugins` | Implement `PluginManifest`, `PluginCapability`, and `PluginRegistry` with unit tests in `tests/`. |
| *(New Crate)* | `vyapaar-brain-report` | Implement `TearsheetReport` & Typst/Markdown source generator consuming `vyapaar-core` `Decimal` metrics with unit tests in `tests/`. |

---

## 2. Mandatory DDD Fixes During Migration
1. **Eliminate Upward Dependency on Runtime (`honba-ya-strategy`)**:
   - In `honba-nou/Cargo.toml`, `honba-nou-strategy` pointed to `../honba-ya/crates/honba-ya-strategy`. Ensure `vyapaar-brain` only depends downward on `vyapaar-core` and `vyapaar-risk` (or if `vyapaar-runtime-strategy` is needed, keep `vyapaar-brain` independent so `vyapaar-runtime` can depend on `vyapaar-brain` without cycles).
2. **Extract Inline Tests**: Ensure zero `#[cfg(test)]` blocks remain in `crates/*/src/`.

## 3. Verification Commands
```bash
cd /home/pmallapp/Devel/Finance/vyapaar-labs/vyapaar-brain
grep -rn "#\[cfg(test)\]" crates/*/src/ && exit 1 || true
cargo fmt --check
cargo clippy --all-targets -- -D warnings
cargo test --workspace
```
