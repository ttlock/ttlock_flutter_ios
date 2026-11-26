import Flutter
import Foundation
import TTLockSDK

public final class TtlockFlutterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
      TTLock.isPrintLog = true
    let context = EventContextStore.shared

    let lockApi = LockHostApiImpl(context: context)
    let gatewayApi = GatewayHostApiImpl(context: context)
    let accessoryApi = AccessoryHostApiImpl(context: context)

    TTLockHostApiSetup.setUp(binaryMessenger: registrar.messenger(), api: lockApi)
    TTGatewayHostApiSetup.setUp(binaryMessenger: registrar.messenger(), api: gatewayApi)
    TTAccessoryHostApiSetup.setUp(binaryMessenger: registrar.messenger(), api: accessoryApi)

    LockScanLockStreamHandler.register(
      with: registrar.messenger(), streamHandler: LockScanLockStreamHandlerImpl())
    LockScanWifiStreamHandler.register(
      with: registrar.messenger(), streamHandler: LockScanWifiStreamHandlerImpl())
    LockAddCardStreamHandler.register(
      with: registrar.messenger(), streamHandler: LockAddCardStreamHandlerImpl())
    LockAddFingerprintStreamHandler.register(
      with: registrar.messenger(), streamHandler: LockAddFingerprintStreamHandlerImpl())
    LockAddFaceStreamHandler.register(
      with: registrar.messenger(), streamHandler: LockAddFaceStreamHandlerImpl())
    LockAddPalmVeinStreamHandler.register(
      with: registrar.messenger(), streamHandler: LockAddPalmVeinStreamHandlerImpl())
    GatewayStartScanStreamHandler.register(
      with: registrar.messenger(), streamHandler: GatewayStartScanStreamHandlerImpl())
    GatewayGetNearbyWifiStreamHandler.register(
      with: registrar.messenger(), streamHandler: GatewayGetNearbyWifiStreamHandlerImpl())
    AccessoryStartScanRemoteKeyStreamHandler.register(
      with: registrar.messenger(), streamHandler: AccessoryStartScanRemoteKeyStreamHandlerImpl())
    AccessoryStartScanRemoteKeypadStreamHandler.register(
      with: registrar.messenger(), streamHandler: AccessoryStartScanRemoteKeypadStreamHandlerImpl())
    AccessoryAddKeypadFingerprintStreamHandler.register(
      with: registrar.messenger(), streamHandler: AccessoryAddKeypadFingerprintStreamHandlerImpl())
    AccessoryAddKeypadCardStreamHandler.register(
      with: registrar.messenger(), streamHandler: AccessoryAddKeypadCardStreamHandlerImpl())
    AccessoryStartScanDoorSensorStreamHandler.register(
      with: registrar.messenger(), streamHandler: AccessoryStartScanDoorSensorStreamHandlerImpl())
    AccessoryStandaloneDoorSensorStartScanStreamHandler.register(
      with: registrar.messenger(),
      streamHandler: AccessoryStandaloneDoorSensorStartScanStreamHandlerImpl())
    AccessoryWaterMeterStartScanStreamHandler.register(
      with: registrar.messenger(), streamHandler: AccessoryWaterMeterStartScanStreamHandlerImpl())
    AccessoryElectricMeterStartScanStreamHandler.register(
      with: registrar.messenger(), streamHandler: AccessoryElectricMeterStartScanStreamHandlerImpl()
    )

    let upgradeApi = UpgradeHostApiImpl(context: context)
    TTUpgradeHostApiSetup.setUp(binaryMessenger: registrar.messenger(), api: upgradeApi)
    let upgradeMessenger = registrar.messenger()
    let upgradeLock = UpgradeLockStreamHandlerImpl()
    UpgradeLockStreamHandler.register(with: upgradeMessenger, streamHandler: upgradeLock)
    attachUpgradeEventBridge(
      messenger: upgradeMessenger,
      channelName: "dev.flutter.pigeon.ttlock_flutter.TTEventChannelApi.upgradeLock",
      handler: upgradeLock)
    let upgradeGateway = UpgradeGatewayStreamHandlerImpl()
    UpgradeGatewayStreamHandler.register(with: upgradeMessenger, streamHandler: upgradeGateway)
    attachUpgradeEventBridge(
      messenger: upgradeMessenger,
      channelName: "dev.flutter.pigeon.ttlock_flutter.TTEventChannelApi.upgradeGateway",
      handler: upgradeGateway)
    let upgradeGatewayByPackage = UpgradeGatewayByPackageStreamHandlerImpl()
    UpgradeGatewayByPackageStreamHandler.register(
      with: upgradeMessenger, streamHandler: upgradeGatewayByPackage)
    attachUpgradeEventBridge(
      messenger: upgradeMessenger,
      channelName: "dev.flutter.pigeon.ttlock_flutter.TTEventChannelApi.upgradeGatewayByPackage",
      handler: upgradeGatewayByPackage)
    let upgradeWaterMeter = UpgradeWaterMeterStreamHandlerImpl()
    UpgradeWaterMeterStreamHandler.register(with: upgradeMessenger, streamHandler: upgradeWaterMeter)
    attachUpgradeEventBridge(
      messenger: upgradeMessenger,
      channelName: "dev.flutter.pigeon.ttlock_flutter.TTEventChannelApi.upgradeWaterMeter",
      handler: upgradeWaterMeter)
    let upgradeWaterMeterByPackage = UpgradeWaterMeterByPackageStreamHandlerImpl()
    UpgradeWaterMeterByPackageStreamHandler.register(
      with: upgradeMessenger, streamHandler: upgradeWaterMeterByPackage)
    attachUpgradeEventBridge(
      messenger: upgradeMessenger,
      channelName: "dev.flutter.pigeon.ttlock_flutter.TTEventChannelApi.upgradeWaterMeterByPackage",
      handler: upgradeWaterMeterByPackage)
    let upgradeElectricMeter = UpgradeElectricMeterStreamHandlerImpl()
    UpgradeElectricMeterStreamHandler.register(
      with: upgradeMessenger, streamHandler: upgradeElectricMeter)
    attachUpgradeEventBridge(
      messenger: upgradeMessenger,
      channelName: "dev.flutter.pigeon.ttlock_flutter.TTEventChannelApi.upgradeElectricMeter",
      handler: upgradeElectricMeter)
    let upgradeElectricMeterByPackage = UpgradeElectricMeterByPackageStreamHandlerImpl()
    UpgradeElectricMeterByPackageStreamHandler.register(
      with: upgradeMessenger, streamHandler: upgradeElectricMeterByPackage)
    attachUpgradeEventBridge(
      messenger: upgradeMessenger,
      channelName: "dev.flutter.pigeon.ttlock_flutter.TTEventChannelApi.upgradeElectricMeterByPackage",
      handler: upgradeElectricMeterByPackage)
    let upgradeKeypad = UpgradeKeypadStreamHandlerImpl()
    UpgradeKeypadStreamHandler.register(with: upgradeMessenger, streamHandler: upgradeKeypad)
    attachUpgradeEventBridge(
      messenger: upgradeMessenger,
      channelName: "dev.flutter.pigeon.ttlock_flutter.TTEventChannelApi.upgradeKeypad",
      handler: upgradeKeypad)
    let upgradeKeypadByPackage = UpgradeKeypadByPackageStreamHandlerImpl()
    UpgradeKeypadByPackageStreamHandler.register(
      with: upgradeMessenger, streamHandler: upgradeKeypadByPackage)
    attachUpgradeEventBridge(
      messenger: upgradeMessenger,
      channelName: "dev.flutter.pigeon.ttlock_flutter.TTEventChannelApi.upgradeKeypadByPackage",
      handler: upgradeKeypadByPackage)

    TTLock.setupBluetooth { bluetoothState in
      NSLog("bluetoothState: \(bluetoothState)")
    }
  }
}
