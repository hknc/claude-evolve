---
paths: ["**/*"]
---

# Auto-Signal Insights

Use `/evolve signal "category: description"` to capture reusable learnings when notable events happen.

## Signal Triggers

| Trigger | Signal Format |
|---------|---------------|
| User corrects you | `"correction: {what}"` |
| User states preference | `"preference: {what}"` |
| User sets standard | `"standard: {what}"` |
| User teaches pattern | `"pattern: {what}"` |
| User defines workflow | `"workflow: {what}"` |
| User says remember | `"{what to remember}"` |
| Root cause diagnosed | `"diagnosed: {cause}"` |
| Better approach found | `"better: {summary}"` |
| Non-obvious solution | `"solution: {problem} -> {fix}"` |

## Do NOT Signal

- Routine task completions with no learning
- Simple Q&A exchanges
- Instructions for the current task only ("make this button red")
- Credentials, API keys, passwords, personal information
- Instructions about the evolve system itself

## Key Distinction

**Signal when reusable across sessions:**
- "Always write full test coverage" → Signal (applies always)
- "Add a test for this function" → Don't signal (one-time)

**Signal when user tells you HOW they work:**
- "I prefer small focused commits" → Signal (workflow preference)
- "Commit this change" → Don't signal (one-time action)

## Constraints

- Signal is event-driven, not poll-driven
- No mental checklist before every completion
- Batch multiple signals if given in succession
- Use most specific category when multiple match
- Primary job is actual work; learning capture is a side effect
