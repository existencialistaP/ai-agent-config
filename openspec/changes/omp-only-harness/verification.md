# Verification - omp-only-harness

Date: 2026-10-22

## `./init.sh`

```text
[doctor] link: $HOME/.omp/agent/AGENTS.md
[doctor] link: $HOME/.omp/agent/APPEND_SYSTEM.md
[doctor] link: $HOME/.omp/agent/config.yml
[doctor] link: $HOME/.omp/agent/mcp.json
[doctor] link: $HOME/.omp/agent/skills
[doctor] link: $HOME/.omp/agent/agents
[doctor] link: $HOME/.omp/agent/commands
[doctor] link: $HOME/.omp/agent/skills-janitor
[doctor] skills compartilhados: 52
[doctor] agents canonicos: 5
[doctor] commands compartilhados: 21
[doctor] sem comando orfao (context-update.md)
[doctor] gateway do sleev em 127.0.0.1:17321
[doctor] plugin i-have-adhd@0.4.1 instalado
[doctor] 0 erro(s), 0 aviso(s)
1..10
ok 1 install publica as arvores canonicas em ~/.omp/agent
ok 2 conflito real vai para backup e a segunda execucao nao cria backup novo
ok 3 seeds ausentes sao instalados com o home resolvido
ok 4 seeds nunca sobrescrevem a versao live
ok 5 --dry-run nao cria diretorio, backup, copia nem link
ok 6 opcao desconhecida encerra com 2
ok 7 install remove link legado que aponta para o repo
ok 8 install preserva arquivo real no caminho legado
ok 9 doctor passa depois do install
ok 10 doctor acusa link quebrado
[init] ok: doctor + install --dry-run + bats + shellcheck
```

## Live migration

```text
[install] backup: $HOME/.config/opencode/opencode.jsonc -> .../20261022T165120/.config-opencode-opencode.jsonc
[install] backup: $HOME/.config/opencode/AGENTS.md -> .../20261022T165120/.config-opencode-AGENTS.md
[install] backup: $HOME/.config/opencode/commands -> .../20261022T165120/.config-opencode-commands
[install] backup: $HOME/.config/opencode/skills -> .../20261022T165120/.config-opencode-skills
[install] backup: $HOME/.config/opencode/agents -> .../20261022T165120/.config-opencode-agents
[install] backup: $HOME/.config/opencode/skills-janitor -> .../20261022T165120/.config-opencode-skills-janitor
[install] backup: $HOME/.config/opencode/plugins/adaptive-thinking.js -> .../20261022T165120/.config-opencode-plugins-adaptive-thinking.js
[install] backup: $HOME/.codex/skills -> .../20261022T165120/.codex-skills
[install] backup: $HOME/.omp/agent/skills -> .../20261022T165120/.omp-agent-skills
[install] backup: $HOME/.omp/agent/agents -> .../20261022T165120/.omp-agent-agents
[install] backup: $HOME/.omp/agent/commands -> .../20261022T165120/.omp-agent-commands
```

The installer kept real files (`cli.json`, `tui.json`, `contexts/`, plugins,
herdr files) untouched; only symlinks into this checkout were moved.

## Runtime smoke

A fresh OMP process loaded the four new skills:

```text
$ omp --model commandcode/deepseek/deepseek-v4.1-flash-fast --mode=text \
    "Read skill://council, skill://verification-planning, skill://step-back and skill://simplify ..."
council
verification-planning
step-back
simplify
```

The long-running session used during this change predates the new files, so
its in-memory skill registry still lists the old set; a restart picks them up.
The five role agents (`orchestrator`, `reviewer`, `scout`, `writer`,
`mechanic`) were already visible in that session.

## Janitor smoke

```text
$ bash skills-janitor/scripts/scan.sh
... JSON output ...
exit 0
```

The engine reads `~/.omp/agent/skills` (platform label `OMP`) plus the
Claude/Codex trees when present.
