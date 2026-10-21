# omp tools — systematic-debugging

| Role | omp primitive |
|------|---------------|
| writer | `task` batch entry — edits code and runs the reproduction |
| scout | `scout` agent (read-only) |
| reviewer | `code-reviewer` agent (read-only) |
| mechanical | `sonic` agent |

## Use in this skill

- **Phase 1 — evidence:** run the reproduction yourself. Dispatch `scout` when the call stack or recent-change diff spans more files than one pass can hold; ask for the trace and the component boundary where the value first goes wrong, not for a fix.
- **Phase 2 — references:** have `scout` return the complete reference implementation and its differences from the working code.
- **Mechanical checks:** `sonic` can add instrumentation, collect logs, or run a diagnostic script while the writer reasons about the evidence.
- **Phase 4 — review:** dispatch `code-reviewer` with the git range, the root-cause statement, and the failing-test evidence. It must reject symptom fixes.
- **One writer per file:** do not dispatch a second writer on the same fix — two writers create two competing root-cause stories.
