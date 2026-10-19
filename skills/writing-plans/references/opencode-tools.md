# opencode Tool Mapping

Skills speak in roles — `writer`, `scout`, `reviewer`, `mechanical`. On opencode these resolve to the primitives below.

| Role / action the skill requests | opencode primitive |
|---|---|
| `writer` — implement a scoped slice | `task` with `subagent_type: "general-purpose"`; use `subagent_type: "writer"` when a writer agent is installed |
| `scout` — read-only investigation | `task` with `subagent_type: "explore"` |
| `reviewer` — read-only review | `task` with `subagent_type: "reviewer"` |
| `mechanical` — mechanically safe edits | `task` with `subagent_type: "general-purpose"` plus a strictly mechanical prompt |
| Parallel dispatch | several `task` calls in one message |
| Wait for results | results return from each `task` call |
| Track tasks | `todowrite` |
| Durable / observable session | a separate terminal/worktree session; no native background subagents |
| Read / search / edit / run a command | read, glob, grep, edit, and bash tools |
| Invoke a skill | the `skill` tool or `skill://<name>` |

## Planning and Handoff

- **Plan artifact.** The plan body lives at `openspec/changes/<name>/tasks.md`. There is no separate plan file. `- [ ]` checkboxes in that file are the tracker; `todowrite` mirrors the active items while you execute.
- **Spec travels with the plan.** `openspec/changes/<name>/design.md` sits beside `tasks.md`. Writers read both; the plan argues from the design.
- **One writer per task, reviewer between.** Dispatch one `task` for a single task, then `subagent_type: "reviewer"` over that task's diff before starting the next. Batch independent tasks 3-5 at a time by issuing that many `task` calls in one message; keep dependent tasks serial.
- **Self-review is inline.** The plan author runs the spec-coverage, placeholder, and type-consistency checks directly. Do not delegate this to a writer.
- **Transport.** The plan author stays in the session and issues `task` calls; each writer gets the task text plus the paths to `design.md` and `tasks.md`, never the whole conversation.
- **Fix rounds.** A reviewer rejection goes back as another `task` call quoting the finding and the rejected diff, rather than restating the whole task.
- **Checkpoint cadence.** After each reviewer pass, check off the landed steps in `tasks.md` and update `todowrite` for the next task.
- **Batch bounds.** Three to five `task` calls per message is the working maximum; above that, review latency hides integration errors.

## Notes

- Trust your actual tool list over this table when they disagree.
- If a primitive is unavailable, fall back to doing the work inline rather than inventing a call.
