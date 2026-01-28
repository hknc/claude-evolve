---
paths: ["**/*"]
---

# User Interaction Architecture

## Critical Constraint

**AskUserQuestion ONLY works at the command level, NOT in subagents.**

Subagents invoked via Task() are stateless and cannot pause for user input.
AskUserQuestion calls in subagents fail silently - the agent falls back to text output.

## Architecture Pattern

### Commands Handle User Interaction

```
Command (main thread)          Subagent (via Task)
─────────────────────          ──────────────────────
✓ CAN use AskUserQuestion      ✗ CANNOT use AskUserQuestion
✓ CAN pause for user input     ✗ Receives input ONCE at invocation
✓ CAN show native UI prompts   ✗ Returns output ONCE when complete
```

### Correct Pattern

```
1. Command uses AskUserQuestion to collect user preferences
2. Command spawns Task(agent) with collected choices as parameters
3. Agent executes based on parameters (NO user interaction)
4. Agent returns structured results
5. Command uses AskUserQuestion for follow-up if needed
```

### Wrong Pattern

```
1. Command spawns Task(agent)
2. Agent tries to use AskUserQuestion → FAILS SILENTLY
3. Agent falls back to numbered text lists
4. User sees "1. Option A  2. Option B" instead of native UI
```

## For Plugin Authors

### In Commands

Commands CAN and SHOULD use AskUserQuestion:

```markdown
## My Command Flow

### Step 1: Get User Preference
Use AskUserQuestion:
- question: "What would you like to do?"
- header: "Action"
- options: ["Option A", "Option B"]

### Step 2: Execute
Based on selection, spawn Task(my-agent) with:
- action: "{selected_option}"
```

### In Agents

Agents should NOT include AskUserQuestion in allowed-tools:

```yaml
---
name: my-agent
description: Executes tasks. Cannot interact with users.
allowed-tools: Read, Write, Bash, Glob, Grep
# NOTE: No AskUserQuestion - agent receives parameters from command
---
```

If an agent needs a decision:
1. Return a structured response with options
2. Let the command ask the user
3. Command can resume/re-invoke agent with the choice

## AskUserQuestion Constraints

When using AskUserQuestion (in commands only):

- **Maximum 4 options per question**
- **No emoji characters** in question, header, or option labels
- **User can always select "Other"** to provide custom input
- **multiSelect: true** allows multiple selections

## Example: Command with Wizard Flow

```markdown
## /setup Command

### Step 1: Check Existing Config
Use Bash to check if config exists.

### Step 2: Ask User (if no config)
Use AskUserQuestion:
- question: "No configuration found. What would you like to do?"
- header: "Setup"
- options: ["Create new config", "Import existing"]

### Step 3: Execute Based on Choice
If "Create new config":
  - Use AskUserQuestion for config options (name, settings, etc.)
  - Then spawn Task(setup-agent) with all collected parameters

If "Import existing":
  - Use AskUserQuestion to get import path
  - Then spawn Task(import-agent) with path parameter
```
