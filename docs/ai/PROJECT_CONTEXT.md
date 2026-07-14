# Project Context

## Product

SleepHealing is a mobile wellness and healing-audio application. Its core value is reliable discovery and playback of calming audio content such as sleep, meditation, focus, healing, rain, ambient, and nature sounds.

## Current delivery priority

The current priority is an iOS-first MVP that is stable enough for production and App Store submission.

The product is under time pressure. Therefore:

- prefer stable completion over broad rewrites
- preserve working behavior
- prioritize Blocking and High issues
- postpone optional architecture modernization
- document technical debt instead of expanding scope without approval

## Repository layout

Verified top-level structure:

```text
SleepHealing/
├── admin/                 Laravel Admin/API
├── app/                   Flutter client
└── docker-compose.yml     Local/server container orchestration
```

The Flutter app includes Android, iOS, desktop, web, assets, library, and test directories.

The Laravel app follows the standard Laravel layout with `app`, `config`, `database`, `resources`, `routes`, `storage`, and `tests`.

## Verified technology baseline

### Flutter

The current dependency set includes:

- Flutter SDK
- Dart SDK >= 3.5
- Riverpod
- Dio
- Hive
- `just_audio`
- `audio_service`
- `audioplayers`
- `cached_network_image`
- Firebase Core and Messaging
- local notifications
- easy localization
- Freezed annotations/code generation
- Google Mobile Ads

The presence of several audio packages means Claude must identify the actual active player path before modifying audio behavior.

### Laravel

The backend uses:

- Laravel 9
- PHP 8.x
- Passport
- Sanctum
- Spatie Permission
- MySQL
- PHPUnit
- Laravel Pint
- Firebase integration
- Twilio and Telesign dependencies

The presence of both Passport and Sanctum does not prove both are active. Inspect routes, middleware, guards, and Flutter token handling before modifying authentication.

### Infrastructure

Docker Compose currently defines:

- Laravel application service
- MySQL 8 service
- persistent MySQL volume
- persistent Laravel storage volume
- application port mapping around `9080`
- MySQL host port mapping around `3308`

Treat actual runtime configuration as environment-dependent. Never assume committed local values are correct for VPS or production.

## Product decisions already made

- Do not implement or display Language Switcher.
- Remove or keep hidden the verified-account concept where it is obsolete.
- Manual account flow is not part of the current frontend-only redesign.
- Google/Clerk sign-in is intended after frontend redesign.
- Carousel should support swipe and each indicator should represent a distinct topic card.
- Verify whether Sleep Timer Default is a true default or only the most recently selected value before changing it.
- Program Detail Phase 7D is optional and may be postponed.
- Search/analyzer evidence is required before deleting unused fields or code.
- Mobile app runs locally during development while Admin/API may run on VPS.
- Apple IAP and App Store release work follow frontend stabilization.

## Main domain concepts

The legacy backend naming may not match product semantics.

Known examples:

- `PlayList` may represent an individual playable track.
- `Albam` is a legacy misspelling of Album and may represent a collection/topic.
- `Media` stores image/audio metadata.
- Category, album, playlist, meditation, sound, and topic relationships require code verification before assumptions.

Do not rename legacy models casually. A naming cleanup can create large API/database regressions and is outside normal bug-fix scope.

## Completion philosophy

The codebase is the source of truth for implementation.

This Handbook is the source of truth for process, constraints, known historical failures, and product decisions.

When the Handbook and current code disagree:

1. verify the code and runtime
2. document the discrepancy
3. update the relevant Handbook file in the same change when appropriate
