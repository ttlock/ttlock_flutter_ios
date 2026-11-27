import Foundation
import TTLockDFUSDK
import TTLockSDK

/// 设备 DFU 启动方式。premise `TTDeviceDFU` 只有固件包重载，没有 clientId 网络版。
enum UpgradeDeviceMode {
  case package(firmwarePackage: String)
}

/// 本轮要升级的设备。不包含人体存在传感器。
enum UpgradeHardware {
  case waterMeter
  case electricMeter
  case keypad
}

/// premise 的 DFU 入口。模块别名是 `TTLockDFUSDK`，经 `TTDfuBridge` 调用原生 SDK。
enum UpgradeDfuFacade {
  static func startLock(
    firmwarePackage: String,
    lockData: String,
    onProgress: @escaping (TTUpgradeStatus, Int) -> Void,
    onSuccess: @escaping () -> Void,
    onError: @escaping (TTLockUpgradeError, String?) -> Void
  ) {
    TTDfuBridge.startLockDfu(
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
    TTDfuBridge.endLockUpgrade()
  }

  static func startGatewayPackage(
    firmwarePackage: String,
    gatewayMac: String,
    onProgress: @escaping (TTUpgradeStatus, Int) -> Void,
    onSuccess: @escaping () -> Void,
    onError: @escaping (TTLockUpgradeError, String?) -> Void
  ) {
    TTDfuBridge.startGatewayDfu(
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
    TTDfuBridge.endGatewayUpgrade()
  }

  /// premise `TTDeviceDFUModel` 无 `deviceId` 字段，也无网络 DFU 重载；仅固件包。
  static func startDevice(
    type: UpgradeHardware,
    deviceMac: String,
    lockData: String,
    slotNumber: Int64,
    featureValue: String,
    mode: UpgradeDeviceMode,
    onProgress: @escaping (TTUpgradeStatus, Int) -> Void,
    onSuccess: @escaping () -> Void,
    onError: @escaping (TTLockUpgradeError, String?) -> Void
  ) {
    let model = deviceModel(
      type: deviceType(type),
      deviceMac: deviceMac,
      lockData: lockData,
      slotNumber: slotNumber,
      featureValue: featureValue
    )
    switch mode {
    case .package(let firmwarePackage):
      TTDfuBridge.startDeviceDfu(
        withFirmwarePackage: firmwarePackage,
        deviceModel: model,
        successBlock: { operation, progress in
          handleOperation(operation, progress: progress, onProgress: onProgress, onSuccess: onSuccess)
        },
        fail: { _, code in
          handleFailure(code, onError: onError)
        }
      )
    }
  }

  static func stopDevice() {
    TTDfuBridge.endDeviceUpgrade()
  }

  /// 锁升级成功后刷新 lockData。`TTLockOnPremise` 2.3.0 走 `getLockSystemInfoWithLockData`。
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

  private static func deviceType(_ hardware: UpgradeHardware) -> TTDeviceType {
    switch hardware {
    case .waterMeter:
      return .waterMeter
    case .electricMeter:
      return .electricMeter
    case .keypad:
      return .keypad
    }
  }

  private static func deviceModel(
    type: TTDeviceType,
    deviceMac: String,
    lockData: String,
    slotNumber: Int64,
    featureValue: String
  ) -> TTDeviceDFUModel {
    let model = TTDeviceDFUModel()
    model.type = type
    model.deviceMac = deviceMac
    model.lockData = lockData
    model.slotNumber = Int(slotNumber)
    model.featureValue = featureValue
    return model
  }
}
