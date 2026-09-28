#!/usr/bin/env bash
# test-ask-question-gate.sh — regression battery for scripts/gate-ask-user-question.sh.
# Run after any change to the gate: bash scripts/test-ask-question-gate.sh
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GATE="$HERE/gate-ask-user-question.sh"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
pass=0; fail=0

tx() {  # tx <file> <assistant tool_use JSON>...  — writes a transcript
  local f="$1"; shift; : > "$f"
  for tu in "$@"; do
    printf '{"type":"assistant","message":{"content":[%s]}}\n' "$tu" >> "$f"
  done
}
q() { printf '{"questions":[{"question":"%s","header":"Q","options":[{"label":"A","description":"a"},{"label":"B","description":"b"}]}]}' "$1"; }

check() {  # check <expect deny|allow> <name> <transcript> <tool_input>
  local out payload
  payload="$(printf '{"tool_name":"AskUserQuestion","transcript_path":"%s","tool_input":%s}' "$3" "$4")"
  out="$(printf '%s' "$payload" | bash "$GATE")"
  if [[ "$out" == *'"deny"'* ]]; then got=deny; else got=allow; fi
  if [ "$got" = "$1" ]; then pass=$((pass+1)); else fail=$((fail+1)); echo "FAIL [$1 expected, got $got]: $2"; fi
}

RUN="$TMP/run.jsonl"
tx "$RUN" '{"type":"tool_use","name":"Agent","input":{"subagent_type":"career-engine:cv-writer","prompt":"x"}}'
RUN2="$TMP/run2.jsonl"
tx "$RUN2" '{"type":"tool_use","name":"Write","input":{"file_path":"/o/Acme/_pipeline/cv-draft.md","content":"x"}}'
DEV="$TMP/dev.jsonl"
tx "$DEV" '{"type":"tool_use","name":"Read","input":{"file_path":"/repo/agents/cv-writer.md"}}' \
          '{"type":"tool_use","name":"Edit","input":{"file_path":"/repo/skills/career-engine-orchestrator/orchestrator-queue.md"}}'
DATA="$TMP/data.jsonl"
tx "$DATA" '{"type":"tool_use","name":"Read","input":{"file_path":"/skills/career-data/references/02-professional-background.md"}}' \
           '{"type":"tool_use","name":"WebFetch","input":{"url":"https://example.com/about"}}'
PASTED="$TMP/pasted.jsonl"
printf '{"type":"user","message":{"content":"spawned career-engine:cv-writer, wrote _pipeline/state.json"}}\n' > "$PASTED"

# must deny — real run + scope question
check deny  "run spawn + continue question"        "$RUN"  "$(q 'The queue is long. Should I continue with the remaining roles?')"
check deny  "run write + cost question"            "$RUN2" "$(q 'This run is getting expensive. Process a subset?')"
# must allow — the reported false positive and its neighbours
check allow "career-data review: years question"   "$DATA" "$(q 'Years of experience: the skill says 25+, your About page says 15+. Which should the skill use?')"
check allow "career-data review: title question"   "$DATA" "$(q 'Canonical Coro title? The skill currently holds four versions.')"
check allow "dev session scope-worded question"    "$DEV"  "$(q 'Should the fix scope include the Stop hook too?')"
check allow "pasted run output only"               "$PASTED" "$(q 'Should I continue?')"
check allow "real run, genuine blocker question"   "$RUN"  "$(q 'output_folder is missing from pipeline-preferences.json. Where should files go?')"
check allow "real run, blocker worded with proceed"  "$RUN"  "$(q 'output_folder is missing from pipeline-preferences.json. How should I proceed?')"
check allow "real run, error worded with continue"   "$RUN2" "$(q 'The Notion fetch failed with an error. Continue with the rest of the queue?')"
check allow "missing transcript"                   "$TMP/none.jsonl" "$(q 'Continue?')"
out="$(printf 'not json' | bash "$GATE")"; [ -z "$out" ] && pass=$((pass+1)) || { fail=$((fail+1)); echo "FAIL: malformed payload not allowed"; }

echo "ask-question gate: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
