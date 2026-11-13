# Rule: Coding Standards, DDD & Hygiene (binding)

**Status: binding for every orchestrator, subagent, and PR across all `tantra-labs` repositories.**

## 1. Domain-Driven Design (DDD)

1. **Ubiquitous Language**: Use canonical `tantra-core` terms everywhere (`InstrumentId`, `ClientOrderId`, `AlgoId`, `Price`, `Quantity`, `Money`, `Currency`, `OrderSide`, `OrderType`, `TimeInForce`, `Decision`, `TaxLot`, `FillReport`). Never propagate raw broker symbols past the Anti-Corruption Layer (ACL).
2. **Rich Domain Aggregates**: Encapsulate invariants and state transitions in aggregate methods (`OrderStateMachine`, `Portfolio`, `RiskEngine`) that return `Result<_, DomainError>`. Reject anemic public-field bags.
3. **Self-Validating Value Objects**: Constructors for `Price`, `Quantity`, `InstrumentId`, and `PriceBand` must validate invariants at creation time.
4. **Untrusted AI Contract**: AI/LLM outputs are untrusted inputs. Always deserialize strictly into closed `tantra_core::Decision` enums (`#[serde(deny_unknown_fields)]`), enforce `allowed_universe` + SEBI algo ID + price collars, and gate every action through `RiskEngine`.

## 2. Language-Specific Standards

### Rust
- **Edition & MSRV**: Edition `2024`, MSRV `1.85`, workspace toolchain `1.97.1`.
- **Lint Parity**: Code must compile cleanly under `cargo fmt --check` and `cargo clippy --all-targets -- -D warnings`.
- **No Panics in Production**: Do not use `.unwrap()` or `.expect()` in production `src/` request/actor paths; propagate typed errors via `thiserror` / `Result`. Recover mutex poisoning cleanly only where documented, preferring async-safe locks.
- **No Unbounded Conversions**: Never convert monetary `Decimal` to `f64` in financial calculations or API order serialization.

### Python (`>= 3.11`)
- **Strict Typing**: All library/adapter code must pass `mypy --strict` (or `pyright`) and `ruff check .` / `ruff format --check .`.
- **Exact Decimals**: Use `decimal.Decimal` constructed from strings/integers (never floats) for financial values.
- **No Dead Shims**: Remove 0-byte or superseded modules (e.g., empty `base.py` leftovers) rather than keeping shadow files.

### TypeScript / Web (`vyapaar-ui-web`)
- **Strict TypeScript**: Must pass `npx tsc --noEmit`, ESLint, `vitest run`, and `npm run build`.
- **Resource Cleanup**: Server API route streams (`ReadableStream`) must implement `cancel()` hooks that abort upstream fetches and close backend WebSockets cleanly.

## 3. Naming & Legacy Hygiene

- **Canonical Brand**: Use `tantra` / `TANTRA_` for crates, packages, JWT issuers, thread names, and environment variables.
- **No New Legacy References**: Do **not** introduce new `honba` / `HONBA_*` or `vyapaar` / `VYAPAAR_*` identifiers, aliases, or env vars. When touching legacy occurrences, migrate or eliminate duplicate paths (e.g., consolidate redundant routers onto `ResilientRouter`).
- **Boy Scout Cleanup**: Delete unused imports, dead stubs, and stale comments when modifying any module.
