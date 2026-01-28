# Subcommand Reference

Detailed documentation for `/evolve` subcommands.

## `/evolve init`

Initialize a new toolkit or discover an existing one.

1. Check for existing toolkits in `$HOME/.claude-evolve/toolkits/`
2. Analyze current project (not home directory)
3. Create minimal toolkit structure dynamically
4. Offer to migrate $HOME/.claude/ content

## `/evolve learn`

Extract learnings from the current conversation and convert them to toolkit components.

**What it captures:**
- Debugging patterns and methodologies
- Solutions (problem -> cause -> fix)
- Improvement ideas (new agents, skills, rules)

**Learnings become Components (FLAT structure):**

| Learning Type | Becomes | Location |
|---------------|---------|----------|
| Problem-solving pattern | Skill | `toolkit/skills/` |
| Investigation method | Agent | `toolkit/agents/` |
| Code pattern/approach | Rule | `toolkit/rules/` |
| Improvement to existing | Consolidated | Merged into existing file |

**Note:** No separate `learnings/solutions/` storage. Learnings ARE the toolkit components.

## `/evolve audit`

Audit configuration and apply pending learnings.

**Modes:**
- `full` - Complete audit with report
- `quick` - Security + coverage check
- `optimize` - Apply all improvements
- `consolidate` - Merge similar components
- `migrate` - Copy $HOME/.claude/ to toolkit

## `/evolve consolidate`

Merge similar toolkit components and remove duplicates.

Routes to `claude-evolve:evolve-setup-auditor` with `action=consolidate`.

**What it does:**
- Scans agents/skills/rules for overlapping functionality
- Merges similar components (>70% name/description overlap)
- Archives replaced components to `history/archive/`
- Logs consolidation events

---

## `/evolve migrate`

Copy existing $HOME/.claude/ customizations to toolkit.

**Migrates:**
- agents/*.md
- skills/*/SKILL.md
- CLAUDE.md patterns -> rules/

**Important:** Original files are COPIED, not moved. $HOME/.claude/ remains unchanged.

## `/evolve prepare`

Analyze current task and create missing agents/skills in your toolkit.

**Use before complex tasks** to ensure your toolkit has the right tools.

**Flow:**
1. Analyzes task requirements (technologies, operations)
2. Checks toolkit for matching agents/skills
3. Identifies gaps that would benefit from new components
4. Offers to create missing agents/skills (only if reusable, not one-off)
5. New agents available after session restart (use /resume to reload)

**Smart filtering:** Only recommends when gap is significant and component would be reusable.

## `/evolve release`

Bump version and push to configured remote. Other machines auto-update via Claude Code plugin system.

**Requires:** `remote:` configured in toolkit.yaml

**Flow:**
1. Checks for configured remote in toolkit.yaml (fails if not set)
2. Shows changes since last release
3. Determines version bump (minor for new agents/skills, patch for rules/fixes)
4. Updates plugin.json version
5. Commits, tags, and pushes to configured remote only

## `/evolve switch {name}`

Switch to a different toolkit (e.g., work vs personal).

## `/evolve context`

Analyze project and suggest relevant agents.

## `/evolve status`

Show toolkit version and changes since last release.

## `/evolve signal [description]`

Flag that this session has valuable insights worth capturing with /learn.

**When to use:**
- Found root cause of a bug
- User corrected your approach
- Discovered a non-obvious pattern
- Session had reusable insights

**Usage:**
```
/evolve signal                    # Flag current insight
/evolve signal "found auth bug"   # Flag with description
```

**How it works:**
1. Writes signal to `~/.claude-evolve/signals/{session_id}.json`
2. Stop hook checks for signals when session ends
3. If signals exist, suggests running /learn
4. Running /learn clears signals for this session

**Session isolation:** Each terminal session has a unique session_id, so concurrent sessions don't interfere.
