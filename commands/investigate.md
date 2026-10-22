---
description: Read-only investigation of the codebase to answer architecture questions or find where a change should go
subtask: false
---

Investigate the following question or topic in the codebase. This is a strictly **read-only**
investigation.

$ARGUMENTS

## Rules

- Do **not** implement anything, fix anything, or create files. Do not turn the investigation
  into work.
- Never modify application files. Only read, search, and explore.
- For broad exploration, load the **orchestrate** skill and follow it for slicing and
  transport decisions (direct / task batch / Herdr / handoff): the `explore` role resolves
  to read-only `scout` agents dispatched in parallel (thoroughness: quick / medium / very
  thorough) instead of exploring inline. Draw the conclusions yourself here.

## Workflow

1. Read `AGENTS.md` and any relevant project instructions.
2. If a project context map exists at `~/.local/share/ai-agent-config/contexts/<project>.md`, read it
   (see the **context** skill) to orient before exploring.
3. Explore the real project structure.
4. Search for existing implementations related to the question.
5. Follow the relevant flow through the code.
6. Identify existing abstractions, services, components, and tests.
7. Compare the context map against the real code.
8. If they diverge, treat the code as the source of truth and note the divergence.
9. Produce an objective conclusion.

## Answer format

```markdown
## Investigation

### What I found

### Relevant files

### Current flow

### Existing abstractions

### Recommendation

### Risks / unknowns
```

Do not go beyond the investigation: no implementation, no fixes, no new files.
