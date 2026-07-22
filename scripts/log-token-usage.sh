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
# cache_creation_input_tokens}) alongside `message.model`. Subagent (Task)
# usage lives in SEPARATE transcript files, so we sum the main transcript AND
# its subagent transcripts, per model.
#
# Correlation: we identify THIS session's metrics file from the orchestrator's
# *write* of it in the transcript (a write tool_use input contains both
# "run-metrics-" and "token_counts"; a mere Read does not), then fill the newest
# still-unfilled run-metrics file in that directory. If the main transcript
# doesn't contain that write (e.g. a subagent performed it, or naming layout
# differs), we widen the search to every JSONL file in the session directory
# by content match before giving up. If a target file can only be found via
# that low-confidence, directory-unscoped last resort, we do NOT attribute
# token numbers to it — we write an explicit unavailable/reason object instead
# of leaving the literal "pending" sentinel in place forever.
#
# Registered automatically via the plugin's hooks/hooks.json. It can also be
# added manually to ~/.claude/settings.json (see README "Token & cost tracking").

PAYLOAD=$(cat)
CE_PAYLOAD="$PAYLOAD" python3 <<'PYEOF' 2>>"${TMPDIR:-/tmp}/career-engine-hook.log"
import os, sys, json, glob, re, datetime

def log(m): print(f"[ce-token-hook] {m}", file=sys.stderr)

# Per-model rate table — USD per 1M tokens, base input/output as specified.
# cache_write/cache_read are derived at the same ratio Anthropic publishes for
# Opus (cache_write = input * 1.25, cache_read = input * 0.10). Matched against
# the JSONL entry's message.model field by case-insensitive substring.
BASE_RATES = {
    "opus":   {"input": 15.0, "output": 75.0},
    "sonnet": {"input": 3.0,  "output": 15.0},
    "haiku":  {"input": 1.0,  "output": 5.0},
    "fable":  {"input": 15.0, "output": 75.0},
}
DEFAULT_RATE_KEY = "opus"

def rates_for_key(key):
    b = BASE_RATES[key]
    return {
        "input": b["input"],
        "output": b["output"],
        "cache_write": round(b["input"] * 1.25, 4),
        "cache_read": round(b["input"] * 0.10, 4),
    }

RATES = {k: rates_for_key(k) for k in BASE_RATES}

def resolve_rate_key(model_name):
    """Match a message.model string to a rate key by substring. Unknown models
    fall back to Opus rates and are flagged via the returned `assumed` bool."""
    m = (model_name or "").lower()
    for key in ("opus", "sonnet", "haiku", "fable"):
        if key in m:
            return key, False
    return DEFAULT_RATE_KEY, True

try:
    payload = json.loads(os.environ.get("CE_PAYLOAD", "{}"))
except Exception:
    sys.exit(0)

transcript = payload.get("transcript_path") or ""
session_id = payload.get("session_id") or ""
cwd = payload.get("cwd") or ""
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

def blank_model_bucket():
    return {"input": 0, "output": 0, "cache_read": 0, "cache_create": 0}

def add_usage(per_model, path):
    """Accumulate token usage keyed by the raw message.model string found on
    each usage-bearing entry in `path`."""
    n = 0
    for d in iter_entries(path):
        msg = d.get("message") or {}
        u = msg.get("usage") or d.get("usage")
        if not u:
            continue
        model = msg.get("model") or d.get("model") or "unknown"
        b = per_model.setdefault(model, blank_model_bucket())
        b["input"]        += u.get("input_tokens", 0) or 0
        b["output"]       += u.get("output_tokens", 0) or 0
        b["cache_read"]   += u.get("cache_read_input_tokens", 0) or 0
        b["cache_create"] += u.get("cache_creation_input_tokens", 0) or 0
        n += 1
    return n

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

per_model = {}
add_usage(per_model, transcript)
for s in subs:
    add_usage(per_model, s)
log(f"summed main + {len(subs)} subagent transcript(s); models seen: {list(per_model)}")

# --- find THIS session's run-metrics file ---
def find_hint(paths):
    """Scan the given JSONL files for a write tool_use whose input mentions
    both a run-metrics path and 'token_counts'. Last match across all given
    paths wins (mirrors 'last write in the session wins')."""
    hint = None
    for p in paths:
        for d in iter_entries(p):
            content = (d.get("message") or {}).get("content")
            for b in (content if isinstance(content, list) else []):
                if isinstance(b, dict) and b.get("type") == "tool_use":
                    s = json.dumps(b.get("input", {}))
                    if "run-metrics-" in s and "token_counts" in s:
                        m = re.search(r'(/[^"\']*?/run-metrics-[^"\']*\.json)', s)
                        if m:
                            hint = m.group(1)
    return hint

metrics_path_hint = find_hint([transcript])
scanned_all_jsonl = False
if not metrics_path_hint:
    log("no run-metrics write found in main transcript; falling back to scanning "
        "all candidate JSONL files in the session dir by content match")
    scanned_all_jsonl = True
    all_jsonl = set(glob.glob(os.path.join(tdir, "*.jsonl")))
    all_jsonl |= set(glob.glob(os.path.join(tdir, "**", "*.jsonl"), recursive=True))
    all_jsonl.discard(os.path.abspath(transcript))
    metrics_path_hint = find_hint(sorted(all_jsonl))
