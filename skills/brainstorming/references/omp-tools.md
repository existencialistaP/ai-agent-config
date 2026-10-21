# OMP Tool Mapping

Skills speak in roles — `writer`, `scout`, `reviewer`, `mechanical`. On OMP these resolve to the primitives below.

| Role / action the skill requests | OMP primitive |
|---|---|
| `writer` — implement a scoped slice | `task` tool with an entry in `tasks[]` using `agent: "writer"`; fall back to `agent: "task"` when the writer role is unpublished |
| `scout` — read-only investigation | `task` with `agent: "scout"` |
| `reviewer` — read-only review | `task` with `agent: "code-reviewer"` |
| `mechanical` — mechanically safe edits | `task` with `agent: "sonic"` |
| Parallel dispatch | several entries in one `tasks[]` array — one call, one batch |
| Wait for results | results auto-deliver; `wait` blocks on jobs you started |
| Track tasks | checkboxes in `openspec/changes/<name>/tasks.md`; there is no todo tool |
| Durable / observable session | `herdr` skill or CLI panes guarded by `HERDR_ENV=1`; or hand off to a new session. Orca is opt-in only |
| Read / search / edit / run a command | `read`, `grep`/`find`, `edit`/`write`, `bash` |
| Invoke a skill | read `skill://<name>` |

## This Skill's Artifacts and Gates

- **Design doc.** Write the validated design to `openspec/changes/<name>/design.md` and commit it. That path is the default; a stated user preference overrides it.
- **Approval gate.** Harness-independent. No writer is dispatched, no code is written, and no scaffold is created before the human approves the design — on every path, including spike and bounded.
- **Spec self-review.** Inline by default. Dispatch a `reviewer` only when the human explicitly asks for an independent read; the inline pass is not a reason to spawn anything.
- **Visual companion.** The companion is a local server, so start it with `--open` and hand over the complete URL. If no browser can be opened, render mockups, diagrams, and side-by-side comparisons as text in chat and keep the same per-question visual/text test.
- **Dialogue tracking.** Keep the one-question-at-a-time dialogue in chat. Do not add a checkbox per question to `openspec/changes/<name>/tasks.md`; that file tracks implementation work, not the conversation.

## Notes

- Trust your actual tool list over this table when they disagree.
- If a primitive is unavailable, fall back to doing the work inline rather than inventing a call.
- Writer slices dispatched in one batch must be disjoint; overlapping edits belong to one writer.
- `wait` never polls in a loop — one call returns the first settled job, and results arrive as follow-up messages.
