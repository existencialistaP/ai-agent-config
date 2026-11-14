#!/usr/bin/env python3
"""Tier 2 routing eval: does each description carry the words users say?

Deterministic, free, no model calls. Stemmed TF-IDF over SKILL.md
descriptions, scored against positive prompts (rank-1 / top-3) and negative
prompts (another skill must win), plus a pairwise description-collision check.

It measures vocabulary coverage, NOT live routing: a description can contain
every word and the model still answer directly. Use route_live.py for that.

Usage:
  python3 route_evals.py                 # report
  python3 route_evals.py --strict        # exit 1 on any violation
  python3 route_evals.py --skills simplify,test-driven-development
"""

from __future__ import annotations

import argparse
import json
import math
import os
import re
import sys
from pathlib import Path

STOP = set(
    """a an and are as at be before but by can could do does done for from has
    have if in into is it its may might must no not of on only or other our
    should than that the their them then there these they this to use used
    uses using was we were what when where which who will with would you your
    i also any all more most""".split()
)


def stem(w: str) -> str:
    if len(w) <= 3:
        return w
    if w.endswith("ies") and len(w) > 5:
        return w[:-3] + "y"
    if w.endswith("ied") and len(w) > 5:
        return w[:-3] + "y"
    for suf in ("ations", "ation", "ings", "ing", "ments", "ment", "ers", "er", "ed", "es", "s", "ly"):
        if w.endswith(suf) and len(w) - len(suf) >= 3:
            w = w[: -len(suf)]
            break
    if len(w) > 3 and w[-1] == w[-2] and w[-1] in "bdgmnprt":
        w = w[:-1]
    return w


def tokens(text: str) -> list[str]:
    words = re.findall(r"[a-z0-9]+", text.lower())
    return [stem(w) for w in words if w not in STOP and len(w) > 1]


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


def load_skills(skills_dir: Path) -> dict[str, list[str]]:
    docs = {}
    for d in sorted(skills_dir.iterdir()):
        f = d / "SKILL.md"
        if not d.is_dir() or not f.is_file():
            continue
        fm = parse_frontmatter(f)
        name = fm.get("name") or d.name
        desc = " ".join(fm.get("description", "").split())
        if desc:
            docs[name] = tokens(desc)
    return docs


def vectors(docs: dict[str, list[str]]) -> tuple[dict[str, dict[str, float]], dict[str, float]]:
    n = len(docs)
    df: dict[str, int] = {}
    for toks in docs.values():
        for t in set(toks):
            df[t] = df.get(t, 0) + 1
    idf = {t: math.log((n + 1) / (c + 1)) + 1 for t, c in df.items()}
    vecs = {}
    for name, toks in docs.items():
        tf: dict[str, int] = {}
        for t in toks:
            tf[t] = tf.get(t, 0) + 1
        v = {t: (1 + math.log(c)) * idf[t] for t, c in tf.items()}
        norm = math.sqrt(sum(x * x for x in v.values())) or 1.0
        vecs[name] = {t: x / norm for t, x in v.items()}
    return vecs, idf


def rank(prompt: str, vecs: dict[str, dict[str, float]], idf: dict[str, float]) -> list[tuple[float, str]]:
    toks = tokens(prompt)
    tf: dict[str, int] = {}
    for t in toks:
        tf[t] = tf.get(t, 0) + 1
    q = {t: (1 + math.log(c)) * idf.get(t, 0.0) for t, c in tf.items()}
    norm = math.sqrt(sum(x * x for x in q.values())) or 1.0
    q = {t: x / norm for t, x in q.items()}
    scored = [(sum(x * d.get(t, 0.0) for t, x in q.items()), name) for name, d in vecs.items()]
    return sorted(scored, reverse=True)


def family(name: str) -> str:
    return name.split("-", 1)[0]


