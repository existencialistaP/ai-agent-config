# Spec Delta

## Purpose

Lean role-based agent definitions: each agent carries only what its task needs, so sessions pay tokens only for relevant context.

## ADDED Requirements

### Requirement: Five role agents

The `agents/` tree SHALL define exactly `scout`, `writer`, `reviewer`, `mechanic`, and `orchestrator`, each with a single responsibility.

#### Scenario: Agent roster

- **WHEN** listing `agents/`
- **THEN** the five definitions exist and no other role agent is added by this change

### Requirement: Least-privilege toolsets

`scout` and `reviewer` SHALL be read-only (no edit, no subagent dispatch); `mechanic` SHALL apply listed fixes without re-architecting or re-fanning-out; `writer` SHALL NOT dispatch subagents.

#### Scenario: Read-only enforcement

- **WHEN** inspecting the `scout` definition
- **THEN** edit, shell-write, and subagent tools are denied

### Requirement: Embedded quality defaults

`writer` and `mechanic` SHALL embed the ponytail rules (YAGNI ladder, root-cause fix, minimal diff, report what was skipped) and `writer` SHALL require TDD (failing test before production code); `reviewer` SHALL flag YAGNI violations as Important or higher.

#### Scenario: Ponytail default without skill call

- **WHEN** a `writer` session completes a coding task without the `ponytail` skill ever being invoked
- **THEN** the diff is minimal and the reply names what was skipped

### Requirement: Cost-tiered execution

`scout` and `mechanic` SHALL be runnable on cheap/fast models with low thinking; `writer`, `reviewer`, and `orchestrator` SHALL use strong models.

#### Scenario: Model routing config

- **WHEN** reading the harness model config after this change
- **THEN** scout/mechanic map to the cheap tier and writer/reviewer/orchestrator to the strong tier

### Requirement: Harness-specific frontmatter

Each agent file SHALL carry per-harness tool declarations (`tools:` for omp, `permissions:` for opencode) so the same role works in every harness.

#### Scenario: Agent loads in both harnesses

- **WHEN** loading the `reviewer` definition in omp and in opencode
- **THEN** each harness enforces its native read-only tool policy
