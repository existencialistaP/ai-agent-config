# omp — workflow global

## Fluxo SDD
1. `/opsx-propose` (ou `/tospec`): cria o change OpenSpec. Só planejamento, sem código. Pare e espere minha revisão.
2. `/opsx-apply` (ou `/feature`): executa as tasks do change, marcando os checkboxes. Siga até concluir ou travar.
3. `/opsx-verify` (ou `/finish`): verificação com evidência antes de dar como pronto.

## Roteamento
Antes de trabalho não trivial, escolha e **declare** o transporte; o loop e o contrato de dispatch estão na skill `orchestrate`.

| Situação | Transporte |
| --- | --- |
| 1 arquivo, leitura pontual, trabalho curto | direto |
| 2+ fatias independentes no mesmo checkout, 1 writer por arquivo | `task` em batch (3–5) |
| Trabalho longo, observável ou checkout isolado | Herdr (`HERDR_ENV=1`) |
| Outra sessão/dono continua | handoff (grave o estado em arquivo antes) |

Papéis `scout`/`writer`/`reviewer`/`mechanic` vivem em `agents/`; a skill `orchestrate` é a fonte do roteamento.

## Guardrails
- OpenSpec é a única fonte de verdade; não crie outro spec/plano.
- Sem afirmar sucesso sem evidência de verificação recente.
- Git: código vai para branch nova com prefixo (`feat/`, `fix/`) + commit. O `push` fica sob `deny` em `bash.patterns` (sob `yolo`, `prompt` não segura push), então eu preparo branch, corpo do PR e o comando exato — o push e o PR são seus.
- Com `yolo` ligado eu não peço aprovação de ferramenta, mas ainda **peço antes** de: instalar dependência, deletar arquivo que não criei, mudar contrato público (API/schema/migração), push/PR.
