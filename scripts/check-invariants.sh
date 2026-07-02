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

# Contract: grade table rows exist in gatekeeper-checks skill (source of truth)
grep -q '\*\*A\*\*' "$REPO/skills/gatekeeper-checks/SKILL.md" \
  || fail "Grade table row A missing from skills/gatekeeper-checks/SKILL.md"
grep -q '\*\*B\*\*' "$REPO/skills/gatekeeper-checks/SKILL.md" \
  || fail "Grade table row B missing from skills/gatekeeper-checks/SKILL.md"

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
for fname in 'gatekeeper-cv' 'gatekeeper-cl' 'recruiter-cv.md' 'coach-letter-review.md'; do
  grep -q "$fname" "$REPO/skills/career-engine-new-application/SKILL.md" \
    || fail "Pipeline file '$fname' missing from new-application SKILL.md"
done

if [ ${#ERRORS[@]} -gt 0 ]; then
  echo "❌ Invariant check failed — fix before committing:"
  printf '  - %s\n' "${ERRORS[@]}"
  echo ""
  echo "Run: bash scripts/check-invariants.sh to diagnose"
  exit 1
fi

echo "✓ Invariants OK"
