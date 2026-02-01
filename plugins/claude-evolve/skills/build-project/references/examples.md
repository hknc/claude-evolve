# Build Project Examples

Walkthroughs showing how the build-project skill flows for each depth.

## Example 1: "Build me a task manager CLI" (plan depth, greenfield)

```
User: "Build me a CLI task manager"

[claude-evolve] Build: New project detected

[Context check: empty directory, no existing structure]

-> AskUserQuestion tool called with goal question
-> User selects "Core MVP"

[Depth: plan — 1+ adaptive rounds, no guided offer]

--- Adaptive Round 1 (Scope + Interactions) ---

Claude analyzes: User wants a "CLI task manager." Unknowns: what operations
it supports, storage mechanism, single-user vs shared.

-> AskUserQuestion with 2 questions:
   1. "[claude-evolve] What operations should the task manager support?"
      (header: "Operations")
      Options: [CRUD basics, Priority + due dates, Projects + tags, Kanban workflow]
   2. "[claude-evolve] Where should tasks be stored?"
      (header: "Storage")
      Options: [Local file (JSON/YAML), SQLite database, Cloud-synced, Git-backed]

-> User selects: "Priority + due dates" and "Local file (JSON/YAML)"

Claude acknowledges: "Task CRUD with priorities and due dates, stored locally as
JSON. That's enough for an MVP — let me set things up."

[Stop: plan depth, 1 round complete, domain decisions clear — stack still pending]

-> AskUserQuestion: "[claude-evolve] What technology stack?"
-> User selects "Rust"

-> Spec doc written to SPEC.md

-> TaskCreate called with:
   subject: "[claude-evolve] Build: Rust CLI task manager"
   metadata: {source: "build-project", depth: "plan", phase: "action",
              spec_file: "SPEC.md", ...}
-> TaskUpdate called to set status: "in_progress"

[claude-evolve] Summary:
- Goal: Core MVP
- Feature: CLI task manager with priorities, due dates, local JSON storage
- Stack: Rust
- Depth: plan

-> AskUserQuestion tool called with approach question [Step 10]
-> User selects "Start working"

-> TaskUpdate called with metadata: {req_approach: "start-working"}

[claude-evolve] Workflow task created: Rust CLI task manager.
Spec written to SPEC.md. Run /workflow to see phases and next steps.

-> Begin execution: start implementing task CRUD with priorities [Step 11]
```

**Key observations:**
- User prompt ("CLI task manager") drove the questions — operations and storage are the natural unknowns for a CLI tool
- Plan depth needed only 1 round — both key decisions (operations + storage) were resolved
- Technology stack was asked because this is greenfield [Step 7]
- Spec doc placed at root (`SPEC.md`) since this is a new project [Step 8]
- "Start working" approach → directly begin execution [Step 11]

## Example 2: "Add real-time notifications" (design depth, existing project, adaptive flow)

This shows the full adaptive elicitation loop for a feature in an existing codebase.

