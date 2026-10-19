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
- liga (symlink) `opencode.jsonc`, `AGENTS.md`, `commands/`, `skills/` e
  `plugins/adaptive-thinking.js` do repositorio para o OpenCode;
- liga a arvore canonica `skills/` em `~/.codex/skills`; `opencode/skills` e um
  symlink interno para `../skills`, entao o destino publicado nao muda;
- liga a arvore canonica `agents/` em `~/.config/opencode/agents`;
  `opencode/agents` e um symlink interno para `../agents`;
- liga `~/.omp/agent/{AGENTS.md,config.yml,mcp.json}` no OMP;
- liga `~/.omp/agent/{commands,skills,agents}` ->
  `~/.config/opencode/{commands,skills,agents}`
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
home da maquina no que vai para o Git, presenca dos skills compartilhados
(contagem derivada de `skills/`), 20 commands, os 5 role agents canonicos, o
alvo `~/.codex/skills`, o gateway do `sleev` em `127.0.0.1:17321` e a presenca
opcional das integracoes geradas por Orca/herdr. Falta de auth, gateway ou
integracao externa vira aviso com a instrucao manual; erro estrutural falha com
exit 1.

## Estrutura

```
skills/              fonte canonica das skills compartilhadas (46)
  <skill>/SKILL.md
  <skill>/references/{omp,opencode,codex}-tools.md
agents/              arvore canonica dos role agents (scout, writer, reviewer, mechanic, orchestrator)
opencode/            config do harness OpenCode
  opencode.jsonc     modelos, permissoes, providers e MCPs
  AGENTS.md          workflow global
  skills -> ../skills    symlink para a arvore canonica
  agents -> ../agents    symlink para a arvore canonica
  commands/          20 comandos compartilhados
  skills-janitor/    engine dos skills janitor (scan, lint, security, swipe, mcp)
  plugins/adaptive-thinking.js
  cli.json           seed (Orca/herdr reescrevem)
  tui.jsonc          seed (Orca/herdr reescrevem)
omp/
  AGENTS.md          workflow global do OMP
  config.yml         modelos, presets, temas e guardrails de shell
  mcp.json           MCPs do OMP (serena via PATH)
  plugins/omp-plugins.lock.json   declaracao de i-have-adhd@0.4.1
  marketplaces.json               seed; ${HOME} e resolvido na copia
mapping.sh           mapa origem->destino usado por install.sh e doctor.sh
```

`skills/` e a fonte unica das skills: `opencode/skills` e um symlink interno
para `../skills`, o `~/.codex/skills` recebe a mesma arvore e o OMP continua
apontando para o que o OpenCode publica. `agents/` segue o mesmo desenho:
`opencode/agents` e um symlink interno para `../agents`, o
`~/.config/opencode/agents` publica a arvore canonica e
`~/.omp/agent/agents` deriva dela (segunda ordem). Os 5 role agents sao os
mesmos nos dois harnesses. `opencode/commands` segue como fonte unica dos
comandos, e a excecao orfa `context-update.md` foi removida (o comando valido e
`context.md`).

Nota para colaboradores: `opencode/skills` e `opencode/agents` deixaram de ser
diretorios e viraram symlinks para `../skills` e `../agents`; num checkout antigo
o `git pull` registra a troca e o `install.sh` move o link/diretorio publicado
para o backup antes de recriar. Edite skills em `skills/` e agents em `agents/`,
nunca nos caminhos internos do OpenCode.

## Skills de terceiros

17 das 46 skills vem de repositorios externos. O `npx skills add` grava em
`~/.agents/skills` (estado nao versionado); aqui elas ficam na fonte unica com a
procedencia registrada:

| Origem | Skills |
| --- | --- |
| `khendzel/skills-janitor` | janitor-report, janitor-security, janitor-swipe, janitor-value |
| `trailofbits/skills` | semgrep, codeql, sarif-parsing, sharp-edges, differential-review |
| `hqhq1025/skill-optimizer` | skill-generalizer, skill-miner, skill-personalizer |
| `anthropics/skills` | skill-creator |
| `hermes-labs-ai/lintlang` | lintlang, lintlang-audit |
| `muratcankoylan/Agent-Skills-for-Context-Engineering` | tool-design |
| `Graphify-Labs/graphify` | graphify (skill gerada pelo proprio CLI, nao pelo `npx skills`) |

