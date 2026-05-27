# Godot SDK Regression Web Fixture

This folder contains a small Godot Web scene used by textclub's SDK functional
regression workflow. It exercises the Godot SDK addon against the live Jest web
host and reports scenario results to Playwright via `window.parent.postMessage`.

The fixture is intentionally SDK-owned so releases of `jest-godot-sdk` can ship
an export that reflects the current addon code without needing a separate sample
project update.

## Covered scenarios

- `core`: initialization state, entry payload, player basics, loading progress,
  custom analytics event capture.
- `player-data`: string/int/float/bool/json values, bulk set/get, `get_all`,
  `get_player_data`, signed player payload, delete, flush, and local change
  signal.
- `commerce-read`: products, incomplete purchases, and subscriptions.
- `commerce-errors`: Godot-side validation for empty purchase/subscription
  inputs.
- `notifications`: schedule/unschedule and option validation.
- `social`: local bot/profile/avatar helpers. These are host-free in Godot.
- `referrals-read`: referral listing.
- `referrals-share`: share dialog with reference, entry payload, share text,
  onboarding slug, and notification templates.
- `internal`: feature flag lookup, name validation, and onboarding event capture.
- `legal`: privacy, terms, and copyright openers.
- `guardrails`: validation paths that should not call the host.

Positive navigation, login, registration overlay, purchase checkout,
subscription checkout, and subscription cancellation flows are not launched here
because they can navigate away from the test iframe or require user interaction.
Their validation paths are covered by guardrail scenarios and existing unit tests.

## Building

The release workflow exports the `JestSDKRegression` Web preset and uploads:

```text
jest-godot-sdk-regression-web.zip
```

That zip is downloaded by textclub's SDK functional regression workflow.
