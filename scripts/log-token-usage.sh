#!/bin/bash
# log-token-usage.sh — career-engine Stop hook
#
# Writes real token usage into the run-metrics-<date>.json file the pipeline
# created during THIS session.
#
# IMPORTANT (R-40): token counts are NOT in the Stop hook stdin payload. The
# payload provides only `transcript_path`, `session_id`, `cwd`, `hook_event_name`.
# Token usage lives in the transcript JSONL, under each assistant message's
# `message.usage` ({input_tokens, output_tokens, cache_read_input_tokens,
# cache_creation_input_tokens}). Subagent (Task) usage lives in SEPARATE
# transcript files, so we sum the main transcript AND its subagent transcripts.
#
# Correlation: we identify THIS session's metrics file from the orchestrator's
# *write* of it in the transcript (a write tool_use input contains both
# "run-metrics-" and "token_counts"; a mere Read does not), then fill the newest
# still-unfilled run-metrics file in that directory. This is session-scoped, so
# it never contaminates another session's file and never leaves a sibling
# "pending" because of mtime guesswork.
#
# Registered automatically via the plugin's hooks/hooks.json. It can also be
# added manually to ~/.claude/settings.json (see README "Token & cost tracking").

PAYLOAD=$(cat)
CE_PAYLOAD="$PAYLOAD" python3 <<'PYEOF' 2>>"${TMPDIR:-/tmp}/career-engine-hook.log"
import os, sys, json, glob, re, datetime

def log(m): print(f"[ce-token-hook] {m}", file=sys.stderr)

# Opus rate table — USD per 1M tokens. Adjust here if rates change.
RATES = {"input": 15.0, "output": 75.0, "cache_write": 18.75, "cache_read": 1.50}

try:
    payload = json.loads(os.environ.get("CE_PAYLOAD", "{}"))
except Exception:
    sys.exit(0)

transcript = payload.get("transcript_path") or ""
session_id = payload.get("session_id") or ""
if not transcript or not os.path.isfile(transcript):
    log(f"no readable transcript ({transcript!r}); nothing to do")
    sys.exit(0)

def iter_entries(path):
    try:
        with open(path, errors="ignore") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    yield json.loads(line)
                except Exception:
                    continue
    except Exception:
        return

def add_usage(totals, path):
    for d in iter_entries(path):
        u = (d.get("message") or {}).get("usage") or d.get("usage")
        if not u:
            continue
        totals["input"]        += u.get("input_tokens", 0) or 0
        totals["output"]       += u.get("output_tokens", 0) or 0
        totals["cache_read"]   += u.get("cache_read_input_tokens", 0) or 0
        totals["cache_create"] += u.get("cache_creation_input_tokens", 0) or 0

# --- discover subagent transcripts (CLI and Cowork host-loop layouts) ---
tdir = os.path.dirname(transcript)
base = os.path.basename(transcript)
base = base[:-6] if base.endswith(".jsonl") else base
subs = set()
for pat in (
    os.path.join(tdir, f"{base}-subagent-*.jsonl"),   # CLI
    os.path.join(tdir, base, "subagents", "*.jsonl"),  # host-loop: <session>/subagents/
    os.path.join(tdir, "subagents", "*.jsonl"),        # transcript already inside session dir
):
    for p in glob.glob(pat):
        if os.path.abspath(p) != os.path.abspath(transcript):
            subs.add(p)

totals = {"input": 0, "output": 0, "cache_read": 0, "cache_create": 0}
add_usage(totals, transcript)
for s in subs:
    add_usage(totals, s)
log(f"summed main + {len(subs)} subagent transcript(s): {totals}")

# --- find THIS session's run-metrics directory from the orchestrator's write ---
metrics_path_hint = None
for d in iter_entries(transcript):
    content = (d.get("message") or {}).get("content")
    for b in (content if isinstance(content, list) else []):
        if isinstance(b, dict) and b.get("type") == "tool_use":
            s = json.dumps(b.get("input", {}))
            if "run-metrics-" in s and "token_counts" in s:
                m = re.search(r'(/[^"\']*?/run-metrics-[^"\']*\.json)', s)
                if m:
                    metrics_path_hint = m.group(1)   # last write in the session wins
if not metrics_path_hint:
    log("no pipeline run-metrics write found in this session; nothing to fill")
    sys.exit(0)

def load(p):
    try:
        with open(p) as f:
            return json.load(f)
    except Exception:
        return None

def is_unfilled(tc):
    """Needs counts if token_counts is the pending string sentinel, or a dict
    whose token values are missing / unknown / zero."""
    if isinstance(tc, dict):
        for k in ("input_tokens", "output_tokens"):
            v = tc.get(k)
            if isinstance(v, (int, float)) and v > 0:
                return False
            if isinstance(v, str) and v.strip().isdigit() and int(v) > 0:
                return False
        return True
    return True

# Primary: the exact file the orchestrator wrote, if the literal path resolved.
metrics_path, data = None, None
if "$(" not in metrics_path_hint and "`" not in metrics_path_hint and os.path.isfile(metrics_path_hint):
    metrics_path, data = metrics_path_hint, load(metrics_path_hint)
# Fallback (e.g. the write used $(date), so the literal path is unexpanded):
# newest still-unfilled run-metrics file in that directory.
if data is None:
    mdir = os.path.dirname(metrics_path_hint)
    cands = []
    for p in glob.glob(os.path.join(mdir, "run-metrics-*.json")):
        dd = load(p)
        if dd is not None and is_unfilled(dd.get("token_counts")):
            cands.append((os.path.getmtime(p), p, dd))
    if cands:
        cands.sort(reverse=True)
        _, metrics_path, data = cands[0]
if data is None:
    log(f"could not resolve a run-metrics file from hint {metrics_path_hint!r}")
    sys.exit(0)

cost = round(
    totals["input"]        / 1e6 * RATES["input"] +
    totals["output"]       / 1e6 * RATES["output"] +
    totals["cache_create"] / 1e6 * RATES["cache_write"] +
    totals["cache_read"]   / 1e6 * RATES["cache_read"], 2)

data["token_counts"] = {
    "input_tokens": totals["input"],
    "output_tokens": totals["output"],
    "cache_read_tokens": totals["cache_read"],
    "cache_creation_tokens": totals["cache_create"],
    "total_tokens": sum(totals.values()),
    "cost_usd_estimate": cost,
    "cost_note": "Opus rates: input $15 / output $75 / cache-write $18.75 / cache-read $1.50 per 1M. >200K-context premium not applied. Session-cumulative.",
    "session_id": session_id,
    "subagent_transcripts_counted": len(subs),
    "recorded_at": datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
}
try:
    with open(metrics_path, "w") as f:
        json.dump(data, f, indent=2)
    log(f"wrote token_counts to {metrics_path}: {totals['input']+totals['output']+totals['cache_read']+totals['cache_create']:,} total, ${cost}")
except Exception as e:
    log(f"failed to write {metrics_path}: {e}")

sys.exit(0)
PYEOF
exit 0
