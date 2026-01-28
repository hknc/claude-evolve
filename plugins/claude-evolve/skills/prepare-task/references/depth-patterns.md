# Task Depth Patterns Reference

Detailed heuristics for detecting task depth and calibrating guidance.

## Depth Detection Heuristics

### Signal Assessment

Each signal is scored Low (1), Medium (2), or High (3).

#### Scope Signal

| Indicator | Score | Examples |
|-----------|-------|----------|
| Single file/operation | Low | "Fix typo", "Add log statement", "Rename variable" |
| Multi-step, single system | Medium | "Add validation", "Implement function", "Write tests for X" |
| Multi-system, cross-cutting | High | "Add authentication", "Migrate database", "Integrate external API" |

#### Stakes Signal

| Indicator | Score | Examples |
|-----------|-------|----------|
| Easily reversible | Low | Local changes, no side effects, git reset works |
| Has rollback path | Medium | Database migrations with down, feature flags available |
| Irreversible/high-impact | High | Production deploys, data deletion, security changes, public APIs |

#### Clarity Signal

| Indicator | Score | Examples |
|-----------|-------|----------|
| Explicit requirements | Low | "Change color to #FF0000", "Sort ascending by date" |
| Some gaps to fill | Medium | "Make it faster", "Improve error handling", "Add tests" |
| Undefined/ambiguous | High | "Make it better", "Fix the architecture", "Add security" |

#### Familiarity Signal

| Indicator | Score | Examples |
|-----------|-------|----------|
| Known domain/pattern | Low | Repeated task, familiar codebase, standard pattern |
| Partially known | Medium | Known tech but new codebase, known codebase but new tech |
| New territory | High | New technology, new domain, first time doing this type of task |

### Depth Mapping

Sum the signal scores:

| Total Score | Depth | Guidance Approach |
|-------------|-------|-------------------|
| 4 (all Low) | `execute` | No guidance, just do it |
| 5-6 | `check` | Brief verification, 1 key consideration |
| 7-8 | `plan` | Suggest phases, 2-3 considerations |
| 9-10 | `design` | Full coaching, explore options, AskUserQuestion |
| 11-12, or Stakes=High + Clarity=High | `explore` | Research first, deep elicitation |

### Override Rules

- **Stakes = High** -> minimum depth is `plan`
- **Stakes = High AND Clarity = High** -> depth is `explore`
- **User says "just do it"** -> depth becomes `execute`
- **Understanding.md shows expertise** -> reduce depth by 1 level

## Elicitation Question Templates

Use these templates when **CALLING the AskUserQuestion tool**. The tables show the options to provide.

### Software Engineering Domain

**CALL the AskUserQuestion tool with TWO questions:**

First question - Header: "Problem"
"What's the core problem you're solving?"
| Label | Description |
|-------|-------------|
| Bug fix | Something isn't working correctly |
| New capability | Adding something that doesn't exist |
| Improvement | Making existing thing better |
| Exploration | Investigating or learning |

Second question - Header: "Priority"
"What constraints matter most?"
| Label | Description |
|-------|-------------|
| Speed | Get it working quickly |
| Quality | Get it right, take time needed |
| Learning | Understand deeply |
| Minimal change | Smallest possible diff |

### Writing/Content Domain

**CALL the AskUserQuestion tool with TWO questions:**

First question - Header: "Content"
"What type of content is this?"
| Label | Description |
|-------|-------------|
| Technical docs | API docs, guides, tutorials |
| Blog/article | Thought leadership, explanations |
| Copy/marketing | Persuasive, conversion-focused |
| Creative | Narrative, storytelling |

Second question - Header: "Audience"
"Who's the audience?"
| Label | Description |
|-------|-------------|
| Developers | Technical, wants details |
| End users | Non-technical, wants simplicity |
| Decision makers | Busy, wants outcomes |
| Mixed | Multiple audience types |

### Research/Analysis Domain

**CALL the AskUserQuestion tool with TWO questions:**

First question - Header: "Goal"
"What's the research goal?"
| Label | Description |
|-------|-------------|
| Understand | Learn how something works |
| Evaluate | Compare options, make decision |
| Validate | Confirm or refute hypothesis |
| Discover | Find new insights or patterns |

Second question - Header: "Application"
"How will you use the findings?"
| Label | Description |
|-------|-------------|
| Immediate action | Make a decision now |
| Inform design | Shape future work |
| Document | Create reference material |
| Share | Communicate to others |

### Generic Domain (fallback)

**CALL the AskUserQuestion tool with TWO questions:**

First question - Header: "Problem"
"What's the core problem you're solving?"
| Label | Description |
|-------|-------------|
| Fix something | Something isn't working right |
| Add something | Create new capability |
| Improve something | Make existing thing better |
| Explore | Investigate or learn |

Second question - Header: "Priority"
"What constraints matter most?"
| Label | Description |
|-------|-------------|
| Speed | Get it done quickly |
| Quality | Get it right |
| Learning | Understand deeply |
| Minimal effort | Smallest change possible |

## Artifact Pattern Examples

### Pre-Work Artifacts (before starting main work)

| Pattern | Indicator | Suggestion Trigger |
|---------|-----------|-------------------|
| Spec writing | User creates design docs before coding | `design` depth tasks |
| Research notes | User gathers information before acting | `explore` depth tasks |
| Test planning | User writes test plan before implementation | Tasks with testing component |
| Architecture sketch | User diagrams before building | Multi-system changes |

### During-Work Artifacts (alongside main work)

| Pattern | Indicator | Suggestion Trigger |
|---------|-----------|-------------------|
| TDD | User writes tests before/with code | New function/module creation |
| Draft PRs | User opens PR early for feedback | Multi-day tasks |
| Incremental commits | User commits frequently | Any code task |
| Running notes | User documents decisions as made | Complex decisions |

### Post-Work Artifacts (after completing main work)

| Pattern | Indicator | Suggestion Trigger |
|---------|-----------|-------------------|
| Documentation | User updates docs after changes | Public API changes |
| Changelog | User maintains changelog | Release preparation |
| Retrospective | User reflects on process | Major task completion |
| Knowledge sharing | User writes up learnings | Novel problem solved |

### Confidence Thresholds

| Observations | Confidence | Action |
|--------------|------------|--------|
| 1-2 | Low | Don't suggest, just note |
| 3-4 | Medium | Suggest tentatively: "You sometimes..." |
| 5+ | High | Suggest confidently: "You typically..." |

## Cross-Domain Guidance Calibration

### Adjusting for User Expertise

Read from understanding.md:
- `expert in {domain}` -> Skip basics, focus on edge cases
- `prefers {style}` -> Frame guidance in that style
- `gets corrected on {X}` -> Be tentative about X

### Adjusting for Project Context

Read from projects/{key}.md:
- Project conventions -> Apply them
- Known patterns -> Reference them
- Past corrections -> Avoid repeating mistakes

### Adjusting for Task History

If similar task was done recently:
- With guidance -> Offer abbreviated version
- Without guidance -> Assume expertise, skip guidance
- With corrections -> Apply learned corrections

### Language Calibration by Depth

| Depth | Language Style |
|-------|---------------|
| `execute` | None (no guidance) |
| `check` | "Quick check: {consideration}" |
| `plan` | "Consider: {considerations}" |
| `design` | "Key decisions: {options}" |
| `explore` | "Before diving in, let's understand: {questions}" |
