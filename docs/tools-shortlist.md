# Ferramentas — shortlist (22)

Já coberto pelo harness, não repita: OpenSpec, semgrep, codeql, SARIF, ast-grep,
LSP, graphify (removido), plannotator, Herdr, Orca, skills-janitor, os evals de
routing. Abaixo, o que fecha lacunas reais.

| # | Ferramenta | Problema que resolve | Esforço | Veredito |
|---|---|---|---|---|
| 1 | [osv-scanner](https://google.github.io/osv-scanner/) | CVEs em dependências e imagens (semgrep/codeql são SAST de código) | ~5 min | **Adotar** |
| 2 | [gitleaks](https://github.com/gitleaks/gitleaks) | Segredo no histórico do git; o pre-commit só vê o worktree | ~5 min | **Adotar** |
| 3 | [lychee](https://github.com/lycheeverse/lychee) | Link morto em 90+ URLs das skills; guidance degrada calada | ~10 min | **Adotar** (agendar, não CI por push) |
| 4 | [sandbox-runtime (srt)](https://github.com/anthropic-experimental/sandbox-runtime) | Isola comandos do agente com bwrap; aprovação por padrão é lexical, não sandbox | ~1 h | **Adotar com cautela** (beta, sem PTY) |
| 5 | [shellcheck](https://www.shellcheck.net/) | Bugs reais nos 4,6k linhas de `skills-janitor/scripts/*.sh` | ~10 min | **Adotar** |
| 6 | [shfmt](https://github.com/mvdan/sh) | Formatação consistente dos mesmos scripts | ~5 min | Adotar junto do shellcheck |
| 7 | [actionlint](https://github.com/rhysd/actionlint) | Erros em workflows GitHub Actions | ~5 min | Adotar se os workflows crescerem |
| 8 | [zizmor](https://github.com/woodruffw/zizmor) | Segurança de workflows (permissões, pin de action) | ~10 min | Adotar se publicar releases |
| 9 | [PIT / pitest](https://pitest.org/) | Mutação em Java: os testes realmente falham? | ~30 min/projeto | Condicional (Java) |
| 10 | [Stryker](https://stryker-mutator.io/) | Mutação em JS/TS | ~30 min/projeto | Condicional (TS) |
| 11 | [trivy](https://trivy.dev/) | CVE + misconfig em imagem/filesystem | ~10 min | Adotar se buildar imagem |
| 12 | [hadolint](https://github.com/hadolint/hadolint) | Dockerfile inseguro/ineficiente | ~5 min | Condicional (Docker) |
| 13 | [checkov](https://www.checkov.io/) | Misconfig de Terraform/K8s | ~15 min | Condicional (IaC) |
| 14 | [cosign](https://github.com/sigstore/cosign) | Assinatura/verificação de imagem | ~20 min | Só se distribuir imagem |
| 15 | [promptfoo](https://www.promptfoo.dev/) | Regressão de prompts/skills com casos e score | ~1 h | **Adotar se** quiser eval além do TF-IDF |
| 16 | [Arize Phoenix](https://github.com/Arize-ai/phoenix) | Traces OTel por tool/skill (o OMP já exporta OTLP) | ~30 min | Opcional; ELv2, loopback |
| 17 | [mise](https://mise.jdx.dev/) | Pin de JDK/Node/Python por projeto | ~10 min | Condicional (multi-versão) |
| 18 | [knip](https://github.com/webpro-nl/knip) | Deps/exports mortos em TS | ~10 min | Condicional (TS) |
| 19 | [dependency-cruiser](https://github.com/sverweij/dependency-cruiser) | Regras de arquitetura e ciclos | ~20 min | Condicional (TS) |
| 20 | [jscpd](https://github.com/kucherenko/jscpd) | Duplicação de código | ~5 min | Opcional |
| 21 | [typos](https://github.com/crate-ci/typos) | Typo em identificadores e docs | ~5 min | Só para código; PT-BR gera allowlist |
| 22 | [Vale](https://vale.sh/) | Prosa técnica consistente (PT/EN) | ~30 min | Opcional |

## Descartar (e por quê)

- **ccusage** — funciona (`bunx ccusage pi daily --pi-path ~/.omp/agent/sessions`), mas `omp stats` e `skill_usage.py` já dão custo/tokens/cache.
- **asciinema** — `omp record`/`play`/`clip` já gravam.
- **repomix / gitingest** — `find`, `read` e o grafo do projeto cobrem; empacotar repo inteiro gasta contexto.
- **syft / grype** — `osv-scanner`/`trivy` cobrem CVE; SBOM é compliance theater para um usuário.
- **markdownlint** — ruído de formatação; o contrato de skill já é validado.
- **just / mise** — OpenSpec + comandos do OMP já são os entry points; `mise` só se aparecer multi-JDK.
- **firejail** — bwrap/srt cobre melhor.
- **Langfuse** — Postgres+ClickHouse+Redis para $12/mês de uso: overkill.
- **Helicone / Braintrust** — proxy/SaaS, forma errada para local-first.
- **knip/ts-prune/jscpd** — só valem se existir um projeto TS seu; hoje não há.

## Ordem de adoção

1. `osv-scanner` + `gitleaks` + `lychee` (uma tarde, cobrem supply chain, segredo e link rot).
2. `shellcheck` + `shfmt` nos scripts do janitor.
3. `promptfoo` se quiser medir qualidade, não só roteamento.
4. O resto conforme o projeto (Java → PIT; Docker → trivy/hadolint; TS → knip).
