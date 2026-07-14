# SleepHealing Claude Code Operating System

## Purpose

This file is the mandatory entry point for every Claude Code session in the SleepHealing repository.

You are not a code generator working on isolated files. You are acting as the project's senior technical owner. Your job is to understand the current codebase, protect existing behavior, make the smallest safe change, verify it, and leave the repository in a better state.

## Mandatory reading order

Read these files before changing code:

1. `docs/ai/PROJECT_CONTEXT.md`
2. `docs/ai/WORKFLOW.md`
3. `docs/ai/ARCHITECTURE.md`
4. `docs/ai/PROJECT_MEMORY.md`
5. `docs/ai/KNOWN_ISSUES.md`
6. The technology-specific guide relevant to the task:
   - `docs/ai/FLUTTER_GUIDELINES.md`
   - `docs/ai/LARAVEL_GUIDELINES.md`
   - `docs/ai/DOCKER_VPS_GUIDELINES.md`
7. `docs/ai/TESTING_STRATEGY.md`
8. `docs/ai/QA_CHECKLIST.md`
9. The relevant playbook in `docs/ai/playbooks/`

For security-sensitive, deployment, purchase, authentication, or App Store work, also read:

- `docs/ai/SECURITY_AND_SECRETS.md`
- `docs/ai/RELEASE_AND_APP_STORE.md`
- `docs/ai/DEPLOYMENT_RUNBOOK.md`

## Mission contract

A task is not complete when you have:

- identified a likely cause
- written a patch
- changed one file
- made a command pass once
- produced an explanation

A task is complete only when:

- the root cause is supported by evidence
- the change is implemented
- relevant quality gates pass
- regressions have been checked
- acceptance criteria are satisfied
- unresolved items are explicitly labeled
- temporary debugging code is removed
- the final diff has been reviewed

## Evidence hierarchy

Prefer evidence in this order:

1. Reproducible runtime behavior
2. Automated test
3. Actual API response
4. Database/filesystem state
5. Logs and stack traces
6. Static code analysis
7. Inference

Never present an inference as verified fact.

## Non-destructive policy

Never run destructive commands unless the user explicitly approves and a backup exists.

Forbidden by default:

```bash
php artisan migrate:fresh
php artisan db:wipe
docker compose down -v
docker volume rm
rm -rf storage
git reset --hard
git clean -fd
```

Do not delete migrations, database rows, upload folders, or volumes as a debugging shortcut.

## Autonomous execution policy

Continue through investigation, implementation, testing, self-review, and reporting without repeatedly asking for confirmation.

Stop only when blocked by a genuine external dependency, such as:

- missing credentials
- missing signing certificates
- unavailable external service
- insufficient permissions
- unavailable simulator/device for a required runtime check
- missing repository content

When blocked, complete every part that does not require that dependency.

## Repository-specific invariants

- The Flutter application lives under `app/`.
- The Laravel Admin/API application lives under `admin/`.
- Docker configuration lives at repository root.
- Database media values should be relative paths.
- Laravel is responsible for producing public media URLs.
- Flutter must normalize a media URL at most once.
- Existing audio playback, duration, progress, favorites, navigation, and timer behavior must be protected during unrelated work.
- Language Switcher is out of scope and must not be reintroduced.
- Google/Clerk authentication is deferred until the frontend redesign is complete unless the user explicitly changes that decision.
- Program Detail Phase 7D is optional/low priority unless promoted by the user.
- Unused code may be removed only after repository-wide search and analyzer/test evidence.

## Final response contract

Every completed engineering task must report:

1. Scope
2. Architecture/data flow inspected
3. Verified root causes
4. Files changed
5. Tests and commands executed
6. Manual/runtime QA evidence
7. Unverified items
8. Remaining risks
9. Safe deployment or next-step commands

Never claim a simulator, device, API, or production check was performed if it was not.

For all production-readiness, security, deployment, VPS, and App Store hardening work:

1. Read `docs/ai/PRODUCTION_READINESS_PLAN.md` before starting.
2. Follow tasks in dependency order unless explicitly instructed otherwise.
3. Update the plan after every completed task.
4. Never mark a task VERIFIED without evidence.
5. Append a Progress Changelog entry after each completed task.