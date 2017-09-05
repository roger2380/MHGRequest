//
//  TCNDataCenterManager.h
//  Pods
//
//  Created by zhou on 2017/7/6.
//
//

#import <Foundation/Foundation.h>
#import "TCNDataCenterMatchedURLItem.h"

@interface TCNDataCenterManager : NSObject

/**
 获取默认的Manager

 @return 默认的Manager
 */
+ (nonnull instancetype)defaultManager;

/**
 通过网络获取一个自动切换服务器的配置文件

 @param url 自动切换服务器配置文件的URL
 @param token 当前登录用户的token,没有登录则传nil
 */
- (void)loadConfigurationWithURL:(nonnull NSString *)url
              currentAccessToken:(nullable NSString *)token;

/**
 获取指定url对应的不同数据中心的地址

 @param url 想要请求的原始url
 @return 不同数据中心对应的URL地址，这些地址已经按照优先级排序
 */
- (nonnull NSArray<TCNDataCenterMatchedURLItem *> *)urlsMatchedWithOriginURL:(nonnull NSString *)url;


/**
 外部请求成功时需要调用这个方法，manager内部可能会据此调整数据中心的优先级

 @param item 本次请求使用的item
 */
- (void)requestSuccessWithItem:(nonnull TCNDataCenterMatchedURLItem *)item;

@end
