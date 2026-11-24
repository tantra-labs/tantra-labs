# 0027 — Live-broker session gateway (singleton per API key) and static egress IP

**Status**: open
**Filed**: 2026-11-23 — workspace design review (root plan 0021) · **Kind**: deployment · **Severity**: high
**Plan**: [0022](../plans/0022-future-deployment-architecture.md)

## What's stubbed or hardcoded

Brokers (Kite, Upstox, Angel) invalidate the prior token on login and require a registered static IP per API key.
Today nothing owns the live session and no outbound client can pin its source address.

- No singleton broker-session gateway or lease: login in a second runtime replica, a Python adapter script or a
  rolling deploy evicts the live session; tokens are in memory; Python `auth.py:262-272` refreshes without a lock.
- The WS ticker gives up after 8 attempts with no supervisor (`tantra-exec` `ticker.rs:317-345`).
- The REST server only has `ExecGateway::default_sim()`; there is no live composition root.
- Static egress: HTTP/WS clients in exec, market feeds, adapters (`common/transport.py`: pooled `http.client`, no
  `proxy_url`/`source_address`), TUI/CLI reqwest clients and the agent LLM client have no bind-address or proxy option.
- Rate limiters (exec token buckets, risk order-rate limiter) are process-local; two processes sharing a key double the rate.

| Repo tracker / evidence | Severity | What it covers |
|---|---|---|
| [exec plan 0004 R4](../../tantra-exec/docs/plans/0004-design-review-2026-11.md) | high | Session lease, supervised ticker, egress config |
| [runtime 0026](../../tantra-runtime/docs/gaps/0026-single-composition-root-serve.md) | high | One composition root wiring real brokers |
| [exec 0005](../../tantra-exec/docs/gaps/0005-durable-order-id-map-and-reconcile.md) | high | In-memory order-id map, no reconcile |
| [risk 0010](../../tantra-risk/docs/gaps/0010-shared-risk-state-and-kill-switch.md) | high | Per-process risk state, unshared kill switch |
| `tantra-adapters/.../common/transport.py`, `auth.py:262-272` | n/a | No proxy/source address; unlocked refresh |

## Why

- A rolling update or a research script using the live key logs the trading session out mid-order; in-flight
  orders lose status and idempotency (see [0010](0010-order-idempotency-end-to-end.md)).
- Cloud and Kubernetes pod egress changes with the node; orders from an unregistered IP are rejected or, worse,
  accepted from an unexpected source. Verify the current SEBI circular and broker notices for the exact rules.

## How to close it

1. `tantra-core` (owner of ports): add a synchronous `SessionLease` port (acquire, renew, release) and shared
   `EgressConfig { bind_addr, proxy_url, no_proxy }` types.
2. `tantra-exec`: implement the lease (Postgres advisory lock or Kubernetes Lease); run the gateway as a singleton
   (`Recreate` strategy); supervise the ticker; apply `EgressConfig` in every HTTP/WS builder; startup egress-IP
   self-check that fails closed in live mode.
3. `tantra-runtime`: single composition root (runtime 0026) wiring the real gateway; other processes call the
   gateway API or use market-data-only keys.
4. `tantra-market`, `tantra-agent`, `tantra-ui`: consume `EgressConfig`. `tantra-adapters`: equivalent
   `proxy_url`/`source_address` in `common/transport.py` and a lock around token refresh.
5. Move rate-limit counters to the gateway (or a leased shared counter) so thresholds are config, never inferred.

**Verification**: two-contender lease test; chaos reconnect test; loopback-proxy integration test asserting the
source address; startup self-check negative test.

## Related

- [0013](0013-risk-gate-single-shared-fail-closed.md), [0023](0023-tamper-evident-audit-trail-unification.md);
  plan 0022 covers the HA and deployment topology.
