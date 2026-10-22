# Workflow skills

## ADDED Requirements

### Requirement: Evidence is planned before implementation

The `verification-planning` skill SHALL guide an agent to state the claim,
its uncertainty and failure modes, choose a project-specific evidence path,
and close that path with observed evidence after implementation.

#### Scenario: Non-trivial change

- **WHEN** an agent starts a non-trivial implementation or fix
- **THEN** it can load `verification-planning` before editing
- **AND** the planned evidence names the command or observation that proves
  the claim

### Requirement: Step-back interrupts patch snowballing

The `step-back` skill SHALL instruct an agent to pause when fixes, shims, or
workarounds keep stacking, state the drift and a cleaner alternative, and let
the user decide before continuing.

#### Scenario: Third workaround

- **WHEN** a task is being pushed forward through repeated patches
- **THEN** the agent presents the current direction, the drift, a cleaner
  alternative, and a recommendation

### Requirement: Council reviews with independent seats

The `council` skill SHALL dispatch at least three independent read-only
`reviewer` tasks in one batch, each with a distinct model, then synthesize a
single verdict. Seats MUST NOT see each other's output. The skill MUST state
that council is opt-in, not a default verification step.

#### Scenario: Requested council

- **WHEN** the user asks for a council, consensus, or second opinion
- **THEN** the agent dispatches the seats in parallel
- **AND** reports the verdict, per-seat findings, and any dissent

### Requirement: Deepwork passes live in the OpenSpec change

The `executing-plans` skill SHALL describe painter passes (`sketch`,
`structure`, `detail`) with one gate per pass, a ranked known-issues list,
and a re-plan step. Its state MUST remain `tasks.md` and `orchestration.md`
inside the active OpenSpec change; it MUST NOT create a second tracker.

#### Scenario: Large multi-phase change

- **WHEN** a change spans multiple subsystems
- **THEN** execution proceeds in passes with a gate between passes
- **AND** no `.slim/deepwork` progress file is created
