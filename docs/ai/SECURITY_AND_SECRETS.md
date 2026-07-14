# Security and Secrets

## Current risk context

Repository history/config may contain local application keys, database credentials, demo credentials, or other secrets.

Do not repeat them in:

- documentation
- final reports
- screenshots
- prompts
- logs
- test fixtures
- commits

## Required secret handling

Use environment files or deployment secret management.

Commit:

- `.env.example`
- variable names
- safe placeholders

Do not commit:

- real APP_KEY
- DB passwords
- OAuth secrets
- Apple private keys
- Firebase service credentials
- API tokens
- SMTP credentials
- production admin credentials

## Rotation

If a secret has been committed publicly, removing it in a later commit is insufficient. Treat it as exposed and rotate it.

## Logging

Never log:

- bearer token
- refresh token
- password
- session cookie
- Apple receipt payload
- full private user data
- Firebase service account content

## Mobile storage

Do not store long-lived sensitive tokens in plain Hive/SharedPreferences if secure storage is required.

Authentication is deferred, but when implemented, select and document a secure token-storage strategy.

## Network

Production:

- HTTPS only
- valid certificate
- no certificate bypass
- no permissive trust manager
- no production cleartext exception

## Admin/API

- validate authorization, not only authentication
- restrict upload types and sizes
- prevent path traversal
- do not expose stack traces
- protect rate-sensitive endpoints
- verify CORS intentionally
