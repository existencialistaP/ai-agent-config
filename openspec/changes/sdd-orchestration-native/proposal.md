# Proposal

## Why

The SDD flow (propose → apply → verify) has no native orchestration layer: skills are coupled to opencode/superpowers naming (`superpowers:*`, `Subagent (general-purpose)`, `docs/superpowers/`), the AGENTS.md carries orchestration prose no command executes, and parallel work depends on Orca instead of harness-native primitives. This causes token waste (every session pays for the full AGENTS.md), broken skills outside opencode, and no durable supervision (you → N0 → N1 → N2).

## What Changes

- Introduce `skills/` as the universal harness-independent skill source; per-harness adapters live in `skills/<name>/references/<harness>-tools.md` (omp, opencode, codex).
- Migrate the 11 SDD-core skills to role-based language (`writer`/`scout`/`reviewer`/`mechanical`) with zero harness-specific names in the body.
- Introduce `agents/` with 5 lean role agents (`scout`, `writer`, `reviewer`, `mechanic`, `orchestrator`); `writer`/`mechanic` embed ponytail + TDD as defaults; `reviewer` absorbs the existing omp `code-reviewer.md`.
- Introduce the `orchestrate` skill (the N0): single routing + supervision loop, native-first (`task` batch for ephemeral, Herdr panes for long-lived/observable, handoff for ownership transfer). Orca is out of the default path.
- Slim both `AGENTS.md` files to a ~15-line router pointing at `orchestrate`; the rest lives in agents/skills.
- Rewire SDD commands (`feature`, `debug`, `finish`, `investigate`, `opsx-*`) to call `orchestrate`; extend `install.sh`/`mapping.sh`/`doctor.sh` for the new trees.

## Capabilities

### New Capabilities

- `universal-skills`: harness-independent skill source with per-harness adapters.
- `role-agents`: lean role-based agent definitions with embedded quality defaults.
- `native-orchestration`: N0 routing + supervision loop with durable file-based state.

### Modified Capabilities

- SDD commands and AGENTS.md files are existing behavior, updated in place (no new spec files; requirements live in the three new capabilities).
