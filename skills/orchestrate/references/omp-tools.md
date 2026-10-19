# omp Tool Mapping

The `orchestrate` skill speaks in roles and transports. On omp they resolve to the primitives below. Trust your actual tool list over this table when they disagree.

| Role / action the skill requests | omp primitive |
|---|---|
| `writer` — implement one scoped slice | `task` tool, one entry in `tasks[]` with `agent: "writer"`; fall back to `agent: "task"` when the role is unpublished |
| `scout` — read-only investigation | `task` entry with `agent: "scout"` |
| `reviewer` — read-only review of a slice | `task` entry with `agent: "code-reviewer"` |
| `mechanic` — one listed, mechanical fix | `task` entry with `agent: "sonic"` |
| Task batch (3-5 slices) | several entries in **one** `tasks[]` call; a second call is a second wave |
| Direct / inline work | do it in the current turn with `read`, `edit`, `write`, `bash` |
| Wait for children | results auto-deliver; call `wait` only when blocked with nothing else to run |
| Read a child's output | `agent://<id>`; transcript at `history://<id>` |
| Write the dispatch contract | `write` to `dispatch/<slice>.md` under the change directory |
| Record supervision state | `edit` on `orchestration.md`; checkboxes in `tasks.md` |
| Run the full suite (N0 only) | `bash`, once, over the union of changes |
| Durable / observable transport | Herdr CLI behind the `test "${HERDR_ENV:-}" = 1` guard; `herdr` skill for syntax |
| Orca workspace (opt-in) | only when the user asks for it or the work needs its browser/artifacts |
| Handoff to another session | write `tasks.md` + `orchestration.md`, then end the turn |
| Invoke a skill | `skill://<name>` |

## Dispatch notes

- **One `writer` per file.** Two writers on the same file in one batch race on edits and one result is lost. Split by file or exported unit.
- **Cold start.** Each `tasks[]` entry gets a self-contained `task` and a `solutionSpace` sized to how open-ended the slice is. The child inherits no conversation; paste the path to its `dispatch/<slice>.md`.
- **Batch shape.** Name each entry in CamelCase (folders for nested slices read as dotted IDs). Keep one call per wave so independent slices start together.
- **Fix rounds.** Send a review finding back to the same worker with `write agent://<id>`, quoting the finding. Do not spawn a replacement writer for a small correction.
- **Depth bound.** N1 entries may spawn `scout` or `sonic` only. A `writer` below depth 1 is a contract violation; the N0 creates a new top-level slice instead.
- **Wait semantics.** Never poll. `wait` returns the first settled job you started; child output also lands in `agent://<id>`.
- **Verification.** Workers edit and report. The N0 runs the project gates once after integration.

## Herdr branch on omp

The omp host already has the `herdr` skill available, but this skill's guard still governs whether it is used:

```bash
test "${HERDR_ENV:-}" = 1
```

- Layout: `herdr pane layout --pane "$HERDR_PANE_ID"`, then `herdr pane split --current --direction right --cwd "$PWD" --no-focus`; read `.result.pane.pane_id`.
- Start: `herdr agent start <name> --kind <kind> --pane <pane-id> -- <args>`.
- Prompt: `herdr agent prompt <name> "<text>" --wait --timeout 120000`.
- Follow: `herdr agent get <name>`, `herdr agent read <name> --source recent-unwrapped --lines 120`.
- `blocked` goes to the user; `unknown` gets an inspection, not an assumption. Never close panes this run did not create.
