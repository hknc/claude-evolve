#!/bin/bash
# SessionStart hook for claude-evolve

set -e

# Ensure hook scripts are executable (safety net for environments that strip permissions)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
chmod +x "$SCRIPT_DIR"/session-start.sh "$SCRIPT_DIR"/stop-hook.sh "$SCRIPT_DIR"/plan-reminder.sh "$SCRIPT_DIR"/user-prompt-check.sh 2>/dev/null || true

# Read input from stdin for session_id export
input=$(cat)

# Export session_id for main Claude's bash commands (signal system)
session_id=$(echo "$input" | jq -r '.session_id // empty')
# Validate session_id format before exporting (security)
if [[ -n "$session_id" && "$session_id" =~ ^[a-zA-Z0-9_-]+$ && -n "$CLAUDE_ENV_FILE" ]]; then
  echo "export CLAUDE_SESSION_ID=$session_id" >> "$CLAUDE_ENV_FILE"
fi

EVOLVE_DIR="$HOME/.claude-evolve"
ACTIVE_FILE="$EVOLVE_DIR/active"

[[ ! -f "$ACTIVE_FILE" ]] && echo '{"ok":true}' && exit 0

TOOLKIT_NAME=$(cat "$ACTIVE_FILE" 2>/dev/null | tr -d '[:space:]')
[[ -z "$TOOLKIT_NAME" ]] && echo '{"ok":true}' && exit 0

# Validate toolkit name (only alphanumeric, underscore, hyphen)
if [[ ! "$TOOLKIT_NAME" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    echo '{"ok":true}' && exit 0
fi

TOOLKIT_DIR="$EVOLVE_DIR/toolkits/$TOOLKIT_NAME"
[[ ! -d "$TOOLKIT_DIR" ]] && echo '{"ok":true}' && exit 0

# Count toolkit components (using find for robustness)
AGENTS=$(find "$TOOLKIT_DIR/agents" -maxdepth 1 -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
SKILLS=$(find "$TOOLKIT_DIR/skills" -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')
RULES=$(find "$TOOLKIT_DIR/rules" -maxdepth 1 -name "*.md" 2>/dev/null | wc -l | tr -d ' ')

# Count observations
OBS_COUNT=0
OBS_DIR="$TOOLKIT_DIR/understanding/observations"
if [[ -d "$OBS_DIR" ]] && ls "$OBS_DIR"/*.yaml >/dev/null 2>&1; then
    OBS_COUNT=$(grep -ch "^id:" "$OBS_DIR"/*.yaml 2>/dev/null | awk '{sum+=$1} END {print sum+0}')
fi
OBS_COUNT=${OBS_COUNT:-0}

# Count pending signals (across all session files)
SIG_COUNT=0
SIG_DIR="$EVOLVE_DIR/signals"
if [[ -d "$SIG_DIR" ]] && ls "$SIG_DIR"/*.json >/dev/null 2>&1; then
    SIG_COUNT=$(cat "$SIG_DIR"/*.json 2>/dev/null | wc -l | tr -d ' ')
fi
SIG_COUNT=${SIG_COUNT:-0}

# Build stats
STATS="${AGENTS}a/${SKILLS}s/${RULES}r"

# Check last reflection time for smart suggestion
LAST_REFLECT_FILE="$TOOLKIT_DIR/understanding/.last-reflection"
DAYS_SINCE_REFLECT=999

if [[ -f "$LAST_REFLECT_FILE" ]]; then
    LAST_REFLECT=$(cat "$LAST_REFLECT_FILE" 2>/dev/null | tr -d '[:space:]')
    # Extract date portion (handles both ISO timestamp and date-only formats)
    LAST_REFLECT_DATE="${LAST_REFLECT:0:10}"

    # Validate date format (YYYY-MM-DD)
    if [[ "$LAST_REFLECT_DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        # Calculate days since last reflection (macOS + GNU compatible)
        LAST_EPOCH=$(date -j -f "%Y-%m-%d" "$LAST_REFLECT_DATE" +%s 2>/dev/null || date -d "$LAST_REFLECT_DATE" +%s 2>/dev/null || echo 0)
        NOW_EPOCH=$(date +%s)
        if [[ $LAST_EPOCH -gt 0 ]]; then
            DAYS_SINCE_REFLECT=$(( (NOW_EPOCH - LAST_EPOCH) / 86400 ))
            # Sanity check: if file claims future date or unreasonably old, treat as missing
            if [[ $DAYS_SINCE_REFLECT -lt 0 ]] || [[ $DAYS_SINCE_REFLECT -gt 365 ]]; then
                DAYS_SINCE_REFLECT=999
            fi
        fi
    fi
fi

# Build message with both signals and observations status
# Priority: pending signals → suggest /learn; pending observations → suggest /reflect
PENDING_MSG=""

if [[ $SIG_COUNT -gt 0 ]]; then
    PENDING_MSG="${SIG_COUNT} signals → /learn"
fi

if [[ $OBS_COUNT -gt 0 ]]; then
    OBS_TEXT="${OBS_COUNT} obs → /reflect"
    if [[ $OBS_COUNT -ge 15 ]] && [[ $DAYS_SINCE_REFLECT -ge 3 ]]; then
        OBS_TEXT="${OBS_COUNT} obs → /reflect recommended"
    fi
    if [[ -n "$PENDING_MSG" ]]; then
        PENDING_MSG="${PENDING_MSG} | ${OBS_TEXT}"
    else
        PENDING_MSG="${OBS_TEXT}"
    fi
fi

if [[ -z "$PENDING_MSG" ]]; then
    PENDING_MSG="0 pending"
fi

echo "{\"ok\":true,\"systemMessage\":\"[claude-evolve] Ready. $STATS | ${PENDING_MSG} | /evolve understanding | /evolve help\"}"
