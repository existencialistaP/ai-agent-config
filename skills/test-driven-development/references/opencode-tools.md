# opencode tools — test-driven-development

| Role | opencode primitive |
|------|--------------------|
| writer | `task` subagent with the general-purpose agent — edits code and runs tests |
| scout | `explore` subagent (read-only) |
| reviewer | `reviewer` subagent (read-only) |
| mechanical | `task` subagent with a narrowly scoped, mechanical prompt |

## Use in this skill

- The red-green-refactor cycle runs inline in the writer's own context. Watching the test fail is not delegable — if a writer did not see RED, it did not do TDD.
- Dispatch `explore` to locate existing test utilities, fixture conventions, and nearby working tests.
- A scoped `task` subagent may run the suite and return raw output, but the writer must confirm the failure is the expected one.
- Dispatch `reviewer` on the final diff with this skill's Verification Checklist as the acceptance bar.
- One writer per file: never let two writers touch the same test or production file.
