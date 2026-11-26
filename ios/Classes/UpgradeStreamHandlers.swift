import Foundation

private let upgradeContext = EventContextStore.shared
private let upgradeBusyMessage = "upgrade already in progress"
private let upgradeFailCode = "\(TTLockUpgradeError.upgradeFail.rawValue)"

enum UpgradeKind {
  case lock
  case gateway
  case water
  case electric
  case keypad

  var isDevice: Bool {
    switch self {
    case .water, .electric, .keypad:
      return true
    case .lock, .gateway:
      return false
    }
  }
}

/// 同一时刻只允许一路升级。结束会话的回调必须带上开始时的代际，迟到回调不能结束下一次同路会话。
final class UpgradeSession {
  static let shared = UpgradeSession()

  private let lock = NSLock()
  private var activeKind: UpgradeKind?
  private var sinks: [UpgradeKind: PigeonEventSink<TTUpgradeEvent>] = [:]
  private var generations: [UpgradeKind: Int64] = [:]

  private init() {}

  func begin(kind: UpgradeKind, sink: PigeonEventSink<TTUpgradeEvent>) -> Int64? {
    lock.lock()
    defer { lock.unlock() }
    guard activeKind == nil else { return nil }
    activeKind = kind
    let next = (generations[kind] ?? 0) + 1
    generations[kind] = next
    sinks[kind] = sink
    return next
  }

  func matches(kind: UpgradeKind, generation: Int64) -> Bool {
    lock.lock()
    defer { lock.unlock() }
    return activeKind == kind && generations[kind] == generation
  }

  func sinkIfCurrent(kind: UpgradeKind, generation: Int64) -> PigeonEventSink<TTUpgradeEvent>? {
    lock.lock()
    defer { lock.unlock() }
    guard activeKind == kind, generations[kind] == generation else { return nil }
    return sinks[kind]
  }

  func take(kind: UpgradeKind) -> PigeonEventSink<TTUpgradeEvent>? {
    lock.lock()
    defer { lock.unlock() }
    guard activeKind == kind else { return nil }
    activeKind = nil
    return sinks.removeValue(forKey: kind)
  }

  func take(kind: UpgradeKind, generation: Int64) -> PigeonEventSink<TTUpgradeEvent>? {
    lock.lock()
    defer { lock.unlock() }
    guard activeKind == kind, generations[kind] == generation else { return nil }
    activeKind = nil
    return sinks.removeValue(forKey: kind)
  }

  /// 另一台设备正在升级时忽略。锁或网关进行中时仍返回 `.stopped(nil)`，调用方只 abort 设备 DFU。
  func takeDeviceStop(kind: UpgradeKind) -> DeviceStop {
    lock.lock()
    defer { lock.unlock() }
    if let active = activeKind, active != kind, active.isDevice {
      return .ignored
    }
    guard activeKind == kind else { return .stopped(nil) }
    activeKind = nil
    return .stopped(sinks.removeValue(forKey: kind))
  }

  enum DeviceStop {
    case ignored
    case stopped(PigeonEventSink<TTUpgradeEvent>?)
  }
}

/// 本路是否真正占有会话。第二路 busy 的 onCancel 不能 take 掉第一路。
private final class UpgradeListenGate {
  let kind: UpgradeKind
  private var ownsSession = false
  private(set) var generation: Int64 = 0

  init(kind: UpgradeKind) {
    self.kind = kind
  }

  func begin<T>(
    sink: PigeonEventSink<TTUpgradeEvent>,
    param: T?,
    missingMessage: String
  ) -> T? {
    ownsSession = false
    guard let param else {
      sink.error(code: upgradeFailCode, message: missingMessage, details: nil)
      sink.endOfStream()
      return nil
    }
    guard let generation = UpgradeSession.shared.begin(kind: kind, sink: sink) else {
      sink.error(code: upgradeFailCode, message: upgradeBusyMessage, details: nil)
      sink.endOfStream()
      return nil
    }
    self.generation = generation
    ownsSession = true
    return param
  }

  /// 成功或失败已经 take 过会话时，这里不再 endUpgrade。
  func cancel(_ abort: () -> Void) {
    guard ownsSession else { return }
    ownsSession = false
    guard UpgradeSession.shared.take(kind: kind) != nil else { return }
    abort()
  }
}

private func onUpgradeMain(_ block: @escaping () -> Void) {
  if Thread.isMainThread {
    block()
  } else {
    DispatchQueue.main.async(execute: block)
  }
}

