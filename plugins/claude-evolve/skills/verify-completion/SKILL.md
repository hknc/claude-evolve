---
name: verify-completion
description: Use when user says "am I done", "before I commit", "final check", "did I miss anything", "ready to ship", "sanity check", "verify complete", or before claiming work is done to systematically check requirements, edge cases, and cleanup.
---

# Verify Completion Skill

You systematically verify work is actually complete before claiming done.

## Philosophy

- **Evidence over feeling** - "I think it's done" -> "I verified it's done"
- **Original requirements** - Check against what was asked, not what was built
- **Edge cases** - The obvious path works, but what about edges?
- **Clean state** - No debug code, no TODOs, no temporary hacks

## Process

### 1. Recall Original Requirements

First, explicitly state what was requested:
- What did the user originally ask for?
- Were there any clarifications or changes?
- What's the acceptance criteria?

### 2. Run Verification Checklist

Go through systematically:

```markdown
## Completion Verification

### Requirements Check
- [ ] Original requirement met: [state it]
- [ ] All clarifications addressed: [list any]
- [ ] Scope creep avoided: [nothing extra added]

### Code Quality (if applicable)
- [ ] No debug code (console.log, print, debugger)
- [ ] No commented-out code
- [ ] No hardcoded values that should be config
- [ ] No TODO/FIXME/HACK comments left
- [ ] Error handling complete

### Testing
- [ ] Happy path works
- [ ] Edge cases handled: [list them]
- [ ] Error cases handled: [list them]
- [ ] Tests pass (if test suite exists)

### Integration
- [ ] Works with existing code
- [ ] No breaking changes (or documented)
- [ ] Dependencies updated if needed

### Cleanup
- [ ] Temporary files removed
- [ ] Git status clean (only intended changes)
- [ ] No unrelated changes mixed in
```

### 3. Verify Evidence

For each check, verify with evidence:

```bash
# No debug statements
grep -r "console.log\|print(\|debugger" src/

# Tests pass
npm test  # or equivalent

# Git status clean
git status
git diff --stat
```

### 4. Check Edge Cases

For the specific feature, identify and test edges:

| Feature Type | Common Edge Cases |
|--------------|-------------------|
| Input handling | Empty, null, very long, special chars |
| Lists | Empty list, single item, many items |
| Numbers | Zero, negative, very large, decimals |
| Dates | Boundaries, timezones, leap years |
| Auth | No token, expired, invalid, wrong permissions |
| Files | Missing, empty, too large, wrong format |

### 5. Final Walkthrough

Mentally or actually walk through:
1. User does the thing
2. System responds correctly
3. Edge cases handled gracefully
4. Errors give helpful messages

### 6. Report Verification Status

```markdown
## Verification Complete

**Original requirement:** Add rate limiting to API

### Verified [OK]
- [x] Rate limiting applied to all `/api/*` routes
- [x] Returns 429 with Retry-After header
- [x] Configurable via environment variables
- [x] Tests pass (12 new tests added)
- [x] No debug code
- [x] Git diff shows only rate-limit related changes

### Edge Cases Tested
- [x] First request (no prior count)
- [x] Exactly at limit (100th request)
- [x] Over limit (101st request)
- [x] After window reset
- [x] Redis connection failure (graceful degradation)

**Ready to commit.**
```

Or if issues found:

```markdown
## Verification Found Issues

**Original requirement:** Add rate limiting to API

### Issues Found
1. **Missing:** Graceful degradation when Redis is down
2. **Debug code:** console.log on line 47 of rateLimiter.js
3. **Edge case:** Empty API key not handled

### Not Ready - Fix These First
```

## Quick Verification (for small changes)

For trivial changes, abbreviated check:

```
Quick verify:
- [x] Does what was asked
- [x] Tests pass
- [x] No debug code
- [x] Clean diff

Ready.
```

## Using Tasks for Thorough Verification

For large changes, verify different aspects in parallel:

```
Task 1: Verify all requirements met (check against original request)
Task 2: Run test suite and check coverage
Task 3: Check for code quality issues (debug code, TODOs)
Task 4: Test edge cases manually

Synthesize: Ready or issues found.
```

## Anti-Patterns

**DON'T:**
- Say "done" based on feeling
- Skip edge case testing
- Leave "I'll fix it later" items
- Mix verification with more changes

**DO:**
- Verify against original requirements
- Test edge cases explicitly
- Clean up before claiming done
- Document what was verified

## When to Use

- Before committing
- Before creating PR
- Before saying "done" to user
- Before moving to next task
- After any "I think it's ready"
