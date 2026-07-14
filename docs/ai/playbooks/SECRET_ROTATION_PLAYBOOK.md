# Secret Rotation Playbook — APP_KEY / DB password / MySQL root password

## Why this exists

`docker-compose.yml` committed real values for `APP_KEY`, `DB_PASSWORD`,
`MYSQL_PASSWORD`, and `MYSQL_ROOT_PASSWORD` (audit finding B1 / plan task
W1-1). As of the W1-1 fix, the tracked file no longer contains these values —
they now resolve via `${VAR}` interpolation from an untracked `.env`.

**Removing the values from the tracked file does not rotate them.** The old
values are permanently in git history (every prior commit that touched
`docker-compose.yml` still has them, and rewriting that history is a separate,
disruptive decision — see "Should we rewrite git history?" below). If any real
environment (VPS, staging, anything reachable from the internet) is currently
running with these exact values, it is compromised right now and must be
rotated using the steps below. This has **not** been done automatically — per
`docs/ai/PRODUCTION_READINESS_PLAN.md` §1.4, live production credentials are
never rotated without explicit operator action, since APP_KEY rotation
invalidates sessions/encrypted data and DB rotation must be coordinated across
both the database and the app's configuration at the same time.

## Important: rotating `.env` alone is not enough for the database

The `mysql:8.0` image only applies `MYSQL_PASSWORD` / `MYSQL_ROOT_PASSWORD`
when it **initializes an empty data directory**. The `mysql_data` volume
already has data in it (and must never be wiped — see `docs/ai/KNOWN_ISSUES.md`
KI-010 and the non-destructive policy in `CLAUDE.md`), so simply changing
`.env` and restarting the container **will not** change the actual MySQL user
passwords already stored inside that volume. The database password must be
changed with SQL against the running instance first; `.env` is then updated to
match so the app container (and any future fresh volume) stays in sync.

## Procedure

Run this against **each real environment** that used the compromised values
(VPS/production first; treat local dev `.env` files as disposable — just
regenerate them, no coordination needed).

### 1. Rotate the MySQL application user password

```bash
# Connect as root inside the running db container
docker compose exec db mysql -u root -p

# At the MySQL prompt:
ALTER USER 'maditam'@'%' IDENTIFIED BY '<new-strong-password>';
FLUSH PRIVILEGES;
EXIT;
```

### 2. Rotate the MySQL root password

```bash
docker compose exec db mysql -u root -p
# At the MySQL prompt:
ALTER USER 'root'@'%' IDENTIFIED BY '<new-strong-root-password>';
FLUSH PRIVILEGES;
EXIT;
```

### 3. Rotate APP_KEY

```bash
docker compose exec app php artisan key:generate --show
```

Before applying the printed key, confirm whether any database columns use
Laravel's `encrypted` cast — those values were encrypted with the *old* key
and become unreadable once the key changes. If any exist, re-encrypt them
under the new key before cutting over (out of scope for this playbook; treat
as a blocking sub-task if discovered). If none exist, applying the new key
only invalidates active sessions and signed cookies — all users are logged out
once, which is acceptable for this rotation.

### 4. Update the environment file

Edit the real `.env` (same directory as `docker-compose.yml` on that host) —
**never commit it**:

```env
APP_KEY=<value from step 3>
DB_PASSWORD=<value from step 1>
MYSQL_ROOT_PASSWORD=<value from step 2>
```

`DB_PASSWORD` here is intentionally the one variable used for both the app's
`DB_PASSWORD` and the db service's `MYSQL_PASSWORD` — they must always be the
same string.

### 5. Recreate the app container to pick up the new `.env`

```bash
docker compose up -d app
docker compose ps
docker compose logs --tail=200 app
```

The `db` service itself does not need to be recreated (its password was
already changed live via SQL in steps 1–2); only `app` needs the new
environment values.

### 6. Verify

- `docker compose exec app php artisan config:show database` — confirm the
  running config resolved the new values (do not print this output anywhere
  that gets logged/committed/pasted; read it directly in the operator's own
  terminal).
- Admin login succeeds.
- A known API endpoint returns data (confirms DB connectivity).
- Existing user sessions are logged out (expected, one-time, from the APP_KEY
  change) and can log back in successfully.

## Should we rewrite git history?

Out of scope for W1-1. Rewriting history (`git filter-repo` / BFG) to strip
the old values from every past commit is a separate, disruptive decision — it
forces every collaborator to re-clone, breaks open PRs, and requires a
coordinated force-push. It does **not** replace rotation: even with history
rewritten, if the old values were ever used on a real server, they must still
be rotated per the procedure above. Raise this as its own decision with the
operator if the repository is public or has external collaborators; do not
perform it without explicit authorization (`CLAUDE.md` forbids `git reset
--hard` / history-rewriting force-pushes without explicit approval).

## Local development

Local dev does not need this procedure — just generate a fresh local-only
`.env` (never reuse the old compromised values, since they're permanently
public in git history now):

```bash
cat > .env <<'EOF'
APP_KEY=base64:REPLACE_ME
DB_PASSWORD=REPLACE_ME
MYSQL_ROOT_PASSWORD=REPLACE_ME
EOF
# Then fill in real random values, e.g.:
#   APP_KEY: base64:$(openssl rand -base64 32)
#   DB_PASSWORD / MYSQL_ROOT_PASSWORD: openssl rand -hex 20
```
