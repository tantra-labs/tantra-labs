# 0029 — Generated-artifact drift: duplicate schemas, committed WASM binaries, no regeneration check

**Status**: open
**Filed**: 2026-11-23 — workspace design review (root plan 0021) · **Kind**: duplication · **Severity**: high
**Plan**: [0023](../plans/0023-build-ci-release-engineering.md)

## What's stubbed or hardcoded

Generated files are committed in several repos and no CI step regenerates and compares them.

- Domain schema: `tantra-core/schema/domain/domain_schema.json` and `tantra-ffi/schema/domain_schema.json` already
  differ (`cmp` differs at byte 21); only ffi CI runs `cargo test -p tantra-ffi-codegen`.
- OpenAPI: `tantra-runtime/crates/tantra-runtime-api-rest/schema/openapi.v2.json` and `tantra-ffi/schema/openapi.json`
  are independent copies (see [0022](0022-canonical-openapi-and-generated-clients.md)).
- `tantra-ffi/python/tantra/{_tantra.pyi,__init__.pyi}`: `make codegen` is not followed by `git diff --exit-code`.
- `tantra-ui-web/src/lib/api-schema.d.ts`: the `check:api-contract` script exists but is not run in
  `tantra-ui-web/.github/workflows/ci.yml`.
- WASM: three byte-identical committed copies of `tantra_ui_web_wasm_bg.wasm` (md5 prefix 4ee9e3a03730, about 308 KB each)
  under `public/wasm`, `src/lib/wasm` and `wasm/tantra-ui-web-wasm/pkg`; nothing rebuilds and compares.
- `tantra-ui-web` `test` is `node --test` while AGENTS.md mandates `npx vitest run`.

| Repo tracker / evidence | Severity | What it covers |
|---|---|---|
| core 0004 (closed `tantra-core` `7926c59`) | n/a | Wire-schema evolution gate — `tantra-core` now owns the generated `schema::domain_schema()` + `make schema-check`; `tantra-ffi-codegen` still builds its own copy (item 1 below) |
| [ffi 0004](../../tantra-ffi/docs/gaps/0004-stub-and-codegen-drift-gate.md) | high | Stub codegen and no drift gate |
| [ui-web 0084](../../tantra-ui-web/docs/gaps/0084-ci-gate-coverage.md) | n/a | CI gate coverage (`check:api-contract` missing) |
| `tantra-ui-web/{public/wasm,src/lib/wasm,wasm/tantra-ui-web-wasm/pkg}/*.wasm` | n/a | Three identical binaries |

## Why

- Clients can compile against a schema the server no longer serves; the drift is already present for the domain schema.
- Binary blobs add roughly 308 KB x 3 to history on each rebuild and can diverge from the Rust source.
- The class of failure the v2 API consolidation (design 0006) is meant to prevent returns through stale generated files.

## How to close it

1. `tantra-core` (owner): the single domain schema (with `compatibility/` history); `tantra-ffi` generates from it at
   build and stops committing a copy, or checks a pinned hash.
2. `tantra-runtime`: single OpenAPI per 0022; consumers read it.
3. `tantra-ui-web`: stop committing `.wasm` (build in CI, ship as a release artifact) or keep one canonical copy
   with a hash check; run `check:api-contract` in CI; align `test` with the mandated runner.
4. Root: `make verify-generated` runs `tantra-codegen`, the runtime OpenAPI dump, `codegen:api --check` and the wasm
   build, then `git diff --exit-code`; wire it into the reusable workflow from [0024](0024-no-ci-for-rust-repos.md).
5. Each consumer adds a golden test `schema hash == pinned hash`.

**Verification**: CI job fails on any regeneration diff; seed a one-field change in core and confirm ffi and ui-web
checks fail until regenerated; `cmp` of core and ffi schemas passes.

## Related

- Root plan 0019 P4.6; [0022](0022-canonical-openapi-and-generated-clients.md); [0024](0024-no-ci-for-rust-repos.md).
