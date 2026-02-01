---
name: workflow
description: |
  Track progress through multi-phase development workflows. Shows current phase, enables phase transitions (next/skip/done), and coordinates multiple concurrent workflows. Uses native Claude Code tasks - no state files.

  <example>
  Context: User wants to check current workflow context
  user: "/workflow"
  assistant: "Shows current task and suggested next phase"
  </example>

  <example>
  Context: User wants to skip the planning phase
  user: "/workflow skip"
  assistant: "Skipping current phase, moving to next"
  </example>

  <example>
  Context: User wants to advance to next phase
  user: "/workflow next"
  assistant: "Advancing to next phase"
  </example>

  <example>
  Context: User wants to complete the workflow
  user: "/workflow done"
  assistant: "Asks for confirmation before completing"
  </example>

  Subcommands: status, skip, next, done, switch, expand

  Triggers: "/workflow", "workflow status", "skip phase", "next phase", "workflow done"
argument-hint: "[status|next|skip|done|switch|expand]"
---

# /workflow Command

Workflow control using native Claude Code tasks. No persistent state files.

## Subcommands

| Command | Action |
|---------|--------|
| `/workflow` | Show current task and phase (status) |
| `/workflow next` | Advance to next phase or sub-task |
| `/workflow skip` | Skip current phase or sub-task |
| `/workflow done` | Mark task complete (with confirmation) |
| `/workflow switch` | Switch between multiple active tasks |
| `/workflow expand` | Create sub-tasks from phase items |

## Execution

### 1. Find Current Task

**CALL TaskList tool** to find tasks with `[claude-evolve]` prefix.

**If multiple found:**
- List them with index numbers
- Let user pick: "[claude-evolve] Multiple workflows found. Which one? (1-N)"
- Or suggest `/workflow switch` for explicit switching

**If none found:**
- Show fallback message (see below)

**If one found:**
- Use that task as current workflow

### 2. Show Status (default `/workflow`)

**CALL TaskGet(id)** to get full task details.

**Read metadata to determine state:**
- `metadata.depth` - determines which phase sequence to use
- `metadata.phase` - identifies current phase
- `metadata.phases_done` - comma-separated list of completed phases
- `metadata.phases_skipped` - comma-separated list of skipped phases

Display format:
```
[claude-evolve] Workflow: {subject}

Phase: {current} | Progress: {visual progress bar}

{Phase-specific guidance based on current phase}

Commands: next | skip | done
```

**Visual progress example for `design` depth:**
```
Progress: requirements [OK] -> design [OK] -> implement <- testing
```

The `<-` indicates current phase.

### 3. Phase Transitions (`/workflow next`)

Advance to the next phase based on depth:

**For `design` depth:** requirements -> design -> implement -> testing -> done
**For `explore` depth:** research -> prototype -> evaluate -> decide -> done
**For `plan` depth:** action -> outcome -> done

**Check for phase tasks with blockedBy:**
1. **CALL TaskList** to find `[claude-evolve] Phase N:` tasks
2. If phase tasks exist with blockedBy, mark current phase task completed
3. The next phase task automatically becomes available (no longer blocked)

**If no phase tasks (single workflow task):**
- **CALL TaskUpdate** with updated `metadata.phase` and `metadata.phases_done`
- Update `description` reflecting new phase context

Announce: `[claude-evolve] Phase complete: {old_phase}. Now in: {new_phase}`

**Spec doc sync:** After advancing, update the spec doc's Status section if `spec_file` exists in metadata. See the workflow skill's Step 5 (Spec Doc Sync) for format details.

### 3.5 Intelligent Sub-Task Creation

When entering a phase with multiple items, use **complexity scoring** to determine whether to create sub-tasks.

**Auto-detect sub-items in plan/description:**
- `- 3.1: Description` or `- 3.1 Description`
- `### 3.1 Title` followed by description
- Numbered lists, bullet points with distinct items

**Complexity scoring determines action:** See `${CLAUDE_PLUGIN_ROOT}/references/complexity-scoring.md` for the full scoring algorithm.

