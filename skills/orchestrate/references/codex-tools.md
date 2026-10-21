# codex Tool Mapping

The `orchestrate` skill speaks in roles and transports. On codex they resolve to the primitives below. Multi-agent dispatch requires `[features] multi_agent = true` in `~/.codex/config.toml`. Trust your actual tool list over this table when they disagree.

| Role / action the skill requests | codex primitive |
|---|---|
| `writer` — implement one scoped slice | `spawn_agent {fork_turns: "none"}` with a full writer prompt; fix rounds via `followup_task` |
| `scout` — read-only investigation | `spawn_agent {fork_turns: "none"}` with a read-only prompt, or an installed scout role via `agent_type` |
| `reviewer` — read-only review of a slice | `spawn_agent {fork_turns: "none"}` with a review prompt, or an installed reviewer role via `agent_type` |
| `mechanic` — one listed, mechanical fix | `spawn_agent {fork_turns: "none"}` with a mechanical prompt |
| Task batch (3-5 slices) | several `spawn_agent` calls in **one** response |
| Direct / inline work | native file read, search, edit, and shell tools |
| Wait for children | `wait_agent` with a 300000-600000 ms timeout; never short polls |
| Read a child's output | the settled result from `wait_agent`; `followup_task` to continue it |
| Write the dispatch contract | native write to `dispatch/<slice>.md` under the change directory |
| Record supervision state | checkboxes in `tasks.md`; `update_plan` when available; `orchestration.md` edits |
| Run the full suite (N0 only) | native shell, once, over the union of changes |
| Durable / observable transport | Codex App or the local checkout; there are no persistent panes |
| Orca workspace (opt-in) | only when the user asks for it or the work needs its browser/artifacts |
| Handoff to another session | write `tasks.md` + `orchestration.md`, then end the turn |
| Invoke a skill | read the skill's `SKILL.md` from the skills directory |

## Dispatch notes

- **One `writer` per file.** Never spawn two writers on the same file in one batch; they race on edits. Split by file or exported unit.
- **Cold start.** Always pass `fork_turns: "none"` so the child starts blank; supply the slice path and all context in the prompt. A forked child inherits exactly what the skill forbids.
- **Batch shape.** Issue every independent `spawn_agent` in one response; they run concurrently. A call issued in a later response starts a new wave.
- **Fix rounds.** Use `followup_task` on the same agent with the finding quoted. Do not spawn a replacement writer for a small correction.
- **Depth bound.** N1 may spawn a read-only scout or a mechanical agent only. No writer below depth 1.
- **Wait semantics.** Use one long `wait_agent` stretch (300000-600000 ms). It returns as soon as any child settles; short polls waste turns.
- **Verification.** Workers edit and report. The N0 runs the project gates once after integration.
- **No Herdr branch.** codex has no persistent pane control. When the guard `test "${HERDR_ENV:-}" = 1` is false, use the spawn batch or hand off to the local checkout / Codex App.
