# Toolkit Configuration Schema

The `.claude-toolkit/toolkit.yaml` file configures your personal toolkit.

## Full Schema

```yaml
version: "1.0"
name: my-toolkit
remote: git@github.com:username/my-toolkit.git  # Required for /evolve release

learning:
  auto_consolidate: true  # Merge similar components when /learn creates new ones
```

## Minimal Configuration

For getting started:

```yaml
version: "1.0"
name: my-toolkit
# remote: git@github.com:you/your-toolkit.git  # Uncomment to enable /evolve release
```

## Configuration Options

### remote

| Option | Required | Description |
|--------|----------|-------------|
| remote | Yes (for release) | Git URL for your personal toolkit repo. Only this remote is used by `/evolve release`. |

**Examples:**
- `git@github.com:username/my-toolkit.git` (SSH)
- `https://github.com/username/my-toolkit.git` (HTTPS)

Without `remote` configured, `/evolve release` will fail with a helpful message.

### learning.auto_consolidate

When `true` (default):
- Merges similar components automatically (>70% name/domain match)
- Archives replaced components to `history/archive/` (full content preserved)
- Keeps toolkit lean and focused

**Triggers:**
- Automatically after `/learn` creates new components
- Manually via `/evolve consolidate`

**Recovery:** Archived files preserve original content. Copy back to original path to restore.

### Learnings Become Components

When `/learn` extracts insights, they become toolkit components directly:

| Learning Type | Becomes | Location |
|---------------|---------|----------|
| Problem-solving patterns | Skills | `skills/` |
| Investigation methods | Agents | `agents/` |
| Code patterns/approaches | Rules | `rules/` |

**No separate learnings storage.** Learnings ARE the toolkit components.

## Directory Structure

```
~/.claude-evolve/
├── .claude-plugin/
│   └── marketplace.json          # For Claude Code plugin discovery
├── active                        # Current toolkit name (plain text)
├── signals/                      # Session signals (temporary)
│   └── {session_id}.json         # JSONL signals per session
└── toolkits/
    └── {name}/                   # YOUR PLUGIN (flat structure)
        ├── .claude-plugin/
        │   └── plugin.json       # Plugin manifest
        ├── .claude-toolkit/
        │   └── toolkit.yaml      # This configuration file
        ├── .gitignore
        ├── agents/               # Your custom agents
        ├── skills/               # Your custom skills
        ├── rules/                # Your context rules
        ├── understanding/
        │   ├── understanding.md  # Universal patterns (<2000 tokens)
        │   ├── .last-reflection  # Timestamp of last /reflect
        │   ├── observations/     # Session observations
        │   │   ├── YYYY-MM.yaml  # Monthly observation files
        │   │   └── archive/      # Processed observations
        │   │       └── YYYY-MM/  # Archived after /reflect
        │   └── projects/         # Project-specific understanding
        │       └── {project}.md  # Per-project patterns (<1500 tokens)
        └── history/
            ├── events.json       # Learning events log
            └── archive/          # Archived components & old events
```

## Signal & Observation Flow

1. **During session:** `/evolve signal` writes to `~/.claude-evolve/signals/{session_id}.json`
2. **At session end:** Stop hook converts signals to observations in `observations/YYYY-MM.yaml`
3. **On /reflect:** Observations are synthesized into `understanding.md` and `projects/*.md`, then archived

### Observation Format

Written by stop-hook (minimal) and learning-extractor (full):

```yaml
---
id: obs-{timestamp}-{random4}
timestamp: {ISO8601}
session: {session_id}
project:
  id: "{git remote URL or empty}"
  directory: "{basename of current directory}"
observations:
  - "{insight summaries}"
corrections:
  - "{correction-type signals}"
```

## Toolkit Discovery

Toolkits are stored in `~/.claude-evolve/toolkits/`:

1. **Active marker**: `~/.claude-evolve/active` contains the active toolkit name
2. **List toolkits**: `ls ~/.claude-evolve/toolkits/`

To switch active toolkit:
```bash
/evolve switch {name}
```
