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
}

/// 替换 listen 的同步 onCancel 期间 > 0。这次取消只换 sink，不能拆掉已占有的会话。
private var upgradeRelistenDepth = 0

/// 同一个 EventChannel handler 上的多次 listen 共用这扇门。
///
/// 忙拒绝和缺参不能清掉已经占有的会话。每张 listen 一张票据：占有的记下代际，否则为 nil。
/// 真正的 cancel 先核销 nil 票据，所以第二路自己的 onCancel 不会 abort 第一路。
/// 只有核销到当前代际时才 take 并 abort。
private final class UpgradeListenGate {
  let kind: UpgradeKind
  private var ownsSession = false
  private(set) var generation: Int64 = 0
  private var tickets: [Int64?] = []
  private var nextCancelId: Int64 = 0
  private var queuedCancels: [Int64] = []

  init(kind: UpgradeKind) {
    self.kind = kind
  }

  func begin<T>(
    sink: PigeonEventSink<TTUpgradeEvent>,
    param: T?,
    missingMessage: String
  ) -> T? {
    if upgradeRelistenDepth > 0, !queuedCancels.isEmpty {
      queuedCancels.removeLast()
    }
    guard let param else {
      sink.error(code: upgradeFailCode, message: missingMessage, details: nil)
      sink.endOfStream()
      tickets.append(nil)
      return nil
    }
    guard let started = UpgradeSession.shared.begin(kind: kind, sink: sink) else {
      sink.error(code: upgradeFailCode, message: upgradeBusyMessage, details: nil)
      sink.endOfStream()
      tickets.append(nil)
      return nil
    }
    generation = started
    ownsSession = true
    tickets.append(started)
    return param
  }

  /// 成功或失败已经 take 过会话时，这里不再 abort。
  func cancel(_ abort: @escaping () -> Void) {
    nextCancelId += 1
    let id = nextCancelId
    queuedCancels.append(id)
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      guard let index = self.queuedCancels.firstIndex(of: id) else { return }
      self.queuedCancels.remove(at: index)
      self.releaseOne(abort)
    }
  }

  private func releaseOne(_ abort: () -> Void) {
    if let index = tickets.firstIndex(where: { $0 == nil }) {
      tickets.remove(at: index)
      return
    }
    guard ownsSession, !tickets.isEmpty else { return }
    let token = tickets.removeFirst()
    guard let token, token == generation else { return }
    ownsSession = false
    guard UpgradeSession.shared.take(kind: kind, generation: token) != nil else { return }
    abort()
  }
}

private final class UpgradeSinkBox {
  var ended = false
}

private final class UpgradeChannelBridge {
  let messenger: FlutterBinaryMessenger
  let channelName: String
  let handler: PigeonEventChannelWrapper<TTUpgradeEvent>
  private var active: UpgradeSinkBox?

  init(
    messenger: FlutterBinaryMessenger,
    channelName: String,
    handler: PigeonEventChannelWrapper<TTUpgradeEvent>
  ) {
    self.messenger = messenger
    self.channelName = channelName
    self.handler = handler
  }

