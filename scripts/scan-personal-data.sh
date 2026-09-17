#!/usr/bin/env bash
# scan-personal-data.sh — detect personal data that must never live in the plugin repo.
#
# The plugin is a SHARED build. Every user installs the same artifact, and that artifact is
# committed to a public repo. Anything personal that reaches this repo reaches everyone —
# which has already happened: eight committed builds in June 2026 shipped a personal config
# dump. This scanner is one of the mechanical guards behind that rule; doctrine alone had
# repeatedly failed to hold it.
#
# All detection logic lives in scripts/personal_data_detect.py, shared with the PreToolUse
# block hook and the build script, so the three layers cannot drift apart. (They did: the
# first version implemented detection three times behind one over-broad allowlist, and a
# single {{PLACEHOLDER}} anywhere on a line defeated all three at once.)
#
# Usage:
#   scripts/scan-personal-data.sh                  # whole repo (tracked + untracked)
#   scripts/scan-personal-data.sh --staged         # only files staged for commit
#   scripts/scan-personal-data.sh FILE [FILE...]   # specific files
#
# Exit 0 = clean. Exit 1 = personal data found.

set -uo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

case "${1:-}" in
  --staged) MODE=staged; shift ;;
  "")       MODE=repo ;;
  *)        MODE=files ;;
esac

case "$MODE" in
  staged) FILES=$(git -C "$REPO" diff --cached --name-only --diff-filter=ACM) ;;
  repo)   FILES=$( { git -C "$REPO" ls-files; git -C "$REPO" ls-files --others --exclude-standard; } ) ;;
  files)  FILES=$(printf '%s\n' "$@") ;;
esac

# NOTE: the python body is loaded into a variable and passed with -c, NOT via a heredoc.
# `python3 - <<EOF` reads the SCRIPT from stdin, which would consume the piped file list
# and leave sys.stdin empty — the scanner would then silently report "clean" on every run.
read -r -d '' PYBODY <<'PY'
import os, sys
sys.path.insert(0, os.path.join(sys.argv[1], "scripts"))
import personal_data_detect as pdd

repo = sys.argv[1]
files = [l.strip() for l in sys.stdin if l.strip()]
hits = []

SKIP_EXT = (".plugin", ".dotx", ".dotm", ".docx", ".png", ".jpg", ".jpeg", ".pdf", ".zip", ".pyc")

for f in files:
    path = f if os.path.isabs(f) else os.path.join(repo, f)
    if not os.path.isfile(path):
        continue
    rel = os.path.relpath(path, repo)
    if os.path.basename(path).startswith("update-prompt-"):
        continue  # reported by the stray-file sweep below, with a better message
    if path.endswith(SKIP_EXT):
        continue
    try:
        text = open(path, "r", encoding="utf-8").read()
    except (UnicodeDecodeError, OSError):
        continue
    for lineno, name, match, why in pdd.scan_text(text, rel):
        hits.append((f"[{name}] {rel}:{lineno}: …{match}…", why))

# Stray personal output files, anywhere in the repo (not just its root).
for root, dirs, names in os.walk(repo):
    dirs[:] = [d for d in dirs if d != ".git"]
    for n in names:
        if pdd.is_stray_output_file(n):
            rel = os.path.relpath(os.path.join(root, n), repo)
            hits.append((f"[stray-output-file] {rel}",
                         "An update-prompt file carries personal career data. It belongs under "
                         "output_folder — see references/career-data-update-prompt-format.md."))

if hits:
    print(f"❌ Personal data detected in the plugin repo ({len(hits)} finding(s)):\n")
    for what, why in dict.fromkeys(hits):
        print(f"  {what}\n          → {why}")
    print("\nThe plugin is a single shared build — anything here ships to every user.")
    print("Personal data belongs in the career-data skill or under output_folder (R-37).")
    print("If a value is genuinely public, add a narrow span to ALLOWED_SPANS (or a path")
    print("exemption) in scripts/personal_data_detect.py, with a comment saying why.")
    sys.exit(1)

print("✓ No personal data detected")
PY

printf '%s\n' "$FILES" | python3 -c "$PYBODY" "$REPO"
