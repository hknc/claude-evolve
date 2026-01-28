#!/bin/bash
# Outputs task-creation reminder as hook JSON
# Usage: bash plan-reminder.sh <hookEventName> <prefix>
# Example: bash plan-reminder.sh SessionStart "Context cleared."

EVENT_NAME="${1:-PostToolUse}"
PREFIX="${2:-Plan approved.}"
MSG="[claude-evolve] $PREFIX IMPORTANT: Before implementing, you MUST first create native tasks with TaskCreate for each phase. Call TaskCreate with subject prefix [claude-evolve] Build: before writing ANY code. Use /workflow to manage progress."

jq -n --arg event "$EVENT_NAME" --arg ctx "$MSG" \
  '{"ok":true,"hookSpecificOutput":{"hookEventName":$event,"additionalContext":$ctx}}'
