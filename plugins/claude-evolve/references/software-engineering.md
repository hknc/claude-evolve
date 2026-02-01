# Software Engineering Quick Reference

**Note:** This is an OPTIONAL reference for software engineering tasks.
Claude-evolve works with ANY domain using Claude's knowledge and research.
This file can be deleted if not needed, or used as a template for other domains.

---

Lightweight reference for guidance agent. Use WebSearch for current/specific guidance.

## Security

### Authentication
- Never store plaintext passwords
- Use established libraries (bcrypt, argon2id)
- Implement rate limiting on auth endpoints
- Consider MFA for sensitive operations
- Token storage: httpOnly cookies > localStorage

### API Security
- Validate all inputs at boundaries
- Use parameterized queries (prevent SQL injection)
- Implement proper CORS policies
- Rate limit public endpoints
- Sanitize output to prevent XSS

### Common Pitfalls
- Secrets in code/logs
- Weak session management
- Missing authorization checks
- Verbose error messages leaking info

## Performance

### Before Optimizing
- Profile first, optimize second
- Measure baseline metrics
- Identify actual bottleneck
- Question if optimization is needed

### Quick Wins
- Database indexes for frequent queries
- Caching expensive operations
- Lazy loading heavy resources
- Connection pooling
- Batch operations where possible

### Warning Signs
- N+1 query patterns
- Unbounded data fetches
- Synchronous I/O in hot paths
- Missing pagination

## Testing

### Strategy by Change Type
| Change | Test Approach |
|--------|---------------|
| Bug fix | Regression test that fails before fix |
| New feature | Unit + integration tests |
| Refactor | Ensure existing tests pass, add if gaps |
| Performance | Benchmark before/after |

### Test Quality
- Test behavior, not implementation
- One assertion per test concept
- Descriptive test names
- Avoid test interdependence

## API Design

### REST Conventions
- Nouns for resources (`/users`, `/orders`)
- HTTP verbs for actions (GET, POST, PUT, DELETE)
- Consistent error response format
- Pagination for list endpoints
- Versioning strategy (URL or header)

### Error Handling
- Use appropriate HTTP status codes
- Include error code for programmatic handling
- Human-readable message
- Don't expose internal details

## Database

### Before Migrations
- Backup data
- Test rollback procedure
- Consider downtime implications
- Check for breaking changes

### Schema Design
- Normalize appropriately (not excessively)
- Index foreign keys
- Consider query patterns
- Plan for growth

## Operations

### Deployment Checklist
- Staging verified?
- Rollback plan ready?
- Monitoring in place?
- Feature flags if needed?

### Incident Response
- Detect -> Triage -> Mitigate -> Resolve -> Learn
- Communicate early and often
- Document timeline and actions

---

*This is a starting reference. Research for current best practices and specific guidance.*
