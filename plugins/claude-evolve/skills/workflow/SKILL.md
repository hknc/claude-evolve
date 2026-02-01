---
name: workflow
description: |
  This skill should be used when the user says "/workflow", "what phase am I on",
  "show my workflow", "workflow status", "next phase", "skip phase", "workflow done",
  "switch workflow", "what's my current phase", "advance phase",
  "how is my project going", "where am I", "what should I do next",
  "what's left to do", "what phase is next", "track my progress",
  "check progress", "mark this phase done", "move to the next step",
  "expand this phase", "break this down into sub-tasks",
  "let's start over", "change direction", "pivot".

  Manages ACTIVE multi-phase workflows using native Claude Code tasks.
  To get a workflow RECOMMENDATION for a new task, use prepare-task instead.
---

# Workflow Skill

Manage active multi-phase development workflows using native Claude Code tasks. This skill covers **core behavior** — routing, status display (including phase-specific guidance), phase transitions, spec doc sync, and acceptance criteria verification. For **implementation details** (sub-task creation, dependency analysis, pivot handling), see `${CLAUDE_PLUGIN_ROOT}/commands/workflow.md`.

## Routing

Route based on user intent:

| Input | Action |
|-------|--------|
| `/workflow` or "show my workflow" | Show current phase and progress |
| `/workflow next` or "next phase" | Advance to next phase |
| `/workflow skip` or "skip phase" | Skip current phase |
| `/workflow done` or "workflow done" | Mark workflow complete |
| `/workflow switch` or "switch workflow" | Switch between active workflows |
| `/workflow expand` | Create sub-tasks from phase items |
| Natural-language status queries (e.g., "where am I", "what should I do next") | Show current phase and progress (same as `/workflow`) |

## Execution

### 1. Find Current Workflow

**CALL TaskList** to find tasks with `[claude-evolve]` prefix.

- **One found:** Use as current workflow
- **Multiple found:** List them and let user pick, or suggest `/workflow switch`
- **None found:** Show fallback (see Error Handling)

### 2. Show Status

**CALL TaskGet(id)** to read task details and metadata.

Read metadata fields: `depth`, `phase`, `phases_done`, `phases_skipped`, `has_phase_tasks`, `spec_file`.

**If `depth` is `execute`** (no phases):
```
[claude-evolve] Workflow: {subject}
Status: In progress (execute — no phases)
{Task description summary}
Commands: done
```

**Otherwise** (depths with phases — `design`, `explore`, `plan`, `check`):
```
[claude-evolve] Workflow: {subject}
Phase: {current} | Progress: requirements [OK] -> design [OK] -> implement <- testing
{Phase-specific guidance — see table below}
Commands: next | skip | done
```

**Phase-specific guidance:**

| Phase | Guidance |
|-------|----------|
| `requirements` | Gathering requirements. Ask clarifying questions. |
| `design` | Planning approach. Consider architecture and patterns. |
| `implement` | Building the feature. Write code, run tests. |
| `testing` | Verifying quality. Test edge cases, review code. |
| `verify` | Quick sanity check. Confirm basics work. |
| `research` | Investigating options. Explore approaches. |
| `prototype` | Building proof of concept. Quick and dirty is OK. |
| `evaluate` | Assessing results. Compare approaches. |
| `decide` | Committing to direction. Make the call. |
| `action` | Taking action. Execute the plan. |
| `outcome` | Checking outcome. Verify results. |

**If `has_phase_tasks` is `"true"`**, also CALL TaskList to find phase sub-tasks and show their completion status alongside the progress bar.

### 3. Phase Transitions

**Advance (`next`):**
1. Update `metadata.phase` to the next phase in the sequence
2. Append the completed phase to `metadata.phases_done` (comma-separated, e.g., `"requirements,design"`)
3. If phase tasks exist with blockedBy, mark current phase task completed so next unblocks
4. Sync the spec doc (see Step 5)
5. **If already on the last phase**, prompt: "This is the final phase. Use `/workflow done` to complete the workflow."

