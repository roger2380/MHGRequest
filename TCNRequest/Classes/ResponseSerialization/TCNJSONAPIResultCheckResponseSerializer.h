//
//  TCNJSONAPIResultCheckResponseSerializer.h
//  Pods
//
//  Created by zhou on 2017/9/27.
//
//

#import <AFNetworking/AFNetworking.h>

// 返回结果检查失败时抛出错误的Domain
extern NSString * const TCNJSONAPIRRSErrorDomain;

// 出现本文件定义的错误时，调用方仍然可以通过
// error.userInfo[TCNJSONAPIRRSErrorJSONObjectUserInfoKey]
// 的方式获取服务器返回数据JSON解析完成后的对象
extern NSString * const TCNJSONAPIRRSErrorJSONObjectUserInfoKey;

/**
 返回结果检查失败的错误类型

 - TCNJSONAPIRRSErrorCodeNone: 未定义
 - TCNJSONAPIRRSErrorCodeIsNotDict: 返回结果不是字典
 - TCNJSONAPIRRSErrorCodeStatusIsNotSuccess: 返回结果的status字段不是success
 */
typedef NS_ENUM(NSInteger, TCNJSONAPIRRSErrorCode) {
  TCNJSONAPIRRSErrorCodeNone = 0,
  TCNJSONAPIRRSErrorCodeIsNotDict = 1,
  TCNJSONAPIRRSErrorCodeStatusIsNotSuccess = 2
};

// 自动检查服务器API返回的结果.
// 如果数据异常会视作请求失败.

// 配合自动切换线路使用,检查失败时会继续切换其他线路.
// 如果需要在检查失败时停止切换线路执行失败回调,则需要将上面定义的错误加入到TCNAutoDataCenterManager的cceptableErrorType中.
@interface TCNJSONAPIResultCheckResponseSerializer : AFJSONResponseSerializer

@end
