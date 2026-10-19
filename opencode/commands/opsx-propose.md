---
description: "Propose a new change - create it and generate all artifacts in one step"
---

Load the `openspec-propose` skill (skill tool, id `openspec-propose`) and follow it exactly,
treating the text below as the change name or the request description.

$ARGUMENTS

**Planning modes.** Without a flag = interactive (current behavior): run in this session
(N0), in dialogue with the human — ask one question at a time, present each artifact
(proposal, design, tasks) section by section and proceed only after approval; gather code
context through the `scout` role in parallel with the questions. With `--direct` =
automatic with a minimal gate: classify the request in one sentence
(spike/bounded/architectural), confirm the scope in one line, and proceed only after that
single ok; then write the artifacts without question rounds. In either mode, write each
artifact to its file before proceeding. Never dispatch a `writer` and never edit code.

Planning may cover 1 or N tasks/slices in the same session: each becomes its own line
with status `queued` in the change's `queue.md`. Deliverable: `orchestration.md` with
status `planned`, the queue filled, and the next step — handoff to the worker.

**Herdr offer (end of planning).** Close with a single question and 3 options: (1) open a
worker in a new Herdr pane, (2) execute here in this session, (3) leave it in the queue.
Default is 3: never auto-start the worker and never open a pane without an explicit "yes".
