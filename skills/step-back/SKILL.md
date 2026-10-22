---
name: step-back
description: Use when a task keeps growing through patches: repeated fixes, workarounds, compatibility shims, or a new path built beside an old one. Pause, reassess the direction, and propose a cleaner alternative before continuing.
---

# Step Back

Momentum is a poor architect. Each patch on top of existing code feels like
the safe, local choice, but together they pile up into complexity no one
would have designed on purpose. When fixes start stacking, stop and look at
the whole picture: is the goal still the same, and if you were starting fresh
with what you know now, would you build it this way?

If the answer is no, don't push through quietly. Tell the user in a few lines:

- where things are heading;
- why that is drifting;
- the cleaner alternative;
- what you recommend.

Then let them decide. If the answer is yes, carry on with confidence. The
goal is to catch the wrong turn early, not to second-guess every step.

## When to invoke

- The third fix in the same area still does not hold.
- A compatibility shim, fallback, or second code path is being added beside
  the one it replaces.
- The task keeps growing in scope while the original goal stays the same.

## When not to invoke

Small, clean, bounded edits where the current direction is still proportional.

## Output

Keep it short and decision-oriented. No essay, no blame, no re-plan unless the
user asks for one.
