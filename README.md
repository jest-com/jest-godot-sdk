# Jest SDK for Godot

Godot 4.x plugin for integrating games with the Jest gaming platform. Provides player management, payments, notifications, referrals, navigation, and more.

**Full documentation:** https://docs.jest.com/

## Installation

1. Copy the `addons/jest_sdk/` folder into your Godot project's `addons/` directory
2. In the Godot editor, go to **Project > Project Settings > Plugins**
3. Enable the **Jest SDK** plugin
4. The `JestSDK` singleton is automatically registered as an autoload

## Quick Start

```gdscript
func _ready():
    var success = await JestSDK.init_sdk()
    if not success:
        print("SDK failed to initialize")
        return
    
    print("Player ID: ", JestSDK.player.id)
    print("Registered: ", JestSDK.player.is_registered)
```

## Web Export

The Jest SDK JavaScript is automatically injected into the exported HTML by the plugin's export hook. No custom HTML shell is needed — just export as Web normally.

## Mock Mode

When running in the Godot editor or on non-web platforms, the SDK automatically uses a mock implementation. Check `JestSDK.is_web` to detect which mode is active.

```gdscript
if not JestSDK.is_web:
    JestSDK.mock.verbose = true                  # Enable console logging
    JestSDK.mock.mock_purchase_succeeds = false   # Simulate purchase cancellation
    JestSDK.mock.is_registered = false            # Simulate unregistered player
```

By default, mock mode is quiet (no console output). Set `verbose = true` for debugging.

## Requirements

- Godot 4.x
- Web export target for production use (editor uses mock mode)

## License

[MIT](LICENSE)
