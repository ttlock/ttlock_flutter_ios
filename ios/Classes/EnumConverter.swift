import Foundation
import TTLockSDK

func lockConfigConvert(_ config: TTLockConfig) -> TTLockConfigType {
  switch config {
  case .audio:
    return TTLockConfigType.lockSound
  case .passcodeVisible:
    return TTLockConfigType.passcodeVisible
  case .freeze:
    return TTLockConfigType.lockFreeze
  case .tamperAlert:
    return TTLockConfigType.tamperAlert
  case .resetButton:
    return TTLockConfigType.resetButton
  case .privacyLock:
    return TTLockConfigType.privacyLock
  case .passageModeAutoUnlock:
    return TTLockConfigType.passageModeAutoUnlock
  case .wifiLockPowerSavingMode:
    return TTLockConfigType.wifiPowerSavingMode
  case .doubleAuth:
    return TTLockConfigType.doubleAuth
  case .publicMode:
    return TTLockConfigType.publicMode
  case .lowBatteryAutoUnlock:
    return TTLockConfigType.lowBatteryAutoUnlock
  case .securityM1Card:
    return TTLockConfigType.securityM1Card
  case .semiAutomaticModeControl:
    return TTLockConfigType.semiAutomaticModeControl
  case .lockSupervision:
    return TTLockConfigType.proofCapture
  }
}

func liftWorkActivateTypeConvert(_ type: TTLiftWorkActivateType) -> TTLiftWorkMode {
  switch type {
  case .allFloors:
    return TTLiftWorkMode.activateAllFloors
  case .specificFloors:
    return TTLiftWorkMode.modeActivateSpecificFloors
  }
}

func powerSaverWorkModeConvert(_ type: TTPowerSaverWorkType) -> TTPowerSaverWorkMode {
  switch type {
  case .allCards:
    return TTPowerSaverWorkMode.allCards
  case .hotelCard:
    return TTPowerSaverWorkMode.hotelCard
  case .roomCard:
    return TTPowerSaverWorkMode.roomCard
  }
}

func passageModeTypeConvert(_ type: TTPassageModeType) -> TTLockSDK.TTPassageModeType {
  switch type {
  case .weekly:
    return .weekly
  case .monthly:
    return .monthly
  }
}

func passageModeTypeRevert(_ type: TTLockSDK.TTPassageModeType) -> TTPassageModeType {
  switch type {
  case .weekly:
    return .weekly
  case .monthly:
    return .monthly
  @unknown default:
      return .weekly
  }
}

func soundVolumeConvert(_ type: TTSoundVolumeType) -> TTSoundVolume {
  switch type {
  case .firstLevel:
    return TTSoundVolume.firstLevel
  case .secondLevel:
    return TTSoundVolume.secondLevel
  case .thirdLevel:
    return TTSoundVolume.thirdLevel
  case .fourthLevel:
    return TTSoundVolume.fourthLevel
  case .fifthLevel:
    return TTSoundVolume.fifthLevel
  case .off:
    return TTSoundVolume.off
  case .on:
    return TTSoundVolume.on
  }
}

func controlActionConvert(_ action: TTControlAction) -> TTLockSDK.TTControlAction {
  switch action {
  case .unlock:
    return .actionUnlock
  case .lock:
    return .actionLock
  }
}

func lockSwitchStateRevert(_ state: TTLockSDK.TTLockSwitchState) -> TTLockSwitchState {
  switch state {
  case .lock:
    return .lock
  case .unlock:
    return .unlock
  default:
    return .unknow
  }
}

func soundVolumeRevert(_ type: TTSoundVolume) -> TTSoundVolumeType {
  switch type {
  case .firstLevel:
    return .firstLevel
  case .secondLevel:
    return .secondLevel
  case .thirdLevel:
    return .thirdLevel
  case .fourthLevel:
    return .fourthLevel
  case .fifthLevel:
    return .fifthLevel
  case .off:
    return .off
  case .on:
    return .on
  default:
    return .off
  }
}

func keyboardPwdTypeConvert(_ type: TTPasscodeType) -> TTLockSDK.TTPasscodeType {
  switch type {
  case .permanent:
    return .permanent
  case .once:
    return .once
  case .period:
    return .period
  case .cycle:
    return .cycle
  }
}

