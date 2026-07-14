# Known Issues and Regression Traps

## KI-001 — Wrong Laravel storage disk

Historical failure:

```php
Storage::put($path, $file, 'public');
```

The third argument represents visibility, not disk selection.

Required pattern:

```php
Storage::disk('public')->put($path, $file);
```

Verify runtime `filesystems.default`, public disk root, URL, and storage symlink.

## KI-002 — Double upload then delete

Historical failure:

Two sequential `if` branches handled “no existing media” and “existing media.” The first branch created media; the second then ran and deleted the newly uploaded file.

Use mutually exclusive control flow or simplify the update operation.

Regression test create/update where prior media is null.

## KI-003 — Unordered pagination

Historical failure:

`paginate()` without explicit ordering caused new rows to appear on the last page.

Every user-facing paginated Admin/API query should have deterministic ordering.

## KI-004 — Media URL environment mismatch

Common failure modes:

- API returns localhost
- API returns Docker service hostname
- Flutter duplicates base URL
- duplicate `/storage/storage/`
- HTTP URL blocked on iOS/Android
- database stores absolute local URL

Normalize the contract and verify from the consuming device environment.

## KI-005 — Audio duration overflow

The track can continue beyond displayed/database duration when metadata and runtime stream disagree.

Runtime player duration and completion state are authoritative when available.

Do not clamp playback solely to database duration without understanding stream semantics.

## KI-006 — Progress/elapsed time not updating

Potential causes:

- UI watches stale provider
- position stream subscription is missing/disposed
- competing player instance
- state mutation does not notify
- duration is null or zero
- widget displays model metadata instead of player state

Trace the active player instance and state stream.

## KI-007 — Play/pause first-tap behavior

Historical symptom:

First tap jumps or rewinds to prior position; state only updates after another control.

Check race conditions between selected track, source loading, seek restoration, and playing state.

## KI-008 — Continue section null duration

Ensure null-safe parsing and rendering. Do not hide the entire item because duration is absent.

## KI-009 — Icon renders as question mark

Potential causes:

- missing font asset
- invalid code point
- tree-shaken custom icon
- incorrect icon font family
- stale generated asset

Prefer Material/SVG assets already bundled and test release mode.

## KI-010 — Docker volume/data loss risk

Do not remove `mysql_data` or `app_storage`.

Before rebuild/deploy:

- inspect mounted volumes
- back up DB for production-risk changes
- confirm upload persistence after restart

## KI-011 — Config cache mismatch

Changing `.env` is insufficient when Laravel config is cached.

Verify:

```bash
php artisan config:show app
php artisan config:show filesystems
php artisan config:show database
```

Clear/rebuild cache safely where needed.

## KI-012 — Mock or cached Flutter data

A valid API fix may not appear if the client uses fixtures, Hive cache, or stale provider state.

Trace actual network activity and state refresh before blaming backend.

## KI-013 — Status/visibility mismatch

Admin may create records with null/inactive status while API filters active-only.

Preserve intended publishing rules and make defaults explicit.

## KI-014 — Multiple audio libraries

The dependency list includes multiple audio packages. Do not assume which one is active. Avoid creating a second independent player state.

## KI-015 — Committed credentials/config

The root Docker Compose has historically included application keys, DB credentials, and demo credentials.

Treat this as a security debt item. Do not copy real secrets into new documentation, prompts, logs, or commits.
