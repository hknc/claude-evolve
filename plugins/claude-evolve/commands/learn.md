---
name: learn
description: |
  Extract learnings from current conversation. Use after debugging sessions, problem-solving, or when valuable insights emerge.

  Triggers: "extract learnings", "save what we learned", "capture insights", "remember this", "document this pattern", "/learn"
---

# /learn Command

## Architecture Note

**Commands handle ALL user interaction. The learning-extractor agent runs in two phases.**

Phase 1: Agent analyzes conversation, returns candidate learnings as structured text.
Phase 2: Agent creates only user-approved components with user-specified types and scopes.

## Execution

### Step 1: Check Toolkit

Use Bash to check: `cat $HOME/.claude-evolve/active 2>/dev/null`

If empty: "Run `/evolve init` first." and STOP.

### Step 2: Check for Explicit Intent (Shortcut)

Before running discovery, check if the user's request contains explicit type and scope:
- **Explicit type** from: "rule", "skill", "agent"
- **Explicit scope** from: "universal", "project", "this project only"

Examples: "save this as a universal rule", "remember this as a project skill"

If both type and scope are explicit: Run Step 3 (discover) to identify what to capture, then skip Steps 4-6 (presentation and selection) and go directly to Step 7 with the user's explicit type and scope applied to all discovered candidates.

If only scope is explicit (e.g., "remember this universally"): Pre-set scope, continue to Step 3 for normal discovery and selection.

If no explicit intent detected: Continue to Step 3.

### Step 3: Discover Learnings (Phase 1 -- Agent)

Spawn `claude-evolve:evolve-learning-extractor` via Task tool with:
- action: "discover"
- topic: The user's trigger text if they provided a hint (e.g., "save what we learned about Redis")

The agent analyzes the full conversation context available through its Task invocation. It also checks for session signals at `$HOME/.claude-evolve/signals/${CLAUDE_SESSION_ID}.json`.

The agent returns at most **4 candidates**, ranked by learning value. Each candidate includes: name, summary, detail, suggested_type (skill|agent|rule), suggested_scope (universal|project), reasoning, and consolidation target if applicable.

If agent returns no candidates: Output "No significant learnings found in this session." and STOP.

### Step 4: Present Learnings Summary

Parse the agent's candidate list and display as a numbered summary:

```
## Learnings Found

1. **{summary}** ({suggested_type}, {suggested_scope})
   {detail — truncated to 80 chars}

2. **{summary}** ({suggested_type}, {suggested_scope})
   {detail — truncated to 80 chars}
```

### Step 5: User Selects Learnings

**If exactly 1 candidate** (shortcut):

Use AskUserQuestion:
- question: "[claude-evolve] Found: '{summary}'. Create as {suggested_type} ({suggested_scope})?"
- header: "Capture"
- options:
  - "Yes, as suggested" - "Create with the recommended type and scope"
  - "Change type/scope" - "Choose a different component type or scope"
  - "Skip" - "Don't capture this learning"

If "Yes, as suggested": Use defaults, go to Step 7.
If "Change type/scope": Ask type and scope directly (skip the "Accept all / Customize" question in Step 6 — go straight to the per-learning type and scope questions).
If "Skip": Output "No learnings captured." and STOP.

**If 2-4 candidates**:

Use AskUserQuestion with multiSelect:
- question: "[claude-evolve] Which learnings would you like to capture?"
- header: "Learnings"
- multiSelect: true
- options (first option is always "Capture all", followed by individual candidates):
  - "Capture all" - "Save all discovered learnings with suggested settings"
  - "{summary of candidate 1}" - "{suggested_type}, {suggested_scope} — {detail truncated to 60 chars}"
  - "{summary of candidate 2}" - "{suggested_type}, {suggested_scope} — {detail truncated to 60 chars}"
  - (etc., up to 4 candidates total — "Capture all" does not count toward the 4-option limit since it replaces individual selections)

If user selects "Capture all": Use all candidates with suggested values, go to Step 7.
If user selects specific learnings: Continue to Step 6 with selected candidates.
If user selects none: Output "No learnings captured." and STOP.

### Step 6: Confirm Types and Scopes

Use AskUserQuestion:
- question: "[claude-evolve] Accept the suggested types and scopes for all selected learnings?"
- header: "Settings"
- options:
  - "Accept all suggestions (Recommended)" - "Use the agent's recommended type and scope for each"
  - "Customize each" - "Choose type and scope per learning"

If "Accept all suggestions": Use the agent's suggested values, go to Step 7.

If "Customize each": For each selected learning, use AskUserQuestion:
- question: "[claude-evolve] '{summary}' — what type?"
- header: "Type"
- options: Always list the recommended option first with "(Recommended)" suffix, followed by the remaining options.
  - If suggested_type is "skill": ["Skill (Recommended)", "Agent", "Rule"]
  - If suggested_type is "agent": ["Agent (Recommended)", "Skill", "Rule"]
  - If suggested_type is "rule": ["Rule (Recommended)", "Skill", "Agent"]

Then use AskUserQuestion:
- question: "[claude-evolve] '{summary}' — what scope?"
- header: "Scope"
- options: Always list the recommended option first with "(Recommended)" suffix.
  - If suggested_scope is "universal": ["Universal (Recommended)", "Project-specific"]
  - If suggested_scope is "project": ["Project-specific (Recommended)", "Universal"]

### Step 7: Create Components (Phase 2 -- Agent)

Spawn `claude-evolve:evolve-learning-extractor` via Task tool with:
- action: "create"
- selections: Array of approved learnings with confirmed types and scopes:

```json
{
  "action": "create",
  "selections": [
    {
      "id": 1,
      "summary": "Brief description",
      "detail": "Full explanation",
      "type": "skill",
      "scope": "universal",
      "name": "suggested-name",
      "consolidates_with": null
    }
  ]
}
```

Include the `consolidates_with` field from Phase 1 if the agent identified a consolidation target (existing component name or `null`).

**Error handling:** If the agent returns an error or fails to create components, display the error and suggest: "Check toolkit directory permissions at `$HOME/.claude-evolve/toolkits/{name}/`."

### Step 8: Report Results

Display what the agent created:

```
## Learnings Captured

**Created:** `skills/{name}/SKILL.md` (universal)
{Description}

**Consolidated:** `rules/{name}.md` (project)
Merged into existing rule.

Available next session. Run `/evolve release` to sync.
```

## Learning Types Reference

| Learning Type | Becomes | Location |
|---------------|---------|----------|
| Problem-solving pattern | Skill | `toolkit/skills/{name}/SKILL.md` |
| Investigation method | Agent | `toolkit/agents/{name}.md` |
| Code pattern/approach | Rule | `toolkit/rules/{name}.md` |
| Improvement to existing | Consolidated | Merged into existing file |

**Key:** No separate storage. Learnings become agents/skills/rules directly.

## Examples

- `/learn` -> Two-phase: discover candidates, present for selection, create chosen
- `save what we learned about debugging Rust` -> Same flow, agent uses "debugging Rust" as topic hint
- `remember this as a universal rule` -> Shortcut: pre-set type=rule, scope=universal, skip selection
