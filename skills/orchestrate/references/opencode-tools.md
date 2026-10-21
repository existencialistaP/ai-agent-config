# opencode Tool Mapping

The `orchestrate` skill speaks in roles and transports. On opencode they resolve to the primitives below. Trust your actual tool list over this table when they disagree.

| Role / action the skill requests | opencode primitive |
|---|---|
| `writer` — implement one scoped slice | `task` tool with the default general worker agent; use an installed `writer` type when present |
| `scout` — read-only investigation | `task` with `subagent_type: "explore"` |
| `reviewer` — read-only review of a slice | `task` with `subagent_type: "reviewer"` |
| `mechanic` — one listed, mechanical fix | `task` with the default worker agent and a strictly mechanical prompt |
| Task batch (3-5 slices) | several `task` calls in **one** message; calls split across messages run sequentially |
| Direct / inline work | native read, search, edit, and bash tools |
| Wait for children | a `task` call blocks until its child returns; that return is the wait |
| Read a child's output | the `task` call's returned result |
| Write the dispatch contract | native write to `dispatch/<slice>.md` under the change directory |
| Record supervision state | `todowrite` plus `orchestration.md` edits |
| Run the full suite (N0 only) | native bash, once, over the union of changes |
| Durable / observable transport | a separate terminal or worktree session; there are no background children |
| Orca workspace (opt-in) | only when the user asks for it or the work needs its browser/artifacts |
| Handoff to another session | write `tasks.md` + `orchestration.md`, then end the turn |
| Invoke a skill | load the skill's `SKILL.md` from the skills directory |

## Dispatch notes

- **One `writer` per file.** Two calls targeting the same file in one batch race on edits. Split by file or exported unit.
- **Cold start.** Each `task` prompt must be fully self-contained and point at its `dispatch/<slice>.md`; nothing carries over from the parent session.
- **Batch shape.** Plan the whole batch, then issue every call in one message. Firing one call and idling wastes the parallelism.
- **Fix rounds.** Send a review finding back to the same worker through a follow-up task quoting the finding. Do not replace the worker for a small correction.
- **Depth bound.** N1 may call `explore` only (plus a mechanical task with a listed fix). Never a writer below depth 1.
- **No waiting state.** Because each call blocks, keep a useful slice in flight rather than polling anything.
- **Verification.** Workers edit and report. The N0 runs the project gates once after integration.
- **No Herdr branch.** opencode has no persistent pane control. When the guard `test "${HERDR_ENV:-}" = 1` is false — which it is outside a Herdr-managed pane — use the task batch or a separate terminal/worktree session.
