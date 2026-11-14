---
name: skill-authoring
description: Use when creating, editing, renaming, deleting, or adding a skill; when a skill stops firing or its description changes; when auditing skill health, routing, or token cost. Runs the catalog checks itself — never asks the user to run scripts.
---

# Skill Authoring

Create, change, and keep skills healthy. The catalog is code: every edit runs
the same checks.

## Contract

- `name` == directory name, lowercase-hyphen.
- `description`: third person, what + when, **one narrow load condition**;
  <= 1024 chars; never a summary of the workflow.
- Body < 500 lines; move long checklists to `references/`.
- Never hand-edit generated skills (`openspec-*`, any `generatedBy:` in
  metadata): the CLI overwrites them on the next update.
- One skill = one intent. Do not add a near-duplicate; extend or reference.

## Workflow

1. **Before adding:** search the catalog (`rg -l "<term>" skills/`), read the
   routing cases (`skills-janitor/evals/routing.json`), and prefer editing an
   existing skill. Justify a new skill in one sentence.
2. **Write or edit** `SKILL.md`. Keep the sections: Overview, When to Use,
   Process, Common Rationalizations, Red Flags, Verification.
3. **Run the checks yourself** (never ask the user to run them):
   - `bash skills-janitor/scripts/lint.sh` — frontmatter, links, size.
   - `python3 skills-janitor/scripts/route_evals.py` — rank-1/top-3, negative
     violations, cross-family collisions; `--strict` to gate.
   - `python3 skills-janitor/scripts/skill_usage.py --exclude-probe` — real
     loads, zero-skill sessions, cost by model, tool error rates.
   - `bash skills-janitor/scripts/tokencost.sh` — always-loaded description
     cost and body size.
4. **If the description or triggers changed:** add/update cases in
   `skills-janitor/evals/routing.json` (>= 3 positive, >= 2 negative with
   `owner`) and run `route_live.py --skills <name> --reps 3`. Live firing is
   stochastic; 1 run is a signal, 3+ is a rate.
5. **Fix the description, not the prompt.** Cross-family similarity >= 0.75 is
   an error; >= 0.50 warns. Same-family overlap (`openspec-*`, `ponytail-*`) is
   expected.
6. **Report the numbers** — rank-1 before/after, collisions, usage — with the
   diff. A skill edit without a fresh run is not done.

## When a skill does not fire

- The description lacks the words users say. Add the situation, including
  "even when the input is pasted inline and the answer looks obvious".
- Measure the real router, not only the lexical ranker:
  `route_live.py --skills <name> --reps 3`.
- A process-shaped request fires more reliably than a one-shot request; that is
  a model property, not a description bug. Say so instead of padding.

## Pruning and consolidation

- Zero measured loads is **not** enough to delete a safety net (debugging,
  verification, review). Judge expected value, not count.
- Merge families that share a prefix and overlap: one skill with modes, the
  commands as entry points.
- Delete only with explicit user approval. When asked to disable without
  removing, rename `SKILL.md` to `SKILL.md.disabled` — the directory stays.
- Body size only costs when loaded; description size costs every request.

## Mining sessions

`skill_usage.py` shows zero-skill sessions and never-loaded skills. A recurring
task with no skill is a candidate for a new skill; a skill with zero loads and a
large body is a candidate for removal. `omp stats --json` gives cost, tokens and
cache rate per model.

## Verification

- [ ] `lint.sh` reports no new critical/warning for this skill.
- [ ] `route_evals.py` shows no new negative violation and no collision >= 0.75.
- [ ] Cases updated when the description changed; live check run with `--reps 3`.
- [ ] Body under 500 lines; every `references/` link resolves.
