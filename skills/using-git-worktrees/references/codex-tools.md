# Codex Tools

`skills/using-git-worktrees/SKILL.md` is canonical; this file only resolves dispatch primitives for Codex.

| Role | Primitive | When to use |
|------|-----------|-------------|
| writer | separate `codex exec` session per slice with workspace-write | Implement or edit files in the isolated workspace |
| scout | read-only `codex exec` session | Step 0 detection, repository layout, directory-selection research |
| reviewer | fresh `codex exec` session given only the diff and spec | Review the change after implementation lands |
| mechanical | low-effort / cheaper-model `codex exec` run | Mechanical updates: renames, table sync, path swaps |

## Notes

- **Isolation creation:** Codex has no native worktree tool, so create the workspace with `git worktree` exactly as in Step 1c (directory selection, `check-ignore`, sandbox fallback).
- Start every session from the worktree path and grant workspace-write only to writers; scouts stay read-only.
- The reviewer session receives the diff and the spec, not the writer transcript, so its findings stay independent.
- Writers get one slice each with disjoint file ownership; the orchestrator integrates and runs baseline tests once.
- Resolve the directory and run `check-ignore` before the first session starts.
- Dispatch order: read-only scout session, then writer sessions, then the fresh reviewer session.
- Mechanical runs never own branches or worktrees; they only edit already-scoped files.
