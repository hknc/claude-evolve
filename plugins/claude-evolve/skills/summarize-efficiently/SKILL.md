---
name: summarize-efficiently
description: Use when user says "summarize", "tl;dr", "key points", "give me the gist", "what's important here", "condense this", "brief overview", or needs to compress documents, conversations, PRs, articles, meeting notes, or codebases while preserving key information.
---

# Summarize Efficiently Skill

You compress information while preserving what matters, adapting to the user's needs.

## Philosophy

- **Preserve signal** - Keep insights, cut filler
- **Respect hierarchy** - Most important first
- **Match depth to need** - One-liner vs detailed depends on context
- **Actionable** - Highlight what user should do or know

## Process

### 1. Understand What to Summarize

| Content Type | Focus On |
|--------------|----------|
| Document/Article | Key claims, evidence, conclusions |
| PR/Code changes | What changed, why, impact |
| Conversation | Decisions, action items, open questions |
| Meeting notes | Outcomes, owners, deadlines |
| Codebase | Architecture, patterns, entry points |
| Error logs | Root cause, frequency, affected areas |

### 2. Determine Compression Level

Ask if unclear, or infer from context:

| Level | Output | Use When |
|-------|--------|----------|
| **One-liner** | 1 sentence | Quick check, already familiar |
| **Key points** | 3-5 bullets | Need to understand essentials |
| **Executive** | 1 paragraph | Share with stakeholders |
| **Detailed** | Structured sections | Deep understanding needed |

### 3. Extract Key Information

Read/analyze the content and identify:
- **Core message** - What's the main point?
- **Key facts** - Numbers, names, dates that matter
- **Decisions/Actions** - What was decided or needs doing
- **Implications** - What does this mean for the reader

### 4. Structure the Summary

**One-liner:**
```
This PR adds rate limiting to prevent API abuse using Redis token buckets.
```

**Key points:**
```
## Key Points

- Rate limiting added to all authenticated endpoints
- Uses Redis token bucket (100 req/min default)
- Returns 429 with Retry-After header when exceeded
- Config in env vars, no code changes needed to adjust
```

**Executive:**
```
## Summary

This PR implements API rate limiting to address the abuse incidents from last week.
It uses Redis-backed token buckets with configurable limits (default 100 req/min).
Users hitting limits get 429 responses with retry guidance. The implementation
adds ~2ms latency per request but prevents the cascade failures we saw.
```

**Detailed:**
```
## Summary: Rate Limiting Implementation

### What Changed
[Structured breakdown]

### Why
[Context and motivation]

### Impact
[Performance, user experience, operations]

### Action Required
[What reader needs to do]
```

## For Long Content

When summarizing very long content, use Task tool:

```
For a large document:
- Task 1: Summarize sections 1-3
- Task 2: Summarize sections 4-6
- Task 3: Summarize sections 7-9

Then synthesize into coherent overall summary.
```

## Summarization Patterns

### PR Summary
```
**What:** [One line on the change]
**Why:** [Motivation]
**How:** [Approach taken]
**Impact:** [What's affected]
**Test:** [How it was verified]
```

### Document Summary
```
**Topic:** [What it's about]
**Key Claims:** [Main arguments/findings]
**Evidence:** [Supporting data]
**Conclusion:** [So what?]
**Caveats:** [Limitations, open questions]
```

### Conversation Summary
```
**Context:** [What was being discussed]
**Decisions:** [What was decided]
**Action Items:** [Who does what by when]
**Open Questions:** [Unresolved items]
```

### Codebase Summary
```
**Purpose:** [What this code does]
**Architecture:** [How it's structured]
**Entry Points:** [Where to start reading]
**Key Patterns:** [Important conventions]
**Dependencies:** [What it relies on]
```

## Anti-Patterns

**DON'T:**
- Include filler ("In this document we will discuss...")
- Lose critical details (numbers, deadlines, owners)
- Add interpretation unless asked
- Make it longer than necessary

**DO:**
- Put most important info first
- Use bullets for scanability
- Preserve specific details that matter
- Match summary length to content importance

## Output Branding

For substantial summaries, use `[summary]` prefix:

```
[summary] Breaking down this 50-page doc...

## Key Points
...
```

For quick tl;dr, just provide it directly without prefix.
