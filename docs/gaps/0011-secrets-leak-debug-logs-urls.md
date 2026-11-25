# 0011 — Credentials and tokens leak via Debug, logs and URLs

**Status**: open
**Filed**: 2026-11-23 — workspace design review (root plan 0021) · **Kind**: design-flaw · **Severity**: high
**Plan**: [0021](../plans/0021-workspace-design-review-2026-11.md)

## What's stubbed or hardcoded

Secrets are plain `String`/`str` fields with derived `Debug`/`Serialize` (Rust) or no redaction in `repr`, dumps and exception text (Python). Specific leaks: the market WebSocket client logs the access token embedded in the connection URL; `tantra-runtime-strategy` prints `api_key` and `access_token` through `Debug`; `OpenAiCompatibleProvider` derives `Debug` over a plaintext API key; exec secret types lack `Zeroize`. Credential sourcing still uses legacy `HONBA_*` env names with in-memory sessions only, so there is no vault or file backend and operators fall back to ad-hoc environment dumps.

| Repo tracker | Severity | What it covers |
|---|---|---|
| ~~[tantra-market 0010](../../tantra-market/docs/gaps/README.md#closed-gaps)~~ *(closed 2026-11-25)* | critical | URL/error/Debug redaction, `WsHandshake` token rotation, dead-connection deadline, and resubscribe/snapshot hooks implemented |
| [tantra-exec 0007](../../tantra-exec/docs/gaps/0007-secret-types-redaction-zeroize.md) | high | Secret types derive `Debug`/`Serialize`, no `Zeroize`, plain `String` |
| [tantra-runtime 0028](../../tantra-runtime/docs/gaps/0028-strategy-crate-concrete-executor-and-nested-runtime.md) | high | `Debug` prints `api_key`/`access_token`; also concrete `ZerodhaExecutor` and nested runtime |
| [tantra-market 0016](../../tantra-market/docs/gaps/0016-rest-client-timeouts-and-errors.md) | medium | Snapshot REST clients: per-call client, no timeout, error mapping |
| [tantra-agent 0015](../../tantra-agent/docs/gaps/0015-llm-provider-secret-and-buffers.md) | medium | Provider `Debug` over plaintext API key; unbounded SSE buffers |
| [tantra-adapters 0015](../../tantra-adapters/docs/gaps/0015-credential-redaction.md) | medium | Plain `str` secrets, no redaction in repr/dump/exceptions |
| [tantra-exec 0012](../../tantra-exec/docs/gaps/0012-credential-sourcing-and-legacy-env.md) | medium | Legacy `HONBA_*` env names; no vault/file backend |

## Why

A routine `tracing::debug!("{:?}", config)`, a panic message, a JSON error payload, or a log aggregator capturing the WebSocket URL writes a live broker token to disk and to shared log systems. Tokens grant order placement rights, so a log leak is an account-compromise path. Binding rule: `.agents/rules/security-and-secrets.md` §3.3 (redacted `Debug`, `Zeroize`/`ZeroizeOnDrop`, secrets never logged or echoed in errors).

## How to close it

1. `tantra-exec`: introduce a single `Secret` wrapper (redacted `Debug`, no default `Serialize`, `ZeroizeOnDrop`) and apply it to `BrokerCredentials`/`SessionTokens` (0007).
2. `tantra-market`: send tokens in headers or redact the URL before logging; reuse the shared secret type (0010, 0016).
3. `tantra-runtime`: remove secret `Debug` output; inject executors rather than constructing concrete ones (0028).
4. `tantra-agent`: wrap provider keys in the secret type; bound SSE buffers (0015).
5. `tantra-adapters`: `SecretStr`-style type with redacting `repr`/dump and scrubbed exception text (0015).
6. `tantra-exec`: migrate `HONBA_*` to `TANTRA_*` with a vault/file backend option (0012).
7. Add a log-scan test in each repo that formats every config/credential struct and asserts no secret substring appears.

**Verification**: per-repo `tests/` assert `format!("{:?}", creds)` and Python `repr`/`model_dump` contain `[REDACTED]`; `cargo clippy --all-targets -- -D warnings`; `pytest -q`.

## Related

- Root plan [0021](../plans/0021-workspace-design-review-2026-11.md); related 0019 P0 (honba to tantra renames).
- Other root gaps: [0010](0010-order-idempotency-end-to-end.md), [0017](0017-broker-integration-consolidation.md).
