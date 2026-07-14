# Flutter Engineering Guidelines

## Verified stack

Current dependencies include Riverpod, Dio, Hive, Freezed, cached network image, audio_service, just_audio, and audioplayers.

Inspect actual usage before changing architecture.

## State management

- There must be one authoritative state owner per domain.
- UI should watch providers and render state; avoid hidden mutable globals.
- Avoid creating providers inside build methods.
- Dispose subscriptions/controllers appropriately.
- Use `ref.read` for commands and `ref.watch` for rendering.
- Invalidate/refetch intentionally after mutations.
- Do not preserve stale remote state indefinitely without a refresh policy.

## Networking

Use one configured Dio/API client per environment.

Centralize:

- base URL
- timeout
- headers
- token handling
- JSON/error mapping
- logging policy

Never log authorization tokens.

Handle:

- non-JSON responses
- 302/login HTML redirects
- timeouts
- no connectivity
- 401/403
- 422 validation
- 500 errors
- malformed payloads

## Models

Parsing must tolerate compatible backend variation.

Common compatibility cases:

- int versus numeric string
- nullable image/audio
- nested media object versus URL field
- relative versus absolute URL
- absent optional relationships

Do not let one malformed item silently turn an entire valid list into an empty list.

When using Freezed/generated code, run required generation and commit generated files according to current repository convention.

## Media URL resolver

There should be one resolver with behavior equivalent to:

```text
absolute public URL → unchanged
/storage/x         → base origin + /storage/x
storage/x          → base origin + /storage/x
images/x           → base origin + /storage/images/x
empty/null         → null or product placeholder
```

Reject obvious local filesystem paths.

## Images

- Prefer existing shared image component.
- Use placeholder only for genuine absence/failure.
- Preserve aspect ratio and avoid layout shifts.
- Expose enough error detail in development logs.
- Verify cache behavior after media replacement.
- Do not append random query parameters as a permanent cache strategy.

## Audio

Before editing, identify:

- active player package
- audio handler/service
- player instance ownership
- queue model
- position/duration streams
- background playback integration

Rules:

- one active source of playback truth
- selected track state and player source must agree
- runtime position drives elapsed UI
- runtime duration is preferred when valid
- database duration is fallback metadata
- restore position only after source is loaded
- protect against double-tap/race conditions
- report player errors
- dispose streams safely
- preserve background/notification behavior

## UI redesign

- Preserve business behavior while changing visuals.
- Keep touch targets usable.
- Respect safe areas.
- Test small and large screens.
- Avoid hardcoded heights that clip translated text.
- Do not reintroduce removed features.
- Keep loading, empty, error, and populated states.

## Platform networking

For development, distinguish:

- Android emulator host mapping
- iOS simulator host access
- physical device LAN access
- VPS public URL

Production should use HTTPS. Treat cleartext exceptions as development-only and document them.

## Required Flutter checks

```bash
flutter pub get
flutter analyze
flutter test
```

For iOS-impacting changes, also perform an iOS build or simulator check when environment permits.
