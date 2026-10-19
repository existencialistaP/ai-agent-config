---
description: "Propose a new change - create it and generate all artifacts in one step"
---

Load the `openspec-propose` skill (skill tool, id `openspec-propose`) and follow it exactly,
treating the text below as the change name or the request description.

$ARGUMENTS

**Interactive planning mode.** Run in this session (N0), in dialogue with the human:
ask one question at a time, present each artifact (proposal, design, tasks) section by
section and proceed only after approval; gather code context through the `scout` role in
parallel with the questions. Write each artifact to its file before proceeding. Never
dispatch a `writer` and never edit code. Deliverable: `orchestration.md` with status
`planned` and the next step — handoff to the worker.
