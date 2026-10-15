# omp — workflow global

Importado do OpenCode/jcode em 2026-10-14. Skills em `~/.omp/agent/skills`,
commands em `~/.omp/agent/commands` (symlinks; a fonte canônica continua em
`~/.config/opencode/`).

## Fluxo
1. `/opsx-propose` (ou `/tospec`): cria o change OpenSpec. Só planejamento, sem código. Pare e espere minha revisão.
2. `/opsx-apply` (ou `/feature`): executa as tasks do change, marcando os checkboxes. Siga até concluir ou travar.
3. `/opsx-verify` (ou `/finish`): verificação com evidência antes de dar como pronto.

## Regras
- OpenSpec é a única fonte de verdade; não crie outro spec/plano.
- Trabalho não trivial exige spec aprovado antes de implementar.
- Sem afirmar sucesso sem evidência de verificação recente.
- Reutilize o código existente; mantenha mudanças no escopo.
- Mudança mínima que resolve (YAGNI): ataque a causa raiz; nunca corte validação nem segurança, e diga o que ficou de fora.
- Ao iniciar num repo, leia `~/.config/opencode/contexts/<slug>.md` (skill `context`). O código vence o mapa.

## Ferramentas
- Arquivos: leia com `read`/`grep`/`ast_grep`/`edit` em vez de `cat`/`grep`/`ls` no bash (resultado focado, menos token).
- Serena (MCP): navegação/refactor por símbolo (prefira a grep/read em renomeações e moves).
- Context7 (MCP): consultar docs antes de usar biblioteca externa.
- Nível de thinking: só mude quando a dificuldade mudar (`--thinking`/`/model`).
- beads (`bd`): se o repo tiver `.beads/`.
- Skills fora do fluxo: `/skill:<nome>` (ex.: `systematic-debugging`, `test-driven-development`, `verification-before-completion`).
- Subagentes: skills importadas falam em `general-purpose`/`explore` (nomes do opencode). No omp use `task` (genérico), `scout` (exploração read-only), `code-reviewer` (review read-only) e `sonic` (mecânico).
