---
paths: ["**/*"]
---

# Auto-Signal Insights

You have access to `/evolve signal` to capture reusable learnings (stored in `~/.claude-evolve/signals/`). Use it when notable events happen during conversation.

## Your Approach: Event-Driven, Not Poll-Driven

Signal when something notable HAPPENS. Do NOT checkpoint or self-reflect at every completion.

**React naturally when:**
- User corrects you ("No, I meant...", "Actually...", "That's wrong")
- User states preference ("I prefer...", "Always do X", "Never do Y")
- User says to remember ("Remember this", "Keep in mind", "Don't forget")
- You discover something surprising about the codebase

**Do NOT add overhead:**
- No mental checklist before every completion
- No self-reflection tax on clean tasks
- No second-guessing responses

Your primary job is the actual work. Learning capture is a side effect of paying attention, not a separate task.

## When to Signal

| Trigger | Examples | Signal Format |
|---------|----------|---------------|
| User corrects you | "No, use X not Y", "That's wrong, do Z" | `"correction: {what}"` |
| User states preference | "You should always X", "I want Y", "Make sure to Z" | `"preference: {what}"` |
| User sets standard | "Full test coverage", "Use strict types", "No magic numbers" | `"standard: {what}"` |
| User teaches pattern | "We always do X because Y", "The convention here is Z" | `"pattern: {what}"` |
| User defines workflow | "Write tests first", "Review before commit", "Plan before code" | `"workflow: {what}"` |
| User says remember | "Remember this", "Don't forget", "Keep in mind" | `"{what to remember}"` |
| Root cause diagnosed | Found cause after investigation | `"diagnosed: {cause}"` |
| Better approach found | More efficient solution discovered | `"better: {summary}"` |
| Non-obvious solution | Workaround for tricky problem | `"solution: {problem} -> {fix}"` |

## Do NOT Signal

- Routine task completions with no learning
- Simple Q&A exchanges
- User just says "thanks" or similar
- Instructions for the current task only ("make this button red")
- Credentials, API keys, passwords, personal information, or sensitive operational details
- Instructions about the evolve system itself ("stop signaling", "don't use /learn")

## Key Distinction

**Signal when reusable across sessions:**
- "You should write full test coverage" → Signal (applies always)
- "Add a test for this function" → Don't signal (one-time instruction)

**Signal when the user tells you HOW they work:**
- "I prefer small focused commits" → Signal (workflow preference)
- "Commit this change" → Don't signal (one-time action)

## How to Signal

Invoke the skill directly in your response:

```
/evolve signal "category: description"
```

Examples:
- `/evolve signal "preference: full test coverage for all implementations"`
- `/evolve signal "correction: use pnpm not npm in this project"`
- `/evolve signal "standard: no magic numbers, use named constants"`

## When Multiple Triggers Match

Use the most specific category. "No, always use strict TypeScript" is a `correction` (most actionable), not just a `preference`.

## Batching

If the user gives several preferences or standards in rapid succession, batch them into one signal:

```
/evolve signal "preferences: full test coverage, strict types, small commits"
```

Do not interrupt your workflow to signal each one individually.

## Optional Acknowledgment

After signaling a correction or preference, you may optionally add a brief acknowledgment to the user:

```
[claude-evolve] Noted {category}. Use /learn to review.
```

Use sparingly — only for clearly reusable insights.
