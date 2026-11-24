# 0026 — Licensing: no LICENSE files, mixed declared licences, third-party attribution

**Status**: open
**Filed**: 2026-11-23 — workspace design review (root plan 0021) · **Kind**: deployment · **Severity**: medium
**Plan**: [0023](../plans/0023-build-ci-release-engineering.md)

## What's stubbed or hardcoded

This is a non-commercial project. Non-commercial third-party licences are acceptable with attribution (decision
2026-11-20); the goal here is accurate, consistent labelling and proper attribution, not a commercial gate.

- No LICENSE or COPYING file exists in any of the 15 repos, so GitHub shows default all-rights-reserved.
- Declared licences are inconsistent: Rust crates and the `tantra` wheel (`tantra-ffi/pyproject.toml`
  `license = { text = "AGPL-3.0" }`) declare AGPL-3.0; adapters, data, examples and strategies declare `MIT`
  (`tantra-adapters/pyproject.toml:11`); `tantra-docs` and `tantra-ui-web` declare none.
- `tantra-adapters` depends on the AGPL wheel (`tantra>=0.1.0`).
- `tantra-strategies` library carries ideas derived from third-party indicators (some under CC BY-NC-SA);
  provenance and licence are optional free text.
- No `THIRD_PARTY_NOTICES`, no `NOTICE`, no SPDX headers, no dependency licence scanning.

| Repo tracker / evidence | Severity | What it covers |
|---|---|---|
| [strategies 0014](../../tantra-strategies/docs/gaps/0014-library-provenance-and-licensing.md) | medium | Provenance/licence free text; no LICENSE |
| `tantra-ffi/pyproject.toml` | n/a | AGPL-3.0 declaration |
| `tantra-adapters/pyproject.toml:11` | n/a | MIT declaration alongside AGPL dependency |

## Why

- Without a LICENSE file, others have no stated permission even for the intended non-commercial use.
- An MIT-labelled package that imports an AGPL extension is misleading about its effective terms when distributed.
- Share-alike and non-commercial components need clear attribution and labelling so users can see what applies to
  which part.

## How to close it

1. Decide one outbound licence for the SDK and one for services; record it in a root `docs/` note.
2. Add `LICENSE` and SPDX `license-files` / headers to every repo; align `pyproject.toml`, `Cargo.toml` and
   `package.json` licence fields.
3. Add `THIRD_PARTY_NOTICES.md` per repo and a root `NOTICE` crediting third-party indicator sources with their
   licence text; label non-commercial-licensed components clearly (for example a separate package or a `LICENSE-NC` note).
4. `tantra-strategies`: make provenance and licence required library manifest fields (strategies 0014).
5. CI: `cargo-deny` licence allow-list, `pip-licenses`, `license-checker` (npm), publishing the report as an artifact.

**Verification**: CI fails when a dependency licence is outside the allow-list or when a repo lacks LICENSE;
manifest schema test rejects library entries without provenance.

## Related

- Plan [0023](../plans/0023-build-ci-release-engineering.md) (licensing and SBOM); [0016](0016-indicator-golden-parity-suite.md)
  (indicator provenance).
