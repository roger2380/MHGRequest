//
//  TCNDataCenterManager.h
//  Pods
//
//  Created by zhou on 2017/7/6.
//
//

#import <Foundation/Foundation.h>

@interface TCNDataCenterManager : NSObject

/**
 获取默认的Manager

 @return 默认的Manager
 */
+ (instancetype)defaultManager;

/**
 通过网络获取一个自动切换服务器的配置文件

 @param url 自动切换服务器配置文件的URL
 */
- (void)loadConfigurationWithURL:(NSString *)url;

/**
 获取指定url对应的推荐地址

 @param url 想要请求的原始url
 @return 推荐的url地址
 */
- (NSArray<NSString *> *)urlsMatchedWithOriginURL:(NSString *)url;

@end
