//
//  TCNAutoDataCenterManager.h
//  Pods
//
//  Created by zhou on 2017/7/6.
//
//

#import <AFNetworking/AFNetworking.h>

/**
 支持自动切换服务器的Manager
 其中自动切换配置使用的是TCNDataCenterManager的defaultManager的配置
 */
@interface TCNAutoDataCenterManager : AFHTTPSessionManager

/**
 可以忽视的错误类型。
 调用方可以通过设置这个属性无视一些错误类型。
 请求过程中出现了这些错误，Manager依然会视为请求成功，执行成功的block。
 */
@property (nullable, nonatomic, copy) NSSet<NSNumber *> *acceptableErrorCodes;

@end
