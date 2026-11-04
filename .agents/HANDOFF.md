# HANDOFF — vyapaar-labs Bottom-Up Migration Batch (Tier 0 → Tier 6)

**Status: PRE-FLIGHT COMPLETE — AGENTS.md vocabulary unified to `vyapaar-*`, standardized repo-root Makefiles installed across all 9 Rust repositories. Tier 0 (`vyapaar-core`) migration in progress.**
Date: 2026-11-04 · Workspace: `/home/pmallapp/Devel/Finance/vyapaar-labs` · Source: `/home/pmallapp/Devel/Finance/honba-workspace`
Playbook: `docs/migration-guide.md` (canonical orchestration)

## Phase / Slice Status
| Slice | Milestone | State |
| :---: | :--- | :---: |
| 0 | **Superproject baseline**: git-initialized `vyapaar-labs` superproject (`.gitmodules` sub-repos are plain dirs until their own tiers migrate). Baseline commit of pre-migration skeleton. | ✅ |
| 0 | **Pre-flight hygiene**: `.agents/AGENTS.md` vocabulary — Rust-Core subgraph references now `vyapaar-core/ledger/risk/market/exec/runtime`, Python plane now `vyapaar SDK`; zero `honba*`/`kokoro`/`tamashii` strings remain. | ✅ |
| 0 | **Pre-flight hygiene**: standardized repo-root `Makefile` (`prod`, `release`, `dev`, `check`, `test`, `fmt`, `clippy`, `clean`, plus `debug`/`check-dev` extras) installed in `vyapaar-{core,risk,ledger,market,exec,runtime,brain,ffi,ui}`. | ✅ |
| T0 | **Tier 0 `vyapaar-core`**: port 15 honba-core modules verbatim with honba→vyapaar doc references; NEW `src/ids.rs` (`ClientOrderId`, `AlgoId`, `AccountId`, `TransactionId` promoted from the Domain Heart repository layer with `JsonSchema`); `Exchange::{Nfo,Cds}` unified; `Price::try_new`/`Quantity::try_new` + validated serde visitors rejecting negative wire values; deterministic `OrderRequest::with_id`; `CanonicalPositionSizer` intentionally NOT ported (concrete algorithm leaves the Shared Kernel per master-guide anti-pattern fix); schema/ copied with `honba`→`vyapaar` string pass; tests ported + placeholder `tests/unit_tests.rs` deleted. | 🚧 |

## Decisions & Discoveries
- **Git topology**: `vyapaar-labs` is the git superproject (init'd on `main`); `.gitmodules` declares the 15 intended sub-repos but none have their own `.git` yet. Per-tier commits land on the superproject; sub-module extraction is a later concern, not in the Tier 0 scope.
- **Kernel slimming**: tier-0 ports `screener.rs`/`portfolio.rs` as wire contracts and the `ports.rs` trait set, per the detailed tier-0 playbook file map — but the concrete `CanonicalPositionSizer` is dropped from the kernel (master-guide antipattern §1.1); the object-safe `PositionSizer` port remains and the port test uses a local adapter instead.
- **Serde hardening**: `Price`/`Quantity` drop the derive-based `#[serde(transparent)]` in favor of manual `Serialize` (string form) + validating `Deserialize` visitors, so negative decimals can never enter the domain from JSON wire payloads; the `#[serde(transparent)]` attribute is kept so `schemars` emits the same transparent schema as the frozen `schema/domain/domain_schema.json` snapshot.
- **rust_decimal 1.43**: `is_zero()`, `is_sign_negative()` are `const fn`, so `Price::new`/`Quantity::new` remain `const` while gaining `debug_assert!` guards; `try_new` enforces the invariant unconditionally.

## Immediate Next Step
1. Finish Tier 0: write `src/*.rs` (15 modules + `src/ids.rs`), port `tests/{core_tests,golden_test,proptest_invariants,schema_compatibility_test}.rs`, delete placeholder `tests/unit_tests.rs`, extend `Cargo.toml` with honba-core `[profile.*]` + full dependency set.
2. Run the Tier 0 verification gate: `cd vyapaar-core && cargo fmt --check && cargo clippy --all-targets -- -D warnings && cargo test`.
3. Commit Tier 0, then proceed to Tier 1A (`vyapaar-risk` from `honba-mon`) and Tier 1B (`vyapaar-ledger` from `honba-kokoro`) in parallel.

## Operating Invariants
- Toolchain: `cargo 1.97.1` / `rustc 1.97.1`; edition 2024, `rust-version = "1.85"`.
- Zero inline `#[test]` / `#[cfg(test)]` in `src/**/*.rs` (Parallel Test Directory Rule, AGENTS.md §3.2).
- `SchemaVersion` stays `8`; schema snapshots are copied + string-replaced, never regenerated in Tier 0.
- Wire compatibility: `Price`/`Quantity` remain string-encoded decimals (`serde-with-str`); `-0.00` parses to `Decimal::ZERO` semantics (not negative-strict), matching upstream rust_decimal behavior.
