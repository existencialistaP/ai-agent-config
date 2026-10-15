# ai-agent-config

Configuracao compartilhada de **OpenCode** e **OMP** (Oh My Pi) num único
repositorio: os dois harnesses usam os mesmos `commands` e `skills`, e cada um
mantem o proprio agente de review.

## Instalacao

```sh
git clone https://github.com/existencialistaP/ai-agent-config.git ~/.local/share/ai-agent-config
~/.local/share/ai-agent-config/install.sh
~/.local/share/ai-agent-config/doctor.sh
```

O `install.sh`:

- cria `~/.config/opencode` e `~/.omp/agent`;
- liga (symlink) `opencode.jsonc`, `AGENTS.md`, `agents/`, `commands/`,
  `skills/` e `plugins/adaptive-thinking.js` do repositorio para o OpenCode;
- liga `~/.omp/agent/{AGENTS.md,config.yml,mcp.json,agents}` no OMP;
- liga `~/.omp/agent/{commands,skills}` -> `~/.config/opencode/{commands,skills}`
  (segunda ordem: o OMP consome o que o OpenCode ja publica);
- copia os seeds mutaveis (`cli.json`, `tui.jsonc`, `omp-plugins.lock.json`,
  `marketplaces.json`) **somente** se ainda nao existirem no destino;
- move qualquer conflito real para
  `~/.local/state/ai-agent-config/backups/<timestamp>/` antes de criar o link.

Nenhum passo le, copia ou restaura credencial: auth (`auth.json`), bancos,
sessoes, caches e `contexts/` ficam de fora e nunca sao tocados.

Previa sem efeito colateral:

```sh
./install.sh --dry-run
```

## doctor.sh

Confere executaveis (`opencode`, `omp`, `serena`, `openwiki`, `sleev`),
resolucao de todos os links, ausencia de links quebrados, ausencia do caminho do
home da maquina no que vai para o Git, presenca dos 29 skills e 20 commands
compartilhados, o gateway do `sleev` em `127.0.0.1:17321` e a presenca opcional
das integracoes geradas por Orca/herdr. Falta de auth, gateway ou integracao
externa vira aviso com a instrucao manual; erro estrutural falha com exit 1.

## Estrutura

```
opencode/            fonte unica de commands, skills, agents e config do OpenCode
  opencode.jsonc     modelos, permissoes, providers e MCPs
  AGENTS.md          workflow global
  agents/reviewer.md
  commands/          20 comandos compartilhados
  skills/            29 skills compartilhadas
  plugins/adaptive-thinking.js
  cli.json           seed (Orca/herdr reescrevem)
  tui.jsonc          seed (Orca/herdr reescrevem)
omp/
  AGENTS.md          workflow global do OMP
  config.yml         modelos, presets, temas e guardrails de shell
  mcp.json           MCPs do OMP (serena via PATH)
  agents/code-reviewer.md
  plugins/omp-plugins.lock.json   declaracao de i-have-adhd@0.4.1
  marketplaces.json               seed; ${HOME} e resolvido na copia
mapping.sh           mapa origem->destino usado por install.sh e doctor.sh
```

`opencode/commands` e `opencode/skills` sao a unica fonte: o OMP aponta para o
que o OpenCode publica, e a excecao orfa `context-update.md` foi removida (o
comando valido e `context.md`).

O agente `code-reviewer.md` do OMP continua proprio porque a interface dele
difere do `reviewer.md` do OpenCode.

## Deliberadamente manual

- Autenticacao de cada harness (`/login`) e do provider local.
- Plugin `i-have-adhd@0.4.1`:
  ```sh
  omp plugin marketplace add ayghri/i-have-adhd
  omp plugin install i-have-adhd@0.4.1
  ```
- Gateway do sleev:
  ```sh
  sleev setup --no-open
  # depois do login no navegador:
  sleev gateway bind --host 127.0.0.1 --port 17321 --restart
  ```
- Integracoes de Orca/herdr: geradas por esses aplicativos, ficam fora do Git.

## Nao versionado

Runtime e estado de qualquer um dos harnesses: `contexts/`, `vendor/`,
`.serena/`, `node_modules/`, `auth.json`, `account.json`, `service.json`,
`.env*`, bancos e WAL/SHM, logs, sessoes, caches, backups e AppImages.

O OMP reescreve `~/.omp/agent/config.yml` (versao de setup, tema, presets)
atravessando o link: revise `git diff` antes de commitar.

## Testes

```sh
shellcheck -x install.sh doctor.sh mapping.sh
bats tests/install.bats
```

Os testes usam `HOME` descartavel e executaveis falsos em `tests/fakes/`; nao
tocam rede, credenciais ou o home real.
