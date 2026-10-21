# omp tools — verification-before-completion

| Role | omp primitive |
|------|---------------|
| writer | `task` batch entry — the role that must produce the fresh evidence |
| reviewer | `code-reviewer` agent (read-only) |
| mechanical | `sonic` agent |
| scout | `scout` agent (read-only) |

## Use in this skill

- The writer that made the change runs the decisive command itself; a claim forwarded from elsewhere is not evidence.
- `sonic` may run long or repetitive verification commands, but it must return the raw exit code and output, not a verdict.
- On a delegated slice, dispatch `code-reviewer` to re-run the decisive check independently before accepting the writer's report. A report whose diff is clean but whose command was never run does not pass.
- `scout` finds which command actually proves a claim when the project has no documented one; it returns the command, not a summary.
- Never accept "the writer said it passed" — the gate function applies to delegated work exactly as it applies to your own.