def main() -> int:
    here = Path(__file__).resolve().parent
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--skills-dir", default=os.environ.get("OMP_USER_SKILLS", str(Path.home() / ".omp/agent/skills")))
    ap.add_argument("--cases", default=str(here.parent / "evals" / "routing.json"))
    ap.add_argument("--skills", help="comma-separated subset to run")
    ap.add_argument("--strict", action="store_true", help="exit 1 on any failure or collision warning")
    args = ap.parse_args()

    skills_dir = Path(args.skills_dir).expanduser()
    docs = load_skills(skills_dir)
    if not docs:
        print(f"no skills with descriptions under {skills_dir}", file=sys.stderr)
        return 2
    vecs, idf = vectors(docs)

    cases = json.loads(Path(args.cases).read_text())
    selected = set(args.skills.split(",")) if args.skills else set(cases)
    missing = selected - set(cases)
    if missing:
        print(f"no cases for: {', '.join(sorted(missing))}", file=sys.stderr)
        return 2

    pos_total = pos_hit1 = pos_hit3 = 0
    failures: list[str] = []
    negatives: list[str] = []
    violations = 0

    print(f"=== Tier 2 routing: {len(docs)} skills, {len(selected)} case sets ===")
    for skill in sorted(selected):
        spec = cases[skill]
        h1 = h3 = 0
        for prompt in spec.get("positive", []):
            ranked = rank(prompt, vecs, idf)
            pos_total += 1
            names = [n for _, n in ranked[:3]]
            if names[0] == skill:
                h1 += 1
                pos_hit1 += 1
            if skill in names:
                h3 += 1
                pos_hit3 += 1
            else:
                failures.append(f"  MISS {skill:32s} rank={_rank_of(ranked, skill):>3}  {prompt[:64]!r}\n         top3={', '.join(f'{n}({s:.2f})' for s, n in ranked[:3])}")
        for neg in spec.get("negative", []):
            ranked = rank(neg["prompt"], vecs, {})
            if ranked and ranked[0][1] == skill:
                violations += 1
                negatives.append(f"  VIOLATION {skill} outranks {neg.get('owner', '?')}: {neg['prompt'][:64]!r}")
            elif neg.get("owner") and _rank_of(ranked, neg["owner"]) > _rank_of(ranked, skill):
                negatives.append(f"  owner-behind {neg['owner']} vs {skill}: {neg['prompt'][:48]!r}")
        print(f"  {skill:32s} rank-1 {h1}/{len(spec.get('positive', []))}  top-3 {h3}/{len(spec.get('positive', []))}")

    pct1 = 100 * pos_hit1 / pos_total if pos_total else 0
    pct3 = 100 * pos_hit3 / pos_total if pos_total else 0
    print(f"\npositive rank-1: {pos_hit1}/{pos_total} ({pct1:.0f}%)   top-3: {pos_hit3}/{pos_total} ({pct3:.0f}%)")
    if failures:
        print("\nfailures:")
        print("\n".join(failures))
    print(f"negative violations: {violations}")
    if negatives:
        print("\nnegative notes:")
        print("\n".join(negatives))

    # Collisions: cross-family pairs are real routing risk; same-family is expected.
    pairs = []
    names = sorted(docs)
    for i, a in enumerate(names):
        for b in names[i + 1:]:
            sim = sum(x * vecs[b].get(t, 0.0) for t, x in vecs[a].items())
            if sim >= 0.30:
                pairs.append((sim, a, b))
    pairs.sort(reverse=True)
    cross = [(s, a, b) for s, a, b in pairs if family(a) != family(b)]
    same = [(s, a, b) for s, a, b in pairs if family(a) == family(b)]
    print(f"\ncollisions: {len(cross)} cross-family >=0.30, {len(same)} same-family >=0.30")
    for sim, a, b in cross[:10]:
        flag = "ERROR" if sim >= 0.75 else "WARN " if sim >= 0.50 else "info "
        print(f"  [{flag}] {sim:.2f}  {a} <-> {b}")
    if cross:
        print(f"  max cross-family similarity: {cross[0][0]:.2f}")

    bad = violations > 0 or any(s >= 0.75 for s, _, _ in cross) or (args.strict and failures)
    return 1 if bad else 0


def _rank_of(ranked: list[tuple[float, str]], name: str) -> int:
    for i, (_, n) in enumerate(ranked, 1):
        if n == name:
            return i
    return 999


if __name__ == "__main__":
    sys.exit(main())
