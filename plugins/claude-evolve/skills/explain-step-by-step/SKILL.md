---
name: explain-step-by-step
description: Use when user asks to "explain", "walk through", "break down", "help me understand", or needs to understand something complex progressively. Works for any domain — PR changes, code, documents, concepts, processes, architectures. Also triggers on "explain this PR", "walk me through", "break down these changes", "step by step", "what does this do". For "break down" into actionable work items with dependencies, use decompose-problem instead.
---

# Step-by-Step Explanation Skill

You explain complex things progressively, building understanding layer by layer.

## Philosophy

- **Progressive disclosure** - Start with the big picture, then details
- **Logical ordering** - Present steps in the order that builds understanding
- **Efficient** - No filler words, no over-explanation
- **Domain-agnostic** - Works for code, PRs, documents, concepts, anything

## Process

### 1. Identify What to Explain

Determine the subject:
- PR/commit changes
- Code file or function
- Architecture or system
- Document or spec
- Concept or process
- Error or behavior

### 2. Gather Context

For PRs/code changes:
```bash
# Get the diff
git diff main...HEAD  # or specific commits
gh pr diff <number>   # for GitHub PRs
```

For code:
- Read the relevant files
- Use LSP for definitions/references if helpful

For concepts:
- Draw on your knowledge
- Research if needed (WebSearch)

### 3. Structure the Explanation

**Always start with a 1-2 sentence summary:**
```
This PR adds rate limiting to the API by introducing a Redis-backed
token bucket and applying it to all authenticated endpoints.
```

**Then break into logical steps:**

| Subject Type | Step Ordering |
|--------------|---------------|
| PR/changes | By logical dependency, not file order |
| Code flow | By execution order |
| Architecture | Outside-in (boundaries -> core) or inside-out |
| Process | Chronological or causal |
| Concept | Simple -> complex, concrete -> abstract |

### 4. Present Each Step

Format each step as:

```
## Step N: [What This Step Accomplishes]

[1-2 sentences explaining the step]

[Code snippet or relevant excerpt if applicable]

**Key insight:** [One sentence on why this matters or what to notice]
```

### 5. Connect the Steps

After all steps, optionally add:
- How the pieces fit together
- What to watch out for
- Questions the reader might have

## Example: Explaining PR Changes

**Input:** "Explain this PR"

**Output:**

```
## Summary

This PR adds user session management with automatic timeout and refresh.

---

## Step 1: New Session Model

Adds `Session` struct with user ID, expiry, and refresh token.

```rust
pub struct Session {
    user_id: Uuid,
    expires_at: DateTime<Utc>,
    refresh_token: String,
}
```

**Key insight:** Sessions are stored server-side, not in JWT claims.

---

## Step 2: Session Middleware

New middleware checks session validity on each request.

```rust
async fn session_check(req: Request, next: Next) -> Response {
    let session = get_session(&req)?;
    if session.is_expired() {
        return Err(Unauthorized);
    }
    next.run(req).await
}
```

**Key insight:** Expired sessions return 401, forcing re-auth.

---

## Step 3: Refresh Endpoint

Adds `/auth/refresh` to extend sessions without re-login.

**Key insight:** Refresh tokens are single-use and rotated on each refresh.

---

## How It Fits Together

Request -> Middleware checks session -> If valid, proceed -> If expired, client calls refresh -> New session issued

**Watch out for:** The refresh token rotation means clients must store the new token after each refresh.
```

## Adapting to Domain

### For Code Explanation

- Follow execution flow
- Highlight state changes
- Note side effects

### For Architecture

- Start with boundaries (what goes in/out)
- Then internal components
- Then data flow between them

### For Concepts

- Start with what it is (definition)
- Then why it exists (motivation)
- Then how it works (mechanism)
- Then when to use it (application)

### For Errors/Debugging

- Start with the symptom
- Then the cause chain
- Then the fix

## Anti-Patterns

**DON'T:**
- Explain in file order (often wrong logical order)
- Include every detail (focus on what builds understanding)
- Use filler ("Let me explain...", "As you can see...")
- Assume knowledge level (calibrate to user)

**DO:**
- Start with summary
- Order by logical dependency
- Use code snippets sparingly but effectively
- End with connections/insights

## Efficiency Tips

- If user knows the domain, skip basics
- If change is trivial, say so briefly
- If step is obvious, compress it
- If something is complex, expand it

## Output Branding

Use `[explain]` prefix for multi-part explanations:

```
[explain] Breaking down this PR in 4 steps...

## Summary
...
```

For simple explanations, skip the prefix.
