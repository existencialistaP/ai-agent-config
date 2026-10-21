# context-mode (MCP ctx_*) — roteamento de saida grande

O `context-mode` e o caminho padrao deste harness para saida volumosa. Um
`curl` sem filtro, um `cat` de log ou um `grep` em arvore grande despeja dezenas
de KB direto no contexto. O adapter do OMP nao registra hooks de tool-call, entao
estas regras sao a unica barreira: trate como MUST.

- Saida grande (log, listagem, teste, build, JSON, diff enorme):
  `ctx_batch_execute(commands, queries)` — o output inteiro fica indexado e so o
  trecho que responde a query entra no contexto.
- Analisar/contar/filtrar/comparar/parsear dados: `ctx_execute(language, code)`,
  imprimindo so a resposta. Nao leia o dado cru para depois raciocinar sobre ele.
- Ler arquivo grande para **analisar**: `ctx_execute_file(path, language, code)`.
  `read` continua correto quando o objetivo e **editar**.
- Procurar em conteudo ja indexado: `ctx_search(queries)` (FTS5; nao e busca semantica).
- Pagina web/docs: `ctx_fetch_and_index(url, source)` e depois `ctx_search`.
- Evite `curl`/`wget`/HTTP inline no bash: passe por `ctx_execute` ou `ctx_fetch_and_index`.
- `shell`/`bash` continua correto para comando curto e para fatos rapidos
  (git, mkdir, mv, cd, ls, instalacao de pacote) — o criterio e o tamanho da saida,
  nao a ferramenta.

Antes de dizer "nao sei onde isso esta no projeto": `ctx_search` antes de varrer arquivos.