func operateLogTypeConvert(_ type: TTOperateRecordType) -> TTLockSDK.TTOperateLogType {
  switch type {
  case .latest:
    return .latest
  case .total:
    return .all
  }
}

func lockDirectionConvert(_ direction: TTLockDirection) -> TTLockSDK.TTUnlockDirection {
  switch direction {
  case .left:
    return .left
  case .right:
    return .right
  }
}

func lockDirectionRevert(_ direction: TTLockSDK.TTUnlockDirection) -> TTLockDirection {
  switch direction {
  case .left:
    return .left
  case .right:
    return .right
  @unknown default:
    return .right
  }
}

func sensitivityValueConvert(_ value: TTSensitivityValue) -> TTLockSDK.TTSensitivityValue {
  switch value {
  case .off:
    return .off
  case .low:
    return .low
  case .medium:
    return .medium
  case .high:
    return .high
  }
}

func sensitivityValueRevert(_ value: TTLockSDK.TTSensitivityValue) -> TTSensitivityValue {
  switch value {
  case .off:
    return .off
  case .low:
    return .low
  case .medium:
    return .medium
  case .high:
    return .high
  @unknown default:
    return .off
  }
}

func remoteAccessoryConvert(_ accessory: TTRemoteAccessory) -> TTLockSDK.TTAccessoryType {
  switch accessory {
  case .remoteKey:
    return .wirelessKeyFob
  case .remoteKeypad:
    return .wirelessKeypad
  case .doorSensor:
    return .doorSensor
  }
}

