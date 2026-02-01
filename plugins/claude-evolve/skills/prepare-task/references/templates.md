# Component Templates

**CRITICAL: Follow these templates exactly. Claude Code validates frontmatter strictly.**

## Agent Template

```markdown
---
name: {agent-name}
description: Use this agent when {triggering conditions}. Examples:

<example>
Context: {Situation description}
user: "{User request}"
assistant: "{Initial response}"
<commentary>
{Why this agent should be triggered}
</commentary>
assistant: "I'll use the {agent-name} agent to {what it does}."
</example>

<example>
Context: {Another scenario}
user: "{Another request}"
assistant: "{Response}"
<commentary>
{Why agent triggers}
</commentary>
assistant: "I'll use the {agent-name} agent to {action}."
</example>

model: inherit
color: {blue|cyan|green|yellow|magenta|red}
tools: ["Read", "Write", "Glob", "Grep", "Bash"]
---

You are {expert role} specializing in {domain}.

**Your Core Responsibilities:**
1. {Primary responsibility}
2. {Secondary responsibility}
3. {Additional responsibility}

**Process:**
1. **{Step Name}**: {What to do}
2. **{Step Name}**: {What to do}
3. **{Step Name}**: {What to do}

**Quality Standards:**
- {Standard 1}
- {Standard 2}
- {Standard 3}

**Output Format:**
{Define structure of output}

**Edge Cases:**
- {Scenario 1}: {How to handle}
- {Scenario 2}: {How to handle}
```

## Frontmatter Reference

### Required Fields

| Field | Format | Example |
|-------|--------|---------|
| `name` | lowercase-hyphens, 3-50 chars | `code-reviewer` |
| `description` | "Use this agent when..." + examples | See template |
| `model` | `inherit`, `sonnet`, `opus`, `haiku` | `inherit` |
| `color` | Color name | `blue` |

### Optional Fields

| Field | Format | Default |
|-------|--------|---------|
| `tools` | JSON array of tool names | All tools |

### Valid Colors

| Color | Use For |
|-------|---------|
| `blue` | Analysis, review, investigation |
| `cyan` | Documentation, information |
| `green` | Generation, creation, success |
| `yellow` | Validation, warnings, caution |
| `red` | Security, critical, errors |
| `magenta` | Refactoring, transformation |

### Tools Array

```yaml
# Read-only agents
tools: ["Read", "Grep", "Glob"]

# Generator agents
tools: ["Read", "Write", "Grep", "Glob"]

# Full agents
tools: ["Read", "Write", "Edit", "Glob", "Grep", "Bash", "LSP"]

# All tools (omit field entirely)
# tools: (not specified)
```

## Example Block Format

**CRITICAL: Each example MUST have this exact structure:**

```
<example>
Context: {One line describing the situation}
user: "{What the user says - in quotes}"
assistant: "{Initial response - in quotes}"
<commentary>
{Why this agent should trigger - explains reasoning}
</commentary>
assistant: "I'll use the {agent-name} agent to {action}."
</example>
```

### Example Block Rules
- Minimum 2 examples, recommended 3-4
- Context line describes scenario
- User line shows what triggers the agent
- First assistant line shows initial response
- Commentary explains WHY agent triggers
- Second assistant line shows agent invocation

## Skill Template

```markdown
---
name: {skill-name}
description: |
  Use when {trigger phrases}. {Brief description of what skill does}.
---

# {Skill Name}

## When to Use
- {Trigger condition 1}
- {Trigger condition 2}

## Instructions

{Step-by-step instructions for the skill}

## Output Format

{What the skill should produce}
```

## Rule Template

```markdown
---
name: {rule-name}
description: {Brief description of what rule enforces}
---

# {Rule Name}

{Instructions that should always be followed}

## Guidelines
- {Guideline 1}
- {Guideline 2}
```

## Validation Checklist

Before creating any component, verify:

**Agent:**
- [ ] `name`: lowercase letters, numbers, hyphens only (3-50 chars)
- [ ] `name`: starts and ends with alphanumeric
- [ ] `description`: starts with "Use this agent when"
- [ ] `description`: has 2+ `<example>` blocks
- [ ] Each example has: Context, user, assistant, commentary, assistant
- [ ] `model`: one of `inherit`, `sonnet`, `opus`, `haiku`
- [ ] `color`: one of `blue`, `cyan`, `green`, `yellow`, `magenta`, `red`
- [ ] `tools`: JSON array format `["Tool1", "Tool2"]` or omitted
- [ ] System prompt: written in second person ("You are...")
- [ ] System prompt: has Core Responsibilities, Process, Quality Standards, Output Format

**Skill:**
- [ ] `name`: follows same naming rules as agents
- [ ] `description`: explains when to use
- [ ] Body: clear instructions

**Rule:**
- [ ] `name`: follows naming rules
- [ ] `description`: brief summary
- [ ] Body: clear guidelines