| Total Score | Action |
|-------------|--------|
| 4-6 | Skip sub-tasks (track inline) |
| 7-8 | Suggest sub-tasks (ask user) |
| 9-12 | Auto-create sub-tasks |

**Overrides:** User saying "expand" forces creation; "keep it simple" skips; items < 2 never creates.

**When creating sub-tasks:**

For each sub-item, **CALL TaskCreate**:
```json
{
  "subject": "[claude-evolve] {phase}: {item number} - {item title}",
  "description": "{item description from plan}",
  "activeForm": "Working on {item}...",
  "metadata": {
    "source": "workflow-expand",
    "parent_phase_task": "{phase task id}",
    "item_number": "3.1",
    "item_index": 1,
    "item_total": 6
  }
}
```

**Intelligent blockedBy assignment (no user prompt needed):**

Analyze plan structure to determine dependencies automatically:

| Pattern Detected | blockedBy Strategy |
|------------------|-------------------|
| "then", "after", "once X is done" | Sequential: each blocked by previous |
| "Step 1", "Step 2", numbered steps | Sequential: each blocked by previous |
| "independently", "in parallel", "any order" | Parallel: all blocked by parent only |
| File changes in same module/component | Sequential: likely dependencies |
| File changes in different modules | Parallel: independent work |
| "depends on", "requires", "needs X first" | Explicit: parse the dependency |
| No clear pattern | Default to sequential (safer) |

**Auto-set blockedBy based on analysis:**

```json
// If sequential detected:
{"taskId": "{sub-task-2-id}", "addBlockedBy": ["{sub-task-1-id}"]}
{"taskId": "{sub-task-3-id}", "addBlockedBy": ["{sub-task-2-id}"]}

// If parallel detected:
{"taskId": "{sub-task-1-id}", "addBlockedBy": ["{parent-phase-id}"]}
{"taskId": "{sub-task-2-id}", "addBlockedBy": ["{parent-phase-id}"]}

// If explicit dependency parsed:
{"taskId": "{api-task-id}", "addBlockedBy": ["{schema-task-id}"]}
```

**Announce what was detected:**
```
[claude-evolve] Created 6 sub-tasks for Phase 3 (sequential - step-by-step pattern detected)
```

**Update parent phase task metadata:**
```json
{
  "taskId": "{phase task id}",
  "metadata": {
    "has_subtasks": "true",
    "subtask_count": "6",
    "subtask_strategy": "sequential"
  }
}
```

### 3.6 Working with Sub-Tasks

When a phase has sub-tasks:

**Status shows sub-tasks:**
```
[claude-evolve] Workflow: Build: OAuth login

Phase: implement | Progress: requirements [OK] -> design [OK] -> implement <- testing

Sub-tasks for Phase 3:
  [x] 3.1 - AI Integration (completed)
  [>] 3.2 - Background Processing (in_progress)
  [ ] 3.3 - Doc Storage (pending)

Progress: 1/3 | Commands: next | skip | done
```

**`/workflow next` with sub-tasks:**
1. If current sub-task in_progress → mark completed, start next sub-task
2. If all sub-tasks completed → complete phase, advance to next phase
3. If sub-tasks incomplete when advancing → warn user:

```
[claude-evolve] Phase has 2 incomplete sub-tasks:
  [ ] 3.2 - Background Processing
  [ ] 3.3 - Doc Storage

Complete sub-tasks first, or use /workflow skip to force advance.
```

### 4. Skip Phase (`/workflow skip`)

**CALL TaskUpdate** with:
- Updated `metadata.phase` to next phase
- Updated `metadata.phases_skipped` (append current phase)
- Updated `description` reflecting skip

Announce: `[claude-evolve] Skipped: {phase}. Now in: {new_phase}`

**Spec doc sync:** After skipping, update the spec doc's Status section if `spec_file` exists in metadata. See the workflow skill's Step 5 (Spec Doc Sync) for format details.

### 5. Complete (`/workflow done`)

