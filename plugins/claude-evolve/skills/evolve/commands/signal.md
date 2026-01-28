---
description: Flag valuable insight for /learn capture. Use when you want to "remember this", "save this insight", "mark for learning", "flag this pattern", or "note this for later".
allowed-tools: [Bash]
args:
  - name: description
    description: Brief description of the insight
    required: false
---

# /evolve signal

Flag that this session has valuable insights worth capturing with /learn.

## When to use

- Found root cause of a bug
- User corrected your approach
- Discovered a non-obvious pattern
- Session had reusable insights

## Usage

```
/evolve signal                    # Flag current insight
/evolve signal "found auth bug"   # Flag with description
```

## Implementation

Run this bash command:

```bash
# Requires $CLAUDE_SESSION_ID (exported by SessionStart hook)
if [[ -z "$CLAUDE_SESSION_ID" ]]; then
  echo "[claude-evolve] Error: Session ID not available. Signal not saved."
  exit 1
fi

SIGNAL_DIR="$HOME/.claude-evolve/signals"
mkdir -p "$SIGNAL_DIR"

DESCRIPTION="${1:-insight flagged}"

# Escape quotes for valid JSON
ESCAPED_DESC=$(echo "$DESCRIPTION" | sed 's/"/\\"/g')

# Append as JSONL (one JSON object per line)
echo "{\"summary\":\"$ESCAPED_DESC\",\"ts\":\"$(date -Iseconds)\",\"cwd\":\"$(pwd)\"}" >> "$SIGNAL_DIR/${CLAUDE_SESSION_ID}.json"

echo "[claude-evolve] Insight flagged. Run /learn to capture."
```