  func install() {
    messenger.setMessageHandlerOnChannel(channelName, binaryMessageHandler: { [self] message, reply in
      guard let message else {
        reply(nil)
        return
      }
      let call = messagesPigeonMethodCodec.decodeMethodCall(message)
      if call.method == "listen" {
        let box = UpgradeSinkBox()
        let replacing = self.active != nil
        self.active = box
        let events: FlutterEventSink = { event in
          guard !box.ended, self.active === box else { return }
          if (event as AnyObject?) === (FlutterEndOfEventStream as AnyObject) {
            box.ended = true
            self.messenger.send(onChannel: self.channelName, message: nil)
          } else if let error = event as? FlutterError {
            self.messenger.send(
              onChannel: self.channelName,
              message: messagesPigeonMethodCodec.encodeErrorEnvelope(error))
          } else {
            self.messenger.send(
              onChannel: self.channelName,
              message: messagesPigeonMethodCodec.encodeSuccessEnvelope(event))
          }
        }
        let sink = PigeonEventSink<TTUpgradeEvent>(events)
        upgradeRelistenDepth += 1
        if replacing {
          handler.onCancel(withArguments: nil)
        }
        handler.onListen(withArguments: call.arguments, sink: sink)
        upgradeRelistenDepth -= 1
        reply(messagesPigeonMethodCodec.encodeSuccessEnvelope(nil))
      } else if call.method == "cancel" {
        self.active = nil
        handler.onCancel(withArguments: call.arguments)
        reply(messagesPigeonMethodCodec.encodeSuccessEnvelope(nil))
      } else {
        reply(nil)
      }
    }
  }
}

private var upgradeChannelBridges: [UpgradeChannelBridge] = []

func attachUpgradeEventBridge(
  messenger: FlutterBinaryMessenger,
  channelName: String,
  handler: PigeonEventChannelWrapper<TTUpgradeEvent>
) {
  let bridge = UpgradeChannelBridge(
    messenger: messenger, channelName: channelName, handler: handler)
  upgradeChannelBridges.append(bridge)
  bridge.install()
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

private func rejectNotImplemented(sink: PigeonEventSink<TTUpgradeEvent>, operation: String) {
  let error = makeUpgradeNotImplementedError(operation)
  sink.error(code: error.code, message: error.message, details: error.details)
  sink.endOfStream()
}

final class UpgradeLockStreamHandlerImpl: UpgradeLockStreamHandler {
  override func onListen(withArguments arguments: Any?, sink: PigeonEventSink<TTUpgradeEvent>) {
    rejectNotImplemented(sink: sink, operation: "upgradeLock")
  }

  override func onCancel(withArguments arguments: Any?) {}
}

final class UpgradeLockByPackageStreamHandlerImpl: UpgradeLockByPackageStreamHandler {
  private let gate = UpgradeListenGate(kind: .lock)

  override func onListen(withArguments arguments: Any?, sink: PigeonEventSink<TTUpgradeEvent>) {
    guard
      let param = gate.begin(
        sink: sink,
        param: upgradeContext.upgradeLockByPackage,
        missingMessage: "请先通过 setUpgradeLockByPackageParam 设置参数后再订阅 upgradeLockByPackage"
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
  override func onListen(withArguments arguments: Any?, sink: PigeonEventSink<TTUpgradeEvent>) {
    rejectNotImplemented(sink: sink, operation: "upgradeGateway")
  }

  override func onCancel(withArguments arguments: Any?) {}
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
  override func onListen(withArguments arguments: Any?, sink: PigeonEventSink<TTUpgradeEvent>) {
    rejectNotImplemented(sink: sink, operation: "upgradeWaterMeter")
  }

  override func onCancel(withArguments arguments: Any?) {}
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
    let generation = gate.generation
    let callbacks = upgradeCallbacks(kind: .water, generation: generation) {
      succeedUpgrade(kind: .water, generation: generation)
    }
    UpgradeDfuFacade.startDevice(
      type: .waterMeter,
      deviceMac: param.deviceMac,
      lockData: "",
      slotNumber: 0,
      featureValue: "",
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

final class UpgradeElectricMeterStreamHandlerImpl: UpgradeElectricMeterStreamHandler {
  override func onListen(withArguments arguments: Any?, sink: PigeonEventSink<TTUpgradeEvent>) {
    rejectNotImplemented(sink: sink, operation: "upgradeElectricMeter")
  }

  override func onCancel(withArguments arguments: Any?) {}
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
    let generation = gate.generation
    let callbacks = upgradeCallbacks(kind: .electric, generation: generation) {
      succeedUpgrade(kind: .electric, generation: generation)
    }
    UpgradeDfuFacade.startDevice(
      type: .electricMeter,
      deviceMac: param.deviceMac,
      lockData: "",
      slotNumber: 0,
      featureValue: "",
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

final class UpgradeKeypadStreamHandlerImpl: UpgradeKeypadStreamHandler {
  override func onListen(withArguments arguments: Any?, sink: PigeonEventSink<TTUpgradeEvent>) {
    rejectNotImplemented(sink: sink, operation: "upgradeKeypad")
  }

  override func onCancel(withArguments arguments: Any?) {}
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
