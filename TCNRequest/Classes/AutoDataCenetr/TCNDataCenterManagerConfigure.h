//
//  TCNDataCenterManagerConfigure.h
//  Pods
//
//  Created by zhou on 2017/9/27.
//
//

#import <Foundation/Foundation.h>

typedef NSString *(^TCNDCMCGetTokenBlock)();

/**
 全局多线路配置管理者的配置文件
 */
@interface TCNDataCenterManagerConfigure : NSObject

/**
 调用方需要设置这个block.
 并且保证执行这个block时可以获取到当前登录用户的token.
 没有登录时block应该返回nil.
 
 默认值为nil.
 */
@property (nonatomic, copy) TCNDCMCGetTokenBlock getTokenBlock;

/**
 多线路配置文件的URL地址
 
 默认值为nil.
 */
@property (nonatomic, copy) NSString *configureURLString;


/**
 刷新多线路配置的最小间隔时间,单位为秒.
 
 默认值为7200.
 */
@property (nonatomic, assign) NSTimeInterval interval;

@end
