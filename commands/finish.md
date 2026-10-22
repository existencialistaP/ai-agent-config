---
description: Verificar e fechar spec/task com evidência
subtask: false
---
Carregue as skills `openspec-verify-change` e `verification-before-completion`
(skill tool) e siga-as exatamente, tratando o texto abaixo como o nome do change
ou argumentos.

Use a skill `orchestrate` (skill tool) para as decisões de fatiamento e transporte
(direct / task batch / Herdr / handoff) quando a verificação se dividir em slices
independentes; uma slice única é verificada diretamente.

$ARGUMENTS

## Checklist:
1. **Diff resumido**: `git diff --stat` (abra o diff inteiro só se necessário).
2. **Spec alinhado?** Compare com o change em `openspec/changes/<nome>/`; confirme os tasks `- [x]`.
3. **Testes/Lint**: rode os comandos do projeto e cole os outputs.
4. **Problemas?** Se houver falhas: corrija e re-execute `/feature`.

> ❌ NÃO declare "pronto" sem evidência passo a passo
