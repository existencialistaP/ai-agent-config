# OMP Tools

`SKILL.md` is canonical; this file only resolves its role names to OMP
dispatch primitives. Use the names exactly as written.

| Role | Primitive | When to use |
|------|-----------|-------------|
| writer | `task` tool batch, one worker per file or disjoint group | Merge conflicts, post-merge fixes, and any other branch edits. Never assign one file to two workers. |
| scout | `scout` agent (read-only) | Branch state is unclear: fork point, upstream, worktree registration, uncommitted files. |
| reviewer | `code-reviewer` agent | The pre-merge review of the diff against the base branch. |
| mechanical | `sonic` agent | Fixed command sequences: test suite, worktree removal, branch deletion. |

Notes:

- **Single writer.** The writer owns the merge and every fix the merged result
  needs. Split multi-file work into disjoint groups. Record the outcome at
  `openspec/changes/<name>/` when the work belongs to an OpenSpec change.
- **Pre-merge review.** The reviewer receives the diff against the base and the
  specification; it does not edit. The writer addresses its findings before the
  merge.
- **Forge CLI.** PR creation uses the forge CLI generically (`gh`, `glab`, or
  whatever the repository documents); this adapter chooses who dispatches, not
  which command runs.
