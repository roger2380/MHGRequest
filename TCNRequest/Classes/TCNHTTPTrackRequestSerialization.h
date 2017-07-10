//
//  TCNHTTPTrackRequestSerialization.h
//  Pods
//
//  Created by zhou on 2017/7/7.
//
//

#import "TCNHTTPRequestSerialization.h"

/**
 body中添加通用参数并且使用JSON格式gzip压缩后发出
 目前常用于广告相关的请求
 */
@interface TCNHTTPTrackRequestSerialization : TCNHTTPRequestSerialization

@end
