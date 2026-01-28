---
name: setup-audit
description: Use when user says "audit my setup", "review configuration", "apply learnings", "optimize Claude Code setup", "check security settings", "check my config", "is my setup secure", "what agents do I have", "review my agents", "check my skills", "consolidate my toolkit", "migrate", "import from .claude", or "/evolve audit". Also use for maintenance or after major projects.
---

# Setup Audit

Alias for `/evolve audit`. Audit and optimize Claude Code configuration.

## Action

Invoke `claude-evolve:evolve-setup-auditor` agent via Task tool.

## Execution

1. **Check prerequisite:** Verify `$HOME/.claude-evolve/active` exists. If not, tell user to run `/evolve init` first and stop.
2. **Determine mode** from user request (see table below). Default is `full`.
3. **Spawn agent:** Invoke `claude-evolve:evolve-setup-auditor` via Task tool with the mode parameter.
4. **Report results** to user.

## Modes

| Mode | Trigger | What It Does |
|------|---------|-------------|
| `full` | "audit my setup" (default) | Complete audit: security, coverage, learnings, recommendations |
| `quick` | "quick check", "fast audit" | Security + coverage check only |
| `security` | "is my setup secure" | Deep security analysis of settings and permissions |
| `optimize` | "optimize", "apply improvements" | Apply all improvements directly to toolkit |
| `consolidate` | "consolidate", "merge duplicates" | Merge similar components, remove redundancy |
| `migrate` | "migrate", "import from .claude" | Copy $HOME/.claude/ content to toolkit |

## Error Handling

| Error | Action |
|-------|--------|
| No toolkit initialized | Tell user: "Run `/evolve init` first." |
| Agent finds no issues | Report: "Setup looks good. No issues found." |
| Agent can't read $HOME/.claude/ | Report what was accessible, note permission issues |

## Expected Output

The agent produces a structured audit report with:
- Configuration summary (component counts by source)
- Security status (critical checks)
- Coverage analysis (gaps in agents/skills/rules)
- Recommendations (only actionable items)
- Migration availability (if $HOME/.claude/ has content not in toolkit)

## Critical Rule

The agent reads from $HOME/.claude/ but **never writes to it**. All changes go to the toolkit at `$HOME/.claude-evolve/toolkits/{name}/`.

## Relationship to /evolve audit

This skill is the natural-language entry point for the same functionality that `/evolve audit` provides via command routing. Both invoke the same `evolve-setup-auditor` agent.
