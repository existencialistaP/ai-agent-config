#!/usr/bin/env python3
"""Tier 3 routing eval: which skill did the real router actually load?

Runs each prompt through `omp -p` (headless, JSON trace) in a throwaway empty
directory, then counts reads of `skill://<name>`. That is the behaviour the
lexical Tier 2 can only approximate.

On demand, costs tokens. Model defaults to the omp config default.

Usage:
  python3 route_live.py                       # all cases in routing.json
  python3 route_live.py --skills simplify,test-driven-development
  python3 route_live.py --reps 3 --positive-only
"""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path

SKILL_READ = re.compile(r"^skill://([a-z0-9][a-z0-9-]*)")
SKILL_FILE = re.compile(r"/skills/([a-z0-9][a-z0-9-]*)/SKILL\.md$")


def fired_skills(trace: str) -> tuple[list[str], int]:
    found, calls = [], 0
    for line in trace.splitlines():
        try:
            d = json.loads(line)
        except json.JSONDecodeError:
            continue
        msg = d.get("message") or {}
        if d.get("type") != "message_end" or msg.get("role") != "assistant":
            continue
        for c in msg.get("content") or []:
            if c.get("type") != "toolCall":
                continue
            calls += 1
            args = c.get("arguments") or {}
            path = str(args.get("path", ""))
            m = SKILL_READ.match(path) or SKILL_FILE.search(path)
            if m:
                found.append(m.group(1))
    return found, calls


def run(omp: str, prompt: str, max_cost: str, model: str | None, cwd: str) -> tuple[list[str], int, str]:
    cmd = [omp, "-p", prompt, "--no-context-files", "--no-session", "--no-title",
           "--mode", "json", "--tools", "read", "--thinking", "off",
           "--max-cost", max_cost, "--max-time", "150"]
    if model:
        cmd += ["--model", model]
    try:
        p = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True, timeout=180)
        return (*fired_skills(p.stdout + p.stderr), "")
    except subprocess.TimeoutExpired:
        return [], 0, "timeout"


def main() -> int:
    here = Path(__file__).resolve().parent
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--cases", default=str(here.parent / "evals" / "routing.json"))
    ap.add_argument("--skills", help="comma-separated subset")
    ap.add_argument("--reps", type=int, default=1)
    ap.add_argument("--positive-only", action="store_true")
    ap.add_argument("--model", default=None, help="defaults to omp's configured default model")
    ap.add_argument("--omp", default="omp")
    ap.add_argument("--max-cost", default="0.05")
    ap.add_argument("--json-out")
    args = ap.parse_args()

    cases = json.loads(Path(args.cases).read_text())
    selected = set(args.skills.split(",")) if args.skills else set(cases)

    rows, hit = [], 0
    total = 0
    with tempfile.TemporaryDirectory(prefix="route-live-") as tmp:
        for skill in sorted(selected):
            spec = cases[skill]
            jobs = [(p, True) for p in spec.get("positive", [])]
            if not args.positive_only:
                jobs += [(n["prompt"], False) for n in spec.get("negative", [])]
            for prompt, positive in jobs:
                for rep in range(args.reps):
                    fired, calls, err = run(args.omp, prompt, args.max_cost, args.model, tmp)
                    total += 1
                    ok = (skill in fired) if positive else (skill not in fired)
                    hit += ok
                    state = "HIT  " if ok else "MISS "
                    label = "pos" if positive else "neg"
                    print(f"[{total:3d}] {state} {label} {skill:30s} fired={','.join(fired) or '-':30s} calls={calls} {err}"
                          f"  {prompt[:56]!r}", flush=True)
                    rows.append({"skill": skill, "positive": positive, "rep": rep, "ok": ok,
                                 "fired": fired, "calls": calls, "error": err, "prompt": prompt})
                print(f"      {skill}: {sum(1 for r in rows if r['skill'] == skill and r['positive'] and r['ok'])}"
                      f"/{sum(1 for r in rows if r['skill'] == skill and r['positive'])} positive fired", flush=True)

    print(f"\nrouter: {hit}/{total} cases behaved as expected")
    if args.json_out:
        Path(args.json_out).write_text(json.dumps(rows, indent=2))
        print(f"wrote {args.json_out}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
