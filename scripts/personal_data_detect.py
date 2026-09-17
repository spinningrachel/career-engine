"""Shared personal-data detection for the plugin repo. One implementation, three callers.

Callers: scripts/scan-personal-data.sh (repo + staged), scripts/block-personal-data-writes.sh
(the PreToolUse block hook), scripts/build-plugin.sh (pre-build and artifact scans).

WHY THIS FILE EXISTS. The first version of this guard implemented the same detection three
times, and all three shared one flawed rule: an allowlist matched against the WHOLE LINE.
Any line containing an allowed token — `{{PLACEHOLDER}}`, `example.com`, even the literal
string `build-plugin.sh` — was exempt from every detector. So this line passed all three
layers clean:

    "output_folder": "/Users/someone/Docs/out", "cv_template": "{{CV_TEMPLATE}}"

That is not a contrived evasion. It is the single most likely shape for a leak here — a
config example — and it is the shape of the file that actually shipped in eight builds in
June 2026. Three layers, one blind spot, zero coverage.

THE FIX, and the rule to preserve if you edit this file: an allowed token neutralises only
the SPAN IT COVERS, never the line. Allowed spans are cut out of the line first; detectors
then run on whatever remains. A real value sitting next to a placeholder is still a real
value, and is still caught.

File-level exemptions are matched against the PATH only, never the content — otherwise any
file that merely mentions a guard script's name exempts itself.
"""

import re

# ── File-level exemptions: matched against the repo-relative PATH, never content ──────
# These paths are not part of the shipped build, or are the guard scripts themselves
# (which necessarily contain the detector patterns and would otherwise self-detect).
PATH_EXEMPT = re.compile(
    r"^(\.git|\.claude|docs)/"
    r"|^scripts/(scan-personal-data\.sh|block-personal-data-writes\.sh|build-plugin\.sh|personal_data_detect\.py)$"
)

# Per-file, per-detector exemptions: {path regex: {detector names}}.
# Narrow by construction — a file exempt from one detector is still checked by the others.
PATH_DETECTOR_EXEMPT = [
    # The plugin author's published contact address, intentionally public.
    (re.compile(r"^\.claude-plugin/(plugin|marketplace)\.json$"), {"real-email"}),
]

# ── Allowed spans: cut from the line before detection ────────────────────────────────
# Each must describe a genuinely public or placeholder value. Adding one here narrows
# detection for that exact text only — it can never exempt a whole line.
ALLOWED_SPANS = re.compile(
    r"\{\{[A-Za-z0-9_]+\}\}"                              # {{PLACEHOLDER}} template slots
    r"|\$\{[A-Za-z_][A-Za-z0-9_]*\}"                      # ${CAREER_DATA}, ${CLAUDE_PLUGIN_ROOT}
    r"|https?://abounding-trouser-bce\.notion\.site/\S*"  # the PUBLIC Notion template link
    # Fictional-persona fixtures. The shipped .dotx/.dotm templates and the brief-CV test
    # all use invented people (Costanza / Simpson); their addresses are placeholders, not
    # anyone's contact details. Keep this list to invented domains only — never add a real
    # provider (gmail.com, outlook.com …), which would blind the detector to actual leaks.
    r"|[A-Za-z0-9._%+-]+@(example\.com|vandelay\.com|costanza\.me|springfieldmail\.com|anthropic\.com)"
    # Documented placeholder home paths. The trailing boundary is load-bearing: without it
    # the alternatives swallow any real username that merely STARTS with them, so
    # /Users/yousef/ and /Users/nameeta/ read as placeholders and pass clean.
    r"|/Users/(<[^>]*>|\.\.\.|your[A-Za-z-]*|you|username|name)(?![A-Za-z0-9._-])"
    r"|/home/(<[^>]*>|\.\.\.|your[A-Za-z-]*|you|username|name)(?![A-Za-z0-9._-])"
    # Temp and cache paths, consumed whole. Session scratch directories are named with
    # dashed UUIDs, so once `notion-id` learned the dashed form it started firing on
    # ordinary working paths — the "cries wolf, gets switched off" failure. A temp path is
    # ephemeral machine state, not personal data; swallowing the span keeps the UUID
    # detector for the places an ID actually leaks (config values, Notion URLs).
    r"|(/private)?/tmp/\S*|/var/folders/\S*|/dev/shm/\S*"
    # The same fictional personas' LinkedIn handles, inside the shipped .dotx fixtures.
    # Listed individually on purpose: a bare `linkedin.com/in/*` exemption would blind the
    # detector to every real profile URL.
    r"|linkedin\.com/in/(homerjsimpson|georgecostanza)"
)

