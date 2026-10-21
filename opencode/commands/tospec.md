---
description: Criar spec OpenSpec completa (proposal + design + tasks)
subtask: false
---
Carregue a skill `openspec-propose` (skill tool, id `openspec-propose`) e siga-a exatamente,
tratando o texto abaixo como o nome do change ou a descrição do pedido.

$ARGUMENTS

**Modos de planning.** Sem flag = interativo (comportamento atual): rode nesta sessão
(N0), em diálogo com o humano — pergunte uma coisa por vez, apresente cada artefato
(proposal, design, tasks) seção por seção e só siga após aprovação; levante contexto do
código com o papel `scout` em paralelo às perguntas. Com `--direct` = automático com gate
mínimo: classifique o pedido em uma frase (spike/bounded/architectural), confirme o scope
em uma linha e prossiga só após esse único ok; depois escreva os artefatos sem rodadas de
perguntas. Em qualquer modo, escreva cada artefato em arquivo antes de prosseguir. Nunca
despache `writer` nem edite código.

O planning pode cobrir 1 ou N tasks/fatias na mesma sessão: cada uma vira uma linha
própria com status `queued` no `queue.md` do change. Entrega: `orchestration.md` com
status `planned`, a fila preenchida e o próximo passo — handoff para o worker.

**Oferta Herdr (fim do planning).** Encerre com uma pergunta única e 3 opções: (1) abrir
um worker em pane Herdr nova, (2) executar aqui mesmo, (3) deixar na fila. O default é 3:
nunca auto-inicie o worker e nunca abra pane sem um "sim" explícito.

Pare ao final e espere revisão — nada de código ainda.