func featureValueConvert(_ lockFunction: TTLockFunction) -> TTLockFeatureValue? {
  switch lockFunction {
  case .passcode:
    // id: 0
    return TTLockFeatureValue.passcode
  case .icCard:
    // id: 1
    return TTLockFeatureValue.icCard
  case .fingerprint:
    // id: 2
    return TTLockFeatureValue.fingerprint
  case .wristband:
    // id: 3
    return TTLockFeatureValue.wristband
  case .autoLock:
    // id: 4
    return TTLockFeatureValue.autoLock
  case .deletePasscode:
    // id: 5
    return TTLockFeatureValue.deletePasscode
  case .firmwareSetting:
    // id: 6
    return nil
  case .managePasscode:
    // id: 7
    return TTLockFeatureValue.managePasscode
  case .locking:
    // id: 8
    return TTLockFeatureValue.locking
  case .passcodeVisible:
    // id: 9
    return TTLockFeatureValue.passcodeVisible
  case .gatewayUnlock:
    // id: 10
    return TTLockFeatureValue.gatewayUnlock
  case .lockFreeze:
    // id: 11
    return TTLockFeatureValue.lockFreeze
  case .cyclePassword:
    // id: 12
    return TTLockFeatureValue.cyclePassword
  case .magnetometer:
    // id: 13
    return nil
  case .unlockSwitch:
    // id: 14
    return TTLockFeatureValue.remoteUnlockSwicth
  case .audioSwitch:
    // id: 15
    return TTLockFeatureValue.audioSwitch
  case .nbIoT:
    // id: 16
    return TTLockFeatureValue.nbIoT
  case .getAdminPasscode:
    // id: 18
    return TTLockFeatureValue.getAdminPasscode
  case .hotelCard:
    // id: 19
    return TTLockFeatureValue.hotelCard
  case .noClock:
    // id: 20
    return TTLockFeatureValue.noClock
  case .noBroadcastInNormal:
    // id: 21
    return TTLockFeatureValue.noBroadcastInNormal
  case .passageMode:
    // id: 22
    return TTLockFeatureValue.passageMode
  case .turnOffAutoLock:
    // id: 23
    return TTLockFeatureValue.turnOffAutoLock
  case .wirelessKeypad:
    // id: 24
    return TTLockFeatureValue.wirelessKeypad
  case .light:
    // id: 25
    return TTLockFeatureValue.light
  case .hotelCardBlacklist:
    // id: 26
    return TTLockFeatureValue.hotelCardBlacklist
  case .identityCard:
    // id: 27
    return TTLockFeatureValue.identityCard
  case .tamperAlert:
    // id: 28
    return TTLockFeatureValue.tamperAlert
  case .resetButton:
    // id: 29
    return TTLockFeatureValue.resetButton
  case .privacyLock:
    // id: 30
    return TTLockFeatureValue.privacyLock
  case .deadLock:
    // id: 32
    return TTLockFeatureValue.deadLock
  case .cyclicCardOrFingerprint:
    // id: 34
    return TTLockFeatureValue.cyclicCardOrFingerprint
  case .unlockDirection:
    // id: 36
    return TTLockFeatureValue.unlockDirection
  case .fingerVein:
    // id: 37
    return TTLockFeatureValue.fingerVein
  case .ble5G:
    // id: 38
    return TTLockFeatureValue.ble5G
  case .nbAwake:
    // id: 39
    return TTLockFeatureValue.nbAwake
  case .recoverCyclePasscode:
    // id: 40
    return TTLockFeatureValue.recoverCyclePasscode
  case .remoteKey:
    // id: 41
    return TTLockFeatureValue.wirelessKeyFob
  case .getAccessoryElectricQuantity:
    // id: 42
    return TTLockFeatureValue.getAccessoryElectricQuantity
  case .soundVolumeAndLanguageSetting:
    // id: 43
    return TTLockFeatureValue.soundVolume
  case .qrCode:
    // id: 44
    return TTLockFeatureValue.qrCode
  case .doorSensorState:
    // id: 45
    return TTLockFeatureValue.sensorState
  case .passageModeAutoUnlockSetting:
    // id: 46
    return TTLockFeatureValue.passageModeAutoUnlock
  case .fingerprintDistribution:
    // id: 47
    return nil
  case .zhongZheng:
    // id: 48
    return nil
  case .syno:
    // id: 49
    return nil
  case .doorSensor:
    // id: 50
    return TTLockFeatureValue.doorSensor
  case .doorSensorAlert:
    // id: 51
    return TTLockFeatureValue.doorSensorAlert
  case .sensitivity:
    // id: 52
    return TTLockFeatureValue.sensitivity
  case .face:
    // id: 53
    return TTLockFeatureValue.face
  case .motorTorque:
    // id: 54
    return TTLockFeatureValue.motorTorque
  case .cpuCard:
    // id: 55
    return TTLockFeatureValue.cpuCard
  case .wifiLock:
    // id: 56
    return TTLockFeatureValue.wifiLock
  case .wifiLockStaticIP:
    // id: 58
    return TTLockFeatureValue.wifiLockStaticIP
  case .passcodeKeyNumber:
    // id: 60
    return TTLockFeatureValue.passcodeKeyNumber
  case .meariCamera:
    // id: 61
    return nil
  case .standAloneActivation:
    // id: 62
    return TTLockFeatureValue.standAloneActivation
  case .doubleAuth:
    // id: 63
    return TTLockFeatureValue.doubleAuth
  case .authorizedUnlock:
    // id: 64
    return TTLockFeatureValue.authorizedUnlock
  case .gatewayAuthorizedUnlock:
    // id: 65
    return TTLockFeatureValue.gatewayAuthorizedUnlock
  case .noEkeyUnlock:
    // id: 66
    return TTLockFeatureValue.noEkeyUnlock
  case .xiongMaiCamera:
    // id: 67
    return nil
  case .onMicroChip:
    // id: 68
    return nil
  case .zhiAnPhotoFace:
    // id: 69
    return TTLockFeatureValue.zhiAnPhotoFace
  case .palmVein:
    // id: 70
    return TTLockFeatureValue.palmVein
  case .wifiArea:
    // id: 71
    return TTLockFeatureValue.wifiArea
  case .xiaoCaoCamera:
    // id: 75
    return TTLockFeatureValue.xiaoCaoCamera
  case .resetLockByCode:
    // id: 76
    return TTLockFeatureValue.resetLockByCode
  case .thirdPartyBluetoothDevice:
    // id: 77
    return TTLockFeatureValue.thirdDevice
  case .autoSetAngle:
    // id: 78
    return TTLockFeatureValue.autoSetAngle
  case .manualSetAngle:
    // id: 79
    return TTLockFeatureValue.manualSetAngle
  case .controlLatchBolt:
    // id: 80
    return TTLockFeatureValue.controlLatchBolt
  case .autoSetUnlockDirection:
    // id: 81
    return TTLockFeatureValue.autoSetUnlockDirection
  case .icCardSecuritySetting:
    // id: 82
    return nil
  case .wifiPowerSavingTime:
    // id: 83
    return TTLockFeatureValue.wifiPowerSavingTime
  case .multiFunctionKeypad:
    // id: 84
    return TTLockFeatureValue.multifunctionalKeypad
  case .doNotSupportTurnOffLatchBolt:
    // id: 85
    return TTLockFeatureValue.fullyAutomatic
  case .publicMode:
    // id: 86
    return TTLockFeatureValue.publicMode
  case .lowBatteryAutoUnlock:
    // id: 87
    return TTLockFeatureValue.lowBatteryAutoUnlock
  case .motorDriveTime:
    // id: 88
    return TTLockFeatureValue.motorDriveTime
  case .modifyFeatureValue:
    // id: 89
    return TTLockFeatureValue.modifyFeatureValue
  case .modifyLockNamePrefix:
    // id: 90
    return TTLockFeatureValue.modifyLockNamePrefix
  case .passcodeWithOpenPrivacyLock:
    // id: 91
    return TTLockFeatureValue.passcodeWithOpenPrivacyLock
  case .authCode:
    // id: 92
    return TTLockFeatureValue.authCode
  case .unauthorizedAttemptAlarm:
    // id: 93
    return TTLockFeatureValue.unauthorizedAttemptAlert
  case .linkLock:
    // id: 94
    return TTLockFeatureValue.linkLock
  case .clearPasscodeAndDynamicPasscodeSetting:
    // id: 95
    return nil
  case .powerSaverSupportWifi:
    // id: 96
    return TTLockFeatureValue.powerSaverSupportWifi
  case .bluetoothAdvertisingSetting:
    // id: 97
    return TTLockFeatureValue.bluetoothAdvertisingInterval
  case .workingMode:
    // id: 98
    return TTLockFeatureValue.workingMode
  case .supplierCode:
    // id: 99
    return TTLockFeatureValue.supplierNumber
  case .catOne:
    // id: 100
    return TTLockFeatureValue.catOne
  case .forcedOpeningDoorAlarm:
    // id: 102
    return TTLockFeatureValue.doorForceOpenAlert
  case .zhiAnFaceFeatureSecondGeneration:
    // id: 103
    return TTLockFeatureValue.zhiAnSecondGenerationPhotoFace
  case .wifiFirmwareVersion:
    // id: 104
    return TTLockFeatureValue.wifiFirmwareVersion
  case .supportDeadLocking:
    // id: 106
    return TTLockFeatureValue.secondDeadLock
  case .workingTime:
    // id: 107
    return TTLockFeatureValue.workingTime
  case .customQRCode:
    // id: 108
    return TTLockFeatureValue.customQRCode
  case .securityM1Card:
    // id: 109
    return TTLockFeatureValue.securityM1Card
  case .yiShengPhotoFace:
    // id: 110
    return TTLockFeatureValue.yiShengPhotoFace
  case .pictureFaceDelivery:
    // id: 112
    // iOS bit 112 为 YiNuoPhotoFace，与 Android SUPPORT_PICTURE_FACE_DELIVERY 同 bit。
    return TTLockFeatureValue.yiNuoPhotoFace
  case .yiNuoPhotoFace:
    // id: 112
    return TTLockFeatureValue.yiNuoPhotoFace
  case .supportSetAlias:
    // id: 114
    return TTLockFeatureValue.setAlias
  case .hideWifiCatOneSleepModeSetting:
    // id: 117
    return TTLockFeatureValue.hideSleepMode
  case .semiAutomaticModeControl:
    // id: 119
    return TTLockFeatureValue.semiAutomaticModeControl
  case .supportSetUserAttributes:
    // id: 120
    return TTLockFeatureValue.setOpenTypeAttributes
  case .motorDriveBoardFirmwareVersion:
    // id: 122
    return TTLockFeatureValue.motorDriveBoardFirmwareVersion
  case .urlFinger:
    // id: 123
    return nil
  case .urlFace:
    // id: 124
    return TTLockFeatureValue.urlFace
  case .urlPalmVein:
    // id: 125
    return nil
  case .supportSupervision:
    // id: 126
    return TTLockFeatureValue.proofCapture
  case .humanPresenceSensor:
    // id: 128
    return TTLockFeatureValue.humanPresenceSensor
  case .faceFeatureDataType:
    // id: 132
    return TTLockFeatureValue.faceFeatureDataType
  }
}

