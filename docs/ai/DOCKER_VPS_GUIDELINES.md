# Docker and VPS Guidelines

## Current topology

Root Compose defines an app service and MySQL service with persistent storage volumes.

Actual VPS networking/reverse proxy rules may be managed outside this repository.

## Safety

Never remove volumes to solve an application bug.

Before deployment:

```bash
docker compose config
docker compose ps
docker volume ls
```

For production-risk DB changes, make a backup first.

## Environment

Do not hardcode production values in Compose.

Prefer:

```yaml
env_file:
  - .env
```

or deployment-managed variables.

Validate inside the running container:

```bash
docker compose exec app php artisan config:show app
docker compose exec app php artisan config:show database
docker compose exec app php artisan config:show filesystems
```

## Storage

The storage volume must preserve:

- `storage/app/public`
- logs as intended
- framework writable directories

Verify:

```bash
docker compose exec app ls -la storage/app/public
docker compose exec app ls -la public/storage
```

## Rebuild

Safe normal sequence:

```bash
git pull --ff-only
docker compose build app
docker compose up -d app
docker compose ps
docker compose logs --tail=200 app
```

Do not assume migration at container startup is always desirable. For production, explicit migration with backup and review is safer.

## Shared VPS constraints

If reverse-proxy rules or public port mappings are controlled by another administrator:

- do not attempt to overwrite unrelated services
- use approved external port/domain
- document required mapping
- verify with `curl` from outside the container

## Health checks

A production setup should have:

- DB health check
- application health endpoint or equivalent
- restart policy
- log retention
- backup schedule
- alerting/error monitoring

Do not mark deployment complete only because the container is “Up.”
