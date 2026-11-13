# Rule: Testing, TDD & Verification Gates (binding)

**Status: binding for every orchestrator, subagent, and PR across all `tantra-labs` repositories.**

## 1. Parallel Test Directory Rule (ZERO EXCEPTIONS)

- **MANDATORY**: All unit tests, integration tests, property tests, fuzzers, and test helpers MUST live in `tests/` parallel to `src/` (Rust) or package `tests/` (Python).
- **STRICTLY FORBIDDEN**: Any `#[test]` or `#[cfg(test)]` block inside `crates/*/src/**/*.rs` (or inline test functions inside Python library modules).
- Note: Any submodule `AGENTS.md` mentioning `src/tests/` is superseded by this workspace-wide rule; always use `crates/<crate>/tests/*.rs`.

## 2. Test-Driven Development (TDD)

Follow **Red → Green → Refactor** for all functional changes and bug fixes:
1. **Red**: Author a failing test in `tests/` encoding the domain contract, security invariant, or bug reproduction *before* changing `src/`.
2. **Green**: Implement the minimal clean fix in `src/`.
3. **Refactor**: Simplify and remove duplication while keeping tests green.

## 3. Specialized Test Coverage Standards

- **Architectural CI Guards**: Cross-crate tier rules (such as `tantra-agent-chat/tests/dependency_rules.rs`) are mandatory CI checks; never disable or weaken them to land a shortcut edge.
- **Property-Based Testing**: Use `proptest` (Rust) and `hypothesis` (Python) for decimal quantization, tick rounding, FIFO lot matching, OMS transitions, and rate-limiter invariants.
- **Golden Vector Testing**: Maintain golden byte/JSON/Arrow fixtures in `tests/` for broker binary protocols, statutory charge contract notes, Rust↔Python FFI parity, and deterministic LLM prompt replay.
- **Security Regression Tests**: Auth middleware, tenant isolation (`/ws/chat`, `/profile`, `/portfolio`), idempotency handling (`POST /orders`), and risk-gate fail-closed behavior must have explicit negative tests.

## 4. Verification Commands by Ecosystem

| Ecosystem | Required Gates Before Completion |
|---|---|
| **Rust workspace** | `cargo fmt --check`, `cargo clippy --all-targets -- -D warnings`, `make check`, `make test`, `make prod` |
| **Rust OOM fallback** | `tantra-runtime-api-rest` full test-bin LTO link can OOM at 15 GiB RAM; if it hits SIGKILL, run `make check` + targeted test binary (`cargo test -p <crate> --test <bin> --profile prod`) and record exact command run |
| **Python packages** | `ruff check .`, `ruff format --check .`, `mypy --strict`, `pytest -v` |
| **PyO3 FFI (`tantra-ffi`)** | `cargo check --workspace --profile prod`, `maturin develop`, `pytest -q` |
| **Web (`vyapaar-ui-web`)** | `npx tsc --noEmit`, `npm run lint`, `npx vitest run`, `npm run build` |
| **Docs (`tantra-docs`)** | `mkdocs build --strict` |
