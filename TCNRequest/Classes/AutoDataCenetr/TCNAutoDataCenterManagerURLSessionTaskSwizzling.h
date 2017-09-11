//
//  TCNAutoDataCenterManagerURLSessionTaskSwizzling.h
//  Pods
//
//  Created by zhou on 2017/9/8.
//
//  这个文件的目的是修改系统NSURLSessionDataTask的cancel行为
//  模块外部不应该使用这个文件中的任何类和方法
//

#import <Foundation/Foundation.h>


/**
 本.h和.m文件会使用runtime对系统原生的NSURLSessionDataTask进行修改
 这个枚举标识修改的结果

 - TCNAutoDataCenterManagerURLSessionTaskSwizzlingTypeNotImplemented: 没有进行任何修改
 - TCNAutoDataCenterManagerURLSessionTaskSwizzlingTypeFailed: 修改失败
 - TCNAutoDataCenterManagerURLSessionTaskSwizzlingTypeSuccessful: 修改成功
 */
typedef NS_ENUM(NSInteger, TCNAutoDataCenterManagerURLSessionTaskSwizzlingType) {
  TCNAutoDataCenterManagerURLSessionTaskSwizzlingTypeNotImplemented = 0,
  TCNAutoDataCenterManagerURLSessionTaskSwizzlingTypeFailed = 1,
  TCNAutoDataCenterManagerURLSessionTaskSwizzlingTypeSuccessful = 2
};

FOUNDATION_EXPORT TCNAutoDataCenterManagerURLSessionTaskSwizzlingType TCNADCMURLSessionTaskSwizzlingType;

@interface TCNAutoDataCenterManagerURLSessionTaskSwizzling : NSObject

@end

@interface NSURLSessionDataTask (TCNADCMCancel)

@property (nonatomic, strong) NSArray<NSURLSessionTask *> *tcnadcmSubTasks;

- (void)tcnadcmCancelSubTasks;

@end
