//
//  TCNAutoDataCenterStopErrorType.h
//  Pods
//
//  Created by zhou on 2017/9/8.
//
//

#import <Foundation/Foundation.h>

/**
 定义多线路切换时遇到后应该停止的错误类型
 */
@interface TCNAutoDataCenterStopErrorType : NSObject

@property (nonatomic, readonly, copy) NSString *errorDomain;
@property (nonatomic, readonly, assign) NSInteger errorCode;

- (instancetype)initWithErrorDomain:(NSString *)errorDomain errorCode:(NSInteger)errorCode;

- (BOOL)isThisErrorType:(NSError *)error;

@end
