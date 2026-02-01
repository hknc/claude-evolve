# Gap Analysis Examples

Examples showing when to recommend new components and when to skip.

## Example 1: Rust Async Refactoring

**Task:** "Refactor auth module to use async traits"

**Analysis:**
- Domain: Rust, async patterns
- Operation: Refactoring

**Gaps:**
- No Rust-specific agent
- No refactoring workflow

**Recommendation:**
- Create `rust-expert` agent (async/await, traits, lifetimes)
- Skip refactoring skill (too generic, existing patterns suffice)

**Reasoning:** Rust async patterns are specialized enough to warrant a dedicated agent. Refactoring workflow is too generic - better handled by existing debugging agents.

---

## Example 2: Simple Bug Fix

**Task:** "Fix the typo in README"

**Analysis:**
- Domain: Documentation
- Operation: Simple edit

**Recommendation:** None - task too simple to benefit from new components.

**Reasoning:** Creating components for trivial tasks wastes time and clutters the toolkit.

---

## Example 3: Kubernetes Debugging

**Task:** "Debug pod crashloop in production"

**Analysis:**
- Domain: Kubernetes, containers
- Operation: Debugging, investigation

**Gaps:**
- No K8s-specific agent

**Recommendation:**
- Create `k8s-debugger` agent

**Reasoning:** K8s debugging requires specific knowledge (kubectl, pod logs, events, resource limits) that justifies a dedicated agent.

---

## Example 4: Generic API Work

**Task:** "Add a new endpoint to the API"

**Analysis:**
- Domain: Web API (generic)
- Operation: Feature development

**Recommendation:** None - too generic.

**Reasoning:** "API" is too broad. Only recommend agents for specific frameworks (FastAPI, Express, Axum) when the user has multiple projects using that framework.

---

## Decision Framework

| Criterion | Recommend | Skip |
|-----------|-----------|------|
| Task complexity | Multi-step, specialized | Simple, one-off |
| Reusability | Will use again | Unlikely to repeat |
| Specificity | Concrete domain (Rust, K8s) | Generic (coding, APIs) |
| Gap severity | No coverage | Partial coverage exists |
