import Foundation

/// 升级参数槽。中止 DFU 仅在对应 Stream `onCancel` 中处理（对齐扫描）。
///
/// premise：锁包 / 网关包 / 水电表包 / 键盘包可用；锁网络 / 网关网络 / 设备网络不可用
///（`TTDeviceDFU` OnPremise 仅有固件包重载）。
final class UpgradeHostApiImpl: NSObject, TTUpgradeHostApi {
  private let context: EventContextStore

  init(context: EventContextStore) {
    self.context = context
  }

  func setUpgradeLockParam(param: TTUpgradeLockParam) throws {
    throw makeUpgradeNotImplementedError("setUpgradeLockParam")
  }

  func setUpgradeLockByPackageParam(param: TTUpgradeLockByPackageParam) throws {
    context.upgradeLockByPackage = param
  }

  func setUpgradeGatewayParam(param: TTUpgradeGatewayParam) throws {
    throw makeUpgradeNotImplementedError("setUpgradeGatewayParam")
  }

  func setUpgradeGatewayByPackageParam(param: TTUpgradeGatewayByPackageParam) throws {
    context.upgradeGatewayByPackage = param
  }

  func setUpgradeWaterMeterParam(param: TTUpgradeWaterMeterParam) throws {
    throw makeUpgradeNotImplementedError("setUpgradeWaterMeterParam")
  }

  func setUpgradeWaterMeterByPackageParam(param: TTUpgradeWaterMeterByPackageParam) throws {
    context.upgradeWaterMeterByPackage = param
  }

  func setUpgradeElectricMeterParam(param: TTUpgradeElectricMeterParam) throws {
    throw makeUpgradeNotImplementedError("setUpgradeElectricMeterParam")
  }

  func setUpgradeElectricMeterByPackageParam(param: TTUpgradeElectricMeterByPackageParam) throws {
    context.upgradeElectricMeterByPackage = param
  }

  func setUpgradeKeypadParam(param: TTUpgradeKeypadParam) throws {
    throw makeUpgradeNotImplementedError("setUpgradeKeypadParam")
  }

  func setUpgradeKeypadByPackageParam(param: TTUpgradeKeypadByPackageParam) throws {
    context.upgradeKeypadByPackage = param
  }
}
