# claude-evolve

What you learn in one session dies when the session ends. Debug the same issue twice? Rediscover the same pattern? That knowledge vanishes.

**claude-evolve creates a personal toolkit plugin** that captures what you learn and turns it into reusable components — agents, skills, rules — that load automatically in future sessions.

Your toolkit starts empty and grows as you work. Works with any domain: coding, writing, research, design, ops.

## See It Work

```
1. You debug something
   > "Oh, the auth issue was caused by stale tokens"

2. Claude flags it (or you do manually)
   /evolve signal "stale token pattern causes auth failures"

3. Extract the learning
   /learn
   → Creates a rule: "Check token freshness before auth debugging"

4. Next session
   → Knowledge loads automatically
   → You skip the same debugging trap
```

## Quick Start

```bash
# Install
/plugin marketplace add hknc/claude-evolve
/plugin install claude-evolve@claude-evolve

# Better /learn components (recommended)
/plugin marketplace add anthropics/claude-plugins-official
/plugin install plugin-dev@claude-plugins-official

# Restart Claude Code, then initialize your toolkit
/evolve init   # Creates ~/.claude-evolve/toolkits/my-toolkit/
```

## What's Included

claude-evolve ships **meta-agents** — agents that create your personalized agents, skills, and rules based on your actual work and preferences. These components evolve over time as you use them.

| Included | Purpose |
|----------|---------|
| 9 agents | Learning extraction, reflection, decisions, risk, progress |
| 13 skills | Problem decomposition, root cause, comparison, research |
| Workflow guides | Depth-aware phases that scale with complexity |

See [docs/reference.md](docs/reference.md) for full component details.

## Your Toolkit

`/evolve init` creates a local plugin at `~/.claude-evolve/` that you own. As you work, `/learn` adds components to it:

| Component | Example | Created From |
|-----------|---------|--------------|
| **Rule** | "Always check X before Y" | Past corrections |
| **Skill** | "Debug auth issues" | Repeated patterns |
| **Agent** | "Investigate perf issues" | Investigation approaches |

Components accumulate in your toolkit over time. Each `/learn` adds to what you've built — shaped by your work, not generic templates.

## Core Features

### Learning

| Command | Purpose |
|---------|---------|
| `/evolve signal` | Flag insight for capture |
| `/learn` | Extract signals → agents/skills/rules |
| `/reflect` | Synthesize observations → understanding.md |

`/reflect` creates `understanding.md` — a condensed file of your patterns that loads at session start. Claude remembers how you work.

### Build Flow

Say **"let's build"** to start a guided flow:

1. **Context detection** — greenfield vs existing, detect stack
2. **Goal gathering** — full implementation, MVP, prototype, or exploration
3. **Spec creation** — writes implementation contract (`SPEC.md`)
4. **Task creation** — creates tasks with dependencies
5. **Build** — start coding, plan first, or research first

### Workflow Depths

Task complexity is assessed automatically:

| Depth | When | Phases |
|-------|------|--------|
| `execute` | Simple task | No phases — just do it |
| `check` | Low complexity | verify |
| `plan` | Medium complexity | action → outcome |
| `design` | High complexity | requirements → design → implement → testing |
| `explore` | Unclear + high stakes | research → prototype → evaluate → decide |

| Command | Purpose |
|---------|---------|
| `/workflow` | Show current phase |
| `/workflow next` | Advance phase |
| `/workflow done` | Complete workflow |

### Toolkit Management

Your toolkit is a local plugin that persists across sessions:

| Command | Purpose |
|---------|---------|
| `/evolve init` | Create your toolkit plugin |
| `/evolve status` | Show version and changes |
| `/evolve release` | Push to remote |
| `/evolve audit` | Audit and optimize config |
| `/evolve prepare` | Check toolkit gaps before complex tasks |
| `/evolve context` | Analyze current project, suggest relevant agents |

## Cross-Machine Sync

```
Machine A                              Machine B
─────────                              ─────────
Work → /learn → toolkit grows
         │
         ▼
/evolve release ────► Git ────► Claude Code auto-updates
                                         │
                                         ▼
                               Your toolkit available here too
```

## License

MIT
