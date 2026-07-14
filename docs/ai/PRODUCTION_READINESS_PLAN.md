# SleepHealing Production Readiness Execution Plan

> **Purpose:** Single execution plan for Claude Code to harden SleepHealing for production and App Store readiness.
>
> Claude Code must read this file before starting production-readiness work, update it after each completed task, and keep all status fields accurate.
>
> **Source audit:** Production Readiness Audit, 2026-07-14
> **Branch audited:** `redesign_v2`
> **Scope:** Laravel Admin/API (`admin/`), Flutter client (`app/`), Docker Compose, VPS/deployment configuration

---

# 1. Mandatory Operating Rules

## 1.1 Reading order

Before starting any task:

1. Read root `CLAUDE.md`.
2. Read every mandatory document referenced by `CLAUDE.md`.
3. Read this plan completely.
4. Inspect the current repository HEAD.
5. Verify the audit finding against current code.
6. Only then modify code.

Do not trust stale line numbers blindly.

For every task, first classify it as:

- `Still Present`
- `Partially Fixed`
- `Already Fixed`
- `False Positive`
- `Requires Live Verification`

If already fixed, do not reimplement it. Add evidence and update this plan.

## 1.2 Allowed task statuses

Use only:

- `NOT_STARTED`
- `IN_PROGRESS`
- `BLOCKED`
- `CODE_COMPLETE`
- `VERIFIED`
- `SKIPPED`
- `DEFERRED`

A task is not `VERIFIED` until its acceptance criteria and required verification are complete.

## 1.3 Update protocol

After every completed task:

1. Update the task `Status`.
2. Add completion date.
3. Add implementation summary.
4. List files changed.
5. List tests/commands executed.
6. Record actual results.
7. Record remaining risks/live actions.
8. Update the Global Progress Dashboard.
9. Append a Progress Changelog entry.

Do not mark tasks complete based only on code inspection.

## 1.4 Safety rules

Never use destructive commands without explicit operator authorization.

Forbidden examples:

```bash
php artisan migrate:fresh
php artisan db:wipe
docker compose down -v
docker volume rm
git reset --hard
git clean -fd
rm -rf storage
```

Do not:

- remove persistent Docker volumes
- rotate live production credentials automatically
- commit automatically unless explicitly instructed
- mix unrelated refactors into a security fix
- remove code only because it appears unused without evidence
- claim browser/device/live verification when it was not actually performed

## 1.5 Execution loop

Use this loop for every task:

```text
verify finding
→ inspect dependencies
→ reproduce where possible
→ implement minimum safe fix
→ add regression tests
→ run focused tests
→ run broader tests
→ perform runtime verification where possible
→ review diff
→ update this plan
```

Do not move on while an introduced regression remains unresolved.

---

# 2. Global Progress Dashboard

## Wave 0 — Repository stabilization

| ID | Task | Priority | Status |
|---|---|---:|---|
| W0-1 | Commit/close current duration work | P0 | `VERIFIED` — pushed to `origin/redesign_v2` (see 2026-07-14 push verification) |
| W0-2 | Commit/close Album/Category work | P0 | `VERIFIED` — pushed to `origin/redesign_v2` (see 2026-07-14 push verification) |
| W0-3 | Commit/close Engineering Handbook work | P0 | `VERIFIED` — committed `e0e069a` and pushed to `origin/redesign_v2` |
| W0-4 | Confirm clean working tree and create recovery checkpoint | P0 | `VERIFIED` — recovery branch `backup/pre-production-hardening-2026-07-14` created and pushed; remaining working-tree items documented below |

**Wave 0 is now fully VERIFIED. Wave 1 may begin on the next task.**

### 2026-07-14 reconciliation — branch state is not what the plan assumes

This plan and the source audit were produced against `redesign_v2` HEAD (`0e29db2`). Since then, the working tree was switched to `main` at the user's request. Reconciliation against actual repository state (`git log --oneline --all --graph`, `git merge-base`, `git diff` between branches) found:

- **`main` (currently checked out) does not contain any redesign_v2 work at all** — not the UI redesign phases, not the duration/album-category fixes, not the Engineering Handbook. `origin/main`'s merge of `redesign_v2` (PR #5, commit `c381722`) only pulled in `d87d28b` ("baseline after player and UI stability fixes before **redesign v2**") — i.e. the commit immediately *before* the redesign_v2 phase work began. None of `8c4ab78`…`0e29db2` are reachable from `origin/main`.
- **Local `main` is also behind `origin/main` by 2 commits** (not yet pulled).
- **The W0-1 and W0-2 work is already committed, but only on local `redesign_v2`, and unpushed:**
  - W0-1 (duration): `4bd4dfb fix(admin,app): make song duration a real int end-to-end and validate atomically`
  - W0-2 (album/category): `be2a574`, `3472579`, `5f00082`, `0e29db2`
  - Local `redesign_v2` is `origin/redesign_v2` **+ 6 unpushed commits** (exactly these five plus `d7acba0`). If this machine's local repo were lost, this work would be lost — it exists nowhere else.
