# omp Tool Mapping

The flow speaks in roles and commands. On omp they resolve to the primitives below. Trust your actual tool list over this table when they disagree.

| Role / action the flow requests | omp primitive |
|---|---|
| Interactive planning, `/tospec` with no flag | the published `tospec` command: `/tospec` |
| Direct planning, `/tospec --direct` | `/tospec --direct` |
| Approve one artifact section at a time | answer the planning turn; the command asks, you reply, it writes that section |
| Read-only code research while planning | `task` entry with `agent: "scout"`, several in one `tasks[]` call |
| Create the queue | `write` to `queue.md` in the change directory (repo root when there is no change), header `slice \| source \| status \| next`, rows `queued` |
| Pick up a queue slice | `read queue.md`, then `edit` that row to `doing` **before** dispatch; `done` or `blocked` after |
| End-of-planning Herdr offer | one question, 3 options, default 3; option 1 only on an explicit yes, behind `test "${HERDR_ENV:-}" = 1` |
| Worker entry via `opsx-apply` | `/opsx-apply <change>` |
| Worker entry via `feature` | `/feature <change or description>` |
| Dispatch a writer | `tasks[]` entry with `agent: "writer"`; fall back to `agent: "task"` when the role is unpublished |
| Dispatch a reviewer for a slice | `tasks[]` entry with `agent: "code-reviewer"` |
| Enforce one writer per file | split `tasks[]` by file; a second writer on the same file is a contract violation |
| Integrate slices (N0) | the current session: `read` / `edit` / `write` across the merged slices |
| Run the full suite as N0 | `bash`, once, over the union of changes |
| Report N/M | write the counts to the turn: `N/M` plus `git diff --stat` and the suite output |
| Blocked slice pause | `edit` the row to `blocked`, stop the wave, ask the user with options |
| Finish / verify | `/finish <change>` with fresh evidence |
| Archive | `/opsx-archive <change>` |
| Resume cold from files | `read` the change directory: `proposal.md`, `design.md`, `tasks.md`, `queue.md`, then continue; no in-memory state is assumed |
| Load the flow-guide skill itself | `read skill://flow-guide` |

## Notes

- Transport primitives — task batches, Herdr CLI, handoff — live in `skills/orchestrate/references/omp-tools.md`; this file does not restate them.
- Slash commands come from the published config commands in `opencode/commands/*.md`, linked into the omp commands dir, so the names above work as written.
- Pickup is event-driven: read the queue, transition the row, dispatch. No daemon or polling; `doing` and `done` rows are never picked up again.
- A blocked slice pauses the run — do not dispatch past it.
- Herdr is opt-in only: `test "${HERDR_ENV:-}" = 1`, and the `herdr` skill for syntax. Offer option 1 never bypasses that guard.
