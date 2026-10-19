# OMP Tool Mapping

Skills speak in roles — `writer`, `scout`, `reviewer`, `mechanical`. On OMP these resolve to the primitives below.

| Role / action the skill requests | OMP primitive |
|---|---|
| `writer` — implement a scoped slice | `task` tool, an entry in `tasks[]` with `agent: "writer"`; fall back to `agent: "task"` when the role is unpublished |
| `scout` — read-only investigation | `task` with `agent: "scout"` |
| `reviewer` — read-only review | `task` with `agent: "code-reviewer"` |
| `mechanical` — mechanically safe edits | `task` with `agent: "sonic"` |
| Parallel dispatch | several `tasks[]` entries in one call |
| Wait for results | results auto-deliver; `wait` blocks on jobs you started |
| Track tasks | checkboxes in `openspec/changes/<name>/tasks.md`; no todo tool |
| Durable / observable session | `herdr` skill/CLI panes guarded by `HERDR_ENV=1`; or hand off to a new session. Orca is opt-in only. |
| Read / search / edit / run a command | `read`, `grep` / `glob`, `edit`, `bash` |
| Invoke a skill | `skill://<name>` |

## Execution Mechanics

**(a) Plan artifact.** The plan is `openspec/changes/<name>/tasks.md`. Each item is a checkbox. Track state only there: `- [ ]` while in progress, `- [x]` when complete, plus a one-line status note beside the item.

**(b) Per-task loop.** Work the plan in order. Execute the bite-sized steps inline by default; dispatch a `writer` only when the task is self-contained enough to isolate. Run every specified verification in the same session that made the change.

**(c) Checkpoints.** At a plan checkpoint, or after each batch when none is marked: stop, read the diff (`bash` with `git diff`) and the verification output, then dispatch `task` with `agent: "code-reviewer"` on the changed paths. Report findings before starting the next task. Fix blocking findings first.

**(d) Handoff.** When all items are `- [x]`, invoke `skill://finishing-a-development-branch` and follow it to verify tests, present options, and execute the choice.

**(e) Prefer `orchestrate`.** When the plan's tasks are independent, `orchestrate` gives each task its own isolated worker and review boundary. Use this skill for a single sequential stream.

## Notes
- Trust your actual tool list over this table when they disagree.
- If a primitive is unavailable, fall back to doing the work inline rather than inventing a call.
