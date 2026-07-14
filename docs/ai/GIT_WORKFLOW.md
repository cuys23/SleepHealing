# Git Workflow

## Before work

```bash
git status --short
git branch --show-current
git log -1 --oneline
```

Do not overwrite user changes.

## Branches

Use focused branches where workflow permits:

```text
fix/admin-media-storage
fix/flutter-audio-progress
feature/clerk-auth
release/1.x
```

## Commits

A commit should be:

- focused
- buildable
- testable
- descriptive

Examples:

```text
fix(admin): persist playlist media on public disk
fix(player): drive progress from active position stream
test(api): cover relative media URL serialization
```

## Diff hygiene

Before completion:

```bash
git diff --check
git diff --stat
git diff
```

Avoid:

- generated noise not required
- mass formatting
- secret files
- IDE files
- build artifacts

## Reverting

Do not use destructive reset against uncommitted user work.

Prefer targeted revert or restore only after identifying ownership of the changes.
