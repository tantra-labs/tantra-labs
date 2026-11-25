# 0010 — End-to-end order idempotency and unknown-outcome handling

**Status**: open
**Filed**: 2026-11-23 — workspace design review (root plan 0021) · **Kind**: design-flaw · **Severity**: critical
**Plan**: [0021](../plans/0021-workspace-design-review-2026-11.md)

## What's stubbed or hardcoded

The client order id that `tantra-core` defines never reaches a broker. Rust executors now carry `OrderTag` and `OutcomeUnknown` (`tantra-exec 0004` closed), while the Python adapters still have no idempotency token or algo tag, strategy `OrderRequest` carries no id (ids are `SIM-n` counters), and the ledger cannot recognise a replayed fill because fills carry no exec id. On top of that, Python retry layers replay non-idempotent POSTs on transport errors and after a 401, and the broker-order-id to client-order-id map is in memory only, so a restart or reconnect cannot reconcile. The result is that a single logical order can be submitted twice and a single fill can be booked twice.

| Repo tracker | Severity | Status | What it covers |
|---|---|---|---|
| [tantra-exec 0004](../../tantra-exec/docs/gaps/README.md#closed-gaps) | critical | **closed (2026-11-25)** | `OrderTag` Base32 wire correlation, `BrokerError::OutcomeUnknown`, `find_by_client_order_id` reconciliation, no SOR failover/breaker trip on ambiguous outcome |
| [tantra-adapters 0008](../../tantra-adapters/docs/gaps/0008-order-idempotency-and-replay.md) | critical | open | No idempotency token or algo tag; POSTs auto-retry and replay on transport error and 401 |
| [tantra-exec 0005](../../tantra-exec/docs/gaps/0005-durable-order-id-map-and-reconcile.md) | high | open | Broker-id to client-id map in memory only; no reconcile on reconnect |
| [tantra-ledger 0017](../../tantra-ledger/docs/gaps/0017-fill-dedup-exec-id.md) | high | open | No exec-id dedupe; duplicate/replayed fills double-counted |
| [tantra-strategies 0010](../../tantra-strategies/docs/gaps/0010-order-request-idempotency-key.md) | high | open | `OrderRequest` has no client order id; `SIM-n` counters |

## Why

Scenario: a strategy places an order, the broker accepts it but the response times out; the router fails over to a second path (or the Python transport retries the POST) and the order is submitted again. The position is now double the intended size, the risk gate saw one order, and when the broker later reports both fills the ledger books both with no way to tell them apart. After a process restart the in-memory id map is gone, so the surviving orders cannot be matched or cancelled. Related rules: `.agents/rules/security-and-secrets.md` §2.3 (unique idempotency keys) and the SEBI algo-tag requirement that every algo order be identifiable.

## How to close it

1. `tantra-core`: make `ClientOrderId` and `AlgoId` the only id types on `OrderRequest`/`FillReport` and add an exec id to `FillReport` (see `tantra-core/docs/plans/0006-design-review-2026-11.md` R3/R5).
2. `tantra-exec`: send the client order id (broker tag / idempotency header) from every executor; introduce an explicit `OutcomeUnknown` result; SOR must query by client id before failing over (`0004`, closed 2026-11-25).
3. `tantra-exec`: persist the broker-id to client-id map and reconcile open orders on reconnect (0005).
4. `tantra-ledger`: dedupe fills by `(broker, exec_id)` before applying (0017).
5. `tantra-adapters`: add idempotency token and algo tag; never auto-retry POSTs; refresh on 401 without replaying order placement (0008).
6. `tantra-strategies`: carry a client order id on `OrderRequest`; generate it at the strategy boundary (0010).
7. Parity: shared golden order-lifecycle vectors (submit, timeout, retry, duplicate fill) run by `tantra-exec`, `tantra-ledger` and `tantra-adapters`.

**Verification**: negative tests in each repo (timeout then retry produces one broker order; duplicate fill leaves position unchanged); `tantra-exec` CI gate `cargo test -p tantra-exec-router --profile prod`; `pytest -q` in adapters/strategies.

## Related

- Root plan [0021](../plans/0021-workspace-design-review-2026-11.md); extends the adapter safeguards of 0019 P2.5.
- Other root gaps: [0013](0013-risk-gate-single-shared-fail-closed.md), [0017](0017-broker-integration-consolidation.md).