if not metrics_path_hint:
    log("no pipeline run-metrics write found anywhere in the session dir; "
        "will attempt a last-resort directory scan")

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

metrics_path, data, trusted = None, None, False

# Tier 1: the exact file the orchestrator wrote, if the literal path resolved.
if (metrics_path_hint and "$(" not in metrics_path_hint and "`" not in metrics_path_hint
        and os.path.isfile(metrics_path_hint)):
    metrics_path, data, trusted = metrics_path_hint, load(metrics_path_hint), True

# Tier 2 (mtime-guess): newest still-unfilled run-metrics file in the hinted
# directory (e.g. the write used $(date), so the literal path is unexpanded).
if data is None and metrics_path_hint:
    mdir = os.path.dirname(metrics_path_hint)
    cands = []
    for p in glob.glob(os.path.join(mdir, "run-metrics-*.json")):
        dd = load(p)
        if dd is not None and is_unfilled(dd.get("token_counts")):
            cands.append((os.path.getmtime(p), p, dd))
    if cands:
        cands.sort(reverse=True)
        _, metrics_path, data = cands[0]
        trusted = True

# Tier 3 (last resort, on mtime-guess failure): broaden the search beyond the
# hinted directory to the session dir and the hook payload's cwd, still only
# considering still-unfilled run-metrics files. A file found only here was not
# confidently correlated to this session, so it is NOT treated as trustworthy
# enough to receive real token numbers (see the write-out logic below).
if data is None:
    search_dirs = {tdir}
    if cwd:
        search_dirs.add(cwd)
    if metrics_path_hint:
        search_dirs.add(os.path.dirname(metrics_path_hint))
    cands = []
    for sd in search_dirs:
        if not sd or not os.path.isdir(sd):
            continue
        for p in glob.glob(os.path.join(sd, "run-metrics-*.json")):
            dd = load(p)
            if dd is not None and is_unfilled(dd.get("token_counts")):
                cands.append((os.path.getmtime(p), p, dd))
    if cands:
        cands.sort(reverse=True)
        _, metrics_path, data = cands[0]
        trusted = False

if data is None:
    log(f"could not resolve any run-metrics file (hint={metrics_path_hint!r}, "
        f"scanned_all_jsonl={scanned_all_jsonl}); nothing to write")
    sys.exit(0)

# --- per-model token + cost breakdown ---
grand = blank_model_bucket()
by_model = {}
any_rate_assumed = False
for model, b in per_model.items():
    rate_key, assumed = resolve_rate_key(model)
    r = RATES[rate_key]
    cost = round(
        b["input"]        / 1e6 * r["input"] +
        b["output"]       / 1e6 * r["output"] +
        b["cache_create"] / 1e6 * r["cache_write"] +
        b["cache_read"]   / 1e6 * r["cache_read"], 4)
    any_rate_assumed = any_rate_assumed or assumed
    by_model[model] = {
        "rate_key": rate_key,
        "rate_assumed": assumed,
        "input_tokens": b["input"],
        "output_tokens": b["output"],
        "cache_read_tokens": b["cache_read"],
        "cache_creation_tokens": b["cache_create"],
        "total_tokens": sum(b.values()),
        "cost_usd_estimate": cost,
    }
    for k in grand:
        grand[k] += b[k]

grand_cost = round(sum(v["cost_usd_estimate"] for v in by_model.values()), 4)
now = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

if not trusted:
    # Could only locate a candidate file via the low-confidence last-resort
    # scan — do not stamp it with token numbers that may belong to a
    # different session. Replace "pending" with an explicit, honest status.
    data["token_counts"] = {
        "status": "unavailable",
        "reason": ("Could not confidently correlate this session's transcript "
                   "with a specific run-metrics file: no write reference was "
                   f"found in the main transcript{' or any JSONL file in the session dir' if scanned_all_jsonl else ''}, "
                   "so the target file was located only via an unscoped "
                   "directory fallback and token counts were withheld to avoid "
                   "attributing usage to the wrong run."),
        "session_id": session_id,
        "subagent_transcripts_counted": len(subs),
        "recorded_at": now,
    }
    log(f"low-confidence match only; wrote unavailable status to {metrics_path}")
else:
    data["token_counts"] = {
        "input_tokens": grand["input"],
        "output_tokens": grand["output"],
        "cache_read_tokens": grand["cache_read"],
        "cache_creation_tokens": grand["cache_create"],
        "total_tokens": sum(grand.values()),
        "cost_usd_estimate": grand_cost,
        "cost_note": ("Per-model rates (USD/1M, input/output): opus $15/$75, "
                       "sonnet $3/$15, haiku $1/$5, fable $15/$75; cache-write "
                       "= input rate * 1.25, cache-read = input rate * 0.10. "
                       "Unknown models fall back to Opus rates (see "
                       "rate_assumed / by_model.*.rate_assumed). >200K-context "
                       "premium not applied. Session-cumulative."),
        "rate_assumed": any_rate_assumed,
        "by_model": by_model,
        "session_id": session_id,
        "subagent_transcripts_counted": len(subs),
        "recorded_at": now,
    }

try:
    with open(metrics_path, "w") as f:
        json.dump(data, f, indent=2)
    if trusted:
        log(f"wrote token_counts to {metrics_path}: {sum(grand.values()):,} total, ${grand_cost}")
except Exception as e:
    log(f"failed to write {metrics_path}: {e}")

sys.exit(0)
PYEOF
exit 0
