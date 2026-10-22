---
description: Review the implementation for correctness, architecture, regressions and quality
subtask: false
---
Perform a code review of what was just implemented.

$ARGUMENTS

Use the **requesting-code-review** skill (load it) and follow its checklist:

1. Determine the git range: `BASE_SHA` = commit before the work, `HEAD_SHA` = current HEAD
   (`git rev-parse HEAD`, `git log --oneline` to find the base).
2. Compose the review package: what was implemented (`$ARGUMENTS`), the plan/spec it implements
   (read `openspec/changes/<nome>/` when referenced), and the git range.
3. Dispatch the **`reviewer` agent** (read-only) to review `git diff BASE_SHA..HEAD_SHA`,
   following the requesting-code-review template.

Review for: correctness, architecture, regressions, code quality, edge cases, security,
adherence to the spec, and adherence to project conventions (AGENTS.md, design system).

Then act on feedback with the **receiving-code-review** skill: verify each finding against the
code before agreeing or pushing back; fix Critical and Important issues (one at a time, test
each); note Minor issues. Re-run typecheck/lint/tests after fixes.

Report findings by severity (Critical / Important / Minor) and state what was fixed and what
was deliberately left, with reasons.

$ARGUMENTS
