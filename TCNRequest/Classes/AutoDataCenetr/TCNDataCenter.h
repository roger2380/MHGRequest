//
//  TCNDataCenter.h
//  Pods
//
//  Created by zhou on 2017/7/13.
//
//

#import <Foundation/Foundation.h>
#import "TCNDataCenterMatchedURLItem.h"

@interface TCNDataCenter : NSObject <NSCoding, NSCopying>

/**
 数据中心的名字
 */
@property (nonnull, nonatomic, readonly, copy) NSString *name;


/**
 用一个数据中心的配置初始化一个数据中心对象

 @param dataCenterDictionary 一个数据中心配置
 @return 初始化完成的数据中心对象。如果配置数据有问题，会返回nil
 */
- (nullable instancetype)initWithDictionary:(nonnull NSDictionary *)dataCenterDictionary;


/**
 将一个url地址转换为该数据中心对应的URLItem配置

 @param url 需要转换的url地址
 @return 转换完成的item。如果该数据中心没有适用于该url的规则，则matchedURL将和OriginURL一致
 */
- (nullable TCNDataCenterMatchedURLItem *)urlsMatchedWithOriginURL:(nullable NSString *)url;

@end
