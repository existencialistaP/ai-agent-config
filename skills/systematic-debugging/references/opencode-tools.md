# opencode tools — systematic-debugging

| Role | opencode primitive |
|------|--------------------|
| writer | `task` subagent with the general-purpose agent — edits code and runs the reproduction |
| scout | `explore` subagent (read-only) |
| reviewer | `reviewer` subagent (read-only) |
| mechanical | `task` subagent with a narrowly scoped, mechanical prompt |

## Use in this skill

- **Phase 1 — evidence:** run the reproduction yourself. Dispatch `explore` when the call stack or recent-change diff spans more files than one pass can hold; ask for the trace and the component boundary where the value first goes wrong, not for a fix.
- **Phase 2 — references:** have `explore` return the complete reference implementation and its differences from the working code.
- **Mechanical checks:** a tightly scoped `task` subagent can add instrumentation, collect logs, or run a diagnostic script.
- **Phase 4 — review:** dispatch `reviewer` with the git range, the root-cause statement, and the failing-test evidence. It must reject symptom fixes.
- **One writer per file:** do not dispatch a second writer on the same fix.
