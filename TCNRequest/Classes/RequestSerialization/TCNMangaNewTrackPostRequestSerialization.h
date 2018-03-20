//
//  TCNNewTrackPostRequestSerialization.h
//  AFNetworking
//
//  Created by zhou on 2018/3/14.
//

#import <AFNetworking/AFNetworking.h>

/**
 用于漫咖新的数据追踪请求
 */
@interface TCNMangaNewTrackPostRequestSerialization : AFHTTPRequestSerializer

/**
 服务器方提供的用于SN签名验证的key
 */
@property (nonatomic, readonly, strong) NSString *signKey;

/**
 使用指定SN签名验证key初始化一个实例
 
 @param signKey 服务器方提供的用于SN签名验证的key
 @return 初始化完成的对象
 */
+ (instancetype)serializerWithSignKey:(NSString *)signKey;

@end