func aliasTypeConvert(_ type: TTAliasType) -> TTLockSDK.TTAliasType {
  switch type {
  case .fingerprint:
    return .fingerprint
  case .card:
    return .card
  case .wirelessKeyFob:
    return .wirelessKeyFob
  case .face:
    return .face
  case .palmVein:
    return .palmVein
  case .passcode:
    return .passcode
  case .qrCode:
    return .qrCode
  }
}

func lockErrorConvert(_ error: TTLockSDK.TTError) -> TTLockError {
  switch error {
  case .hadReseted:
    return .reseted
  case .crcError:
    return .crcError
  case .noPermisstion:
    return .noPermisstion
  case .wrongAdminCode:
    return .wrongAdminCode
  case .lackOfStorageSpace:
    return .noStorageSpace
  case .inSettingMode:
    return .inSettingMode
  case .noAdmin:
    return .noAdmin
  case .notInSettingMode:
    return .notInSettingMode
  case .wrongDynamicCode:
    return .wrongDynamicCode
  case .isNoPower:
    return .noPower
  case .resetPasscode:
    return .resetPasscode
  case .updatePasscodeIndex:
    return .unpdatePasscodeIndex
  case .invalidLockFlagPos:
    return .invalidLockFlagPos
  case .ekeyExpired:
    return .ekeyExpired
  case .passcodeLengthInvalid:
    return .passcodeLengthInvalid
  case .samePasscodes:
    return .samePasscodes
  case .ekeyInactive:
    return .ekeyInactive
  case .aesKey:
    return .aesKey
  case .fail:
    return .fail
  case .passcodeExist:
    return .passcodeExist
  case .passcodeNotExist:
    return .passcodeNotExist
  case .lackOfStorageSpaceWhenAddingPasscodes:
    return .lackOfStorageSpaceWhenAddingPasscodes
  case .invalidParaLength:
    return .invalidParaLength
  case .cardNotExist:
    return .cardNotExist
  case .fingerprintDuplication:
    return .fingerprintDuplication
  case .invalidParam:
    return .invalidParameter
  case .fingerprintNotExist:
    return .fingerprintNotExist
  case .invalidCommand:
    return .invalidCommand
  case .inFreezeMode:
    return .inFreezeMode
  case .invalidClientPara:
    return .invalidClientPara
  case .lockIsLocked:
    return .lockIsLocked
  case .recordExist:
    return .recordExist
  case .recordNotExist:
    return .recordNotExist
  case .wrongSSID:
    return .wrongWifi
  case .wrongWifiPassword:
    return .wrongWifiPassword
  case .bluetoothPoweredOff:
    return .bluetoothOff
  case .connectionTimeout:
    return .bluetoothConnectTimeount
  case .disconnection:
    return .bluetoothDisconnection
  case .lockIsBusy:
    return .lockIsBusy
  case .wrongLockData:
    return .invalidLockData
  case .invalidParameter:
    return .invalidParameter
  @unknown default:
    return .fail
  }
}

