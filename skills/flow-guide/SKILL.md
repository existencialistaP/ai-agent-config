---
name: flow-guide
description: Use whenever anyone asks how to use the N0/worker/queue/Herdr flow, when to plan interactively versus with --direct, how to read or pick up from queue.md, or how to hand work to a worker — and load it before explaining or starting any step of that flow, even when the question sounds like a one-liner.
---

# Flow Guide

How to use the planning → queue → worker flow. This is the usage guide; `orchestrate` owns transport routing and the supervision rules, and every adapter under `references/` maps the commands below to one harness. Load `orchestrate` when you need the rules themselves, and this skill when the question is *which command starts which phase, what it expects from the human, and where state is written*.

Vocabulary: **N0** is the session that plans or supervises; **N1** is a dispatched worker role (`writer`, `scout`, `reviewer`, `mechanic`); **N2** is a narrow helper an N1 may dispatch. Planning-N0 hands off to worker-N0 through files; worker-N0 dispatches N1 slices.

## 1. When to use this flow (vs doing it directly)

Use the flow when **any** of these is true:

- The work splits into **2+ independent slices** — more than one file or exported unit, each reviewable on its own.
- The request deserves a **spec someone reviews** before code exists — new behavior, a contract change, a migration.
- The work must **survive the session** — long-lived, likely to hit compaction, or may move to another harness, session, or human.

Do it directly when the work is one file, one read, one command, or under a few minutes. Do not open a change, do not write a queue line, do not dispatch. Dispatch overhead exceeds the work.

| Signal | Do it directly | Use the flow |
|---|---|---|
| Touched files | one | 2+ slices |
| Review needed before code | no | yes |
| Lifetime | this turn | beyond this session |
| Example | rename a symbol, fix a typo | add rate limiting, migrate a module |

## 2. Planning, interactive mode

Start with the planning command and **no flag**:

```
/tospec add rate limiting to the public API
```

What to expect, in order:

1. The planner asks **one question at a time** — scope, constraints, edge cases, failure behavior. Answer conversationally; do not dump a spec unless asked.
2. Read-only code research (`scout`) runs **in parallel with the questions**. The planner reads the real code rather than asking you what the code does.
3. Each artifact is presented **section by section** — `proposal.md`, then `design.md`, then `tasks.md`. Approve, correct, or reject each section before the next one.
4. It covers **1..N tasks/slices** in the same session. Every slice gets its own line in `queue.md`.
5. It ends with `orchestration.md` at status `planned`, the queue filled, and the Herdr offer (section 5).

Use this mode by default whenever requirements are still moving or the design deserves a second opinion.

## 3. Planning, direct mode

Add `--direct` and the flow drops the question rounds:

```
/tospec --direct fix the retry counter overflow in client.ts
```

The **whole human gate is three lines**:

1. One sentence classifying the request — `spike`, `bounded`, or `architectural`.
2. One line confirming the scope — what changes and what explicitly does not.
3. One `ok` from you.

After that `ok` the planner writes every artifact without stopping. Get the classification and scope right at the gate, because there is no later checkpoint before execution begins.

Use `--direct` for fixes, mechanical changes, and requests whose scope is already obvious. Do not use it for architectural decisions, ambiguous requirements, or security-sensitive changes — those need section-by-section review.

## 4. The queue

`queue.md` lives in the change directory (`openspec/changes/<change>/queue.md`), or at the repo root when there is no change. It is the only handoff between planning and execution.

```markdown
| Slice | Source | Status | Next |
|---|---|---|---|
| rate-limit-middleware | tospec | queued | pickup |
| retry-overflow-fix | tospec --direct | doing | review |
| docs-update | opsx-propose | blocked | ask human |
```

- **Schema:** `slice | source | status | next`, one line per slice, any count.
- **Statuses:** `queued` → `doing` → `done`, or `blocked` from any active state.
- **Source:** the command or mode that produced the line (`tospec`, `tospec --direct`, `opsx-propose`), for traceability only.
- **Next:** the literal next action — `pickup`, `review`, `ask human`, `archive`.
- Planning writes `queued`. The worker transitions a row at the **start of its turn**, before dispatching that slice: `queued` → `doing`, then `done` or `blocked`.
- **Pickup is event-driven.** No daemon, no polling loop, no watcher. A session reads the queue when it starts or resumes; the row it claims moves to `doing`; nobody picks up a `doing` or `done` row again.

A resuming session reads `tasks.md`, `orchestration.md`, and `queue.md` in that order and continues from the first row that is not `done`.

## 5. End-of-planning Herdr offer

Planning ends with exactly **one question and three options**:

1. Open a worker in a new Herdr pane.
2. Execute here in this session.
3. Leave it in the queue.

**Default is 3.** Never auto-start a worker, and never open a Herdr pane without an explicit "yes". The offer is not a prompt to begin work — it is a choice about where work begins.

