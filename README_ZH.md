# ttlock_flutter_ios

[English](./README.md)

[`ttlock_flutter`](https://github.com/ttlock/ttlock_flutter) 联邦插件的 **iOS 平台实现**。宿主 App 通常只依赖 **`ttlock_flutter`**，由它在 iOS 上选用本包。当你维护 iOS 子模块、自定义 CocoaPods，或排查原生 SDK 链接问题时，请以本文为准。

> 当前包版本：**0.0.3**（以 `pubspec.yaml` 为准）。  
> 本分支（**`main`**）依赖 **在线 / 云端** CocoaPod **`TTLock`**。

## 在技术栈中的位置

```text
App  →  ttlock_flutter（Dart API）
     →  ttlock_flutter_platform_interface（Pigeon）
     →  ttlock_flutter_ios（本包）  →  TTLock iOS SDK（CocoaPods）
```

对外 Dart API 在父插件（`package:ttlock_flutter/ttlock.dart`）。本包负责把 Pigeon Host API 接到 TTLock iOS 原生 SDK。

## 原生 SDK（本分支：在线版）

| 项 | 值 |
|----|-----|
| 分支 | `main` |
| CocoaPod | `TTLock` **3.6.16** |
| 声明位置 | `ios/ttlock_flutter_ios.podspec` |
| 最低 iOS | **12.0** |
| Swift 模块别名 | `-module-alias TTLockSDK=TTLock` |

已启用 `s.static_framework = true`。模块别名是因为二进制同时把模块名与主类都暴露为 `TTLock`；Swift 侧通过 `TTLockSDK` 别名引用类型。

修改 podspec 或切换分支后请重新安装 Pod：

```bash
cd ios
pod install
# 或在 Flutter 宿主工程中：
flutter pub get
cd ios && pod install
```

## 与 `premise` 的差异

| | `main`（本分支） | `premise` |
|--|------------------|-----------|
| 场景 | 在线 / 云端 SDK | 本地化（On-Premise） |
| CocoaPod | `TTLock`（如 3.6.16） | `TTLockOnPremise`（如 2.2.6） |
| 模块别名 | `TTLockSDK=TTLock` | `TTLockSDK=TTLockOnPremise` |

不要在同一 App Target 混用在线版与本地化 Pod。本地化打包请改用 **`premise`** 分支。

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
      url: https://github.com/ttlock/ttlock_flutter.git
      path: ttlock_flutter
      ref: mix   # 按团队发布分支 / tag 调整
```

```dart
import 'package:ttlock_flutter/ttlock.dart';
```

能力一览、BleGuard、API 总览见父仓库 [README_ZH](https://github.com/ttlock/ttlock_flutter/blob/mix/README_ZH.md)。

## 相关资源

- 父插件仓库：<https://github.com/ttlock/ttlock_flutter>
- 本包 homepage（pubspec）：同上父仓库
- 云端 REST 接口见开放平台 `cloud/` 目录（锁初始化、更新锁数据等需与 BLE 操作配合）
