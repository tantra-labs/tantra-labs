# 0009 — Root plan index rows 0015 / 0016 still say T21.5–T21.6 and T22.6–T22.8 "planned"

**Status**: open

## What's stubbed or hardcoded

[`docs/plans/README.md`](../plans/README.md) shows out-of-date status for two tracks that have
since been implemented:

- **Row 0015** (Track T21) ends with "`T21.5–T21.6` planned". Both are implemented:
  - **T21.5** (`tantra-ui-web`): `OverlayScenePrimitive` (`c0e6575`), scene sub-pane (`73ecd1e`),
    layer pills + Hint inspector + Strategy Loop & Hedge Workbench (`4b5618b`), ChatRail
    "Render on Chart" (`8a1c7c9`). Root commit `737ce45` records "T21.5 complete; plan 0015
    Track T21 fully implemented".
  - **T21.6**: agent plan 0018 (`9925588`, `7ffc079`: `strategy_loop_eval` / `strategy_loop_sweep` /
    `strategy_hedge_recommend` / `chart_scene_annotate` in chat-tools + MCP); runtime in-process
    wiring (`9d69b8c`); docs `strategies/elephant-edge/strategy-loop.md` (`tantra-docs` `cb81295`).
    Root commit `2790fab` records "T21.6 complete (agent 0018)".
- **Row 0016** (Track T22) says "T22.6–T22.8 wiring planned (runtime 0010, agent 0017, ui-web 0017);
  gaps data 0026, strategies 0008". All of these are implemented or closed:
  - runtime plan 0010: `7e33319`, `d17dea8`
  - agent plan 0017: `429c097`, `9984310`
  - ui-web plan 0017 (Indicator Lab): `40b9210`
  - data gap 0026: `82b1fb9` + strategies `9299121`
  - strategies gap 0008: `fe5b170`

The architectural-analysis unification batch in `tantra-strategies` (`268b368` … `e2c6da4`, from
`docs/plans/Here is an architectural analysis of the.md`) has also landed, but no index row
records it.

One T21.5 item is still open: the Playwright interaction tests, tracked as
`tantra-ui-web/docs/gaps/0078-t21-5-playwright-interaction-tests.md`.

## Why

The per-repo plan indexes were updated when each slice landed, but the root index rows weren't.
When this gap was filed (2026-11-21), `docs/plans/README.md` also had uncommitted in-progress
edits (new rows 0017–0019), so it was left untouched.

## How to close it

1. Once the in-progress `docs/plans/README.md` edits are committed, update row 0015 to
   "Implemented 2026-11-21 (T21.1–T21.6)". Cite the commits above and note that ui-web gap 0078
   is still open.
2. Update row 0016 to "Implemented 2026-11-20 (T22.1–T22.8)", with data 0026 and strategies 0008
   closed.
3. Per `.agents/rules/gap-tracking.md` §4, move 0015/0016 to the Implemented section if the
   index has one, and decide whether `docs/plans/Here is an architectural analysis of the.md`
   should be renamed into the numbered scheme or retired now that it's implemented.
4. Close this gap and record it under Closed Gaps.
