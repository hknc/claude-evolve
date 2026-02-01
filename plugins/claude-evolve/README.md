# Claude Evolve Plugin

Adaptive toolkit that learns your patterns for Claude Code.

## Installation

```bash
/plugin marketplace add hknc/claude-evolve
/plugin install claude-evolve@claude-evolve
/evolve init
```

## How It Works

1. **Work normally** - Claude Evolve observes your sessions
2. **Signal insights** - Use `/evolve signal` when you discover something valuable
3. **Extract learnings** - Run `/learn` to capture patterns as toolkit components
4. **Get guidance** - Your toolkit provides personalized help in future sessions

## Components

| Type | Count | Examples |
|------|-------|----------|
| Commands | 6 | `/evolve`, `/learn`, `/reflect`, `/workflow` |
| Agents | 9 | toolkit-manager, learning-extractor, context-detector |
| Skills | 13 | build-project, workflow, compare-options, verify-completion |
| Rules | 5 | system-architecture, use-native-ui, auto-signal-insights |
| Hooks | 4 | SessionStart (2), Stop, PostToolUse |

## Commands

### Core

| Command | Purpose |
|---------|---------|
| `/evolve init` | Create or recover your toolkit |
| `/evolve status` | Show toolkit version and changes |
| `/evolve release` | Push toolkit to git remote |
| `/evolve help` | Show all commands |

### Learning

| Command | Purpose |
|---------|---------|
| `/learn` | Extract session insights → toolkit components |
| `/reflect` | Synthesize observations → understanding.md |
| `/evolve signal` | Flag current session has valuable insights |
| `/evolve understanding` | View your learned patterns |

### Workflow

| Command | Purpose |
|---------|---------|
| `/workflow` | Show current task and phase |
| `/workflow next` | Advance to next phase |
| `/workflow skip` | Skip current phase |
| `/workflow done` | Mark task complete |
| `/workflow switch` | Switch between active workflows |
| `/workflow expand` | Create sub-tasks from phase items |

## Learning Flow

```
Work → /evolve signal → /learn → Components created
         (flag insight)   (extract)   (agents/skills/rules)
```

**`/evolve signal`** - Call when you:
- Find root cause of a bug
- Get corrected by user
- Discover a non-obvious pattern
- Have reusable insights

**`/learn`** - Extracts insights into:
- **Agents** for investigation methods
- **Skills** for problem-solving patterns
- **Rules** for code patterns/approaches

## Toolkit Structure

```
~/.claude-evolve/toolkits/{name}/
├── .claude-plugin/plugin.json
├── agents/           # Your custom agents
├── skills/           # Your custom skills
├── rules/            # Your custom rules
└── understanding/
    ├── understanding.md    # Synthesized patterns
    └── observations/       # Raw session observations
```

## Cross-Machine Sync

```bash
# Set remote (one-time)
# Edit ~/.claude-evolve/toolkits/{name}/.claude-toolkit/toolkit.yaml
# Add: remote: "git@github.com:user/my-toolkit.git"

# Push changes
/evolve release

# On another machine
/evolve init  # Choose "Clone from git URL"
```

## License

MIT