func gatewayTypeConvert(_ type: TTGatewayType) -> Int {
  switch type {
  case .g2:
    return 2
  case .g3:
    return 3
  case .g4:
    return 4
  case .g5:
    return 5
  case .g6:
    return 6
  }
}

func gatewayTypeRevert(_ nativeGatewayType: Int) -> TTGatewayType {
  switch nativeGatewayType {
  case 2:
    return TTGatewayType.g2
  case 3:
    return TTGatewayType.g3
  case 4:
    return TTGatewayType.g4
  case 5:
    return TTGatewayType.g5
  case 6:
    return TTGatewayType.g6
  default:
      return TTGatewayType.g2
  }
}

func gatewayConnectStatusConvert(_ error: TTLockSDK.TTGatewayConnectStatus) -> TTGatewayConnectStatus {
    switch error {
    case .success:
        return .success
    case .timeout:
        return .timeout
    case .fail:
        return .failed
    @unknown default:
        return .failed
    }
}

func gatewayErrorConvert(_ error: TTLockSDK.TTGatewayStatus) -> TTGatewayError {
  switch error {
  case .success:
    return .success
  case .fail:
    return .failed
  case .wrongSSID:
    return .badWifiName
  case .wrongWifiPassword:
    return .badWifiPassword
  case .invalidCommand:
    return .invalidCommand
  case .timeout:
    return .timeOut
  case .noSIM:
    return .noSimCard
  case .noPlugCable:
    return .noCable
  case .wrongCRC:
    return .wrongCRC
  case .wrongAeskey:
    return .wrongAesKey
  case .notConnect:
    return .unConnected
  case .disconnect:
    return .communicationDisconnected
  case .failConfigRouter:
    return .failedConfigureRouter
  case .failConfigServer:
    return .failedConfigureServer
  case .failConfigAccount:
    return .failedConfigAccount
  case .failConfigIP:
    return .failedConfigIp
  case .failInvaildIP:
    return .invalidIp
  @unknown default:
    return .failed
  }
}
func faceErrorConvert(_ error: TTLockSDK.TTFaceErrorCode) -> TTFaceErrorCode {
  switch error {
  case .noError:
      return .normal
  case .noFaceDetected:
      return .noFaceDetected
  case .tooCloseToTheTop:
      return .tooCloseToTheTop
  case .tooCloseToTheBottom:
      return .tooCloseToTheBottom
  case .tooCloseToTheLeft:
      return .tooCloseToTheLeft
  case .tooCloseToTheRight:
      return .tooCloseToTheRight
  case .tooFarAway:
      return .tooFarAway
  case .tooClose:
      return .tooClose
  case .eyebrowsCovered:
      return .eyebrowsCovered
  case .eyesCovered:
      return .eyesCovered
  case .faceCovered:
      return .faceCovered
  case .wrongFaceDirection:
      return .faceDirection
  case .eyeOpeningDetected:
      return .eyeOpeningDetected
  case .eyesClosedStatus:
      return .eyesClosedStatus
  case .failedToDetectEye:
      return .failedToDetectEye
  case .needTurnHeadToLeft:
      return .needTurnHeadToLeft
  case .needTurnHeadToRight:
      return .needTurnHeadToRight
  case .needRaiseHead:
      return .needRaiseHead
  case .needLowerHead:
      return .needLowerHead
  case .needTiltHeadToLeft:
      return .needTiltHeadToLeft
  case .needTiltHeadToRight:
      return .needTiltHeadToRight
  @unknown default:
      return .normal
  }
}

