# Design

## Context

See proposal.md (Why). Current state shaping the approach:

- Single source today is `opencode/skills/` (46 entries); `~/.omp/agent/skills` is a derived symlink to the published `~/.config/opencode/skills` (`mapping.sh` `link_derived`). `~/.omp/agent/commands` likewise derives from opencode commands.
- `mapping.sh` is the only origin→destination map consumed by both `install.sh` and `doctor.sh`; `doctor.sh` asserts fixed counts (45 skills, 20 commands) and link resolution.
- OMP agent format (`omp/agents/*.md`: `name/description/tools:` frontmatter) differs from opencode (`opencode/agents/*.md`: `description/mode/permissions:`), which is why `code-reviewer.md` stayed omp-proprietary (README documents this).
- `~/.codex/skills/` exists on this machine, so a codex publication target is available.
- Herdr integration is a single extension file (`~/.omp/agent/extensions/herdr-omp-agent-state.ts`, managed by herdr, must not be edited); orchestration touches Herdr only through the `herdr` CLI guarded by `HERDR_ENV=1`.
- This change dogfoods its own durability convention: `tasks.md` checkboxes plus `orchestration.md` in this change directory.

## Goals / Non-Goals

**Goals:**

- One canonical skill body per skill, zero harness names in the body, adapters per harness.
- Five role agents with least-privilege toolsets and embedded ponytail/TDD defaults.
- One N0 skill (`orchestrate`) owning transport selection and the supervision loop.
- AGENTS.md files reduced to a router; SDD commands delegate slicing to `orchestrate`.
- Install/doctor cover the new trees; legacy symlinks keep working until doctor passes.

**Non-Goals:**

- No Orca dependency in the default path (opt-in note only, no spec requirements).
- No `orchestrate-state.ts` plugin automation in this change (manual file convention only; plugin is a follow-up).
- No migration of non-SDD skills (`codeql`, `semgrep`, `ponytail/*`, janitor, etc.) — only the 11-skill core set.
- No model-config changes beyond documenting the cheap/strong tier mapping.

## Decisions

### 1. New top-level `skills/` canonical tree; `opencode/skills` becomes a symlink

`skills/<name>/SKILL.md` plus `skills/<name>/references/{omp,opencode,codex}-tools.md` is the only source. `opencode/skills` becomes a symlink to `../skills` inside the repo, so every existing `mapping.sh` entry and downstream path keeps resolving with zero edits, and the OMP derived link (`$CONFIG_DIR/skills → $OMP_DIR/skills`) keeps working untouched. Codex gains one new mapping entry to `~/.codex/skills`.

- Alternative considered: keep `opencode/skills` canonical and add `references/` in place. Rejected: perpetuates opencode-centrism, codex stays second-class, and the "universal" claim is cosmetic.
- Alternative considered: copy instead of symlink per harness. Rejected: copies drift; the repo already standardizes on symlinks with backup-on-conflict.

### 2. Role language in bodies, concrete mapping in adapters

Bodies name only `writer` / `scout` / `reviewer` / `mechanical`. Each adapter maps roles to harness primitives: omp (`task` writer batch, `scout`, `code-reviewer`, `sonic`), opencode (`task`/`general-purpose`, `explore`, `reviewer`), codex (codex equivalents). The existing `using-superpowers/references/*-tools.md` pattern is the template; add `omp-tools.md` (missing today) and generalize.

### 3. Single agent file, dual frontmatter keys

`agents/<role>.md` carries both `tools:` (omp) and `permissions:` (opencode) keys; each harness reads its own and ignores the other. Fallback if a harness chokes on unknown keys: split into `agents/<role>.md` + `agents/<role>.opencode.md` with a mapping entry each. `reviewer` absorbs the current omp `code-reviewer.md` body (already role-shaped: read-only, no subagents, severity-grouped report); opencode keeps its `reviewer.md` until the unified file is validated, then it becomes a symlink.

### 4. `orchestrate` is a universal skill, Herdr is a guarded branch

`skills/orchestrate/SKILL.md` holds the router table, dispatch-contract format, supervision loop, and resume protocol. The Herdr branch is CLI-only (`pane split --current --no-focus`, `agent start`, `agent prompt --wait`, `agent get/read`), entered only when `HERDR_ENV=1` and the work qualifies (long-lived/isolated/TUI-observed). No extension code, no daemon, no Orca in this change.

### 5. Durability is a file convention, not a service

`tasks.md` (checkboxes) + `orchestration.md` (slice→owner/status/checkpoint/next) + `dispatch/<slice>.md` + `dispatch/<slice>-result.md`, all inside the executed change's directory. Writers write `-result.md` before replying (deliveries expire). Resume = read two files. Works across compaction, sessions, and harnesses.

### 6. AGENTS.md slimming keeps the contract block

Both AGENTS.md files shrink to ~15 lines: SDD phase list, router table (direct / task batch / Herdr / handoff), and a pointer to `orchestrate`. Guardrails that are load-bearing (push denial, yolo approvals, OpenSpec-as-source-of-truth, verification-before-claims) stay verbatim; everything else moves into agents/skills.

## Risks / Trade-offs

- **Dual-frontmatter rejection**: a harness may fail on unknown keys → fallback to split files (Decision 3). Validate with `doctor.sh` plus a load check in each harness before deleting `opencode/agents/reviewer.md`.
- **Count assertions in `doctor.sh`**: skill count changes shape (canonical move + new `orchestrate`); update expected counts or the check fails red. Include in tasks.
- **Third-party skill drift**: the 11-skill core includes no third-party skills (all are local Superpowers-lineage), so no upstream rebase conflict in this change.
- **Dispatch overhead**: 5 agents risk over-fan-out; the skill caps batches at 3–5 and prefers one `writer` over scout+writer+reviewer chains for small slices.
- **`opencode/skills` → symlink churn**: `git` records a symlink replacing a directory; collaborators with the old tree get a conflict on pull. Mitigate with a README note and the install backup path.
