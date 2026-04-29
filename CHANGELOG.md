# Changelog

## [1.3.0] - 2026-04-29

### Added
- `JestSDK.show_registration_overlay(options)` convenience wrapper.

## [1.2.0] - 2026-04-24

### Added
- `JestPlayer.username` and `JestPlayer.avatar_url` — mirror the new fields
  returned by the platform's `getPlayer()` response. `JestSignedPlayer` now
  carries the same two fields.
- `JestNotificationOptions.title` — optional notification title.
- `JestNotificationOptions.asset_reference` — preferred replacement for
  `image_reference` (still accepted as a fallback).
- `JestNotificationOptions.priority` now accepts `"critical"` alongside
  `"low" / "medium" / "high"`.
- `JestSDK.registration_overlay.show(options)` — opens the platform
  registration overlay with game-rendered UI. Returns a
  `JestRegistrationOverlayHandle` exposing `login_button_action()`,
  `close_button_action()`, and a `closed` signal.
- New resource `JestRegistrationOverlayOptions` for configuring the overlay.

### Deprecated
- `JestNotificationOptions.image_reference` — use `asset_reference` instead.

## [1.1.1]

- Migration to CDN-hosted SDK (inline injection removed).
- Fixed referrals response transformation.

## [1.1.0]

- Added `estimated_revenue` to `JestPurchase`; `credits` is now float.
- Guest purchases allowed.

## [1.0.0]

- Initial release.
