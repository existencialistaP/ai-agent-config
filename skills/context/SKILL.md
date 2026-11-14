---
name: context
description: Use when starting work in a project before broad codebase exploration to check the project context map at ~/.local/share/ai-agent-config/contexts/<slug>.md, or when asked to create/update/refresh that map with this skill
---

# Project Context Map

Keep one compact architectural map per project at
`~/.local/share/ai-agent-config/contexts/<slug>.md` so agents find where things
live without broad exploration. The map is a starting point; **the code is
always the source of truth.**

Always read and write the canonical path. If an older install still has a
`~/.config/opencode/contexts/` symlink, treat it as a legacy mirror and ignore
it.

## Consult (default when starting a task)

1. Identify the project:
   - Inside a git repo: `git rev-parse --show-toplevel`, use its basename.
   - Otherwise: use the current working directory basename.
   - Slug = lowercase, non-alphanumeric → `-` (e.g. `Miau Social` → `miau-social`).
2. Check `~/.local/share/ai-agent-config/contexts/<slug>.md`. If present, read it
   and confirm its `path:` frontmatter matches the current repo (a same-named
   project elsewhere is a different project).
3. Use it as a map: where things live, what to reuse, which commands to verify.
   Confirm against the code before relying on it.
4. If the map contradicts the code or is stale, **trust the code** and offer to
   refresh the map with this skill (or refresh it yourself when asked / write
   access allows).
5. No map exists? Continue normally. If the task needs broad exploration, note
   that a context map would save future tokens and recommend this skill.

## Write / update (when asked to create or refresh, or when dispatched as writer)

1. Resolve project and target path as above;
   `mkdir -p ~/.local/share/ai-agent-config/contexts`.
2. If the file exists, **read it first and update incrementally**: keep sections
   that are still accurate, rewrite only what changed, add new discoveries, bump
   `updated:`. Recreate from scratch only after a major restructure.
3. Map the codebase efficiently. Read `package.json`/manifest scripts + deps,
   README, entry points, and the dir tree. Prefer scout role workers (see the
   `dispatching-parallel-agents` skill) to keep the main session lean.
4. Write a COMPACT map (target 30-60 lines) with this structure:

```markdown
---
project: <slug>
path: <absolute repo path>
updated: YYYY-MM-DD
---

# <Project name>

## Objetivo
1-2 sentences: what the project is for.

## Stack
Languages, frameworks, key libraries, one per line.

## Estrutura
Each main directory → one line: what lives there and where to look.

## Arquitetura
Patterns: layers/DDD, DI, data access, auth, state. Where flows enter and exit.

## Fluxos importantes
Named flows (auth, checkout, build...) → starting file(s) for each.

## Abstrações a reutilizar
Existing components/services/helpers to reuse — never reinvent.

## Convenções
Naming, styling, forms, API, git conventions that differ from defaults.

## Comandos
test / lint / typecheck / dev / build / db.

## Dependências-chave
Only deps whose role matters: the "why", not the full list.

## Gotchas / não-óbvio
Things that cost exploration to discover: breaking framework versions, invariants, traps.
```

5. Rules:
   - **Map, not dump**: file paths + one-line purpose. No large code excerpts, no full configs.
   - Facts only, sourced from the code — never invent.
   - Keep it useful at a glance; trim stale entries while updating.
6. After writing, report the file path and a 2-3 line summary of what changed.
