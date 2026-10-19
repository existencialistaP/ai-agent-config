# OpenCode Tools

`SKILL.md` is canonical; this file only resolves its role names to OpenCode
dispatch primitives. Use the names exactly as written.

| Role | Primitive | When to use |
|------|-----------|-------------|
| writer | `task` tool with the default worker subagent | Merge conflicts, post-merge fixes, and any other branch edits. Never assign one file to two workers. |
| scout | `explore` subagent | Branch state is unclear: fork point, upstream, worktree registration, uncommitted files. |
| reviewer | `reviewer` agent | The pre-merge review of the diff against the base branch. |
| mechanical | low-effort `task` run | Fixed command sequences: test suite, worktree removal, branch deletion. |

Notes:

- **Single writer.** The writer owns the merge and every fix the merged result
  needs; split multi-file work into disjoint groups. Record the outcome at
  `openspec/changes/<name>/` when the work belongs to an OpenSpec change.
- **Pre-merge review.** The reviewer sees the diff against the base and the
  specification, and does not edit. The writer handles the findings.
- **Forge CLI.** PR creation uses the forge CLI generically (`gh`, `glab`, or
  whatever the repository documents); this adapter chooses who dispatches, not
  which command runs.
