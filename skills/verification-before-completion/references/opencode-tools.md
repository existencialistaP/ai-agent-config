# opencode tools — verification-before-completion

| Role | opencode primitive |
|------|--------------------|
| writer | `task` subagent with the general-purpose agent — the role that must produce the fresh evidence |
| reviewer | `reviewer` subagent (read-only) |
| mechanical | `task` subagent with a narrowly scoped, mechanical prompt |
| scout | `explore` subagent (read-only) |

## Use in this skill

- The writer that made the change runs the decisive command itself; a claim forwarded from elsewhere is not evidence.
- A scoped `task` subagent may run long or repetitive verification commands, but it must return the raw exit code and output, not a verdict.
- On a delegated slice, dispatch `reviewer` to re-run the decisive check independently before accepting the writer's report.
- `explore` finds which command actually proves a claim when the project has no documented one; it returns the command, not a summary.
- Never accept "the writer said it passed" — the gate function applies to delegated work exactly as it applies to your own.
