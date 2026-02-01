---
paths: ["**/*"]
---

# LSP-First Code Navigation

When navigating code, prefer LSP tools over grep/search for accuracy and speed.

## LSP Tools

Claude Code has a native `LSP` tool. Use it directly:

| Need | LSP Operation | Better Than |
|------|---------------|-------------|
| Find definition | `LSP goToDefinition` | Grep for function name |
| Find references | `LSP findReferences` | Grep for usage |
| Get type info | `LSP hover` | Reading source |
| File structure | `LSP documentSymbol` | Scanning file |
| Find symbols | `LSP workspaceSymbol` | Glob for files |
| Find implementations | `LSP goToImplementation` | Grep for interface |
| Call hierarchy | `LSP incomingCalls` / `outgoingCalls` | Manual tracing |

## When to Use LSP vs Search

| Task | Use |
|------|-----|
| "Where is X defined?" | LSP goToDefinition |
| "What calls X?" | LSP findReferences / incomingCalls |
| "What type is X?" | LSP hover |
| "Find files matching pattern" | Glob |
| "Find text in files" | Grep |

## Why LSP?

- **Accurate**: Understands code semantically, not just text
- **Fast**: Pre-indexed, instant results
- **Context-aware**: Knows about types, scopes, imports

## Fallback

If LSP fails or returns empty, fall back to Grep/Glob with explicit note: "LSP unavailable, using text search."