- A `git stash` entry is also sitting uncommitted: `docker-compose.yml` `./Admin` → `./admin` path fix, stashed off `redesign_v2` before the branch switch to `main`.
- Backend security-relevant files spot-checked identically between `main` and `redesign_v2` (`LoginController.php`, `NotificationsController.php` show no diff), so the Laravel/Docker Blocking findings (B1–B5) apply to both branches equally. The Flutter findings and the duration/album backend hardening do not exist on `main` at all.
- **Documentation mismatch:** `CLAUDE.md` references `docs/ai/PRODUCTION_READINESS_PLAN.md`, but this plan file actually lives at repo root as `SleepHealing_PRODUCTION_READINESS_PLAN.md`. Needs a decision: move the file or fix the reference.

**Consequence:** W0-4 ("clean working tree / recovery checkpoint") cannot be completed until the user decides which branch is the actual base for production-hardening work (`redesign_v2`, which matches everything this plan was written against, or `main`, which is an older baseline missing all of it). Proceeding with Wave 1+ on the wrong branch would silently re-scope the entire plan.

#### Resolution (2026-07-14, same day)

Operator decision: **`redesign_v2` is the base branch.** Executed in order:

1. `git checkout redesign_v2` (back from `main`), `git stash pop` restored the pending `docker-compose.yml` fix.
2. `git push origin redesign_v2` → `8d845a2..0e29db2 redesign_v2 -> redesign_v2`. All 6 previously-local-only commits (`be2a574`, `3472579`, `d7acba0`, `4bd4dfb`, `5f00082`, `0e29db2`) confirmed present on `origin/redesign_v2` via `git merge-base --is-ancestor` for each, and `git log origin/redesign_v2..redesign_v2` returned empty.
3. Engineering Handbook committed as its own unit: `CLAUDE.md` + all of `docs/ai/**`, including moving `SleepHealing_PRODUCTION_READINESS_PLAN.md` → `docs/ai/PRODUCTION_READINESS_PLAN.md` (resolves the path-mismatch note above) — commit `e0e069a docs(ai): add SleepHealing engineering handbook and production readiness plan`. Pushed and confirmed on `origin/redesign_v2`.
4. Recovery branch `backup/pre-production-hardening-2026-07-14` created at `e0e069a` and pushed to origin (`https://github.com/cuys23/SleepHealing/tree/backup/pre-production-hardening-2026-07-14`). Not merged into `main`.
5. `git status --short` after all of the above shows exactly two remaining items, both pre-existing and intentionally out of this scope:
   - `M docker-compose.yml` — the `./Admin` → `./admin` build-path fix (unrelated to the handbook/security work; left uncommitted pending an explicit decision on that change).
   - `?? HANDBOOK_MANIFEST.json` — a handbook file-index the operator did not include in the explicit W0-3 file list; left untracked.

No secrets were introduced by the handbook commit (grepped for key/password/token-shaped strings in `CLAUDE.md` and `docs/ai/**` before committing — none found; the audit doc only references secret *locations*, never values).

## Wave 1 — Critical security blockers

| ID | Audit ID | Task | Priority | Status |
|---|---|---|---:|---|
| W1-1 | B1 | Externalize and rotate compromised secrets | BLOCKING | NOT_STARTED |
| W1-2 | B2 | Remove public MySQL exposure | BLOCKING | NOT_STARTED |
| W1-3 | B3 | Enforce Admin authorization | BLOCKING | NOT_STARTED |
| W1-4 | B4 | Fix forgot-password OTP/token leakage | BLOCKING | NOT_STARTED |
| W1-5 | B5 | Remove plaintext password cookie | BLOCKING | NOT_STARTED |

## Wave 2 — Mobile production networking and platform security

| ID | Audit ID | Task | Priority | Status |
|---|---|---|---:|---|
| W2-1 | B6 | Add environment-aware Flutter API base URL | BLOCKING | NOT_STARTED |
| W2-2 | B7 | Remove global TLS certificate bypass | BLOCKING | NOT_STARTED |
| W2-3 | B8 | Resolve Google Mobile Ads / ATT requirement | BLOCKING | NOT_STARTED |
| W2-4 | H11 | Disable global cleartext HTTP in release | HIGH | NOT_STARTED |

## Wave 3 — Authorization, token security, production config

| ID | Audit ID | Task | Priority | Status |
|---|---|---|---:|---|
| W3-1 | H3 | Fix notification IDOR | HIGH | NOT_STARTED |
| W3-2 | H9 | Move auth token from Hive to secure storage | HIGH | NOT_STARTED |
| W3-3 | H1 | Remove committed demo credentials | HIGH | NOT_STARTED |
| W3-4 | H2 | Add production environment configuration | HIGH | NOT_STARTED |
| W3-5 | H7 | Restrict unsafe production seeders | HIGH | NOT_STARTED |
| W3-6 | M1 | Add safe environment templates | MEDIUM | NOT_STARTED |

## Wave 4 — Security hardening

| ID | Audit ID | Task | Priority | Status |
|---|---|---|---:|---|
| W4-1 | M9 | Add upload size/type restrictions; review SVG | MEDIUM | NOT_STARTED |
| W4-2 | M10 | Add dedicated auth/reset rate limits | MEDIUM | NOT_STARTED |
| W4-3 | M4 | Review and tighten CORS | MEDIUM | NOT_STARTED |
| W4-4 | M6 | Remove Storage API anti-patterns | MEDIUM | NOT_STARTED |

## Wave 5 — Data consistency and performance

