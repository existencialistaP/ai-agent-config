# ai-agent-config

Configuracao versionada do harness **OMP** (Oh My Pi): skills, role agents,
commands, o motor dos skills janitor e os arquivos de configuracao do OMP.

## Instalacao

```sh
git clone https://github.com/existencialistaP/ai-agent-config.git ~/.local/share/ai-agent-config
~/.local/share/ai-agent-config/install.sh
~/.local/share/ai-agent-config/doctor.sh
```

O `install.sh`:

- cria `~/.omp/agent`;
- liga (symlink) `omp/AGENTS.md`, `omp/APPEND_SYSTEM.md`, `omp/config.yml` e
  `omp/mcp.json` nos destinos do OMP;
- liga as arvores canonicas `skills/`, `agents/`, `commands/` e
  `skills-janitor/` diretamente em `~/.omp/agent/`;
- copia os seeds mutaveis (`omp-plugins.lock.json`, `marketplaces.json`)
  **somente** se ainda nao existirem no destino;
- move qualquer conflito real para
  `~/.local/state/ai-agent-config/backups/<timestamp>/` antes de criar o link;
- remove links legados que apontam para este checkout (layout antigo em
  `~/.config/opencode/*` e `~/.codex/skills`), sempre com backup. Arquivos
  reais, diretorios reais e links de terceiros ficam intocados.

Nenhum passo le, copia ou restaura credencial: auth, bancos, sessoes, caches e
`contexts/` ficam de fora e nunca sao tocados.

Previa sem efeito colateral:

```sh
./install.sh --dry-run
```

## doctor.sh

Confere executaveis (`omp`, `serena`, `openwiki`, `sleev`), resolucao de todos
os links, ausencia de links quebrados em `~/.omp/agent`, ausencia do caminho do
home da maquina no que vai para o Git, contagem de skills (derivada de
`skills/`), 21 commands, os 5 role agents canonicos, o gateway do `sleev` em
`127.0.0.1:17321` e a presenca opcional do plugin `i-have-adhd`. Falta de auth,
gateway ou plugin vira aviso com a instrucao manual; erro estrutural falha com
exit 1. Um link legado que ainda aponte para este repositorio tambem falha: a
migracao do layout OpenCode nao rodou.

## Estrutura

```
skills/              fonte canonica das skills compartilhadas (52)
  <skill>/SKILL.md
  <skill>/references/{omp,opencode,codex}-tools.md
agents/              arvore canonica dos role agents (scout, writer, reviewer, mechanic, orchestrator)
commands/            fonte unica dos 21 comandos compartilhados
skills-janitor/      engine dos skills janitor (scan, lint, security, swipe, mcp)
omp/
  AGENTS.md          workflow global do OMP
  APPEND_SYSTEM.md   roteamento do context-mode
  config.yml         modelos, presets, temas e guardrails de shell
  mcp.json           MCPs do OMP (serena via PATH)
  plugins/omp-plugins.lock.json   declaracao de i-have-adhd@0.4.1
  marketplaces.json               seed; ${HOME} e resolvido na copia
mapping.sh           mapa origem->destino usado por install.sh e doctor.sh
```

`skills/`, `agents/`, `commands/` e `skills-janitor/` sao a fonte unica:
`~/.omp/agent/` recebe um symlink para cada uma, e o OMP segue esses links. Nao
existe mais publicacao para OpenCode nem para Codex.

As skills continuam portaveis: os corpos do core nao citam harness e cada uma
traz adapters em `references/`. O OMP usa `references/omp-tools.md`; os arquivos
`opencode-tools.md` e `codex-tools.md` ficam como documentacao de portabilidade,
nao como caminho de execucao deste repo. A excecao e `council`, que usa
deliberadamente os primitivos do OMP (`task`, `wait`, `agent://`).

## Skills de terceiros

21 das 52 skills vem de repositorios externos. O `npx skills add` grava em
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
| `Graphify-Labs/graphify` | graphify (skill gerada pelo proprio CLI) |
| `alvinunreal/oh-my-opencode-slim` | verification-planning, step-back, simplify, council |

O `graphify` nao vem do `npx skills`: o CLI e um pacote Python e a skill e
escrita por ele direto na arvore canonica. Instalar/atualizar:

```sh
uv tool install "graphifyy[leiden]"      # CLI (PyPI graphifyy, com double-y)
graphify install --platform opencode     # gera a skill no diretorio do harness
uv tool upgrade graphifyy                # atualizar; depois repita o install
```

Este repo nao publica mais em `~/.config/opencode`: se o `graphify install`
gravar la, copie a skill gerada para `skills/graphify` na arvore canonica e
rode `./install.sh`.

