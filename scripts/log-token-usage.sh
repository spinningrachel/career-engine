#!/bin/bash
# log-token-usage.sh
#
# Stop hook for cv-campaign plugin.
# Reads token usage from the Claude Code session payload (stdin),
# finds the most recent run-metrics file in the cv-campaign output folder,
# and writes the actual token counts into it.
#
# Configure in ~/.claude/settings.json:
#   "hooks": {
#     "Stop": [{
#       "hooks": [{
#         "type": "command",
#         "command": "bash ${CLAUDE_PLUGIN_ROOT}/scripts/log-token-usage.sh"
#       }]
#     }]
#   }

# Read the session payload from stdin
PAYLOAD=$(cat)

# Extract token counts from payload (Claude Code Stop hook provides these fields)
INPUT_TOKENS=$(echo "$PAYLOAD" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    print(d.get('session', {}).get('stats', {}).get('inputTokens', d.get('inputTokens', 'unknown')))
except:
    print('unknown')
" 2>/dev/null)

OUTPUT_TOKENS=$(echo "$PAYLOAD" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    print(d.get('session', {}).get('stats', {}).get('outputTokens', d.get('outputTokens', 'unknown')))
except:
    print('unknown')
" 2>/dev/null)

CACHE_TOKENS=$(echo "$PAYLOAD" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    stats = d.get('session', {}).get('stats', d)
    print(stats.get('cacheReadInputTokens', stats.get('cacheTokens', 0)))
except:
    print(0)
" 2>/dev/null)

TOTAL_COST=$(echo "$PAYLOAD" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    print(d.get('session', {}).get('stats', {}).get('totalCostUSD', d.get('costUSD', 'unknown')))
except:
    print('unknown')
" 2>/dev/null)

# Find the most recent run-metrics file in the configured output folder
# OUTPUT_FOLDER is set during onboarding; falls back to home directory search
SEARCH_BASE="${OUTPUT_FOLDER:-$HOME}"
METRICS_FILE=$(find "$SEARCH_BASE" -name "run-metrics-*.json" -newer /tmp/.cv-campaign-last-hook 2>/dev/null | sort -r | head -1)

# Update the last hook marker
touch /tmp/.cv-campaign-last-hook 2>/dev/null

if [ -z "$METRICS_FILE" ]; then
    # No metrics file found — write a standalone token log instead
    LOG_DIR="${SEARCH_BASE}/cv-campaign-token-log"
    mkdir -p "$LOG_DIR" 2>/dev/null
    echo "{\"date\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\", \"input_tokens\": $INPUT_TOKENS, \"output_tokens\": $OUTPUT_TOKENS, \"cache_read_tokens\": $CACHE_TOKENS, \"cost_usd\": \"$TOTAL_COST\", \"note\": \"no run-metrics file found\"}" \
        >> "$LOG_DIR/token-log.jsonl" 2>/dev/null
    exit 0
fi

# Update the metrics file with real token counts
python3 - << PYEOF
import json, sys

path = "$METRICS_FILE"
try:
    with open(path) as f:
        data = json.load(f)
except:
    data = {}

data["token_counts"] = {
    "input_tokens": "$INPUT_TOKENS",
    "output_tokens": "$OUTPUT_TOKENS",
    "cache_read_tokens": "$CACHE_TOKENS",
    "cost_usd": "$TOTAL_COST",
    "recorded_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}

with open(path, 'w') as f:
    json.dump(data, f, indent=2)

print(f"Token counts written to {path}")
PYEOF
