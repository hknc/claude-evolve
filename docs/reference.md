# claude-evolve Reference

Complete reference for claude-evolve components, configuration, and internals.

## Agents

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

## Skills

Skills load progressively via Claude Code's native progressive disclosure — only triggered skills load into context.

| Skill | Triggers | What It Does |
|-------|----------|--------------|
| `learn` | "extract learnings", "save what we learned" | Extract session insights into toolkit components |
| `evolve` | "/evolve", "manage toolkit" | Toolkit management and signal flagging |
| `setup-audit` | "audit my setup", "review config" | Audit and optimize Claude Code configuration |
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

## Rules

Automatically loaded based on context:

| Rule | Purpose |
|------|---------|
| `auto-signal-insights` | Claude flags insights via /evolve signal automatically |
| `intelligent-evolve-usage` | When to delegate to /build, /learn, /reflect |
| `subagent-constraints` | AskUserQuestion limitations and failure behavior |
| `lsp-first-navigation` | Prefer LSP tools over grep/search |

## Hooks

| Hook | Trigger | Purpose |
|------|---------|---------|
| `SessionStart` (startup/resume) | Session begins | Load understanding, export session ID, show stats |
| `SessionStart` (clear/compact) | Context cleared | Nudge task creation before implementing |
| `UserPromptSubmit` | User mentions "evolve" | Route to correct claude-evolve skill |
| `PostToolUse` (ExitPlanMode) | Plan approved | Nudge task creation before coding |
| `Stop` | Session ends | Convert signals to observations, suggest /learn |

## Signal-Based Learning

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

## Workflow Depths

Task complexity is assessed automatically and mapped to a workflow depth:

| Depth | When | Phases |
|-------|------|--------|
| `execute` | All low | No phases — just do it |
| `check` | Mixed low | verify |
| `plan` | Mixed medium | action → outcome |
| `design` | Multiple high | requirements → design → implement → testing |
| `explore` | High stakes + unclear | research → prototype → evaluate → decide |

### Workflow Commands

```
/workflow          → show current phase and progress
/workflow next     → advance to next phase
/workflow skip     → skip current phase
/workflow done     → complete workflow
/workflow switch   → switch between workflows
/workflow expand   → create sub-tasks from phase items
```

### Sub-Task Dependencies

Sub-tasks are created based on intelligent complexity scoring (not a fixed count). The algorithm assesses item count, dependencies, scope, and complexity:

| Pattern Detected | Dependency Strategy |
|-----------------|-------------------|
| "then", "after", "Step 1 → Step 2" | Sequential (each blocked by previous) |
| "independently", "in parallel" | Parallel (all blocked by parent only) |
| "depends on", "requires" | Explicit (parsed from text) |
| Default | Sequential (safer) |

### Research-First Recommendations

When a project has insufficient context (new project with few or no files), the workflow recommends doing deep research first using Claude on the web (claude.ai) or the desktop app, then dropping the research report into the project folder (e.g., `research.md`). This gives Claude Code the context it needs to produce substantially better results, especially for `design`/`explore` depths.

## Toolkit Preparation

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

## Commands Reference

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

## Toolkit Structure

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

## Principles

- **Signal-based**: Claude flags insights automatically; you can also flag with `/evolve signal`
- **User control**: You decide what's worth extracting via `/learn`
- **Depth-aware**: Task complexity assessed automatically — simple tasks skip ceremony
- **Toolkit isolation**: All writes go to ~/.claude-evolve/, never ~/.claude/
- **Explicit sync**: `/evolve release` to push changes to remote
- **Session isolation**: Each terminal session tracks signals independently
- **No state files**: Workflow uses native Claude Code tasks, not custom files
