# API Contract Standards

## Goals

The API contract must be:

- stable
- explicit
- null-safe
- mobile-friendly
- backward-compatible where practical
- independent of container/local filesystem details

## Standard response principles

Prefer consistent envelope shape within the existing API convention.

Example entity:

```json
{
  "id": 123,
  "name": "Morning Rain",
  "image_url": "https://api.example.com/storage/images/playlist/a.webp",
  "audio_url": "https://api.example.com/storage/audio/playlist/a.mp3",
  "duration": 240,
  "is_active": true
}
```

## Media fields

Preferred normalized fields:

- `image_url`
- `audio_url`

Legacy fields may remain temporarily:

- `image`
- `thumbnail`
- `src`
- nested `media`

Do not remove a legacy field until all consumers are verified.

## Duration

Preferred unit: seconds, integer.

If legacy data may be string:

- normalize in API when safe
- keep Flutter parser compatible
- test null, zero, integer, numeric string

## Null semantics

Use JSON null for genuinely absent optional values.

Do not use:

- empty object instead of null
- `"null"` string
- invalid placeholder URL presented as real media

## Error contract

API errors should use correct status codes and structured JSON.

At minimum include:

- message
- validation details for 422
- stable error code where current architecture supports it

Do not expose stack traces in production.

## Contract-change procedure

Before changing a response:

1. search all Flutter consumers
2. inspect Admin/AJAX consumers
3. add compatibility field if needed
4. add API test
5. update model test
6. update this file
