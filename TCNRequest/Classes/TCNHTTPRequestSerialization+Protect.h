//
//  TCNHTTPRequestSerialization+Protect.h
//  Pods
//
//  Created by zhou on 2017/7/6.
//
//

#import "TCNHTTPRequestSerialization.h"

@interface TCNHTTPRequestSerialization (Protect)

/**
 服务器方提供的用于SN签名验证的key
 */
@property (nonatomic, strong) NSString *signKey;

/**
 发起网络请求时使用的用户tokne
 */
@property (nonatomic, strong) NSString *accessToken;


/**
 使用指定的accessToken和SN签名验证key初始化一个实例
 
 @param signKey 服务器方提供的用于SN签名验证的key
 @param accessToken 用户登录后获取的accessToken
 @return 初始化完成的对象
 */
- (instancetype)initWithSignKey:(NSString *)signKey accessToken:(NSString *)accessToken;

/**
 组装HTTP请求Body部分的方法
 子类可以通过重写这个方法来自定义body的格式

 @param request 当前请求的request
 @param parameters 当前请求的参数
 */
- (void)buildPostBodyWithRequest:(NSMutableURLRequest *)request parameters:(id)parameters;

@end
