---
name: prepare-task
description: |
  Use when user says "/evolve prepare", "prepare toolkit", "check toolkit gaps",
  "do I have the right agents", "what tools do I need", "analyze my toolkit",
  "what workflow should I follow", or before complex tasks that might need
  specialized agents, skills, or workflow guidance.
  To manage an ACTIVE workflow (advance, skip, check status), use the workflow skill instead.
---

# Prepare Task Skill

Analyze the current task and proactively create missing agents/skills in the user's toolkit.

## When to Use

- Before complex tasks that might benefit from specialized agents
- When user wants to optimize their toolkit for a specific domain
- After creating a plan, before execution
- When starting work that would benefit from workflow guidance

## Workflow

### 1. Gather Task Context

Read the current conversation to understand:
- What task is the user trying to accomplish?
- What technologies/domains are involved?
- What operations are needed (debugging, refactoring, testing, etc.)?

If a plan exists in the conversation, analyze its steps.

### 2. Assess Task Depth

Evaluate complexity signals to determine how much preparation is warranted:

| Signal | Low | Medium | High |
|--------|-----|--------|------|
| **Scope** | Single operation | Multi-step | Multi-system |
| **Stakes** | Reversible | Has rollback | Irreversible |
| **Clarity** | Explicit requirements | Some gaps | Undefined |
| **Familiarity** | Known | Partially known | New territory |

Map to depth:
- `execute` (all low) -> Skip toolkit recommendations entirely
- `check` (mixed low) -> Skip toolkit recommendations
- `plan` (mixed medium) -> Recommend only high-impact gaps
- `design` (multiple high) -> Full gap analysis + workflow suggestion
- `explore` (high stakes + unclear) -> Full analysis + research suggestions

**For `execute`/`check` tasks:** Output only:
```
[claude-evolve] Task is straightforward - no toolkit gaps to address.
```

See `${CLAUDE_PLUGIN_ROOT}/skills/prepare-task/references/depth-patterns.md` for detailed signal assessment heuristics, override rules, and AskUserQuestion templates.

### 3. Discover Toolkit Capabilities

Find the active toolkit:
```bash
TOOLKIT_NAME=$(cat $HOME/.claude-evolve/active 2>/dev/null)
TOOLKIT_PATH=$HOME/.claude-evolve/toolkits/$TOOLKIT_NAME
```

List existing agents (FLAT structure):
```bash
ls $TOOLKIT_PATH/agents/*.md 2>/dev/null
```

List existing skills (FLAT structure):
```bash
ls $TOOLKIT_PATH/skills/*/SKILL.md 2>/dev/null
```

### 4. Gap Analysis

**Skip this section for `execute`/`check` depth tasks.**

For each task requirement, evaluate:

| Requirement | Has Coverage? | Gap Severity |
|-------------|---------------|--------------|
| {domain} expertise | Yes/Partial/No | Low/Medium/High |
| {operation} workflow | Yes/Partial/No | Low/Medium/High |

**Recommendation thresholds by depth:**
- `plan`: Only recommend if gap severity is High AND component is clearly reusable
- `design`/`explore`: Recommend if gap severity is Medium or High

**Only recommend if:**
- Gap is significant (not trivial)
- Task is complex enough to benefit
- Component would be reusable (not one-off)

### 5. Artifact Pattern Detection

Check understanding.md and project observations for artifact patterns the user has established:

```bash
TOOLKIT_NAME=$(cat $HOME/.claude-evolve/active 2>/dev/null)
TOOLKIT_PATH=$HOME/.claude-evolve/toolkits/$TOOLKIT_NAME
```

Then use the Read tool on `$TOOLKIT_PATH/understanding/understanding.md` and search for the "Artifact Patterns" section.

Look for learned patterns like:
- **Pre-work artifacts**: Does user typically create specs, designs, or plans before coding?
- **During-work artifacts**: Does user write tests alongside code (TDD)? Create PRs early?
- **Post-work artifacts**: Does user document after? Create changelogs?

**Suggest learned artifacts at appropriate phases:**
- If user has TDD pattern and task involves new code -> "You typically write tests first - want to start there?"
- If user has spec-writing pattern and task is `design` depth -> "You usually create a spec for tasks like this - want to draft one?"
- If user has documentation pattern and task is completing -> "You typically document after - want to update docs?"

