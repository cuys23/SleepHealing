# Production Readiness Audit — SleepHealing

**Date:** 2026-07-14
**Branch:** `redesign_v2`
**Scope:** Laravel Admin/API (`admin/`), Flutter client (`app/`), Docker Compose & VPS config
**Method:** Read-only audit (3 parallel agents: Docker/VPS/secrets, Laravel backend, Flutter client). No files modified, no destructive commands run. Evidence based on direct code reading, `git log`/`git ls-files`, `flutter analyze`, and repo-wide `grep`/`find`.

## Verdict

**Not ready for production or App Store submission.** 8 Blocking issues found, including live secrets committed to git, a publicly exposed database port, a full admin-panel authentication bypass, an account-takeover path via the forgot-password endpoint, and a Flutter release build that is hardcoded to talk to `localhost`.

## Summary

| Severity | Count |
|---|---|
| Blocking | 8 |
| High | 11 |
| Medium | 15 |
| Low | 4 |

---

## Blocking

Must fix before any production deploy or App Store submission.

### B1 — Real secrets committed to git (APP_KEY, DB password, MySQL root password)
- **File:** `docker-compose.yml:10, 18, 33, 34`
- These values live directly in the `environment:` block (not via `env_file`), present since the initial commit and unchanged at current HEAD — this is live config, not stale history. Anyone with repo read access (including git history) can recover the APP_KEY (decrypts sessions/cookies) and the MySQL root password.
- **Action:** treat as fully compromised. Rotate APP_KEY and all DB passwords; move to an untracked `.env` or the deployment platform's secret manager.

### B2 — MySQL port publicly exposed, combined with the leaked root password from B1
- **File:** `docker-compose.yml:37-38` → `"3308:3306"`
- Bound to all interfaces (no `127.0.0.1:` prefix). If the VPS lacks an external firewall rule, anyone on the internet can connect directly to MySQL with the committed root credentials.
- **Action:** change to `127.0.0.1:3308:3306` or drop the host port mapping entirely — the `app` service already reaches `db` via the internal Docker network.

### B3 — Any signed-up app user can log into the Admin panel with full privileges
- **File:** `admin/app/Http/Controllers/Web/LoginController.php:44-49`, `routes/web.php:42`
- The Admin `/login` page authenticates against the same `users` table the public `/sign-up` API writes to (default role `user`), with no role/permission check before `Auth::login()`. No `role:`/`permission:` middleware or `authorize()` call exists anywhere in `Web/*Controller.php`.
- **Scenario:** a regular end user signs up in the mobile app, then logs into the Laravel web `/login` with the same credentials and gets a fully privileged Admin session (full CRUD over all content, users, settings).

### B4 — Forgot-password endpoint returns the OTP/reset token directly in the API response
- **File:** `admin/app/Http/Controllers/API/AuthController.php:74-77`
- Calling `forgot-password` for any registered email returns the OTP/reset token in the JSON response instead of emailing it — full account takeover for any known email address, no inbox access required.
- **Action:** actually dispatch the OTP via email (`EmailVerificationEvent` already exists) and stop returning the `Verification` model in the response.

### B5 — Plaintext password stored in a 30-day browser cookie
- **File:** `admin/app/Http/Controllers/Web/LoginController.php:32`
- `Cookie::queue('password', $loginRequest->password, $time)` stores the raw plaintext password client-side for up to 30 days when "remember me" is used. Any cookie leak (XSS, shared computer, browser extension, unencrypted proxy) exposes the real password, not just a session token.

### B6 — Flutter API base URL hardcoded to `localhost` for every build, including release
- **File:** `app/lib/config/config.dart:3-4`, `app/lib/features/core/logic/app_config_provider.dart:7-16`
- `isAppLiveProvider` is a `StateProvider<bool>` hardcoded to `true` with no dart-define/flavor/build-mode override — even release/TestFlight/App Store builds use `baseUrl = 'http://localhost:9080/api'`.
- **Scenario:** shipping the current code to the App Store means every network request fails immediately on a real device, since `localhost` resolves to the device itself.

### B7 — TLS certificate validation disabled app-wide
- **File:** `app/lib/main.dart` — `MyHttpOverrides.badCertificateCallback` always returns `true`
- `HttpOverrides.global` accepts any HTTPS certificate (expired, self-signed, attacker-controlled) for every connection the app makes. On public Wi-Fi, an attacker can MITM all HTTPS traffic (API, tokens, Firebase) with no warning to the user. Directly contradicts `docs/ai/SECURITY_AND_SECRETS.md`.

