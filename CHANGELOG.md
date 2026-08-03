# Changelog

## [1.10.0] - 2026-08-03

### Added

- `JestSDK.payment.claim_retention_offer(sku)` — applies a subscription's configured
  retention discount to the player's existing subscription instantly, no checkout.
  Returns a `JestSubscriptionResult` with the refreshed subscription, or an error
  (`"not_eligible"` when already claimed, ineligible, or an intro offer is still
  running).
- `JestSubscription.retention_offer` — the retention discount the wallet can claim
  once via `claim_retention_offer`. Empty `Dictionary` when none available.

## [1.9.1] - 2026-06-15

### Fixed

- Regression web export is now packaged with `index.html` at the archive root,
  so it uploads cleanly to the platform (release tooling only; no SDK changes).

## [1.9.0] - 2026-06-05

### Changed

- `JestSDK.login()` is now a coroutine that resumes when the player dismisses the
  login popup, or immediately when the player is already registered. `await` it to
  run code after the flow completes; fire-and-forget callers are unaffected.

### Added

- `JestUtils.texture_to_data_url(texture)` / `JestUtils.image_to_data_url(image)` —
  encode a texture or image to a PNG base64 data URL (for image fields such as the
  referral `share_image`). Compressed images are decompressed first.

### Deprecated

- `JestSubscription.estimated_revenue` — always `0`. Kept for backwards
  compatibility and will be removed in a future release.

## [1.5.1] - 2026-05-15

### Added

- `JestSDK.social` — groups profile and avatar helpers to match the HTML5 SDK's
  social module. Includes:
  - `JestSDK.social.get_profile(avatar_size = 1000)` — returns a Dictionary with
    `username` and a resized `avatar_url`.
  - `JestSDK.social.get_player_avatar(size = 1000)` — returns only the current
    player's resized avatar URL.
  - `JestSDK.social.get_bot_avatar(username, size = 1000)` — returns a
    deterministic bot avatar URL.
    Sizes accept 64, 128, 256, 512, or 1000; intermediate values bucket down to
    the next supported size. Localhost player avatar URLs pass through unwrapped
    because Cloudflare can't fetch them in dev.
- Root `JestSDK.get_player_avatar(...)` and `JestSDK.get_bot_avatar(...)` remain
  compatibility aliases for the social module.

## [1.5.0] - 2026-05-13

### Added

- `JestSDK.get_player_avatar(size = 1000)` — returns a CDN URL for the current
  player's avatar, routed through Cloudflare Image Resizing so Godot receives a
  decodable image format instead of the raw bucket file. Returns an empty string
  when the player has no avatar. `size` accepts 64, 128, 256, 512, or 1000;
  intermediate values bucket down to the next supported size. Localhost URLs are
  passed through unwrapped (Cloudflare can't fetch them in dev). Mirrors the
  HTML5 SDK's `social.getProfile({ avatarSize })`.

### Changed

- Sized avatar URLs now request `format=webp` from Cloudflare instead of
  `format=auto`, avoiding browser-dependent AVIF responses in Godot.
- Web exports pass the Godot SDK version through `JestSDK.init` instead of
  patching `window.parent.postMessage`.

## [1.4.1] - 2026-05-12

### Changed

- `JestSDK.get_bot_avatar()` URL path changed from
  `cdn.jest.com/avatar/bot/<N>.webp` to `cdn.jest.com/avatars/bot/<N>.webp`,
  aligning with player avatars (`cdn.jest.com/avatars/<uuid>.webp`) so both
  live under a single `/avatars/*` prefix. The platform-side migration must
  run before this SDK is shipped, or `get_bot_avatar()` will return URLs
  that 404.

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
