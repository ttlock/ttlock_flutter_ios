# ttlock_flutter_ios

[中文文档](./README_ZH.md)

iOS platform implementation of the [`ttlock_flutter`](https://github.com/ttlock/ttlock_flutter) federated plugin. Host apps normally depend on **`ttlock_flutter`**, which selects this package on iOS. Use this README when you maintain the iOS submodule, customize CocoaPods, or debug native SDK linkage.

> Current package version: **0.0.3** (see `pubspec.yaml`).  
> This branch (**`main`**) depends on the **online / cloud** CocoaPod **`TTLock`**.

## Role in the stack

```text
App  →  ttlock_flutter (Dart API)
     →  ttlock_flutter_platform_interface (Pigeon)
     →  ttlock_flutter_ios (this package)  →  TTLock iOS SDK (CocoaPods)
```

Dart-facing APIs live in the parent plugin (`package:ttlock_flutter/ttlock.dart`). This package wires Pigeon host APIs to the native TTLock iOS SDK.

## Firmware upgrade

Depends on CocoaPod **`TTLockDFU`** in addition to `TTLock`. Wires `TTUpgradeHostApi` + upgrade EventChannels to `TTLockDFU`. Online (`main`) supports lock / gateway (network + package) / water meter / electric meter / keypad upgrade. See the parent [README](https://github.com/ttlock/ttlock_flutter/blob/mix/README.md) «Firmware upgrade».

## Native SDK (this branch: online)

| Item | Value |
|------|--------|
| Branch | `main` |
| CocoaPod | `TTLock` **3.6.16** |
| DFU CocoaPod | `TTLockDFU` **3.6.14**（pulls `iOSDFULibrary ~> 4.14.0`） |
| Declared in | `ios/ttlock_flutter_ios.podspec` |
| Min iOS | **12.0** |
| Swift module alias | `-module-alias TTLockSDK=TTLock -module-alias TTLockDFUSDK=TTLockDFU` |

`s.static_framework = true` is enabled. Module aliases exist because the binaries expose both the module name and the main class as `TTLock` / `TTLockDFU`; Swift imports types via `TTLockSDK` / `TTLockDFUSDK`.

After changing the podspec or switching branches:

```bash
cd ios
pod install
# or from the Flutter app:
flutter pub get
cd ios && pod install
```

## Diff vs `premise`

| | `main` (this branch) | `premise` |
|--|----------------------|-----------|
| Scenario | Online / cloud SDK | On-premise |
| CocoaPod | `TTLock` (e.g. 3.6.16) | `TTLockOnPremise` (e.g. 2.2.6) |
| DFU CocoaPod | `TTLockDFU` (e.g. 3.6.14) | `TTLockDFUOnPremise` (e.g. 2.2.6) |
| Module alias | `TTLockSDK=TTLock` / `TTLockDFUSDK=TTLockDFU` | `TTLockSDK=TTLockOnPremise` / `TTLockDFUSDK=TTLockDFUOnPremise` |
| Upgrade APIs | Full set | Lock package + gateway package only |

Do not mix online and on-premise pods in one app target. For on-premise packaging, use the **`premise`** branch.

## Permissions (host app)

Add usage descriptions in `ios/Runner/Info.plist`:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Bluetooth is required to connect smart locks and gateways</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>Bluetooth is required to connect smart locks and gateways</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Location permission is required to scan nearby Bluetooth devices</string>
```

Add camera / photo library keys if you enroll faces. The system prompts on first Bluetooth use.

## Integration via parent plugin

Most apps should depend on the parent package, not this package alone:

```yaml
dependencies:
  ttlock_flutter:
    git:
      url: https://github.com/ttlock/ttlock_flutter.git
      path: ttlock_flutter
      ref: mix   # use the release branch / tag your team ships
```

```dart
import 'package:ttlock_flutter/ttlock.dart';
```

See the parent [README](https://github.com/ttlock/ttlock_flutter/blob/mix/README.md) for features, BleGuard, and API overview.

## Resources

- Parent plugin: <https://github.com/ttlock/ttlock_flutter>
- This package homepage (pubspec): same parent repo
- Cloud REST APIs: open-platform `cloud/` docs (lock init / lockData updates must pair with BLE operations)
