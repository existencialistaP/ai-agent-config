---
description: "Harness metrics: cost, skill usage, tool errors, routing"
subtask: false
---

Run the three checks and report a compact dashboard. Do not paste raw output.

1. `omp stats --json` — cost, tokens and cache rate per model (current window).
2. `python3 skills-janitor/scripts/skill_usage.py --exclude-probe` — real skill
   loads, zero-skill %, cost by model/session, tool error rates.
3. `python3 skills-janitor/scripts/route_evals.py` — rank-1/top-3, negative
   violations, cross-family collisions.

Report, in this order:

- total cost and the top model and session by spend;
- skills loaded vs catalog, and the zero-skill %;
- every tool with an error rate above 5%;
- routing rank-1 and any cross-family collision >= 0.50;
- the top 3 actions, ranked by measured impact.

No metric, no claim: if a command fails, say which one and why.
