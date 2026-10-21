# codex tools — systematic-debugging

Codex exposes no per-skill tool names. Map the roles to the multi-agent primitives your session provides; trust your actual tool list over this table when they disagree.

| Role | codex primitive |
|------|-----------------|
| writer | `spawn_agent` on an isolated fork with write and execute tools |
| scout | `spawn_agent` on an isolated fork restricted to read and search |
| reviewer | `spawn_agent` with the reviewer role file (`agent_type`) and a read-only prompt |
| mechanical | `spawn_agent` with one mechanical instruction, then collect the result |

## Use in this skill

- **Phase 1 — evidence:** run the reproduction yourself. Spawn an isolated-fork read-only child (`fork_turns: "none"`) for a wide trace; give it the files, the error, and the exact command. Ask for the origin and the failing component boundary, not a fix.
- **Phase 2 — references:** the same read-only child returns the complete reference implementation and its differences from the working code.
- **Mechanical checks:** spawn a child with a single instrumentation or log-collection instruction.
- **Phase 4 — review:** spawn a reviewer child with the git range, the root-cause statement, and the failing-test evidence.
- **Waiting:** while you still have local work, do not wait — the child's answer arrives in your mailbox. When idle, wait once with a long `timeout_ms` (5–10 minutes) instead of polling. Resume the same child with `followup_task` rather than spawning a duplicate.
