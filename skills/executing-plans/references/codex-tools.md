# Codex Tool Mapping

Skills speak in roles — `writer`, `scout`, `reviewer`, `mechanical`. On Codex these resolve to the primitives below. Multi-agent tools require `[features] multi_agent = true` in `~/.codex/config.toml`.

| Role / action the skill requests | Codex primitive |
|---|---|
| `writer` — implement a scoped slice | `spawn_agent {fork_turns: "none"}` with an explicit writer prompt; fix rounds via `followup_task` |
| `scout` — read-only investigation | `spawn_agent {fork_turns: "none"}` with a read-only prompt, or `agent_type` for an installed scout role |
| `reviewer` — read-only review | `spawn_agent {fork_turns: "none"}` with a review prompt, or `agent_type` for an installed reviewer role |
| `mechanical` — mechanically safe edits | `spawn_agent {fork_turns: "none"}` with a mechanical prompt |
| Parallel dispatch | several `spawn_agent` calls in one response |
| Wait for results | `wait_agent` in 300000-600000 ms stretches, never short polls |
| Track tasks | checkboxes in `openspec/changes/<name>/tasks.md`; `update_plan` when available |
| Durable / observable session | Codex App, or hand off to the local checkout |
| Read / search / edit / run a command | shell commands and file edits in the current session |
| Invoke a skill | read the skill's `SKILL.md` from the skills directory |

## Execution Mechanics

**(a) Plan artifact.** The plan is `openspec/changes/<name>/tasks.md`. Checkboxes in that file are canonical: `- [ ]` while in progress, `- [x]` when complete, with a one-line status note. When `update_plan` is available, keep it aligned with the file rather than as a second source of truth.

**(b) Per-task loop.** Work the plan in order. Execute the bite-sized steps inline by default; dispatch a writer only when the task is self-contained enough to isolate. Run every specified verification in the same session that made the change.

**(c) Checkpoints.** At a plan checkpoint, or after each batch when none is marked: stop, read the diff (`git diff`) and the verification output, then `spawn_agent {fork_turns: "none"}` with a review prompt on the changed paths. Wait with `wait_agent` in long stretches, then report findings before starting the next task. Fix blocking findings first.

**(d) Handoff.** When all items are `- [x]`, invoke `finishing-a-development-branch` and follow it to verify tests, present options, and execute the choice.

**(e) Prefer `orchestrate`.** When the plan's tasks are independent, `orchestrate` gives each task its own isolated worker and review boundary. Use this skill for a single sequential stream.

## Notes
- Trust your actual tool list over this table when they disagree.
- If a primitive is unavailable, fall back to doing the work inline rather than inventing a call.
