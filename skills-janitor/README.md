# Skill routing evals

Do the skill descriptions actually fire? Two tiers, same cases file
(`evals/routing.json`).

```bash
python3 scripts/route_evals.py                 # Tier 2: free, deterministic
python3 scripts/route_live.py                  # Tier 3: real router, costs tokens
python3 scripts/route_live.py --skills simplify --reps 3
```

**Tier 2** (`route_evals.py`) builds stemmed TF-IDF vectors from every
`SKILL.md` description and scores positive prompts (expected skill) and
negative prompts (a different skill must win). It also reports cross-family
description collisions. It measures **vocabulary coverage only** — a
description can contain every word and the model still answer directly.
Interpret failures as "the description is missing the words users say", not
"the model will ignore the skill".

**Tier 3** (`route_live.py`) runs each prompt through `omp -p` in a throwaway
empty directory with `--tools read` and counts reads of `skill://<name>` in
the JSON trace. That is the real router, at the configured default model.
Use `--reps` — invocation is stochastic. Negative cases pass when the target
skill is *not* loaded.

Thresholds: fail on negative violations; treat cross-family similarity
`>= 0.75` as an error and `>= 0.50` as a warning. Discard `--strict` results
for same-family pairs (`openspec-*`, `ponytail-*`) — overlap there is expected.

## Real usage

`scripts/skill_usage.py` parses OMP session traces and counts actual
`skill://<name>` loads, tool calls, zero-skill sessions and per-project usage,
joined with the catalog cost:

```bash
python3 scripts/skill_usage.py                  # all sessions
python3 scripts/skill_usage.py --exclude-probe  # skip -tmp* probe sessions
python3 scripts/skill_usage.py --json
```

Use it next to Tier 3: `route_live.py` measures recall on authored prompts,
`skill_usage.py` measures what actually fires. A skill with zero loads and a
large body is a pruning candidate; a safety-net skill (debugging, verification)
is not, even at zero — judge by expected value, not count.

Cases look like:

```json
{"skill-name": {
  "positive": ["prompt in user language"],
  "negative": [{"prompt": "...", "owner": "expected-other-skill"}]
}}
```

Add cases for a skill when its description changes; keep at least three
positives and two negatives. Phrases should be how users actually ask, not a
paraphrase of the description.
