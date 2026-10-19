# codex tools — test-driven-development

Codex exposes no per-skill tool names. Map the roles to the multi-agent primitives your session provides; trust your actual tool list over this table when they disagree.

| Role | codex primitive |
|------|-----------------|
| writer | `spawn_agent` on an isolated fork with write and execute tools |
| scout | `spawn_agent` on an isolated fork restricted to read and search |
| reviewer | `spawn_agent` with the reviewer role file (`agent_type`) and a read-only prompt |
| mechanical | `spawn_agent` with one mechanical instruction, then collect the result |

## Use in this skill

- The red-green-refactor cycle runs inline in the writer's own context. Watching the test fail is not delegable — if a writer did not see RED, it did not do TDD.
- Spawn an isolated-fork read-only child (`fork_turns: "none"`) to locate existing test utilities and conventions; it returns paths and snippets, not edits.
- A child may run the suite and return raw output, but the writer must read the failure and confirm it is the expected one.
- Spawn a reviewer child with the final diff and this skill's Verification Checklist as the acceptance bar.
- One writer per file: never let two writers touch the same test or production file. Use `followup_task` to continue the existing writer rather than spawning a duplicate.
