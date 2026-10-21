# Codex Tools

`SKILL.md` is canonical; this file only resolves the dispatch primitives that
the role language in the skill maps to on Codex.

| Role | Primitive | When to use |
|---|---|---|
| writer | separate `codex exec` session per slice with workspace-write | Creating or updating the map file; the writer owns the map |
| scout | read-only `codex exec` session | Mapping a codebase: manifests, entry points, dir tree |
| reviewer | fresh `codex exec` session given only the diff and spec | Checking that the finished map's claims match the code |
| mechanical | low-effort / cheaper-model `codex exec` run | Slug resolution, `mkdir -p`, frontmatter `updated:` bumps |

## Notes

- Scout is the natural role for mapping a codebase: a read-only session cannot
  disturb the tree and returns findings the writer can assemble.
- The writer owns the map file. Give each writer slice its own session and
  never let two sessions edit `contexts/<slug>.md` concurrently.
- Keep mechanical runs on a low-effort or cheaper model; they only resolve the
  slug, create the directory, and bump metadata.
