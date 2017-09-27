//
//  TCNDataCenterManager.h
//  Pods
//
//  Created by zhou on 2017/7/6.
//
//

#import <Foundation/Foundation.h>
#import "TCNDataCenterMatchedURLItem.h"
#import <TCNRequest/TCNDataCenterManagerConfigure.h>

/**
 全局多线路配置管理者
 */
@interface TCNDataCenterManager : NSObject

/**
 初始化全局多线路配置管理者,应用启动时调用

 @param config 指定的配置
 */
+ (void)initializationWithConfig:(nonnull TCNDataCenterManagerConfigure *)config;

/**
 获取指定url对应的不同数据中心的地址

 @param url 想要请求的原始url
 @return 不同数据中心对应的URL地址，这些地址已经按照优先级排序
 */
+ (nonnull NSArray<TCNDataCenterMatchedURLItem *> *)urlsMatchedWithOriginURL:(nonnull NSString *)url;


/**
 外部请求成功时需要调用这个方法，manager内部可能会据此调整数据中心的优先级

 @param item 本次请求使用的item
 */
+ (void)requestSuccessWithItem:(nonnull TCNDataCenterMatchedURLItem *)item;

@end
