#!/bin/bash
# Stop hook - convert signals to observations and suggest /learn

set -e

# Ensure jq is available
command -v jq >/dev/null || { echo '{"ok":true}'; exit 0; }

input=$(cat)
session_id=$(echo "$input" | jq -r '.session_id // empty')

# session_id required for isolation
if [[ -z "$session_id" ]]; then
  echo '{"ok":true}'
  exit 0
fi

# Validate session_id format (prevent path traversal)
if [[ ! "$session_id" =~ ^[a-zA-Z0-9_-]+$ ]]; then
  echo '{"ok":true}'
  exit 0
fi

SIGNAL_FILE="$HOME/.claude-evolve/signals/${session_id}.json"

# No signals → nothing to do
if [[ ! -f "$SIGNAL_FILE" ]] || [[ ! -s "$SIGNAL_FILE" ]]; then
  echo '{"ok":true}'
  exit 0
fi

signal_count=$(wc -l < "$SIGNAL_FILE" | tr -d ' ')

# --- Write observations from signals ---
ACTIVE_FILE="$HOME/.claude-evolve/active"
if [[ -f "$ACTIVE_FILE" ]]; then
  TOOLKIT_NAME=$(cat "$ACTIVE_FILE" 2>/dev/null | tr -d '[:space:]')
  # Validate toolkit name
  if [[ -n "$TOOLKIT_NAME" && "$TOOLKIT_NAME" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    TOOLKIT_DIR="$HOME/.claude-evolve/toolkits/$TOOLKIT_NAME"
    OBS_DIR="$TOOLKIT_DIR/understanding/observations"

    if [[ -d "$TOOLKIT_DIR" ]]; then
      mkdir -p "$OBS_DIR"

      YEAR_MONTH=$(date +"%Y-%m")
      OBS_FILE="$OBS_DIR/${YEAR_MONTH}.yaml"
      TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
      RANDOM4=$(head -c 4 /dev/urandom | od -An -tx1 | tr -d ' ' | head -c 4)
      OBS_ID="obs-$(date +%s)-${RANDOM4}"

      # Extract project info from the first signal's cwd
      FIRST_CWD=$(head -1 "$SIGNAL_FILE" | jq -r '.cwd // empty')
      PROJECT_DIR=""
      PROJECT_REMOTE=""
      if [[ -n "$FIRST_CWD" && -d "$FIRST_CWD" ]]; then
        PROJECT_DIR=$(basename "$FIRST_CWD")
        PROJECT_REMOTE=$(git -C "$FIRST_CWD" remote get-url origin 2>/dev/null || echo "")
      fi

      # Build observations and corrections lists from signals
      OBS_ENTRIES=""
      CORR_ENTRIES=""
      while IFS= read -r line; do
        summary=$(echo "$line" | jq -r '.summary // empty')
        [[ -z "$summary" ]] && continue

        # Categorize: corrections vs general observations
        if [[ "$summary" == correction:* ]] || [[ "$summary" == diagnosed:* ]]; then
          CORR_ENTRIES="${CORR_ENTRIES}  - \"${summary//\"/\\\"}\"\n"
        else
          OBS_ENTRIES="${OBS_ENTRIES}  - \"${summary//\"/\\\"}\"\n"
        fi
      done < "$SIGNAL_FILE"

      # Write YAML entry (append with separator)
      {
        echo "---"
        echo "id: ${OBS_ID}"
        echo "timestamp: ${TIMESTAMP}"
        echo "session: ${session_id}"
        echo "project:"
        echo "  id: \"${PROJECT_REMOTE}\""
        echo "  directory: \"${PROJECT_DIR}\""
        echo "observations:"
        if [[ -n "$OBS_ENTRIES" ]]; then
          printf '%s' "$OBS_ENTRIES"
        else
          echo "  []"
        fi
        echo "corrections:"
        if [[ -n "$CORR_ENTRIES" ]]; then
          printf '%s' "$CORR_ENTRIES"
        else
          echo "  []"
        fi
      } >> "$OBS_FILE"

      # Clean up signal file after successful conversion to prevent duplicates
      rm -f "$SIGNAL_FILE"
    fi
  fi
fi

# Suggest /learn to capture insights as reusable components
echo "{\"ok\":true,\"systemMessage\":\"[claude-evolve] ${signal_count} insight(s) saved as observations. Run /learn to create reusable components.\"}"