func palmVeinErrorConvert(_ error: TTLockSDK.TTPalmVeinErrorCode) -> TTPalmVeinErrorCode {
  switch error {
  case .noPalm:
    return .noPalmVeinDetected
  case .rectConfidenceLow:
    return .palmRectConfLow
  case .landmarkConfidenceLow:
    return .palmLandmarkConfLow
  case .angleRoll:
    return .palmAngleRollError
  case .angleLean:
    return .palmAngleLeanError
  case .plamBlock:
    return .palmBlock
  case .plamBlur:
    return .palmBlur
  case .plamBack:
    return .palmBack
  @unknown default:
    return .unknownStatus
  }
}

func remoteErrorConvert(_ error: TTLockSDK.TTKeyFobStatus) -> TTRemoteAccessoryError {
  switch error {
  case TTKeyFobSuccess:
    return .success
  case TTKeyFobFail:
    return .connectFailed
  case TTKeyFobConnectTimeout:
    return .connectFailed
  case TTKeyFobWrongCRC:
    return .wrongCRC
  default:
    return .failed
  }
}

func keypadErrorConvert(_ error: TTLockSDK.TTKeypadStatus) -> TTRemoteAccessoryError {
  switch error {
  case TTKeypadSuccess:
    return .success
  case TTKeypadFail:
    return .failed
  case TTKeypadWrongCRC:
    return .wrongCRC
  case TTKeypadConnectTimeout:
    return .connectFailed
  case TTKeypadWrongFactorydDate:
    return .dataFormatError
  default:
    return .failed
  }
}

