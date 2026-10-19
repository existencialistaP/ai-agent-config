# OpenCode Tools

`skills/using-git-worktrees/SKILL.md` is canonical; this file only resolves dispatch primitives for OpenCode.

| Role | Primitive | When to use |
|------|-----------|-------------|
| writer | `task` tool with the default worker subagent | Implement or edit files in the isolated workspace |
| scout | `explore` subagent | Step 0 detection, repository layout, directory-selection research |
| reviewer | `reviewer` agent | Review the change after implementation lands |
| mechanical | low-effort `task` run | Mechanical updates: renames, table sync, path swaps |

## Notes

- **Isolation creation:** OpenCode has no native worktree tool, so create the workspace with `git worktree` exactly as in Step 1c (directory selection, `check-ignore`, sandbox fallback).
- Run each `task` call with the worktree path as the working directory; workers do not create or switch worktrees themselves.
- Give every writer a disjoint file set so parallel subagents never edit the same file.
- Keep setup commands (Step 2) and baseline tests (Step 3) on the orchestrator, not inside writers.
- Resolve the directory and run `check-ignore` before any `task` call; declare the resulting path in each task's context.
- Dispatch order: `explore` first, then writers, then `reviewer` after integration.
- The reviewer receives the integrated diff and the spec, not worker transcripts.
