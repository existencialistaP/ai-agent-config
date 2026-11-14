# Saída grande — roteamento nativo

Não há MCP de context-mode montado neste harness. Para saída volumosa, use os
primitivos do próprio OMP:

- Filtre no `bash` (`rg`, `head`, `tail`, `sed -n`, `jq`) em vez de despejar o
  output inteiro no contexto.
- Para analisar, contar, filtrar ou parsear, use `eval` (Python/JS) e imprima
  só a resposta.
- Para ler arquivo grande, use `read` com seletor de linhas
  (`arquivo:50-200`) em vez do arquivo todo.
- Output já gerado que foi truncado: leia `artifact://<id>` em vez de
  reexecutar o comando.
- `web_search` para descobrir; `read` de URL para a página.
- `find` descreve comportamento; `grep` acha literal; `glob` acha nome.
