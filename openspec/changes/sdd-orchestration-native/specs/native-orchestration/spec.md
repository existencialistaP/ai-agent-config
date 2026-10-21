# Spec Delta

## Purpose

N0 routing plus supervision loop with durable file-based state: native-first orchestration that any session can resume.

## ADDED Requirements

### Requirement: Single routing decision

The `orchestrate` skill SHALL be the only place that selects the transport: single-file/read-only goes direct; 2+ ephemeral slices in one checkout go `task` batch with one writer per file; long-lived/isolated/TUI-observable work goes Herdr; ownership transfer goes handoff. Orca SHALL NOT be in the default path.

#### Scenario: Router classifies ephemeral parallel work

- **WHEN** the N0 receives 3 independent slices in one checkout
- **THEN** it dispatches a `task` batch, never Herdr or Orca

### Requirement: Self-contained dispatch contract

Every dispatch SHALL write `dispatch/<slice>.md` first, containing Target, Change, Constraints, Ownership, and observable Acceptance, with full context (no inherited conversation).

#### Scenario: Child starts cold

- **WHEN** a dispatched agent reads only its `dispatch/<slice>.md`
- **THEN** it has everything needed without the parent session history

### Requirement: Bounded fan-out

N1 agents SHALL only dispatch read-only `scout` or mechanical `mechanic` agents and SHALL NOT re-fan-out writers.

#### Scenario: Depth audit

- **WHEN** tracing dispatch depth from the N0
- **THEN** no writer appears below depth 1

### Requirement: Durable file state

The N0 SHALL persist `tasks.md` checkboxes, `orchestration.md` (slice to owner, status, checkpoint, next step), and `dispatch/<slice>-result.md` per completed slice; a new session reading `tasks.md` plus `orchestration.md` SHALL resume without the prior conversation.

#### Scenario: Session resume

- **WHEN** the session dies with 3/5 slices done and a new session reads both files
- **THEN** it continues from slice 4 with no repeated or lost work

### Requirement: Evidence-gated supervision

The N0 SHALL run a reviewer per slice, integrate, run the full suite itself, and report N/M plus diff stat plus tool outputs; it SHALL NOT claim completion without fresh verification evidence, and a blocked slice SHALL pause with options.

#### Scenario: Blocked slice pauses

- **WHEN** a slice hits an unclear requirement
- **THEN** the N0 stops that slice and asks with options instead of guessing

### Requirement: Herdr transport conditions

Herdr SHALL be used only when `HERDR_ENV=1` and the work is long-lived, isolated, or TUI-observed; the N0 SHALL split a sibling pane with `--no-focus`, start a named agent, prompt with `--wait`, and SHALL NOT close panes it did not create.

#### Scenario: Herdr absent

- **WHEN** `HERDR_ENV` is unset
- **THEN** the N0 uses native `task` batch and never invokes `herdr`
