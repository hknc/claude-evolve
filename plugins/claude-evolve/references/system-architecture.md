---
paths: ["**/*"]
---

# Claude-Evolve System (Reference)

Claude-evolve captures and applies learnings across sessions. This reference
helps you understand the system - use the knowledge naturally to enhance your work.

## Architecture

**Active toolkit:** `$HOME/.claude-evolve/active` (plain text file with toolkit name)

**Learnings location:** `$HOME/.claude-evolve/toolkits/{name}/understanding/`
- `understanding.md` - Personal patterns (communication style, workflow preferences)
- `projects/{key}.md` - Project patterns (architecture, commands, conventions)
- `observations/YYYY-MM.yaml` - Raw session observations (auto-captured)

**Size limits:**
- `understanding.md` - max ~2000 tokens (~1500 words)
- `projects/{key}.md` - max ~1500 tokens (~1100 words) each

## How It Works

1. **Loading:** SessionStart hook loads relevant patterns into context, shows pending signals/observations
2. **Signaling:** Claude flags insights via `/evolve signal` during conversation (see `auto-signal-insights` rule)
3. **Capturing:** Stop hook converts signals into observation YAML entries and suggests `/learn`
4. **Extracting:** `/learn` converts signals into agents/skills/rules, also writes enriched observations
5. **Reflecting:** `/reflect` synthesizes accumulated observations into understanding.md and projects/*.md

## Signal Criteria

See `auto-signal-insights` rule for full trigger list. Claude flags insights during conversation via `/evolve signal`, user runs `/learn` to extract them into components.

## Pattern Scope

| Scope | Examples | File |
|-------|----------|------|
| Personal | Response style, workflow preferences | understanding.md |
| Project | Build commands, architecture, conventions | projects/{key}.md |

Most learnings are project-specific. If a pattern appears across multiple projects,
ask the user whether it should be universal.

## Project Key

Derived from git remote (last path segment without .git) or directory basename.
Example: `github.com/user/my-api` -> project key is `my-api`

## First-Time Setup

If `$HOME/.claude-evolve/active` doesn't exist, run `/evolve init` to create a toolkit.
The toolkit initializer will:
1. Create the directory structure
2. Set up the active toolkit marker
3. Analyze the current project for initial agents

## Observations Schema

Observations are written by two sources:
1. **Stop hook** — auto-converts session signals into basic observation entries
2. **`/learn` command** — writes enriched observations with conversation context

Both write to `observations/YYYY-MM.yaml` in this format:

```yaml
---
id: obs-{timestamp}-{random4}      # Unique identifier
timestamp: {ISO 8601}              # When captured
session: {session_id}              # Session that produced this
task: "{description}"              # What was being done (from /learn, empty from hook)
project:
  id: "{git remote URL or empty}"  # Full git URL
  directory: "{basename}"          # Current directory name
observations:
  - "{insight or pattern}"         # General observations
corrections:
  - "{correction-type signal}"     # Corrections made during session
```

The `/reflect` command reads these entries and synthesizes patterns into `understanding.md` (personal) and `projects/{key}.md` (project-specific).
