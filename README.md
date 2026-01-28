<div align="center">

# 🧬 claude-evolve

**v1.1.47** · Self-improving toolkit for Claude Code

*learns · reflects · guides · grows*

</div>

A plugin that builds persistent knowledge from your sessions. Claude Code gets better at working with you over time by accumulating observations, synthesizing patterns, and converting insights into reusable components.

**Completely unopinionated.** Works with any domain—coding, writing, research, design, ops. Your patterns, your rules.

## Quick Start

```bash
# Install claude-evolve
/plugin marketplace add hknc/claude-evolve
/plugin install claude-evolve@claude-evolve

# Recommended: better /learn components
/plugin marketplace add anthropics/claude-plugins-official
/plugin install plugin-dev@claude-plugins-official

# Restart Claude Code

# Initialize your toolkit
/evolve init
```

## Features

- [Workflow Guides](#workflow-guides) — depth-aware phases, build flow, sub-task creation
- [Built-in Skills](#built-in-skills) — 13 progressive-disclosure skills for problem-solving, analysis, and knowledge work
- [Toolkit Preparation](#toolkit-preparation) — gap analysis and component recommendations before complex tasks
- [Agents](#agents) — 9 specialized agents for decisions, risk, progress, and more
- [Signal-Based Learning](#signal-based-learning) — automatic insight capture and extraction into reusable components
- [Cross-Machine Sync](#cross-machine-sync) — git-backed toolkit sharing across machines

### Workflow Guides

Depth-aware workflow management using native Claude Code tasks. No state files — uses TaskCreate/TaskUpdate/TaskList.

Say **"let's build"**, **"create this"**, or **"new feature"** to start a guided build flow:

1. **Context detection** — greenfield vs existing project, detect stack and conventions
2. **Goal gathering** — full implementation, MVP, prototype, or exploration
3. **Guided gathering** — for complex tasks, adaptive multi-round requirements elicitation
4. **Spec doc creation** — writes an implementation contract (`SPEC.md` or `docs/specs/{feature}.md`)
5. **Task creation** — parent task with phase metadata, blockedBy dependencies, and spec reference
6. **Approach choice** — start building, plan first, or research first

Task complexity is assessed automatically and mapped to a workflow depth:

| Depth | When | Phases |
|-------|------|--------|
| `execute` | All low | No phases — just do it |
| `check` | Mixed low | verify |
| `plan` | Mixed medium | action → outcome |
| `design` | Multiple high | requirements → design → implement → testing |
| `explore` | High stakes + unclear | research → prototype → evaluate → decide |

Manage your active workflow with `/workflow`:

```
/workflow          → show current phase and progress
/workflow next     → advance to next phase
/workflow skip     → skip current phase
/workflow done     → complete workflow
/workflow switch   → switch between workflows
/workflow expand   → create sub-tasks from phase items
```

When a phase has 3+ items, sub-tasks are created automatically with intelligent dependency analysis:

| Pattern Detected | Dependency Strategy |
|-----------------|-------------------|
| "then", "after", "Step 1 → Step 2" | Sequential (each blocked by previous) |
| "independently", "in parallel" | Parallel (all blocked by parent only) |
| "depends on", "requires" | Explicit (parsed from text) |
| Default | Sequential (safer) |

When a project has insufficient context (new project with few or no files), the workflow recommends doing deep research first using Claude on the web (claude.ai) or the desktop app, then dropping the research report into the project folder (e.g., `research.md`). This gives Claude Code the context it needs to produce substantially better results, especially for `design`/`explore` depths.

Hooks nudge task creation at key moments — after plan approval and after context clear — so structure is maintained throughout your session.

### Built-in Skills

Skills load progressively — only when triggered, keeping context focused.

| Skill | Triggers | What It Does |
|-------|----------|--------------|
| `build-project` | "let's build", "create this", "new project" | Guided requirements gathering and project scaffolding |
| `workflow` | "/workflow", "what phase am I on" | Phase management for active workflows |
| `prepare-task` | "/evolve prepare", "check toolkit gaps" | Gap analysis and component recommendations |
| `compare-options` | "compare X vs Y", "pros and cons" | Structured tradeoff analysis |
| `root-cause-analysis` | "why does this happen", "find root cause" | Systematic diagnosis (5 Whys, Fishbone, etc.) |
| `decompose-problem` | "break this down", "where do I start" | Break complex problems into manageable pieces |
| `explain-step-by-step` | "explain", "walk through" | Progressive explanation of complex concepts |
| `summarize-efficiently` | "summarize", "tl;dr", "key points" | Extract essentials while preserving context |
| `verify-completion` | "am I done", "before I commit" | Systematic check of requirements and edge cases |
| `research-synthesize` | "research", "investigate" | Multi-source research and synthesis |
| `learn` | "extract learnings", "save what we learned" | Extract session insights into toolkit components |
| `evolve` | "/evolve", "manage toolkit" | Toolkit management and signal flagging |
| `setup-audit` | "audit my setup", "review config" | Audit and optimize Claude Code configuration |

### Toolkit Preparation

`/evolve prepare` runs gap analysis before complex tasks:

1. **Assesses task depth** from complexity signals
2. **Discovers toolkit capabilities** — existing agents, skills, rules
3. **Identifies gaps** — missing coverage for task requirements
4. **Detects artifact patterns** — learned habits (TDD, specs, docs) from understanding.md
5. **Recommends components** — only when significant and reusable
6. **Creates components** (if approved) — using plugin-dev for best practices

Filtering is depth-aware:
- `execute`/`check`: Skip entirely ("no toolkit gaps to address")
- `plan`: Only recommend high-severity, clearly reusable gaps
- `design`/`explore`: Full gap analysis + artifact suggestions + workflow guidance

### Agents

9 specialized agents handle complex operations autonomously:

| Agent | Purpose |
|-------|---------|
| `evolve-toolkit-manager` | Initialize, migrate, release, switch toolkits |
| `evolve-learning-extractor` | Convert signals to agents/skills/rules |
| `evolve-reflection-agent` | Synthesize observations into understanding |
| `evolve-guidance-agent` | Proactive guidance, workflow coaching |
| `evolve-setup-auditor` | Audit config, consolidate, apply learnings |
| `evolve-context-detector` | Analyze projects, match available agents |
| `evolve-decision-advisor` | Structured decision analysis with tradeoffs |
| `evolve-risk-assessor` | Identify risks before executing plans |
| `evolve-progress-tracker` | Track progress on multi-session tasks |

## How Learning Works

### Signal-Based Learning

Claude flags insights as they occur — you can also flag manually:

```
SessionStart → loads understanding
        ↓
┌─────────────────────────────────────────────────┐
│              CONVERSATION LOOP                  │
│                                                 │
│   CLAUDE FLAGS (automatic):                     │
│     • You correct Claude's approach             │
│     • Root cause diagnosed                      │
│     • Key insight emerges                       │
│                                                 │
│   YOU FLAG (optional):                          │
│     /evolve signal "discovered pattern"         │
│                                                 │
│                    ↺                            │
└─────────────────────────────────────────────────┘
        ↓
Stop hook → saves observations + suggests /learn (when signals exist)
```

| Claude Does | You Control |
|-------------|-------------|
| Flags corrections & insights during chat | `/evolve signal` - flag additional insights |
| Loads understanding at session start | `/learn` - extract signals to components |
| Stop hook saves observations when signals exist | `/reflect` - synthesize into understanding |
| Assesses complexity during build/prepare flows | `/evolve prepare` - check toolkit gaps |
| Nudges task creation after plan | `/workflow` - manage phases |

### Why Meta-Components?

claude-evolve ships **meta agents and skills that create your personalized components** — enforcing best practices, then consolidating patterns from sessions and refining over time.

| Templates | Learned Components |
|-----------|-------------------|
| Generic, one-size-fits-all | Shaped by your patterns |
| Static, never improve | Evolve from corrections |
| Same for everyone | Unique to how you work |
| Guessing what's useful | Built from real needs |

Your toolkit starts empty. As you work:
- `/evolve signal` when you discover something → flags for capture
- `/learn` extracts flagged insights → creates agents/skills/rules
- Session corrections → captured as signals, converted to rules via `/learn`
- Repeated patterns → refined into reusable components

**Result:** A toolkit that fits like a glove and keeps fitting better.

### Progressive Disclosure

Skills and agents load only when relevant, not all at once.

**Why this matters:** LLM context windows are precious. Loading 50 skills upfront = noise drowning signal. Loading 1 relevant skill = Claude understands deeply.

**How it works:**
1. Skills have trigger patterns (e.g., "debug", "compare X vs Y")
2. Agents have descriptions matched to task types
3. When triggered, full content loads into context
4. After task, context returns to baseline

## Commands

### Learning

| Command | Purpose |
|---------|---------|
| `/evolve signal` | Flag insight for `/learn` capture (Claude does this automatically too) |
| `/learn` | Extract flagged signals → agents/skills/rules |
| `/reflect` | Synthesize observations → understanding.md |
| `/evolve understanding` | View your learned patterns |

### Workflow

| Command | Purpose |
|---------|---------|
| `/workflow` | Show current phase and progress |
| `/workflow next` | Advance to next phase |
| `/workflow skip` | Skip current phase |
| `/workflow done` | Mark workflow complete |
| `/workflow switch` | Switch between active workflows |
| `/workflow expand` | Create sub-tasks from phase items |

### Toolkit Management

| Command | Purpose |
|---------|---------|
| `/evolve init` | Create or recover your toolkit |
| `/evolve status` | Show version and pending changes |
| `/evolve release` | Bump version, push to remote |
| `/evolve audit` | Audit config, apply learnings, consolidate |
| `/evolve prepare` | Analyze task complexity, check toolkit gaps |
| `/evolve context` | Analyze current project, suggest relevant agents |
| `/evolve migrate` | Import ~/.claude/ content into toolkit |
| `/evolve switch` | Change active toolkit |
| `/evolve consolidate` | Merge similar components |
| `/evolve help` | Show all commands |

## Configuration

In `.claude-toolkit/toolkit.yaml`:

```yaml
version: "1.0"
name: my-toolkit
remote: git@github.com:you/your-toolkit.git  # For /evolve release

learning:
  auto_consolidate: true  # Merge similar components on /learn
  auto_suggest: true      # Suggest /learn at session end when valuable
```

## Cross-Machine Sync

```
Machine A                              Machine B
─────────                              ─────────
Work → signals flagged
         │
         ▼
/evolve release ────► Git ────► Claude Code auto-updates
                                         │
                                         ▼
                               Toolkit synced!
```

---

## Reference

### Rules

Automatically loaded based on context:

| Rule | Purpose |
|------|---------|
| `auto-signal-insights` | Claude flags insights via /evolve signal automatically |
| `system-architecture` | Reference for claude-evolve internals |
| `intelligent-evolve-usage` | When to use /learn, /reflect, /evolve prepare |
| `use-native-ui` | Enforce AskUserQuestion for choices |
| `lsp-first-navigation` | Prefer LSP tools over grep/search |

### Hooks

| Hook | Trigger | Purpose |
|------|---------|---------|
| `SessionStart` (startup/resume) | Session begins | Load understanding, export session ID, show stats |
| `SessionStart` (clear/compact) | Context cleared | Nudge task creation before implementing |
| `PostToolUse` (ExitPlanMode) | Plan approved | Nudge task creation before coding |
| `Stop` | Session ends | Convert signals to observations, suggest /learn |

### Toolkit Structure

```
~/.claude-evolve/
├── active                            # Current toolkit name
├── signals/                          # Session signal files (JSONL)
│   └── {session_id}.json            # Cleared after /learn
└── toolkits/{name}/
    ├── .claude-plugin/plugin.json    # Plugin manifest
    ├── .claude-toolkit/toolkit.yaml  # Configuration
    ├── agents/                       # Your custom agents
    ├── skills/                       # Your custom skills
    ├── rules/                        # Your context rules
    ├── understanding/
    │   ├── understanding.md          # Universal patterns (<2000 tokens)
    │   ├── projects/{key}.md         # Project patterns (<1500 tokens each)
    │   └── observations/YYYY-MM.yaml # Session observations (90-day retention)
    └── history/
        ├── events.json               # Learning events log
        └── archive/                  # Monthly archives
```

---

## Principles

- **Signal-based**: Claude flags insights automatically; you can also flag with `/evolve signal`
- **User control**: You decide what's worth extracting via `/learn`
- **Depth-aware**: Task complexity assessed automatically — simple tasks skip ceremony
- **Toolkit isolation**: All writes go to ~/.claude-evolve/, never ~/.claude/
- **Explicit sync**: `/evolve release` to push changes to remote
- **Session isolation**: Each terminal session tracks signals independently
- **No state files**: Workflow uses native Claude Code tasks, not custom files

## License

MIT
