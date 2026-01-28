# Adaptive Requirements Gathering — Methodology Reference

This file teaches Claude HOW to gather requirements, not WHAT to ask. Questions emerge from the user's context and domain, not from templates. This methodology works for any domain — code, writing, research, design, ops.

## Tool Call Format

Every AskUserQuestion call uses this structure:

```json
{
  "questions": [
    {
      "question": "The question text with [claude-evolve] prefix",
      "header": "ShortLabel",
      "options": [
        {"label": "Option 1", "description": "What this option means"},
        {"label": "Option 2", "description": "What this option means"}
      ],
      "multiSelect": false
    }
  ]
}
```

**Constraints:**
- `header`: Max 12 characters
- `options`: 2-4 options per question (prefer 3 when one is "That covers it" — 2 real options + exit — though 4 is acceptable when all options add value)
- `questions`: 1-4 questions per call
- `multiSelect`: See dedicated section below
- Users can always select "Other" for free-text input

### Using multiSelect

Set `multiSelect: true` when choices are not mutually exclusive — e.g., "Which platforms should we support?" or "Which notification channels?".

**When to use:**
- The user could reasonably pick 2+ options (platforms, features, integrations)
- Options represent additive capabilities, not alternative approaches

**When NOT to use:**
- Options are mutually exclusive (architecture choice, storage backend)
- One option is "That covers it" — always single-select in that case

**Aggregation:** Treat all selected options as requirements. If the combination creates complexity (e.g., selecting all 4 platforms), flag it in the next round: "Supporting all 4 platforms significantly increases scope. Should we prioritize?"

---

## Core Structural Questions

These structural questions are the one prescribed part of the flow — they apply to every build flow regardless of domain. Everything else is adaptive. **This file is the single source of truth** for the canonical JSON format; `${CLAUDE_PLUGIN_ROOT}/skills/build-project/SKILL.md` references these structural questions directly.

### Primary Goal

```json
{
  "questions": [{
    "question": "[claude-evolve] What's your primary goal?",
    "header": "Goal",
    "options": [
      {"label": "Full implementation", "description": "Complete, production-ready feature"},
      {"label": "Core MVP", "description": "Essential functionality only"},
      {"label": "Prototype", "description": "Quick proof of concept"},
      {"label": "Exploration", "description": "Learn or investigate approaches"}
    ],
    "multiSelect": false
  }]
}
```

### Technology Stack (Greenfield only)

```json
{
  "questions": [{
    "question": "[claude-evolve] What technology stack?",
    "header": "Stack",
    "options": [
      {"label": "TypeScript/Node", "description": "JavaScript ecosystem"},
      {"label": "Rust", "description": "Systems programming, performance"},
      {"label": "Python", "description": "Data, ML, scripting"},
      {"label": "Go", "description": "Cloud native, services"}
    ],
    "multiSelect": false
  }]
}
```

### Guided Gathering Offer

Only shown for `design` (Full implementation) and `explore` (Exploration) depths. Skip for `plan` (Core MVP) and `check` (Prototype).

```json
{
  "questions": [{
    "question": "[claude-evolve] This looks like a substantial task. Use guided requirements gathering to cover all aspects before planning?",
    "header": "Gathering",
    "options": [
      {"label": "Thorough gathering (Recommended)", "description": "Multi-round adaptive questions to ensure nothing is missed"},
      {"label": "Quick start", "description": "Minimal questions, jump to building"}
    ],
    "multiSelect": false
  }]
}
```

### Approach (Post-Gathering)

Asked at Step 10, after the adaptive loop and spec doc creation — not during the initial questions.

```json
{
  "questions": [{
    "question": "[claude-evolve] How should we proceed?",
    "header": "Approach",
    "options": [
      {"label": "Start working", "description": "Jump into execution"},
      {"label": "Plan first", "description": "Design the approach before starting"},
      {"label": "Research first", "description": "Investigate options first"}
    ],
    "multiSelect": false
  }]
}
```

---

## Adaptive Elicitation Methodology

Everything below teaches Claude how to generate context-appropriate questions. No templates — just method.

### Coverage Dimensions

These are areas to check, not questions to ask. Use them as a mental checklist to identify what's unknown.

