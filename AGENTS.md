# ai-agent-config — instruções do repo

Fonte canônica dos harnesses OpenCode e OMP. O workflow global de SDD e
roteamento vem do `AGENTS.md` publicado pelo harness; este arquivo cobre apenas
o desenvolvimento deste repositório.

## Startup Workflow

- Leia `README.md`, `mapping.sh` e o change ativo em
  `openspec/changes/<change>/tasks.md` antes de editar.
- Retome do primeiro `- [ ]`. One feature at a time: um change ativo por vez;
  não abra outro em paralelo.
- Edite a fonte canônica (`skills/`, `agents/`, `opencode/commands/`,
  `opencode/opencode.jsonc`, `omp/`) e publique com `./install.sh`.
- Nunca edite os caminhos publicados diretamente; eles são symlinks.

## Definition of Done

- `./init.sh` verde (doctor + dry-run + bats + shellcheck).
- `openspec/changes/<change>/tasks.md` com todas as tasks do escopo em `- [x]`.
- Diff revisado; nenhum link publicado apontando para fora da árvore canônica.
- `/opsx-verify` com o output dos comandos colado. Sem evidência fresca, não está pronto.
- Evidence: cole o comando e o output no change ou no report final.
- Push e PR são do usuário: prepare a branch e o comando, não execute.

## Verification Commands

- `./init.sh` — entrypoint único: `./doctor.sh`, `./install.sh --dry-run`,
  `bats tests/install.bats` e `shellcheck -x doctor.sh install.sh mapping.sh`.
- `./doctor.sh` — links, contagens, paths fixos e integrações.
- `./install.sh --dry-run` — simula a publicação sem criar link, cópia ou backup.
- `bats tests/install.bats` — testes de instalação e conflito.
- `shellcheck -x doctor.sh install.sh mapping.sh` — lint dos scripts.

## State

- Estado canônico: `openspec/changes/<change>/tasks.md`.
- Em orquestração: `orchestration.md` no diretório do change, com
  slice → owner/status/checkpoint/next; `dispatch/<slice>.md` e
  `<slice>-result.md` para os briefs e relatórios.
- Não crie `feature_list.json` nem `progress.md`: o OpenSpec é o único tracker.

## Stay in scope

- Só o change ativo. Fora dele: pare e proponha, sem editar.
- Skills fora do core SDD (`codeql`, `semgrep`, `ponytail/*`, janitor) só com
  pedido explícito.
- Não renomeie, reformate nem refatore arquivos não tocados pelo change.
- Um writer por arquivo; em batch, fatias disjuntas.

## End of Session

- Rode `/handoff`: grava `.opencode-handoff.md` na raiz do repo ativo com
  `Last Updated`, `Current Objective`, `Files`, `Blockers` e `Next Session`.
- Se parar no meio de um change, deixe as tasks não concluídas como `- [ ]` e
  registre o comando exato que falhou.
- Template: `session-handoff.md`.
- Clean restart: leia o handoff e retome do primeiro `- [ ]`.
