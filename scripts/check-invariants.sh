#!/usr/bin/env bash
set -euo pipefail
REPO=$(git rev-parse --show-toplevel)
ERRORS=()
fail() { ERRORS+=("$1"); }

# Contract: R-41 output protocol present in required agents
for agent in gatekeeper cv-writer letter-writer recruiter-reviewer humanizer; do
  grep -q "Output protocol (R-41)" "$REPO/agents/$agent.md" \
    || fail "R-41 marker missing from agents/$agent.md"
done

# Contract: Tier 1 / Tier 2 grading model exists in gatekeeper-checks skill (source of truth; replaced the retired Grade A-D table)
grep -q 'Tier 1' "$REPO/skills/gatekeeper-checks/SKILL.md" \
  || fail "Tier 1 grading section missing from skills/gatekeeper-checks/SKILL.md"
grep -q 'Tier 2' "$REPO/skills/gatekeeper-checks/SKILL.md" \
  || fail "Tier 2 grading section missing from skills/gatekeeper-checks/SKILL.md"

# Contract: gatekeeper agent has both PASS and FAIL cover letter output templates
grep -q 'PASS — cover letter' "$REPO/agents/gatekeeper.md" \
  || fail "PASS cover letter template missing from agents/gatekeeper.md"
grep -q 'FAIL — cover letter' "$REPO/agents/gatekeeper.md" \
  || fail "FAIL cover letter template missing from agents/gatekeeper.md"

# Contract: CAREER_DATA passed through in sub-pipeline skills (not entry skills like intake, which self-locate)
for skill in career-engine-new-application career-engine-edit; do
  grep -q 'CAREER_DATA=${CAREER_DATA}' "$REPO/skills/$skill/SKILL.md" \
    || fail "CAREER_DATA pass-through missing from skills/$skill/SKILL.md"
done

# Contract: gatekeeper option values present in agent
for opt in cv cover-letter coach-output; do
  grep -q "option=$opt" "$REPO/agents/gatekeeper.md" \
    || fail "option=$opt missing from agents/gatekeeper.md"
done

# Contract: key OUTPUT_PATH filenames present in new-application pipeline
# 2026-07-22: coach-letter-review.md removed from the pipeline (coach review replaced by Gate 5/9
# conformance per the user's instruction); coach-outline.md is the letter-plan file both paths produce.
for fname in 'gatekeeper-cv' 'gatekeeper-cl' 'recruiter-cv.md' 'coach-outline.md'; do
  grep -q "$fname" "$REPO/skills/career-engine-new-application/SKILL.md" \
    || fail "Pipeline file '$fname' missing from new-application SKILL.md"
done

# Relational layer: list parity, defined-term closure, spawn params, $PIPE closure
# (scripts/qa-parity.py + qa-parity.json). Fast (<1s), so it runs on every commit —
# this is what forces the consumer sweep when a fix touches one list but not its siblings.
if ! python3 "$REPO/scripts/qa-parity.py" "$REPO" >/dev/null 2>&1; then
  fail "qa-parity relational checks failed — diagnose with: python3 scripts/qa-parity.py ."
fi

if [ ${#ERRORS[@]} -gt 0 ]; then
  echo "❌ Invariant check failed — fix before committing:"
  printf '  - %s\n' "${ERRORS[@]}"
  echo ""
  echo "Run: bash scripts/check-invariants.sh to diagnose"
  exit 1
fi

echo "✓ Invariants OK"
