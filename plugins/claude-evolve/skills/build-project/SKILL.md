---
name: build-project
description: |
  This skill should be used when the user says "let's build", "build this project", "build me", "build a",
  "create this", "implement this", "make this", "make me a", "develop this",
  "let's make", "start building", "build it", "create it", "let's create",
  "let's implement", "new project", "new feature", "help me create", "start a new",
  "from scratch", "greenfield", "scaffold", "bootstrap", "set up a new", "initialize",
  "I want to build", "I want to create", "I want to make",
  or initiates any new development task.

  Provides STRUCTURED requirements gathering using native AskUserQuestion UI
  with adaptive, depth-aware elicitation. Works for any domain — code, writing,
  research, design, ops. Gathers goal through interactive questions, then runs
  an adaptive elicitation loop that derives questions from context (not templates).
  Creates an implementation doc, then hands off to /workflow for phase guidance.
---

# Build Project Skill

Guide new projects, features, and tasks with adaptive requirements gathering using native UI. Works equally well for greenfield projects and new features within existing codebases.

## Philosophy

- **Meta, not prescriptive** - Teach Claude HOW to gather requirements, not WHAT to ask. Questions emerge from context, not templates. Works for any domain.
- **Native UI first** - Always use `AskUserQuestion` tool, never text-based numbered lists
- **Depth-aware** - Scale elicitation to task complexity
- **Adaptive** - Each round of questions derives from what's known vs unknown
- **Workflow handoff** - Connect to `/workflow` command for ongoing phase guidance

## CRITICAL: Use Native UI

**ALWAYS use the `AskUserQuestion` tool** for all user-facing questions — never text-based numbered lists. The terminal renders AskUserQuestion as interactive chips/buttons; numbered lists break this UX.

See `${CLAUDE_PLUGIN_ROOT}/skills/build-project/references/questions.md` for the exact JSON format, constraints (max 12-char headers, 2-4 options, 1-4 questions per call), and core question templates.

## Process

### Step 1. Gather Initial Context

Before asking questions, quickly assess the environment:

- List directory contents to check for existing project structure
- Check for docs, requirements, or spec files

Look for:
- Existing code structure (indicates adding a feature vs greenfield project)
- Documentation or spec files (may have existing requirements or architecture)
- Package files (indicates technology stack already chosen)
- Existing specs from previous build flows (e.g., `SPEC.md`, `docs/specs/`)

**Greenfield vs existing project:** If the codebase already exists, note the stack, structure, and conventions. The adaptive loop will factor these in — questions should reference the existing codebase rather than asking from scratch.

### Step 1b. Insufficient Context Check

After gathering initial context, check if the project has enough information to work with effectively.

**Heuristic:** The directory is empty or has fewer than 3 source files (excluding config files like `package.json`, `.gitignore`, `README.md`) AND the task requires implementing substantial functionality (not just a config change or small script).

If context is insufficient:

**CALL the AskUserQuestion tool:**

| Field | Value |
|-------|-------|
| question | "[claude-evolve] This project doesn't have enough context for me to work effectively. I recommend doing deep research first using Claude on the web (claude.ai) or the desktop app, then dropping the research report into this project (e.g., research.md). Should we continue anyway or pause for research?" |
| header | "Context" |

| Label | Description |
|-------|-------------|
| Pause for research (Recommended) | Do deep research first, drop report into project, then come back |
| Continue anyway | Proceed with limited context |

If user selects "Pause for research":
```
[claude-evolve] Pausing for research.

Next steps:
1. Open Claude on the web (claude.ai) or the desktop app
2. Research your project idea thoroughly — architecture, libraries, patterns, examples
3. Save the research as a file in this project (e.g., research.md)
4. Come back and say "let's build" — I'll use the research to produce much better results
```
Then stop — do not proceed with the build flow.

If user selects "Continue anyway", proceed to Step 2.

### Step 2. Detect Project Type

Based on context gathered:

