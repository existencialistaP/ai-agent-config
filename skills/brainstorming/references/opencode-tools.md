# OpenCode Tool Mapping

Skills speak in roles — `writer`, `scout`, `reviewer`, `mechanical`. On OpenCode these resolve to the primitives below.

| Role / action the skill requests | OpenCode primitive |
|---|---|
| `writer` — implement a scoped slice | `task` with `subagent_type: "general-purpose"`; use `subagent_type: "writer"` when a writer agent is installed |
| `scout` — read-only investigation | `task` with `subagent_type: "explore"` |
| `reviewer` — read-only review | `task` with `subagent_type: "reviewer"` |
| `mechanical` — mechanically safe edits | `task` with `subagent_type: "general-purpose"` plus a strictly mechanical prompt |
| Parallel dispatch | several `task` calls in one message |
| Wait for results | results return from each `task` call; there is no separate wait primitive |
| Track tasks | `todowrite` |
| Durable / observable session | a separate terminal or worktree session; there are no native background subagents |
| Read / search / edit / run a command | `read`, `grep`/`glob`, `edit`/`write`, `bash` |
| Invoke a skill | the `skill` tool |

## This Skill's Artifacts and Gates

- **Design doc.** Write the validated design to `openspec/changes/<name>/design.md` and commit it. That path is the default; a stated user preference overrides it.
- **Approval gate.** Harness-independent. No writer is dispatched, no code is written, and no scaffold is created before the human approves the design — on every path, including spike and bounded.
- **Spec self-review.** Inline by default. Dispatch a `reviewer` only when the human explicitly asks for an independent read. `subagent_type: "reviewer"` exists here, which makes an independent pass easy, but it is never the default.
- **Visual companion.** OpenCode exposes no artifact viewer. Render mockups, diagrams, and side-by-side comparisons as text in chat, keeping the per-question visual/text test. If the human explicitly asks for the companion server, start it and hand over the complete URL rather than trying to embed a browser.
- **Dialogue tracking.** Keep the one-question-at-a-time dialogue in chat. Do not create a `todowrite` item per question; `todowrite` is for the path checklist, not the conversation.

## Notes

- Trust your actual tool list over this table when they disagree.
- If a primitive is unavailable, fall back to doing the work inline rather than inventing a call.
- Several `task` calls in one message run in parallel; a single call per message serializes them.
- There is no polling loop to write: each `task` call returns its own result.