| Dimension | What to probe | Example probes (adapt to context) |
|-----------|--------------|-----------------------------------|
| **Scope & boundaries** | What it does, what it doesn't | "Should the notification system handle email, push, both, or something else?" |
| **Interactions** | Users, systems, inputs, outputs | "Who triggers the export — end users via UI, or an automated scheduler?" |
| **Data & state** | What's stored, formats, state transitions | "What data needs to persist between sessions — just preferences, or full history?" |
| **Structure** | Components, layers, data flow | "Should the parser produce an AST, a flat token list, or transformed output?" |
| **Dependencies** | External services, data, existing code | "Does this need to integrate with the existing auth middleware, or is it standalone?" |
| **Constraints** | Performance, compatibility, environment | "Is there a latency budget? Sub-second responses or batch-OK?" |
| **Security & access** | Authentication, authorization, data privacy | "Who should have access to this — all users, admins only, or role-based?" |
| **Success criteria** | What "done" looks like, verification | "How will you verify this works — specific test scenarios or user acceptance?" **Must be probed before stopping** — answers become the spec doc's `## Acceptance Criteria` checklist. |

**Not all dimensions apply to every task.** For non-code tasks (writing, research, design), Structure might mean "document outline" and Dependencies might mean "source material." Interpret the dimensions flexibly for non-code tasks, but keep the canonical dimension names listed above for consistent tracking.

#### Existing Project Considerations

When the task is a feature or change within an existing codebase, probe these additional areas — they often reveal hidden constraints:

- **Affected modules:** What existing code/modules does this touch? Are there shared utilities or abstractions to reuse?
- **Conventions:** Are there patterns, naming conventions, or architectural styles established in the codebase? (e.g., existing error handling patterns, state management approach)
- **Integration surface:** What's the boundary with existing functionality? Are there APIs, event systems, or shared state that the new feature must integrate with?
- **Test infrastructure:** What testing patterns exist? (unit test framework, integration test setup, fixtures, mocks) Does the new feature require new test categories?
- **Migration & rollout:** Does this change require data migration, backwards compatibility, or feature flags? Are there observability requirements (logging, metrics, alerts)?

### How to Formulate Good Questions

1. **Start from the user's words.** If they said "real-time dashboard," ask about real-time requirements, not generic "what type of app?"
2. **Reference existing context.** If you detected a React project, don't ask "what framework?" — ask "should this be a new route or embedded in an existing page?"
3. **Be specific, not generic.** "How should the retry logic handle partial failures?" beats "What about error handling?"
4. **Offer concrete options.** Each option should represent a real design choice, not vague categories. Options should reflect what's actually plausible for this task.
5. **Combine related questions.** Use multi-question calls (up to 4) when questions are independent but related to the same area.
6. **Skip what you know.** If the stack is detected, don't ask about it. If the user described the architecture, don't re-ask.
7. **Order questions by importance.** Within a multi-question call, put the highest-impact question first — the one whose answer most affects subsequent decisions.

### Handling Free-Text ("Other") Responses

AskUserQuestion automatically includes an "Other" option that lets users type free text. When a user provides free-text input:

- Treat it as a new requirement or constraint — incorporate it into your understanding
- If the free text is ambiguous or vague (e.g., "make it scalable"), ask a follow-up in the next round to clarify what that means concretely
- If it contradicts a previous answer, surface the contradiction (see below)
- If it reveals significant new scope (e.g., "I also need SSO support"), extend the loop even if the minimum round count has been met — do not stop until the new scope is covered
- If it pre-answers a question you planned to ask later, skip that question — don't re-ask what the user already told you
- If it's off-topic or unclear (e.g., "make it cool"), acknowledge briefly and redirect to the next coverage dimension
- Map free-text answers to coverage dimensions where possible. "I also need SSO support" covers Security & access. "It needs to work offline" covers Constraints

### Handling Contradictions

If a user's answer in a later round contradicts an earlier one (e.g., "small scale" in Round 1 but describing requirements that imply large scale in Round 2), surface it gently:

```
"Earlier you mentioned small scale, but the alert volume you're describing suggests
something larger. Should we plan for growth, or keep it small for now?"
```

Include this as a question in the next round with concrete options representing each direction:

```json
{
  "questions": [{
    "question": "[claude-evolve] Earlier you mentioned small scale, but the alert volume suggests something larger. How should we plan?",
    "header": "Scale",
    "options": [
      {"label": "Plan for growth", "description": "Design for larger scale from the start"},
      {"label": "Keep it small", "description": "Optimize for current needs only"},
      {"label": "Start small, migrate", "description": "Simple now with a migration path"}
    ],
    "multiSelect": false
  }]
}
```

### Round Progression

**Round 1** — Focus on the biggest unknowns: scope, core behavior, main interactions. These are always derivable from the user's initial description.

