# OpenCode SDD — Config Compartilhada da Equipe

Configuração compartilhada do [OpenCode](https://opencode.ai) com o fluxo completo de
**Spec-Driven / Subagent-Driven Development (SDD)** baseado no
[Superpowers](https://github.com/obra/superpowers), mais comandos, agente e skills próprios
da equipe.

Objetivo: todo mundo usa o mesmo fluxo, as mesmas convenções e as mesmas capacidades —
versionado num único lugar, atualizável com `git pull`.

## O que está incluso

**Superpowers** (motor do SDD) — instalado como plugin git via `opencode.jsonc`, então todos
ficam na mesma versão:

- brainstorming, writing-plans, subagent-driven-development, test-driven-development,
  systematic-debugging, dispatching-parallel-agents, using-git-worktrees,
  requesting-code-review, receiving-code-review, verification-before-completion,
  finishing-a-development-branch, executing-plans, using-superpowers, writing-skills

**Comandos** (`commands/`) — os pontos de entrada do fluxo:

| Comando | O que faz |
|---|---|
| `/tospec` | Transforma ideia/requisito em spec detalhada e pronta pra implementar |
| `/feature` | Implementa uma spec aprovada (TDD, subagents, verificação) |
| `/debug` | Investiga e corrige bugs de forma sistemática (root cause antes de fix) |
| `/review` | Code review do que acabou de ser implementado |
| `/finish` | Verifica e fecha a task com evidência |
| `/investigate` | Investigação read-only do codebase |
| `/context` | Cria/atualiza o mapa de contexto do projeto |

**Agente** (`agents/reviewer.md`) — subagent `reviewer` read-only para code review.

**Skill** (`skills/context/`) — skill de mapa de contexto de projeto.

## Como funciona a instalação

O OpenCode descobre agents/commands/skills nos diretórios globais
`~/.config/opencode/{agents,commands,skills}/`. O `install.sh` faz **symlinks** desses
diretórios do repo para lá — assim `git pull` atualiza tudo automaticamente, sem copiar
arquivos e sem variáveis de ambiente.

## Instalação

```bash
git clone git@github.com:SUA-ORG/opencode-sdd.git ~/.config/opencode-sdd
bash ~/.config/opencode-sdd/install.sh
```

O script:

1. Cria symlinks `~/.config/opencode/{agents,commands,skills}` → repo.
2. Config: se você já tem um `opencode.json`/`opencode.jsonc`, ele **não sobrescreve** —
   imprime as chaves para você adicionar manualmente. Se não tem, copia o da equipe.

Valide:

```bash
opencode debug agents          # deve listar "reviewer"
```

E pergunte ao agente para listar as skills (deve aparecer `context`, `brainstorming`, etc.).

## Uso

Fluxo completo de uma feature:

```
/tospec  → aprova a spec →  /feature  →  /review  →  /finish
```

Para algo pequeno e sem ambiguidade, vá direto em `/feature`.

## O que NÃO está versionado (fica no seu setup pessoal)

- `contexts/` — mapas de contexto de projeto (`~/.config/opencode/contexts/*.md`); são
  por-desenvolvedor e por-máquina.
- `cli.json` — preferências de TUI (tema, atalhos, animações).
- Plugins pessoais (ex.: notificações de desktop via `notify-send`).
- `service.json` — token local do servidor (nunca comitar).

## Como atualizar

```bash
cd ~/.config/opencode-sdd && git pull
```

## Como contribuir / estender

- **Comando novo:** crie `commands/<nome>.md` (frontmatter `description` + template com `$ARGUMENTS`).
- **Agente novo:** crie `agents/<nome>.md` (frontmatter `description`, `mode`, `permission`).
- **Skill nova:** crie `skills/<nome>/SKILL.md` (frontmatter `name` + `description`).
- **Ajuste de config:** edite `opencode.jsonc` (modelo, plugins, permissions).

Abra um PR; revise com `/review` antes de mergear.

## Migrando de um setup antigo (vendor + skills.paths)

Se o seu `~/.config/opencode/opencode.jsonc` ainda aponta para um clone vendored do
Superpowers (`skills.paths: ["~/.config/opencode/vendor/superpowers/skills"]`), troque por
um plugin git e remova o clone:

```jsonc
"plugin": ["superpowers@git+https://github.com/obra/superpowers.git"]
```

```bash
rm -rf ~/.config/opencode/vendor/superpowers
```
