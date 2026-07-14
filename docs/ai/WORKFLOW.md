# Mandatory Engineering Workflow

## 1. Intake

Restate the task internally as:

- user-visible symptom
- expected behavior
- affected platforms
- acceptance criteria
- explicit constraints
- potentially protected behavior

Do not expand scope without evidence.

## 2. Baseline

Before editing:

```bash
git status --short
git diff --stat
```

Identify pre-existing uncommitted changes. Do not overwrite or revert user work.

Run a minimal baseline check relevant to the task when practical.

Examples:

```bash
cd app && flutter analyze
cd admin && php artisan test
docker compose ps
```

Record pre-existing failures separately from regressions introduced by the task.

## 3. Trace the real flow

Create a short flow map.

For Flutter/API issues:

```text
Screen
→ Provider/Controller
→ Repository
→ API Client
→ Endpoint
→ Laravel Route
→ Controller
→ Repository/Service
→ Model/DB
→ Resource/JSON
→ Flutter Model
→ State
→ Widget
```

For audio issues:

```text
User action
→ selected track state
→ queue/audio source
→ player service
→ duration stream
→ position stream
→ UI progress
```

For upload issues:

```text
Form
→ route
→ validation
→ controller
→ repository
→ storage disk
→ media row
→ resource URL
→ app consumer
```

## 4. Reproduce

Do not patch before reproducing where possible.

Use the smallest repeatable reproduction:

- one HTTP request
- one test
- one database record
- one widget action
- one player interaction
- one Docker restart

Capture the failure evidence.

## 5. Root-cause analysis

Separate:

- symptom
- immediate cause
- root cause
- contributing factors
- historical/legacy constraints

A root cause should explain why the failure occurs and why the proposed change fixes it.

## 6. Change plan

Before editing, identify:

- files to change
- files deliberately not changed
- expected behavior
- test strategy
- regression risk
- rollback strategy for deployment/config changes

## 7. Implementation

Rules:

- make the smallest coherent change
- follow current project architecture
- centralize cross-cutting behavior
- avoid temporary compatibility breaks
- do not mix unrelated cleanup
- preserve legacy API fields if other clients may consume them
- use migrations only when schema change is necessary

## 8. Local self-review

Run:

```bash
git diff --check
git diff
```

Review:

- nullability
- async lifecycle
- error handling
- state invalidation
- URL handling
- resource cleanup
- cache invalidation
- security and secrets
- migration reversibility
- localization
- accessibility where UI changed

Search modified areas for temporary code:

```text
TODO
FIXME
HACK
TEMP
print(
debugPrint(
console.log(
dd(
dump(
var_dump(
```

Do not remove intentional existing diagnostics outside the task without justification.

## 9. Quality-gate loop

For each applicable command:

1. run the command
2. inspect failures
3. determine whether pre-existing or introduced
4. fix introduced failures
5. rerun
6. repeat until passing or externally blocked

Never stop at “the command failed.”

## 10. Runtime QA

Static analysis is insufficient for runtime-sensitive paths.

Use:

- real endpoint request
- real media URL check
- test database
- Docker container
- simulator/device
- browser network inspection
- player error stream/log

If runtime verification is unavailable, clearly label it.

## 11. Regression scan

Test nearby behavior, not only the exact changed line.

Examples:

- upload create and update
- play, pause, seek, next, previous
- null image and valid image
- local, relative, and absolute URLs
- active and inactive records
- first page and pagination
- cold start and refresh
- container restart and persistence

## 12. Completion review

A task can be marked complete only when:

- acceptance criteria are checked one by one
- relevant tests pass
- introduced analyzer/build errors are zero
- final diff is reviewed
- unverified runtime items are listed
- no destructive shortcut was used
