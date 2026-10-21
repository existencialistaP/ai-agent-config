# codex tools — requesting-code-review

Codex exposes no per-skill tool names. Map the roles to the multi-agent primitives your session provides; trust your actual tool list over this table when they disagree.

| Role | codex primitive |
|------|-----------------|
| writer | `spawn_agent` on an isolated fork with write and execute tools |
| reviewer | `spawn_agent` with the reviewer role file (`agent_type`) and a read-only prompt |
| scout | `spawn_agent` on an isolated fork restricted to read and search |
| mechanical | `spawn_agent` with one mechanical instruction, then collect the result |

## Use in this skill

- Gather `BASE_SHA` / `HEAD_SHA` yourself or with a mechanical child; never let the reviewer guess the range.
- Spawn the reviewer with the filled [code-reviewer.md](../code-reviewer.md) template on an isolated fork (`fork_turns: "none"`). Pass only the description, the plan or `openspec/changes/<name>/tasks.md`, and the SHAs — never your transcript.
- The reviewer is read-only and must not spawn further reviewers. One review seat per slice.
- If the reviewer must understand surrounding code, give it a read-only scout child's output rather than widening its own exploration.
- Collect findings and fix Critical issues before dispatching the next task. Do not review inline: the diff belongs in the reviewer's context, not yours.
- A reviewer child normally finishes in one turn; if it stalls, `followup_task` the same child instead of spawning a second reviewer.
