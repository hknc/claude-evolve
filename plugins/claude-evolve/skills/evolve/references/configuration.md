# Configuration Reference

Toolkit settings in `$HOME/.claude-evolve/toolkits/{name}/.claude-toolkit/toolkit.yaml`.

## Full Schema

```yaml
version: "1.0"
name: my-toolkit
remote: git@github.com:username/my-toolkit.git  # Required for /evolve release

learning:
  auto_consolidate: true  # Merge similar components when /learn creates new ones
```

## Settings

### remote

| Option | Required | Description |
|--------|----------|-------------|
| remote | Yes (for release) | Git URL for your personal toolkit repo. Only this remote is used by `/evolve release`. |

**Examples:**
- `git@github.com:username/my-toolkit.git` (SSH)
- `https://github.com/username/my-toolkit.git` (HTTPS)

### learning.auto_consolidate

When `true` (recommended):
- Merges similar components automatically
- Archives replaced components to `history/archive/`
- Keeps toolkit lean and focused

## Observation Capture

Observation capture is **always-on** at session end. The Stop hook automatically captures:
- Corrections you give Claude
- Surprising outcomes
- Explicit feedback

**To opt-out of a specific session:** Say "don't save" or "skip capture" during the session.

## Learnings Become Components

Learnings become toolkit components directly (agents/skills/rules). No separate storage.

| Learning Type | Becomes | Location (FLAT) |
|---------------|---------|-----------------|
| Problem-solving pattern | Skill | `toolkit/skills/` |
| Investigation method | Agent | `toolkit/agents/` |
| Pattern/approach | Rule | `toolkit/rules/` |
