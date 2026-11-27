# ttlock_flutter_ios

[English](./README.md)

[`ttlock_flutter`](https://github.com/ttlock/ttlock_flutter_plus) 联邦插件的 **iOS 平台实现**。宿主 App 通常只依赖 **`ttlock_flutter`**，由它在 iOS 上选用本包。当你维护 iOS 子模块、自定义 CocoaPods，或排查原生 SDK 链接问题时，请以本文为准。

> 当前包版本：**0.0.3**（以 `pubspec.yaml` 为准）。  
> 本分支（**`premise`**）依赖 **本地化（On-Premise）** CocoaPod **`TTLockOnPremise`**。

## 在技术栈中的位置

```text
App  →  ttlock_flutter（Dart API）
     →  ttlock_flutter_platform_interface（Pigeon）
     →  ttlock_flutter_ios（本包）  →  TTLock iOS SDK（CocoaPods）
```

对外 Dart API 在父插件（`package:ttlock_flutter/ttlock.dart`）。本包负责把 Pigeon Host API 接到 TTLock iOS 原生 SDK。

## 固件升级

除 `TTLockOnPremise` 外另依赖 CocoaPod **`TTLockDFUOnPremise`**。本地化（`premise`）仅编译**锁固件包**与**网关固件包** DFU。约定见父仓库 [README_ZH](https://github.com/ttlock/ttlock_flutter_plus/blob/main/README_ZH.md)「固件升级」。

## 原生 SDK（本分支：本地化）

| 项 | 值 |
|----|-----|
| 分支 | `premise` |
| CocoaPod | `TTLockOnPremise` **2.2.6** |
| DFU CocoaPod | `TTLockDFUOnPremise` **2.2.6**（传递 `iOSDFULibrary ~> 4.14.0`） |
| 声明位置 | `ios/ttlock_flutter_ios.podspec` |
| 最低 iOS | **12.0** |
| Swift 模块别名 | `-module-alias TTLockSDK=TTLockOnPremise -module-alias TTLockDFUSDK=TTLockDFUOnPremise` |

已启用 `s.static_framework = true`。模块别名用于在链接本地化 Pod 时，通过 `TTLockSDK` / `TTLockDFUSDK` 引用 SDK 类型。

请确认 CocoaPods specs / 私有源可以解析 `TTLockOnPremise`（以本地化交付为准）。修改 podspec 或切换分支后请重新安装 Pod：

```bash
cd ios
pod install
# 或在 Flutter 宿主工程中：
flutter pub get
cd ios && pod install
```

## 与 `main` 的差异

| | `premise`（本分支） | `main` |
|--|---------------------|--------|
| 场景 | 本地化（On-Premise） | 在线 / 云端 SDK |
| CocoaPod | `TTLockOnPremise`（如 2.2.6） | `TTLock`（如 3.6.16） |
| DFU CocoaPod | `TTLockDFUOnPremise`（如 2.2.6） | `TTLockDFU`（如 3.6.14） |
| 模块别名 | `TTLockSDK=TTLockOnPremise` / `TTLockDFUSDK=TTLockDFUOnPremise` | `TTLockSDK=TTLock` / `TTLockDFUSDK=TTLockDFU` |
| 升级能力 | 仅锁固件包 + 网关固件包 | 全量 |

不要在同一 App Target 混用在线版与本地化 Pod。在线 / 云端打包请改用 **`main`** 分支。

## 权限（宿主 App）

在 `ios/Runner/Info.plist` 配置用途说明：

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>需要使用蓝牙连接智能锁与网关设备</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>需要使用蓝牙连接智能锁与网关设备</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>扫描附近蓝牙设备需要定位权限</string>
```

人脸场景按需补充相机 / 相册说明。首次使用蓝牙时系统会弹窗授权。

## 通过父插件接入

多数 App 应依赖父包，而不是单独依赖本包：

```yaml
dependencies:
  ttlock_flutter:
    git:
      url: https://github.com/ttlock/ttlock_flutter_plus.git
      path: ttlock_flutter
```

本地化发版时，请确认父工程 / 子模块把本包钉在 **`premise`** 分支。

```dart
import 'package:ttlock_flutter/ttlock.dart';
```

能力一览、BleGuard、API 总览见父仓库 [README_ZH](https://github.com/ttlock/ttlock_flutter_plus/blob/main/README_ZH.md)。

## 相关资源

- 父插件仓库：<https://github.com/ttlock/ttlock_flutter_plus>
- 本包 homepage（pubspec）：同上父仓库
- 本地化原生 SDK：从通通锁本地化 CocoaPods 交付源解析 `TTLockOnPremise`
