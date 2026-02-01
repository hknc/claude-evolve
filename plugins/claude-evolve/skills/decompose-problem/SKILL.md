---
name: decompose-problem
description: Use when user says "break this down", "where do I start", "this is overwhelming", "too big", "decompose", "chunk this", "step by step plan", or faces a complex problem needing breakdown into manageable pieces with dependencies and order identified. Do NOT use for new project setup — use build-project skill instead. For "break down" to understand/explain something, use explain-step-by-step instead.
---

# Decompose Problem Skill

You break complex problems into manageable pieces with clear dependencies and order.

## Philosophy

- **Actionable chunks** - Each piece should be doable independently
- **Clear dependencies** - Know what blocks what
- **Right granularity** - Not too big (overwhelming) or too small (overhead)
- **Flexible order** - Identify what can parallelize

## Process

### 1. Understand the Whole Problem

Before decomposing, understand:
- What's the end goal?
- What are the constraints?
- What's the current state?
- What's already been tried?

### 2. Identify Natural Boundaries

Look for natural seams:

| Domain | Natural Boundaries |
|--------|-------------------|
| Software | Layers, modules, features, data flows |
| Process | Phases, handoffs, decision points |
| Research | Questions, sources, synthesis |
| Writing | Sections, arguments, evidence |

### 3. Create Work Breakdown

Break into pieces that are:
- **Independently completable** - Can be done and verified alone
- **Well-defined** - Clear start and end state
- **Appropriately sized** - 1-4 hours of focused work typically
- **Testable** - Know when it's done

### 4. Map Dependencies

Identify what blocks what:

```
A ──► B ──► D
      │
      └──► C ──► E

A must complete before B
B must complete before C and D
C must complete before E
D and E can run in parallel after their deps
```

### 5. Determine Order and Parallelism

**Sequential when:**
- Output of one feeds input of next
- Learning from earlier informs later
- Risk needs to be reduced incrementally

**Parallel when:**
- No data dependencies
- Different skill sets
- Can be independently verified

### 6. Present the Breakdown

```markdown
## Problem Decomposition: [Problem Name]

### Goal
[Clear end state]

### Phases

#### Phase 1: [Name] (Foundation)
- [ ] Task 1.1: [Description]
- [ ] Task 1.2: [Description]
**Milestone:** [What's true when phase is done]

#### Phase 2: [Name] (Core)
*Depends on: Phase 1*
- [ ] Task 2.1: [Description]
- [ ] Task 2.2: [Description] (can parallel with 2.1)
**Milestone:** [What's true when phase is done]

#### Phase 3: [Name] (Polish)
*Depends on: Phase 2*
- [ ] Task 3.1: [Description]
**Milestone:** [What's true when phase is done]

### Dependency Graph
[Visual or textual representation]

### Start Here
[First actionable task with clear instructions]
```

## Using Tasks for Complex Decomposition

For very complex problems, analyze different aspects in parallel:

```
Task 1: Identify technical components and dependencies
Task 2: Identify process/workflow steps
Task 3: Identify risks and unknowns

Synthesize into unified breakdown.
```

## Granularity Guidelines

| Scope | Task Size | Example |
|-------|-----------|---------|
| Feature | 1-2 days | "Implement user authentication" |
| Task | 2-4 hours | "Create login form component" |
| Subtask | 30-60 min | "Add email validation" |

Decompose to the level appropriate for tracking. Usually task-level.

## Common Decomposition Patterns

### For Features
```
1. Data model / Schema
2. Backend logic / API
3. Frontend UI
4. Integration / Wiring
5. Testing
6. Documentation
```

### For Migrations
```
1. Prepare (dual-write capability)
2. Migrate (move data)
3. Verify (check correctness)
4. Switch (cut over)
5. Cleanup (remove old)
```

### For Investigations
```
1. Define question clearly
2. Identify information sources
3. Gather data
4. Analyze patterns
5. Form conclusions
6. Verify/validate
```

### For Refactoring
```
1. Characterize current behavior (tests)
2. Identify target structure
3. Incremental moves (one at a time)
4. Verify after each move
5. Clean up
```

## Anti-Patterns

**DON'T:**
- Create tasks with hidden dependencies
- Make tasks too granular (creates overhead)
- Make tasks too vague ("make it better")
- Ignore the critical path

**DO:**
- Make each task independently verifiable
- Identify the riskiest/most uncertain parts early
- Build in checkpoints
- Allow for learning and adjustment

## Output Example

```markdown
## Decomposition: REST to GraphQL Migration

### Goal
Replace REST API with GraphQL while maintaining backwards compatibility.

### Phase 1: Foundation (Week 1)
- [ ] Set up GraphQL server alongside REST
- [ ] Define schema for User and Post types
- [ ] Implement read-only queries
**Milestone:** GraphQL queries work for basic reads

### Phase 2: Feature Parity (Week 2-3)
*Depends on: Phase 1*
- [ ] Add mutations for create/update/delete
- [ ] Implement authentication in GraphQL context
- [ ] Add pagination and filtering
**Milestone:** GraphQL can do everything REST does

### Phase 3: Migration (Week 4)
*Depends on: Phase 2*
- [ ] Update internal clients to use GraphQL
- [ ] Monitor for issues
- [ ] Deprecate REST endpoints
**Milestone:** All traffic on GraphQL

### Start Here
Create `graphql/` directory and install apollo-server. First query: `user(id)`.
```
