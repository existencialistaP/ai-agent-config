---
description: Verify and close out the current development task with evidence, then present finish options
subtask: false
---

Finish the current development task. Evidence first: never declare success without fresh
verification output.

$ARGUMENTS

## Close-out workflow

1. Check `git status` and inspect `git diff` (staged and unstaged).
2. Identify unrelated changes. If any exist, do **not** mix them into this task's finish —
   stop and ask how to handle them.
3. Confirm the implementation matches the requirement/spec/plan (check
   `docs/superpowers/specs/` and `docs/superpowers/plans/` when referenced).
4. Verify the relevant tests, then run the project's verification commands (typecheck, lint,
   build — see AGENTS.md).
5. Ensure no known errors are ignored or skipped (no `.skip`/todo left by this work, no
   swallowed failures, no suppressed checks without justification).
6. If problems appear, fix **only** problems related to this task, then re-run the
   verifications from scratch.
7. Load and follow the **verification-before-completion** skill (use the skill tool) — every
   claim needs fresh command output as evidence.
8. Load and follow the **finishing-a-development-branch** skill (use the skill tool) to wrap
   up the branch. Execute only the option I choose.

## Hard limits — require my explicit approval

NEVER do automatically: `git push`, merge, deploy, production changes, secrets/credential
changes. Commits and the finishing-a-development-branch options also wait for my approval.

## Final report

State clearly, with evidence:

- Verification commands executed and their results (paste the output).
- Test results.
- Files changed.
- Problems found and how they were handled (fixed / deliberately left, with reasons).
- Branch status.
- Possible next steps (the finishing-a-development-branch options), waiting for my choice.
