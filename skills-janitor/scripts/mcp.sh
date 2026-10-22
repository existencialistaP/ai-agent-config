#!/bin/bash
# Skills Janitor - MCP Server Inventory & Usage
# Inventories every configured MCP server (user, project, per-project entries
# in ~/.claude.json, plugin-bundled .mcp.json) and cross-references REAL
# usage from Claude Code session transcripts (tool_use entries named
# mcp__<server>__<tool>).
#
# Unlike skills, MCP tool schemas live server-side — the janitor does not
# invent token numbers for them. It reports what it can prove: where the
# server is configured, how many distinct tools you've actually called,
# how often, and when last.
#
# Usage:
#   mcp.sh [--weeks N] [--json]

set -euo pipefail

command -v python3 &>/dev/null || { echo "ERROR: python3 required" >&2; exit 1; }

WEEKS=8
JSON_OUTPUT=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        --weeks) WEEKS="$2"; shift 2 ;;
        --json) JSON_OUTPUT=true; shift ;;
        -h|--help) echo "Usage: mcp.sh [--weeks N] [--json]"; exit 0 ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

# --- Transcript usage: pre-filter with grep (transcript trees run to GBs) ---
# Only lines containing an mcp__ tool_use name are relevant; only files
# modified inside the lookback window are read at all.
USAGE_TMP=$(mktemp -t janitor-mcp.XXXXXX)
trap 'rm -f "$USAGE_TMP"' EXIT

DAYS=$((WEEKS * 7))
for _proj_root in "${CLAUDE_CONFIG_DIR:-/nonexistent}/projects" "$HOME/.claude/projects" "$HOME"/.claude-account-*/projects; do
    [[ -d "$_proj_root" ]] || continue
    # realpath-dedup roots (~/.claude may symlink to an account dir)
    _rr=$(cd "$_proj_root" 2>/dev/null && pwd -P || echo "$_proj_root")
    case "|${_seen_roots:-}|" in *"|$_rr|"*) continue ;; esac
    _seen_roots="${_seen_roots:-}|$_rr"
    find "$_proj_root" -name "*.jsonl" -type f -mtime "-$DAYS" 2>/dev/null \
        | while IFS= read -r f; do
            LC_ALL=C grep -h '"name":"mcp__' "$f" 2>/dev/null || true
        done >> "$USAGE_TMP"
done

# OMP records MCP calls as mcp__<server>_<tool> in its session transcripts
# (single underscore between server and tool), so pair each marker with the
# session file's mtime date instead of a per-line timestamp.
if [[ -d "$HOME/.omp/agent/sessions" ]]; then
    find "$HOME/.omp/agent/sessions" -name "*.jsonl" -type f -mtime "-$DAYS" 2>/dev/null \
        | while IFS= read -r f; do
            _d=$(stat -c %y "$f" 2>/dev/null | cut -c1-10 || stat -f %Sm -t %Y-%m-%d "$f" 2>/dev/null) || continue
            LC_ALL=C grep -ho 'mcp__[a-z0-9][a-z0-9_]*' "$f" 2>/dev/null | sed "s|$| $_d|" || true
        done >> "$USAGE_TMP"
fi

export USAGE_TMP WEEKS JSON_OUTPUT
export CLAUDE_JSON="$HOME/.claude.json"
export PROJECT_MCP="./.mcp.json"
export INSTALLED_PLUGINS_FILE="$HOME/.claude/plugins/installed_plugins.json"
# This environment: OMP declares its servers in mcp.json, same mcpServers
# shape as Claude's user config; it is deliberately not parsed here.
export OMP_MCP="$HOME/.omp/agent/mcp.json"

python3 <<'PYEOF'
import json
import os
import re
import sqlite3
import sys
from collections import defaultdict
from datetime import datetime, timedelta, timezone

WEEKS = int(os.environ.get("WEEKS", "8"))
JSON_OUTPUT = os.environ.get("JSON_OUTPUT", "false") == "true"

# --- Inventory ---------------------------------------------------------------
servers = {}  # name -> record; first scope wins, extra scopes appended

