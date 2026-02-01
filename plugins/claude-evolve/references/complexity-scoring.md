# Sub-Task Complexity Scoring

Reference for determining when to create sub-tasks from phase items.

## Signal Assessment

Each signal is scored Low (1), Medium (2), or High (3).

### Item Count Signal

| Indicator | Score | Examples |
|-----------|-------|----------|
| Few items | Low | 2-3 distinct items |
| Several items | Medium | 4-5 items |
| Many items | High | 6+ items |

### Dependency Signal

| Indicator | Score | Examples |
|-----------|-------|----------|
| Independent | Low | "Update X", "Update Y" - no ordering implied |
| Some ordering | Medium | "Step 1, Step 2" or same-module changes |
| Explicit chain | High | "After X", "Requires Y", "Then Z" |

### Scope Signal

| Indicator | Score | Examples |
|-----------|-------|----------|
| Same area | Low | All items in one file/module |
| Related areas | Medium | Same domain, different modules |
| Cross-cutting | High | Different systems, multiple domains |

### Complexity Signal

| Indicator | Score | Examples |
|-----------|-------|----------|
| Simple operations | Low | "Add field", "Update text", "Rename" |
| Standard work | Medium | "Implement function", "Add endpoint" |
| Complex work | High | "Migrate", "Refactor", "Integrate", "Security" |

## Score Mapping

Sum the signal scores (4-12):

| Total | Action | Announcement |
|-------|--------|--------------|
| 4-6 | Skip sub-tasks | `[claude-evolve] Phase has {N} items, tracking inline. (Say "expand" for sub-tasks)` |
| 7-8 | Suggest sub-tasks | `[claude-evolve] Phase has {N} items with moderate complexity. Create sub-tasks? [y/N]` |
| 9-12 | Auto-create sub-tasks | `[claude-evolve] Creating {N} sub-tasks. Strategy: {sequential\|parallel} ({reason})` |

## Override Rules

| Condition | Effect |
|-----------|--------|
| User says "expand" or "break this down" | Create sub-tasks regardless of score |
| User says "keep it simple" | Skip sub-tasks regardless of score |
| Explicit dependencies detected (High dependency signal) | Minimum action is "suggest" |
| Item count < 2 | Never create sub-tasks (nothing to split) |

## Assessment Process

1. **Count items** in the phase description (numbered lists, bullets, sections)
2. **Score each signal** using the tables above
3. **Sum the scores** (4-12 range)
4. **Check overrides** - user intent or explicit dependencies
5. **Take action** based on score mapping

## Examples

### Example 1: Skip (Score 5)

Phase items:
- Update README
- Add .gitignore
- Bump version number

Assessment:
- Item Count: Low (1) - 3 items
- Dependency: Low (1) - independent tasks
- Scope: Low (1) - all project root files
- Complexity: Low (1) - simple file changes

Total: 4 → **Skip sub-tasks**

### Example 2: Suggest (Score 7)

Phase items:
- Step 1: Add validation schema
- Step 2: Update API endpoint
- Step 3: Add frontend form
- Step 4: Write tests

Assessment:
- Item Count: Medium (2) - 4 items
- Dependency: Medium (2) - numbered steps
- Scope: Medium (2) - API and frontend
- Complexity: Low (1) - standard implementation

Total: 7 → **Suggest sub-tasks**

### Example 3: Auto-create (Score 10)

Phase items:
- Migrate user table to new schema (requires backup first)
- Refactor user repository to use new schema
- Update authentication to handle migration
- Integrate with new identity provider
- Update all user-facing APIs
- Security audit of changes

Assessment:
- Item Count: High (3) - 6 items
- Dependency: High (3) - explicit requirements
- Scope: High (3) - multiple systems
- Complexity: High (3) - migration, security

Total: 12 → **Auto-create sub-tasks (sequential)**

### Example 4: Override

Phase items:
- Fix typo in config
- Update constant value

User says: "expand this phase"

Assessment: Score would be 4 (skip)
Override: User requested expansion → **Create sub-tasks**

## Related Files

- `../commands/workflow.md` - Uses this scoring in section 3.5
- `../skills/workflow/SKILL.md` - References this algorithm
- `../skills/prepare-task/references/depth-patterns.md` - Similar scoring pattern for task depth
