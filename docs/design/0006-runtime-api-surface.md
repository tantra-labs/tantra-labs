# 0006 — Runtime API Surface: One Versioned, Fail-Closed, Generated Contract

**Status**: Proposed. Review written 2026-11-21; implementation starts next session.
**Scope**: The HTTP + WebSocket surface of `tantra-runtime-api-rest` (`tantra serve`), and every
client of it: `tantra-ui-web` (browser + Next.js BFF), `tantra-ui` (TUI, CLI), `tantra-agent-mcp`,
the Python SDK and examples, and `tantra-docs`.
**Inputs**: a route inventory of `tantra-runtime-api-rest/src/{lib,v1,v2,auth,openapi,library_routes,
market,orders,trade_journal,ws_live}.rs` and a client inventory across the workspace (both
2026-11-21, file:line cited below).
**Related**:
- design 0005 (agent orchestration over ACP; needs derivatives resources);
- agent plan 0019 (ACP; Phase 6 retires `/ws/chat`);
- root plan 0019 P1.1 (body caps) and P1.8 (web off deprecated paths);
- `.agents/rules/security-and-secrets.md`, `architecture-and-coupling.md` §2.5 (versioned contracts).

---

## 1. Where it stands

### 1.1 Shape
- **One router served three times.** `v2::router()` is `v1::router()` merged with a few
  v2-only study routes, wrapped in an envelope rewrite that only sets `api_version`
  (`v2.rs:15-22,78-81`). `lib.rs:328-334` mounts v1 at `/api/v1`, v2 at `/api/v2`, and v1 again
  at `/` (legacy, with a deprecation header).
  - So every route exists at 3 prefixes, and v2 isn't a different contract, just a relabel.
  - There is no bare `/v1/...` prefix. Docs and code saying `/v1/acp` caused today's 404.
- **About 95 routes, many duplicated.** Eleven resources have two paths: positions, trades,
  equity curve, concentration, WAC, ledger, tax, fees, audit, fills, plus `/ws` vs `/ws/market`
  (`v1.rs:209-231,246,311-312`). Studies live at both `/experimental-analysis/*` and
  `/studies/experimental-analysis/*`.
- **Inconsistent style.**
  - Verb paths: `/positions/close`, `/approval/approve|reject`, `/screener/scan`,
    `/strategies/verify`, `/studies/indicators/compute`.
  - Mixed singular and plural: `/tax/report` vs `/orders`.
  - Mixed parameter names: `:order_id` vs `:id` (`v1.rs:231,246`).
  - Naming collision: `/journals/:id` is a run journal, while `/trade-journal/*` is the
    trading diary.
- **The response envelope isn't enforced.** Most handlers go through `market::success`, but
  some return bare JSON (`trade_journal.rs:515,790`). v2 passes unenveloped bodies through
  untouched (`v2.rs:78-81`).
- **Hand-maintained in four places.** The route list (`v1.rs`), the scope table
  (`auth.rs:258-515`), the OpenAPI path list (`openapi.rs`, 2,664 lines) and
  `tantra_runtime_api::ENDPOINTS` are maintained separately, and they have drifted.

### 1.2 Security gaps (fail-open today)
A route with no scope row is **public** by design (`auth.rs:256`). The drift guard checks only
`ENDPOINTS` (`auth.rs:582`), so these routes are **reachable without a token even when auth is
enabled**:

| Route | Risk |
|---|---|
| `GET /ws/live` (`v1.rs:313`, `ws_live.rs:28`) | Accepts `place_order` / `cancel_order` commands, so unauthenticated **paper-order placement** is possible. No `Caller`, no scope. |
| `POST /trade-journal/accounts`, `PATCH /trade-journal/trades/:id`, `POST /trade-journal/notes`, plus all trade-journal GETs (`v1.rs:299-310`) | Unauthenticated writes to user data. No `Caller` scoping either. |
| `GET /market-data/{symbol-profile/:id,calendar,block-deals}` (`v1.rs:184-189`) | Unscoped reads. Low risk, but inconsistent with `/bars` (`read`). |

