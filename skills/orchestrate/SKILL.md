---
name: orchestrate
description: Use when routing or supervising work - pick direct, task batch, Herdr, or handoff, then run the N0 supervision loop native-first
---

# Orchestrate

You are the N0. You own the routing decision, the dispatch contracts, integration, and the evidence that the work is done. The default is native primitives in the current checkout; every heavier transport must earn its place.

**Vocabulary:** `N0` is you, the orchestrator. `N1` is a dispatched worker (`writer`, `scout`, `reviewer`, `mechanic`). `N2` is an optional helper an N1 dispatches for a narrow job. Bodies in this repo speak in roles; concrete primitives live in `references/` for the harness you run on.

## 1. Router

Pick exactly one transport before the first dispatch. The lightest transport that covers the lifetime of the work wins.

| Situation | Transport | Why |
|---|---|---|
| One file, one read, one command, or work under a few minutes | **Direct** — do it yourself | Dispatch overhead exceeds the work |
| 2+ independent slices, ephemeral, same checkout, one `writer` per file | **Task batch** — all entries in one call | Parallel wall-clock gain, no isolation needed |
| Long-lived work, isolated checkout needed, or the human wants to watch the TUI | **Herdr panes** — only when `HERDR_ENV=1` | Durable, observable, survives your turn |
| A different session or owner continues the work | **Handoff** — write state to files first | Ownership is transferring, not just work |

Decision rules:

- Read-only investigation that feeds an edit is `scout` first, then named `writer` slices.
- Never split a slice across two writers. Split by file or by exported unit; one `writer` owns one file.
- Keep batches at 3-5 units. Above that, review latency hides integration errors; below three units, do it inline.
- Herdr is not a default. `HERDR_ENV` unset means no `herdr` invocation at all.
- An Orca workspace is opt-in only: use it when the user asks for it or the work needs its browser/artifacts. It is never the default path.

## 2. Dispatch contract

Write `dispatch/<slice>.md` **before** dispatching. The child starts cold — it inherits no conversation, no plan, no decisions. Everything it needs must be in the file.

Every dispatch file carries these headings:

```markdown
# Slice: <name>

## Target
<Files and paths this slice owns. Exact, no globs.>

## Change
<What to implement or fix. APIs, patterns, edge cases.>

## Constraints
<What NOT to touch. Existing conventions to reuse. No build/lint/test runs.>

## Ownership
<One writer. Which files it may edit. Which dispatch directory it writes results to.>

## Acceptance
<Observable result: command output, behavior, file state.>
```

Rules for the contract:

- **Self-contained.** Reference repo paths, not "the plan we discussed". Quote the failing output, the expected behavior, the exact symbols.
- **Observable acceptance.** "Tests pass" is not acceptance unless you name the command and the expected outcome. Prefer behavior a reviewer can check from the diff.
- **Bounded ownership.** State the files. A writer that needs another file messages the N0 instead of editing it.
- **No verification duty.** The child edits and reports. The N0 runs gates, tests, and formatters after integration.
- **Result contract.** The child writes `dispatch/<slice>-result.md` before replying, with what changed, what it could not do, and the evidence it collected.

### Planning is not dispatched

Spec-building runs on the N0, interactively, in the current session: the N0 asks the human one question at a time, presents each artifact section for approval, and uses `scout` children for read-only code research in parallel with the questions. No child ever receives spec-building work. Planning ends when the artifacts are written to files and `orchestration.md` carries status `planned` plus the next step — the handoff to the worker. The worker-N0 resumes cold from `tasks.md` + `orchestration.md` and never re-asks a decision already settled there; it pauses with options only when execution reveals new ambiguity.

## 3. Bounds

Fan-out is a tree, not a mesh.

- N0 dispatches `writer`, `scout`, `reviewer`, or `mechanic` slices.
- N1 may dispatch **only** `scout` (read-only) or `mechanic` (a listed, mechanical fix). Never a second `writer`.
- No `writer` exists below depth 1. If an N1 slice turns out to need a second writer, it reports back and the N0 creates a new top-level slice.
- Depth 2 is the hard floor: an N2 helper gets one narrow question or one listed fix, not a problem domain.
- Fix rounds return to the same worker as a follow-up with the finding quoted; do not spawn a replacement writer for a small correction.

## 4. Herdr transport

Herdr gives durable, human-observable panes. It is entered only when the work is long-lived, needs an isolated checkout, or the human asked to watch. The Herdr branch is a guarded branch, not a default.

### 4.1 Guard

```bash
test "${HERDR_ENV:-}" = 1 || { echo "not inside Herdr; use task batch"; exit 1; }
```

If the guard fails, stop the Herdr branch and use a task batch. Never inspect or drive a Herdr session from outside Herdr.

### 4.2 Layout

Inspect the caller before splitting:

```bash
herdr pane layout --pane "$HERDR_PANE_ID"
```

Default to a sibling pane in the current tab at the current working directory. Split right for a wide pane, down for a narrow or tall one; avoid repeated same-direction splits. Keep the human's focus where it is:

