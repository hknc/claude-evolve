# Auto-Signaling: Final Approach

## Core Insight

**Claude IS the intelligence.** Hooks can't be smart. But we also don't want Claude distracted by meta-cognition. The goal is learning capture without cognitive overhead.

## Final Approach: Event-Driven Signaling

### What We're Doing

- Rely on existing rule (`auto-signal-insights.md`) to define WHAT to signal
- Claude reacts naturally to corrections, preferences, insights
- Optional user hints when something notable happens

### What We're NOT Doing

- Regex pattern matching in hooks
- Completion checkpoints
- Self-reflection polling
- Mechanical meta-cognition

### Why

1. **90% of tasks have nothing to signal** - checkpoints waste cognition
2. **Event-driven captures ~70% of learnings** with near-zero overhead
3. **Claude's primary job is work**, not self-monitoring
4. **User retains control** over what gets remembered

## Rejected Approaches

| Approach | Problem |
|----------|---------|
| Regex patterns in hooks | Not intelligent, false positives |
| Completion checkpoints | Adds overhead to EVERY task (90% have nothing to signal) |
| Polling-based self-reflection | Makes Claude a "bureaucrat filing reports" |

## Key Principle

> "Event-driven, not poll-driven"

Signal when:
- User corrects ("No, I meant...", "Actually...")
- User states preference ("I always...", "Never do...")
- User explicitly asks to remember something

Don't:
- Mechanically check before every completion
- Add self-reflection overhead to clean tasks
- Second-guess every response

## Cognitive Load Summary

| Approach | Per-task overhead | Capture rate |
|----------|-------------------|--------------|
| Checkpoint polling | ~50 tokens EVERY task | ~75% |
| Event-driven (chosen) | ~0 normally, ~50 on trigger | ~70% |

**We trade 5% capture rate for near-zero overhead on 90% of tasks.**

## Implementation Files

| File | Purpose |
|------|---------|
| `rules/auto-signal-insights.md` | Defines what to signal, event-driven focus |
| `hooks/session-start.sh` | Minimal awareness, no pressure |

## Verification

1. Start session → rule is loaded
2. Have Claude do a task → no signal overhead on clean completion
3. Correct Claude ("No, use X instead") → Claude should signal naturally
4. Express preference ("I always want Y") → Claude should signal
5. Check signals are captured in `~/.claude-evolve/signals/`
