# Design

## Context

- OMP loads `~/.omp/agent/{skills,agents,commands}` through symlinks; the
  symlinked canonical trees work there (verified in the running session).
- OpenCode v2.1.2 does not follow a symlinked global `agents/` directory, so
  the old publication model never delivered the five role agents to OpenCode.
  Removing OpenCode also removes that failure mode.
- `skills-janitor` is harness-agnostic but was published under the OpenCode
  config dir. Its scripts read `$HOME/.config/opencode/skills`; they must be
  repointed to `$HOME/.omp/agent/skills`.

## Goals

- One harness (OMP), one publication root (`~/.omp/agent`), one canonical
  tree per asset type.
- Install/doctor/tests prove the OMP tree, not a derived OpenCode tree.
- Add the four upstream workflows without adding a second tracker or new
  default agents.

## Non-Goals

- No OpenCode compatibility layer, no Codex publication.
- No `.slim/` state directory; OpenSpec remains the only tracker.
- No change to the shell guardrails or the context-mode routing rules.

## Decisions

### 1. Canonical trees at the repository root

`skills/`, `agents/`, `commands/`, `skills-janitor/`, and `omp/` are the only
sources. `mapping.sh` maps each directly to `~/.omp/agent/<name>` or to the
OMP config file. `link_derived` disappears.

Alternative rejected: keep `opencode/` as a symlink farm. It preserves dead
paths and keeps the misleading second-harness contract.

### 2. Legacy links are pruned by target, not by path

`install.sh` walks a fixed legacy list. A path is removed only when it is a
symlink whose resolved target is inside `REPO_ROOT`; it goes to the standard
backup directory first. Regular files, real directories, and links to other
targets are untouched. This cleans the machine without deleting user state.

### 3. Council without new agents

OMP's `task` accepts a per-task `model`. The council skill dispatches three
independent read-only `reviewer` tasks in one batch, each on a different
model, then synthesizes. Seats never see each other. If the N0 model is
weaker than the seats, a fourth `reviewer` dispatch with the strongest model
synthesizes from the three `agent://` outputs. No `councillor-*` roster.

Alternative rejected: three static councillor agents. It grows the roster,
requires config per harness, and duplicates the same prompt.

### 4. Deepwork is a mode of executing-plans, not a new tracker

The painter passes (`sketch`, `structure`, `detail`), one gate per pass, a
ranked known-issues list, and the "never defer security or data correctness"
rule go into `skills/executing-plans/SKILL.md`. State stays in
`openspec/changes/<change>/tasks.md` plus `orchestration.md`.

Alternative rejected: porting `.slim/deepwork/<slug>/progress.md`. It would
create a second tracker and violate the repository state rule.

### 5. Verification planning complements, not replaces, the completion gate

`verification-before-completion` stays the post-hoc gate.
`verification-planning` runs before implementation and designs the evidence
path. Both use the same rule: no claim without evidence.

## Risks / Trade-offs

- **Loss of OpenCode portability.** Accepted: the harness is OMP-only.
- **Legacy pruning could surprise.** Mitigated by matching only symlinks that
  resolve inside the repository and by backing them up first.
- **Council cost.** Three seats on strong models is expensive. The skill is
  explicit that it is opt-in and not a default verification step.
- **Model overrides may not apply to every OMP build.** `task.agentModelOverrides`
  already carries `reviewer`; the new entries follow the same shape. If a
  build ignores an entry, the agent falls back to the session model.
