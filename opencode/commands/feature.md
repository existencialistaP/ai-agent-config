---
description: Implementar spec OpenSpec aprovada ou muda pequena direta
subtask: false
---
Se houver spec OpenSpec aprovada: carregue as skills `openspec-apply-change` e
`test-driven-development` (skill tool) e siga-as exatamente, tratando o texto abaixo
como o nome do change ou argumentos. Execute as tasks marcando `- [x]` conforme cada
uma conclui.

$ARGUMENTS

## Se for muda pequena (sem spec):
1. Entenda → escreva teste → código → teste passa
2. Rode linters/tests do projeto

## Qualidade:
- Sem código morto
- Sem `console.log`
- Edge cases tratados
- Siga padrões existentes

Reporte o diff final.
