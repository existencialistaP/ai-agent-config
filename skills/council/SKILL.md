---
name: council
description: Use when the user asks for a council, consensus, second opinion, multi-model review, or a high-stakes decision that benefits from independent judgments.
---

# Council

Run independent read-only reviewers on different models, then synthesize one
verdict. Council is opt-in and expensive; never make it the default
verification step.

## When to use

- Architecture or design choice with real trade-offs.
- Risky migration, security decision, or data-correctness question.
- A review where a single model may share the author's blind spot.

**Don't use** for routine implementation, one-file changes, or anything the
normal `reviewer` gate already covers.

## Seats

Dispatch **three `reviewer` tasks in one `task` batch**, each with a different
`model` and the same question plus enough context to answer cold:

| Seat | Model (example) | Bias |
|---|---|---|
| alpha | `commandcode/gpt-5.6-sol` | correctness and failure modes |
| beta | `commandcode/zai-org/GLM-5.3` | architecture and maintainability |
| gamma | `commandcode/moonshotai/Kimi-K3` | edge cases and operability |

Rules:

- One batch, so the seats run concurrently.
- Every seat is read-only: it may read the repo and run read-only checks; it
  never edits.
- No seat sees another seat's output. Independence is the point; do not ask
  one seat to critique another.
- If a seat fails or returns empty, continue with the remaining seats and say
  which one is missing. Never silently replace it with the same model twice.
- Every seat prompt names the exact files, the question, and the required
  output. The child inherits no conversation.
- If the seats are still running, use `wait`; do not poll.

Seat prompt shape:

```text
Review the decision below as an independent council seat.

Question: <one paragraph>
Scope: <exact files and behavior to inspect>
Your bias: <correctness | architecture | edge cases>
Output: findings with file:line, severity, and a one-line recommendation.
Do not edit anything and do not ask follow-up questions.
```

## Synthesis

Read each seat at `agent://<name>` (or the delivered task result). Synthesize
on the N0 when the N0 model is at least as strong as the seats. Otherwise
dispatch one more `reviewer` with the strongest model, passing the question
and the three reports, and use its synthesis.

The final report MUST contain:

1. **Verdict** - the recommended answer, in one paragraph.
2. **Confidence** - high / medium / low, and why.
3. **Per-seat findings** - what each seat found, compressed to the points that
   changed or confirmed the verdict.
4. **Dissent** - disagreements and the evidence behind them. Never average
   away a dissenting finding.

## Cost

Three strong-model reviews cost roughly three times a single review. Use it
when a wrong decision is more expensive than the review, not as a ritual.
