---
name: executing-plans
description: Use when you have a written implementation plan to execute in a separate session with review checkpoints
---

# Executing Plans

## Overview

Load plan, review critically, execute all tasks, report when complete.

**Announce at start:** "I'm using the executing-plans skill to implement this plan."

This skill works in any harness. When the harness can dispatch role agents (`writer`, `scout`, `reviewer`, `mechanical`), use the `orchestrate` skill instead of this skill for per-task isolation: each plan task becomes a scoped slice with its own agent and review boundary.

## The Process

### Step 1: Load and Review Plan
1. Ensure an isolated workspace: use the `using-git-worktrees` skill to create one or verify the existing one
2. Read the plan file (`openspec/changes/<name>/tasks.md` by default)
3. Review critically - identify any questions or concerns about the plan
4. If concerns: Raise them with your human partner before starting
5. If no concerns: Track each plan item as a checkbox (`- [ ]` -> `- [x]`) in the plan file and proceed

### Step 2: Execute Tasks

For each task:
1. Change the item's checkbox state in the plan file and add a one-line status note next to it (`- [ ]` while in progress, `- [x]` when complete)
2. Follow each step exactly (plan has bite-sized steps)
3. Run verifications as specified
4. Mark the item `- [x]` and record the verification result in its status note

#### Review Checkpoints

At each checkpoint in the plan, or after each batch of tasks when the plan has no explicit checkpoints:

1. Stop. Do not begin the next task.
2. Inspect the diff and the verification output from the tasks just completed.
3. When the harness supports role dispatch, dispatch a `reviewer` against that diff and the plan items it covers.
4. Report the review findings before continuing. Address blocking findings first; if a finding changes the approach, return to Step 1.

### Step 3: Complete Development

After all tasks complete and verified:
- Announce: "I'm using the finishing-a-development-branch skill to complete this work."
- **REQUIRED SUB-SKILL:** Use the `finishing-a-development-branch` skill
- Follow that skill to verify tests, present options, execute choice

## When to Stop and Ask for Help

**STOP executing immediately when:**
- Hit a blocker (missing dependency, test fails, instruction unclear)
- Plan has critical gaps preventing starting
- You don't understand an instruction
- Verification fails repeatedly

**Ask for clarification rather than guessing.**

## When to Revisit Earlier Steps

**Return to Review (Step 1) when:**
- Partner updates the plan based on your feedback
- Fundamental approach needs rethinking

**Don't force through blockers** - stop and ask.

## Remember
- Review plan critically first
- Follow plan steps exactly
- Don't skip verifications
- Reference skills when plan says to
- Stop when blocked, don't guess
- Never start implementation on main/master branch without explicit user consent

## Harness Adapters

Role names in this skill resolve to concrete primitives per harness. See the `references/` directory for the adapter that matches your environment.
