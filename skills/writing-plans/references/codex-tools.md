# Codex Tool Mapping

Skills speak in roles — `writer`, `scout`, `reviewer`, `mechanical`. On Codex these resolve to the primitives below. Multi-agent dispatch requires `[features] multi_agent = true` in `~/.codex/config.toml`.

| Role / action the skill requests | Codex primitive |
|---|---|
| `writer` — implement a scoped slice | `spawn_agent {fork_turns: "none"}` with an explicit writer prompt; fix rounds via `followup_task` |
| `scout` — read-only investigation | `spawn_agent {fork_turns: "none"}` with a read-only prompt, or `agent_type` for an installed scout role |
| `reviewer` — read-only review | `spawn_agent {fork_turns: "none"}` with a review prompt, or `agent_type` for an installed reviewer role |
| `mechanical` — mechanically safe edits | `spawn_agent {fork_turns: "none"}` with a mechanical prompt |
| Parallel dispatch | several `spawn_agent` calls in one response |
| Wait for results | `wait_agent` in 300000-600000 ms stretches; never short polls |
| Track tasks | checkboxes in `openspec/changes/<name>/tasks.md`; `update_plan` when available |
| Durable / observable session | Codex App, or a handoff to the local checkout |
| Read / search / edit / run a command | shell, file read, grep, and apply-patch tools |
| Invoke a skill | the skill file path or the skill loader your build exposes |

## Planning and Handoff

- **Plan artifact.** The plan body lives at `openspec/changes/<name>/tasks.md`. There is no separate plan file. `- [ ]` checkboxes in that file are the tracker; keep `update_plan` in sync when the tool is present.
- **Spec travels with the plan.** `openspec/changes/<name>/design.md` sits beside `tasks.md`. Writers read both; the plan argues from the design.
- **One writer per task, reviewer between.** `spawn_agent` one writer for a single task, then a reviewer agent over that task's diff before starting the next. Batch independent tasks 3-5 at a time by spawning them in one response; keep dependent tasks serial.
- **Self-review is inline.** The plan author runs the spec-coverage, placeholder, and type-consistency checks directly. Do not delegate this to a writer.
- **Transport.** The main session stays the plan author and dispatches; each spawned agent gets the task text plus the paths to `design.md` and `tasks.md`, never the whole conversation.
- **Fix rounds.** A reviewer rejection goes back through `followup_task` on the same agent with the finding quoted, rather than spawning a replacement writer.
- **Checkpoint cadence.** After each reviewer pass, check off the landed steps in `tasks.md` and refresh `update_plan`.
- **Batch bounds.** Three to five simultaneous `spawn_agent` calls is the working maximum; wait with `wait_agent`, never a tight loop.

## Notes

- Trust your actual tool list over this table when they disagree.
- If a primitive is unavailable, fall back to doing the work inline rather than inventing a call.
