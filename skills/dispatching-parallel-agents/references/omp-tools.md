# omp Tool Mapping

Skills speak in roles — `writer`, `scout`, `reviewer`, `mechanical`. On omp these resolve to the primitives below.

| Role / action the skill requests | omp primitive |
|---|---|
| `writer` — implement a scoped slice | `task` tool, one entry in `tasks[]` with `agent: "writer"`; fall back to `agent: "task"` when the role is unpublished |
| `scout` — read-only investigation | `task` with `agent: "scout"` |
| `reviewer` — read-only review | `task` with `agent: "code-reviewer"` |
| `mechanical` — mechanically safe edits | `task` with `agent: "sonic"` |
| Parallel dispatch | several entries in one `tasks[]` call |
| Wait for results | results auto-deliver; `wait` blocks on jobs you started |
| Track tasks | checkboxes in `openspec/changes/<name>/tasks.md`; no todo tool |
| Durable / observable session | `herdr` skill/CLI panes guarded by `HERDR_ENV=1`; or hand off to a new session. Orca is opt-in only |
| Read / search / edit / run a command | `read`, `grep`/`glob`, `edit`/`write`, `bash` |
| Invoke a skill | `skill://<name>` |

## Dispatch and Transport

- **Parallel batch:** one `task` call with a `tasks[]` array. Every unit in that array starts together; a second `task` call is a second wave. Give each entry its own `name`, a self-contained `task`, and a `solutionSpace` sized to how open the slice is.
- **Durable transport:** start panes with `HERDR_ENV=1` set and give each pane a stable name. Split with `--no-focus` so you keep your current focus. Never close a pane you did not create. An Orca workspace is opt-in, never the default; use it only when the user asks for it or when the work needs its browser/artifacts.
- **One `writer` per file:** never put two writers on the same file in a batch — they will race on edits and one result will be lost. Split by file or by exported unit.
- **Reviewer integration:** after the writers return, pass their diff union to `code-reviewer` before you integrate, then run the suite once.
- **Wait semantics:** child output lands in `agent://<id>` and is delivered to you automatically. Call `wait` only when you are blocked with nothing else to run; never poll.
- **Scout first:** when the cause is unknown, send `scout` entries in the first batch, then convert their findings into named `writer` slices in the next wave.
- **Batch cap:** 3-5 writers per batch; beyond that, integration cost exceeds the parallelism gain.

## Notes
- Trust your actual tool list over this table when they disagree.
- If a primitive is unavailable, fall back to doing the work inline rather than inventing a call.