**Confirm before completing:**
```
[claude-evolve] Mark this workflow complete? [y/N]

Task: {subject}
Phases completed: {phases_done}
Phases skipped: {phases_skipped}
```

Wait for user confirmation.

**After confirmation, CALL TaskUpdate** with:
- `status: "completed"`
- Updated `metadata.phase: "done"`
- Updated `description` with completion status

**Spec doc sync:** After completing, update the spec doc's Status section to "Implemented" if `spec_file` exists in metadata. See the workflow skill's Step 5 (Spec Doc Sync) for format details.

**Then offer learning extraction:**
```
[claude-evolve] Workflow completed!

Want to extract learnings from this session? Run /learn
```

### 6. Switch (`/workflow switch`)

**CALL TaskList** to find all `[claude-evolve]` tasks.

List all with details:
```
[claude-evolve] Active Workflows:

1. [claude-evolve] Build: OAuth login (phase: implement)
2. [claude-evolve] Build: CLI tool (phase: design)

Enter number to switch, or 0 to cancel:
```

**After user selects a number:**
- Display that workflow's full status (same as `/workflow` for that task)
- Use the selected task for subsequent `/workflow next`, `/workflow skip`, etc.
- If user selects 0, cancel and return to previous state

## Fallback (No Task Found)

When no `[claude-evolve]` task exists:

```
[claude-evolve] No active workflow found.

Options:
- Describe your project and I'll create a workflow task
- Use /build-project for guided setup with requirements gathering
- If continuing from a previous session, describe what you were working on
```

## Handle Pivots

If user says "let's start over" or significantly changes direction:

**Ask:** "[claude-evolve] Update the existing workflow or create a new one?"

**Update option:**
- Modify task description
- Reset phase to first phase for current depth:
  - `design` depth → reset to `requirements`
  - `explore` depth → reset to `research`
  - `plan` depth → reset to `action`
  - `check` depth → reset to `verify`
- Clear `phases_done` and `phases_skipped`

**New option:**
- Create fresh task via build-project flow
- Mark old task as completed with note "Superseded by new workflow"

## Phase-Specific Guidance

When showing status, include contextual guidance:

| Phase | Guidance |
|-------|----------|
| `requirements` | "Gathering requirements. Ask clarifying questions." |
| `design` | "Planning approach. Consider architecture and patterns." |
| `implement` | "Building the feature. Write code, run tests." |
| `testing` | "Verifying quality. Test edge cases, review code." |
| `verify` | "Quick sanity check. Confirm basics work." |
| `research` | "Investigating options. Explore approaches." |
| `prototype` | "Building proof of concept. Quick and dirty is OK." |
| `evaluate` | "Assessing results. Compare approaches." |
| `decide` | "Committing to direction. Make the call." |
| `action` | "Taking action. Execute the plan." |
| `outcome` | "Checking outcome. Verify results." |

## Depth-Aware Phase Lists

| Depth | Phases |
|-------|--------|
| `execute` | No phases - just do it |
| `check` | verify (single phase) |
| `plan` | action -> outcome |
| `design` | requirements -> design -> implement -> testing |
| `explore` | research -> prototype -> evaluate -> decide |

## Output Branding

All output uses `[claude-evolve]` prefix.

## Example Session

```
User: /workflow

[claude-evolve] Workflow: Build: OAuth login feature

Phase: implement | Progress: requirements [OK] -> design [OK] -> implement <- testing

Currently implementing the OAuth feature.
- Write the authentication handlers
- Connect to OAuth providers
- Test the login flow

Commands: next | skip | done

User: /workflow next

[claude-evolve] Phase complete: implement. Now in: testing

Testing phase - verify the implementation:
- Unit tests for auth handlers
- Integration tests with OAuth providers
- Manual testing of login flow

User: /workflow done

[claude-evolve] Mark this workflow complete? [y/N]

Task: [claude-evolve] Build: OAuth login feature
Phases completed: requirements, design, implement, testing
Phases skipped: (none)

User: y

[claude-evolve] Workflow completed!

Want to extract learnings from this session? Run /learn
```