**Skip:**
1. Update `metadata.phase` to the next phase and append current to `metadata.phases_skipped`
2. Sync the spec doc
3. **If skipping the last phase**, same prompt as above

**Complete (`done`):**
1. Check the spec doc's `## Acceptance Criteria` section (if present) — verify all criteria are met. Warn the user if any are unmet
2. Confirm with user before completing
3. Set task `status: "completed"` and `metadata.phase: "done"`
4. Sync the spec doc with final status
5. Suggest `/learn` afterward

### 4. Phase Sequences by Depth

| Depth | Phases |
|-------|--------|
| `design` | requirements -> design -> implement -> testing |
| `explore` | research -> prototype -> evaluate -> decide |
| `plan` | action -> outcome |
| `check` | verify (single phase) |
| `execute` | No phases — just do it. No phase management needed. |

### 5. Spec Doc Sync

After phase transitions (`next`, `skip`, `done`), update the spec doc:

1. Check if `spec_file` exists in metadata — skip if missing or file not found
2. Read the file, find or append a `## Status` section
3. Update with phase completion info, e.g.:
   ```
   - Phase: implement
   - Completed: requirements, design
   - Next: testing
   ```

See `${CLAUDE_PLUGIN_ROOT}/commands/workflow.md` (Spec Doc Sync sections) for format details and edge cases.

### 6. Sub-Task Management

Sub-task creation is determined by **complexity scoring**, not a fixed item count. The algorithm assesses item count, dependencies, scope, and complexity signals (each Low/Medium/High) to decide whether to skip, suggest, or auto-create sub-tasks.

See `${CLAUDE_PLUGIN_ROOT}/references/complexity-scoring.md` for the scoring algorithm. See `${CLAUDE_PLUGIN_ROOT}/commands/workflow.md` (Intelligent Sub-Task Creation and Working with Sub-Tasks sections) for dependency analysis and sub-task workflows.

### 7. Switch Between Workflows

**CALL TaskList** to find all `[claude-evolve]` tasks. Display an indexed list with subjects and current phases. Let the user pick by number, then show the selected workflow's full status. See `${CLAUDE_PLUGIN_ROOT}/commands/workflow.md` (Switch section) for full output format.

### 8. Expand Phase into Sub-Tasks

Parse the current phase's items from the task description. Use complexity scoring to determine whether to create sub-tasks (see `${CLAUDE_PLUGIN_ROOT}/references/complexity-scoring.md`). See `${CLAUDE_PLUGIN_ROOT}/commands/workflow.md` (Intelligent Sub-Task Creation section) for dependency analysis.

### 9. Handling Pivots

If the user says "let's start over" or significantly changes direction, ask whether to update the existing workflow or create a new one. Updating resets the phase and clears progress; creating a new one marks the old task as "Superseded." See `${CLAUDE_PLUGIN_ROOT}/commands/workflow.md` (Handle Pivots section) for reset and supersede flows.

## Insufficient Context Detection

When showing status or starting work on a phase, check if the project directory has insufficient context. **Heuristic:** fewer than 3 source files (excluding config files like `package.json`, `.gitignore`) and the task requires implementing substantial functionality. If context is insufficient for the current phase:

```
[claude-evolve] This project doesn't have enough context for me to work effectively.

Recommendation: Do deep research first using Claude on the web (claude.ai) or another
research tool, then drop the research report into a file in this project (e.g., research.md).
I'll use that context to produce much better results.
```

This is especially relevant for `design`/`explore` depths where understanding the problem space is critical before implementation.

## Error Handling

| Error | Action |
|-------|--------|
| No `[claude-evolve]` tasks found | Show: "No active workflow. Use /build-project for guided setup or describe your project." |
| Task has no metadata.phase | Treat as freeform task, show status without phase progress |
| Multiple workflows, user doesn't pick | Default to most recently updated task |

