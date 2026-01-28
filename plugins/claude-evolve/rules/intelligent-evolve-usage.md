---
paths: ["**/*"]
---

# Intelligent Evolve System Usage

**CRITICAL — Read this first:** When the user wants to start building, creating, or working on anything substantial, you MUST invoke the `build-project` skill using the Skill tool. Do NOT handle build/create/project requests directly. Do NOT show your own project setup UI. Always delegate to `Skill(skill: "build-project")`.

## Starting Any Substantial Work

When the user's intent is to start working on something — whether it's a new project, a feature, a fix, a refactor, a migration, or any non-trivial task — **ALWAYS invoke the `build-project` skill** using the Skill tool first. Do not handle these requests directly.

This applies regardless of phrasing. Judge by **intent**, not keywords. Examples:
- "let's build a CLI tool" → build-project
- "I need to add auth to my app" → build-project
- "fix the payment flow" → build-project (if it's substantial, not a one-line fix)
- "refactor the database layer" → build-project
- "migrate from REST to GraphQL" → build-project
- "let's get started" (in an empty directory) → build-project
- Describing a project idea without explicit "build" language → build-project

**Exception:** Skip for trivial tasks that are clearly a single quick action (fixing a typo, adding a log line, renaming a variable). If in doubt, use the skill.

## Before Complex Tasks

When starting a complex task (refactoring, new domain, unfamiliar technology):
- **Tip:** `/evolve prepare` can analyze the task and create missing agents/skills
- This is optional - just a reminder that the feature exists

## Learning Extraction

At session end, if signals are pending, the Stop hook suggests `/learn`.
Run `/learn` to convert flagged insights into reusable components:

| Signal Type | Becomes |
|-------------|---------|
| Problem-solving pattern | Skill |
| Investigation method | Agent |
| Code pattern/approach | Rule |

## Use Context Detection

When starting work in an unfamiliar codebase or switching projects:
- Run `/evolve context` to discover relevant agents
- The system will analyze the project and suggest tools

## Periodic Maintenance

After major milestones:
- Run `/evolve audit` to check coverage and apply learnings
- Run `/evolve release` to publish changes (other machines auto-update)

## Key Principle

**You are the observer.** When valuable insights occur, signal them immediately. The Stop hook will remind users about pending signals so nothing gets lost.
