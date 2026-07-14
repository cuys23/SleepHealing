# Laravel Engineering Guidelines

## Runtime truth

Do not rely only on `.env`.

Inspect runtime values:

```bash
php artisan about
php artisan config:show app
php artisan config:show database
php artisan config:show filesystems
php artisan route:list
```

Use Docker-prefixed equivalents when applicable.

## Controllers

Controllers should:

- validate/request orchestration
- call repository/service/domain logic
- return correct response/redirect
- not contain duplicated storage/URL logic

Do not return success after a caught failure.

## Repositories/services

- Use transactions when DB and file operations must remain consistent.
- Clean up newly uploaded files if DB operation fails.
- Delete/replace old files only after the new write succeeds.
- Avoid double-branch upload logic.
- Preserve relations and visibility rules.
- Make list ordering deterministic.

## Storage

Use explicit disk:

```php
Storage::disk('public')
```

DB value:

```text
images/playlist/file.webp
audio/playlist/file.mp3
```

Public URL:

```php
Storage::disk('public')->url($path)
```

Centralize compatibility handling for legacy values.

## API

- Return JSON for API routes.
- Avoid redirecting mobile API requests to Blade login.
- Use Resources/Transformers for stable contracts.
- Preserve legacy fields when introducing normalized fields.
- Return correct status codes.
- Validate pagination and ordering.
- Invalidate cache on relevant CRUD operations.
- Avoid N+1 queries through intentional eager loading.

## Validation

Validate actual client MIME/file constraints, not only extension.

For upload errors:

- show validation errors in Admin
- do not create incomplete records accidentally
- do not leave orphan files
- keep old media if replacement fails

## Database

- Never use destructive reset commands on user environments.
- Inspect actual schema before migration.
- New migrations must be reversible.
- Do not rename legacy tables/models in a bug-fix task.
- Set explicit defaults for visibility/status where business rules require them.
- Use indexes when new production query patterns justify them.

## Authentication

Both Passport and Sanctum dependencies exist. Determine the active mechanism from:

- guards
- middleware
- routes
- token issuance
- Flutter headers

Do not add a third token mechanism.

## Admin lists

All paginated user-facing lists require explicit order.

When filtering:

- make active/published semantics clear
- retain filter values across pagination
- ensure new content is findable
- display validation/server errors accurately

## Required backend checks

```bash
composer install
php artisan route:list
php artisan test
./vendor/bin/pint --test
```

Use only applicable commands and report pre-existing failures honestly.