private func emitProgress(kind: UpgradeKind, generation: Int64, status: TTUpgradeStatus, progress: Int) {
  onUpgradeMain {
    guard let sink = UpgradeSession.shared.sinkIfCurrent(kind: kind, generation: generation) else {
      return
    }
    sink.success(
      TTUpgradeEvent(
        phase: .progress,
        status: status,
        progress: Int64(progress)
      ))
  }
}

private func failUpgrade(
  kind: UpgradeKind,
  generation: Int64,
  code: TTLockUpgradeError,
  message: String?
) {
  onUpgradeMain {
    guard let sink = UpgradeSession.shared.take(kind: kind, generation: generation) else { return }
    sink.error(code: "\(code.rawValue)", message: message ?? "", details: nil)
    sink.endOfStream()
  }
}

private func succeedUpgrade(kind: UpgradeKind, generation: Int64, lockData: String? = nil) {
  onUpgradeMain {
    guard let sink = UpgradeSession.shared.take(kind: kind, generation: generation) else { return }
    sink.success(TTUpgradeEvent(phase: .success, lockData: lockData))
    sink.endOfStream()
  }
}

private func upgradeCallbacks(
  kind: UpgradeKind,
  generation: Int64,
  onSuccess: @escaping () -> Void
) -> (
  onProgress: (TTUpgradeStatus, Int) -> Void,
  onSuccess: () -> Void,
  onError: (TTLockUpgradeError, String?) -> Void
) {
  (
    onProgress: { status, progress in
      emitProgress(kind: kind, generation: generation, status: status, progress: progress)
    },
    onSuccess: onSuccess,
    onError: { code, message in
      failUpgrade(kind: kind, generation: generation, code: code, message: message)
    }
  )
}

final class UpgradeLockStreamHandlerImpl: UpgradeLockStreamHandler {
  private let gate = UpgradeListenGate(kind: .lock)

  override func onListen(withArguments arguments: Any?, sink: PigeonEventSink<TTUpgradeEvent>) {
    guard
      let param = gate.begin(
        sink: sink,
        param: upgradeContext.upgradeLock,
        missingMessage: "请先通过 setUpgradeLockParam 设置参数后再订阅 upgradeLock"
      )
    else { return }
    let generation = gate.generation
    let callbacks = upgradeCallbacks(kind: .lock, generation: generation) {
      onUpgradeMain {
        guard UpgradeSession.shared.matches(kind: .lock, generation: generation) else { return }
        UpgradeDfuFacade.refreshLockSystemInfo(
          lockData: param.lockData,
          onSuccess: { refreshed in
            succeedUpgrade(kind: .lock, generation: generation, lockData: refreshed)
          },
          onError: { message in
            failUpgrade(
              kind: .lock,
              generation: generation,
              code: .getSpecialValueError,
              message: message
            )
          }
        )
      }
    }
    UpgradeDfuFacade.startLock(
      firmwarePackage: param.firmwarePackage,
      lockData: param.lockData,
      onProgress: callbacks.onProgress,
      onSuccess: callbacks.onSuccess,
      onError: callbacks.onError
    )
  }

  override func onCancel(withArguments arguments: Any?) {
    gate.cancel { UpgradeDfuFacade.stopLock() }
  }
}

final class UpgradeGatewayStreamHandlerImpl: UpgradeGatewayStreamHandler {
  private let gate = UpgradeListenGate(kind: .gateway)

  override func onListen(withArguments arguments: Any?, sink: PigeonEventSink<TTUpgradeEvent>) {
    guard
      let param = gate.begin(
        sink: sink,
        param: upgradeContext.upgradeGateway,
        missingMessage: "请先通过 setUpgradeGatewayParam 设置参数后再订阅 upgradeGateway"
      )
    else { return }
    let generation = gate.generation
    let callbacks = upgradeCallbacks(kind: .gateway, generation: generation) {
      succeedUpgrade(kind: .gateway, generation: generation)
    }
    UpgradeDfuFacade.startGatewayNet(
      dfuType: param.dfuType,
      clientId: param.clientId,
      accessToken: param.accessToken,
      gatewayId: param.gatewayId,
      gatewayMac: param.gatewayMac,
      onProgress: callbacks.onProgress,
      onSuccess: callbacks.onSuccess,
      onError: callbacks.onError
    )
  }

  override func onCancel(withArguments arguments: Any?) {
    gate.cancel { UpgradeDfuFacade.stopGateway() }
  }
}

final class UpgradeGatewayByPackageStreamHandlerImpl: UpgradeGatewayByPackageStreamHandler {
  private let gate = UpgradeListenGate(kind: .gateway)

