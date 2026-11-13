# Rule: Security, Auth & Secrets Hygiene (binding)

**Status: binding for every orchestrator, subagent, and PR across all `tantra-labs` repositories.**

## 1. Fail-Closed Authentication & Transport

1. **Enforce Auth for EVERY Enabled Credential Mode**:
   - Auth middleware MUST be mounted whenever **any** auth mechanism is configured (`tokens_file` OR `jwt_secret` OR `jwt_rsa_key` — `config.auth.is_enabled()`). Never gate `auth_middleware` solely on `tokens_file`.
2. **Fail Closed on Non-Loopback Binds**:
   - Binding HTTP/WS servers to non-loopback addresses (`0.0.0.0`, external IPs) without auth configured MUST fail startup unless an explicit, auditable insecure override flag is passed.
3. **CORS Correctness**:
   - Never allow wildcard `*` origins on authenticated APIs; when auth is enabled, explicitly include `AUTHORIZATION` alongside `CONTENT_TYPE` in allowed CORS headers.
4. **Trusted Proxy Headers**:
   - Never trust `X-Forwarded-For` / `Forwarded` headers for IP rate-limiting or audit logs unless the peer IP belongs to a configured trusted-proxy CIDR allowlist.

## 2. Tenant Isolation & Idempotency

1. **Bind Sessions to Authenticated `Caller`**:
   - Every user-scoped route (`/profile`, `/portfolio`, `/ws/chat`, `/orders`, `/alerts`) MUST extract `Caller` (or `TokenInfo`) and namespace sessions/documents by `(caller_id, workspace/resource)`. Never key shared sessions or documents solely off unvalidated query parameters (`?workspace=`).
2. **Proxy Auth Propagation**:
   - BFF / Next.js routes (`/api/chat`, etc.) must forward the authenticated `Authorization` header (or signed session token) to backend REST/WS endpoints.
3. **Unique Order Idempotency Keys**:
   - Never substitute a constant string (e.g., `"rest"`) when `client_order_id` is omitted. Generate a unique UUID per keyless order placement, or reject missing idempotency keys on `POST /orders`.

## 3. Cryptography & Secret Handling

1. **No Custom Crypto**: Never hand-roll SHA-1, SHA-256, HMAC, or constant-time comparisons. Always use audited crates (`sha2`, `hmac`, `subtle::ConstantTimeEq`, `jsonwebtoken`).
2. **Strict JWT Validation**: Enable `jsonwebtoken::Validation` checks (`validate_exp`, `validate_nbf`, `validate_aud`, `iss`, bounded `leeway`) — never disable standard claim validation.
3. **Secret Memory & Logging Hygiene**:
   - Structs holding credentials, API secrets, passwords, TOTP seeds, or session tokens (`BrokerCredentials`, `SessionTokens`) MUST implement manual redacted `Debug` (`[REDACTED]`), skip/protect serialization of secrets by default, and derive `Zeroize` / `ZeroizeOnDrop`.
   - Secrets originate from environment variables, OS keyrings, or secret managers — never logged, committed, or echoed in error payloads.

## 4. Input, SQL, Code-Gen & Execution Safety

1. **Parameterized SQL Only**: Always pass query inputs via bind parameters (`$1` in SQLx/Postgres, `?` in SQLite/DuckDB). Never interpolate user input or path strings into SQL strings (including `read_parquet('...')`).
2. **No `eval` / Code-Gen Interpolation**: Replace expression evaluators with pure AST interpreters (no `eval()`), and never interpolate untrusted prompts into generated Python/shell source strings.
3. **MCP & HTTP Hardening**: Enforce explicit HTTP timeouts (`reqwest::Client::builder().timeout(...)`), TLS verification (never disable cert checks in non-test builds), and bounded payload sizes on MCP/SSE/JSON-RPC transports.
