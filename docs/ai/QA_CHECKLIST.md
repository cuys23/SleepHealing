# QA Checklist

Use the relevant sections before declaring completion.

## Universal

- [ ] Acceptance criteria listed
- [ ] Root cause verified
- [ ] Final diff reviewed
- [ ] No unrelated changes
- [ ] No temporary debugging code
- [ ] Errors are not swallowed
- [ ] Existing user data preserved
- [ ] Unverified items listed

## Flutter

- [ ] `flutter analyze`
- [ ] `flutter test`
- [ ] Loading state
- [ ] Error state
- [ ] Empty state
- [ ] Populated state
- [ ] Null optional fields
- [ ] Small screen
- [ ] Large screen
- [ ] Back/navigation behavior
- [ ] No stale provider/cache state
- [ ] No hardcoded environment URL

## Media

- [ ] DB stores relative path
- [ ] API returns reachable URL
- [ ] URL contains no localhost/container hostname
- [ ] Image HTTP response works
- [ ] Audio HTTP response works
- [ ] Replacement upload works
- [ ] Null media works
- [ ] Container restart preserves files
- [ ] Cache does not permanently show replaced image

## Audio

- [ ] First play
- [ ] Pause/resume
- [ ] Seek
- [ ] Next/previous
- [ ] Completion
- [ ] Position updates
- [ ] Duration updates
- [ ] Background/notification behavior where relevant
- [ ] Sleep timer interaction
- [ ] Error stream/log checked
- [ ] No duplicate player instance

## Laravel/Admin

- [ ] Route/method correct
- [ ] CSRF/auth behavior correct
- [ ] Validation visible
- [ ] Create
- [ ] Update
- [ ] Delete if in scope
- [ ] Pagination ordering
- [ ] Status/visibility
- [ ] Storage path
- [ ] API resource
- [ ] Cache invalidation
- [ ] PHPUnit relevant suite

## Docker/VPS

- [ ] `docker compose config`
- [ ] Correct environment
- [ ] Volumes present
- [ ] DB healthy
- [ ] App logs checked
- [ ] No destructive volume command
- [ ] Public port reachable
- [ ] Storage symlink valid
- [ ] Restart persistence verified where relevant

## Release

- [ ] Production API HTTPS
- [ ] Debug logging disabled
- [ ] Secrets not committed
- [ ] Version/build number updated
- [ ] App icon/splash validated
- [ ] Privacy/permission strings accurate
- [ ] Purchase restore flow tested if applicable
- [ ] Store metadata and URLs ready