  override func onListen(withArguments arguments: Any?, sink: PigeonEventSink<TTUpgradeEvent>) {
    guard
      let param = gate.begin(
        sink: sink,
        param: upgradeContext.upgradeGatewayByPackage,
        missingMessage: "请先通过 setUpgradeGatewayByPackageParam 设置参数后再订阅 upgradeGatewayByPackage"
      )
    else { return }
    let generation = gate.generation
    let callbacks = upgradeCallbacks(kind: .gateway, generation: generation) {
      succeedUpgrade(kind: .gateway, generation: generation)
    }
    UpgradeDfuFacade.startGatewayPackage(
      firmwarePackage: param.firmwarePackage,
      gatewayMac: param.gatewayMac,
      onProgress: callbacks.onProgress,
      onSuccess: callbacks.onSuccess,
      onError: callbacks.onError
    )
  }

  override func onCancel(withArguments arguments: Any?) {
    gate.cancel { UpgradeDfuFacade.stopGateway() }
  }
}

final class UpgradeWaterMeterStreamHandlerImpl: UpgradeWaterMeterStreamHandler {
  private let gate = UpgradeListenGate(kind: .water)

  override func onListen(withArguments arguments: Any?, sink: PigeonEventSink<TTUpgradeEvent>) {
    guard
      let param = gate.begin(
        sink: sink,
        param: upgradeContext.upgradeWaterMeter,
        missingMessage: "请先通过 setUpgradeWaterMeterParam 设置参数后再订阅 upgradeWaterMeter"
      )
    else { return }
    startMeterNetwork(
      kind: .water,
      generation: gate.generation,
      type: .waterMeter,
      clientId: param.clientId,
      accessToken: param.accessToken,
      deviceId: param.deviceId,
      deviceMac: param.deviceMac
    )
  }

  override func onCancel(withArguments arguments: Any?) {
    gate.cancel { UpgradeDfuFacade.stopDevice() }
  }
}

final class UpgradeWaterMeterByPackageStreamHandlerImpl: UpgradeWaterMeterByPackageStreamHandler {
  private let gate = UpgradeListenGate(kind: .water)

  override func onListen(withArguments arguments: Any?, sink: PigeonEventSink<TTUpgradeEvent>) {
    guard
      let param = gate.begin(
        sink: sink,
        param: upgradeContext.upgradeWaterMeterByPackage,
        missingMessage: "请先通过 setUpgradeWaterMeterByPackageParam 设置参数后再订阅 upgradeWaterMeterByPackage"
      )
    else { return }
    startMeterPackage(
      kind: .water,
      generation: gate.generation,
      type: .waterMeter,
      deviceId: param.deviceId,
      deviceMac: param.deviceMac,
      firmwarePackage: param.firmwarePackage
    )
  }

  override func onCancel(withArguments arguments: Any?) {
    gate.cancel { UpgradeDfuFacade.stopDevice() }
  }
}

final class UpgradeElectricMeterStreamHandlerImpl: UpgradeElectricMeterStreamHandler {
  private let gate = UpgradeListenGate(kind: .electric)

  override func onListen(withArguments arguments: Any?, sink: PigeonEventSink<TTUpgradeEvent>) {
    guard
      let param = gate.begin(
        sink: sink,
        param: upgradeContext.upgradeElectricMeter,
        missingMessage: "请先通过 setUpgradeElectricMeterParam 设置参数后再订阅 upgradeElectricMeter"
      )
    else { return }
    startMeterNetwork(
      kind: .electric,
      generation: gate.generation,
      type: .electricMeter,
      clientId: param.clientId,
      accessToken: param.accessToken,
      deviceId: param.deviceId,
      deviceMac: param.deviceMac
    )
  }

  override func onCancel(withArguments arguments: Any?) {
    gate.cancel { UpgradeDfuFacade.stopDevice() }
  }
}

final class UpgradeElectricMeterByPackageStreamHandlerImpl: UpgradeElectricMeterByPackageStreamHandler {
  private let gate = UpgradeListenGate(kind: .electric)

  override func onListen(withArguments arguments: Any?, sink: PigeonEventSink<TTUpgradeEvent>) {
    guard
      let param = gate.begin(
        sink: sink,
        param: upgradeContext.upgradeElectricMeterByPackage,
        missingMessage:
          "请先通过 setUpgradeElectricMeterByPackageParam 设置参数后再订阅 upgradeElectricMeterByPackage"
      )
    else { return }
    startMeterPackage(
      kind: .electric,
      generation: gate.generation,
      type: .electricMeter,
      deviceId: param.deviceId,
      deviceMac: param.deviceMac,
      firmwarePackage: param.firmwarePackage
    )
  }

