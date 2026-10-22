# Proposal

## Why

The repository publishes the same trees to OpenCode and OMP, but only OMP is
used. The OpenCode half is dead weight: `opencode/opencode.jsonc`,
`cli.json`, `tui.jsonc`, the OpenCode-only plugin, the OpenCode `AGENTS.md`,
and the derived-link publication path. OpenCode v2.1.2 also does not follow
the symlinked global `agents/` directory, so those published agents never
load there (verified with `opencode debug agents`). Keeping a second harness
costs maintenance, hides real failures, and adds prompt/config noise.

At the same time, the OMP setup lacks four workflow pieces that the
oh-my-opencode-slim project (MIT, 9.7k stars) has proven useful:
evidence planning before implementation, an anti-snowball step-back, a
behavior-preserving simplification skill, and multi-model council review.

## What Changes

- Remove the OpenCode harness from the repository. `opencode/` is deleted;
  `commands/` and `skills-janitor/` move to the repository root as canonical
  trees.
- Publish everything directly into `~/.omp/agent/` (`skills`, `agents`,
  `commands`, `skills-janitor`, plus the OMP config files). No derived links,
  no `~/.config/opencode`, no `~/.codex` publication.
- On install, prune legacy links that point into this repository from
  `~/.config/opencode` and `~/.codex`, moving them to the backup directory
  first. User-mutated seeds are left alone.
- Port four skills from oh-my-opencode-slim, adapted to OMP primitives:
  `verification-planning`, `step-back`, `simplify`, and `council` (with a
  `/council` command).
- Enrich the orchestration layer: per-role Delegate/Don't routing verdicts in
  `agents/orchestrator.md`, painter passes and pass gates in
  `skills/executing-plans`, per-role model overrides in `omp/config.yml`, and
  a repeated-tool-call rule in `omp/AGENTS.md`.
- Update `install.sh`, `doctor.sh`, `mapping.sh`, tests, and `README.md` for
  the OMP-only layout.

## Out of Scope

- No plugin runtime, hooks, marketplace, interview UI, presets, or codemap
  script from oh-my-opencode-slim.
- No new role agents. Council seats reuse the existing read-only `reviewer`
  with per-task model overrides.
- No deletion of user state under `~/.config/opencode` beyond links that
  resolve into this repository.
- No push or PR.