| Signals | Project Type |
|---------|--------------|
| `package.json`, `tsconfig.json` | JavaScript/TypeScript |
| `Cargo.toml`, `src/main.rs` | Rust |
| `pyproject.toml`, `setup.py` | Python |
| `go.mod` | Go |
| Other language-specific files | Detect accordingly (e.g., `pom.xml` → Java, `*.sln` → C#) |
| Empty directory | Greenfield - ask about stack |
| No code signals | Non-code task - skip to Step 3 |

**Non-code tasks** (writing, research, design, ops): If the task doesn't involve code, skip this step and Step 7 entirely. The adaptive loop (Step 6) handles all domain-specific gathering.

### Step 3. Ask Goal Question

**CALL the AskUserQuestion tool:**

| Field | Value |
|-------|-------|
| question | "[claude-evolve] What's your primary goal?" |
| header | "Goal" |

| Label | Description |
|-------|-------------|
| Full implementation | Complete, production-ready feature |
| Core MVP | Essential functionality only |
| Prototype | Quick proof of concept |
| Exploration | Learn or investigate approaches |

### Step 4. Map Goal to Depth

Based on goal answer, calibrate depth:

| Goal | Depth | Elicitation |
|------|-------|-------------|
| Full implementation | `design` | Guided adaptive loop |
| Core MVP | `plan` | 1+ adaptive rounds |
| Prototype | `check` | Minimal — usually 1 round |
| Exploration | `explore` | Guided adaptive loop |

### Step 5. Offer Guided Requirements Gathering

For `design` and `explore` depths, offer a guided workflow before diving in:

**CALL the AskUserQuestion tool:**

| Field | Value |
|-------|-------|
| question | "[claude-evolve] This looks like a substantial task. Use guided requirements gathering to cover all aspects before planning?" |
| header | "Gathering" |

| Label | Description |
|-------|-------------|
| Thorough gathering (Recommended) | Multi-round adaptive questions to ensure nothing is missed |
| Quick start | Minimal questions, jump to building |

If user selects "Quick start", skip to Step 7 (if greenfield code project) or Step 8 (all other cases) with just a brief requirements summary.

If user selects "Thorough gathering", proceed to Step 6.

For `plan` and `check` depths, skip this step and go directly to Step 6 with their respective minimum rounds.

### Step 6. Adaptive Elicitation Loop

This is the core methodology. Claude does NOT use prescriptive templates. Instead, it follows this method to derive context-appropriate questions each round.

#### Method

**Each round:**
1. Analyze what's known vs unknown about the user's task
2. Identify the most important unknowns for creating a solid plan
3. Formulate 1-4 context-specific questions using AskUserQuestion
4. After the user responds, briefly acknowledge what was learned
5. Repeat until coverage is sufficient or user exits early

**Coverage dimensions** (not questions — areas to check; see `${CLAUDE_PLUGIN_ROOT}/skills/build-project/references/questions.md` for the full table with example probes):

Scope & boundaries, Interactions, Data & state, Structure, Dependencies, Constraints, Security & access, Success criteria.

**Key rules for formulating questions:**
- Derive every question from the user's actual description and domain — never ask generic template questions
- Contextualize: "How will the authentication service interact with your existing user database?" not "How do users authenticate?"
- Combine up to 4 questions per AskUserQuestion call for efficiency
- On round 2+, include a "That covers it" option to allow early exit
- After each round, briefly summarize what was learned before asking more
- Use the "Other" option (built into AskUserQuestion) for open-ended answers

#### Minimum Rounds by Depth (Authoritative)

| Depth | Min Rounds | Guidance |
|-------|-----------|----------|
| `design` | 2 | Continue until all relevant dimensions are covered |
| `explore` | 2 | Continue until unknowns and scope are well-defined |
| `plan` | 1 | Continue if key decisions are still unclear |
| `check` | 0 | Usually 1 round suffices, but no cap |

**Stop condition:** Not a round count — stop when you can confidently write a comprehensive plan that addresses all aspects the user cares about. If unsure, ask another round.

**Acceptance criteria:** Before stopping, ensure at least one round probed the **Success criteria** dimension. The gathered answers become the `## Acceptance Criteria` checklist in the spec doc (Step 8). Each criterion must be concrete and verifiable — "users can log in" not "auth works." If the user exits early before Success criteria is probed, ask one focused follow-up question on verification before proceeding to Step 7/8.

See `${CLAUDE_PLUGIN_ROOT}/skills/build-project/references/questions.md` for the full methodology reference (coverage dimensions, question formulation, round examples, multiSelect guidance) and `${CLAUDE_PLUGIN_ROOT}/skills/build-project/references/examples.md` for complete walkthroughs of each depth.

### Step 7. Technology Stack (if greenfield code project)

If the task involves code and no existing stack is detected:

**CALL the AskUserQuestion tool:**

| Field | Value |
|-------|-------|
| question | "[claude-evolve] What technology stack?" |
| header | "Stack" |

| Label | Description |
|-------|-------------|
| TypeScript/Node | JavaScript ecosystem |
| Rust | Systems programming, performance |
| Python | Data, ML, scripting |
| Go | Cloud native, services |

These are common options — users can always select "Other" for any unlisted stack (e.g., Java, C#, Swift, Ruby).

### Step 8. Write Implementation Doc

After gathering requirements, create a concise spec file in the user's project.

**File placement:**
- **Greenfield project:** `SPEC.md` at project root
- **New feature in existing project:** `docs/specs/{feature-name}.md` (create `docs/specs/` if needed)
- **If a spec already exists** (from a prior build flow): Update it rather than creating a new one

**Doc format:**

```markdown
# {Project or Feature Name} — Spec

## Goal
{One sentence from goal answer}

## Technology Stack
{Stack from Step 7 or detected from existing project. Omit for non-code tasks.}

## Scope
**In scope:**
- {gathered requirements}

**Out of scope:**
- {explicitly excluded items, if discussed}

## Key Decisions
- {Architecture choices, trade-offs made during gathering}

## Requirements
- {Prioritized bullet list from all rounds}

## Acceptance Criteria
- [ ] {Concrete, verifiable condition from success criteria dimension}
- [ ] {Another testable condition — what "done" looks like}

## Status
- Phase: {current phase}
- Next: {what's coming}
```

**Keep this doc concise.** No bloat. This serves as the contract for what to build and persists across sessions. Store the spec path in task metadata (`spec_file`) so the workflow skill can find and update it.

### Step 9. Create Workflow Tasks with Dependencies

After gathering requirements, create native Claude Code tasks using TaskCreate.

**Parent task format:**
- `subject`: `[claude-evolve] Build: {brief project description}`
- `description`: Full gathered requirements + phase sequence for depth
- `activeForm`: `Working on {brief description}...`

**Required metadata fields:**

| Field | Value |
|-------|-------|
| `source` | `"build-project"` |
| `depth` | The depth from Step 4 |
| `phase` | First phase for the depth |
| `phases_done` | `""` (empty) |
| `phases_skipped` | `""` (empty) |
| `spec_file` | Path to spec doc from Step 8 |
| `has_phase_tasks` | `"true"` (only for `design`/`explore`) |

**Phase task creation by depth:**

| Depth | Phase Sequence | Task Structure |
|-------|---------------|----------------|
| `design` | requirements → design → implement → testing | Parent + 4 phase tasks with sequential blockedBy. First phase set to in_progress. |
| `explore` | research → prototype → evaluate → decide | Parent + 4 phase tasks with sequential blockedBy. First phase set to in_progress. |
| `plan` | action → outcome | Parent task only. Set status to in_progress. |
| `check` | verify | Parent task only. Set status to in_progress. |

Save the parent task ID for the handoff message.

**Note:** `execute` depth is not created by this skill — it's used for ad-hoc tasks created outside the build-project flow.

### Step 9b. Check Prepare-Task (Optional)

After creating tasks, check if prepare-task should run.

**Invoke** the `Skill` tool with skill: `prepare-task` when ALL are true:
- Depth is `design` or `explore`
- Task involves unfamiliar technology or domain
- Task scope is substantial

**Skip** when any of:
- Depth is `check` or `plan`
- Toolkit already has relevant coverage
- Domain is familiar

### Step 10. Present Summary and Suggest Approach

After creating tasks:

```markdown
## Summary

**Goal:** {goal}
**Stack:** {stack}
**Depth:** {depth}

### Key Requirements
- {requirement 1}
- {requirement 2}

### Spec
Written to `{spec path}` — this is your implementation contract.
```

**CALL the AskUserQuestion tool:**

| Field | Value |
|-------|-------|
| question | "[claude-evolve] How should we proceed?" |
| header | "Approach" |

| Label | Description |
|-------|-------------|
| Start working | Jump into execution |
| Plan first | Design the approach before starting |
| Research first | Investigate options first |

After the user answers, **CALL TaskUpdate** to store `metadata.req_approach` (e.g., `"start-working"`, `"plan-first"`, `"research-first"`).

### Step 11. Hand Off

Based on approach answer:

| Answer | Action |
|--------|--------|
| Start working | Begin execution, show handoff message |
| Plan first | Use `EnterPlanMode` tool, then invoke `Skill` tool with skill: "decompose-problem" |
| Research first | Invoke `Skill` tool with skill: "research-synthesize" |

**Always show handoff message after task creation:**

```
[claude-evolve] Workflow task created: {subject}. Spec written to {spec path}. Run /workflow to see phases and next steps.
```

See `${CLAUDE_PLUGIN_ROOT}/references/workflow-metadata-schema.md` for full metadata details.

## Output Branding

All output uses `[claude-evolve]` prefix:

```
[claude-evolve] Build: {context — e.g., "New project detected" or "Adding feature to existing project"}

Gathering requirements...
```

## References

- **Questions & Methodology:** `${CLAUDE_PLUGIN_ROOT}/skills/build-project/references/questions.md` — Core question templates and adaptive elicitation methodology
- **Examples:** `${CLAUDE_PLUGIN_ROOT}/skills/build-project/references/examples.md` — Walkthroughs for each depth including adaptive multi-round flow