```
User: "Add real-time notifications to our app"

[claude-evolve] Build: Adding feature to existing project

[Context check: package.json found, TypeScript/React project, Express backend,
 src/ structure exists]

-> AskUserQuestion tool called with goal question
-> User selects "Full implementation"

[Depth: design — guided gathering offered]

-> AskUserQuestion: "This looks like a substantial task. Use guided requirements
   gathering to cover all aspects before planning?"
-> User selects "Thorough gathering (Recommended)"

--- Adaptive Round 1 (Scope + Interactions) ---

Claude analyzes: User wants "real-time notifications" in a React/TS app.
Unknowns: notification types, delivery channels, what triggers them.

-> AskUserQuestion with 3 questions:
   1. "[claude-evolve] What events should trigger notifications — user actions,
      system events, or external webhooks?" (header: "Triggers")
      Options: [User actions, System events, External webhooks, All of the above]
   2. "[claude-evolve] Should notifications appear in-app only, or also via
      email/push?" (header: "Channels")
      Options: [In-app only, In-app + email, In-app + push, All channels]
   3. "[claude-evolve] Do users need to configure which notifications they
      receive?" (header: "User control")
      Options: [Yes, full preferences, Basic on/off per type, No, everyone gets all]

-> User: "System events + user mentions" (via Other), "In-app + email", "Yes, full preferences"

Claude acknowledges: "System events and mentions, delivered in-app and via email,
with user preference controls. Let me dig into the technical side:"

--- Adaptive Round 2 (Structure + Dependencies) ---

Claude analyzes: Now knows triggers and channels. Unknowns: real-time tech,
integration with existing backend, email service.

[Claude reasons: Express backend detected + real-time requirement → WebSocket
vs SSE is the key architectural decision. Email channel selected → need to know
if email service exists or must be set up.]

-> AskUserQuestion with 2 questions + early exit:
   1. "[claude-evolve] Your app uses Express — should we add WebSocket support
      (Socket.io) or use Server-Sent Events for real-time delivery?"
      (header: "Real-time")
      Options: [Socket.io, Server-Sent Events, That covers it]
   2. "[claude-evolve] Is there an existing email service, or should we set one
      up?" (header: "Email")
      Options: [Already have one, Need to set up, Skip email for now, That covers it]

-> User: "Socket.io", "We use SendGrid already" (via Other)

Claude acknowledges: "Socket.io for real-time, SendGrid for email. One more area:"

--- Adaptive Round 3 (Data & state + Success criteria) ---

Claude analyzes: Core architecture decided. Remaining unknowns: persistence model
and success criteria (must be probed before stopping per SKILL.md).

[Claude reasons: Express backend + Socket.io decided → persistence is the last
structural unknown. Success criteria needed for acceptance criteria checklist.]

-> AskUserQuestion with 2 questions + early exit:
   1. "[claude-evolve] Should notifications persist in a database for history,
      or are they ephemeral?" (header: "Persistence")
      Options: [Persist with read/unread state, Ephemeral (gone after viewed),
               Keep last 30 days]
   2. "[claude-evolve] How will you verify notifications work correctly?"
      (header: "Verification")
      Options: [Users receive within 5 seconds, Email delivery confirmed,
               Preference toggles work, That covers it]

-> User: "That covers it" for both (exits early)

[User exited early — persistence TBD, but verification criteria captured from
question framing: real-time delivery + email + preferences. These become the
spec doc's Acceptance Criteria checklist.]

-> Spec doc written to docs/specs/real-time-notifications.md

-> TaskCreate (parent) called with:
   subject: "[claude-evolve] Build: Real-time notification system"
   description: includes all gathered requirements
   metadata: {source: "build-project", depth: "design", phase: "requirements",
              has_phase_tasks: "true", spec_file: "docs/specs/real-time-notifications.md", ...}

-> Phase tasks created:
   Phase 1: Requirements (in_progress)
   Phase 2: Design (blockedBy Phase 1)
   Phase 3: Implement (blockedBy Phase 2)
   Phase 4: Testing (blockedBy Phase 3)

[claude-evolve] Summary:
- Goal: Full implementation
- Feature: Real-time notification system
- Stack: TypeScript/React (detected) + Socket.io + SendGrid
- Key decisions: WebSocket via Socket.io, email via SendGrid, user preference
  controls, persistence TBD (user exited before answering)
- Depth: design

[Step 9b: Depth is design — check prepare-task criteria. Tech (React/Socket.io)
is familiar, toolkit has coverage → prepare-task skipped]

-> AskUserQuestion tool called with approach question [Step 10]
-> User selects "Plan first"

-> TaskUpdate called with metadata: {req_approach: "plan-first"} [Step 10]

[claude-evolve] Workflow task created. Spec written to docs/specs/real-time-notifications.md.
Run /workflow to see phases and next steps.
[claude-evolve] Entering plan mode for design-first approach.

-> EnterPlanMode tool called, then Skill tool invoked with skill: "decompose-problem" [Step 11]
```

