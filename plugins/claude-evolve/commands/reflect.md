---
name: reflect
description: Trigger deep reflection on recent observations to update understanding
---

# /reflect Command

## Architecture Note

**The reflection agent CANNOT use AskUserQuestion.** It auto-processes observations with sensible defaults.

## Execution

Spawn `claude-evolve:evolve-reflection-agent` via Task tool.

The agent will:
1. Read all observations in the toolkit
2. Group by project
3. Update projects/{key}.md files with project-specific patterns
4. Auto-promote patterns seen in 3+ projects to universal (understanding.md)
5. Mark stale patterns (90+ days without reinforcement) for review
6. Report exactly what changed

Pass this context to the agent: "Run full reflection. Analyze all recent observations, update project files, and report changes."

## Behavior Notes

- Patterns in 3+ projects are auto-promoted to universal (agent cannot ask)
- Stale patterns are moved to a "Stale Patterns" section, not deleted
- User can manually review and delete stale patterns if desired
