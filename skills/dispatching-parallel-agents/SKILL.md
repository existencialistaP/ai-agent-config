---
name: dispatching-parallel-agents
description: Use when facing 2+ independent tasks that can be worked on without shared state or sequential dependencies
---

# Dispatching Parallel Agents

## Overview

You delegate tasks to role-scoped agents with isolated context. By precisely crafting their instructions and context, you ensure they stay focused and succeed at their task. They should never inherit your session's context or history — you construct exactly what they need. This also preserves your own context for coordination work.

When you have multiple unrelated failures (different test files, different subsystems, different bugs), investigating them sequentially wastes time. Each investigation is independent and can happen in parallel.

**Core principle:** Dispatch one agent per independent problem domain. Let them work concurrently.

## When to Use

```dot
digraph when_to_use {
    "Multiple failures?" [shape=diamond];
    "Are they independent?" [shape=diamond];
    "Single agent investigates all" [shape=box];
    "One agent per problem domain" [shape=box];
    "Can they work in parallel?" [shape=diamond];
    "Sequential agents" [shape=box];
    "Parallel dispatch" [shape=box];

    "Multiple failures?" -> "Are they independent?" [label="yes"];
    "Are they independent?" -> "Single agent investigates all" [label="no - related"];
    "Are they independent?" -> "Can they work in parallel?" [label="yes"];
    "Can they work in parallel?" -> "Parallel dispatch" [label="yes"];
    "Can they work in parallel?" -> "Sequential agents" [label="no - shared state"];
}
```

**Use when:**
- 3+ test files failing with different root causes
- Multiple subsystems broken independently
- Each problem can be understood without context from others
- No shared state between investigations

**Don't use when:**
- Failures are related (fix one might fix others)
- Need to understand full system state
- Agents would interfere with each other

## Choose the Transport

Pick the lightest transport that covers the lifetime of the work.

- **Ephemeral batch** — default. Harness-native dispatch in one batch for work that finishes in minutes, returns a summary, and edits the working tree. Cap at 3-5 units; one `writer` per file.
- **Durable / observable** — when work is long-lived, needs TTY observation, or ownership changes hands. Use Herdr panes when `HERDR_ENV=1` (named agents, `--no-focus` splits, never close panes you did not create). An Orca workspace is opt-in, never the default.
- **Handoff** — when a different session or owner continues the work; write the state to files before handing off.

## The Pattern

### 1. Identify Independent Domains

Group failures by what's broken:
- File A tests: Tool approval flow
- File B tests: Batch completion behavior
- File C tests: Abort functionality

Each domain is independent - fixing tool approval doesn't affect abort tests.

### 2. Create Focused Agent Tasks

Each dispatch gets a role, a scope, and an output contract:
- **Role:** `writer` when the work edits code; `scout` for read-only root-cause investigation when the cause is not yet known.
- **Specific scope:** One test file or subsystem
- **Clear goal:** Make these tests pass, or report the root cause
- **Constraints:** Don't change other code
- **Expected output:** Summary of what you found and fixed

### 3. Dispatch in Parallel

Issue all dispatches in one batch — they run concurrently:

```text
writer: "Fix agent-tool-abort.test.ts failures"
writer: "Fix batch-completion-behavior.test.ts failures"
writer: "Fix tool-approval-race-conditions.test.ts failures"
# All three dispatches issued together run concurrently.
```

Issue every dispatch in one response/batch. A dispatch issued alone, then another later, runs sequentially. If the cause is not yet known, send `scout` dispatches first and convert their findings into `writer` slices.

Concrete primitives for "one batch" differ per harness; see `references/`.

### 4. Review and Integrate

When the writers return:
- Read each summary
- Verify fixes don't conflict
- Dispatch a `reviewer` over the union of their diffs before integrating
- Route mechanical follow-ups (renames, fixture updates, log collection) to `mechanical`
- Run full test suite
- Integrate all changes

## Agent Prompt Structure

Good agent prompts are:
1. **Focused** - One clear problem domain
2. **Self-contained** - All context needed to understand the problem
3. **Specific about output** - What should the agent return?

Each dispatched `writer` or `scout` gets its scope, constraints, and expected output stated in the prompt; nothing is inherited from your session.

```markdown
Fix the 3 failing tests in src/agents/agent-tool-abort.test.ts:

1. "should abort tool with partial output capture" - expects 'interrupted at' in message
2. "should handle mixed completed and aborted tools" - fast tool aborted instead of completed
3. "should properly track pendingToolCount" - expects 3 results but gets 0

These are timing/race condition issues. Your task:

1. Read the test file and understand what each test verifies
2. Identify root cause - timing issues or actual bugs?
3. Fix by:
   - Replacing arbitrary timeouts with event-based waiting
   - Fixing bugs in abort implementation if found
   - Adjusting test expectations if testing changed behavior

Do NOT just increase timeouts - find the real issue.

Return: Summary of what you found and what you fixed.
```

## Common Mistakes

**❌ Too broad:** "Fix all the tests" - agent gets lost
**✅ Specific:** "Fix agent-tool-abort.test.ts" - focused scope

**❌ No context:** "Fix the race condition" - agent doesn't know where
**✅ Context:** Paste the error messages and test names

**❌ No constraints:** Agent might refactor everything
**✅ Constraints:** "Do NOT change production code" or "Fix tests only"

**❌ Vague output:** "Fix it" - you don't know what changed
**✅ Specific:** "Return summary of root cause and changes"

## When NOT to Use

**Related failures:** Fixing one might fix others - investigate together first
**Need full context:** Understanding requires seeing entire system
**Exploratory debugging:** You don't know what's broken yet
**Shared state:** Agents would interfere (editing same files, using same resources)

## Real Example from Session

**Scenario:** 6 test failures across 3 files after major refactoring

**Failures:**
- agent-tool-abort.test.ts: 3 failures (timing issues)
- batch-completion-behavior.test.ts: 2 failures (tools not executing)
- tool-approval-race-conditions.test.ts: 1 failure (execution count = 0)

**Decision:** Independent domains - abort logic separate from batch completion separate from race conditions

**Dispatch (one batch, three writers):**
```text
writer: "Fix agent-tool-abort.test.ts failures"
writer: "Fix batch-completion-behavior.test.ts failures"
writer: "Fix tool-approval-race-conditions.test.ts failures"
# All three dispatches issued together run concurrently.
```

**Results:**
- Writer 1: Replaced timeouts with event-based waiting
- Writer 2: Fixed event structure bug (threadId in wrong place)
- Writer 3: Added wait for async tool execution to complete

**Integration:** All fixes independent, no conflicts, full suite green

## Verification

After agents return:
1. **Review each summary** - Understand what changed
2. **Check for conflicts** - Did agents edit same code?
3. **Run full suite** - Verify all fixes work together
4. **Spot check** - Agents can make systematic errors

## Harness Adapters

Role names in this skill resolve to concrete primitives per harness. See the `references/` directory for the adapter that matches your environment.