Also:
- `/ws` and `/ws/market` are public.
- `/ws/chat` sessions are keyed by `?workspace=` and not by `Caller` (`chat.rs:512-521`),
  against the tenant-isolation rule.
- `GET /orders` needs `trade` but `GET /orders/:id/fills` needs `read`.

### 1.3 Clients

| Client | Prefix | Auth | Notes |
|---|---|---|---|
| Web `api-client.ts` (`apiV2Url`) | `/api/v2` | **none**: 0 `Authorization` hits in `src` | Base URL from `NEXT_PUBLIC_TANTRA_RUNTIME_URL`, default `:8000`. Types generated from the **legacy un-prefixed** schema (`api-schema.d.ts`), which has no `/studies/*`. |
| Web BFF `app/api/chat/route.ts:54` | un-prefixed `/ws/chat` | none forwarded | Violates "BFF forwards Authorization". |
| Web experimental-analysis client (`:1456-1526`) | `/api/v2/experimental-analysis/*` | none | Deprecated alias, not `/studies/...`. |
| TUI `market_feed.rs:156` | `/api/v2/bars` | bearer | — |
| TUI `agent_link.rs` | `/api/v1/acp` | bearer | Mixes v1 and v2 within one client. |
| CLI `study_loop.rs`, `scan.rs:251` | v2 / **un-prefixed** | none | — |
| `tantra-agent-mcp` `library_http.rs` | `/api/v2/studies/*` | `TANTRA_RUNTIME_TOKEN` | Reads `TANTRA_RUNTIME_URL` from the env. |
| Python examples `07_run_via_client.py` | un-prefixed `/health` | — | `tantra.client` SDK source is **not in this workspace**. |
| `tantra-docs/docs/api/*` | un-prefixed only | — | No `/api/v*`, `/studies`, `/ws/live` or `/acp`. |

The same endpoint is hand-coded more than once:
- bars: web (3 call sites) and TUI;
- strategy-loop: web, CLI and agent-mcp;
- library: web and agent-mcp;
- screener: web, CLI and the Python SDK.

About half the routes have **no client** at all: orders, portfolio/reports, trade-journal,
backtests/sweeps, approval, `/ws`, `/ws/market` and `/ws/live`.

## 2. Principles (from the overall project picture)

1. **Two front doors, clear roles.**
   - **ACP** (`/api/v2/acp`) is the *agent* interface: natural-language analysis,
     orchestration (design 0005), plan and step summaries. Its tools call runtime services
     **in-process** through ports (like `RuntimeStrategyLoopPort` today), never through REST.
   - **REST + one stream WS** is the *resource* interface: deterministic data and operations
     for UIs, scripts, the Python SDK and out-of-process MCP.
   - A capability lives in one service. REST and the agent tools are two adapters over it.
2. **One live contract: `/api/v2`.** It's always enveloped (`ResponseEnvelope<T>`) and fully
   described by `openapi.v2.json`. `/api/v1` is frozen and then removed. The un-prefixed root
   mount is removed. A path is versioned or it doesn't exist.
3. **Resource-oriented, one path per resource.**
   - Plural nouns, `{id}` parameters, query filters.
   - Actions are explicit sub-resources: `POST /orders/{id}/cancel`, `POST /approvals/{id}/approve`.
   - Expensive computations are `POST` on a named calculator under `/studies/...`.
   - No aliases.
4. **Fail closed by construction.** A route can only be registered together with its scope and
   its OpenAPI operation, through one declaration (a route registry). Unscoped means rejected at
   startup, not public. User-owned resources take `Caller` and are keyed by
   `(caller_id, workspace)`.
5. **Generated clients, not hand-written ones.** `openapi.v2.json` is the source of truth for:
   - the TS client (web);
   - the Rust client (TUI, CLI);
   - the Python SDK models;
   - the docs.

   `tantra-agent-mcp` can't depend on `tantra-runtime-*` (rule R1). It keeps its own adapter
   behind its ports, and a contract test checks it against `openapi.v2.json`.
