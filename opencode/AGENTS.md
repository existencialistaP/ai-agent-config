# OpenCode — workflow global

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
- Arquivos: leia com `read`/`agentgrep`/`edit` em vez de `cat`/`grep`/`ls` no bash (resultado focado, menos token).
- Serena: navegação/refactor por símbolo (prefira a grep/read em renomeações e moves).
- Context7: consultar docs antes de usar biblioteca externa.
- `set_reasoning_effort`: só quando a dificuldade mudar.
- beads (`bd`): se o repo tiver `.beads/`.
