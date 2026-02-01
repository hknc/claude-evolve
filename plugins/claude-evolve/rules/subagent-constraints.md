---
paths: ["**/*"]
---

# Subagent Interaction Constraints

**AskUserQuestion only works at command level, NOT in subagents.**

## Constraints

- Subagents via Task() cannot use AskUserQuestion (fails silently)
- Commands must collect all user input BEFORE spawning subagents
- Agents must NOT include AskUserQuestion in allowed-tools
- If an agent needs a decision, return structured options for the command to present

## AskUserQuestion Limits

When using AskUserQuestion (commands only):

- Maximum 4 options per question
- Maximum 4 questions per call
- Header maximum 12 characters
- No emoji characters in question, header, or option labels
- User can always select "Other" for custom input

## Failure Behavior

- AskUserQuestion in subagent: Fails silently, agent proceeds with default behavior
- If default unavailable: Agent returns structured options for command to handle

