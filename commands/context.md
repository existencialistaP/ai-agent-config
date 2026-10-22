---
description: Create or update the compact project context map in ~/.local/share/ai-agent-config/contexts/
subtask: false
---
Create or update the project context map for the current project.

$ARGUMENTS

The context map is a **MAP/CACHE of the architecture, not the source of truth** — the current
code is the source of truth. Verify any map information relevant to the task against the code
before relying on it; never assume a map fact is still true without checking when it matters
for the task. If the map is stale or contradicts the code, fix the map as part of this command.

Load and follow the **context** skill (use the skill tool to load it). Identify the current
project, read the existing map at `~/.local/share/ai-agent-config/contexts/<project>.md` if present, map
the codebase efficiently (explore subagents are allowed), and write/update the compact
architectural map following the skill's template and rules. Update incrementally — do not
rewrite from scratch unless the project changed drastically.
