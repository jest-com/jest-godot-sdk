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
- `lifecycle`: verifies the `hidden`/`shown`/`exit_requested` signals expose a
  connect/disconnect cycle without error. The events themselves are
  host-triggered (document visibility, platform exit flow) and not exercised
  here.
- `referrals-read`: referral listing.
- `referrals-share`: share dialog with reference, entry payload, share text,
  and notification templates.
- `internal`: feature flag lookup, name validation, and onboarding event capture.
- `legal`: privacy, terms, and copyright openers.
- `guardrails`: validation paths that should not call the host.

Positive navigation, login, registration overlay, purchase checkout,
subscription checkout, subscription cancellation, and retention offer claim flows
are not launched here because they can navigate away from the test iframe, require
user interaction, or mutate one-time entitlement state. Their validation paths are
covered by guardrail scenarios and existing unit tests.

## Building

The release workflow exports the `JestSDKRegression` Web preset and uploads:

```text
jest-godot-sdk-regression-web.zip
```

That zip is downloaded by textclub's SDK functional regression workflow.
