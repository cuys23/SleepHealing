# Architecture Guide

## Status labels

Every architecture statement should be understood as one of:

- **Verified** — observed in repository or runtime
- **Historical** — confirmed by prior project work
- **To verify** — likely but must be checked before change

## System overview

```text
Flutter app (`app/`)
    │
    │ HTTP/JSON
    ▼
Laravel Admin/API (`admin/`)
    │
    ├── MySQL
    ├── public storage/media
    ├── authentication/permissions
    └── Admin Blade interface
            │
            ▼
Docker Compose
    ├── application container
    ├── MySQL container
    ├── mysql_data volume
    └── app_storage volume
```

## Flutter architecture

**Verified dependencies:**

- Riverpod for state management
- Dio for networking
- Hive for local persistence
- Freezed available for immutable/model generation
- audio_service, just_audio, and audioplayers are present
- cached_network_image for network image loading

**Required discovery before changes:**

- which audio package is authoritative
- whether more than one player implementation is active
- exact provider/controller hierarchy
- repository abstraction and API client
- whether Freezed is used consistently or only partially
- current environment/base URL mechanism
- cache invalidation rules

Do not infer active architecture only from dependencies.

## Backend architecture

The Laravel application uses conventional folders and historically includes:

- web routes for Admin
- API routes
- controllers
- repositories
- Eloquent models
- Blade views
- storage/media handling
- PHPUnit feature tests

Historical audit indicates repository classes are used in key Admin media flows.

## Media ownership contract

Recommended and historically validated contract:

```text
Database:
  relative path only

Laravel storage:
  public disk
  storage/app/public/...

Public web:
  /storage/...

API:
  normalized public URL fields

Flutter:
  accepts public URLs
  uses one compatibility resolver for legacy relative values
```

Do not store container paths or host-specific URLs in the database.

## Audio state ownership

There must be one authoritative playback state owner.

It should own or expose:

- selected track
- queue
- playing/buffering state
- position
- duration
- completion
- error
- sleep timer interaction

UI widgets should subscribe to state; they should not maintain competing playback truth.

Database duration is metadata and must not override valid runtime duration blindly.

## Environment boundaries

Keep distinct:

- local Flutter app
- local Laravel Docker
- iOS simulator
- Android emulator
- physical device on LAN
- VPS
- production API
- App Store production build

A URL valid inside one environment may be unreachable from another.

## Architecture update rule

After meaningful changes to:

- API contract
- authentication
- state management
- audio service
- storage
- Docker topology
- deployment
- purchase flow

update this document or create an ADR.
