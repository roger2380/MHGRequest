//
//  TCNJSONAPIResultCheckResponseSerializer.h
//  Pods
//
//  Created by zhou on 2017/9/27.
//
//

#import <AFNetworking/AFNetworking.h>

// 返回的JSON数据检查失败时抛出错误的Domain
extern NSString * const TCNJSONAPIRRSErrorDomain;

// 出现本文件定义的错误时，调用方仍然可以通过
// error.userInfo[TCNJSONAPIRRSErrorJSONObjectUserInfoKey]
// 的方式获取服务器返回数据JSON解析完成后的对象
extern NSString * const TCNJSONAPIRRSErrorJSONObjectUserInfoKey;

/**
 返回的JSON数据检查失败的错误类型

 - TCNJSONAPIRRSErrorCodeNone: 未定义
 - TCNJSONAPIRRSErrorCodeIsNotDict: 返回的JSON数据不是字典
 - TCNJSONAPIRRSErrorCodeStatusIsNotSuccess: 返回的JSON数据的status字段不是success
 */
typedef NS_ENUM(NSInteger, TCNJSONAPIRRSErrorCode) {
  TCNJSONAPIRRSErrorCodeNone = 0,
  TCNJSONAPIRRSErrorCodeIsNotDict = 1,
  TCNJSONAPIRRSErrorCodeStatusIsNotSuccess = 2
};

// 自动检查服务器API返回的JSON数据.
// 如果数据异常会视作请求失败.
// 注意:这里的”异常“指的是数据结构,字段的异常,并不是指JSON解析异常.
// 注意:如果返回数据JSON解析出现问题,并不会抛出本文件定义的错误.

// 配合自动切换线路使用,检查失败时会继续切换其他线路.
// 如果需要在检查失败时停止线路切换执行失败回调,则需要将上面定义的错误加入到TCNAutoDataCenterManager的acceptableErrorType中.
@interface TCNJSONAPIResultCheckResponseSerializer : AFJSONResponseSerializer

@end
