# OpenCode Tool Mapping

Skills speak in roles — `writer`, `scout`, `reviewer`, `mechanical`. On OpenCode these resolve to the primitives below.

| Role / action the skill requests | OpenCode primitive |
|---|---|
| `writer` — implement a scoped slice | `task` with `subagent_type: "general-purpose"`; use `subagent_type: "writer"` when a writer agent is installed |
| `scout` — read-only investigation | `task` with `subagent_type: "explore"` |
| `reviewer` — read-only review | `task` with `subagent_type: "reviewer"` |
| `mechanical` — mechanically safe edits | `task` with `subagent_type: "general-purpose"` plus a strictly mechanical prompt |
| Parallel dispatch | several `task` calls in one message |
| Wait for results | results return from each `task` call |
| Track tasks | `todowrite` |
| Durable / observable session | a separate terminal/worktree session; no native background subagents |
| Read / search / edit / run a command | `read`, `grep` / `glob`, `edit`, `bash` |
| Invoke a skill | `skill` tool, or read the skill's `SKILL.md` from the skills directory |

## Execution Mechanics

**(a) Plan artifact.** The plan is `openspec/changes/<name>/tasks.md`. Checkboxes in that file are canonical: `- [ ]` while in progress, `- [x]` when complete, with a one-line status note. Mirror the current task in `todowrite` so progress survives context loss; reconcile the todo list back to the plan file at each checkpoint.

**(b) Per-task loop.** Work the plan in order. Execute the bite-sized steps inline by default; dispatch a `writer` only when the task is self-contained enough to isolate. Run every specified verification in the same session that made the change.

**(c) Checkpoints.** At a plan checkpoint, or after each batch when none is marked: stop, read the diff (`git diff`) and the verification output, then dispatch `task` with `subagent_type: "reviewer"` on the changed paths. Report findings before starting the next task. Fix blocking findings first.

**(d) Handoff.** When all items are `- [x]`, invoke the `finishing-a-development-branch` skill and follow it to verify tests, present options, and execute the choice.

**(e) Prefer `orchestrate`.** When the plan's tasks are independent, `orchestrate` gives each task its own isolated worker and review boundary. Use this skill for a single sequential stream.

## Notes
- Trust your actual tool list over this table when they disagree.
- If a primitive is unavailable, fall back to doing the work inline rather than inventing a call.
