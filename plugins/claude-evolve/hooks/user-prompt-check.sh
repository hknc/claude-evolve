#!/bin/bash
# Fast gate: catch "evolve" mentions and inject skill routing directive
# Uses additionalContext for proper context injection into Claude's conversation

INPUT=$(cat)
PROMPT=$(printf '%s' "$INPUT" | jq -r '.prompt // empty' 2>/dev/null)
[ -z "$PROMPT" ] && exit 0
echo "$PROMPT" | grep -qi "evolve" || exit 0

jq -n '{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "[claude-evolve] The user mentioned evolve. You MUST route their request to the correct claude-evolve skill using the Skill tool. Do NOT handle directly.\n\nAvailable skills and their purpose:\n- evolve — toolkit management (init, release, migrate, switch, status, consolidate)\n- learn — extract learnings from conversation\n- reflect — synthesize observations into understanding\n- build-project — start building any project/feature/substantial task\n- workflow — track progress through multi-phase work\n- setup-audit — audit and optimize Claude Code configuration\n- prepare-task — analyze task and check toolkit gaps\n- compare-options — structured comparison of alternatives\n- root-cause-analysis — find underlying causes of problems\n- decompose-problem — break complex problems into steps\n- explain-step-by-step — progressive explanation of complex topics\n- summarize-efficiently — compress content preserving key info\n- verify-completion — final check before shipping\n- research-synthesize — gather and combine information from sources\n\nMatch the user intent to the BEST skill above. Use Skill tool immediately."
  }
}'