# ── Detectors ─────────────────────────────────────────────────────────────────────────
# Deliberately user-agnostic: each matches the SHAPE of personal data, never one person's
# values, so the guard protects any contributor's clone rather than one machine's layout.
DETECTORS = [
    ("absolute-home-path", re.compile(r"(/Users/|/home/)[A-Za-z0-9._-]+/"),
     "A real filesystem path leaks a username and local layout. "
     "Use ${CAREER_DATA} / ${CLAUDE_PLUGIN_ROOT} / output_folder."),
    ("real-email", re.compile(r"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}"),
     "A real email address. Use a {{PLACEHOLDER}} or an example.com address."),
    # Both forms, both cases. The dashed form is the canonical one in a Notion URL — the
    # adapter's own docs tell you to strip the dashes — so a `database_id` copied straight
    # out of the browser is dashed, and that is the likeliest leak shape of all. The
    # uppercase alternative was lost when three scanners were merged into one; the earlier
    # tracker-id detector had [0-9a-fA-F].
    ("notion-id", re.compile(
        r"\b[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\b"
        r"|\b[0-9a-fA-F]{32}\b"),
     "A 32-hex tracker/database ID (dashed or bare). It belongs in career-data config, "
     "never the shared build."),
    ("linkedin-profile", re.compile(r"linkedin\.com/in/[A-Za-z0-9-]+"),
     "A real LinkedIn profile URL identifies a person."),
    ("icloud-path", re.compile(r"com~apple~CloudDocs"),
     "A personal iCloud Drive path."),
    ("share-link", re.compile(r"anchorpoint\.app/link\?"),
     "A share link that may itself grant access to its target."),
]

# Filenames that are personal output by definition, wherever they appear in the repo.
STRAY_FILE = re.compile(r"^update-prompt-.*\.md$")


def path_is_exempt(relpath):
    return bool(PATH_EXEMPT.search(relpath.replace("\\", "/")))


def _detectors_for(relpath):
    rel = relpath.replace("\\", "/")
    skip = set()
    for rx, names in PATH_DETECTOR_EXEMPT:
        if rx.search(rel):
            skip |= names
    return [d for d in DETECTORS if d[0] not in skip]


def scan_line(line, relpath=""):
    """Return (detector_name, matched_text, why) for the first hit, or None.

    Allowed spans are removed first, so a real value sharing a line with a placeholder
    is still detected — the failure mode this whole module exists to prevent.
    """
    residue = ALLOWED_SPANS.sub(" ", line)
    for name, rx, why in _detectors_for(relpath):
        m = rx.search(residue)
        if m:
            return name, m.group(0), why
    return None


def scan_text(text, relpath="", max_hits=5):
    """Scan a whole file/blob. Returns a list of (lineno, detector, match, why)."""
    hits = []
    if path_is_exempt(relpath):
        return hits
    for i, line in enumerate(text.splitlines(), 1):
        r = scan_line(line, relpath)
        if r:
            hits.append((i, r[0], r[1], r[2]))
            if len(hits) >= max_hits:
                break
    return hits


def is_stray_output_file(basename):
    return bool(STRAY_FILE.match(basename))
