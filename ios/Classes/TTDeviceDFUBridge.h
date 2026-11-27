#import <Foundation/Foundation.h>
#import <TTLockDFUOnPremise/TTDeviceDFU.h>
#import <TTLockDFUOnPremise/TTGatewayDFU.h>
#import <TTLockDFUOnPremise/TTLockDFUOnPremise.h>

NS_ASSUME_NONNULL_BEGIN

/// Xcode 27 / Swift 6 对部分 DFU ObjC API 导入不完整，统一经 ObjC 桥接调用。
@interface TTDfuBridge : NSObject

+ (void)startLockDfuWithFirmwarePackage:(NSString *)firmwarePackage
                               lockData:(NSString *)lockData
                           successBlock:(TTLockDFUSuccessBlock)successBlock
                              failBlock:(TTLockDFUFailBlock)failBlock;

+ (void)endLockUpgrade;

+ (void)startGatewayDfuWithFirmwarePackage:(NSString *)firmwarePackage
                                gatewayMac:(NSString *)gatewayMac
                              successBlock:(TTLockDFUSuccessBlock)successBlock
                                 failBlock:(TTLockDFUFailBlock)failBlock;

+ (void)endGatewayUpgrade;

+ (void)startDeviceDfuWithFirmwarePackage:(NSString *)firmwarePackage
                              deviceModel:(TTDeviceDFUModel *)deviceModel
                             successBlock:(TTLockDFUSuccessBlock)successBlock
                                failBlock:(TTLockDFUFailBlock)failBlock;

+ (void)endDeviceUpgrade;

@end

NS_ASSUME_NONNULL_END
