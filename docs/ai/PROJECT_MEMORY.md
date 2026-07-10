# Project Memory and Decisions

This file records stable product and engineering decisions. Claude must consult it before proposing changes.

## PM-001 — Language Switcher removed

Status: Accepted

The application should not implement or display a Language Switcher. Do not add it as Coming Soon.

Localization packages/assets may remain for existing content, but this does not authorize a visible language-selection feature.

## PM-002 — Authentication sequencing

Status: Accepted

The current redesign phase is frontend-first.

Google/Clerk authentication should be implemented after frontend redesign unless the user explicitly reprioritizes it.

Do not build placeholder authentication that creates future migration debt.

## PM-003 — Program Detail priority

Status: Accepted

Program Detail Phase 7D is optional and low priority. It may be postponed to protect MVP timing.

## PM-004 — Sleep Timer semantics

Status: Requires verification

Before changing a setting labeled Sleep Timer Default, determine whether it represents:

- a true persistent default, or
- the most recently selected timer value

Do not rename or change persistence behavior based on UI label alone.

## PM-005 — Removal safety

Status: Accepted

Before deleting unused fields, models, routes, screens, assets, or code:

- search the complete repository
- run analyzer/tests
- inspect dynamic references/routes
- document evidence

## PM-006 — Deployment boundary

Status: Accepted

During development:

- Admin/API may run on VPS or Docker
- Flutter app may run locally
- the mobile client must access a reachable API URL
- localhost inside the mobile client is not the VPS

## PM-007 — Audio stability

Status: Accepted

Audio playback is a protected subsystem.

Unrelated UI/API work must not regress:

- first-tap play/pause
- elapsed position
- progress bar
- seek
- duration
- next/previous
- queue
- sleep timer
- continue-playing state

## PM-008 — Data preservation

Status: Accepted

Never use destructive database or Docker-volume reset commands as a normal repair strategy.

## PM-009 — Product naming and legacy backend naming

Status: Accepted

Product-facing names may evolve, but legacy backend names such as `Albam` and `PlayList` must not be renamed without a dedicated migration and compatibility plan.

## PM-010 — App Store path

Status: Accepted

Stabilize frontend and backend integration before final Apple IAP and App Store release work.

## PM-011 — Admin song audio-duration validation is atomic

Status: Accepted

`App\Rules\ValidAudioDuration` (used by `PlayListRequest`) runs ffprobe against an uploaded `audio` file during Laravel form validation, before the `PlaylistController`/`PlayListRepository` ever run. A song create/update whose audio has no detectable positive, finite duration fails as a normal validation error on the `audio` field - it must never create/update a PlayList, Media row, or Album pivot, and must never surface as a "created with a warning" success. `PlayListRepository::storeByRequest()` additionally wraps the DB writes in a transaction and deletes any newly stored thumbnail/audio file if that transaction fails, since filesystem writes are not rolled back by a DB transaction. The only remaining valid "success with a warning" flash is a song created/updated with no Album attached (`PlaylistController::buildPlaylistWarning()`).

Do not reintroduce a code path where a duration-detection failure results in a persisted PlayList with `duration === null` and a warning flash.
