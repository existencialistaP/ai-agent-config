#!/usr/bin/env python3
"""Real skill usage from OMP session traces.

Counts reads of `skill://<name>` in ~/.omp/agent/sessions/**/*.jsonl, plus
tool calls, zero-skill sessions, and per-project breakdown. Joins the result
with the skill catalog to show what is never loaded and what it costs.

This is the usage side of the eval pair: route_live.py measures recall on
authored prompts, this measures what actually ran.

Usage:
  python3 skill_usage.py
  python3 skill_usage.py --json
  python3 skill_usage.py --exclude -tmp      # skip probe sessions
"""

from __future__ import annotations

import argparse
import collections
import glob
import json
import os
import re
import sys
from pathlib import Path


def parse_frontmatter(path: Path) -> dict[str, str]:
    try:
        lines = path.read_text(encoding="utf-8", errors="replace").splitlines()
    except OSError:
        return {}
    if not lines or lines[0].strip() != "---":
        return {}
    end = next((i for i in range(1, len(lines)) if lines[i].strip() == "---"), None)
    if end is None:
        return {}
    fm, out, i = lines[1:end], {}, 0
    while i < len(fm):
        m = re.match(r"^([A-Za-z0-9_-]+):\s*(.*)$", fm[i])
        if not m:
            i += 1
            continue
        key, val = m.group(1), m.group(2).strip()
        if re.fullmatch(r"[>|][-+]?\d*", val):
            folded = val.startswith(">")
            parts = []
            i += 1
            while i < len(fm) and (not fm[i].strip() or fm[i][0] in " \t"):
                parts.append(fm[i].strip())
                i += 1
            out[key] = (" " if folded else "\n").join(p for p in parts if p)
            continue
        out[key] = val.strip('"').strip("'")
        i += 1
    return out


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--sessions-dir", default=str(Path.home() / ".omp/agent/sessions"))
    ap.add_argument("--skills-dir", default=str(Path.home() / ".omp/agent/skills"))
    ap.add_argument("--exclude", action="append", default=[], help="skip project dirs starting with this prefix (use --exclude=PROBE)")
    ap.add_argument("--exclude-probe", action="store_true", help="skip -tmp* probe sessions")
    ap.add_argument("--json", action="store_true")
    args = ap.parse_args()

    root = Path(args.sessions_dir)
    files = sorted(root.glob("**/*.jsonl"))
    skills = collections.Counter()
    tools = collections.Counter()
    per_project = collections.defaultdict(collections.Counter)
    project_sessions = collections.Counter()
    project_zero = collections.Counter()
    first = last = None
    cost = collections.Counter()
    calls = collections.Counter()
    session_cost = collections.Counter()
    tool_ids = {}
    tool_totals = collections.Counter()
    tool_errors = collections.Counter()

    catalog = {}
    skills_dir = Path(args.skills_dir)
    for d in sorted(skills_dir.iterdir()) if skills_dir.is_dir() else []:
        f = d / "SKILL.md"
        if not f.is_file():
            continue
        fm = parse_frontmatter(f)
        desc = " ".join(fm.get("description", "").split())
        body = f.read_text(encoding="utf-8", errors="replace")
        catalog[fm.get("name") or d.name] = {
            "desc_tokens": max(1, len(desc) // 4),
            "body_tokens": max(1, len(body) // 4),
        }

    for f in files:
        project = f.relative_to(root).parts[0]
        if any(project.startswith(p) for p in args.exclude):
            continue
        if args.exclude_probe and project.startswith("-tmp"):
            continue
        project_sessions[project] += 1
        reads = 0
        try:
            fh = open(f, encoding="utf-8", errors="replace")
        except OSError:
            continue
        with fh:
            for line in fh:
                if not ('"toolCall"' in line or '"toolResult"' in line or '"type":"message"' in line):
                    continue
                try:
                    d = json.loads(line)
                except json.JSONDecodeError:
                    continue
                msg = d.get("message") or {}
                if d.get("type") == "message" and msg.get("role") == "assistant":
                    usage = msg.get("usage") or {}
                    spend = (usage.get("cost") or {}).get("total") or 0
                    model = msg.get("model") or "?"
                    cost[model] += spend
                    calls[model] += 1
                    session_cost[str(f)] += spend
                elif msg.get("role") == "toolResult":
                    cid = msg.get("toolCallId") or msg.get("tool_call_id") or msg.get("id")
                    name = tool_ids.get(cid, "?")
                    tool_totals[name] += 1
                    if msg.get("isError"):
                        tool_errors[name] += 1
                for c in msg.get("content") or []:
                    if c.get("type") != "toolCall":
                        continue
                    tool_name = c.get("name", "?")
                    tools[tool_name] += 1
                    tool_ids[c.get("id")] = tool_name
                    path = str((c.get("arguments") or {}).get("path", ""))
                    if path.startswith("skill://"):
                        name = path[8:].split("/", 1)[0]
                        if name in catalog:
                            skills[name] += 1
                            per_project[project][name] += 1
                            reads += 1
        if reads == 0:
            project_zero[project] += 1
        ts = f.stat().st_mtime
        first = ts if first is None or ts < first else first
        last = ts if last is None or ts > last else last

    total_sessions = sum(project_sessions.values())
    zero_sessions = sum(project_zero.values())
    unused = sorted((n for n in catalog if n not in skills), key=lambda n: -catalog[n]["desc_tokens"])
    report = {
        "sessions": total_sessions,
        "zero_skill_sessions": zero_sessions,
        "skills_read": skills.most_common(),
        "tools": tools.most_common(),
        "per_project": {p: dict(c) for p, c in per_project.items()},
        "catalog": catalog,
        "unused": unused,
        "always_loaded_unused_desc_tokens": sum(catalog[n]["desc_tokens"] for n in unused),
        "cost_by_model": cost.most_common(),
        "total_cost": sum(cost.values()),
        "tool_errors": {n: [tool_errors[n], tool_totals[n]] for n in tool_errors},
    }

    if args.json:
        print(json.dumps(report, indent=2))
        return 0

    span = ""
    if first and last:
        import datetime
        span = f" · {datetime.date.fromtimestamp(first)}..{datetime.date.fromtimestamp(last)}"
    print(f"sessions: {total_sessions}{span} · zero-skill: {zero_sessions}/{total_sessions}"
          f" ({100 * zero_sessions / max(1, total_sessions):.0f}%)")
    print(f"skills loaded: {len(skills)}/{len(catalog)} · unused desc cost ~{report['always_loaded_unused_desc_tokens']}t/request")

    print("\nprojects (sessions / zero-skill / reads):")
    for p in sorted(project_sessions):
        mark = " [probe]" if p.startswith("-tmp") else ""
        print(f"  {p:58s} {project_sessions[p]:4d} {project_zero[p]:4d} {sum(per_project[p].values()):4d}{mark}")

    print("\ntop skills:")
    for name, n in skills.most_common(15):
        print(f"  {name:32s} {n:4d}")

    print(f"\nunused ({len(unused)}), desc tokens each:")
    for name in unused:
        print(f"  {name:32s} ~{catalog[name]['desc_tokens']}t desc / ~{catalog[name]['body_tokens']}t body")

    print("\ntools:")
    for name, n in tools.most_common(12):
        print(f"  {name:20s} {n:5d}")
    for name in ("lsp", "ast_edit", "debug", "eval"):
        if name not in tools:
            print(f"  {name:20s}     0")

    print("\ncost by model:")
    for model, spend in cost.most_common():
        print(f"  {model:48s} ${spend:6.2f} {calls[model]:5d} calls")
    print(f"  total ${sum(cost.values()):.2f} / {sum(calls.values())} calls")

    print("\ntop sessions:")
    for path, spend in session_cost.most_common(5):
        print(f"  ${spend:5.2f} {Path(path).name}")

    print("\ntool errors:")
    if not tool_errors:
        print("  none")
    for name, n in tool_errors.most_common():
        print(f"  {name:12s} {n}/{tool_totals[name]} ({100 * n / tool_totals[name]:.0f}%)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
