# Changelog

## [1.4.0] - 2026-05-07

### Added
- `JestPurchase.price` (float) and `JestPurchase.currency` (String, ISO 4217) —
  populated from the platform's purchase response so games can display the
  amount paid in the original currency.
- `JestProduct.currency` (String, ISO 4217) — alongside `price`, returned by
  `JestSDK.payment.get_products()` so games can format prices correctly.
- `JestSDK.get_bot_avatar(username, size = 1000)` — returns a CDN URL for a
  deterministic bot avatar seeded by username. `size` accepts 64, 128, 256, 512,
  or 1000; intermediate values bucket down to the next supported size. The hash
  is bit-compatible with the HTML5 SDK so the same username yields the same
  avatar across SDKs.
- `JestNotificationOptions.BODY_CHAR_LIMIT` (2000), `TITLE_CHAR_LIMIT` (200),
  `CTA_CHAR_LIMIT` (50) — exposed as public constants on the resource.

### Changed
- `JestNotificationOptions.validate()` now also enforces:
  - `body` must be at most 2000 characters.
  - `title` must be at most 200 characters when set.
  - `cta_text` limit raised from 25 to 50 characters (mirrors HTML5 SDK).
- `JestSDK.open_privacy_policy()`, `open_terms_of_service()`, and
  `open_copyright()` doc-marked `@internal`. They remain callable but are not
  part of the supported public API surface (mirrors the HTML5 SDK).

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
