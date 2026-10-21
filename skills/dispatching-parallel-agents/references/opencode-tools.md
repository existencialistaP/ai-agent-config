# opencode Tool Mapping

Skills speak in roles — `writer`, `scout`, `reviewer`, `mechanical`. On opencode these resolve to the primitives below.

| Role / action the skill requests | opencode primitive |
|---|---|
| `writer` — implement a scoped slice | `task` with `subagent_type: "general-purpose"`; use `subagent_type: "writer"` when a writer agent is installed |
| `scout` — read-only investigation | `task` with `subagent_type: "explore"` |
| `reviewer` — read-only review | `task` with `subagent_type: "reviewer"` |
| `mechanical` — mechanically safe edits | `task` with `subagent_type: "general-purpose"` plus a strictly mechanical prompt |
| Parallel dispatch | several `task` calls in one message |
| Wait for results | each `task` call returns its result |
| Track tasks | `todowrite` |
| Durable / observable session | a separate terminal/worktree session; no native background subagents |
| Read / search / edit / run a command | native file read, search, edit, and bash tools |
| Invoke a skill | load the skill's `SKILL.md` from the skills directory |

## Dispatch and Transport

- **Parallel batch:** send several `task` calls in one message. Calls split across messages run sequentially, so plan the whole batch before you send it.
- **Durable transport:** opencode has no background subagents. Long-lived or TTY-observed work goes to a separate terminal or worktree session; record the state in files before you leave. An Orca workspace is opt-in, never the default.
- **One `writer` per file:** never target the same file from two `task` calls in one batch; they race on edits. Split by file or exported unit.
- **Reviewer integration:** after the writers return, send the combined diff to a `subagent_type: "reviewer"` task, apply or skip its findings explicitly, then run the suite.
- **Wait semantics:** a `task` call blocks until its child finishes, so "wait" is just the return of the call. Batch calls together rather than firing one and idling.
- **Scout first:** when the cause is unknown, send `subagent_type: "explore"` calls in the first message, then turn their findings into named writer tasks in the next.
- **Batch cap:** 3-5 tasks per message; beyond that, integration cost exceeds the parallelism gain.

## Notes
- Trust your actual tool list over this table when they disagree.
- If a primitive is unavailable, fall back to doing the work inline rather than inventing a call.
