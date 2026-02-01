---
name: evolve
description: |
  Manage claude-evolve toolkit. Initialize, release, migrate, and switch toolkits.

  Subcommands: init, help, learn, audit, migrate, prepare, release, switch, context, status, consolidate, understanding

  Triggers: "/evolve", "toolkit", "setup toolkit", "initialize toolkit", "release toolkit"
---

# /evolve Command

## Architecture Note

**CRITICAL: Commands handle ALL user interaction. Subagents CANNOT use AskUserQuestion.**

Subagents invoked via Task() are stateless and cannot pause for user input.
The command must collect all user choices BEFORE spawning the agent.

## Routing

| Command | Handler |
|---------|---------|
| `/evolve` (bare) | Task(claude-evolve:evolve-toolkit-manager) with action="status" |
| `/evolve init` | See Init Flow below |
| `/evolve help` | Read file `${CLAUDE_PLUGIN_ROOT}/commands/help.md` and output its content EXACTLY. Do NOT search for or scan any directories. |
| `/evolve status` | Task(claude-evolve:evolve-toolkit-manager) with action="status" |
| `/evolve release` | See Release Flow below |
| `/evolve migrate` | Task(claude-evolve:evolve-toolkit-manager) with action="migrate" |
| `/evolve switch {name}` | Task(claude-evolve:evolve-toolkit-manager) with action="switch", name="{name}" |
| `/evolve context` | Task(claude-evolve:evolve-context-detector) |
| `/evolve learn` | Same as `/learn` command — execute the two-phase interactive flow from `${CLAUDE_PLUGIN_ROOT}/commands/learn.md` |
| `/evolve audit` | Task(claude-evolve:evolve-setup-auditor) |
| `/evolve consolidate` | Task(claude-evolve:evolve-setup-auditor) with action="consolidate" |
| `/evolve prepare` | Use prepare-task skill |
| `/evolve understanding` | List all understanding files (see below) |

---

## Understanding Command (`/evolve understanding`)

Show the user's learned patterns and learning activity. Run these bash commands and display results:

```bash
TOOLKIT_NAME=$(cat $HOME/.claude-evolve/active 2>/dev/null)
TOOLKIT_PATH=$HOME/.claude-evolve/toolkits/$TOOLKIT_NAME
UNDERSTANDING_PATH=$TOOLKIT_PATH/understanding
```

**Output format:**

```markdown
## Your Understanding

**Universal patterns:** {UNDERSTANDING_PATH}/understanding.md
{Show first 15 lines of content or "Empty - run /learn then /reflect to build"}

**Project-specific:**
{List all files in {UNDERSTANDING_PATH}/projects/*.md with their first line}
{Or "None yet - run /reflect after /learn sessions to build project patterns"}

**Learning history:**
{Count events in $TOOLKIT_PATH/history/events.json or "No learnings yet"}
{Show last 5 events (summary + timestamp) if events exist}

**Toolkit components:**
{Count agents in $TOOLKIT_PATH/agents/*.md}
{Count skills in $TOOLKIT_PATH/skills/*/SKILL.md}
{Count rules in $TOOLKIT_PATH/rules/*.md}

**Pending signals:** {count from $HOME/.claude-evolve/signals/*.json}
{If count > 0: "Run /learn to capture pending signals"}
{If count = 0: "No pending signals"}
```

---

## Help Content (`/evolve help`)

**Use the Read tool on `${CLAUDE_PLUGIN_ROOT}/commands/help.md` and output the help content from that file EXACTLY as written. Do NOT search for the file, scan directories, or improvise help content.** That file is the single source of truth.

---

## Init Flow (`/evolve init`)

The command handles the interactive wizard, then passes choices to the agent.

### Step 1: Check Plan Mode

If currently in plan mode, use AskUserQuestion:
- question: "[claude-evolve] Toolkit initialization requires exiting plan mode. Continue?"
- header: "Exit plan mode"
- options: ["Yes, exit and initialize", "No, stay in plan mode"]

If "Yes": Call ExitPlanMode tool, then continue.
If "No": Output "[claude-evolve] Init cancelled." and STOP.

### Step 2: Check for Existing Toolkit

Use Bash to check: `cat $HOME/.claude-evolve/active 2>/dev/null`

**If toolkit exists**, use AskUserQuestion:
- question: "[claude-evolve] Found existing toolkit '{name}'. Would you like to use it?"
- header: "Use toolkit"
- options: ["Yes, use existing", "No, create new"]