**Round 2+** — Each subsequent round should:
- Build on what was just learned (reference specific answers)
- Cover dimensions not yet addressed
- Go deeper where answers revealed complexity
- Include a "That covers it" option to allow early exit

**Early exit option (round 2+):**
```json
{
  "questions": [{
    "question": "[claude-evolve] {next question derived from context}",
    "header": "{Label}",
    "options": [
      {"label": "{Option A}", "description": "{...}"},
      {"label": "{Option B}", "description": "{...}"},
      {"label": "That covers it", "description": "Enough detail to start planning"}
    ],
    "multiSelect": false
  }]
}
```

### Between-Round Acknowledgment

After each round, briefly acknowledge what was learned before asking the next round. Keep this to 1-2 sentences — summarize key decisions, then transition naturally to the next area. Don't re-list everything.

Example acknowledgments:
- "Socket.io for real-time, SendGrid for email. Let me clarify the data model:"
- "SQL dialect conversion with streaming for medium datasets. A few structural decisions:"
- "Browser-targeted WASM with JS interop. Let me understand the scope:"
- "'Scalable architecture' noted — I'll explore what that means concretely. Meanwhile, let me nail down the data model:"

### Example: Adaptive Rounds in Action

**User:** "Let's build a CLI tool that migrates data between database formats"

**Round 1** (Scope + Dependencies — the biggest unknowns; "Formats" first because it most affects all subsequent decisions):
```json
{
  "questions": [
    {
      "question": "[claude-evolve] Which database formats need to be supported?",
      "header": "Formats",
      "options": [
        {"label": "SQL dialects", "description": "PostgreSQL, MySQL, SQLite conversions"},
        {"label": "SQL to NoSQL", "description": "Relational to document/key-value"},
        {"label": "File formats", "description": "CSV, JSON, Parquet to database"},
        {"label": "Custom schema", "description": "Proprietary or domain-specific format"}
      ],
      "multiSelect": false
    },
    {
      "question": "[claude-evolve] How large are the datasets being migrated?",
      "header": "Scale",
      "options": [
        {"label": "Small", "description": "Fits in memory, under 1GB"},
        {"label": "Medium", "description": "Needs streaming, 1-100GB"},
        {"label": "Large", "description": "Distributed processing, 100GB+"}
      ],
      "multiSelect": false
    }
  ]
}
```

*User selects: "SQL dialects" and "Medium"*

**Acknowledgment:** "SQL dialect conversion with streaming for medium datasets. Let me clarify a few structural decisions:"

**Round 2** (Structure + Constraints — informed by Round 1):
```json
{
  "questions": [
    {
      "question": "[claude-evolve] Should the CLI handle schema migration (DDL) as well as data migration (DML)?",
      "header": "Scope",
      "options": [
        {"label": "Both", "description": "Migrate schema and data together"},
        {"label": "Data only", "description": "Assume target schema already exists"},
        {"label": "Schema only", "description": "Generate DDL, user handles data"}
      ],
      "multiSelect": false
    },
    {
      "question": "[claude-evolve] How should it handle migration failures mid-stream?",
      "header": "Failures",
      "options": [
        {"label": "Transactional", "description": "All-or-nothing with rollback"},
        {"label": "Checkpoint", "description": "Resume from last successful batch"},
        {"label": "Skip & log", "description": "Continue, report failures at end"},
        {"label": "That covers it", "description": "Enough detail to start planning"}
      ],
      "multiSelect": false
    }
  ]
}
```

### Minimum Rounds by Depth

See `${CLAUDE_PLUGIN_ROOT}/skills/build-project/SKILL.md` Step 6 for the authoritative table. In short: `design`/`explore` need 2+ rounds, `plan` needs 1+, `check` needs 0+ (usually 1 suffices). Stop when you can confidently write a comprehensive plan — not at a fixed round count.

---

## Depth-Based Elicitation Summary

| Depth | Flow |
|-------|------|
| `check` (Prototype) | Goal → 0-1 adaptive rounds → spec doc + workflow tasks |
| `plan` (Core MVP) | Goal → 1+ adaptive rounds → spec doc + workflow tasks |
| `design` (Full implementation) | Goal → guided offer → 2+ adaptive rounds → spec doc + workflow tasks |
| `explore` (Exploration) | Goal → guided offer → 2+ adaptive rounds → spec doc + workflow tasks |

All flows end with spec doc creation (`${CLAUDE_PLUGIN_ROOT}/skills/build-project/SKILL.md` Step 8) and workflow task setup (`${CLAUDE_PLUGIN_ROOT}/skills/build-project/SKILL.md` Step 9).