O guard do OMP (`graphify pi guard install` + `omp plugin install`) nao esta
instalado de proposito: ele intercepta read/grep/find/bash e, com
`GRAPHIFY_HOOK_STRICT=1`, nega leitura com grafo desatualizado.

Para atualizar do upstream e trazer para a fonte unica (skills do `npx skills`):

```sh
npx skills add <owner/repo> --skill <nome> -g -y -a opencode
cp -r ~/.agents/skills/<nome> ~/.local/share/ai-agent-config/skills/
rm -r ~/.agents/skills/<nome>
```

O `-a opencode` e apenas o rotulo do fetcher; a skill e copiada para a arvore
canonica e publicada no OMP pelo `install.sh`.

As quatro skills adaptadas de `oh-my-opencode-slim` foram reescritas para os
primitivos do OMP, sem plugin nem hooks:

- **verification-planning** — desenha o caminho de evidencia antes da
  implementacao (claim, incerteza, affordance, budget). Complementa
  `verification-before-completion`, que continua sendo o gate final.
- **step-back** — interrompe empilhamento de patches/workarounds e propoe uma
  direcao mais limpa antes de continuar.
- **simplify** — refactor preservando comportamento, com foco em clareza.
- **council** — tres revisoes independentes em modelos diferentes, sintetizadas
  em um veredito. Opt-in, nunca gate padrao.

As skills `janitor-*` foram adaptadas para este ambiente: invocam o engine em
`skills-janitor/` (publicado em `~/.omp/agent/skills-janitor/`) e o engine le os
fontes locais do OMP (`~/.omp/agent/sessions`, `~/.omp/agent/history.db`,
`~/.omp/agent/mcp.json`). Um update do upstream por cima perde essas
adaptacoes; porte o diff.

O estado gerado pelo engine (usage-history, deck, changelog) fica em
`~/.local/state/ai-agent-config/skills-janitor/`, fora do Git.

Nao adotadas: `UiPath/coder_eval` (skill `check-skill`) depende do CLI
`coder-eval` e dos templates `${CLAUDE_PLUGIN_ROOT}/reference/*`, que nao
existem no diretorio da skill.

## Council

O council e um modo opt-in para decisoes caras:

```text
/council qual migracao e mais segura para este schema?
```

ou peça em linguagem natural ("rode um council sobre estas duas arquiteturas").

O N0 dispara tres tarefas `reviewer` read-only em um unico batch, cada uma com
um modelo diferente (`commandcode/gpt-5.6-sol`, `commandcode/zai-org/GLM-5.3`,
`commandcode/moonshotai/Kimi-K3` por padrao), e sintetiza veredito, confianca,
achados por cadeira e dissenso. As cadeiras nao se veem; a independencia e o
ponto. Ajuste os modelos em `skills/council/SKILL.md` para os que voce tem
habilitados.

O modelo de cada role agent pode ser fixado em `omp/config.yml`
(`task.agentModelOverrides`): `orchestrator` e `reviewer` no modelo forte,
`scout` e `mechanic` no flash rapido, `writer` no flash padrao.

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

`omp/config.yml` (`bash.patterns`) mantem os limites:

| Comando | omp |
| --- | --- |
| `git push` | `prompt` |
| `git reset --hard`, `git clean` | deny |
| `rm -rf` / `rm -fr` / `rm -r -f` | deny |
| `sudo` | deny |

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

- Autenticacao do OMP e do provider local.
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

## Migracao do layout OpenCode

Versoes anteriores publicavam em `~/.config/opencode` e derivavam o OMP de la.
O `install.sh` atual remove, com backup, apenas os symlinks que apontam para
este checkout:

- `~/.config/opencode/{opencode.jsonc,AGENTS.md,commands,skills,agents,skills-janitor,plugins/adaptive-thinking.js}`
- `~/.codex/skills`

`cli.json`, `tui.jsonc` e qualquer arquivo real permanecem. Se o `doctor.sh`
ainda acusar link legado, rode `./install.sh` de novo.

## Nao versionado

Runtime e estado do harness: `contexts/`, `vendor/`, `.serena/`,
`node_modules/`, `auth.json`, `account.json`, `service.json`, `.env*`, bancos e
WAL/SHM, logs, sessoes, caches, backups e AppImages.

O OMP reescreve `~/.omp/agent/config.yml` (versao de setup, tema, presets)
atravessando o link: revise `git diff` antes de commitar.

## Testes

```sh
shellcheck -x install.sh doctor.sh mapping.sh
bats tests/install.bats
```

Os testes usam `HOME` descartavel e executaveis falsos em `tests/fakes/`; nao
tocam rede, credenciais ou o home real.

## Mudanca de escopo

Este repo e OMP-only por decisao explicita. O layout OpenCode foi removido em
`openspec/changes/omp-only-harness/`; nao reintroduza publicacao para outro
harness sem um change novo.
