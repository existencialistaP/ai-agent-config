# omp tools — test-driven-development

| Role | omp primitive |
|------|---------------|
| writer | `task` batch entry — edits code and runs the test suite |
| scout | `scout` agent (read-only) |
| reviewer | `code-reviewer` agent (read-only) |
| mechanical | `sonic` agent |

## Use in this skill

- The red-green-refactor cycle runs inline in the writer's own context. Watching the test fail is not delegable — if a writer did not see RED, it did not do TDD.
- Dispatch `scout` to locate existing test utilities, fixture conventions, and a nearby working test when the surface is unfamiliar.
- `sonic` may run the suite and return raw output, but the writer must read the failure and confirm it is the expected one.
- Dispatch `code-reviewer` on the final diff and ask it to apply this skill's Verification Checklist: every test names a break, asserts real behavior, and was watched failing.
- One writer per file: never let two writers touch the same test or production file.