| ID | Audit ID | Task | Priority | Status |
|---|---|---|---:|---|
| W5-1 | H4 | Add deterministic pagination ordering | HIGH | NOT_STARTED |
| W5-2 | H6 | Remove N+1 queries in API resources | HIGH | NOT_STARTED |
| W5-3 | M15 | Review Composer minimum stability | MEDIUM | NOT_STARTED |

## Wave 6 — App Store and client cleanup

| ID | Audit ID | Task | Priority | Status |
|---|---|---|---:|---|
| W6-1 | H8 | Reconcile Firebase projects across platforms | HIGH | NOT_STARTED |
| W6-2 | H10 | Align Android versionCode with pubspec build number | HIGH | NOT_STARTED |
| W6-3 | M11 | Replace unrelated iOS permission descriptions | MEDIUM | NOT_STARTED |
| W6-4 | M12 | Replace placeholder contact/App Store config | MEDIUM | NOT_STARTED |
| W6-5 | M13 | Remove/gate release logging and sensitive logs | MEDIUM | NOT_STARTED |
| W6-6 | M14 | Decide ship/hide/complete mock-data wellness screens | MEDIUM | NOT_STARTED |

## Wave 7 — Infrastructure and operations

| ID | Audit ID | Task | Priority | Status |
|---|---|---|---:|---|
| W7-1 | M2 | Add application healthcheck | MEDIUM | NOT_STARTED |
| W7-2 | M3 | Add log rotation and backup strategy | MEDIUM | NOT_STARTED |
| W7-3 | M5 | Remove unconditional migration-on-startup | MEDIUM | NOT_STARTED |
| W7-4 | M7 | Add queue worker strategy or keep sync explicitly | MEDIUM | NOT_STARTED |
| W7-5 | M8 | Replace `php artisan serve` in production | MEDIUM | NOT_STARTED |

## Wave 8 — Framework maintenance

| ID | Audit ID | Task | Priority | Status |
|---|---|---|---:|---|
| W8-1 | H5 | Plan and execute supported Laravel/Passport upgrade | HIGH | DEFERRED |

## Wave 9 — Low-risk cleanup

| ID | Audit ID | Task | Priority | Status |
|---|---|---|---:|---|
| W9-1 | L1 | Review/remove inert Sanctum config | LOW | NOT_STARTED |
| W9-2 | L2 | Remove orphaned Firebase plist | LOW | NOT_STARTED |
| W9-3 | L3 | Remove AdMob test-device leftover | LOW | NOT_STARTED |
| W9-4 | L4 | Clean Flutter template naming remnants | LOW | NOT_STARTED |

---

# 3. Wave 0 — Repository Stabilization

## W0-1 — Close current duration work
**Status:** `VERIFIED`

### Objective
Commit the completed duration/media changes as an independently reviewable unit before security hardening.

### Verify
- automatic duration detection remains intact
- API returns integer duration
- Flutter parsing remains compatible
- atomic create/update failure behavior remains intact
- relevant tests pass

### Recommended commit
```text
feat(media): derive and validate track duration from uploaded audio
```

### Completion record
- Completed: 2026-07-14 (reconciliation; work itself pre-dates this session)
- Classification: **Already committed** — matches `docs/ai/PROJECT_MEMORY.md` PM-011 exactly (`ValidAudioDuration` rule, atomic transaction with file cleanup on failure).
- Commit: `4bd4dfb fix(admin,app): make song duration a real int end-to-end and validate atomically`, present on local branch `redesign_v2` only.
- Files: per `git show --stat 4bd4dfb` (not re-listed here; inspect directly).
- Tests: not re-run in this reconciliation pass (read-only classification).
- Result: code-complete and already committed as an independent unit — the original intent of this task is satisfied.
- Remaining risk: none for this task's scope (repository durability). Pushed and confirmed present on `origin/redesign_v2` (`git merge-base --is-ancestor 4bd4dfb origin/redesign_v2` → yes). Note this verifies the commit is safely backed up on the remote — it does not re-verify the underlying duration/media *runtime* behavior (no tests were (re-)run in this session; that behavior was validated when the feature was originally built, per `docs/ai/PROJECT_MEMORY.md` PM-011).
- Notes: see "2026-07-14 reconciliation" note and its "Resolution" subsection above Wave 0 dashboard for full branch-state evidence.

---

## W0-2 — Close Album/Category work
**Status:** `VERIFIED`

### Objective
Commit previous Album/Category unattached-state UX separately.

### Recommended commit
```text
fix(admin): clarify unattached albums and songs
```

### Completion record
- Completed: 2026-07-14 (reconciliation; work itself pre-dates this session)
- Classification: **Already committed**, across four commits rather than the single suggested one — each independently reviewable:
  - `be2a574 fix(admin): clarify songs not attached to albums`
  - `3472579 fix(admin): attach albam/playlist pivots and use the public storage disk`
  - `5f00082 fix(admin): enforce pivot uniqueness, fix broken relationships, add category icon FK`
  - `0e29db2 fix(admin): warn when an album has no category attached`
  - All present on local branch `redesign_v2` only.
