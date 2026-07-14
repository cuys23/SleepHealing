# Release and App Store Guide

## Release sequence

1. Stabilize frontend.
2. Stabilize API/media integration.
3. Complete authentication.
4. Complete Apple IAP/subscriptions.
5. Complete legal URLs and privacy disclosures.
6. Test on real devices.
7. TestFlight.
8. App Store submission.

## iOS release checks

- Bundle ID confirmed
- App display name confirmed
- Version/build number incremented
- Signing/team/provisioning correct
- App icon has no alpha where prohibited
- Permission descriptions match actual use
- Push notification capability only if used
- Background audio mode only if justified
- HTTPS networking
- No certificate bypass
- No debug/demo credentials
- Restore purchases available
- Subscription terms and privacy links accessible

## IAP principles

- StoreKit/product IDs are environment-specific.
- Never unlock premium solely from local state.
- Restore flow is required.
- Handle pending/cancelled/failed purchases.
- Server validation strategy must be documented before production.
- Do not fake purchase completion in production code.

## App Review readiness

Ensure the reviewer can access required functionality.

If login is required, provide a review account through App Store Connect, not in public documentation.

## Legal

Privacy Policy and Terms URLs must:

- be public
- use HTTPS
- match actual data practices
- remain stable
- be linked in app/store metadata where required
