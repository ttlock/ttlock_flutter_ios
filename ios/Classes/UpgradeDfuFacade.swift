import Foundation
import TTLockDFUSDK
import TTLockSDK

/// premise 的 DFU 入口。模块别名是 `TTLockDFUSDK`，锁类名仍是 `TTLockDFUOnPremise`。
/// 网关类名是 `TTGatewayDFU`。水电表 / 键盘本轮不调用 `TTDeviceDFU`。
enum UpgradeDfuFacade {
  static func startLock(
    firmwarePackage: String,
    lockData: String,
    onProgress: @escaping (TTUpgradeStatus, Int) -> Void,
    onSuccess: @escaping () -> Void,
    onError: @escaping (TTLockUpgradeError, String?) -> Void
  ) {
    TTLockDFUOnPremise.shareInstance().startDfu(
      withFirmwarePackage: firmwarePackage,
      lockData: lockData,
      successBlock: { operation, progress in
        handleOperation(operation, progress: progress, onProgress: onProgress, onSuccess: onSuccess)
      },
      fail: { _, code in
        handleFailure(code, onError: onError)
      }
    )
  }

  static func stopLock() {
    TTLockDFUOnPremise.shareInstance().endUpgrade()
  }

  static func startGatewayPackage(
    firmwarePackage: String,
    gatewayMac: String,
    onProgress: @escaping (TTUpgradeStatus, Int) -> Void,
    onSuccess: @escaping () -> Void,
    onError: @escaping (TTLockUpgradeError, String?) -> Void
  ) {
    TTGatewayDFU.shareInstance().start(
      withFirmwarePackage: firmwarePackage,
      gatewayMac: gatewayMac,
      successBlock: { operation, progress in
        handleOperation(operation, progress: progress, onProgress: onProgress, onSuccess: onSuccess)
      },
      fail: { _, code in
        handleFailure(code, onError: onError)
      }
    )
  }

  static func stopGateway() {
    TTGatewayDFU.shareInstance().endUpgrade()
  }

  /// 锁升级成功后刷新 lockData。`TTLockOnPremise` 2.2.6 走 `getLockSystemInfoWithLockData`。
  /// 失败交给调用方映射为 `getSpecialValueError`，这里不吞。
  static func refreshLockSystemInfo(
    lockData: String,
    onSuccess: @escaping (String) -> Void,
    onError: @escaping (String?) -> Void
  ) {
    TTLock.getLockSystemInfo(withLockData: lockData) { systemModel in
      guard let refreshed = systemModel?.lockData, !refreshed.isEmpty else {
        onError("getLockSystemInfo returned empty lockData")
        return
      }
      onSuccess(refreshed)
    } failure: { _, errorMsg in
      onError(errorMsg)
    }
  }

  /// `UpgradeOpration.preparing` 的 raw 是 1，不能当作 `TTUpgradeStatus` 下标。`success` 不是进度状态。
  private static func handleOperation(
    _ operation: UpgradeOpration,
    progress: Int,
    onProgress: (TTUpgradeStatus, Int) -> Void,
    onSuccess: () -> Void
  ) {
    switch operation {
    case .preparing:
      onProgress(.preparing, progress)
    case .upgrading:
      onProgress(.upgrading, progress)
    case .recovering:
      onProgress(.recovering, progress)
    case .success:
      onSuccess()
    @unknown default:
      onProgress(.upgrading, progress)
    }
  }

  /// 按 ObjC case 名映射。`UpgradeOprationSetLockTimeError` 没有同名枚举，落入 `upgradeFail` 并保留原文。
  private static func handleFailure(
    _ code: UpgradeErrorCode,
    onError: (TTLockUpgradeError, String?) -> Void
  ) {
    let mapped = upgradeError(from: code)
    onError(mapped.error, mapped.message)
  }

  private static func upgradeError(from code: UpgradeErrorCode) -> (
    error: TTLockUpgradeError, message: String
  ) {
    switch code {
    case .errorCodePeripheralPoweredOff:
      return (.peripheralPoweredOff, "peripheralPoweredOff")
    case .errorCodeConnectTimeout:
      return (.connectTimeout, "connectTimeout")
    case .errorCodeNetFail:
      return (.netFail, "netFail")
    case .errorNONeedUpgrade:
      return (.noNeedUpgrade, "noNeedUpgrade")
    case .errorUnknownUpgradeVersion:
      return (.unknownUpgradeVersion, "unknownUpgradeVersion")
    case .errorCodeEnterUpgradeState:
      return (.enterUpgradeState, "enterUpgradeState")
    case .errorCodeUpgradeLockFail:
      return (.upgradeLockFail, "upgradeLockFail")
    case .oprationPreparingError:
      return (.preparingError, "preparingError")
    case .oprationGetSpecialValueError:
      return (.getSpecialValueError, "getSpecialValueError")
    case .errorCodeUpgradeFail:
      return (.upgradeFail, "upgradeFail")
    case .oprationSetLockTimeError:
      return (.upgradeFail, "setLockTimeError")
    @unknown default:
      return (.upgradeFail, "upgradeFail")
    }
  }
}
