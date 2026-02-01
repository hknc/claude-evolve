---
paths: ["**/*"]
---

# Evolve System Delegation

## Critical Constraint

When the user wants to build, create, or work on anything substantial, you MUST invoke the `build-project` skill using the Skill tool. Do NOT handle build/create/project requests directly.

## Delegate to build-project When

Judge by **intent**, not keywords:

- "let's build a CLI tool" → build-project
- "I need to add auth to my app" → build-project
- "fix the payment flow" → build-project (if substantial)
- "refactor the database layer" → build-project
- "migrate from REST to GraphQL" → build-project
- "let's get started" (in empty directory) → build-project
- User describes a project idea → build-project

## Exception

Skip for trivial tasks that are clearly a single quick action:
- Fixing a typo
- Adding a log line
- Renaming a variable

If in doubt, use the skill.