### B8 — Missing `NSUserTrackingUsageDescription` despite bundled Google Mobile Ads SDK
- **File:** `app/ios/Runner/Info.plist`
- The Google Mobile Ads SDK is capable of IDFA access and `MobileAds.instance.initialize()` runs unconditionally in `main()`. Apple's binary scan checks for the ATT usage string whenever this SDK is present — a very common, near-certain App Store rejection reason if submitted as-is.

---

## High

Not launch-blocking by itself, but serious security/operational risk — handle in the same pass as Blocking.

| ID | Area | Finding | File |
|---|---|---|---|
| H1 | Docker | Demo admin credentials (`DEMO_USER`/`DEMO_PASS`) committed | `docker-compose.yml:19-20` |
| H2 | Docker | `APP_ENV: local` is the value shipped in the only compose file, apparently used for the VPS too — no production override file exists | `docker-compose.yml:9` |
| H3 | Laravel | IDOR: any authenticated user can read/mark-read/delete any other user's notifications, and create notifications targeting an arbitrary `user_id` | `admin/app/Http/Controllers/API/NotificationsController.php` |
| H4 | Laravel | Unordered-pagination regression (KI-003 pattern) in 4 of 6 repositories — no `orderBy()`/`latest()` before `paginate()` | `CategoryRepository.php:37`, `BannerRepository.php:30`, `SubscriptionPlanRepository.php:23`, `UserRepository.php:36` |
| H5 | Laravel | Laravel 9 / Passport 11 / oauth2-server 8.5 are EOL or multiple majors behind — no more security patches for core framework/auth packages | `admin/composer.json` |
| H6 | Laravel | N+1 queries in `PlayListResource`/`AlbamResource` — every listing endpoint (home, browse, album detail) re-queries per row instead of eager-loading | `PlayListResource.php:16-33`, `AlbamResource.php:13-24` |
| H7 | Laravel | Seeder hardcodes 3 production accounts (`root@`/`admin@`/`visitor@playmusic.com`, password `"secret"`), gated only by an `environment('production')` check — not auto-run, but reachable via CLI/CI access | `admin/database/seeders/UpdateAdminSeeder.php:66-91` |
| H8 | Flutter | iOS and Android point at two unrelated Firebase projects (`maditam-bed79` vs `meditam-live`) — push/analytics/remote-config split across platforms | `app/ios/GoogleService-Info.plist`, `app/android/app/google-services.json` |
| H9 | Flutter | Auth token stored in a plain, unencrypted Hive box instead of secure storage — contradicts the project's own security doc; login/sign-up routes are live, not dead code | `app/lib/services/interceptor.dart`, `app/lib/config/hive_contants.dart:6,13` |
| H10 | Flutter | Android `versionCode` hardcoded to `27`, fully decoupled from the `pubspec.yaml` build number — next Play Store upload can silently fail/reject | `app/android/app/build.gradle:29-32, 62` |
| H11 | Flutter | Android allows cleartext HTTP globally (`usesCleartextTraffic="true"`, unscoped) and the "real" UAT host itself is plain HTTP, not HTTPS | `app/android/app/src/main/AndroidManifest.xml`, `config.dart:4` |

---

## Medium

Technical/operational debt to clean up before or shortly after launch.

| ID | Area | Finding |
|---|---|---|
| M1 | Docker | No `admin/.env.example` template exists despite `.gitignore` referencing that workflow |
| M2 | Docker | `app` service has no `healthcheck` (only `db` does) |
| M3 | Docker | No log rotation or visible backup schedule for MySQL data |
| M4 | Laravel | CORS `allowed_origins: ['*']` on `/api/*` (mitigated by `supports_credentials: false`) — `admin/config/cors.php` |
| M5 | Docker | `migrate --force` runs unconditionally on every container (re)start — `admin/Dockerfile:24` |
| M6 | Laravel | `MediaRepository` still uses the `Storage::put(path, file, 'public')` anti-pattern (KI-001 shape); works today only because `FILESYSTEM_DISK=public` is the current default — `MediaRepository.php:19,32,46` |
| M7 | Laravel | No queue worker/supervisor exists — switching `QUEUE_CONNECTION` off `sync` would silently break email verification (`EmailVerificationListener` uses `ShouldQueue`) |
| M8 | Laravel | `php artisan serve` used as the production web server — not designed for real concurrent traffic — `admin/Dockerfile:29` |
| M9 | Laravel | No max file-size validation on uploads; SVG accepted for thumbnails/banners (stored-XSS risk if ever rendered inline) |
| M10 | Laravel | No dedicated rate limit on login/OTP/reset-password beyond the generic `throttle:api` (60/min) — compounds B4 |
| M11 | Flutter | iOS camera/photo-library/microphone permission strings are leftover copy from an unrelated e-commerce app — `app/ios/Runner/Info.plist` |
| M12 | Flutter | Placeholder contact info and App Store URL still in config (`+88017xxxxxxxx`, `example@gmail.com`) — `app/lib/config/config.dart:15,22-25` |
| M13 | Flutter | 51 ungated `print`/`debugPrint` calls execute in release builds, including logging the FCM device token — `app/lib/main.dart:139-140` and scattered across `app/lib` |
| M14 | Flutter | Several wellness screens (sleep tracker, statistics, achievements, mood check-in, meditation) still run on mock data, not a real backend — `app/lib/features/wellness/mock/*.dart` |
| M15 | Laravel | `composer.json` sets `minimum-stability: dev` (mitigated by `prefer-stable: true` but unusual for production) — `admin/composer.json:70-71` |

