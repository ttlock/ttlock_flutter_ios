import Foundation

/// 升级参数槽。中止 DFU 仅在对应 Stream `onCancel` 中处理（对齐扫描）。
final class UpgradeHostApiImpl: NSObject, TTUpgradeHostApi {
  private let context: EventContextStore

  init(context: EventContextStore) {
    self.context = context
  }

  func setUpgradeLockParam(param: TTUpgradeLockParam) throws {
    context.upgradeLock = param
  }

  func setUpgradeGatewayParam(param: TTUpgradeGatewayParam) throws {
    context.upgradeGateway = param
  }

  func setUpgradeGatewayByPackageParam(param: TTUpgradeGatewayByPackageParam) throws {
    context.upgradeGatewayByPackage = param
  }

  func setUpgradeWaterMeterParam(param: TTUpgradeWaterMeterParam) throws {
    context.upgradeWaterMeter = param
  }

  func setUpgradeWaterMeterByPackageParam(param: TTUpgradeWaterMeterByPackageParam) throws {
    context.upgradeWaterMeterByPackage = param
  }

  func setUpgradeElectricMeterParam(param: TTUpgradeElectricMeterParam) throws {
    context.upgradeElectricMeter = param
  }

  func setUpgradeElectricMeterByPackageParam(param: TTUpgradeElectricMeterByPackageParam) throws {
    context.upgradeElectricMeterByPackage = param
  }

  func setUpgradeKeypadParam(param: TTUpgradeKeypadParam) throws {
    context.upgradeKeypad = param
  }

  func setUpgradeKeypadByPackageParam(param: TTUpgradeKeypadByPackageParam) throws {
    context.upgradeKeypadByPackage = param
  }
}
