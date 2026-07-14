# Testing Strategy

## Testing pyramid for this project

### Unit tests

Use for:

- URL normalization
- JSON parsing
- duration conversion
- provider/controller state logic
- repository mapping
- helper functions

### Feature/API tests

Use for:

- Admin CRUD
- validation
- storage
- database persistence
- visibility rules
- API resources
- authentication/middleware
- cache invalidation

### Widget tests

Use for:

- loading/error/empty/data states
- song/album rendering
- image URL handoff
- player command handoff
- navigation

### Integration/runtime tests

Use for:

- real API integration
- audio loading/playback
- platform networking
- notifications/background audio
- Docker persistence
- App Store purchase flows

## Regression-test requirements

A fixed production bug should receive a regression test unless impractical.

Test name should describe behavior, not implementation.

Example:

```text
updating_album_without_existing_thumbnail_keeps_new_file
```

## Test isolation

- Do not use production DB.
- Use transactions/test database.
- Use `Storage::fake('public')` where suitable.
- Create and clean only task-owned QA data.
- Do not depend on test order.

## Command loop

Flutter:

```bash
flutter pub get
flutter analyze
flutter test
```

Laravel:

```bash
php artisan test
./vendor/bin/pint --test
```

Docker/runtime:

```bash
docker compose config
docker compose ps
docker compose logs --tail=200 app
```

## Pre-existing failures

If the baseline already fails:

- document exact failure
- do not claim full green suite
- ensure the change does not add failures
- fix the pre-existing issue only when in scope or necessary

## Runtime labels

Use these exact labels in reporting:

- **Verified on device/simulator**
- **Verified by automated test**
- **Verified by HTTP/runtime command**
- **Not verified**
