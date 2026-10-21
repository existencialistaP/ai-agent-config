# OMP Tools

`skills/using-git-worktrees/SKILL.md` is canonical; this file only resolves dispatch primitives for OMP.

| Role | Primitive | When to use |
|------|-----------|-------------|
| writer | `task` tool batch: one worker per file or disjoint group | Implement or edit files in the isolated workspace; never assign two workers to one file |
| scout | `scout` agent (read-only) | Step 0 detection, repository layout, directory-selection research |
| reviewer | `code-reviewer` agent | Review the change after implementation lands |
| mechanical | `sonic` agent | Mechanical updates: renames, table sync, path swaps |

## Notes

- **Isolation creation:** use the native worktree tool when the session exposes one (Step 1a); otherwise, when `HERDR_ENV=1` and the `herdr` CLI is present, create the worktree through Herdr or Orca and then work inside it. If neither is available, use `git worktree` (Step 1c).
- Workers must not create their own worktrees. The orchestrator owns Steps 0-1 and hands each worker the already-isolated path.
- Batch writers by disjoint files; shared files need one integration owner so sibling edits do not race.
- Run baseline tests once, on the orchestrator, after all workers land.
- Dispatch order: scout first, then the writer batch, then the reviewer after integration.
- Escalate blockers to the orchestrator instead of editing outside the assigned slice.
- Reviewers see the integrated diff, not a single writer's slice.
