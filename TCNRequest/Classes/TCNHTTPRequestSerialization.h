//
//  TCNHTTPRequestSerialization.h
//  Pods
//
//  Created by zhou on 2017/7/6.
//
//

#import <AFNetworking/AFNetworking.h>

/**
 添加url通用参数和sign验签的请求类型
 */
@interface TCNHTTPRequestSerialization : AFHTTPRequestSerializer

/**
 服务器方提供的用于SN签名验证的key
 */
@property (nonatomic, readonly, strong) NSString *signKey;

/**
 发起网络请求时使用的用户tokne
 */
@property (nonatomic, readonly, strong) NSString *accessToken;

/**
 使用指定SN签名验证key初始化一个实例

 @param signKey 服务器方提供的用于SN签名验证的key
 @return 初始化完成的对象
 */
+ (instancetype)serializerWithSignKey:(NSString *)signKey;

/**
 使用指定的accessToken初始化一个实例

 @param accessToken 用户登录后获取的accessToken
 @return 初始化完成的对象
 */
+ (instancetype)serializerWithAccessToken:(NSString *)accessToken;

/**
 使用指定的accessToken和SN签名验证key初始化一个实例

 @param signKey 服务器方提供的用于SN签名验证的key
 @param accessToken 用户登录后获取的accessToken
 @return 初始化完成的对象
 */
+ (instancetype)serializerWithSignKey:(NSString *)signKey accessToken:(NSString *)accessToken;

@end
