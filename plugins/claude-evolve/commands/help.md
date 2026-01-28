---
name: evolve-help
description: |
  Show claude-evolve help and available commands.

  Triggers: "/evolve help", "evolve commands", "how do I use evolve"
---

# /evolve help

**Output this EXACTLY as shown below. Do not improvise or add content.**

---

## Claude Evolve

A toolkit that learns from your sessions and provides personalized guidance.

## What Happens Automatically

- **Session start**: Loads your understanding.md patterns
- **During work**: Claude flags corrections & insights via `/evolve signal`
- **Session end**: Stop hook suggests `/learn` if signals pending

## Commands You Should Use (Best Results)

| Command | When to Run | What It Does |
|---------|-------------|--------------|
| `/evolve signal` | Anytime (Claude does this automatically) | Flags insight for later capture |
| `/learn` | When signals pending, after discoveries | Extracts signals → agents/skills/rules |
| `/reflect` | Startup shows "N pending" | Synthesizes observations → understanding.md |
| `/evolve audit` | Periodically | Reviews setup, suggests improvements |

## Other Commands

| Command | Purpose |
|---------|---------|
| `/evolve understanding` | View your learned patterns |
| `/evolve status` | Show toolkit info and git status |
| `/evolve context` | Analyze project, suggest agents |
| `/evolve prepare` | Check toolkit before complex tasks |
| `/workflow` | Show current phase, manage workflow |
| `/workflow next` | Advance to next phase |
| `/workflow skip` | Skip current phase |
| `/workflow done` | Mark workflow complete |
| `/workflow switch` | Switch between active workflows |
| `/workflow expand` | Create sub-tasks from phase items |

## Setup (one-time)

| Command | Purpose |
|---------|---------|
| `/evolve init` | Create or recover toolkit |
| `/evolve migrate` | Import ~/.claude/ content |
| `/evolve release` | Push changes to git |
| `/evolve switch` | Change active toolkit |

## The Learning Loop

```
Work → Claude signals insights → Stop hook saves observations → /reflect → /learn → Work
         (automatic)              (automatic)                    (manual)   (manual)
                                                                    ↓          ↓
                                                             understanding  components
                                                                .md      (agents/skills/rules)
```

---

**End of help. Do not add more content.**