**Do NOT suggest artifacts if:**
- No pattern learned (don't prescribe)
- Pattern confidence is low (fewer than 3 observations)
- User has explicitly skipped this artifact before for similar tasks
- Understanding.md doesn't exist or has no "Artifact Patterns" section

**Fallback:** If understanding.md is missing or lacks artifact patterns, skip artifact suggestions entirely - don't prescribe patterns the user hasn't established.

### 6. Present Findings

**Format varies by task depth:**

**For `plan` depth:**
```markdown
## Toolkit Analysis for: {task summary}

**Task depth:** plan (moderate complexity)
**Your toolkit:** {N} agents, {M} skills

### High-Impact Gap
- **{missing-capability}** - {why it matters for this task}
  -> Recommend: `{component-name}`

Create this component? [y/N]
```

**For `design`/`explore` depth:**
```markdown
## Toolkit Analysis for: {task summary}

**Task depth:** {depth} ({reason})
**Your toolkit:** {N} agents, {M} skills

### Current Coverage
- [OK] {existing-agent} - covers {aspect}
- [OK] {existing-skill} - covers {aspect}

### Gaps Identified
1. **{missing-capability}** - {why it would help}
   -> Recommend: `{agent-name}` agent

2. **{missing-workflow}** - {why it would help}
   -> Recommend: `{skill-name}` skill

### Artifact Suggestions
{Based on your patterns:}
- {artifact-type} - {you usually create this for similar tasks}

### Recommendations
{Only list if gaps are significant and components are reusable}
```

**CALL the AskUserQuestion tool:**

Question: "[claude-evolve] Create these components?"
Header: "Toolkit"
| Label | Description |
|-------|-------------|
| Yes, create them | Add the recommended components to your toolkit |
| No, skip | Continue without creating components |

### 7. Create Components (if approved)

**CRITICAL: Write to toolkit, never $HOME/.claude/**

```
# FLAT structure - toolkit IS the plugin
TOOLKIT_AGENTS=$TOOLKIT_PATH/agents/
TOOLKIT_SKILLS=$TOOLKIT_PATH/skills/
```

**Use plugin-dev skills for best practices:**

If `plugin-dev` plugin is available, use its skills to create high-quality components:
- `plugin-dev:agent-development` - For creating agents with proper structure
- `plugin-dev:skill-development` - For creating skills with proper structure

**When using plugin-dev skills:**
1. Invoke the skill with the task context
2. Specify the target path: `$TOOLKIT_AGENTS/` or `$TOOLKIT_SKILLS/`
3. The skill will guide creation following Claude Code best practices

**If plugin-dev not available, create directly:**

See `${CLAUDE_PLUGIN_ROOT}/skills/prepare-task/references/templates.md` for agent and skill templates.

### 8. Confirm Availability

After creation:
```markdown
## Created Successfully

**Agents:**
- `{agent-name}` -> {path}

**Skills:**
- `{skill-name}` -> {path}

**Note:** New agents are available after session restart (Claude Code loads agents at startup).
You can either:
1. Continue current task manually, then use new agents next session
2. Use /resume to restart session with new agents loaded
```

## Workflow Integration

After analyzing toolkit gaps, also suggest workflow guidance (for `plan`/`design`/`explore` depth only).

### Suggest Workflow Based on Depth

**For `plan` depth:**
```markdown
### Workflow Recommendation

**Task depth:** plan - Structured phases would help.

**Quick workflow:**
1. {phase} -> {outcome}
2. {phase} -> {outcome}

Use this structure? [Y/n]
```

**For `design` depth:**
```markdown
### Workflow Recommendation

**Task depth:** design - Full workflow coaching recommended.

**Suggested workflow:** {workflow_name}
- Phase 1: {phase} - {goal}
- Phase 2: {phase} - {goal}
- Phase 3: {phase} - {goal}
- Phase 4: {phase} - {goal}

Start with workflow guidance? [Y/n]
```

**For `explore` depth:**
```markdown
### Workflow Recommendation

**Task depth:** explore - Research-first approach recommended.

**Suggested workflow:**
1. Research - Investigate unknowns, gather information
2. Prototype - Try small experiments
3. Evaluate - Assess what you learned
4. Decide - Commit to direction
5. Execute - Implement chosen approach

Start with research phase?
```

**CALL the AskUserQuestion tool:**

Question: "[claude-evolve] Use workflow guidance for this task?"
Header: "Workflow"
| Label | Description |
|-------|-------------|
| Yes, guide me | Get phase-by-phase suggestions |
| No, I'll manage | Skip workflow guidance |

### Workflow Guidance

If user accepts workflow:
1. Use guidance-agent for phase recommendations
2. Track progress conversationally (no state files)
3. **CALL AskUserQuestion tool** for phase decisions
4. Respect user's skip/advance requests

## Smart Filtering Rules

**DO recommend when:**
- Task depth is `design` or `explore`
- Task depth is `plan` AND gap severity is High
- Task involves specific technology (Rust, K8s, etc.) without matching agent
- Task requires systematic workflow (refactoring, migration) without matching skill
- User will likely do similar tasks again

**DON'T recommend when:**
- Task depth is `execute` or `check`
- Task is simple/one-off
- Existing agents/skills partially cover it
- Gap is too generic ("coding" agent)
- Task is trivial (single file, obvious change)

## Examples

See `${CLAUDE_PLUGIN_ROOT}/skills/prepare-task/references/examples.md` for detailed gap analysis examples showing when to recommend components and when to skip.
