# Deployment Incident Playbook

## Symptoms

- site unavailable
- API 500
- DB connection failure
- media 404
- old code still served
- login redirect loop
- container restart loop
- data missing

## Triage

```bash
docker compose ps
docker compose logs --tail=300 app
docker compose logs --tail=200 db
docker compose exec app php artisan about
docker compose exec app php artisan config:show database
docker compose exec app php artisan config:show filesystems
```

## Safety

- do not remove volumes
- do not reset DB
- do not overwrite reverse proxy for unrelated projects
- collect evidence before rebuild

## Recovery order

1. availability
2. data integrity
3. media/storage
4. API correctness
5. client verification
6. root-cause fix and regression prevention
