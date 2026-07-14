# Coding Standards

## General

- Follow existing code style before introducing a new pattern.
- Prefer explicit, readable code over clever abstraction.
- Keep functions focused.
- Avoid duplicated business rules.
- Use descriptive domain names while respecting legacy API/database names.
- Handle errors at the correct layer.
- Do not catch exceptions only to suppress them.
- Do not log credentials, tokens, cookies, file contents, or private user data.
- Avoid unrelated formatting churn in bug fixes.

## Change size

A bug fix should ideally contain:

- root-cause fix
- regression test
- minimal compatibility handling
- documentation update if behavior/contract changed

Do not combine broad refactors unless necessary for correctness.

## Nullability

- Distinguish missing, empty, zero, and invalid.
- Do not convert null into the string `"null"`.
- Do not make optional fields required without validating historical data.
- UI should degrade gracefully for optional media/duration.
- Backend validation should enforce true business requirements.

## Time and duration

Use explicit units in names where ambiguous:

- `durationSeconds`
- `positionMs`
- `timeoutMinutes`

Do not mix seconds and milliseconds silently.

## URL handling

- Store relative media paths in DB.
- Generate public URLs centrally.
- Normalize compatibility values once in Flutter.
- Do not concatenate URLs in widgets.
- Do not hardcode hosts inside controllers/models/widgets.

## Error messages

User-facing error:
- understandable
- actionable
- no stack trace or secret

Developer log:
- operation
- entity ID where safe
- exception
- endpoint/context
- no secret

## Comments

Comments should explain why, not restate what.

Remove outdated comments when behavior changes.

## Tests

Test behavior and contracts, not private implementation details.

Every regression test should fail before the fix and pass after it where practical.