func doorSensorErrorConvert(_ error: TTLockSDK.TTDoorSensorError) -> TTRemoteAccessoryError {
  switch error {
  case .bluetoothPowerOff:
    return .requestFailed
  case .connectTimeout:
    return .connectFailed
  case .fail:
    return .failed
  case .wrongCRC:
    return .wrongCRC
  @unknown default:
    return .failed
  }
}

func waterMeterErrorConvert(_ error: TTLockSDK.TTWaterMeterError) -> TTRemoteAccessoryError {
  switch error {
  case .bluetoothPowerOff:
    return .requestFailed
  case .connectTimeout:
    return .connectFailed
  case .disconnect:
    return .connectFailed
  case .netError:
    return .noResponse
  case .requestServerError:
    return .requestFailed
  case .existedInServer:
    return .requestFailed
  @unknown default:
    return .failed
  }
}

func electricMeterErrorConvert(_ error: TTLockSDK.TTElectricMeterError) -> TTRemoteAccessoryError
{
  switch error {
  case .bluetoothPowerOff:
    return .requestFailed
  case .connectTimeout:
    return .connectFailed
  case .disconnect:
    return .connectFailed
  case .netError:
    return .noResponse
  case .requestServerError:
    return .requestFailed
  case .existedInServer:
    return .requestFailed
  @unknown default:
    return .failed
  }
}

func multifunctionalKeypadErrorConvert(_ error: TTLockSDK.TTKeypadStatus)
  -> TTMultifunctionalKeypadError
{
  switch error {
  case TTKeypadSuccess:
    return .success
  case TTKeypadFail:
    return .failed
  case TTKeypadWrongCRC:
    return .wrongCRC
  case TTKeypadConnectTimeout:
    return .keypadConnectFailed
  case TTKeypadWrongFactorydDate:
    return .dataFormatError
  case TTKeypadDuplicateFingerprint:
    return .duplicateFingerprint
  case TTKeypadLackOfStorageSpace:
    return .noStorageSpace
  default:
    return .failed
  }
}

func waterMeterFeatureConvert(_ feature: TTWaterMeterFeature) -> TTLockSDK.TTWaterMeterFeature {
  switch feature {
  case .catOne:
    return .catOne
  }
}

func electricMeterFeatureConvert(_ feature: TTElectricMeterFeature) -> TTLockSDK.TTElectricMeterFeature {
  switch feature {
  case .catOne:
      return TTLockSDK.TTElectricMeterFeature.catOne
  case .telink:
      return TTLockSDK.TTElectricMeterFeature.telink
  }
}

func standaloneDoorSensorErrorConvert(
  _ error: TTLockSDK.TTStandaloneDoorSensorError
) -> TTStandaloneDoorSensorError {
  switch error {
  case .bluetoothPowerOff:
    return .bluetoothPowerOff
  case .connectTimeout:
    return .connectTimeout
  case .disconnect:
    return .disconnect
  case .fail:
    return .failed
  case .wrongCRC:
    return .wrongCRC
  case .wrongSSID:
    return .wrongSSID
  case .wrongWifiPassword:
    return .wrongWifiPassword
  @unknown default:
    return .failed
  }
}

func standaloneDoorSensorFeatureConvert(
  _ feature: TTStandaloneDoorSensorFeature
) -> TTLockSDK.TTStandaloneDoorSensorFeature? {
  switch feature {
  case .wifi24G:
    return .feature24GWifi
  case .wifi5G:
    return .feature5GWifi
  case .authCode:
    return .featureAuthCode
  case .alarm:
    return TTLockSDK.TTStandaloneDoorSensorFeature(rawValue: 3)
  }
}

func payModeConvert(_ mode: TTMeterPayMode) -> Int {
  switch mode {
  case .postpaid:
    return 0
  case .prepaid:
    return 1
  }
}
