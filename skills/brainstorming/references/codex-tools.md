# Codex Tool Mapping

Requires `[features] multi_agent = true` in `~/.codex/config.toml`. Skills speak in roles — `writer`, `scout`, `reviewer`, `mechanical`. On Codex these resolve to the primitives below.

| Role / action the skill requests | Codex primitive |
|---|---|
| `writer` — implement a scoped slice | `spawn_agent` with `{fork_turns: "none"}` and an explicit writer prompt; fix rounds go back through `followup_task` |
| `scout` — read-only investigation | `spawn_agent` with `{fork_turns: "none"}` and a read-only prompt, or `agent_type` when a scout role is installed |
| `reviewer` — read-only review | `spawn_agent` with `{fork_turns: "none"}` and a review prompt, or `agent_type` when a reviewer role is installed |
| `mechanical` — mechanically safe edits | `spawn_agent` with `{fork_turns: "none"}` and a mechanical prompt |
| Parallel dispatch | several `spawn_agent` calls in one response |
| Wait for results | `wait_agent` in 300000–600000 ms stretches, never short polls |
| Track tasks | checkboxes in `openspec/changes/<name>/tasks.md`; `update_plan` when available |
| Durable / observable session | Codex App, or hand off to the local checkout |
| Read / search / edit / run a command | the shell tool plus the file read/edit tools |
| Invoke a skill | read the skill's `SKILL.md` from the skills directory |

## This Skill's Artifacts and Gates

- **Design doc.** Write the validated design to `openspec/changes/<name>/design.md` and commit it. That path is the default; a stated user preference overrides it.
- **Approval gate.** Harness-independent. No agent is spawned, no code is written, and no scaffold is created before the human approves the design — on every path, including spike and bounded.
- **Spec self-review.** Inline by default. Spawn a `reviewer` only when the human explicitly asks for an independent read; the inline pass is not a reason to spawn an agent.
- **Visual companion.** Codex exposes no artifact viewer. Render mockups, diagrams, and side-by-side comparisons as text in chat, keeping the per-question visual/text test. Codex App cannot serve the companion's interactive screens, so do not pretend it is running.
- **Dialogue tracking.** Keep the one-question-at-a-time dialogue in chat. Do not add questions to `update_plan` or to the `tasks.md` checklist; those track implementation, not the conversation.

## Notes

- Trust your actual tool list over this table when they disagree.
- If a primitive is unavailable, fall back to doing the work inline rather than inventing a call.
- `fork_turns: "none"` keeps a spawned agent from inheriting the conversation; state the slice fully in the prompt.
- Wait in long stretches; short polling wastes rounds and delays the result.
