# SleepHealing AI Engineering Handbook v2

This package is intended to be placed in the SleepHealing repository.

Recommended location:

```text
SleepHealing/
├── CLAUDE.md
└── docs/
    └── ai/
        ├── PROJECT_CONTEXT.md
        ├── WORKFLOW.md
        ├── ...
        ├── playbooks/
        ├── prompts/
        └── adr/
```

## Installation

1. Put the root `CLAUDE.md` in the repository root.
2. Put all remaining files under `docs/ai/`.
3. Open Claude Code from repository root.
4. Begin tasks with a prompt from `docs/ai/prompts/` or explicitly instruct Claude to read `CLAUDE.md`.

## Maintenance

This is a living system.

Update it when:

- architecture changes
- a stable product decision is made
- a recurring bug is discovered
- API contracts change
- deployment/release process changes

## Important limitation

The Handbook encodes verified repository-level facts, historical project decisions, and operating rules. Claude must still inspect current code and runtime before modifying the application.
