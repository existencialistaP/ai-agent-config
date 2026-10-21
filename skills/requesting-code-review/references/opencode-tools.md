# opencode tools — requesting-code-review

| Role | opencode primitive |
|------|--------------------|
| writer | `task` subagent with the general-purpose agent — produces the change and hands over the range |
| reviewer | `reviewer` subagent (read-only) |
| scout | `explore` subagent (read-only) |
| mechanical | `task` subagent with a narrowly scoped, mechanical prompt |

## Use in this skill

- Gather `BASE_SHA` / `HEAD_SHA` yourself or via a scoped `task` subagent; never let the reviewer guess the range.
- Dispatch `reviewer` with the filled [code-reviewer.md](../code-reviewer.md) template. Pass only the description, the plan or `openspec/changes/<name>/tasks.md`, and the SHAs — never your session history.
- The reviewer is read-only and must not dispatch further reviewers. One review seat per slice.
- If the reviewer must understand surrounding code, give it the `explore` output rather than widening its own exploration.
- Collect findings and fix Critical issues before dispatching the next task. Do not review inline: the diff belongs in the reviewer's context, not yours.
