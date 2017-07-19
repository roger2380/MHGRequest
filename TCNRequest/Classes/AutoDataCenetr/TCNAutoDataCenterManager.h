//
//  TCNAutoDataCenterManager.h
//  Pods
//
//  Created by zhou on 2017/7/6.
//
//

#import <AFNetworking/AFNetworking.h>

typedef void(^TCNAutoDataCenterSuccessBlock)(id _Nonnull);
typedef void(^TCNAutoDataCenterFailureBlock)(NSError * _Nonnull);

NS_ASSUME_NONNULL_BEGIN

@interface TCNAutoDataCenterStopErrorType : NSObject

@property (nonatomic, readonly, copy) NSString *errorDomain;
@property (nonatomic, readonly, assign) NSInteger errorCode;

- (nullable instancetype)initWithErrorDomain:(nullable NSString *)errorDomain errorCode:(NSInteger)errorCode;

- (BOOL)isThisErrorType:(nullable NSError *)error;

@end

/**
 支持自动切换服务器的Manager
 其中自动切换配置使用的是[TCNDataCenterManager defaultManager]的配置
 */
@interface TCNAutoDataCenterManager : AFHTTPSessionManager

/**
 停止切换线路的错误类型。
 调用方可以设置一些错误类型。
 出现这些错误时，将停止线路切换，执行错误处理的block。
 */
@property (nullable, nonatomic, strong) NSArray<TCNAutoDataCenterStopErrorType *> *acceptableErrorType;


- (nullable NSURLSessionDataTask *)autoDataCenterGET:(nonnull NSString *)URLString
                                          parameters:(nullable id)parameters
                                             success:(nullable void (^)(id _Nullable responseObject))success
                                             failure:(nullable void (^)(NSError *error))failure;

- (nullable NSURLSessionDataTask *)autoDataCenterPOST:(nonnull NSString *)URLString
                                           parameters:(nullable id)parameters
                                              success:(nullable void (^)(id _Nullable responseObject))success
                                              failure:(nullable void (^)(NSError *error))failure;

@end
NS_ASSUME_NONNULL_END
