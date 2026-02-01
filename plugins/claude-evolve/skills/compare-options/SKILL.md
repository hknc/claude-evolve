---
name: compare-options
description: Use when user says "compare X vs Y", "which should I use", "pros and cons", "what's the difference between", "A or B", "help me choose", "tradeoffs", "what are the tradeoffs", or needs to compare tools, libraries, approaches, or architectures with tradeoffs clearly presented.
---

# Compare Options Skill

You provide structured comparisons of alternatives, making tradeoffs explicit.

## Philosophy

- **Balanced** - Present each option fairly, not just validate user's leaning
- **Contextual** - Tradeoffs depend on the user's specific situation
- **Actionable** - End with a clear recommendation when possible
- **Honest** - If options are equivalent, say so

## Process

### 1. Identify Options

Clarify what's being compared:
- Explicit options provided by user
- If vague ("what database should I use"), ask clarifying questions first

### 2. Determine Comparison Criteria

Infer relevant criteria from context, or ask. Common criteria:

| Domain | Typical Criteria |
|--------|------------------|
| Tools/Libraries | Performance, learning curve, ecosystem, maintenance |
| Architectures | Scalability, complexity, cost, team familiarity |
| Approaches | Speed, quality, risk, reversibility |
| Services | Pricing, features, vendor lock-in, support |

### 3. Research If Needed

For technical comparisons, gather current information:

```
Use WebSearch for:
- Recent benchmarks
- Known issues or limitations
- Community sentiment
- Version-specific changes
```

For complex comparisons, use Task tool to research options in parallel:

```
Task 1: Research option A - features, limitations, recent changes
Task 2: Research option B - features, limitations, recent changes
Task 3: Research option C - features, limitations, recent changes
```

### 4. Build Comparison

Structure the comparison:

```markdown
## Comparison: [Option A] vs [Option B]

**Context:** [What user is trying to achieve]

| Criteria | Option A | Option B |
|----------|----------|----------|
| [Criterion 1] | [Rating/Detail] | [Rating/Detail] |
| [Criterion 2] | [Rating/Detail] | [Rating/Detail] |

### Option A: [Name]
**Best for:** [Use cases]
**Watch out:** [Limitations]

### Option B: [Name]
**Best for:** [Use cases]
**Watch out:** [Limitations]

## Recommendation

**For your case:** [Clear recommendation with reasoning]

[Or if genuinely equivalent: "Both are solid choices. Go with [factor that might tip the scales]."]
```

### 5. Tailor to Context

Adjust recommendation based on:
- User's stated constraints (budget, timeline, team size)
- Understanding.md preferences (read `$HOME/.claude-evolve/active` to get toolkit name, then check `$HOME/.claude-evolve/toolkits/{name}/understanding/understanding.md` if available)
- Project context (detected stack, scale)

## Output Format

**For simple comparisons (2 options, clear winner):**

```
## Redis vs Memcached for Sessions

| Aspect | Redis | Memcached |
|--------|-------|-----------|
| Persistence | [OK] | [X] |
| Data types | Rich | Key-value |
| Memory | Higher overhead | More efficient |

**For sessions:** Redis - you'll want TTL and potential persistence.
```

**For complex comparisons (multiple options, nuanced):**

Use full format with sections for each option, detailed criteria table,
and context-aware recommendation.

## Anti-Patterns

**DON'T:**
- Always recommend the "popular" option
- Ignore user's context
- Present opinion as fact
- Avoid making a recommendation when one is clearly better

**DO:**
- Acknowledge when options are genuinely close
- Highlight deal-breakers early
- Consider total cost of ownership, not just features
- Update recommendation if user provides new context

## Examples

### Quick Comparison
```
User: "pnpm or npm?"

For most projects, pnpm - faster installs, better disk usage, strict dependency resolution.
Stick with npm if: team is unfamiliar, or CI doesn't support pnpm well.
```

### Detailed Comparison
```
User: "Comparing Next.js vs Remix vs Astro for our marketing site"

[Full comparison table with SSR, SSG, learning curve, ecosystem]

**For marketing site:** Astro - you need mostly static content with islands of interactivity.
Next.js is overkill, Remix is better for apps with lots of data mutations.
```
