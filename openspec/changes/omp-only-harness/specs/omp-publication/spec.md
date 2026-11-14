# OMP-only publication

## ADDED Requirements

### Requirement: Canonical trees publish directly into the OMP agent directory

The repository SHALL publish `skills/`, `agents/`, `commands/`, and
`skills-janitor/` as symlinks directly under `~/.omp/agent/`, and SHALL
publish `omp/AGENTS.md`, `omp/APPEND_SYSTEM.md`, `omp/config.yml`, and
`omp/mcp.json` to their OMP destinations. The installer MUST NOT create or
require any path under `~/.config/opencode` or `~/.codex`.

#### Scenario: Fresh install

- **WHEN** `./install.sh` runs on a machine without an OMP config
- **THEN** every canonical tree is a symlink under `~/.omp/agent/`
- **AND** no `~/.config/opencode` directory is created
- **AND** `./doctor.sh` exits 0

### Requirement: Legacy repository links are pruned safely

The installer SHALL remove a legacy OpenCode or Codex path only when it is a
symlink whose resolved target is inside this repository. It MUST move the
link to the backup directory before removal. It MUST NOT remove regular
files, real directories, or links to other targets.

#### Scenario: Old OpenCode link

- **WHEN** `~/.config/opencode/skills` is a symlink into this repository
- **THEN** `./install.sh` moves that symlink to the backup directory
- **AND** the path no longer exists afterward

#### Scenario: User file

- **WHEN** `~/.config/opencode/opencode.jsonc` is a regular file
- **THEN** `./install.sh` leaves it untouched

### Requirement: Doctor validates the OMP tree

`./doctor.sh` SHALL verify the OMP executables, every published link, the
absence of broken links under `~/.omp/agent`, the canonical skill count, the
canonical command count, and the five role agents. It MUST NOT check
OpenCode or Codex publication.

#### Scenario: Broken OMP link

- **WHEN** `~/.omp/agent/skills` points to a missing path
- **THEN** `./doctor.sh` exits non-zero and reports the broken link