---

## Low

Cleanup only, no functional or security impact.

| ID | Finding |
|---|---|
| L1 | Sanctum is configured but inert — `EnsureFrontendRequestsAreStateful` middleware is commented out, no route uses `auth:sanctum` |
| L2 | An orphaned second `GoogleService-Info.plist` exists on iOS (`app/ios/Runner/GoogleService-Info.plist`), not referenced by the Xcode build — confusing but harmless |
| L3 | A hardcoded AdMob test-device ID is left in `main.dart` — harmless dev leftover |
| L4 | Leftover Flutter template naming remnants (`namespace com.example.medyo`, pubspec `name: medyo`, generic description) |

---

## Verified OK

Listed to confirm audit coverage — not everything is broken.

- No `.env`/`.env.production` file has ever been committed (checked full git history via `git log --all --diff-filter=A`).
- No Passport OAuth private keys, Apple `.p8`/`.p12`, or Firebase service-account JSON committed.
- `mysql_data` and `app_storage` are correctly declared as named, persistent volumes; both services have `restart: unless-stopped`; the DB has a working healthcheck.
- `auth:api` middleware is correctly applied to all sensitive API routes; the public catalog routes are intentionally public.
- No exploitable mass-assignment path found despite broad `$guarded=['id']` on models — all write paths use explicit field arrays.
- The media URL contract (relative path in DB → public disk → normalized API URL) matches the documented architecture.
- `flutter analyze`: 0 compile errors (297 issues total, mostly generated-code/style lints).
- Ads are fully gated off behind a single flag with no unguarded call sites; AdMob IDs are consistent per platform with no test/prod mixups.
- No Stripe/IAP code is wired into the client — consistent with the prior decision to remove payment gateways.
- The Language Switcher is absent as required by product decision; `easy_localization` is configured with a safe fallback locale.
- App icons and launch screen are custom assets, not the Flutter template default.

## Unverified

Needs a live environment/device — not guessed at.

- Real deployed `.env` values on the VPS (no such file exists in this checkout) — actual `APP_ENV`/`APP_DEBUG`/`FILESYSTEM_DISK`/`QUEUE_CONNECTION` in production could not be confirmed beyond what's committed in `docker-compose.yml`.
- The `public/storage` symlink at runtime (created by the Dockerfile at container boot; not verified against a live container).
- The PHPUnit suite: 53 failed / 7 passed in the audit sandbox, but every failure traced to a missing local DB user/`APP_KEY` (environment, not logic) — `phpunit.xml`'s SQLite override is commented out, so the suite isn't self-contained. Recommend fixing that before trusting it as a CI gate.
- `easy_localization`'s missing-key fallback behavior, push-notification deep-link handling, and the actual trigger points for iOS permission prompts — all need a simulator/device to confirm.

---

## Recommended fix order

1. **Rotate all leaked secrets** — APP_KEY, app DB password, MySQL root password. Move to an untracked `.env` or the VPS's secret manager. Treat old values as permanently compromised, not just removed from the file.
2. **Lock down the MySQL port** — bind to `127.0.0.1` or drop the host port mapping; confirm the VPS firewall blocks 3306/3308 externally.
3. **Patch the Laravel auth holes** — add role/permission middleware to the Admin web routes; fix forgot-password to email the OTP instead of returning it; remove the plaintext-password cookie.
4. **Fix Flutter's network config before any release build** — flavor/dart-define mechanism for the API base URL; remove the always-true `badCertificateCallback`; add `NSUserTrackingUsageDescription`.
5. **Work through the remaining High items** — notifications IDOR, the 4 unordered-pagination repositories, the N+1 queries, reconciling the two Firebase projects, moving the auth token to secure storage, decoupling the Android `versionCode`.
6. **Clean up Medium/Low as time allows** — prioritize the iOS permission strings, placeholder contact info, upload size limits, and ungated release logging before App Store submission.
