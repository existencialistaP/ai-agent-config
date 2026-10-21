# codex Tool Mapping

Skills speak in roles — `writer`, `scout`, `reviewer`, `mechanical`. On codex these resolve to the primitives below.

Multi-agent dispatch requires `[features] multi_agent = true` in `~/.codex/config.toml`.

| Role / action the skill requests | codex primitive |
|---|---|
| `writer` — implement a scoped slice | `spawn_agent {fork_turns: "none"}` with an explicit writer prompt; fix rounds via `followup_task` |
| `scout` — read-only investigation | `spawn_agent {fork_turns: "none"}` with a read-only prompt (or `agent_type` for an installed scout role) |
| `reviewer` — read-only review | `spawn_agent {fork_turns: "none"}` with a review prompt (or `agent_type` for an installed reviewer role) |
| `mechanical` — mechanically safe edits | `spawn_agent {fork_turns: "none"}` with a mechanical prompt |
| Parallel dispatch | several `spawn_agent` calls in one response |
| Wait for results | `wait_agent` in 300000-600000 ms stretches; never short polls |
| Track tasks | checkboxes in `openspec/changes/<name>/tasks.md`; `update_plan` when available |
| Durable / observable session | Codex App, or hand off to the local checkout |
| Read / search / edit / run a command | native file read, search, edit, and shell tools |
| Invoke a skill | read the skill's `SKILL.md` from the skills directory |

## Dispatch and Transport

- **Parallel batch:** issue several `spawn_agent` calls in one response. Always pass `fork_turns: "none"` so the child starts blank and you supply all context in the prompt.
- **Durable transport:** there are no persistent panes. Long-lived or TTY-observed work moves to Codex App or the local checkout; write the state to files before handing off. An Orca workspace is opt-in, never the default.
- **One `writer` per file:** never spawn two writers on the same file in one batch; they race on edits. Split by file or exported unit.
- **Reviewer integration:** after the writers return, spawn a review agent over the combined diff, or fall back to reading the diff inline, then run the suite.
- **Wait semantics:** `wait_agent` with a 300000-600000 ms timeout. Short polls waste turns and usually return nothing; a long stretch returns as soon as any child settles. Use `followup_task` for fix rounds rather than spawning a fresh writer.

## Notes
- Trust your actual tool list over this table when they disagree.
- If a primitive is unavailable, fall back to doing the work inline rather than inventing a call.
