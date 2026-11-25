# 0018 — Lakehouse manifest/ref contract

**Status**: open (snapshot commit contract landed 2026-11-25 via closed `tantra-data` `0027`; ref CAS/lock & cross-language wiring remain)
**Filed**: 2026-11-23 — workspace design review (root plan 0021) · **Kind**: design-flaw · **Severity**: critical
**Plan**: [0021](../plans/0021-workspace-design-review-2026-11.md)

## What's stubbed or hardcoded

Lakehouse v3 (see `../design/0004-data-catalog-lakehouse-layout.md` and [the snapshot commit contract](../../tantra-data/docs/design/lakehouse-v3-snapshot-contract.md)) is written by two independent implementations, Rust (`tantra-market-store` `lakehouse.rs:153`, `manifest.rs`) and Python (`tantra-data` `lakehouse_v3.py`, `manifest_store.py`, `parquet_catalog.py`), with a wheel reader in `tantra-ffi/python/tantra/{store,coverage}.py`. There is no atomic compare-and-swap on refs, no cross-process lock on refs or `catalog.duckdb`, and part naming is TOCTOU. `gc` considers only ref tips with no grace period; CAS reads do not verify content hashes; and manifest promotion evidence is an unchecked prefix string. Canonical JSON and key ordering must be byte-identical across languages for hashes, and inline Decimal wire scale is not pinned.

| Repo tracker | Severity | What it covers |
|---|---|---|
| [tantra-data 0027](../../tantra-data/docs/gaps/README.md#closed-gaps) *(closed 2026-11-25)* | critical | Snapshot-merge commits, `entries_replace_only`, `tantra-catalog repair`, [snapshot contract](../../tantra-data/docs/design/lakehouse-v3-snapshot-contract.md) |
| [tantra-market 0014](../../tantra-market/docs/gaps/0014-lakehouse-writer-ref-cas.md) | high | Two writers, no lock, non-CAS ref update, TOCTOU part naming |
| [tantra-data 0028](../../tantra-data/docs/gaps/0028-ref-cas-and-catalog-locking.md) | high | No CAS or cross-process lock on refs/`catalog.duckdb` |
| [tantra-data 0029](../../tantra-data/docs/gaps/0029-gc-reachability-and-grace.md) | high | `gc` ref-tip-only, no grace, races in-flight writes |
| [tantra-data 0032](../../tantra-data/docs/gaps/0032-cas-read-verification.md) | medium | CAS reads do not verify hash |
| [tantra-strategies 0015](../../tantra-strategies/docs/gaps/0015-promotion-evidence-digest.md) | medium | Promotion evidence is an unchecked prefix string |
| [tantra-core 0010](../../tantra-core/docs/gaps/0010-decimal-wire-scale-pinning.md) | medium | Decimal wire scale not pinned |

## Why

Two concurrent writers (Rust ingest and Python bridge) can overwrite each other's ref update. A manifest hashed by Python and by Rust can differ by key ordering or decimal scale, so promotion evidence stops verifying. Without [0029](../../tantra-data/docs/gaps/0029-gc-reachability-and-grace.md), `gc` deletes objects reachable only from historical commits.

## How to close it

1. Specify the ref-update protocol in `../design/0004-data-catalog-lakehouse-layout.md`: single-writer lock plus atomic CAS on refs, part names allocated atomically, canonical JSON and pinned decimal scale.
2. `tantra-data`: ~~fix the bridge export to build on the parent tree first (closed 0027)~~; next CAS, lock and gc reachability with grace period (0028, 0029); verify content hash on read (0032).
3. `tantra-market`: Rust writer uses the same snapshot, CAS and lock protocol (0014).
4. `tantra-strategies`: promotion evidence is a verified full digest (0015).
5. `tantra-core`: pin Decimal wire scale (0010).
6. Shared byte-compat fixtures: golden manifests and trees written by Rust and read by Python and vice versa, plus a concurrent-writer test.

**Verification**: golden manifest fixtures in both `tantra-market` and `tantra-data` CI; concurrency tests (two writers, gc during write); `pytest -q`; `cargo test -p tantra-market-store --profile prod`.

## Related

- Root plan [0021](../plans/0021-workspace-design-review-2026-11.md); overlaps 0019 P2.3 (Repository protocols only) and design [0004](../design/0004-data-catalog-lakehouse-layout.md).
- Other root gaps: [0014](0014-unified-financial-enums-and-position-model.md), [0019](0019-calendar-instrument-master-corporate-actions-sources.md).