O `graphify` nao vem do `npx skills`: o CLI e um pacote Python e a skill e escrita
por ele direto na arvore canonica. Instalar/atualizar:

```sh
uv tool install "graphifyy[leiden]"      # CLI (PyPI graphifyy, com double-y)
graphify install --platform opencode     # escreve em $CONFIG_DIR/skills/graphify (link -> skills/graphify)
uv tool upgrade graphifyy                # atualizar; depois repita o install
```

O guard do OMP (`graphify pi guard install` + `omp plugin install`) nao esta
instalado de proposito: ele intercepta read/grep/find/bash e, com
`GRAPHIFY_HOOK_STRICT=1`, nega leitura com grafo desatualizado.

Para atualizar do upstream e trazer para a fonte unica (skills do `npx skills`):

```sh
npx skills add <owner/repo> --skill <nome> -g -y -a opencode
cp -r ~/.agents/skills/<nome> ~/.local/share/ai-agent-config/skills/
rm -r ~/.agents/skills/<nome>
```

As skills `janitor-*` foram adaptadas para este ambiente: invocam o engine em
`opencode/skills-janitor/` (publicado pelo install.sh em
`~/.config/opencode/skills-janitor/`) e o engine le os fontes locais do OMP
(`~/.omp/agent/sessions`, `~/.omp/agent/history.db`, `~/.omp/agent/mcp.json`).
Um update do upstream por cima perde essas adaptacoes; porte o diff.

O estado gerado pelo engine (usage-history, deck, changelog) fica em
`~/.local/state/ai-agent-config/skills-janitor/`, fora do Git.

Nao adotadas: `UiPath/coder_eval` (skill `check-skill`) depende do CLI
`coder-eval` e dos templates `${CLAUDE_PLUGIN_ROOT}/reference/*`, que nao
existem no diretorio da skill.

## context-mode (roteamento de saida grande)

O servidor MCP `context-mode` esta no `mcp.json` e o plugin grava seus hooks
(`session_start`, `tool_result`, `session_before_compact`) em
`~/.omp/context-mode/sessions/*.db`. O adapter do OMP nao registra hook de
tool-call, entao as regras de roteamento sao a unica barreira: elas vivem em
`omp/APPEND_SYSTEM.md` e o install.sh publica em `~/.omp/agent/APPEND_SYSTEM.md`
(rota aditiva — so a sessao principal recebe; subagente nao herda).

O `mcp.sh` do janitor conta tambem os eventos de hook, alem das chamadas MCP:
para servidores assim, `0` na coluna Calls nao significa "nunca usado".

## Guardrails de shell

`omp/config.yml` (`bash.patterns`) e `opencode/opencode.jsonc` (`permissions`)
mantem os mesmos limites, com uma excecao consciente:

| Comando | omp | opencode |
| --- | --- | --- |
| `git push` | `prompt` | `ask` |
| `git reset --hard`, `git clean` | deny | deny |
| `rm -rf` / `rm -fr` / `rm -r -f` | deny | deny |
| `sudo` | deny | deny |

Push pede confirmacao a cada chamada (padrao `prompt` explicito nao entra no
"always allow" da sessao); o resto segue negado mesmo com autoaccept/yolo.

Por que nao existe bypass por skill/command: `deny` e `prompt` resolvem antes do
`BashTool.execute()`, entao conteudo de prompt (skill, command, AGENTS.md) nao
altera politica de ferramenta — so a config altera.

Furo conhecido e aceito: `bash.patterns` nao cobre o tool `eval`, que declara o
tier `exec` e pode spawnar `bash -c`, e `tools.approval` esta vazio. Um `eval`
consegue, portanto, rodar comando que o bash nega. Fechar isso e
`tools.approval.eval: prompt` (custo: todo eval passa a pedir aprovacao).

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
