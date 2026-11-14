# Tasks

## 1. Repository cleanup

- [x] 1.1 Move `commands/` and `skills-janitor/` to the repository root; delete the `opencode/` tree.
- [x] 1.2 Rewrite `mapping.sh` for OMP-only links, seeds, and legacy-link pruning.
- [x] 1.3 Rewrite `install.sh`: direct publication into `~/.omp/agent`, backup on conflict, prune legacy links only when they resolve into this checkout.
- [x] 1.4 Rewrite `doctor.sh`: OMP executables, OMP links, broken links, counts (52 skills, 21 commands, 5 agents), legacy leftovers.
- [x] 1.5 Rewrite `tests/install.bats`; drop the `opencode` fake.
- [x] 1.6 Repoint the janitor engine and janitor skills to `~/.omp/agent`; update the remaining hardcoded OpenCode paths.
- [x] 1.7 Update root `AGENTS.md` and `README.md` for the OMP-only layout.

## 2. Upstream workflow skills

- [x] 2.1 Add `verification-planning` (evidence path before implementation).
- [x] 2.2 Add `step-back` (interrupt patch snowballing).
- [x] 2.3 Add `simplify` (behavior-preserving simplification).
- [x] 2.4 Add `council` skill and `/council` command using OMP per-task model overrides.

## 3. Orchestration enrichment

- [x] 3.1 Add Delegate/Don't routing verdicts to `agents/orchestrator.md`.
- [x] 3.2 Add painter passes and pass gates to `skills/executing-plans`.
- [x] 3.3 Add per-role model overrides and the repeated-tool-call rule to the OMP config.

## 4. Verification

- [x] 4.1 Run the real `./install.sh` to migrate the machine; confirm legacy links moved to backup.
- [x] 4.2 `./init.sh` green (doctor + dry-run + bats + shellcheck) with output recorded.
- [x] 4.3 Smoke-check OMP loads 5 agents, 21 commands, and 52 skills.
- [x] 4.4 Reconcile README/doctor counts and attach the verification output.
