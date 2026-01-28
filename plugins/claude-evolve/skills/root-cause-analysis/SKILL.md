---
name: root-cause-analysis
description: Use when user says "why does this happen", "find the root cause", "diagnose", "keeps happening", "what's causing", "5 whys", "get to the bottom of", or needs to find underlying causes for bugs, performance issues, process failures, or system outages.
---

# Root Cause Analysis Skill

You systematically diagnose problems to find the underlying cause, not just symptoms.

## Philosophy

- **Depth over speed** - Surface fixes create recurring problems
- **Evidence-based** - Verify each "why" before going deeper
- **Systemic thinking** - Look for process/system failures, not just individual errors
- **Actionable** - End with fixes at the appropriate level

## Process

### 1. Define the Problem Clearly

Start by stating the problem precisely:
- What is happening?
- What should be happening?
- When did it start / how often?
- What's the impact?

```
**Problem:** API response times increased from 200ms to 3s
**Expected:** Responses under 500ms
**When:** Started Monday after deployment
**Impact:** 40% of users abandoning checkout
```

### 2. Choose Analysis Method

| Method | Best For |
|--------|----------|
| **5 Whys** | Linear cause chains, single root cause |
| **Fishbone** | Multiple contributing factors |
| **Fault Tree** | System failures with AND/OR logic |
| **Timeline** | Incidents with sequence of events |

### 3. Gather Evidence

Before each "why", gather evidence:

For code/systems:
```bash
# Logs, metrics, traces
# Use Task tool for parallel investigation if multiple areas
```

For processes:
- Interview stakeholders
- Review documentation
- Check recent changes

### 4. Apply 5 Whys

Ask "why" iteratively, but verify each answer:

```markdown
## 5 Whys Analysis

**Problem:** Users report slow page loads

1. **Why slow?** -> API takes 3 seconds
   *Evidence: Network tab shows /api/users taking 3.2s*

2. **Why does API take 3s?** -> Database query is slow
   *Evidence: Query logs show SELECT taking 2.8s*

3. **Why is query slow?** -> Full table scan on users table
   *Evidence: EXPLAIN shows no index used*

4. **Why no index?** -> Index was dropped in migration
   *Evidence: Migration 042 drops idx_users_email*

5. **Why was it dropped?** -> Copied from stack overflow without understanding
   *Evidence: Commit message references SO link*

**Root Cause:** Migration review process doesn't catch index changes
```

### 5. Identify Fix Levels

Every root cause analysis should identify fixes at multiple levels:

```markdown
## Fixes

**Immediate (address symptom):**
- Add index back to users table

**Preventive (address root cause):**
- Add migration review checklist
- Add performance regression tests

**Systemic (address deeper issue):**
- Training on database optimization
- Automated index usage analysis in CI
```

### 6. Verify Root Cause

Before concluding, verify:
- Does fixing this cause prevent recurrence?
- Are there other contributing factors?
- Is this the deepest actionable cause?

## Fishbone Diagram (for multiple factors)

When problem has multiple contributing causes:

```
                    ┌─ Process: No code review
                    ├─ Process: No testing requirement
        People ─────┼─ Skills: Junior dev unfamiliar with DB
                    └─ Capacity: Team overloaded

Slow ───────────────┼─ Technology: No query monitoring
Page                ├─ Technology: No performance budget
Loads   Technology ─┼─ Technology: Outdated ORM version
                    └─

                    ┌─ Environment: Prod DB larger than staging
        Environment ┼─ Environment: No realistic test data
                    └─ Environment: Different DB version
```

## Using Tasks for Parallel Investigation

For complex problems, investigate areas in parallel:

```
Spawn parallel tasks:
- Task 1: Analyze recent code changes
- Task 2: Check infrastructure metrics
- Task 3: Review error logs
- Task 4: Check external dependencies

Synthesize findings to identify root cause.
```

## Output Format

```markdown
## Root Cause Analysis: [Problem]

### Problem Statement
[Clear description with impact]

### Analysis Method
[5 Whys / Fishbone / Timeline]

### Investigation
[Step-by-step with evidence]

### Root Cause
[The underlying cause, not the symptom]

### Recommended Fixes
| Level | Action | Effort |
|-------|--------|--------|
| Immediate | [Quick fix] | Low |
| Preventive | [Stop recurrence] | Medium |
| Systemic | [Address deeper issue] | High |

### Verification
[How to confirm the root cause is correct]
```

## Anti-Patterns

**DON'T:**
- Stop at the first "why" (symptom-level fix)
- Assume without evidence
- Blame individuals (look for system failures)
- Skip verification

**DO:**
- Keep asking why until you reach an actionable systemic cause
- Verify each step with evidence
- Consider multiple contributing factors
- Propose fixes at multiple levels