6. **One configuration source for clients.**
   - Runtime URL and token come from the client config: a `runtime` block in `tantra.jsonc`,
     with `{file:}` for the token, matching the provider-config rule of no LLM-style env vars.
   - The web app keeps `NEXT_PUBLIC_*`, which Next.js requires, but proxies through the BFF and
     forwards `Authorization`.
   - `TANTRA_RUNTIME_URL` and `TANTRA_RUNTIME_TOKEN` (agent-mcp) move to the same config.

## 3. Target resource map (`/api/v2`)

| Domain | Resources (★ = new or changed vs today) |
|---|---|
| system | `GET /health`, `GET /capabilities`, `GET /openapi.json` ★ (replaces `/schema`, `/schema/openapi/*`, `/docs`, `/swagger-ui`, which stay only as a docs UI) |
| instruments | `GET /instruments?kind=&exchange=&underlying=&expiry=` ★ filters, `GET /instruments/{id}`, `GET /instruments/{id}/profile` ★ (was `/market-data/symbol-profile/:id`) |
| market data | `GET /quotes?ids=`, `GET /bars/{id}?tf=&from=&to=&cursor=`, `GET /depth/{id}`, `GET /calendar` ★ (holidays, sessions, F&O expiries), `GET /block-deals` ★ |
| derivatives ★ | `GET /derivatives/expiries?underlying=` and `GET /derivatives/chains/{underlying}?expiry=&strikes=`. Backed by the bhavcopy F&O master (design 0005 §4.2); EOD-labelled `as_of`. |
| orders | `GET/POST /orders` (`Idempotency-Key` header ★ + `client_order_id`), `GET /orders/{id}`, `POST /orders/{id}/cancel` ★ (was `DELETE`), `GET /orders/{id}/fills` |
| portfolio | `GET /portfolio` (summary), `/portfolio/accounts`, `/portfolio/positions`, `/portfolio/holdings`, `/portfolio/trades`, `POST /portfolio/positions/close` ★ |
| reports | `GET /reports/{ledger,tax,fees,wac,concentration,equity-curve,audit,snapshots}` (all the `/ledger`, `/tax/report`, `/fees`, `/portfolio/chart`… aliases removed) |
| user | `GET/PUT /profile`, `/profile/layouts/{name}`, `/profile/modules/{id}`, `GET/POST/DELETE /alerts` ★ (first-class; today alerts hide inside the profile document and chat tools) |
| trade journal | `/trade-journal/{accounts,trades,notes,overview,calendar,compare}`: scoped, `Caller`-keyed, enveloped |
| research | `GET/POST /strategies`, `POST /strategies/verify`, `GET/POST /backtests`, `GET /backtests/{id}`, `/backtests/{id}/{journal,events}`, `GET/POST /sweeps`, `/sweeps/{id}/journal` (top-level `/journals/:id` removed) |
| studies | `/studies/strategy-loop/{evaluate,sweep,recommend-hedge}`, `/studies/library/entries[/{id}]`, `/studies/indicators/compute`, `/studies/signal-study`, `/studies/experimental-analysis/*` (bare `/experimental-analysis/*` removed) |
| screener | `GET /screener/scans?…` ★ (or keep `scan`; see decision §6.3) |
| admin | `GET/PUT /trading-state`, `GET /approvals`, `POST /approvals/{id}/{approve,reject}` ★ |
| streams ★ | `GET /stream` (WS): one authenticated multiplexed socket with `subscribe {channel, ids}` for `quotes`, `bars`, `depth`, `orders`, `fills`, `portfolio`, plus paper `place_order`/`cancel_order` commands gated by the `trade` scope per message. This replaces `/ws`, `/ws/market` and `/ws/live`. |
| agent | `GET /acp` (WS, ACP). `/ws/chat` is retired per agent plan 0019 Phase 6. |

Cross-cutting rules for every route:
- **Envelope** `{api_version, schema_version, data, error, meta}`, enforced by middleware and
  tests; a debug build rejects bare bodies.
- **Errors** use `ErrorCode` with fixed status mapping (validation 422, auth 401/403, not found
  404, conflict 409, rate 429, unavailable 503 with the `PortError::unavailable` gap cite).