```bash
herdr pane split --current --direction right --cwd "$PWD" --no-focus
```

`--direction` accepts `right` or `down`. Read the new pane ID from the JSON response at `.result.pane.pane_id` — never predict it.

### 4.3 Start and prompt

The pane must be at an interactive shell prompt. Names match `[a-z][a-z0-9_-]{0,31}` and are unique among live agents:

```bash
herdr agent start <name> --kind <kind> --pane <pane-id> -- <agent-args...>
herdr agent prompt <name> "<prompt>" --wait --timeout 120000
```

- `agent start` returns only after Herdr detects the agent and considers it ready. `agent_not_ready` means it is blocked during startup; wait for `idle` before prompting.
- `--wait` returns on the first settled `idle`, `done`, or `blocked`. Add `--until` only for a state-specific workflow; do not repeat the settled defaults.
- `agent_prompt_stalled` or `timeout` does not prove the prompt was not delivered. Inspect before any resend.

### 4.4 Follow up and read state

```bash
herdr agent get <name>
herdr agent read <name> --source recent-unwrapped --lines 120
```

State handling:

| State | Meaning | Action |
|---|---|---|
| `idle` / `done` | Settled; ready for the next input | Read the result, then dispatch review |
| `blocked` | Approval or question UI is waiting | **Stop and ask the human.** Never answer a blocked dialog for them |
| `unknown` | Agent present; Herdr cannot classify it | Inspect `agent get` and `agent read`; do not assume completion |
| `working` | Turn in progress | Wait; do not send a second prompt |

### 4.5 Lifecycle rules

- Never close a workspace, tab, or pane this run did not create. The human may be using it.
- Record every created pane ID in `orchestration.md` so a resumed session can identify what it owns.
- When the work is done, leave the panes open unless the human asks otherwise. Report their names and pane IDs instead of tidying up.
- `--no-focus` on every split. Focus changes are the human's choice, not a side effect of dispatch.

## 5. Supervision loop

The N0 supervises; workers execute.

1. **Write contracts.** One `dispatch/<slice>.md` per slice, before any dispatch.
2. **Dispatch the batch.** All independent slices in one call. Record owner, status, and checkpoint in `orchestration.md`.
3. **Review each slice.** When a `writer` returns, dispatch a `reviewer` over that slice's diff. Review findings go back to the same writer as a follow-up.
4. **Integrate on the N0.** Apply, sequence, and resolve conflicts yourself. No worker owns the union of the diffs.
5. **Run the full suite on the N0.** The N0 runs the project gates once over the union of changes: build, tests, formatter, linter. Workers never verify their own work.
6. **Report.** Give `N/M` slices landed, the `git diff --stat`, and the actual tool outputs. A blocked slice is not "done with a follow-up"; it is open.

### Evidence gate

No completion claim without fresh verification output from this session. "Looks right", "should pass", and a worker's self-report are not evidence. If the suite was not run after the last integration, the work is not complete.

### Blocked slices

A blocked slice pauses the loop for that slice only:

- State what is unclear and why the contract cannot settle it.
- Offer concrete options with their trade-offs.
- Do not guess an answer to a `blocked` agent dialog, and do not silently drop the slice.
- Continue with slices that are not blocked; report the pause in the final tally.

## 6. Durability

State lives in files inside the change being executed, not in the conversation. This survives compaction, a dead session, and a harness switch.

| File | Owner | Content |
|---|---|---|
| `tasks.md` | N0 | Checkbox per step; the checklist is the progress record |
| `orchestration.md` | N0 | Slice to owner, status, checkpoint, next step, created pane IDs |
| `dispatch/<slice>.md` | N0 | The contract the worker reads |
| `dispatch/<slice>-result.md` | Worker | What changed, evidence, what remains — written **before** the worker replies |

`orchestration.md` row shape:

```markdown
| Slice | Owner | Status | Checkpoint | Next |
|---|---|---|---|---|
| parser-fix | writer/parser-fix | done | dispatch/parser-fix-result.md | review |
| docs-sync | writer/docs | blocked | needs scope decision | ask human |
```

### Resume

A fresh session resumes by reading exactly two files:

1. `tasks.md` — which steps are checked.
2. `orchestration.md` — which slice belongs to whom, what is done, what is next.

Then, for any slice in flight, read its `dispatch/<slice>.md` and `dispatch/<slice>-result.md`. Do not redo a slice whose result file exists and whose acceptance still holds; do not skip a slice whose result file is missing. Mark state in the files before dispatching again — a resume must never depend on remembered context.

A worker-N0 resuming cold never re-asks a decision already recorded in `tasks.md` or `orchestration.md`; new ambiguity revealed by execution is the only reason to pause, and then with concrete options rather than a reopened planning conversation.

## 7. Adapters

`references/omp-tools.md`, `references/opencode-tools.md`, and `references/codex-tools.md` map every role and transport in this skill to that harness's primitives. Read the one for your harness before the first dispatch. When the table and the actual tool list disagree, trust the tool list and fall back to doing the work inline rather than inventing a call.
