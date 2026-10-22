---
description: Systematically investigate and fix bugs
subtask: false
---
Debug the following issue.

$ARGUMENTS

Use the **systematic-debugging** skill (load it). Follow the Iron Law: **no fixes without root
cause investigation first**.

Before splitting the work, load the **orchestrate** skill and follow it for slicing and
transport decisions (direct / task batch / Herdr / handoff): one failure per slice, one
`scout` or `writer` per slice, independent failures dispatched as one parallel batch.

1. Reproduce the bug reliably; capture the exact failure (error, second-level, exact command).
2. Read the relevant code, tests and logs; form hypotheses; test them cheaply; find the root
   cause. If a project context map exists at `~/.local/share/ai-agent-config/contexts/<project>.md`, read it
   first (see the **context** skill) to locate the relevant code faster. Use the
   **dispatching-parallel-agents** skill if there are multiple independent failures to
   investigate.
3. Only after root cause is confirmed, fix it — minimal change, following existing patterns,
   using **test-driven-development**: add a failing test that captures the bug, watch it fail,
   then make it pass. Update related tests.
4. Run the project's verification commands (typecheck, lint, tests — see AGENTS.md).
5. **verification-before-completion** skill: verify the fix actually fixes the reported
   symptom and introduces no regressions; show the evidence, not an assertion.

Report: root cause, the fix, the test that proves it, and verification output. Do not pad the
fix with unrelated refactoring.

$ARGUMENTS