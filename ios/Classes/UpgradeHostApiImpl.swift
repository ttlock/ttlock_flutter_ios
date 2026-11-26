import Foundation

/// 升级参数槽与停止。停止只结束对应客户端，不跨锁 / 网关 / 设备互相 abort。
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

  func stopUpgradeLock() throws {
    let sink = UpgradeSession.shared.take(kind: .lock)
    UpgradeDfuFacade.stopLock()
    sink?.endOfStream()
  }

  func stopUpgradeGateway() throws {
    let sink = UpgradeSession.shared.take(kind: .gateway)
    UpgradeDfuFacade.stopGateway()
    sink?.endOfStream()
  }

  func stopUpgradeWaterMeter() throws {
    stopDevice(kind: .water)
  }

  func stopUpgradeElectricMeter() throws {
    stopDevice(kind: .electric)
  }

  func stopUpgradeKeypad() throws {
    stopDevice(kind: .keypad)
  }

  /// 只 `endUpgrade` 设备 DFU。另一台设备正在升级时直接返回，避免误停那一路。
  private func stopDevice(kind: UpgradeKind) {
    switch UpgradeSession.shared.takeDeviceStop(kind: kind) {
    case .ignored:
      return
    case .stopped(let sink):
      UpgradeDfuFacade.stopDevice()
      sink?.endOfStream()
    }
  }
}
