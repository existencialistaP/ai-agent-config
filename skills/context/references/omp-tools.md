# OMP Tools

`SKILL.md` is canonical; this file only resolves the dispatch primitives that
the role language in the skill maps to on OMP.

| Role | Primitive | When to use |
|---|---|---|
| writer | `task` tool batch: one worker per file or disjoint group, never two workers on one file | Creating or updating the map file; the writer owns the map |
| scout | `scout` agent (read-only) | Mapping a codebase: reading manifests, entry points, dir tree |
| reviewer | `code-reviewer` agent | Checking that the finished map's claims match the code |
| mechanical | `sonic` agent | Slug resolution, `mkdir -p`, frontmatter `updated:` bumps |

## Notes

- Scout is the natural role for mapping a codebase: it is read-only, returns
  compressed context, and keeps the main session lean while the map is built.
- The writer owns the map file. When several slices are mapped in parallel,
  collect their findings first and let a single writer assemble the file.
- Mechanical work in this skill is path and metadata bookkeeping only; anything
  that requires judgement about code belongs to scout or writer.
