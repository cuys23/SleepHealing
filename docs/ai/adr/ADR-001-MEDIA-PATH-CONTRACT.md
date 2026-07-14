# ADR-001 — Media Path and URL Contract

- Status: Accepted
- Context: Historical upload and URL failures
- Scope: Laravel storage, API, Flutter

## Decision

- Database stores relative media paths.
- Laravel uses the explicit `public` disk.
- Laravel/API produces normalized public URL fields.
- Flutter uses a single compatibility resolver for legacy relative values.
- Widgets and player services do not concatenate URLs independently.

## Consequences

Positive:

- environment-independent DB data
- simpler client behavior
- fewer duplicate `/storage` failures
- no container/local filesystem leakage

Negative:

- legacy records may require compatibility handling
- API resources and Flutter models must be tested together

## Verification

- storage feature test
- API resource test
- Flutter URL resolver test
- HTTP check from consumer environment