Option 1 is still bound by the guard: it only works when `HERDR_ENV=1`. If the guard fails, say so and fall back to option 2 or 3; do not inspect or drive Herdr from outside Herdr.

## 6. The worker

Execution starts from one of two commands:

```
/opsx-apply rate-limit-api
```

for an approved OpenSpec change, or:

```
/feature rate-limit-api
```

for a change or a small direct request. Both consume the queue rather than re-planning it.

The worker-N0 then:

1. Reads `tasks.md` + `orchestration.md` + `queue.md` and claims the first `queued` slice.
2. Dispatches slices as `writer` work with a self-contained brief — target paths, change, constraints, observable acceptance.
3. Enforces **one writer per file**. Two writers on one path race; split by file or exported unit instead.
4. Dispatches a `reviewer` **per slice** over that slice's diff, and sends findings back to the same writer.
5. **Integrates** on the N0, then runs the full suite **once** over the union of changes.
6. Reports **N/M slices landed**, the diff stat, and the actual tool output. A blocked slice is open, not "done with a follow-up".

When execution reveals new ambiguity, the worker pauses on that slice with concrete options — it never silently rules on a requirement that planning did not settle, and it keeps working on slices that are not blocked.

## 7. Closing

Verify with fresh evidence and only then archive:

```
/finish rate-limit-api
/opsx-archive rate-limit-api
```

`/finish` compares the implementation against the change artifacts, runs the project's tests and linters, and pastes the outputs. "Looks right" is not evidence; a worker's self-report is not evidence. Only after that gate passes does `/opsx-archive` move the change into the archive.

## 8. Prior art and differences

This flow was shaped by three existing bodies of work. The comparison is about design choices, not attribution.

### obra/superpowers — plan execution via fresh contexts

The SDD skill dispatches a fresh implementer per task, reviews each task, keeps a progress ledger under `.superpowers/sdd/`, declares "rulings, not stalls" (the controller decides ambiguities instead of asking), runs **one implementation at a time** to avoid conflicts, and isolates each plan in its own worktree.

What differs here:

- Planning-N0 is **separate from worker-N0**, and the handoff is a file set, so planning and execution can happen in different sessions or harnesses.
- The human is asked during interactive planning; during execution the worker **pauses with options** on a new requirement ambiguity. There is no silent ruling about what the product should do.
- `queue.md` supports **multi-task pickup** instead of a strict serial per-task loop.
- Adapters make the same flow runnable per harness; Herdr is opt-in rather than implied.

Source: <https://github.com/obra/superpowers/blob/main/skills/subagent-driven-development/SKILL.md>

### Codagent orchestrate-change

That skill's N0 never edits project files, gives every delegated slice a self-contained brief, and keeps its plan, rulings, and progress in a file **outside the repository** so they survive compaction.

What differs here:

- Same spirit — N0 does not implement, briefs stand alone — but our state lives **inside the change** (`tasks.md`, `orchestration.md`, `queue.md`, `dispatch/`) and is versioned in git, so a collaborator or a later session sees the same truth.
- Planning has **two modes** (interactive and `--direct`) instead of one autonomous path.
- Planning ends with an explicit **Herdr offer** rather than starting execution unconditionally.

Source: <https://github.com/codagent-ai/agent-skills/blob/main/skills/orchestrate-change/SKILL.md>

### OpenAI and Azure handoff patterns

Both ecosystems model delegation as an **in-process handoff**: a supervisor transfers control to a specialist agent, which continues the conversation with its own instructions and tools. The handoff is a call inside one runtime, carrying message history.

What differs here: our handoff is a **file, not a call**. `tasks.md` + `orchestration.md` + `queue.md` + `dispatch/<slice>.md` are readable by any session, on any harness, after a crash or a compaction. No shared runtime or message history is required; the state is the interface.

Sources:

- <https://developers.openai.com/api/docs/guides/agents/orchestration>
- <https://openai.github.io/openai-agents-python/handoffs>
- <https://learn.microsoft.com/en-us/azure/architecture/ai-ml/guide/ai-agent-design-patterns>
- <https://learn.microsoft.com/en-us/agent-framework/workflows/orchestrations/handoff>

## 9. Adapters

Read the adapter for your harness before the first command:

| Harness | Adapter | Transport reference |
|---|---|---|
| omp | `references/omp-tools.md` | `skills/orchestrate/references/omp-tools.md` |
| opencode | `references/opencode-tools.md` | `skills/orchestrate/references/opencode-tools.md` |
| codex | `references/codex-tools.md` | `skills/orchestrate/references/codex-tools.md` |

Adapters here cover **planning and worker commands** — which command or skill starts each phase, how the queue is claimed, how a reviewer is requested. Transport primitives (batch dispatch, Herdr CLI, handoff mechanics) stay in the `orchestrate` adapters; when a table and the actual tool list disagree, trust the tool list and fall back to doing the work inline rather than inventing a call.