**Key observations:**
- Questions emerged from the user's description ("real-time notifications") and detected context (React/TS, Express)
- No domain templates were used — each question referenced specific project details
- Round 2 referenced Round 1 answers (Socket.io question based on knowing it's a JS backend)
- Round 3 focused on data & state — Claude explicitly noted which dimensions were lower priority and why
- **Stop condition reasoning:** After Round 3, Scope (triggers, channels), Interactions (preferences), Structure (Socket.io, SendGrid), and Dependencies (Express backend) were all covered. User's "That covers it" confirmed remaining gap (persistence) was acceptable as TBD — sufficient coverage to write a confident plan
- User selected "Other" for free-text responses where predefined options didn't fit exactly
- Step 9b checked prepare-task criteria: design depth but familiar tech → skipped
- "Plan first" approach → EnterPlanMode + decompose-problem [Step 11]
- Spec file placed in `docs/specs/` since this is a feature in an existing project

## Example 3: "Quick prototype of a markdown previewer" (check depth, minimal flow)

```
User: "Quick prototype — I want to see if a live markdown previewer works in the terminal"

[claude-evolve] Build: Starting prototype

[Context check: existing Rust project with Cargo.toml, src/ structure exists]

-> AskUserQuestion tool called with goal question
-> User selects "Prototype"

[Depth: check — 0-1 rounds, no guided offer]

--- Adaptive Round 1 (optional, Scope) ---

Claude analyzes: User wants a "live markdown previewer in the terminal."
The description is specific enough — the one key unknown is rendering approach.

-> AskUserQuestion with 1 question:
   1. "[claude-evolve] For the terminal rendering, should we try full ANSI
      styling (bold, colors, indentation) or plain text with minimal
      formatting?" (header: "Rendering")
      Options: [Full ANSI styling, Plain text + headers, Side-by-side raw/rendered]

-> User selects "Full ANSI styling"

Claude acknowledges: "Full ANSI-styled markdown preview in the terminal. Let's prototype."

[Stop: check depth, core question answered]

-> Spec doc written to SPEC.md (brief — just goal, rendering approach, and verify step)

-> TaskCreate called with:
   subject: "[claude-evolve] Build: Terminal markdown previewer prototype"
   metadata: {source: "build-project", depth: "check", phase: "verify",
              spec_file: "SPEC.md", ...}
-> TaskUpdate called to set status: "in_progress"

[claude-evolve] Summary:
- Goal: Prototype
- Focus: Live markdown preview with full ANSI styling in terminal
- Stack: Rust (detected)

-> AskUserQuestion tool called with approach question [Step 10]
-> User selects "Start working"

-> TaskUpdate called with metadata: {req_approach: "start-working"}

[claude-evolve] Workflow task created: Terminal markdown previewer prototype.
Spec written to SPEC.md. Run /workflow to see phases and next steps.

[claude-evolve] Prototype mode — let's build fast and validate.

-> Begin execution: start prototyping ANSI markdown renderer [Step 11]
```

**Key observations:**
- Only 1 adaptive round needed — the user's description was already specific [Step 6]
- The question targeted the one genuinely ambiguous aspect (rendering approach)
- Stack was detected (Rust project), so no stack question was asked [Step 7 skipped]
- Spec doc is brief for check depth — just enough to remember what was prototyped [Step 8]
- Approach question still asked — even prototypes benefit from choosing how to start [Step 10]
- "Start working" approach → begin execution directly [Step 11]

## Example 4: "Let's explore WASM compilation for our parser" (explore depth, research-first)

```
User: "Let's explore whether we can compile our Rust parser to WASM for the frontend"

[claude-evolve] Build: Exploration mode

[Context check: existing Rust project with Cargo.toml, src/parser/ module exists]

-> AskUserQuestion tool called with goal question
-> User selects "Exploration"

[Depth: explore — guided gathering offered]

-> AskUserQuestion: "This looks like a substantial task. Use guided requirements
   gathering to cover all aspects before planning?"
-> User selects "Thorough gathering (Recommended)"

--- Adaptive Round 1 (Scope + Constraints) ---

Claude analyzes: User wants to explore compiling their Rust parser to WASM.
Unknowns: target environment, what API surface to expose, performance needs.

-> AskUserQuestion with 2 questions:
   1. "[claude-evolve] Is the WASM target for browser use, server-side
      (Node/Deno), or both?" (header: "Target")
      Options: [Browser only, Node/Deno, Both, Unsure yet]
   2. "[claude-evolve] What's the main goal — raw performance, portability
      across platforms, or JS interop with your existing frontend?"
      (header: "Goal")
      Options: [Performance, Portability, JS interop, All equally]

-> User: "Browser only", "JS interop with existing frontend"

Claude acknowledges: "Browser-targeted WASM with JS interop for the frontend.
Let me understand the scope:"

--- Adaptive Round 2 (Structure + Dependencies) ---

Claude analyzes: Now knows target (browser) and goal (JS interop). Unknowns:
API surface breadth, compatibility with existing parser internals, build tooling.

-> AskUserQuestion with 2 questions + early exit:
   1. "[claude-evolve] Should the WASM module expose the full parser API or a
      simplified subset for common operations?" (header: "API scope")
      Options: [Full API, Simplified subset, Start minimal and expand,
               That covers it]
   2. "[claude-evolve] Does your parser have any dependencies that might not
      compile to WASM (system calls, file I/O, threading)?"
      (header: "Blockers")
      Options: [Uses file I/O, Uses threading, Pure computation,
               Not sure — need to check]

-> User: "Start minimal and expand", "Not sure — need to check"

Claude acknowledges: "Minimal API surface initially, with potential compatibility
blockers to investigate. That's a clear exploration scope."

[Stop: 2 rounds complete, exploration boundaries well-defined.
The "not sure" answer confirms this needs research before decisions.]

-> Spec doc written to docs/specs/wasm-exploration.md

-> TaskCreate (parent):
   subject: "[claude-evolve] Build: WASM compilation exploration"
   description: includes all gathered info + explicit unknowns to research
   metadata: {depth: "explore", phase: "research", has_phase_tasks: "true",
              spec_file: "docs/specs/wasm-exploration.md", ...}

-> Phase tasks created:
   Phase 1: Research (in_progress) — investigate WASM compatibility of parser deps
   Phase 2: Prototype (blockedBy Phase 1) — minimal WASM build + JS bindings
   Phase 3: Evaluate (blockedBy Phase 2) — test in browser, measure bundle size
   Phase 4: Decide (blockedBy Phase 3) — commit to WASM or choose alternative

[claude-evolve] Summary:
- Goal: Exploration
- Focus: WASM compilation of Rust parser for browser JS interop
- Key unknowns: dependency compatibility, optimal API surface
- Stack: Rust (detected)
- Depth: explore

-> AskUserQuestion tool called with approach question [Step 10]
-> User selects "Research first"

-> TaskUpdate called with metadata: {req_approach: "research-first"}

[claude-evolve] Workflow task created: WASM compilation exploration.
Spec written to docs/specs/wasm-exploration.md.
Run /workflow to see phases and next steps.

[claude-evolve] Starting research phase.
-> Invoking Skill tool with skill: "research-synthesize" [Step 11]
```

**Key observations:**
- User's "Not sure" answer in Round 2 confirmed this is genuinely exploratory — it shaped the Research phase description
- Questions referenced the existing codebase (parser module, potential dependency blockers)
- Between-round acknowledgment summarized key info before transitioning
- Explore-depth phases (Research → Prototype → Evaluate → Decide) differ from design-depth phases
- Phase descriptions are specific to what was gathered (e.g., "investigate WASM compatibility of parser deps")
- Spec doc includes explicit unknowns — for exploration, documenting what you don't know is as important as what you do
- Two rounds were sufficient here because the exploration boundaries were clear. A more open-ended exploration (e.g., "explore ML options for our pipeline") might need 3+ rounds to narrow scope

## Example 5: "Write a technical blog post series" (plan depth, non-code task)

```
User: "I want to create a technical blog post series about system design"

[claude-evolve] Build: Non-code task detected

[Context check: no code signals — this is a writing task]

-> AskUserQuestion tool called with goal question
-> User selects "Core MVP"

[Depth: plan — 1+ adaptive rounds, no guided offer]

--- Adaptive Round 1 (Scope + Interactions) ---

Claude analyzes: User wants a "technical blog post series about system design."
Unknowns: audience level, specific topics, publication cadence, target platform.

-> AskUserQuestion with 2 questions:
   1. "[claude-evolve] Who is the target audience?" (header: "Audience")
      Options: [Junior developers, Mid-level engineers, Senior/Staff engineers, Mixed levels]
   2. "[claude-evolve] How many posts in the series?" (header: "Scope")
      Options: [3-5 focused posts, 6-10 comprehensive series,
               Ongoing/open-ended]

-> User: "Mid-level engineers", "3-5 focused posts"

Claude acknowledges: "A focused 3-5 post series on system design for mid-level
engineers. Let me set things up."

[Stop: plan depth, 1 round complete, scope is clear]

-> Spec doc written to SPEC.md

-> TaskCreate called with:
   subject: "[claude-evolve] Build: System design blog series"
   metadata: {source: "build-project", depth: "plan", phase: "action",
              spec_file: "SPEC.md", ...}
-> TaskUpdate called to set status: "in_progress"

[claude-evolve] Summary:
- Goal: Core MVP
- Focus: 3-5 post system design series for mid-level engineers
- Depth: plan

-> AskUserQuestion tool called with approach question [Step 10]
-> User selects "Plan first"

-> TaskUpdate called with metadata: {req_approach: "plan-first"}

[claude-evolve] Workflow task created: System design blog series.
Spec written to SPEC.md. Run /workflow to see phases and next steps.

-> EnterPlanMode tool called, then Skill tool invoked with skill: "decompose-problem" [Step 11]
```

**Key observations:**
- Non-code task — Step 2 (project detection) and Step 7 (stack) were skipped entirely
- Questions used domain-appropriate language: "audience" and "posts" instead of code terminology
- Coverage dimensions still applied: Scope (post count), Interactions (audience), Structure (series format)
- Same flow structure as code tasks — the methodology is domain-agnostic [Step 6]
- "Plan first" approach → EnterPlanMode + decompose-problem [Step 11]

## Example 6: Quick start path (design depth, skipping adaptive loop)

This mini-example shows what happens when a user opts out of thorough gathering.

```
User: "Add a dark mode toggle to our React app"

[claude-evolve] Build: Adding feature to existing project

[Context check: package.json found, TypeScript/React project]

-> AskUserQuestion tool called with goal question
-> User selects "Full implementation"

[Depth: design — guided gathering offered]

-> AskUserQuestion: "This looks like a substantial task. Use guided requirements
   gathering to cover all aspects before planning?"
-> User selects "Quick start"

[Quick start: skip adaptive loop, go directly to spec doc]

-> Spec doc written to docs/specs/dark-mode-toggle.md
   (brief — goal: "Full implementation of dark mode toggle", scope: "Dark mode
   for React app", no gathered details yet — to be fleshed out during
   requirements phase)

-> TaskCreate + phase tasks created as usual
-> TaskUpdate called to set status: "in_progress"

[claude-evolve] Summary:
- Goal: Full implementation
- Feature: Dark mode toggle
- Stack: TypeScript/React (detected)
- Depth: design (quick start — minimal requirements gathered)

-> AskUserQuestion tool called with approach question [Step 10]
-> User selects "Start working"

-> TaskUpdate called with metadata: {req_approach: "start-working"}

[claude-evolve] Workflow task created: Dark mode toggle.
Spec written to docs/specs/dark-mode-toggle.md.
Run /workflow to see phases and next steps.

-> Begin execution: start implementing dark mode toggle [Step 11]
```

**Key observations:**
- User chose "Quick start" at Step 5 — no adaptive rounds were run [Step 6 skipped]
- Spec doc is minimal (just the initial description), to be fleshed out during requirements phase [Step 8]
- Phase tasks still created — the workflow phases provide structure even without deep gathering [Step 9]
- The requirements phase will naturally prompt for more detail during execution
- "Start working" approach → begin execution directly [Step 11]

## Paths Not Shown

These examples cover the most common flows. Other paths that follow the same methodology:

- **Greenfield + design depth:** A new project with "Full implementation" goal — combines Example 1's greenfield stack question with Example 2's multi-round adaptive flow and phase task creation.
- **Contradiction handling:** When a later answer conflicts with an earlier one, Claude surfaces the contradiction as a question in the next round (see `${CLAUDE_PLUGIN_ROOT}/skills/build-project/references/questions.md` for the method).
- **Multi-select questions:** When choices aren't mutually exclusive (e.g., "Which platforms?"), `multiSelect: true` allows selecting multiple options (see `${CLAUDE_PLUGIN_ROOT}/skills/build-project/references/questions.md` multiSelect section).
- **Prepare-task integration:** For `design`/`explore` depth with unfamiliar technology, Step 9b invokes prepare-task to check toolkit coverage before the summary.
- **Existing spec update:** When a prior build flow already created a spec doc, Step 8 updates it rather than creating a new one.
- **Research first on non-explore depth:** Any depth can select "Research first" at Step 10 — the action (invoke `research-synthesize`) is the same regardless of depth. Example 4 shows this on `explore`, but it works identically on `design` or `plan`.
