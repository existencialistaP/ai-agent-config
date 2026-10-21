# codex Tool Mapping

The flow speaks in roles and slash commands; on codex there are no published slash commands, so each command resolves to the skill you load, and each role resolves to a spawned agent or a native tool. Multi-agent dispatch requires `[features] multi_agent = true` in `~/.codex/config.toml`. Trust your actual tool list over this table when they disagree.

| Role / action the flow requests | codex primitive |
|---|---|
| Interactive planning — `/tospec` | Load the `openspec-propose` skill from `~/.codex/skills/openspec-propose/SKILL.md`; ask one question at a time and propose proposal, design, and tasks section by section |
| Direct planning — `/tospec --direct` | Same skill, with a prompt line such as `direct mode: classify once, confirm scope in one line, then write artifacts` — `--direct` is a mode instruction, not a CLI flag |
| Approve each artifact section | Present the section, stop, and take the reply as the approval; never batch sections into one ask |
| Read-only code research during planning | Several `spawn_agent {fork_turns: "none"}` calls in one response with read-only prompts, or native search `grep`, `glob`, `read` |
| Create the queue | Native `write` to `queue.md` (change directory, or repo root) with `slice \| source \| status \| next`; every row starts `queued` |
| Pick up / transition a queue row | `read` `queue.md`, native `edit` the row to `doing` before spawning, then `done` or `blocked` after |
| End-of-planning Herdr offer | One question with options (2) execute here and (3) leave in queue, default 3; state that (1) new-pane worker is unavailable on codex because there are no persistent panes |
| Worker entry — `/opsx-apply <change>` | Load the `openspec-apply-change` skill from `~/.codex/skills/openspec-apply-change/SKILL.md`, then consume `queue.md` |
| Worker entry — `/feature <change or description>` | Load `openspec-apply-change` then `test-driven-development` from `~/.codex/skills/<name>/SKILL.md` |
| Dispatch a writer | `spawn_agent {fork_turns: "none"}` with a self-contained writer brief (slice path, files, acceptance), or `agent_type` when a writer role agent is installed |
| Dispatch a reviewer | `spawn_agent {fork_turns: "none"}` with a read-only review brief quoting the slice diff, or `agent_type` for an installed reviewer |
| Dispatch a scout / mechanic | `spawn_agent {fork_turns: "none"}` with a read-only or mechanical brief; `update_plan` to track state when available |
| Enforce one writer per file | Put file ownership in the queue row and in each brief; never spawn two writers on one file in the same response |
| Integrate slices | N0 reads each settled result, applies or merges the slice edits, and resolves overlaps inline |
| Run the full suite as N0 | Native shell command, once, over the union of the change; keep the output for the report |
| Report N/M + diff stat | Final turn: settle all children with `wait_agent`, run `git diff --stat`, quote the suite output, and state N/M complete |
| Blocked slice pause | `edit` the queue row to `blocked`, stop the slice, and ask with the available options (retry, narrow, skip) |
| Finish / verify — `/finish <change>` | Load `openspec-verify-change` plus `verification-before-completion`; require fresh evidence before declaring done |
| Archive — `/opsx-archive <change>` | Load `openspec-archive-change` from `~/.codex/skills/openspec-archive-change/SKILL.md` |
| Resume cold from files | `read` `queue.md`, `tasks.md`, `proposal.md`, and `design.md` under the change directory; take the first non-`done` row |
| Load the flow-guide skill itself | Read `~/.codex/skills/flow-guide/SKILL.md` (or `skill://flow-guide` where that path is supported) |

## Notes

- Transport (spawn batches, `wait_agent`, `followup_task`, handoff, cold-start rules) lives in `skills/orchestrate/references/codex-tools.md`; this file does not repeat it.
- Use `fork_turns: "none"` on every spawn and put the whole slice brief in the prompt; forked context is not a substitute for the queue row.
- `wait_agent` with a 300000-600000 ms timeout; it returns when any child settles. Fix rounds go to the same agent via `followup_task` with the finding quoted.
- Skills are plain files under `~/.codex/skills/<name>/SKILL.md`; loading one means reading it before acting, not referencing it by name only.
- Herdr only exists behind `test "${HERDR_ENV:-}" = 1` and the `herdr` skill; codex presents no new-pane option regardless of the guard.
- The queue is the only durable pickup mechanism: no daemon, no polling, and a row marked `doing` or `done` is never picked up again.
