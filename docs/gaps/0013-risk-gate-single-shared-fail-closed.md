# 0013 — Pre-trade risk gate is not single, shared or fail-closed

**Status**: open
**Filed**: 2026-11-23 — workspace design review (root plan 0021) · **Kind**: design-flaw · **Severity**: critical
**Plan**: [0021](../plans/0021-workspace-design-review-2026-11.md)

## What's stubbed or hardcoded

The risk gate is meant to be the one non-bypassable path for every order. Today it is none of single, shared or fail-closed. Missing reference data (price band, freeze limit, reference price, equity) skips the check instead of rejecting. `Decision::ModifyOrder` bypasses global halt, algo halt, registry and circuit checks. Several independent `RiskEngine` instances exist per process with no shared kill switch or persistence. The risk actor blocks its mailbox awaiting broker acks. The Python `tantra.risk` never reaches the compiled engine, strategies and the live adapter path have their own sizing and no gate, and `propose_trade` lets the model pick the algo id and a session-wide grant bypasses `Decision`/`RiskEngine`. Pre-trade checks are also duplicated: OTR `min_operations` defaults to 20 in `tantra-risk` but 25 in `tantra-exec-router`, with further copies for freeze limits, reduce-only and sizing.

| Repo tracker | Severity | What it covers |
|---|---|---|
| tantra-risk 0006 (closed `9bfb3c2`) | high | Missing reference data fails open — now `FailClosed` by default; runtime loader is tantra-runtime 0039 |
| [tantra-risk 0007](../../tantra-risk/docs/gaps/0007-modify-order-bypasses-halts.md) | high | `ModifyOrder` bypasses halts and circuits |
| [tantra-risk 0010](../../tantra-risk/docs/gaps/0010-shared-risk-state-and-kill-switch.md) | high | Per-process engines; kill switch not shared or persisted |
| [tantra-runtime 0030](../../tantra-runtime/docs/gaps/0030-risk-actor-blocking-broker-ack.md) | high | Risk actor blocks on broker ack |
| [tantra-agent 0012](../../tantra-agent/docs/gaps/0012-propose-trade-untrusted-ai-boundary.md) | high | `propose_trade` bypasses `Decision`/`RiskEngine` |
| [tantra-ffi 0003](../../tantra-ffi/docs/gaps/0003-python-risk-never-uses-native-engine.md) | high | `tantra.risk` never reaches native engine |
| [tantra-ffi 0006](../../tantra-ffi/docs/gaps/0006-python-fallback-parity-vectors.md) | high | Python copies of Rust logic without parity vectors |
| [tantra-strategies 0009](../../tantra-strategies/docs/gaps/0009-live-context-parity.md) | high | LiveContext breaks research/live parity |
| [tantra-adapters 0011](../../tantra-adapters/docs/gaps/0011-live-order-gate.md) | high | Python live order path un-gated |
| [tantra-agent 0019](../../tantra-agent/docs/gaps/0019-fail-closed-approval-gate-and-clock.md) | medium | Scheduler defaults fail open (`PermissiveApprovalGate`) |
| [tantra-strategies 0011](../../tantra-strategies/docs/gaps/0011-sizing-and-helper-duplication.md) | medium | Duplicated sizing and helpers |

## Why

Scenario: the exchange price-band feed is briefly empty at open; the engine skips the band check and an LLM-proposed order at a stale price goes out. Or an operator trips the kill switch on one process while a second `RiskEngine` instance keeps approving. Or a Python script calls the adapter directly and never meets the gate. Binding rules: `.agents/rules/security-and-secrets.md` and the Untrusted AI principle in `.agents/rules/coding-and-ddd.md` §1.4 (all AI output passes `RiskEngine` unconditionally).

## How to close it

1. `tantra-risk`: reject (fail closed) on missing reference data; run halt checks for `ModifyOrder`; single OTR counter, freeze catalog and reduce-only logic (one `min_operations` default) (0006, 0007).
2. `tantra-risk`: shared, persisted state and kill switch behind a port; one engine instance per composition root (0010).
3. `tantra-runtime`: make the broker ack asynchronous so the risk mailbox never blocks (0030); remove duplicated freeze/OTR checks in `tantra-exec-router`, `tantra-exec-slicer`, REST orders and paper MIS.
4. `tantra-ffi`: route `tantra.risk` to the compiled engine; refuse instead of falling back to float Python (0003, 0006).
5. `tantra-agent`: `propose_trade` emits a closed `Decision`; no model-chosen algo id; no blanket session grant; approval gate fails closed (0012, 0019).
6. `tantra-strategies` / `tantra-adapters`: sizing via wheel; live orders refused unless they pass the gate (0009, 0011).
7. Golden vectors for each check (band, freeze, OTR, reduce-only) shared between Rust and the wheel.

**Verification**: negative tests per repo; `tantra-risk` CI `cargo test -p tantra-risk --profile prod`; parity pytest in `tantra-ffi`.

## Related

- Root plan [0021](../plans/0021-workspace-design-review-2026-11.md); overlaps 0019 P4.2 only for analytics, not risk checks.
- Other root gaps: [0010](0010-order-idempotency-end-to-end.md), [0012](0012-fabricated-data-presented-as-real.md).
