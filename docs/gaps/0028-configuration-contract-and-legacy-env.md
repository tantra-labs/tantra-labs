# 0028 — Configuration contract: no central registry; legacy `HONBA_`, `QUANTCEPT_`, `VYAAPAAR_` env names

**Status**: open
**Filed**: 2026-11-23 — workspace design review (root plan 0021) · **Kind**: deployment · **Severity**: medium
**Plan**: [0022](../plans/0022-future-deployment-architecture.md)

## What's stubbed or hardcoded

The config surface is spread across env vars, flags and files with three generations of brand prefixes and no
registry. Distinct env names in `src`: 16 `TANTRA_`, 2 `HONBA_`, 1 `QUANTCEPT_`, 5 `VYAAPAAR_`, 1 `NEXT_PUBLIC_`.

- `HONBA_ENV` and `HONBA_SEBI_COMPLIANCE` (`tantra-agent/crates/tantra-agent-mcp/src/frontier.rs`): a compliance
  switch under a retired brand.
- `QUANTCEPT_LOG_LEVEL` (`tantra-cli/src/args.rs`): third brand, alias of `TANTRA_LOG_LEVEL`.
- `VYAAPAAR_SIM_BACKEND` (`tantra-ffi/python/tantra/backtest/simulated.py`), `VYAAPAAR_EXAMPLES_ALLOW_LIVE_ORDERS`,
  `VYAAPAAR_LOG_EVENTS`, `VYAAPAAR_STRATEGIES_DIR`.
- `TANTRA_DATA_DIR` is read independently in Python (`mutual_funds.py:126`) and Rust (`runtime-backtest/calendar.rs`).
- State locations come from three mechanisms (`TANTRA_HOME`, `TANTRA_JOBS_PATH`, positional `data_dir`); defaults are
  cwd-relative (`data/journals`, `data/profiles`, `data/portfolios`).
- No env contract for JWT secret/RSA key, broker credentials, bind address, CORS, OTLP endpoint or `RUST_LOG`.
- `NEXT_PUBLIC_TANTRA_RUNTIME_URL` is baked into the web build; adapters are TOML-only without an env overlay.

| Repo tracker / evidence | Severity | What it covers |
|---|---|---|
| [exec 0012](../../tantra-exec/docs/gaps/0012-credential-sourcing-and-legacy-env.md) | medium | Legacy `HONBA_*` credential env names, no vault/file backend |
| [ffi plan 0005 R2](../../tantra-ffi/docs/plans/0005-design-review-2026-11.md) | medium | Wheel-side env and config handling |
| `tantra-agent/crates/tantra-agent-mcp/src/frontier.rs` | n/a | `HONBA_SEBI_COMPLIANCE`, `HONBA_ENV` |
| `tantra-cli/src/args.rs` | n/a | `QUANTCEPT_LOG_LEVEL` |

## Why

- A compliance toggle with a retired brand is easy to miss in a container environment; operators cannot enumerate
  what they must set.
- Naming rule: `.agents/rules/coding-and-ddd.md` §3 forbids new `honba`/`vyapaar` identifiers and requires migrating
  legacy ones.
- Without a single settings object, the same setting resolves differently per process (cwd-relative paths, duplicate readers).

## How to close it

1. `tantra-core` (owner): central env/setting registry (names, type, default, secret flag) and a naming convention;
   generate `docs/config-reference.md` from it.
2. Each repo renames its legacy variables with a deprecation shim (read old name, warn once, then delete):
   agent-mcp, tantra-ui, ffi, examples, exec (exec 0012).
3. Add `TANTRA_*` env overlays to adapters and data; one reader per setting shared through the wheel for Python.
4. Runtime/ui: make data and state dirs absolute and configurable from one root; document bind, CORS, JWT and OTLP settings.
5. Web: runtime URL resolved at request time, not build time.
6. CI rg-guard rejecting any new non-`TANTRA_` env name.

**Verification**: guard test in `make verify-architecture` (0019 P4.6); a test that every registry entry is
documented; deprecation-shim tests asserting old and new names resolve identically.

## Related

- Plan 0019 P0 honba-to-tantra renames (source symbols); this gap covers env/runtime config contract.
- [0027](0027-live-broker-session-gateway-and-static-egress.md), [0011](0011-secrets-leak-debug-logs-urls.md).