  override func onCancel(withArguments arguments: Any?) {
    gate.cancel { UpgradeDfuFacade.stopDevice() }
  }
}

final class UpgradeKeypadStreamHandlerImpl: UpgradeKeypadStreamHandler {
  private let gate = UpgradeListenGate(kind: .keypad)

  override func onListen(withArguments arguments: Any?, sink: PigeonEventSink<TTUpgradeEvent>) {
    guard
      let param = gate.begin(
        sink: sink,
        param: upgradeContext.upgradeKeypad,
        missingMessage: "请先通过 setUpgradeKeypadParam 设置参数后再订阅 upgradeKeypad"
      )
    else { return }
    let generation = gate.generation
    let callbacks = upgradeCallbacks(kind: .keypad, generation: generation) {
      succeedUpgrade(kind: .keypad, generation: generation)
    }
    UpgradeDfuFacade.startDevice(
      type: .keypad,
      deviceId: param.deviceId,
      deviceMac: param.deviceMac,
      lockData: param.lockData ?? "",
      slotNumber: param.slotNumber ?? 0,
      featureValue: param.featureValue ?? "",
      mode: .network(clientId: param.clientId, accessToken: param.accessToken),
      onProgress: callbacks.onProgress,
      onSuccess: callbacks.onSuccess,
      onError: callbacks.onError
    )
  }

  override func onCancel(withArguments arguments: Any?) {
    gate.cancel { UpgradeDfuFacade.stopDevice() }
  }
}

final class UpgradeKeypadByPackageStreamHandlerImpl: UpgradeKeypadByPackageStreamHandler {
  private let gate = UpgradeListenGate(kind: .keypad)

  override func onListen(withArguments arguments: Any?, sink: PigeonEventSink<TTUpgradeEvent>) {
    guard
      let param = gate.begin(
        sink: sink,
        param: upgradeContext.upgradeKeypadByPackage,
        missingMessage: "请先通过 setUpgradeKeypadByPackageParam 设置参数后再订阅 upgradeKeypadByPackage"
      )
    else { return }
    let generation = gate.generation
    let callbacks = upgradeCallbacks(kind: .keypad, generation: generation) {
      succeedUpgrade(kind: .keypad, generation: generation)
    }
    UpgradeDfuFacade.startDevice(
      type: .keypad,
      deviceId: param.deviceId,
      deviceMac: param.deviceMac,
      lockData: param.lockData ?? "",
      slotNumber: param.slotNumber ?? 0,
      featureValue: param.featureValue ?? "",
      mode: .package(firmwarePackage: param.firmwarePackage),
      onProgress: callbacks.onProgress,
      onSuccess: callbacks.onSuccess,
      onError: callbacks.onError
    )
  }

  override func onCancel(withArguments arguments: Any?) {
    gate.cancel { UpgradeDfuFacade.stopDevice() }
  }
}

private func startMeterNetwork(
  kind: UpgradeKind,
  generation: Int64,
  type: UpgradeHardware,
  clientId: String,
  accessToken: String,
  deviceId: Int64,
  deviceMac: String
) {
  let callbacks = upgradeCallbacks(kind: kind, generation: generation) {
    succeedUpgrade(kind: kind, generation: generation)
  }
  UpgradeDfuFacade.startDevice(
    type: type,
    deviceId: deviceId,
    deviceMac: deviceMac,
    lockData: "",
    slotNumber: 0,
    featureValue: "",
    mode: .network(clientId: clientId, accessToken: accessToken),
    onProgress: callbacks.onProgress,
    onSuccess: callbacks.onSuccess,
    onError: callbacks.onError
  )
}

private func startMeterPackage(
  kind: UpgradeKind,
  generation: Int64,
  type: UpgradeHardware,
  deviceId: Int64,
  deviceMac: String,
  firmwarePackage: String
) {
  let callbacks = upgradeCallbacks(kind: kind, generation: generation) {
    succeedUpgrade(kind: kind, generation: generation)
  }
  UpgradeDfuFacade.startDevice(
    type: type,
    deviceId: deviceId,
    deviceMac: deviceMac,
    lockData: "",
    slotNumber: 0,
    featureValue: "",
    mode: .package(firmwarePackage: firmwarePackage),
    onProgress: callbacks.onProgress,
    onSuccess: callbacks.onSuccess,
    onError: callbacks.onError
  )
}
