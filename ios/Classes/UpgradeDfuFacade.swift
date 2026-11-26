import Foundation
import TTLockDFUSDK
import TTLockSDK

/// 设备 DFU 的启动方式。类型由调用方写死，不从外部传入 `deviceType`。
enum UpgradeDeviceMode {
  case network(clientId: String, accessToken: String)
  case package(firmwarePackage: String)
}

/// 本轮要升级的设备。不包含人体存在传感器。
enum UpgradeHardware {
  case waterMeter
  case electricMeter
  case keypad
}

/// main 的 DFU 入口。模块别名是 `TTLockDFUSDK`，类名仍是 `TTLockDFU` / `TTGatewayDFU` / `TTDeviceDFU`。
enum UpgradeDfuFacade {
  static func startLockNet(
    clientId: String,
    accessToken: String,
    lockId: Int64,
    lockData: String,
    onProgress: @escaping (TTUpgradeStatus, Int) -> Void,
    onSuccess: @escaping () -> Void,
    onError: @escaping (TTLockUpgradeError, String?) -> Void
  ) {
    TTLockDFU.shareInstance().start(
      withClientId: clientId,
      accessToken: accessToken,
      lockId: NSNumber(value: lockId),
      lockData: lockData,
      successBlock: { operation, progress in
        handleOperation(operation, progress: progress, onProgress: onProgress, onSuccess: onSuccess)
      },
      fail: { _, code in
        handleFailure(code, onError: onError)
      }
    )
  }

  static func startLock(
    firmwarePackage: String,
    lockData: String,
    onProgress: @escaping (TTUpgradeStatus, Int) -> Void,
    onSuccess: @escaping () -> Void,
    onError: @escaping (TTLockUpgradeError, String?) -> Void
  ) {
    TTLockDFU.shareInstance().start(
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
    TTLockDFU.shareInstance().endUpgrade()
  }

  /// iOS 没有独立的 cache 重试 API。每次订阅都带 `dfuType` 调 `startDfuWithType`。
  static func startGatewayNet(
    dfuType: TTDfuType,
    clientId: String,
    accessToken: String,
    gatewayId: Int64,
    gatewayMac: String,
    onProgress: @escaping (TTUpgradeStatus, Int) -> Void,
    onSuccess: @escaping () -> Void,
    onError: @escaping (TTLockUpgradeError, String?) -> Void
  ) {
    TTGatewayDFU.shareInstance().start(
      with: gatewayDfuType(dfuType),
      clientId: clientId,
      accessToken: accessToken,
      gatewayId: NSNumber(value: gatewayId),
      gatewayMac: gatewayMac,
      successBlock: { operation, progress in
        handleOperation(operation, progress: progress, onProgress: onProgress, onSuccess: onSuccess)
      },
      fail: { _, code in
        handleFailure(code, onError: onError)
      }
    )
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

  static func startDevice(
    type: UpgradeHardware,
    deviceId: Int64,
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
      deviceId: deviceId,
      deviceMac: deviceMac,
      lockData: lockData,
      slotNumber: slotNumber,
      featureValue: featureValue
    )
    switch mode {
    case .network(let clientId, let accessToken):
      TTDeviceDFU.shareInstance().start(
        withClientId: clientId,
        accessToken: accessToken,
        deviceModel: model,
        successBlock: { operation, progress in
          handleOperation(operation, progress: progress, onProgress: onProgress, onSuccess: onSuccess)
        },
        fail: { _, code in
          handleFailure(code, onError: onError)
        }
      )
    case .package(let firmwarePackage):
      TTDeviceDFU.shareInstance().start(
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
    TTDeviceDFU.shareInstance().endUpgrade()
  }

  /// 锁升级成功后刷新 lockData。失败交给调用方映射为 `getSpecialValueError`，这里不吞。
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

  private static func gatewayDfuType(_ type: TTDfuType) -> TTGatewayDFUType {
    switch type {
    case .net:
      return .byNet
    case .bluetooth:
      return .byBluetooth
    }
  }

  private static func deviceModel(
    type: TTDeviceType,
    deviceId: Int64,
    deviceMac: String,
    lockData: String,
    slotNumber: Int64,
    featureValue: String
  ) -> TTDeviceDFUModel {
    let model = TTDeviceDFUModel()
    model.type = type
    model.deviceId = Int(deviceId)
    model.deviceMac = deviceMac
    model.lockData = lockData
    model.slotNumber = Int(slotNumber)
    model.featureValue = featureValue
    return model
  }
}
