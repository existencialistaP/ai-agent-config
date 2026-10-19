# Tasks

## 1. Canonical trees and publication plumbing

- [x] 1.1 Create `skills/` canonical tree (moved all 46 per approved option A; only the 11 SDD-core get rewritten in phase 2), replace `opencode/skills` with a symlink to `../skills`. Commit 8a63593.
- [x] 1.2 Create `agents/` canonical tree with `scout.md`, `writer.md`, `reviewer.md` (absorbed omp `code-reviewer.md` body byte-identical), `mechanic.md`, `orchestrator.md`, each with dual frontmatter (`tools:` + `permissions:`). Commit 8a63593.
- [x] 1.3 Extend `mapping.sh`: added `skills|` entries for config + codex (OMP via existing derived link; agents publication deferred to 4.4 per N0 decision). Commit 61d6a5b.
- [x] 1.4 Update `doctor.sh` (derived skill count, EXPECTED_AGENTS=5, codex target) + `README.md` structure; `./install.sh --dry-run` exit 0. Commit 61d6a5b.
- [x] 1.5 `shellcheck` clean, `bats` 8/8 pass. 3 doctor errors are pre-existing (codex target not installed, dead codex socket, $HOME in omp/AGENTS.md + mcp.json untouched by this change).

## 2. Universal skill bodies and adapters

- [x] 2.1 Rewrite the 11 skill bodies in role language (commits 990fb32, d03b968, 435ad4c). Remaining matches only in graphify/tool-design, out of scope per design Non-Goals.
- [x] 2.2 Write `references/omp-tools.md`, `references/opencode-tools.md`, `references/codex-tools.md` per migrated skill (33 files total).
- [x] 2.3 Retire `using-superpowers` as router: 11-line alias pointing at `orchestrate` (commit d03b968).
- [x] 2.4 Grep-verify: zero matches across the 11 core dirs (excluding references/).

## 3. Orchestrate skill (N0)

- [x] 3.1 Write `skills/orchestrate/SKILL.md`: router table, dispatch-contract format, batch bounds (3-5), N2 bound. Commit 62e2bbf.
- [x] 3.2 Write the Herdr transport branch, validated against the installed CLI. Commit 62e2bbf.
- [x] 3.3 Write the supervision loop (reviewer per slice, N0 integration, evidence gate, pause-with-options). Commit 62e2bbf.
- [x] 3.4 Write the durability convention (tasks.md + orchestration.md + dispatch result files; resume-from-two-files). Commit 62e2bbf.

## 4. SDD rewire and slimming

- [x] 4.1 Slim `opencode/AGENTS.md` and `omp/AGENTS.md` to the router (both 24 lines; push guardrail aligned to `prompt` per user decision, commit 5bc8016; java-recon left in legacy per user decision).
- [x] 4.2 Rewire `opencode/commands/feature.md`, `debug.md`, `finish.md`, `investigate.md` to delegate slicing to `orchestrate` (commit 77f695b).
- [x] 4.3 Update `README.md` structure section (in commit 6162938).
- [x] 4.4 Publish canonical `agents/` (opencode/agents symlink, OMP derived link, doctor check, EXPECTED_AGENTS=5; opencode reviewer.md retired after validation) (commit 6162938).

## 5. Verification and rollout

- [ ] 5.1 Full verification: `./install.sh --dry-run`, `./doctor.sh`, `shellcheck`, `bats`, grep-verify (2.4), and a cold-resume drill (new session resumes a half-done change from `tasks.md` + `orchestration.md`).
- [ ] 5.2 Commit on a `feat/` branch; report diff stat, test outputs, and the resume-drill evidence.
