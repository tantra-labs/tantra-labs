# Rule: Subagent Discipline (OpenCode)

**Status: binding for every orchestrator/parent session and every spawned subagent in this workspace.**

## 1. Concurrency cap — utmost 2 subagents at any point of time
- At most **2 subagent sessions may be alive simultaneously** in a workspace.
- A wave of exactly 2 is the maximum fan-out: dispatch wave → collect/verify → only then dispatch the next wave.
- Sequential execution (0 or 1 live subagent) is always acceptable and preferred whenever the two tracks would touch the same files.

## 2. Zero recon — all context is sent by the orchestrator
- A subagent prompt must be **self-contained**: it carries the exact file paths to read/edit, every API signature and type shape the task needs (quoted, verified), the design decisions, environment facts (tool commands, verify commands, known warnings), and the allowed scope boundary.
- Subagents must **not** spend steps discovering the codebase. Discovery reads cost the session budget and starve the write phase — this has failed in practice (wave-1 agents exhausted their step budget on reconnaissance and produced zero edits).
- If a subagent is missing a fact the prompt did not provide, it must **stop and return immediately** with the precise question instead of reconning.
- Read load on a subagent: at most the files it will *edit* (and copies of its own target files); anything else must be inlined by the orchestrator.

## 3. Write-first budget
- Or when resuming via `sessionID`, resume prompts say "execute" and the remaining-work list: no re-reading what was already verified.
- A subagent's expected step budget: ~10–15 steps (writes + one verify loop). Verify commands belong **at the end**, once, not after every file.

## 4. Context preservation
- A subagent whose reconnaissance exceeded its step budget must be resumed with `sessionID` (context preserved), not restarted from scratch with a redundant prompt.
- The orchestrator stores the verified API facts surfaced by reconnaissance and inlines them into every later prompt of the same batch.

## 5. Orchestrator obligations
- Before dispatching: prepare the dispatch plan, split scopes so the two tracks **cannot edit the same file**, and inline shared context into both prompts.
- After each wave: sanity-check the diff (`git diff --stat`, spot reads), run the aggregate verification (`cargo check/clippy/test` at the stated workspace), and only then commit.
