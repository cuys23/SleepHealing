# Documentation Maintenance

## When to update Handbook files

Update documentation when a change affects:

- architecture
- API contract
- environment/deployment
- authentication
- storage/media rules
- audio ownership
- product decision
- known issue
- quality gate

## Documentation truth

Do not write speculative architecture as verified.

Use labels:

- Verified
- Historical
- To verify
- Deprecated

## Project memory updates

When the user makes a stable decision, add it to `PROJECT_MEMORY.md`.

When a bug is verified and likely to recur, add it to `KNOWN_ISSUES.md`.

When an architectural choice is made, add an ADR.

## Avoid documentation bloat

Do not copy full code files.

Link to paths and describe invariants, flow, and decisions.
