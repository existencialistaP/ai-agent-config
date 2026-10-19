# omp Tool Mapping

Skills speak in roles — `writer`, `scout`, `reviewer`, `mechanical`. On omp these resolve to the primitives below.

| Role / action the skill requests | omp primitive |
|---|---|
| `writer` — implement a scoped slice | `task` entry in `tasks[]` with `agent: "writer"`. Several entries in one call = parallel batch. If `writer` is unpublished, fall back to `agent: "task"`. |
| `scout` — read-only investigation | `task` entry with `agent: "scout"` |
| `reviewer` — read-only review | `task` entry with `agent: "code-reviewer"` |
| `mechanical` — mechanically safe edits | `task` entry with `agent: "sonic"` |
| Parallel dispatch | several entries in one `tasks[]` array |
| Wait for results | results auto-deliver; `wait` blocks on jobs you started |
| Track tasks | checkboxes in `openspec/changes/<name>/tasks.md`; no todo tool |
| Durable / observable session | `herdr` skill/CLI panes guarded by `HERDR_ENV=1`, or a handoff to a new session; Orca is opt-in only |
| Read / search / edit / run a command | file read, grep, edit, and shell tools |
| Invoke a skill | `skill://<name>` |

## Planning and Handoff

- **Plan artifact.** The plan body lives at `openspec/changes/<name>/tasks.md`. There is no separate plan file. `- [ ]` checkboxes in that file are the tracker; mark a step done as the work lands.
- **Spec travels with the plan.** `openspec/changes/<name>/design.md` sits beside `tasks.md`. Writers read both; the plan argues from the design.
- **One writer per task, reviewer between.** Dispatch `agent: "writer"` for a single task, then `agent: "code-reviewer"` over that task's diff before starting the next. Batch independent tasks 3-5 at a time in one `tasks[]` call; keep dependent tasks serial.
- **Self-review is inline.** The plan author runs the spec-coverage, placeholder, and type-consistency checks directly. Do not delegate this to a writer.
- **Transport.** The plan author stays in the main session and dispatches; writers receive the task text plus the paths to `design.md` and `tasks.md`, never the whole conversation.
- **Fix rounds.** A reviewer rejection goes back to the same writer as a follow-up, with the finding quoted, rather than spawning a replacement writer.
- **Checkpoint cadence.** After each reviewer pass, check off the landed steps in `tasks.md` and re-read the design section the next task consumes.
- **Batch bounds.** Three to five parallel writers is the working maximum; above that, review latency hides integration errors.

## Notes

- Trust your actual tool list over this table when they disagree.
- If a primitive is unavailable, fall back to doing the work inline rather than inventing a call.
