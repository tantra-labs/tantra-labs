# 0023 — Tamper-evident audit trail unification (exec WAL, runtime audit ledger, risk refusals)

**Status**: open
**Filed**: 2026-11-23 — workspace design review (root plan 0021) · **Kind**: duplication · **Severity**: high
**Plan**: [0021](../plans/0021-workspace-design-review-2026-11.md)

## What's stubbed or hardcoded

Two audit trails exist and only one is tamper-evident; risk refusals and operator actions feed neither reliably.

- `tantra-exec/crates/tantra-exec-audit/src/{hash_chain,journal,entry}.rs`: fsynced hash-chained JSONL segments,
  but the hash does not bind order fields, a torn tail blocks reopen, there is no directory lock, no shipping and no
  retention policy, and it is not wired into any runtime.
- `tantra-runtime-persistence/src/{audit,decisions}.rs`: SQLite-only SEBI audit ledger outside migrations,
  schema-divergent from the WAL, rows editable without detection.
- Operator journal and auth audit are plain NDJSON (not hash-chained); LLM replay WAL is a third, separate chain.
- Ledger aggregates have no event log or snapshots, so there is no canonical event to export; `RiskEngine` state is
  all `pub` and resume has no authorisation or audit record.

| Repo tracker / evidence | Severity | What it covers |
|---|---|---|
| [exec 0009](../../tantra-exec/docs/gaps/0009-audit-wal-integrity.md) | high | WAL hash does not bind order fields; torn tail; not wired |
| [runtime 0033](../../tantra-runtime/docs/gaps/0033-audit-ledger-unification.md) | high | SQLite-only ledger, not tamper-evident |
| [runtime 0025](../../tantra-runtime/docs/gaps/0025-async-purity-auth-sse.md) | medium | Sync file/NDJSON/audit I/O in async paths |
| [ledger 0019](../../tantra-ledger/docs/gaps/0019-event-log-and-snapshots.md) | high | No event log or snapshots to audit |
| [risk 0011](../../tantra-risk/docs/gaps/0011-encapsulated-state-and-operator-audit.md) | medium | Mutable `pub` state; resume not audited |

## Why

- SEBI expects algo order records to be retained and verifiable; verify the current circular for retention periods.
  A DB row that can be edited undetected, or a WAL that cannot be reopened after a crash, fails that purpose.
- Audit answers ("who halted, who resumed, which order, which risk verdict") require one chain, not three.
- Blocking audit writes inside async handlers breach `.agents/rules/scalability-and-concurrency.md` §2.

## How to close it

1. `tantra-core` (owner of the type): define a shared `AuditEntry` with typed kinds (order, risk refusal,
   operator action, approval decision) and a canonical serialisation to hash.
2. `tantra-exec`: fix the WAL (hash binds all order fields, tolerate torn tail, dir lock, rotation and a ship hook);
   expose it as a sink trait.
3. `tantra-runtime`: persistence sink stores chain-linked entries (hash column, verify job) through migrations;
   buffered async writer replaces sync I/O; wire the WAL into the composition root.
4. `tantra-risk`/`tantra-ledger`: emit audit entries for refusals, halts, resumes and fills with explicit timestamps.
5. Ops: periodic anchor hash, ship segments to write-once storage, retention window set from the verified circular;
   `tantra-exec-audit verify` run on a schedule.

**Verification**: tamper-detection tests (edit one row or byte, verify fails); crash-recovery test for the torn
tail; golden vector for entry serialisation shared by Rust and any Python reader; `make check`, `make prod`.

## Related

- Root plan [0022](../plans/0022-future-deployment-architecture.md) (retention and shipping at deployment level).
- [0013](0013-risk-gate-single-shared-fail-closed.md) (risk state sharing) and [0027](0027-live-broker-session-gateway-and-static-egress.md).
- Exec plan [0004](../../tantra-exec/docs/plans/0004-design-review-2026-11.md).