- **List endpoints** use cursor pagination: `cursor`, `limit` (default 100, max 1000) and
  `meta.next_cursor`.
- **Body caps** are declared per route: 1 MiB by default, 4 MiB for studies, larger only for
  `POST /bars` ingest.
- **Rate limiting** uses a token bucket per caller per scope (`trade` strict).
- **CORS** comes from config only. `Authorization` is allowed when auth is on.

## 4. Mechanism: a route registry
A single table drives router construction, scope enforcement, OpenAPI paths and the ENDPOINTS
manifest, for example:

```rust
route!(GET  "/bars/{id}",  market::get_bars,  scope = Read,  req = BarsQuery,     resp = BarsResponse);
route!(POST "/orders",     orders::post,      scope = Trade, req = OrdersRequest, resp = OrderAck, body = 64 KiB);
```

With that in place:
- startup fails if any registered route lacks a scope;
- a test walks the registry and asserts an OpenAPI operation exists for each route, and a
  scope row for each;
- `openapi.rs` stops being a 2,664-line hand list. Operations are generated from the
  `schemars` DTOs already in `tantra-runtime-api`.

## 5. Migration (phased; each phase independently shippable)

| Phase | Work | Verify |
|---|---|---|
| **R0 security (do first, small)** | Scope rows: `/ws/live` (`trade`, plus `Caller`), `/trade-journal/*` (`read`/`trade`, plus `Caller` keying), `/market-data/*` (`read`). Flip the default for unscoped routes to **deny**. Extend the drift guard to the real router, not just `ENDPOINTS`. Key `/ws/chat` sessions by `Caller`. Envelope `trade_journal.rs:515,790`. | Negative auth tests per route (401 without a token, 403 with the wrong scope). `auth_scope` drift test fails on an unscoped route. |
| R1 registry | Route registry macro or table; generated OpenAPI ops; envelope-enforcing middleware; per-route body caps; error-status mapping test. | `openapi_conformance` against the registry; a bare-body test fails. |
| R2 canonical v2 | Add the ★ resources (derivatives after design 0005 P2; alerts; approvals; `/stream`). Old paths answer `308` or serve with `Deprecation` + `Link: rel=successor-version`, and their usage is logged. | Per-alias redirect tests; usage counter. |
| R3 clients | Regenerate the web TS types from `openapi.v2.json`. Add a generated Rust client crate (`tantra-runtime-client` in `tantra-runtime`, L3, used by `tantra-ui`). Regenerate the Python SDK models. Add an agent-mcp contract test. Add the client `runtime` config block. Web BFF forwards `Authorization`. | `tsc` + vitest, TUI/CLI tests, SDK tests, MCP contract test. |
| R4 migrate callers | Web experimental-analysis → `/studies/...`; web chat → ACP via the BFF (agent 0019 Phase 4); CLI `scan`; examples; TUI `/acp` → `/api/v2/acp`; docs regenerated from OpenAPI. | Zero hits for un-prefixed or v1 calls (grep gate in CI). |
| R5 remove | Drop the root mount, `/api/v1`, the aliases, `/ws`, `/ws/market`, `/ws/live` and `/ws/chat` after one deprecation window. | Route count drops by about half; all suites green. |

## 6. Open decisions
1. **v1 lifetime.** Freeze now and remove after R4, or keep `/api/v1` permanently as a frozen
   compatibility layer for external scripts.
2. **Python SDK home.** `tantra.client` isn't in this workspace. Bring it into `tantra-ffi`
   (`tantra` wheel) with generated models, or keep it external.
3. **Action-path convention.** `POST /orders/{id}/cancel` (sub-resource verbs, proposed) vs
   `DELETE /orders/{id}`, and `screener/scans` vs `screener/scan`.
4. **Stream protocol.** Plain JSON channel frames (proposed) vs SSE for read-only feeds plus WS
   only for commands.
5. **Client config location.** A `runtime` block in `tantra.jsonc` (proposed, shared with LLM
   config) vs a separate `~/.config/tantra/client.jsonc`.
