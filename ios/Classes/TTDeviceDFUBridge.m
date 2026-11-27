#import "TTDeviceDFUBridge.h"

@implementation TTDfuBridge

+ (void)startLockDfuWithFirmwarePackage:(NSString *)firmwarePackage
                               lockData:(NSString *)lockData
                           successBlock:(TTLockDFUSuccessBlock)successBlock
                              failBlock:(TTLockDFUFailBlock)failBlock {
  [[TTLockDFUOnPremise shareInstance] startDfuWithFirmwarePackage:firmwarePackage
                                                         lockData:lockData
                                                     successBlock:successBlock
                                                        failBlock:failBlock];
}

+ (void)endLockUpgrade {
  [[TTLockDFUOnPremise shareInstance] endUpgrade];
}

+ (void)startGatewayDfuWithFirmwarePackage:(NSString *)firmwarePackage
                                gatewayMac:(NSString *)gatewayMac
                              successBlock:(TTLockDFUSuccessBlock)successBlock
                                 failBlock:(TTLockDFUFailBlock)failBlock {
  [[TTGatewayDFU shareInstance] startDfuWithFirmwarePackage:firmwarePackage
                                                 gatewayMac:gatewayMac
                                               successBlock:successBlock
                                                  failBlock:failBlock];
}

+ (void)endGatewayUpgrade {
  [[TTGatewayDFU shareInstance] endUpgrade];
}

+ (void)startDeviceDfuWithFirmwarePackage:(NSString *)firmwarePackage
                              deviceModel:(TTDeviceDFUModel *)deviceModel
                             successBlock:(TTLockDFUSuccessBlock)successBlock
                                failBlock:(TTLockDFUFailBlock)failBlock {
  [[TTDeviceDFU shareInstance] startDfuWithFirmwarePackage:firmwarePackage
                                               deviceModel:deviceModel
                                              successBlock:successBlock
                                                 failBlock:failBlock];
}

+ (void)endDeviceUpgrade {
  [[TTDeviceDFU shareInstance] endUpgrade];
}

@end