def add(name, scope, origin, cfg):
    key = name
    if key in servers:
        if scope not in servers[key]["scopes"]:
            servers[key]["scopes"].append(scope)
        return
    servers[key] = {
        "name": name,
        "scope": scope,
        "scopes": [scope],
        "origin": origin,   # config file (or plugin) the entry lives in
        "transport": cfg.get("type", "stdio") if isinstance(cfg, dict) else "stdio",
        "command": (cfg.get("command", "") if isinstance(cfg, dict) else "")[:120],
        "url": (cfg.get("url", "") if isinstance(cfg, dict) else "")[:200],
    }

cj_path = os.environ.get("CLAUDE_JSON", "")
if cj_path and os.path.isfile(cj_path):
    try:
        cj = json.load(open(cj_path))
    except Exception:
        cj = {}
    for name, cfg in (cj.get("mcpServers") or {}).items():
        add(name, "mcp-user", cj_path, cfg)
    for proj, pdata in (cj.get("projects") or {}).items():
        if not isinstance(pdata, dict):
            continue
        for name, cfg in (pdata.get("mcpServers") or {}).items():
            add(name, "mcp-project", f"{cj_path} [projects -> {proj}]", cfg)

omp_path = os.environ.get("OMP_MCP", "")
if omp_path and os.path.isfile(omp_path):
    try:
        d = json.load(open(omp_path))
        for name, cfg in (d.get("mcpServers") or {}).items():
            add(name, "mcp-omp", omp_path, cfg)
    except Exception:
        pass

pm = os.environ.get("PROJECT_MCP", "")
if pm and os.path.isfile(pm):
    try:
        d = json.load(open(pm))
        for name, cfg in (d.get("mcpServers") or {}).items():
            add(name, "mcp-project", os.path.abspath(pm), cfg)
    except Exception:
        pass

# Plugin-bundled MCP servers: <installPath>/.mcp.json
ip = os.environ.get("INSTALLED_PLUGINS_FILE", "")
if ip and os.path.isfile(ip):
    try:
        data = json.load(open(ip))
        plugins = data.get("plugins") if isinstance(data, dict) else None
        for key, instances in (plugins or {}).items():
            pname = key.split("@", 1)[0]
            for inst in instances if isinstance(instances, list) else []:
                path = inst.get("installPath", "") if isinstance(inst, dict) else ""
                mcp_file = os.path.join(path, ".mcp.json")
                if path and os.path.isfile(mcp_file):
                    try:
                        d = json.load(open(mcp_file))
                        for name, cfg in (d.get("mcpServers") or {}).items():
                            add(name, "mcp-plugin", f"plugin:{pname}", cfg)
                    except Exception:
                        pass
    except Exception:
        pass

# --- Usage from transcripts --------------------------------------------------
NAME_RX = re.compile(r'"name":"mcp__([^_"][^"]*?)__([^"]+)"')
TS_RX = re.compile(r'"timestamp":"([0-9T:.\-]+)')

calls = defaultdict(int)          # server -> total calls
tools = defaultdict(set)          # server -> distinct tools called
last_used = {}                    # server -> iso ts

usage_tmp = os.environ.get("USAGE_TMP", "")
# OMP emits "<marker> <mtime-date>" lines and uses a single underscore between
# server and tool, so resolve the server against the inventory by longest
# prefix rather than by splitting on "__".
OMP_RX = re.compile(r'(mcp__[a-z0-9_]+) (\d{4}-\d{2}-\d{2})\b')
_omp_names = sorted(servers.keys(), key=len, reverse=True)
if usage_tmp and os.path.isfile(usage_tmp):
    with open(usage_tmp, errors="replace") as f:
        for line in f:
            names = NAME_RX.findall(line)
            ts_m = TS_RX.search(line)
            ts = ts_m.group(1)[:10] if ts_m else ""
            for server, tool in names:
                calls[server] += 1
                tools[server].add(tool)
                if ts and ts > last_used.get(server, ""):
                    last_used[server] = ts
            for marker, day in OMP_RX.findall(line):
                rest = marker[len("mcp__"):]
                server = next((n for n in _omp_names if rest.startswith(n + "_")), None)
                if server is None:
                    server = rest.partition("_")[0]
                if server not in servers:
                    continue
                calls[server] += 1
                tools[server].add(rest[len(server) + 1:] or rest)
                if day > last_used.get(server, ""):
                    last_used[server] = day

