---
name: research-synthesize
description: Use when user says "research", "find out about", "what do sources say", "gather information on", "learn about", "investigate", or needs to gather and combine information from multiple sources for technical research, market analysis, or learning new topics.
---

# Research Synthesize Skill

You gather information from multiple sources and synthesize into coherent understanding.

## Philosophy

- **Multiple sources** - Don't rely on single source
- **Critical evaluation** - Assess credibility and recency
- **Synthesis over collection** - Combine into insight, not just list
- **Actionable output** - End with what user can do with this

## Process

### 1. Define Research Question

Clarify what needs to be learned:
- What specific question(s)?
- What decisions will this inform?
- What depth is needed?
- Any constraints (recency, source types)?

### 2. Identify Source Strategy

| Research Type | Sources |
|---------------|---------|
| Technical (how-to) | Official docs, GitHub, Stack Overflow |
| Comparison | Benchmarks, reviews, case studies |
| Current state | Recent articles, announcements, changelogs |
| Best practices | Industry guides, expert blogs, standards |
| Market/competitive | Company sites, analyst reports, news |

### 3. Gather in Parallel

Use Task tool to research multiple aspects simultaneously:

```markdown
Spawn parallel research tasks:

Task 1: Search official documentation and guides
Task 2: Search recent articles and blog posts (last 2 years)
Task 3: Search community discussions (Reddit, HN, forums)
Task 4: Search for benchmarks or comparisons

Each task returns:
- Key findings
- Source credibility (official/community/anecdotal)
- Recency
- Relevance to question
```

### 4. Evaluate Sources

For each source, assess:

| Factor | Questions |
|--------|-----------|
| **Credibility** | Who wrote it? Official source? Known expert? |
| **Recency** | When written? Still accurate? |
| **Bias** | Vendor content? Affiliate? Agenda? |
| **Depth** | Surface overview or deep analysis? |
| **Corroboration** | Do other sources agree? |

### 5. Synthesize Findings

Combine sources into coherent understanding:

```markdown
## Research Synthesis: [Topic]

### Question
[What we set out to learn]

### Key Findings

**Consensus (multiple sources agree):**
- [Finding with high confidence]
- [Finding with high confidence]

**Likely (some evidence):**
- [Finding with medium confidence]

**Uncertain (conflicting or limited):**
- [Finding needing more research]

### Source Analysis
| Source | Type | Recency | Key Contribution |
|--------|------|---------|------------------|
| [Source 1] | Official | 2026 | [What it told us] |
| [Source 2] | Community | 2025 | [What it told us] |

### Implications
[What this means for user's decision/work]

### Gaps
[What we couldn't find / needs more research]

### Recommended Actions
[What user should do with this information]
```

### 6. Cite Sources

Always provide sources for verification:

```markdown
### Sources
- [Title](URL) - [Brief note on relevance]
- [Title](URL) - [Brief note on relevance]
```

## Research Depth Levels

| Depth | Time | Output | Use When |
|-------|------|--------|----------|
| Quick | 5 min | Key facts | Simple factual question |
| Standard | 15 min | Synthesized findings | Typical research need |
| Deep | 30+ min | Comprehensive analysis | Major decision |

## Parallel Research Pattern

For comprehensive research:

```
Research Question: "Should we use Rust or Go for our new service?"

Task 1 (Performance):
  - Search benchmarks comparing Rust vs Go
  - Focus on relevant workloads (web services, concurrent I/O)

Task 2 (Ecosystem):
  - Search for library availability in both
  - Check framework maturity for web services

Task 3 (Team factors):
  - Search for learning curve comparisons
  - Hiring market for each language

Task 4 (Production experience):
  - Search for case studies of companies using each
  - Look for "migrated from X to Y" stories

Synthesize all findings into recommendation.
```

## Output Format

**Quick research:**
```
[Topic]: [Direct answer with source]

Source: [URL]
```

**Standard research:**
```
## Research: [Topic]

### Summary
[2-3 sentence synthesis]

### Key Findings
- [Finding 1] (Source: [X])
- [Finding 2] (Source: [Y])

### Recommendation
[What to do with this information]

### Sources
[List with URLs]
```

**Deep research:**
Full synthesis format with confidence levels, source analysis, implications, gaps.

## Anti-Patterns

**DON'T:**
- Use single source
- Present findings without source attribution
- Ignore contradictory evidence
- Treat all sources as equally credible
- Research endlessly without synthesis

**DO:**
- Use multiple independent sources
- Note confidence levels
- Highlight disagreements
- Prioritize recent and authoritative sources
- Synthesize into actionable insight

## When to Use

- Learning new technology
- Making technical decisions
- Understanding best practices
- Competitive/market analysis
- Investigating unfamiliar domain
