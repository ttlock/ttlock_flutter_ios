# ttlock_flutter_ios

[中文文档](./README_ZH.md)

iOS platform implementation of the [`ttlock_flutter`](https://github.com/ttlock/ttlock_flutter) federated plugin. Host apps normally depend on **`ttlock_flutter`**, which selects this package on iOS. Use this README when you maintain the iOS submodule, customize CocoaPods, or debug native SDK linkage.

> Current package version: **0.0.3** (see `pubspec.yaml`).  
> This branch (**`premise`**) depends on the **on-premise** CocoaPod **`TTLockOnPremise`**.

## Role in the stack

```text
App  →  ttlock_flutter (Dart API)
     →  ttlock_flutter_platform_interface (Pigeon)
     →  ttlock_flutter_ios (this package)  →  TTLock iOS SDK (CocoaPods)
```

Dart-facing APIs live in the parent plugin (`package:ttlock_flutter/ttlock.dart`). This package wires Pigeon host APIs to the native TTLock iOS SDK.

## Firmware upgrade

Depends on CocoaPod **`TTLockDFUOnPremise`** in addition to `TTLockOnPremise`. On-premise (`premise`) compiles **lock firmware-package** and **gateway firmware-package** DFU only. See the parent [README](https://github.com/ttlock/ttlock_flutter/blob/mix/README.md) «Firmware upgrade».

## Native SDK (this branch: on-premise)

| Item | Value |
|------|--------|
| Branch | `premise` |
| CocoaPod | `TTLockOnPremise` **2.2.6** |
| DFU CocoaPod | `TTLockDFUOnPremise` **2.2.6**（pulls `iOSDFULibrary ~> 4.14.0`） |
| Declared in | `ios/ttlock_flutter_ios.podspec` |
| Min iOS | **12.0** |
| Swift module alias | `-module-alias TTLockSDK=TTLockOnPremise -module-alias TTLockDFUSDK=TTLockDFUOnPremise` |

`s.static_framework = true` is enabled. Module aliases let Swift refer to SDK types via `TTLockSDK` / `TTLockDFUSDK` while linking the on-premise pods.

Ensure your CocoaPods specs / private source can resolve `TTLockOnPremise` (as provided in your on-premise delivery). After changing the podspec or switching branches:

```bash
cd ios
pod install
# or from the Flutter app:
flutter pub get
cd ios && pod install
```

## Diff vs `main`

| | `premise` (this branch) | `main` |
|--|-------------------------|--------|
| Scenario | On-premise | Online / cloud SDK |
| CocoaPod | `TTLockOnPremise` (e.g. 2.2.6) | `TTLock` (e.g. 3.6.16) |
| DFU CocoaPod | `TTLockDFUOnPremise` (e.g. 2.2.6) | `TTLockDFU` (e.g. 3.6.14) |
| Module alias | `TTLockSDK=TTLockOnPremise` / `TTLockDFUSDK=TTLockDFUOnPremise` | `TTLockSDK=TTLock` / `TTLockDFUSDK=TTLockDFU` |
| Upgrade APIs | Lock package + gateway package | Full set |

Do not mix online and on-premise pods in one app target. For online / cloud packaging, use the **`main`** branch.

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

Ensure the parent checkout / submodule pins this package’s **`premise`** branch when you ship on-premise.

```dart
import 'package:ttlock_flutter/ttlock.dart';
```

See the parent [README](https://github.com/ttlock/ttlock_flutter/blob/mix/README.md) for features, BleGuard, and API overview.

## Resources

- Parent plugin: <https://github.com/ttlock/ttlock_flutter>
- This package homepage (pubspec): same parent repo
- On-premise native SDK: resolve `TTLockOnPremise` from your TTLock on-premise CocoaPods delivery
