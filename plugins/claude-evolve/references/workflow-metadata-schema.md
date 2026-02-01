# Workflow Metadata Schema

This document defines the metadata structure used when creating native Claude Code tasks via the `TaskCreate` tool for workflow tracking.

## Overview

When the build-project skill or /workflow command creates a task, it stores workflow state in the task's `metadata` field. This enables:

1. **Session continuity** - Resume work context within a session
2. **Phase tracking** - Know which workflow phases are complete
3. **Requirements preservation** - Keep all gathered requirements together
4. **Depth awareness** - Maintain task complexity context

## Design Principle: Flat Metadata

**Keep metadata flat and simple.** This ensures:
- Easy to work with in TaskUpdate calls
- Resilient to context summarization (if metadata is lost, description has context)
- Simple key-value pairs that don't require nested parsing

## TaskCreate Metadata Schema

```yaml
# FLAT metadata structure for workflow tasks
metadata:
  # Source identification
  source: "build-project"           # Origin: "build-project" | "workflow" | "manual"

  # Task complexity
  depth: "design"                   # One of: execute | check | plan | design | explore

  # Current phase (single value, not nested)
  phase: "implement"                # Current workflow phase

  # Completed phases (comma-separated for flat storage)
  phases_done: "requirements,design" # Phases already done (empty string if none)
  phases_skipped: ""                # Phases user chose to skip (empty string if none)

  # Requirements (flat, prefixed with req_)
  req_goal: "Full implementation"   # From goal question
  req_type: "Web application"       # From type question
  req_stack: "TypeScript"           # Detected or user-selected
  req_priority: "Quality"           # From priority question
  req_approach: "Start building"    # From approach question (added via TaskUpdate after step 6)
```

## Depth Values

| Depth | When Used | Phase Approach |
|-------|-----------|----------------|
| `execute` | All low complexity signals | No phases - just do it |
| `check` | Mixed low signals | Brief verification only |
| `plan` | Mixed medium signals | action -> outcome steps |
| `design` | Multiple high signals | Full: requirements -> design -> implement -> testing |
| `explore` | High stakes + unclear | Research: research -> prototype -> evaluate -> decide |

## Phase Values

### For `design` depth
- `requirements` - Gather requirements, ask questions
- `design` - Plan implementation approach
- `implement` - Build the feature
- `testing` - Test and review

### For `explore` depth
- `research` - Investigate options
- `prototype` - Try approaches
- `evaluate` - Assess results
- `decide` - Commit to direction

### For `plan` depth
- `action` - Execute the plan
- `outcome` - Verify results

## Task Subject Convention

Tasks created by claude-evolve use this subject format:
```
[claude-evolve] Build: {brief project description}
```

Examples:
- `[claude-evolve] Build: OAuth login feature`
- `[claude-evolve] Build: CLI tool for data processing`
- `[claude-evolve] Build: API integration with Stripe`

This prefix enables `/workflow` to find claude-evolve tasks via `TaskList`.

## Example TaskCreate Call

```json
{
  "subject": "[claude-evolve] Build: OAuth login feature",
  "description": "Goal: Full implementation\nType: Authentication feature\nStack: TypeScript/Next.js\nPriority: Quality\n\nRequirements:\n- Support Google and GitHub OAuth providers\n- Store tokens securely\n- Handle refresh tokens\n\nCurrent Phase: requirements",
  "activeForm": "Working on OAuth login...",
  "metadata": {
    "source": "build-project",
    "depth": "design",
    "phase": "requirements",
    "phases_done": "",
    "phases_skipped": "",
    "req_goal": "Full implementation",
    "req_type": "Authentication feature",
    "req_stack": "TypeScript",
    "req_priority": "Quality",
    "req_approach": "Start building"
  }
}
```

## Phase Transition Updates

When advancing phases, call `TaskUpdate` with updated metadata AND description:

```json
{
  "taskId": "1",
  "description": "Goal: Full implementation\nType: Authentication feature\nStack: TypeScript/Next.js\nPriority: Quality\n\nRequirements:\n- Support Google and GitHub OAuth providers\n- Store tokens securely\n- Handle refresh tokens\n\nCurrent Phase: implement\nCompleted: requirements, design",
  "metadata": {
    "phase": "implement",
    "phases_done": "requirements,design"
  }
}
```

**Important:** Always update both metadata AND description. If context summarization loses metadata, the description still preserves the state.

## Completion

When task is complete, call `TaskUpdate`:

```json
{
  "taskId": "1",
  "status": "completed",
  "description": "Goal: Full implementation\nType: Authentication feature\nStack: TypeScript/Next.js\nPriority: Quality\n\nRequirements:\n- Support Google and GitHub OAuth providers\n- Store tokens securely\n- Handle refresh tokens\n\nStatus: COMPLETED\nCompleted phases: requirements, design, implement, testing",
  "metadata": {
    "phase": "done",
    "phases_done": "requirements,design,implement,testing"
  }
}
```

## Sub-Task Metadata

When phases are expanded into sub-tasks via `/workflow expand`:

### Parent Phase Task (extended)

```yaml
metadata:
  # ... existing fields ...
  has_subtasks: "true"            # Flag indicating sub-tasks exist
  subtask_count: "6"              # Total sub-tasks created
  subtask_strategy: "sequential"  # How blockedBy was assigned: sequential | parallel | explicit
  subtask_decision: "auto"        # How sub-task creation was decided: auto | suggest | skip | override
  subtask_score: "10"             # Complexity score (4-12) that triggered the decision
```

### Sub-Task Decision Values

| Value | Meaning |
|-------|---------|
| `auto` | Score 9-12: sub-tasks created automatically |
| `suggest` | Score 7-8: user was prompted, said yes |
| `skip` | Score 4-6: no sub-tasks created (or user said no at suggest) |
| `override` | User said "expand" regardless of score |

### Sub-Task Metadata

```yaml
metadata:
  source: "workflow-expand"       # Origin: expanded from phase
  parent_phase_task: "task-123"   # ID of parent phase task
  item_number: "3.1"              # Plan item reference (e.g., 3.1, 3.2)
  item_index: "1"                 # Sequential index (1-based)
  item_total: "6"                 # Total items in phase
```

### Sub-Task Subject Convention

```
[claude-evolve] Phase {N}: {item_number} - {item title}
```

Examples:
- `[claude-evolve] Phase 3: 3.1 - AI Integration`
- `[claude-evolve] Phase 3: 3.2 - Background Processing`
- `[claude-evolve] Phase 3: 3.3 - Doc Storage`

### Example Sub-Task Creation

```json
{
  "subject": "[claude-evolve] Phase 3: 3.1 - AI Integration",
  "description": "Implement AI integration for documentation generation.\n\n- src/lib/ai/client.ts - Anthropic SDK wrapper\n- src/lib/ai/prompts.ts - Prompt templates\n- src/lib/ai/documentation.ts - Generate docs from parsed code",
  "activeForm": "Working on AI Integration...",
  "metadata": {
    "source": "workflow-expand",
    "parent_phase_task": "task-1",
    "item_number": "3.1",
    "item_index": "1",
    "item_total": "6"
  }
}
```

## Using blockedBy for Dependencies

The `blockedBy` field creates task dependencies. Tasks with blockedBy cannot start until blocking tasks complete. Dependencies are set up **automatically** based on intelligent analysis of plan structure.

### Automatic Phase Dependencies

For `design` and `explore` depths, build-project automatically creates phase tasks with blockedBy:

```
Phase 1: Requirements (no blockedBy - starts immediately)
Phase 2: Design (blockedBy: Phase 1)
Phase 3: Implement (blockedBy: Phase 2)
Phase 4: Testing (blockedBy: Phase 3)
```

### Intelligent Sub-Task Dependencies

When sub-tasks are created, blockedBy is assigned automatically based on plan analysis:

| Pattern in Plan | Detected Strategy | blockedBy Result |
|-----------------|-------------------|------------------|
| "Step 1", "Step 2", numbered steps | Sequential | Each blocked by previous |
| "then", "after", "once X is done" | Sequential | Each blocked by previous |
| "independently", "in parallel" | Parallel | All blocked by parent only |
| Same module/component changes | Sequential | Likely code dependencies |
| Different module changes | Parallel | Independent work |
| "depends on X", "requires Y" | Explicit | Parse and honor dependency |
| No clear pattern | Sequential | Default (safer assumption) |

**Example - Sequential detected:**
```json
// Plan says: "Step 1: Schema, Step 2: API, Step 3: Tests"
{"taskId": "api-task", "addBlockedBy": ["schema-task"]}
{"taskId": "tests-task", "addBlockedBy": ["api-task"]}
```

**Example - Parallel detected:**
```json
// Plan says: "These can be done in any order"
{"taskId": "feature-a-task", "addBlockedBy": ["parent-phase"]}
{"taskId": "feature-b-task", "addBlockedBy": ["parent-phase"]}
```

**Example - Explicit dependency:**
```json
// Plan says: "API endpoints (requires schema first)"
{"taskId": "api-task", "addBlockedBy": ["schema-task"]}
```

### Extended Metadata for Dependencies

```yaml
metadata:
  # ... existing fields ...
  has_phase_tasks: "true"       # Parent has phase task children
  has_subtasks: "true"          # Phase has sub-task children
  subtask_count: "6"            # Number of sub-tasks
  subtask_strategy: "sequential" # How blockedBy was assigned
```

### Viewing Dependencies

When calling `TaskList`, blocked tasks show their dependencies:

```
#1 [in_progress] Phase 1 - Requirements
#2 [pending] Phase 2 - Design > blocked by #1
#3 [pending] Phase 3 - Implement > blocked by #2
#4 [pending] Phase 4 - Testing > blocked by #3
```

A task cannot transition to `in_progress` until all its `blockedBy` tasks are `completed`.

## Related Files

- `../skills/build-project/SKILL.md` - Creates tasks with this schema
- `../commands/workflow.md` - Reads and updates task metadata
