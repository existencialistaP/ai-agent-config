# Codex Tools

`SKILL.md` is canonical; this file only resolves its role names to `codex exec`
dispatch primitives. Use the names exactly as written.

| Role | Primitive | When to use |
|------|-----------|-------------|
| writer | separate `codex exec` session per slice with workspace-write | Merge conflicts, post-merge fixes, and any other branch edits. One session per slice. |
| scout | read-only `codex exec` session | Branch state is unclear: fork point, upstream, worktree registration, uncommitted files. |
| reviewer | fresh `codex exec` session given only the diff and specification | The pre-merge review of the diff against the base branch. |
| mechanical | low-effort or cheaper-model `codex exec` run | Fixed command sequences: test suite, worktree removal, branch deletion. |

Notes:

- **Single writer.** The writer owns the merge and every fix the merged result
  needs. Slice multi-file work into disjoint groups and give each its own
  session. Record the outcome at `openspec/changes/<name>/` when the work
  belongs to an OpenSpec change.
- **Pre-merge review.** Start a fresh session with only the diff and the
  specification, so it reviews the change rather than your reasoning. The
  writer handles the findings.
- **Forge CLI.** PR creation uses the forge CLI generically (`gh`, `glab`, or
  whatever the repository documents); this adapter chooses who dispatches, not
  which command runs.
