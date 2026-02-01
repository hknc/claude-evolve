---
name: evolve
description: Use when user says "/evolve", "manage my toolkit", "initialize toolkit", "release my changes", "switch toolkits", "toolkit status", "setup my toolkit", "sync my setup", or asks about toolkit management and cross-machine synchronization.
---

# Claude Evolve Toolkit Management

## Action

Parse subcommand and invoke appropriate agent via Task tool.

## Routing

| Command | Handler | Notes |
|---------|---------|-------|
| `/evolve` | `claude-evolve:evolve-toolkit-manager` action=status | Show toolkit status |
| `/evolve init` | **Command wizard first** | Command handles AskUserQuestion, then spawns agent |
| `/evolve learn` | `claude-evolve:evolve-learning-extractor` | Auto-detects scope |
| `/evolve audit` | `claude-evolve:evolve-setup-auditor` | Returns suggestions |
| `/evolve migrate` | `claude-evolve:evolve-toolkit-manager` action=migrate | Copy $HOME/.claude/ content |
| `/evolve prepare` | (use prepare-task skill) | - |
| `/evolve release` | **Command confirms first** | Command uses AskUserQuestion, then spawns agent |
| `/evolve switch {name}` | `claude-evolve:evolve-toolkit-manager` action=switch | Switch toolkits |
| `/evolve context` | `claude-evolve:evolve-context-detector` | Analyze project |
| `/evolve status` | `claude-evolve:evolve-toolkit-manager` action=status | Show status |
| `/evolve consolidate` | `claude-evolve:evolve-setup-auditor` action=consolidate | Merge similar components |
| `/evolve signal [desc]` | **Bash command** | Flag insight for /learn capture |

## Architecture Note

**Commands handle ALL user interaction. Agents CANNOT use AskUserQuestion.**

For `/evolve init` and `/evolve release`, the command collects user choices via AskUserQuestion BEFORE spawning the agent. See `commands/evolve.md` for the full wizard flow.

## Critical Rules

- Never write to $HOME/.claude/
- All writes go to `$HOME/.claude-evolve/toolkits/{name}/` (FLAT structure)

## Structure (FLAT - Toolkit IS the Plugin)

```
$HOME/.claude-evolve/
├── .claude-plugin/
│   └── marketplace.json              <- For Claude Code plugin discovery
├── active                            <- Current toolkit name
└── toolkits/
    └── {name}/                       <- THE PLUGIN DIRECTLY
        ├── .claude-plugin/plugin.json
        ├── .claude-toolkit/toolkit.yaml
        ├── agents/                   <- Learned agents
        ├── skills/                   <- Learned skills
        ├── rules/                    <- Learned patterns
        ├── understanding/
        │   ├── understanding.md      <- Universal user patterns (<2000 tokens)
        │   ├── observations/         <- Raw session observations with project tags
        │   │   └── YYYY-MM.yaml
        │   └── projects/             <- Project-specific patterns (SHAREABLE)
        │       ├── my-api.md         <- Can be shared with team
        │       └── web-dashboard.md
        └── history/
            ├── events.json           <- Event tracking (stats computed on-demand)
            └── archive/              <- Monthly archives
```

**Registration:** `{name}-toolkit@claude-evolve-local`

See `${CLAUDE_PLUGIN_ROOT}/skills/evolve/references/subcommands.md` and `${CLAUDE_PLUGIN_ROOT}/skills/evolve/references/configuration.md` for details.
