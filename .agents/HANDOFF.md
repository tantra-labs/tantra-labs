# HANDOFF — vyapaar-labs Bottom-Up Migration Batch (Tier 0 → Tier 6)

**Status: TIER 0 GREEN — `vyapaar-core` migrated with DDD fixes; `cargo fmt --check`, `cargo clippy --all-targets -- -D warnings`, `cargo test` (46/46) all PASS. Pre-flight hygiene complete. Next: Tier 1A `vyapaar-risk` + Tier 1B `vyapaar-ledger` in parallel.**
Date: 2026-11-04 · Workspace: `/home/pmallapp/Devel/Finance/vyapaar-labs` · Source: `/home/pmallapp/Devel/Finance/honba-workspace`
Playbook: `docs/migration-guide.md` (canonical orchestration)

## Phase / Slice Status
| Slice | Milestone | State |
| :---: | :--- | :---: |
| 0 | **Superproject baseline**: git-initialized `vyapaar-labs` superproject (`.gitmodules` sub-repos are plain dirs until their own tiers migrate). Baseline commit of pre-migration skeleton. | ✅ |
| 0 | **Pre-flight hygiene**: `.agents/AGENTS.md` vocabulary — Rust-Core subgraph references now `vyapaar-core/ledger/risk/market/exec/runtime`, Python plane now `vyapaar SDK`; zero `honba*`/`kokoro`/`tamashii` strings remain. | ✅ |
| 0 | **Pre-flight hygiene**: standardized repo-root `Makefile` (`prod`, `release`, `dev`, `check`, `test`, `fmt`, `clippy`, `clean`, plus `debug`/`check-dev` extras) installed in `vyapaar-{core,risk,ledger,market,exec,runtime,agent,ffi,ui}` (renamed from `vyapaar-brain` to `vyapaar-agent` in commit `4674aa5`). | ✅ |
| T0 | **Tier 0 `vyapaar-core`**: port 15 honba-core modules verbatim with honba→vyapaar doc references; NEW `src/ids.rs` (`ClientOrderId`, `AlgoId`, `AccountId`, `TransactionId` promoted from the Domain Heart repository layer with `JsonSchema`); `Exchange::{Nfo,Cds}` unified; `Price::try_new`/`Quantity::try_new` + validated serde visitors rejecting negative wire values; deterministic `OrderRequest::with_id`; `CanonicalPositionSizer` intentionally NOT ported (concrete algorithm leaves the Shared Kernel per master-guide anti-pattern fix); schema/ copied with `honba`→`vyapaar` string pass; tests ported + placeholder `tests/unit_tests.rs` deleted. | ✅ |

## Final Gate Report (from `vyapaar-core/` crate root)
```
1  cargo fmt --check                                  PASS
2  cargo clippy --all-targets -- -D warnings          PASS
3  cargo test                                         PASS (46 tests, 0 failed across 4 suites: 34 core, 6 golden, 4 proptest, 2 schema-compat)
4  grep '#\[cfg(test)\]'/#'e#\[test\]' src/            PASS (0 matches — Parallel Test Directory Rule)
5  grep tokio/std::fs/std::net/Utc::now/Instant src/  PASS (0 matches — Zero-I/O & temporal determinism)
6  grep f32/f64 src/                                  PASS (0 matches — Zero-Floats)
```

## Decisions & Discoveries
- **Git topology**: `vyapaar-labs` is the git superproject (init'd on `main`); `.gitmodules` declares the 15 intended sub-repos but none have their own `.git` yet. Per-tier commits land on the superproject; sub-module extraction is a later concern, not in the Tier 0 scope.
- **Kernel slimming**: tier-0 ports `screener.rs`/`portfolio.rs` as wire contracts and the `ports.rs` trait set, per the detailed tier-0 playbook file map — but the concrete `CanonicalPositionSizer` is dropped from the kernel (master-guide antipattern §1.1); the object-safe `PositionSizer` port remains and the port test uses a local adapter instead.
- **Serde hardening**: `Price`/`Quantity` drop the derive-based `#[serde(transparent)]` in favor of manual `Serialize` (string form) + validating `Deserialize` visitors, so negative decimals can never enter the domain from JSON wire payloads; the `#[serde(transparent)]` attribute is kept so `schemars` emits the same transparent schema as the frozen `schema/domain/domain_schema.json` snapshot.
- **rust_decimal 1.43**: `is_zero()`, `is_sign_negative()` are `const fn`, so `Price::new`/`Quantity::new` remain `const` while gaining `debug_assert!` guards; `try_new` enforces the invariant unconditionally.

## Immediate Next Step
1. Tier 1A (`vyapaar-risk` from `honba-mon`) and Tier 1B (`vyapaar-ledger` from `honba-kokoro`) may now run in parallel — Tier 0 is green.
2. Tier 1A: port `honba-mon/src/{algo_registry,engine,error,limits,metrics,otr,refusal,sizing_gate,state}.rs` into `vyapaar-risk/src/`, swap `honba_core` imports for `vyapaar_core`, thread explicit `now: DateTime<Utc>` through every `RiskEngine` check, port `honba-mon/tests/` into `vyapaar-risk/tests/`.
3. Tier 1B: remove `tokio` from the planned `vyapaar-ledger` workspace, unify `honba-kokoro-oms` on `vyapaar-core` types (delete duplicate `Exchange`/`OrderSide`/`Quantity(u64)` definitions), move `Filled`/`PartiallyFilled` transition onto `filled_quantity` vs `target_quantity`, promote `ClientOrderId`/`AlgoId`/`AccountId`/`TransactionId` imports from `vyapaar_core::ids`, and extract all inline `#[cfg(test)]` blocks and `src/tests/` dirs into `crates/*/tests/`.

## Operating Invariants
- Toolchain: `cargo 1.97.1` / `rustc 1.97.1`; edition 2024, `rust-version = "1.85"`.
- Zero inline `#[test]` / `#[cfg(test)]` in `src/**/*.rs` (Parallel Test Directory Rule, AGENTS.md §3.2).
- `SchemaVersion` stays `8`; schema snapshots are copied + string-replaced, never regenerated in Tier 0.
- Wire compatibility: `Price`/`Quantity` remain string-encoded decimals (`serde-with-str`); `-0.00` parses to `Decimal::ZERO` semantics (not negative-strict), matching upstream rust_decimal behavior.