# Hook-based activity: a server that intercepts tool calls through harness hooks
# never appears as an MCP tool call. context-mode records its own events under
# the adapter's storage root, so count those separately instead of reporting a
# working integration as unused.
hook_activity = {}
for _root in ("~/.omp/context-mode/sessions",
              "~/.codex/context-mode/sessions",
              "~/.pi/context-mode/sessions"):
    _dir = os.path.expanduser(_root)
    if not os.path.isdir(_dir):
        continue
    for _fn in sorted(os.listdir(_dir)):
        if not _fn.endswith(".db"):
            continue
        _n = 0
        try:
            _con = sqlite3.connect(f"file:{os.path.join(_dir, _fn)}?mode=ro", uri=True)
            for _tbl in ("session_events", "tool_calls"):
                try:
                    _n += _con.execute(f"SELECT COUNT(*) FROM {_tbl}").fetchone()[0]
                except sqlite3.Error:
                    pass
            _con.close()
        except sqlite3.Error:
            continue
        if _n:
            hook_activity["context-mode"] = hook_activity.get("context-mode", 0) + _n

# Transcript names may differ from config names (plugin MCP servers get
# prefixed/namespaced). Match loosely: exact, else substring either way.
def usage_for(cfg_name):
    if cfg_name in calls:
        return cfg_name
    low = cfg_name.lower().replace("-", "_")
    for used in calls:
        u = used.lower()
        if low in u or u in low:
            return used
    return None

rows = []
for s in servers.values():
    hit = usage_for(s["name"])
    # Hook adapters are keyed by the configured server name, not by the
    # transcript-derived name (a hook-only server has no transcript name).
    hooks = hook_activity.get(s["name"], 0) or (hook_activity.get(hit, 0) if hit else 0)
    rows.append({
        **{k: v for k, v in s.items() if k != "scopes"},
        "scope": ",".join(sorted(s["scopes"])),
        "calls": calls.get(hit, 0),
        "hook_activity": hooks,
        "distinct_tools_used": len(tools.get(hit, ())),
        "last_used": last_used.get(hit, "never"),
    })

# Servers seen in transcripts but not in any config (removed or session-scoped)
configured_hits = {usage_for(s["name"]) for s in servers.values()}
orphans = [
    {"name": u, "scope": "transcript-only", "origin": "(not in any config)",
     "transport": "?", "command": "", "url": "",
     "calls": calls[u], "distinct_tools_used": len(tools[u]),
     "last_used": last_used.get(u, "never")}
    for u in sorted(calls) if u not in configured_hits
]

rows.sort(key=lambda r: (r["calls"], r["last_used"]))

if JSON_OUTPUT:
    print(json.dumps({
        "period_weeks": WEEKS,
        "configured": len(rows),
        "unused": sum(1 for r in rows if r["calls"] == 0 and not r["hook_activity"]),
        "servers": rows,
        "transcript_only": orphans,
    }, indent=2))
    sys.exit(0)

print("=== Skills Janitor - MCP Servers ===")
print(f"Usage window: last {WEEKS} weeks of session transcripts")
print()
if not rows and not orphans:
    print("No MCP servers configured.")
    sys.exit(0)

print(f"  {'Server':<28} {'Scope':<12} {'Calls':>6} {'Tools':>6} {'Last Used':<11} Origin")
print(f"  {'─'*28} {'─'*12} {'─'*6} {'─'*6} {'─'*11} {'─'*24}")
for r in rows:
    print(f"  {r['name'][:28]:<28} {r['scope'][:12]:<12} {r['calls']:>6} {r['distinct_tools_used']:>6} {r['last_used']:<11} {r['origin'][:44]}")
print()
hooked = [r for r in rows if r["hook_activity"]]
for r in hooked:
    print(f"  note: {r['name']} — {r['hook_activity']} hook events in the adapter storage "
          f"(not MCP tool calls); a 0 in Calls is not 'unused' for these.")
if hooked:
    print()
unused = [r for r in rows if r["calls"] == 0 and not r["hook_activity"]]
if unused:
    print(f"--- Unused in {WEEKS} weeks ({len(unused)}) ---")
    for r in unused:
        print(f"  {r['name']} ({r['scope']}) — configured in {r['origin'][:60]}")
    print()
    print("  Every connected server loads its tool schemas into context.")
    print("  Consider removing unused entries (or /janitor-swipe to triage).")
if orphans:
    print(f"--- Seen in transcripts, not configured now ({len(orphans)}) ---")
    for r in orphans[:8]:
        print(f"  {r['name']} — {r['calls']} calls, last {r['last_used']}")
PYEOF
