---
description: Implement an approved specification (or a small, unambiguous change) efficiently
subtask: false
---
Implement the approved specification. Follow the project's conventions and existing code.

$ARGUMENTS

## Orient

If a project context map exists at `~/.config/opencode/contexts/<project>.md`, read it first
(see the **context** skill) to orient before exploring the codebase. Trust the code over the map.

## Decide the path

Classify the task size first, then follow its flow:

- **Small and unambiguous** — implement directly: understand → implement → test → verify.
- **Medium** — plan before implementing: context → plan → approval when required → implement →
  test → review.
- **Large or complex** — use the existing Superpowers capabilities end to end:
  **brainstorming** (only if there is no approved spec/design), **writing-plans**,
  **subagent-driven-development**, **test-driven-development**, **using-git-worktrees** when
  isolation from current work is appropriate, **dispatching-parallel-agents** when the work
  splits into independent parts, **verification-before-completion**, and
  **requesting-code-review**. Do not create new skills for this.

## Implement

1. **writing-plans** skill — if the task is multi-step, produce an implementation plan at
   `docs/superpowers/plans/YYYY-MM-DD-<feature>.md` and get the execution approach approved
   before coding. For single-step changes, go straight to coding.
2. **test-driven-development** skill — write the failing test first, verify it fails, then the
   minimal code to pass, then refactor. Respect project test/lint/typecheck commands.
3. **subagent-driven-development** skill (recommended, when a plan exists and subagents are
   available) — fresh implementer subagent per task + review between tasks. Do **not** pause
   between tasks; keep executing until the plan or the change is complete. When the work has
   independent parts, use **dispatching-parallel-agents**; when isolation from current work is
   needed, use **using-git-worktrees**.
4. Run the project's verification commands (typecheck, lint, tests — see AGENTS.md) and fix
   any failures. **verification-before-completion** skill: no success claims without fresh
   evidence.

## Reuse, don't rewrite

Inspect the existing codebase first. Prefer existing components/abstractions/patterns; keep
changes scoped; avoid unrelated refactors; follow the repo's style and docs. Do not invent
requirements beyond the spec.

## Quality bar

- Edge cases handled, error states considered.
- Tests updated or added where appropriate.
- No dead code, no unused exports.
- Scope respected: only files the work requires.

Finish with a summary of what changed, verification output, and offer a code review (`review`).