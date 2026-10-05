---
description: Turn a requirement or idea into a detailed, implementation-ready specification
subtask: false
---
Turn the following requirement/idea into a **detailed, implementation-ready specification**.

Start by orienting: if a project context map exists at `~/.config/opencode/contexts/<project>.md`,
read it first (see the **context** skill) to ground the spec in the actual architecture.

Work through the **brainstorming** skill (load it now and follow it exactly): classify the
request as spike / bounded / architectural, explore the actual project context and existing
code, ask the clarifying questions that matter, propose and present a design in sections, and
get my approval at each gate. Do **not** start implementing anything.

When the design is approved:

- **Architectural / multi-step:** write the specification document to
  `docs/superpowers/specs/YYYY-MM-DD-<topic>-spec.md` (source of truth, implementation-ready:
  goal, scope, non-goals, requirements, interfaces, data model, edge cases, testing strategy,
  affected files, dependencies). Then self-review it for gaps/contradictions before asking me
  to review it.
- **Bounded:** present a short design in chat and stop for my approval; no spec file.
- **Spike:** present the question and probe plan; report findings as a recommendation.

The spec must describe **WHAT** is needed — never start writing the **HOW** (that is `feature`'s
job). Keep it scoped to the actual codebase, reuse existing architecture/abstractions, and do
not invent requirements. Finish by telling me where the spec lives and offering to move to
`feature`.

$ARGUMENTS