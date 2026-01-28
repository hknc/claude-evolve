---
name: learn
description: Use when user says "extract learnings", "save what we learned", "capture insights", "remember this", "remember this for next time", "document this pattern", "what did we learn", "save this approach", "save this pattern", or "/learn". Use after debugging sessions, problem-solving, or when valuable patterns are discovered.
---

# Learning Extraction

## Action

Execute the `/learn` command flow, which orchestrates the learning-extractor agent in two phases with user selection in between.

## Execution

1. **Check prerequisite:** Verify `$HOME/.claude-evolve/active` exists. If not, tell user to run `/evolve init` first and stop.
2. **Check explicit intent:** If the user's request contains explicit type and scope (e.g., "save this as a universal rule"), pre-set those values and skip selection steps.
3. **Phase 1 - Discover:** Spawn `claude-evolve:evolve-learning-extractor` with action="discover" and the user's trigger text as topic hint. Agent analyzes conversation context and session signals, returns at most 4 candidate learnings ranked by value.
4. **Present candidates:** Show discovered learnings to user as a numbered list with summary, suggested type, and scope.
5. **User selects:** Use AskUserQuestion to let user choose which learnings to capture. Single candidate gets a shortcut (yes/change/skip). Multiple candidates use multiSelect with a "Capture all" option.
6. **Confirm settings:** Use AskUserQuestion to ask "Accept suggested types/scopes or customize each?" If customizing, ask type then scope per learning with the recommended option listed first.
7. **Phase 2 - Create:** Spawn `claude-evolve:evolve-learning-extractor` with action="create" and the user's approved selections (id, summary, detail, type, scope, name, consolidates_with per learning).
8. **Report result:** Show user what was created or consolidated. If Phase 2 fails, display error and suggest checking toolkit permissions.

See `${CLAUDE_PLUGIN_ROOT}/commands/learn.md` for full implementation details.

## Learning Types (Learnings become Components)

| Found | Becomes | Location |
|-------|---------|----------|
| Problem-solving pattern | Skill | `$HOME/.claude-evolve/toolkits/{name}/skills/{skill-name}/SKILL.md` |
| Investigation method | Agent | `$HOME/.claude-evolve/toolkits/{name}/agents/{name}.md` |
| Code pattern/approach | Rule | `$HOME/.claude-evolve/toolkits/{name}/rules/{name}.md` |
| Improvement to existing | Consolidated | Merged into existing file |

**Key:** No separate storage. Learnings become agents/skills/rules directly.

## Error Handling

| Error | Action |
|-------|--------|
| No toolkit initialized | Tell user: "Run `/evolve init` first." |
| Phase 1 returns no candidates | Report: "No significant learnings found in this session." |
| User selects no candidates | Report: "No learnings captured." |
| Phase 2 fails to write | Report error, suggest checking toolkit directory permissions |
| Consolidation target found | Agent marks target in Phase 1; user approves in selection; agent consolidates in Phase 2 |

## Expected Output

```
## Learnings Captured

**Created:** `agents/{name}.md` (universal)
**Created:** `skills/{name}/SKILL.md` (project-specific)
**Consolidated:** `rules/{name}.md` (universal)

{Description of each component}

Available next session (agents/skills load at startup).
Run `/evolve release` to sync to other machines.
```

## When to Use

Best results when the session contains:
- A root cause diagnosis after debugging
- A correction from the user about approach or tooling
- A reusable pattern or technique discovered during work
- A non-obvious workaround for a tricky problem

Less useful for routine task completions with no novel insights.
