# omp tools — requesting-code-review

| Role | omp primitive |
|------|---------------|
| writer | `task` batch entry — produces the change and hands over the range |
| reviewer | `code-reviewer` agent (read-only) |
| scout | `scout` agent (read-only) |
| mechanical | `sonic` agent |

## Use in this skill

- Gather `BASE_SHA` / `HEAD_SHA` yourself or via `sonic`; never let the reviewer guess the range.
- Dispatch `code-reviewer` with the filled [code-reviewer.md](../code-reviewer.md) template. Pass only the description, the plan or `openspec/changes/<name>/tasks.md`, and the SHAs — never your session history.
- The reviewer is read-only and must not dispatch further reviewers. One review seat per slice.
- If the reviewer must understand surrounding code, give it the `scout` output rather than widening its own exploration.
- Collect findings and fix Critical issues before dispatching the next task. Do not review inline: the diff belongs in the reviewer's context, not yours.
