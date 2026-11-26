import Foundation

/// 与 Android premise / OHOS 对齐：code 为 `TTLockError.fail` 数字串，message 为 notImplemented。
func makeUpgradeNotImplementedError(operation: String) -> PigeonError {
  PigeonError(
    code: "\(TTLockError.fail.rawValue)",
    message: "notImplemented",
    details: "\(operation) is not implemented on premise"
  )
}

/// 升级参数槽与停止。premise 只实现锁包和网关包；停止只结束对应客户端。
final class UpgradeHostApiImpl: NSObject, TTUpgradeHostApi {
  private let context: EventContextStore

  init(context: EventContextStore) {
    self.context = context
  }

  func setUpgradeLockParam(param: TTUpgradeLockParam) throws {
    context.upgradeLock = param
  }

  func setUpgradeGatewayParam(param: TTUpgradeGatewayParam) throws {
    throw makeUpgradeNotImplementedError(operation: "setUpgradeGatewayParam")
  }

  func setUpgradeGatewayByPackageParam(param: TTUpgradeGatewayByPackageParam) throws {
    context.upgradeGatewayByPackage = param
  }

  func setUpgradeWaterMeterParam(param: TTUpgradeWaterMeterParam) throws {
    throw makeUpgradeNotImplementedError(operation: "setUpgradeWaterMeterParam")
  }

  func setUpgradeWaterMeterByPackageParam(param: TTUpgradeWaterMeterByPackageParam) throws {
    throw makeUpgradeNotImplementedError(operation: "setUpgradeWaterMeterByPackageParam")
  }

  func setUpgradeElectricMeterParam(param: TTUpgradeElectricMeterParam) throws {
    throw makeUpgradeNotImplementedError(operation: "setUpgradeElectricMeterParam")
  }

  func setUpgradeElectricMeterByPackageParam(param: TTUpgradeElectricMeterByPackageParam) throws {
    throw makeUpgradeNotImplementedError(operation: "setUpgradeElectricMeterByPackageParam")
  }

  func setUpgradeKeypadParam(param: TTUpgradeKeypadParam) throws {
    throw makeUpgradeNotImplementedError(operation: "setUpgradeKeypadParam")
  }

  func setUpgradeKeypadByPackageParam(param: TTUpgradeKeypadByPackageParam) throws {
    throw makeUpgradeNotImplementedError(operation: "setUpgradeKeypadByPackageParam")
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
    throw makeUpgradeNotImplementedError(operation: "stopUpgradeWaterMeter")
  }

  func stopUpgradeElectricMeter() throws {
    throw makeUpgradeNotImplementedError(operation: "stopUpgradeElectricMeter")
  }

  func stopUpgradeKeypad() throws {
    throw makeUpgradeNotImplementedError(operation: "stopUpgradeKeypad")
  }
}
