# Checklist: Pre-Commit & End-of-Turn Gate

Verify every applicable item before reporting completion, committing, or updating `HANDOFF.md`.

## 1. Static & Structural Checks
- [ ] **No Inline Tests**: `grep -rn "#\[cfg(test)\]" --exclude-dir=target <repo>/crates/*/src/` returns zero hits; all tests live under `tests/` parallel to `src/`.
- [ ] **Zero-Floats Check**: No `f32`/`f64`/`float` introduced in prices, quantities, fees, margins, or risk checks.
- [ ] **Zero-Clock / Zero-I/O Check**: Pure domain crates introduce no `Utc::now`, `SystemTime::now`, `Instant::now`, `std::fs`, or `Runtime::new` / `block_on`.
- [ ] **No Unbounded Channels or Sync Blocking in Async**: No new `mpsc::unbounded_channel`, `axum::body::to_bytes(..., usize::MAX)`, or sync `std::fs` inside async Axum/Tokio handlers.
- [ ] **No Secret / Injection Regressions**: No unredacted secret `Debug` derives, no SQL string formatting, no raw `eval` / template shell interpolation.

## 2. Language Verification Matrix
- **Rust repos**:
  - [ ] `cargo fmt --check`
  - [ ] `cargo clippy --workspace --all-targets --profile prod -- -D warnings`
  - [ ] `cargo check --workspace --profile prod` (or `make check`)
  - [ ] `cargo test --workspace --profile prod` (or `make test`; if `tantra-runtime-api-rest` hits 15 GiB LTO OOM, run `make check` + targeted test binaries and note it)
  - [ ] `make prod` (leaves `target/prod/` fresh)
- **Python repos** (`tantra-strategies`, `tantra-adapters`, `tantra-data`, `tantra-examples`):
  - [ ] `ruff check . && ruff format --check .`
  - [ ] `mypy --strict` (or `pyright`)
  - [ ] `pytest -v`
- **Python FFI (`tantra-ffi`)**:
  - [ ] `cargo check --workspace --profile prod` + `maturin develop --profile prod` + `pytest -q`
- **Web Frontend (`vyapaar-ui-web`)**:
  - [ ] `npx tsc --noEmit && npm run lint && npx vitest run && npm run build`
- **Docs (`tantra-docs`)**:
  - [ ] `mkdocs build --strict`

## 3. Governance Hygiene
- [ ] **Gaps/Plans Cited & Cleaned**: Stubs file a provider `docs/{gaps,plans}/XXXX-*.md` cited in code; completed items removed from active dirs and logged in `README.md`.
- [ ] **HANDOFF Trimmed**: `.agents/HANDOFF.md` reflects current reality with stale/closed items removed in the same edit (`rules/handoff-hygiene.md`).
