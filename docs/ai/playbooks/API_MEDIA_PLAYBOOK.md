# API and Media Playbook

## Trace

```text
Admin form
→ validation
→ storage
→ DB media path
→ API query
→ Resource
→ JSON
→ Flutter model
→ URL resolver
→ image/player
```

## Required checks

- correct disk
- file exists
- relative DB path
- public URL
- same DB for Admin/API
- active/status visibility
- deterministic order
- cache invalidation
- JSON field/type
- Flutter parsing
- consumer-reachable URL
- restart persistence

## HTTP checks

```bash
curl -I "IMAGE_URL"
curl -I "AUDIO_URL"
curl -i -H "Range: bytes=0-1023" "AUDIO_URL"
```

HTTP reachability is not full playback verification.
