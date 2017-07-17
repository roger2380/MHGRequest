//
//  TCRequest.h
//  TCRequest
//
//  Created by xbwu on 2017/6/19.
//  Copyright © 2017年 xbwu. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString * const TCNRequestErrorDomain;

// 出现本文件定义的错误时，仍然可以尝试通过
// error.userInfo[TCNRequestErrorResponseDataErrorKey]
// 的方式获取服务器返回的数据
FOUNDATION_EXPORT NSString * const TCNRequestErrorResponseDataErrorKey;

/**
 TCNRequest错误码

 - TCNRequestErrorCodeNone: 未定义
 - TCNRequestErrorCodeBadServerResponse: 服务器返回数据的status不是success
 */
typedef NS_ENUM(NSInteger, TCNRequestErrorCode) {
  TCNRequestErrorCodeNone = 0,
  TCNRequestErrorCodeBadServerResponse = 1,
};
