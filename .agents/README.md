# `.agents/` — Workspace Governance, Settings & Rules Index

This directory is the **single source of truth** for AI coding agents, subagents, and engineers across `tantra-labs`. Compatibility symlinks `.claude -> .agents`, `.gemini -> .agents`, and per-submodule `<repo>/.agents/rules -> ../../.agents/rules` ensure every tool and repository inherits the same binding standards.

## Directory Layout

```text
.agents/
├── README.md                              # This index & load-order guide
├── AGENTS.md                              # Master instructions & subsystem map (mirrored at /AGENTS.md)
├── HANDOFF.md                             # Active cross-repo handoff state (trimmed per rules/handoff-hygiene.md)
├── settings.json                          # Tool permission allow/deny policy
├── scheduled_tasks.lock                   # Runtime scheduler lockfile (managed by tooling)
├── config/
│   ├── config.json                        # Sandbox & terminal CLI command policy
│   └── project-settings.json              # Machine-readable design, coding, testing, architecture & security settings
├── rules/                                 # Binding rules (inherited by all submodules via ../../.agents/rules)
│   ├── architecture-and-coupling.md       # Tier DAG (L0–L6), cycle bans, UI/REST decoupling
│   ├── interface-first-and-modularity.md  # Trait/Protocol ports, typed errors, Zero-I/O, Zero-Floats, clock injection
│   ├── coding-and-ddd.md                  # Language standards (Rust/Python/TS), aggregates, naming hygiene
│   ├── testing-and-verification.md        # Parallel tests/ rule, TDD, proptest/golden vectors, CI gates
│   ├── scalability-and-concurrency.md     # Bounded channels, async I/O on Tokio, persistence & memory caps
│   ├── security-and-secrets.md            # Fail-closed auth, tenant isolation, idempotency, audited crypto, SQL/eval
│   ├── build-discipline.md                # Canonical `prod` profile invariant
│   ├── gap-tracking.md                    # Plan/gap filing & cleanup lifecycle
│   ├── handoff-hygiene.md                 # `HANDOFF.md` trimming discipline
│   ├── no-recon.md                        # Subagent zero-recon enforcement
│   └── subagent-discipline.md             # Subagent concurrency & self-contained prompt rule
├── checklists/
│   ├── design-review.md                   # Pre-implementation gate for plans, traits & cross-repo changes
│   └── pre-commit-gate.md                 # End-of-turn verification & drift prevention gate
└── skills/
    └── system/run-workflow/SKILL.md       # Workflow orchestration skill
```

## Load Order for Agents

1. **Orientation**: Read `AGENTS.md` (and `<subrepo>/.agents/AGENTS.md` + `HANDOFF.md` if working in a submodule).
2. **Settings**: Consult `config/project-settings.json` for pinned toolchains, tier maps, prohibited patterns, and verification commands.
3. **Binding Rules**: Apply all rules in `rules/` relevant to the layer and language touched.
4. **Gates**: Run `checklists/design-review.md` before structural changes and `checklists/pre-commit-gate.md` before declaring work complete.
