# Rule: Subagent Zero-Recon (binding)

**Status**: binding for every spawned subagent in this workspace.
**Created**: 2026-11-01, after back-to-back coder sessions burned 100% of their
step budget on reconnaissance and produced zero-to-two edits despite fully
inlined facts. Complements `.agents/rules/subagent-discipline.md` §2 (that
section binds the *orchestrator* to send self-contained prompts; this rule
binds the *subagent* to not recon anyway).

## The rule

A subagent is dispatched to **write**, not to explore.

1. **Banned reads/actions** (each one of these counts against your ~10-15 step
   budget and is a discipline violation):
   - `ls` / `glob` / dir listings to "orient" or verify a path the prompt already states
   - broad `grep` sweeps for usages, patterns, or examples you were not asked about
   - reading any file other than (a) the exact files you will edit, and (b) at
     most the **2 verification reads** the prompt explicitly budgets
   - re-reading files whose contents the prompt quotes or summarizes
   - reading external/registry crate sources (`~/.cargo/registry/...`,
     vendored trees) to "verify an API name" unless the prompt budgets it
   - re-reading your own finished work to "double-check" before continuing
2. **Orchestrator facts are ground truth**: paths, line numbers, type shapes,
   struct fields, and engine mechanics supplied in the prompt are verified
   facts. Build on them directly.
3. **Missing fact protocol**: the correct failure mode is to stop immediately
   and return one precise question. Do not recon to cover it.
4. **Uncertain API protocol**: if the prompt marks an API as "assumed X; if it
   fails, tighten to Y", write X anyway and let the compiler error decide.
   The compiler is your verifier — one fix loop, not source archaeology.
5. **Step budget**: ~10-15 total = writes (first) + at most 2 budgeted
   verification reads + one verify command pass at the end.
6. **Exceptions**: agents of type *explore/noter/auditor* are reconnaissance
   agents by definition and may recon; they must still return compact facts,
   not start edits.

## Enforcement

- The orchestrator counts your first-move pattern: dispatch → immediate list
  of edits. First reads must map onto prompt-stated edit targets.
- A subagent that recons past step 4 of its budget is either (a) hard-stopped,
  facts salvaged, and resumed via `sessionID` with a write-only prompt, or
  (b) marked for re-dispatch with stricter inlining.
