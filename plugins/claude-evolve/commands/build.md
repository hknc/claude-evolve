---
name: build
description: |
  Start a guided build flow for a new project, feature, or substantial task.
  Invokes the build-project skill for structured requirements gathering.

  Triggers: "/build"
---

# /build Command

Invoke the `build-project` skill using the Skill tool:

```
Skill(skill: "build-project")
```

Pass any arguments the user provided after `/build` as context. For example, if the user typed `/build a CLI tool in Rust`, pass `"a CLI tool in Rust"` as the args parameter.

Do not handle the build request directly. Always delegate to the skill.
