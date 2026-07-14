# Deployment Runbook

## Pre-deployment

1. Confirm branch/commit.
2. Review `git diff` and status.
3. Run relevant tests.
4. Check migration list.
5. Back up production DB for schema/data-risk changes.
6. Confirm storage volume.
7. Confirm environment/secrets.
8. Record rollback target.

## Deploy Laravel/Docker

Typical non-destructive flow:

```bash
git pull --ff-only
docker compose config
docker compose build app
docker compose up -d app
docker compose ps
docker compose logs --tail=200 app
```

If migrations are required:

```bash
docker compose exec app php artisan migrate --force
```

Run only after migration review and backup policy.

Then:

```bash
docker compose exec app php artisan optimize:clear
docker compose exec app php artisan config:cache
docker compose exec app php artisan route:cache
```

Use route caching only if routes are compatible.

## Post-deployment checks

- Admin login
- API health
- newest content endpoint
- image URL
- audio URL
- database connectivity
- storage persistence
- app logs
- no unexpected redirects

## Rollback

Rollback code to known commit and rebuild.

Do not roll back schema blindly. Use the migration-specific rollback plan prepared before deployment.

## Flutter build

Before release:

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build ios --release
```

A successful build does not replace device/TestFlight QA.