If "Yes, use existing":
  - Check if plugin is installed
  - If not installed, tell user:
    ```
    Run these commands to activate your toolkit:
    /plugin marketplace add ~/.claude-evolve
    /plugin install {name}-toolkit@claude-evolve-local
    ```
  - DONE

If "No, create new": Continue to step 3.

**If no toolkit exists**, use AskUserQuestion:
- question: "[claude-evolve] No toolkit found. What would you like to do?"
- header: "Setup"
- options: ["Create new toolkit", "Clone from git URL"]

If "Clone from git URL":
  - Use AskUserQuestion to ask for git URL (user selects "Other" to enter URL)
  - Spawn Task(claude-evolve:evolve-toolkit-manager) with action="clone", url="{url}"
  - DONE

If "Create new toolkit": Continue to step 3.

### Step 3: Choose Toolkit Name

Get username via Bash: `whoami`
Get machine name via Bash: `hostname -s`

Use AskUserQuestion:
- question: "[claude-evolve] What would you like to name your toolkit?"
- header: "Name"
- options with descriptions:
  - "{username}" - "Name toolkit after your username"
  - "{machine}" - "Name toolkit after this computer"
  - "personal" - "Generic name for personal toolkit"

User can also select "Other" to enter a custom name.

### Step 4: Create Toolkit (spawn agent)

Spawn Task(claude-evolve:evolve-toolkit-manager) with:
- action: "create"
- name: "{chosen_name}"

The agent will:
- Create directory structure
- Create all required files
- Return success with location

### Step 5: Project Analysis (spawn agent)

Get current directory via Bash: `pwd`

Spawn Task(claude-evolve:evolve-context-detector) with:
- directory: "{current_dir}"
- mode: "analyze"

The agent returns:
- technologies: List of detected tech
- recommended_agents: List of agent suggestions
- existing_agents: Any agents already in $HOME/.claude/

### Step 6: Ask About Agents

If recommended_agents is not empty, use AskUserQuestion:
- question: "[claude-evolve] Would you like to create agents for this project?"
- header: "Agents"
- options: ["All recommended", "Project-specific only", "Universal only", "Skip for now"]

### Step 7: Create Agents (if selected)

If user selected agents, spawn Task(claude-evolve:evolve-toolkit-manager) with:
- action: "create_agents"
- toolkit: "{toolkit_name}"
- agents: [list of selected agent types]
- project: "{project_name}"
- technologies: [list from analysis]

### Step 8: Install Toolkit Plugin

Output to user:
```
## Install Your Toolkit

Run these commands to activate your toolkit:

/plugin marketplace add ~/.claude-evolve
/plugin install {toolkit_name}-toolkit@claude-evolve-local

After installation:
- Rules and skills are active immediately
- Agents available after restart (or /resume)
- Run /evolve release later to sync to other machines
```

### Step 9: Next Steps

Use AskUserQuestion:
- question: "[claude-evolve] What would you like to do next?"
- header: "Next step"
- options: ["Run audit (Recommended)", "Migrate $HOME/.claude/", "See commands", "Done for now"]

Handle response:
- "Run audit": Spawn Task(claude-evolve:evolve-setup-auditor)
- "Migrate $HOME/.claude/": Spawn Task(claude-evolve:evolve-toolkit-manager) with action="migrate"
- "See commands": Output command reference
- "Done for now": Output "[claude-evolve] Tip: Use /workflow for phase-by-phase task guidance."

---

## Release Flow (`/evolve release`)

### Step 1: Check Toolkit and Remote

Spawn Task(claude-evolve:evolve-toolkit-manager) with:
- action: "release_check"

Agent returns:
- has_toolkit: boolean
- has_remote: boolean
- has_changes: boolean
- current_version: string
- suggested_version: string
- change_summary: string

### Step 2: Confirm Release

If has_changes, use AskUserQuestion:
- question: "[claude-evolve] Release as v{suggested_version}?"
- header: "Release"
- options: ["Yes, release", "No, cancel"]

### Step 3: Execute Release

If confirmed, spawn Task(claude-evolve:evolve-toolkit-manager) with:
- action: "release_execute"
- version: "{suggested_version}"

---

## Critical Rules

- **Commands handle user interaction** - AskUserQuestion only works at command level
- **Agents are stateless** - Pass all needed parameters when spawning
- **Never write to $HOME/.claude/** - All writes go to toolkit at `$HOME/.claude-evolve/toolkits/{name}/`
- **Check toolkit exists** - Most commands require `/evolve init` first
