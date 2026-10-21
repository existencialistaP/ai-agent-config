# Spec Delta

## Purpose

Universal harness-independent skill source: one body written in role language, with per-harness adapters, published to every harness via symlink.

## ADDED Requirements

### Requirement: Universal skill body

The skill body SHALL use only role names (`writer`, `scout`, `reviewer`, `mechanical`) and MUST NOT contain harness-specific dispatch names (`Subagent (general-purpose)`, `task`, `explore`) or namespace prefixes (`superpowers:`).

#### Scenario: Audit skill body for harness coupling

- **WHEN** scanning `skills/<name>/SKILL.md` for `superpowers:`, `general-purpose`, `docs/superpowers`
- **THEN** zero matches are found

### Requirement: Per-harness adapters

Each migrated skill SHALL ship `references/omp-tools.md`, `references/opencode-tools.md`, and `references/codex-tools.md` mapping each role to the concrete harness primitive.

#### Scenario: Adapter resolves roles

- **WHEN** reading any migrated skill's `references/omp-tools.md`
- **THEN** `writer`, `scout`, `reviewer`, and `mechanical` each map to an omp-native agent or tool

### Requirement: Symlink publication

`install.sh`/`mapping.sh` SHALL publish `skills/` to `~/.config/opencode/skills`, `~/.omp/agent/skills`, and `~/.codex/skills` via symlink, and `doctor.sh` SHALL verify resolution.

#### Scenario: Fresh install resolves skills

- **WHEN** running `install.sh` then `doctor.sh` on a clean HOME
- **THEN** all three destinations resolve to the canonical source with no broken links

### Requirement: SDD-core migration set

The following 11 skills SHALL be migrated: `brainstorming`, `writing-plans`, `executing-plans`, `dispatching-parallel-agents`, `systematic-debugging`, `test-driven-development`, `verification-before-completion`, `requesting-code-review`, `using-git-worktrees`, `context`, `finishing-a-development-branch`.

#### Scenario: Core set complete

- **WHEN** listing migrated skills
- **THEN** all 11 are present with adapters and zero harness-coupled references
