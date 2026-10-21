# opencode Tool Mapping

The flow speaks in roles and commands. On opencode they resolve to the primitives below. Trust your actual tool list over this table when they disagree.

| Role / action the flow requests | opencode primitive |
|---|---|
| Interactive planning, `/tospec` with no flag | the published command: `/tospec add rate limiting to the public API` |
| Direct planning, `/tospec --direct` | `/tospec --direct fix the retry counter overflow in client.ts` |
| Approve one artifact section at a time | answer the planning turn; the command asks, you reply, and only then writes that section |
| Read-only code research while planning | `task` with `subagent_type: "explore"`, several calls in one message |
| Create the queue | native write to `queue.md` in the change directory (repo root when there is no change), header `slice \| source \| status \| next`, rows `queued` |
| Pick up a queue slice | native read of `queue.md`, then write that row to `doing` **before** dispatch; `done` or `blocked` after |
| End-of-planning Herdr offer | one question, 3 options, default 3; option 1 needs an explicit yes and a terminal that supports it — otherwise fall back to option 2 or 3 |
| Worker entry via `opsx-apply` | `/opsx-apply rate-limit-api` |
| Worker entry via `feature` | `/feature rate-limit-api` |
| Dispatch a writer | `task` with the default worker agent, or an installed `writer` type when one is present |
| Dispatch a reviewer for a slice | `task` with `subagent_type: "reviewer"` |
| Enforce one writer per file | split the batch by file; two `task` calls targeting one file in the same batch is a contract violation |
| Integrate slices (N0) | the current session: native read/write/edit across the merged slices |
| Run the full suite as N0 | native bash, once, over the union of changes |
| Report N/M | the turn text: `N/M` plus `git diff --stat` and the suite output |
| Blocked slice pause | write the row to `blocked`, stop the batch, ask the user with concrete options |
| Finish / verify | `/finish rate-limit-api` with fresh evidence |
| Archive | `/opsx-archive rate-limit-api` |
| Resume cold from files | native read of `proposal.md`, `design.md`, `tasks.md`, `queue.md` in that order; assume no in-memory state |
| Load the flow-guide skill itself | the skill tool by id: `flow-guide` (or `openspec-propose` when the plan calls for it) |

## Notes

- Transport primitives — batches, background panes, handoff — live in `skills/orchestrate/references/opencode-tools.md`; this file does not restate them.
- Slash commands come from the published config commands in `opencode/commands/*.md`, so the names above work as written.
- A batch is several `task` calls in **one** message. Each call blocks until its child returns, so that return is the wait — keep another slice in flight instead of polling.
- No persistent background panes: there is nothing to open a Herdr worker into. The offer must say option 1 needs a terminal that supports it, and default to option 2 (execute here) or 3 (leave in queue).
- Pickup is event-driven: read `queue.md`, transition the row, dispatch. No daemon or polling; `doing` and `done` rows are never picked up again.
- Plan state is `todowrite` plus edits to `orchestration.md`; a blocked slice pauses the run — do not dispatch past it.
