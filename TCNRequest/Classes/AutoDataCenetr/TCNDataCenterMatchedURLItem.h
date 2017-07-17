//
//  TCNDataCenterMatchedURLItem.h
//  Pods
//
//  Created by zhou on 2017/7/17.
//
//

#import <Foundation/Foundation.h>

/**
 某个数据中心的一个接口配置
 */
@interface TCNDataCenterMatchedURLItem : NSObject

@property (nullable, nonatomic, readonly, copy) NSString *dataCenterName;

@property (nullable, nonatomic, readonly, copy) NSString *originalURL;

@property (nonnull, nonatomic, readonly, copy) NSString *matchedURL;

- (nullable instancetype)initWithDataCenterName:(nullable NSString *)name
                                    originalURL:(nullable NSString *)originalURL
                                     matchedURL:(nonnull NSString *)matchedURL;

@end