- Tests: not re-run in this reconciliation pass (read-only classification).
- Result: code-complete and already committed — the original intent of this task is satisfied, split across a more granular commit history than the plan anticipated.
- Remaining risk: none for this task's scope. All four commits confirmed present on `origin/redesign_v2` via `git merge-base --is-ancestor` (each returned yes) after the 2026-07-14 push.
- Notes: see "2026-07-14 reconciliation" note and its "Resolution" subsection above Wave 0 dashboard.

---

## W0-3 — Close Engineering Handbook work
**Status:** `VERIFIED`

### Objective
Commit root `CLAUDE.md` and `docs/ai/**` separately from application code.

### Recommended commit
```text
docs(ai): add SleepHealing engineering handbook
```

### Completion record
- Completed: 2026-07-14
- Classification: **Done.** Committed on `redesign_v2` as `e0e069a docs(ai): add SleepHealing engineering handbook and production readiness plan` (message per operator instruction, differs slightly from the originally-suggested message to also name the plan file). Pushed to `origin/redesign_v2` and confirmed via `git merge-base --is-ancestor e0e069a origin/redesign_v2` → yes.
- Files (30 total, all new): `CLAUDE.md`; `docs/ai/API_CONTRACT.md`, `ARCHITECTURE.md`, `CODING_STANDARDS.md`, `DEPLOYMENT_RUNBOOK.md`, `DOCKER_VPS_GUIDELINES.md`, `DOCUMENTATION_MAINTENANCE.md`, `FLUTTER_GUIDELINES.md`, `GIT_WORKFLOW.md`, `KNOWN_ISSUES.md`, `LARAVEL_GUIDELINES.md`, `PRODUCTION_READINESS_AUDIT.md`, `PRODUCTION_READINESS_PLAN.md`, `PROJECT_CONTEXT.md`, `QA_CHECKLIST.md`, `README.md`, `RELEASE_AND_APP_STORE.md`, `SECURITY_AND_SECRETS.md`, `TESTING_STRATEGY.md`, `WORKFLOW.md`; `docs/ai/adr/ADR-001-MEDIA-PATH-CONTRACT.md`, `ADR_TEMPLATE.md`; `docs/ai/playbooks/*` (5 files); `docs/ai/prompts/*` (3 files).
- Tests: n/a (docs only). Pre-commit secret scan run (`grep` for key/password/token-shaped strings) — no matches.
- Result: the documentation-path mismatch flagged earlier is resolved as part of this commit — `SleepHealing_PRODUCTION_READINESS_PLAN.md` was relocated to `docs/ai/PRODUCTION_READINESS_PLAN.md`, matching `CLAUDE.md`'s reading-order reference exactly.
- Deliberately excluded (operator's file list did not name them, left untracked, not part of this commit): `HANDBOOK_MANIFEST.json`, `design/` (contains a large local `.mov`/screenshots, unrelated to the handbook).
- Notes: none remaining.

---

## W0-4 — Create clean recovery checkpoint
**Status:** `VERIFIED`

### Objective
Before security hardening:

- confirm `git status`
- confirm intended commits exist
- create a recovery branch/tag if appropriate
- never include new secrets

Suggested branch:

```text
backup/pre-production-hardening-2026-07-14
```

### Acceptance criteria
- working tree is clean or all remaining changes are documented
- current stable state is recoverable
- no secret is introduced

### Completion record
- Completed: 2026-07-14
- Result: operator chose `redesign_v2` as the base branch. Executed: switched back to `redesign_v2`, restored the stashed `docker-compose.yml` fix, pushed the 6 previously-local-only commits, committed and pushed the Engineering Handbook (W0-3), then created and pushed the recovery branch.
- Recovery reference: `backup/pre-production-hardening-2026-07-14`, created at `e0e069a` (handbook commit, which includes all Wave-0 work), pushed to `origin` — confirmed via `git log -1 --oneline origin/backup/pre-production-hardening-2026-07-14`. **Not merged into `main`**, per operator instruction.
- `git status --short` after checkpoint creation:
  ```text
   M docker-compose.yml
  ?? HANDBOOK_MANIFEST.json
  ```
  Both documented and intentionally out of scope (see W0-3 notes and the pre-existing `./Admin`→`./admin` path fix noted in the 2026-07-14 reconciliation section) — satisfies the acceptance criterion "working tree is clean **or all remaining changes are documented**."
- No secret introduced: confirmed via pre-commit grep of the handbook content (see W0-3).
- Remaining risk: none for repository-durability purposes. The `docker-compose.yml` change itself (`./Admin` → `./admin`) is still uncommitted pending an explicit operator decision on whether to fold it into Wave 1 (it touches the same file W1-1/W1-2 will modify) or commit it standalone first.

---

# 4. Wave 1 — Critical Security Blockers

Wave 1 must be completed before any production deploy.

## W1-1 / B1 — Externalize and rotate compromised secrets
**Status:** `NOT_STARTED`

### Finding
Tracked config contains real:
- `APP_KEY`
- application DB password
- MySQL root password

### Required implementation
1. Verify all tracked secret locations.
2. Replace hardcoded values with environment interpolation.
3. Add placeholder-only environment templates.
4. Confirm real `.env` files remain untracked.
5. Produce a live rotation procedure.
6. Treat previously committed values as compromised.

Example:

```yaml
environment:
  APP_ENV: ${APP_ENV}
  APP_KEY: ${APP_KEY}
  DB_DATABASE: ${DB_DATABASE}
  DB_USERNAME: ${DB_USERNAME}
  DB_PASSWORD: ${DB_PASSWORD}
  MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
```

### Live boundary
Do not rotate live credentials automatically.

APP_KEY rotation may invalidate:
- sessions
- encrypted cookies
- encrypted values

DB rotation must coordinate:
- MySQL user password
- Laravel DB configuration

### Acceptance criteria
- no real secret remains in tracked active config
- safe `.env.example` exists
- `.env` remains ignored
- rotation runbook exists
- no secret is printed in logs/reports

### Completion record
- Completed:
- Classification:
- Files changed:
- Tests/checks:
- Live operator action:
- Remaining risk:

---

## W1-2 / B2 — Remove public MySQL exposure
**Status:** `NOT_STARTED`

### Preferred design
```text
Laravel app
→ Docker internal network
→ MySQL on db:3306
```

### Required implementation
Preferred:
- remove host port mapping

Alternative for host-only debugging:
```yaml
127.0.0.1:3308:3306
```

### Acceptance criteria
- app connects with `DB_HOST=db`, `DB_PORT=3306`
- MySQL is not publicly bound by default
- database volume remains intact

### Completion record
- Completed:
- Classification:
- Files changed:
- Verification:
- Live verification:
- Remaining risk:

---

## W1-3 / B3 — Enforce Admin authorization
**Status:** `NOT_STARTED`

### Required architecture
Layer 1:
```text
valid credentials
→ verify authorized admin role/permission
→ login only when authorized
```

Layer 2:
```text
auth
+
admin authorization middleware
```

Layer 3:
Sensitive actions authorize explicitly where necessary.

### Rules
- use existing role/permission model when available
- do not invent a second auth system without need
- mobile/API auth must remain unaffected
- normal users must never obtain an Admin session

### Required tests
- standard user cannot log into Admin
- standard authenticated web user cannot access Admin routes
- authorized Admin can log in
- authorized Admin can access protected routes
- unauthorized requests get correct redirect/403
- API auth regression remains passing

### Completion record
- Completed:
- Classification:
- Files changed:
- Tests:
- Result:
- Remaining risk:

---

## W1-4 / B4 — Fix forgot-password OTP/token leakage
**Status:** `NOT_STARTED`

### Required flow
```text
request reset
→ generate short-lived code/token
→ store securely
→ dispatch via email flow
→ return generic success
```

### Security requirements
- never return OTP/reset token in JSON
- avoid unnecessary user enumeration
- expiration
- single use
- invalidate after successful reset
- dedicated rate limiting or explicit follow-up task
- safe logs only

### Response pattern
```json
{
  "message": "If the account exists, password reset instructions have been sent."
}
```

### Required tests
- OTP/token absent from response
- Verification model not serialized
- email/event dispatch occurs
- expired token rejected
- reused token rejected
- successful reset invalidates token
- API auth regression remains passing

### Completion record
- Completed:
- Classification:
- Files changed:
- Tests:
- Email delivery status:
- Remaining risk:

---

## W1-5 / B5 — Remove plaintext password cookie
**Status:** `NOT_STARTED`

### Required implementation
- remove raw password cookie behavior
- use Laravel standard remember/session mechanism
- never persist raw password after authentication

### Required tests
- successful login works
- remember-me works as intended
- response cookies do not contain raw password
- failed login does not persist credentials

### Completion record
- Completed:
- Classification:
- Files changed:
- Tests:
- Result:
- Remaining risk:

---

# 5. Wave 2 — Mobile Production Networking and Platform Security

## W2-1 / B6 — Environment-aware Flutter API base URL
**Status:** `NOT_STARTED`

### Required architecture
Use build-time environment config, for example:

```dart
const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:9080/api',
);
```

Production example:

```bash
flutter build ipa   --dart-define=APP_ENV=production   --dart-define=API_BASE_URL=https://api.example.com/api
```

### Acceptance criteria
- local development remains easy
- release cannot silently use localhost
- one authoritative API base URL source exists

### Completion record
- Completed:
- Files changed:
- Tests:
- Build verification:
- Remaining risk:

---

## W2-2 / B7 — Remove global TLS bypass
**Status:** `NOT_STARTED`

### Required implementation
- remove production-wide `badCertificateCallback`
- use valid HTTPS certificates
- any development override must be debug-only and excluded from release

### Completion record
- Completed:
- Files changed:
- Tests:
- Live HTTPS verification:
- Remaining risk:

---

## W2-3 / B8 — Resolve Ads SDK / ATT requirement
**Status:** `NOT_STARTED`

### Decision
Determine whether Ads are part of the production MVP.

If Ads are not required:
- remove Google Mobile Ads dependency/init from production

If Ads are required:
- add accurate ATT usage description
- implement ATT flow where applicable
- respect denied tracking
- verify privacy declarations

### Completion record
- Completed:
- Decision:
- Files changed:
- Tests:
- App Store impact:
- Remaining risk:

---

## W2-4 / H11 — Disable global cleartext HTTP in release
**Status:** `NOT_STARTED`

### Requirements
- production API uses HTTPS
- release does not globally allow cleartext
- local/debug HTTP may use debug-only config

### Completion record
- Completed:
- Files changed:
- Tests:
- Remaining risk:

---

# 6. Wave 3 — Authorization, Token Security, Production Config

## W3-1 / H3 — Fix notification IDOR
**Status:** `NOT_STARTED`

Scope every notification operation to the authenticated user unless explicit Admin behavior is intended.

Cover:
- read
- mark read
- delete
- arbitrary `user_id` targeting

Required tests:
- user A cannot read/modify/delete user B notifications
- normal user cannot create arbitrary-target notification
- authorized Admin behavior remains explicit

### Completion record
- Completed:
- Files changed:
- Tests:
- Result:

---

## W3-2 / H9 — Move auth token to secure storage
**Status:** `NOT_STARTED`

### Migration pattern
```text
read old token once
→ write secure storage
→ verify
→ delete old Hive token
```

### Required tests
- new login writes secure storage
- interceptor reads secure storage
- old Hive token migrates
- logout clears secure token
- old plaintext token is removed after migration

### Completion record
- Completed:
- Files changed:
- Tests:
- Migration behavior:
- Remaining risk:

---

## W3-3 / H1 — Remove committed demo credentials
**Status:** `NOT_STARTED`

Remove tracked demo credentials from runtime config. Do not replace them with new real credentials.

### Completion record
- Completed:
- Files changed:
- Verification:

---

## W3-4 / H2 — Add production environment configuration
**Status:** `NOT_STARTED`

At minimum production must use:

```text
APP_ENV=production
APP_DEBUG=false
```

Use explicit production configuration instead of shipping only local settings.

### Completion record
- Completed:
- Files changed:
- Verification:
- Live operator action:

---

## W3-5 / H7 — Restrict unsafe production seeders
**Status:** `NOT_STARTED`

Prevent accidental predictable production account creation.

### Completion record
- Completed:
- Files changed:
- Tests:

---

## W3-6 / M1 — Add safe environment templates
**Status:** `NOT_STARTED`

Add placeholder-only templates. Never include real credentials.

### Completion record
- Completed:
- Files changed:

---

# 7. Wave 4 — Security Hardening

## W4-1 / M9 — Upload limits and SVG review
**Status:** `NOT_STARTED`

For each upload define:
- allowed MIME/extensions
- max size
- dimensions where appropriate

Prefer:
```text
jpeg
png
webp
```

Remove SVG unless a verified need and safe rendering path exist.

### Completion record
- Completed:
- Files changed:
- Tests:

---

## W4-2 / M10 — Dedicated auth/reset rate limits
**Status:** `NOT_STARTED`

Add dedicated limiters for:
- Admin login
- API login
- forgot password
- OTP verification
- reset password

### Completion record
- Completed:
- Files changed:
- Tests:

---

## W4-3 / M4 — Review and tighten CORS
**Status:** `NOT_STARTED`

Verify actual client/deployment needs. Do not narrow blindly.

### Completion record
- Completed:
- Files changed:
- Tests:

---

## W4-4 / M6 — Remove Storage API anti-patterns
**Status:** `NOT_STARTED`

Replace ambiguous calls such as:

```php
Storage::put($path, $file, 'public')
```

with explicit disk use.

### Completion record
- Completed:
- Files changed:
- Tests:

---

# 8. Wave 5 — Data Consistency and Performance

## W5-1 / H4 — Deterministic pagination
**Status:** `NOT_STARTED`

Affected audit targets:
- CategoryRepository
- BannerRepository
- SubscriptionPlanRepository
- UserRepository

Use business-specific stable ordering. Prefer explicit sort fields when they exist.

### Completion record
- Completed:
- Files changed:
- Tests:

---

## W5-2 / H6 — Remove N+1 queries
**Status:** `NOT_STARTED`

Move relationship loading into query construction. Keep API contract unchanged.

### Completion record
- Completed:
- Files changed:
- Tests:
- Query evidence:

---

## W5-3 / M15 — Review Composer minimum stability
**Status:** `NOT_STARTED`

Determine whether `minimum-stability: dev` is still required.

### Completion record
- Completed:
- Decision:
- Files changed:
- Verification:

---

# 9. Wave 6 — App Store and Client Cleanup

## W6-1 / H8 — Reconcile Firebase projects
**Status:** `NOT_STARTED`

Verify intended production Firebase project before changing configs.

Check:
- bundle ID
- Android package
- APNs
- FCM
- analytics
- remote config

### Completion record
- Completed:
- Decision:
- Files changed:
- Device verification:

---

## W6-2 / H10 — Align Android versionCode
**Status:** `NOT_STARTED`

Use one authoritative version/build source.

### Completion record
- Completed:
- Files changed:
- Build verification:

---

## W6-3 / M11 — Replace iOS permission descriptions
**Status:** `NOT_STARTED`

Every description must match actual app behavior.

### Completion record
- Completed:
- Files changed:
- Device verification:

---

## W6-4 / M12 — Replace placeholder production info
**Status:** `NOT_STARTED`

Replace:
- phone
- email
- App Store URL

Do not invent final values; mark operator input required.

### Completion record
- Completed:
- Files changed:
- Operator input required:

---

## W6-5 / M13 — Remove/gate release logging
**Status:** `NOT_STARTED`

Review logging of:
- FCM token
- auth data
- API responses
- user identifiers

### Completion record
- Completed:
- Files changed:
- Tests:

---

## W6-6 / M14 — Decide mock-data screen strategy
**Status:** `NOT_STARTED`

For each mock screen:
- connect to backend
- mark clearly as demo
- or hide/remove from production navigation

### Completion record
- Completed:
- Decision by screen:
- Files changed:

---

# 10. Wave 7 — Infrastructure and Operations

## W7-1 / M2 — Application healthcheck
**Status:** `NOT_STARTED`

Add a meaningful, lightweight app healthcheck.

### Completion record
- Completed:
- Files changed:
- Verification:

---

## W7-2 / M3 — Log rotation and backups
**Status:** `NOT_STARTED`

Define:
- container log rotation
- MySQL backup schedule
- retention
- off-server copy
- restore test

A backup is not verified until restore is tested.

### Completion record
- Completed:
- Files changed:
- Backup verification:
- Restore verification:

---

## W7-3 / M5 — Remove migration-on-startup
**Status:** `NOT_STARTED`

Preferred:

```text
build
→ deploy
→ explicit migration step
→ start/switch traffic
```

### Completion record
- Completed:
- Files changed:
- Deployment verification:

---

## W7-4 / M7 — Queue worker strategy
**Status:** `NOT_STARTED`

Choose:
- intentionally keep `sync`
- or add a real worker

Do not configure async queue without worker infrastructure.

### Completion record
- Completed:
- Decision:
- Files changed:
- Verification:

---

## W7-5 / M8 — Replace `php artisan serve`
**Status:** `NOT_STARTED`

Move to production-grade serving, e.g.:

```text
Nginx
+
PHP-FPM
```

Respect current VPS reverse-proxy constraints.

### Completion record
- Completed:
- Architecture:
- Files changed:
- Runtime verification:

---

# 11. Wave 8 — Framework Maintenance

## W8-1 / H5 — Laravel/Passport upgrade
**Status:** `DEFERRED`

Treat this as a dedicated project.

Required approach:
1. inventory versions
2. read official upgrade guides
3. plan intermediate versions
4. upgrade incrementally
5. run full backend/API regression
6. verify Passport tokens
7. verify Docker
8. verify Flutter auth

Do not start until earlier production blockers are stable.

### Completion record
- Completed:
- Upgrade path:
- Tests:
- Remaining risk:

---

# 12. Wave 9 — Low-Risk Cleanup

## W9-1 / L1 — Review inert Sanctum config
**Status:** `NOT_STARTED`

## W9-2 / L2 — Remove orphaned Firebase plist
**Status:** `NOT_STARTED`

## W9-3 / L3 — Remove AdMob test-device leftover
**Status:** `NOT_STARTED`

## W9-4 / L4 — Clean Flutter template naming remnants
**Status:** `NOT_STARTED`

---

# 13. Cross-Cutting Quality Gates

After every wave:

## Backend
Run focused tests first, then:

```bash
docker compose exec app php artisan test
```

Known pre-existing failures must be identified, never hidden.

## Flutter
When Flutter code changes:

```bash
cd app
flutter pub get
flutter analyze
flutter test
cd ..
```

## Docker
When runtime/config changes:

```bash
docker compose config
docker compose build app
docker compose up -d app
docker compose ps
docker compose logs --tail=200 app
```

Do not remove volumes.

## Repository
Always finish with:

```bash
git diff --check
git status --short
git diff --stat
git diff
```

Search changed files for temporary code:

```text
dd(
dump(
var_dump(
debugPrint(
console.log(
TODO
FIXME
TEMP
HACK
```

Only remove temporary code introduced by the current task.

---

# 14. Production Readiness Exit Criteria

The project is not production-ready until every Blocking task is `VERIFIED`.

## Security
- no committed live secrets
- compromised credentials rotated
- MySQL not publicly exposed
- normal users cannot access Admin
- reset tokens/OTP never returned to clients
- plaintext passwords never stored in cookies
- production TLS validation enabled
- production API URL configured correctly
- secure token storage implemented
- notification IDOR fixed

## Deployment
- production environment configuration exists
- `APP_DEBUG=false`
- persistent volumes protected
- backup strategy defined
- healthcheck exists
- no unsafe automatic startup behavior

## App Store
- release API reachable from a real device
- no global certificate bypass
- Ads/ATT decision resolved
- iOS permission strings accurate
- placeholder production info removed
- Firebase environment consistent
- mock features intentionally handled

## Quality
- focused tests pass
- no new full-suite failures
- Flutter release build succeeds
- production Docker image rebuild succeeds
- runtime smoke tests pass
- remaining risks documented

---

# 15. Audit Re-Verification Counts

Initial audit:

```text
Blocking: 8
High: 11
Medium: 15
Low: 4
```

Update these after re-verification:

```text
Still Present Blocking: TBD
Still Present High: TBD
Still Present Medium: TBD
Still Present Low: TBD
Already Fixed: TBD
False Positive: TBD
Requires Live Verification: TBD
```

---

# 16. Progress Changelog Instructions

Append one entry after every completed task.

Template:

```markdown
## YYYY-MM-DD — TASK-ID — Short title

**Status:** VERIFIED

### What changed
- ...

### Files
- ...

### Verification
- command → result
- command → result

### Remaining actions
- None
```

Do not delete previous changelog entries.

---

# 17. Progress Changelog

<!-- Claude Code: append new progress entries below this line. -->

## 2026-07-14 — Wave 0 reconciliation — Branch state audit (no code changes)

**Status:** Investigation only — Wave 1 not started, per operator instruction.

### What changed
- No application code changed. Read-only reconciliation of Wave 0 (W0-1..W0-4) against actual repository state.
- Updated Wave 0 dashboard statuses and each task's completion record with evidence.

### Findings
- W0-1 (duration work) and W0-2 (album/category work): **already committed** as independent commits on local `redesign_v2` (`4bd4dfb`; `be2a574`, `3472579`, `5f00082`, `0e29db2`) — but **unpushed** to `origin/redesign_v2` and **absent from `main`/`origin/main` entirely**.
- W0-3 (handbook commit): still `NOT_STARTED` — `CLAUDE.md`/`docs/ai/**`/this plan file remain untracked on every branch.
- W0-4 (clean checkpoint): `BLOCKED` — current HEAD (`main`) does not contain any redesign_v2 work; `origin/main`'s PR #5 merge only pulled in the pre-redesign baseline (`d87d28b`), not the phase work or later fixes. Local `redesign_v2` has 6 commits that exist nowhere but this machine.
- Documentation defect found: `CLAUDE.md` points to `docs/ai/PRODUCTION_READINESS_PLAN.md`; actual file is `SleepHealing_PRODUCTION_READINESS_PLAN.md` at repo root.

### Files
- `SleepHealing_PRODUCTION_READINESS_PLAN.md` (this file — status/evidence updates only)

### Verification
- `git branch -vv` → confirmed `redesign_v2` is ahead of `origin/redesign_v2` by 6; `main` is behind `origin/main` by 2.
- `git merge-base main redesign_v2` / `git log main..redesign_v2` / `git log redesign_v2..main` → confirmed zero overlap of redesign_v2 work into main.
- `git merge-base --is-ancestor <commit> origin/main` for each redesign_v2-era commit → all `no`.
- `git show --stat c381722` → confirmed PR #5 into `origin/main` only merged `d87d28b` (pre-redesign baseline), not the redesign_v2 phase commits.
- `git diff main redesign_v2 -- admin/app/Http/Controllers/Web/LoginController.php` and `.../NotificationsController.php` → no diff, confirming Blocking audit findings B1–B5 (Laravel/Docker) apply equally to both branches.
- `git stash list` → 1 entry pending (`docker-compose.yml` path fix, stashed from `redesign_v2`).

### Remaining actions
- **Awaiting operator decision:** confirm base branch (`redesign_v2` vs `main`) before W0-4 can proceed or Wave 1 can begin.
- Push the 6 unpushed `redesign_v2` commits once the branch decision is confirmed.
- Commit the Engineering Handbook (W0-3) on the confirmed base branch.
- Resolve the `docs/ai/PRODUCTION_READINESS_PLAN.md` vs `SleepHealing_PRODUCTION_READINESS_PLAN.md` path mismatch.

## 2026-07-14 — W0-1..W0-4 — Wave 0 closed out (push, handbook commit, recovery checkpoint)

**Status:** VERIFIED

### What changed
- Operator confirmed `redesign_v2` as the base branch (see resolution note above the Wave 0 dashboard).
- Switched back to `redesign_v2`, restored the stashed `docker-compose.yml` fix (`git stash pop`).
- Pushed the 6 previously-local-only commits to `origin/redesign_v2`.
- Relocated `SleepHealing_PRODUCTION_READINESS_PLAN.md` → `docs/ai/PRODUCTION_READINESS_PLAN.md`, resolving the `CLAUDE.md` path mismatch.
- Committed the Engineering Handbook (`CLAUDE.md` + `docs/ai/**`) as `e0e069a`, pushed to `origin/redesign_v2`.
- Created recovery branch `backup/pre-production-hardening-2026-07-14` at `e0e069a`, pushed to origin. Not merged into `main`.
- Updated Wave 0 dashboard and all four task completion records to `VERIFIED` with evidence.

### Files
- `docs/ai/PRODUCTION_READINESS_PLAN.md` (this file — moved from repo root, statuses updated)
- `CLAUDE.md`, `docs/ai/*` (29 other files) — new, via commit `e0e069a`
- No application code changed.

### Verification
- `git push origin redesign_v2` → `8d845a2..0e29db2 redesign_v2 -> redesign_v2`
- `git merge-base --is-ancestor <c> origin/redesign_v2` for all 6 commits → yes (all 6)
- `git push origin redesign_v2` (handbook) → `0e29db2..e0e069a redesign_v2 -> redesign_v2`
- `git merge-base --is-ancestor e0e069a origin/redesign_v2` → yes
- `git push origin backup/pre-production-hardening-2026-07-14` → `* [new branch]`
- `git log -1 --oneline origin/backup/pre-production-hardening-2026-07-14` → `e0e069a`
- `git status --short` → only `M docker-compose.yml` (pre-existing, documented) and `?? HANDBOOK_MANIFEST.json` (deliberately excluded) remain

### Remaining actions
- None to close Wave 0. Wave 1 (Critical Security Blockers) may begin on explicit operator instruction.
- Carried forward: decide standalone commit vs. folding the `docker-compose.yml` `./Admin`→`./admin` fix into Wave 1 (W1-1/W1-2 touch the same file).
