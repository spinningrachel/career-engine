#!/usr/bin/env python3
"""qa-parity.py — relational consistency checks driven by scripts/qa-parity.json.

Usage: python3 scripts/qa-parity.py <target-dir>

Complements scripts/qa-mechanical.sh (presence checks) with the relational
layer: list parity across files, named-term closure, spawn-parameter context
checks, and $PIPE producer/consumer closure. Same output contract as
qa-mechanical.sh: one "PARITY <id>: PASS|FAIL — detail" line per check,
a summary line, exit 0 iff no failures.

Check kinds (see qa-parity.json):
  member_set   — every member string must appear in every listed location
                 (a location is a file, optionally scoped to the region between
                 two anchor strings). Catches list drift: a field added to one
                 enumeration but not its siblings.
  defined_term — a term other files cite by name must exist in its defining
                 file(s). Catches "per the X policy" pointing at nothing.
  context_set  — every paragraph in the listed files that contains `trigger`
                 must contain every `require` string, unless it contains one of
                 `alternates`. Catches spawn sites that drop a required param.
  pipe_closure — every $PIPE/$RUN_PIPE/$QUEUE_PIPE file token mentioned in a
                 pipeline doc must have at least one occurrence on a line with
                 a write marker in that same doc (or be listed in exceptions).
                 Catches "read a file no step ever writes".
"""
import json, os, re, sys

def die(msg):
    print(f"qa-parity: ERROR — {msg}", file=sys.stderr)
    sys.exit(2)

if len(sys.argv) != 2:
    die("usage: qa-parity.py <target-dir>")
TARGET = os.path.abspath(sys.argv[1])
MANIFEST = os.path.join(os.path.dirname(os.path.abspath(__file__)), "qa-parity.json")
if not os.path.isdir(TARGET):
    die(f"target dir not found: {TARGET}")
try:
    manifest = json.load(open(MANIFEST))
except Exception as e:
    die(f"cannot load {MANIFEST}: {e}")

PASS = 0
FAIL = 0
def report(cid, ok, detail=""):
    global PASS, FAIL
    if ok:
        print(f"PARITY {cid}: PASS")
        PASS += 1
    else:
        print(f"PARITY {cid}: FAIL — {detail}")
        FAIL += 1

def read(relpath):
    p = os.path.join(TARGET, relpath)
    if not os.path.isfile(p):
        return None
    return open(p, encoding="utf-8").read()

def region(text, start, end):
    if start:
        i = text.find(start)
        if i < 0:
            return None
        text = text[i:]
    if end:
        j = text.find(end)
        if j > 0:
            text = text[:j]
    return text

def loc_label(loc):
    lbl = loc["file"]
    if loc.get("start"):
        lbl += f" §'{loc['start'][:40]}'"
    return lbl

for cs in manifest.get("member_sets", []):
    cid = cs["id"]
    failures = []
    for loc in cs["locations"]:
        text = read(loc["file"])
        if text is None:
            failures.append(f"{loc['file']}: file missing")
            continue
        reg = region(text, loc.get("start"), loc.get("end"))
        if reg is None:
            failures.append(f"{loc_label(loc)}: start anchor not found")
            continue
        reg_l = reg.lower()
        skip = set(m.lower() for m in loc.get("skip_members", []))
        for m in cs["members"]:
            if m.lower() in skip:
                continue
            if m.lower() not in reg_l:
                failures.append(f"'{m}' missing from {loc_label(loc)}")
    report(cid, not failures, "; ".join(failures[:6]) + (" …" if len(failures) > 6 else ""))

for dt in manifest.get("defined_terms", []):
    cid = dt["id"]
    failures = []
    for f in dt["files"]:
        text = read(f)
        if text is None:
            failures.append(f"{f}: file missing")
        elif dt["term"].lower() not in text.lower():
            failures.append(f"'{dt['term']}' not defined/present in {f}")
    report(cid, not failures, "; ".join(failures))

for ctx in manifest.get("context_sets", []):
    cid = ctx["id"]
    failures = []
    hits = 0
    for f in ctx["files"]:
        text = read(f)
        if text is None:
            failures.append(f"{f}: file missing")
            continue
        for n, para in enumerate(re.split(r"\n\s*\n", text)):
            if ctx["trigger"] not in para:
                continue
            hits += 1
            if any(alt in para for alt in ctx.get("alternates", [])):
                continue
            missing = [r for r in ctx["require"] if r not in para]
            if missing:
                head = " ".join(para.split())[:70]
                failures.append(f"{f} para#{n} ('{head}…') missing: {', '.join(missing)}")
    if hits < ctx.get("min_sites", 1):
        failures.append(f"trigger '{ctx['trigger']}' found at {hits} site(s), expected >= {ctx.get('min_sites', 1)}")
    report(cid, not failures, "; ".join(failures[:4]) + (" …" if len(failures) > 4 else ""))

pc = manifest.get("pipe_closure")
if pc:
    token_re = re.compile(r"\$(?:PIPE|RUN_PIPE|QUEUE_PIPE)/[A-Za-z0-9._<>*-]+")
    write_re = re.compile(pc["write_marker_regex"], re.I)
    exceptions = {(e["file"], e["token"]) for e in pc.get("exceptions", [])}
    failures = []
    for f in pc["files"]:
        text = read(f)
        if text is None:
            failures.append(f"{f}: file missing")
            continue
        lines = text.splitlines()
        tokens = {}
        for ln in lines:
            for tok in token_re.findall(ln):
                tok = tok.rstrip(".,;:`)*")
                tokens.setdefault(tok, []).append(ln)
        for tok, occ in sorted(tokens.items()):
            if (f, tok) in exceptions:
                continue
            if not any(write_re.search(ln) for ln in occ):
                failures.append(f"{f}: {tok} mentioned {len(occ)}x, no occurrence on a write-marked line")
    report(pc["id"], not failures, "; ".join(failures[:5]) + (" …" if len(failures) > 5 else ""))

print(f"qa-parity: {PASS} passed, {FAIL} failed")
sys.exit(0 if FAIL == 0 else 1)
