# 0022 — One canonical OpenAPI document and generated Rust/Python/TS clients

**Status**: open
**Filed**: 2026-11-23 — workspace design review (root plan 0021) · **Kind**: duplication · **Severity**: medium
**Plan**: [0021](../plans/0021-workspace-design-review-2026-11.md)

## What's stubbed or hardcoded

Four committed OpenAPI documents exist and several hand-written clients consume the API in parallel, so the
wire contract has no single source and nothing byte-compares the copies.

- `tantra-runtime/crates/tantra-runtime-api-rest/schema/openapi.v2.json` (should be canonical).
- `tantra-ffi/schema/openapi.json` (independent copy; ffi codegen input).
- `tantra-examples/tantra_examples/provision/openapi.json` (third copy; `provision` server imports undeclared deps).
- `tantra-market/schema/openapi/openapi.json` (fourth copy).
- Clients: `tantra-runtime-client`, `tantra-agent-mcp/src/library_http.rs`, `tantra-tui` reqwest,
  `tantra-ffi/crates/tantra-ffi-codegen/src/lib.rs:161`, plus the TS `src/lib/api-schema.d.ts` in `tantra-ui-web`.
- Inside the runtime itself there are three route inventories (`ENDPOINTS`, `RouteTable`, hand-built OpenAPI).

| Repo tracker / evidence | Severity | What it covers |
|---|---|---|
| [runtime 0023](../../tantra-runtime/docs/gaps/0023-single-route-inventory.md) | medium | Three parallel route inventories and a stale capability manifest |
| [ffi 0004](../../tantra-ffi/docs/gaps/0004-stub-and-codegen-drift-gate.md) | high | Hand-written stub codegen, no drift gate |
| [examples 0011](../../tantra-examples/docs/gaps/0011-provision-server-deps-and-openapi-copy.md) | medium | Third OpenAPI copy, undeclared server deps |
| [docs 0004](../../tantra-docs/docs/gaps/0004-api-reference-provenance.md) | medium | "Generated" API reference is hand-committed |
| `tantra-market/schema/openapi/openapi.json` | n/a | Fourth copy, no owner |

## Why

- A stale copy regenerates wrong Python or TS types; clients then compile against a contract the server no longer serves.
- Two Rust HTTP clients disagree on error mapping, so the same failure is retried by one and surfaced by the other.
- The v2 consolidation in design 0006 is only as good as the one document that describes it.

## How to close it

1. `tantra-runtime` (owner): derive the OpenAPI document from the single route inventory (runtime 0023) and
   publish it as the only committed schema (`openapi.v2.json`); `tantra-market` and `tantra-examples` delete their copies.
2. `tantra-ffi`: codegen reads the runtime document (no local copy); make `tantra-ffi-codegen` output deterministic.
3. `tantra-runtime-client` becomes the only Rust HTTP client; `library_http.rs` and the TUI migrate to it.
4. `tantra-ui-web`: `codegen:api` reads the runtime document; `tantra-docs` API reference is generated from it.
5. CI byte-diff: regenerate and `git diff --exit-code` in runtime, ffi, ui-web (see [0029](0029-generated-artifact-drift.md)).

**Verification**: runtime `tests/openapi_conformance.rs` runs in CI; a consumer test asserts `sha256(openapi)` equals
the pinned hash; Python and TS contract tests exercise one generated client against a running runtime.

## Related

- Design [0006](../design/0006-runtime-api-surface.md) (R3 clients landed; this gap closes the document-copy residue).
- [0029](0029-generated-artifact-drift.md) (drift gates) and ffi plan [0005](../../tantra-ffi/docs/plans/0005-design-review-2026-11.md).
