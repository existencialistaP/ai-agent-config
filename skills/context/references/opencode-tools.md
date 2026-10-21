# OpenCode Tools

`SKILL.md` is canonical; this file only resolves the dispatch primitives that
the role language in the skill maps to on OpenCode.

| Role | Primitive | When to use |
|---|---|---|
| writer | `task` tool with the default worker subagent | Creating or updating the map file; the writer owns the map |
| scout | `explore` subagent | Mapping a codebase: manifests, entry points, dir tree |
| reviewer | `reviewer` agent | Checking that the finished map's claims match the code |
| mechanical | low-effort `task` run | Slug resolution, `mkdir -p`, frontmatter `updated:` bumps |

## Notes

- Scout is the natural role for mapping a codebase: `explore` reads without
  editing and returns a compact summary the writer can assemble.
- The writer owns the map file. Parallel scouts may cover disjoint areas, but
  only one writer session may touch `contexts/<slug>.md` at a time.
- Reserve the low-effort `task` run for mechanical edits; do not send it
  codebase questions that need real investigation.
