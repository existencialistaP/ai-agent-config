# codex tools — verification-before-completion

Codex exposes no per-skill tool names. Map the roles to the multi-agent primitives your session provides; trust your actual tool list over this table when they disagree.

| Role | codex primitive |
|------|-----------------|
| writer | `spawn_agent` on an isolated fork with write and execute tools |
| reviewer | `spawn_agent` with the reviewer role file (`agent_type`) and a read-only prompt |
| mechanical | `spawn_agent` with one mechanical instruction, then collect the result |
| scout | `spawn_agent` on an isolated fork restricted to read and search |

## Use in this skill

- The writer that made the change runs the decisive command itself; a claim forwarded from elsewhere is not evidence.
- A child may run long or repetitive verification commands, but its message must carry the raw exit code and output, not a verdict.
- On a delegated slice, spawn a reviewer child to re-run the decisive check independently before accepting the writer's report.
- A read-only child can find which command proves a claim; it returns the command, not a summary.
- Never accept "the writer said it passed" — the gate function applies to delegated work exactly as it applies to your own. If a child reports success, inspect its diff and re-run the check yourself.
