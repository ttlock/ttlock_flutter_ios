## 0.0.3

* iOS 平台实现：将 Pigeon Host API 接到 TTLock 原生 iOS SDK（在线分支使用 CocoaPod `TTLock`）。
* 接入 `TTLockDFU`，实现 `TTUpgradeHostApi` 与升级进度流；支持锁 / 网关 / 水电表 / 键盘的网络 DFU 与固件包 DFU。
* 升级中止仅走 Stream `onCancel`；去掉显式 `stop*`，与扫描 cancel 语义对齐。
* 修复同通道二次监听拆掉首路升级会话等问题。
* 透传 `connectAddress`；修正 `setOpenTypeAttributes` 映射；键盘扫描不再透传 `advertisementData`，避免编解码崩溃。
* 对齐 `featureValue` 位图，补齐蓝牙广播间隔与闩锁驱动等级等能力接线。
