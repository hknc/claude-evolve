---
name: setup-audit
description: |
  Alias for `/evolve audit`. Audit and optimize Claude Code configuration.

  Triggers: "audit my setup", "review configuration", "check my config", "is my setup secure", "optimize setup", "/evolve audit"
---

# /setup-audit Command

This is an alias for `/evolve audit`. Prefer `/evolve audit` for consistency.

## Action

Invoke the `claude-evolve:evolve-setup-auditor` agent via Task tool.

## Execution

1. Parse mode from arguments (default: `full`)
2. Spawn `claude-evolve:evolve-setup-auditor` agent with mode parameter
3. Return audit results to user

## Modes

| Mode | Action |
|------|--------|
| `full` | Run complete audit (security + coverage + recommendations) |
| `quick` | Fast security and coverage check |
| `security` | Deep security analysis |
| `optimize` | Apply pending improvements to toolkit |
| `consolidate` | Merge similar components |
| `migrate` | Copy $HOME/.claude/ content to toolkit |

## Prerequisite

Check that toolkit is initialized (`$HOME/.claude-evolve/active` exists). If not, tell user to run `/evolve init` first.
