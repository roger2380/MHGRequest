//
//  TCNAutoDataCenterManager.m
//  Pods
//
//  Created by zhou on 2017/7/6.
//
//

#import "TCNAutoDataCenterManager.h"
#import "TCNDataCenterManager.h"
#import <TCNRequest/TCNAutoDataCenterManagerURLSessionTaskSwizzling.h>

typedef void(^TCNAFSuccessBlock)(NSURLSessionDataTask * _Nonnull, id _Nonnull);
typedef void(^TCNAFFailureBlock)(NSURLSessionDataTask * _Nonnull, NSError * _Nonnull);

@interface AFHTTPSessionManager (TCNAutoDataCenterManager)

NS_ASSUME_NONNULL_BEGIN
- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                                  uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgress
                                downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgress
                                         success:(void (^)(NSURLSessionDataTask *, id))success
                                         failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;
NS_ASSUME_NONNULL_END

@end

@interface TCNAutoDataCenterManager ()

@property (nonatomic, readonly, assign) BOOL autoDataCenterUsable;

@end

@implementation TCNAutoDataCenterManager

+ (void)initializationWithConfig:(TCNAutoDataCenterManagerConfigure *)config {
  TCNDataCenterManagerConfigure *dataCenterManagerConfig = [[TCNDataCenterManagerConfigure alloc] init];
  dataCenterManagerConfig.getTokenBlock = config.getTokenBlock;
  dataCenterManagerConfig.configureURLString = config.configureURLString;
  dataCenterManagerConfig.interval = config.interval;
  
  [TCNDataCenterManager initializationWithConfig:dataCenterManagerConfig];
}

- (nullable NSURLSessionDataTask *)autoDataCenterGET:(nonnull NSString *)URLString
                                          parameters:(nullable id)parameters
                                             success:(nullable void (^)(id _Nullable responseObject))success
                                             failure:(nullable void (^)(NSError *error))failure {
  if (self.autoDataCenterUsable) {
    return [self startAutoDataCenterWithHTTPMethod:@"GET"
                                         URLString:URLString
                                        parameters:parameters
                                           success:success
                                           failure:failure];
  } else {
    TCNAFFailureBlock failureBlock = ^(NSURLSessionDataTask * _Nullable task, NSError *error) {
      if (failure) {
        failure(error);
      }
    };
    
    TCNAFSuccessBlock successBlock = ^(NSURLSessionDataTask * _Nonnull task, id _Nonnull responseObject) {
      if (success) {
        success(responseObject);
      }
    };
    
    return [self GET:URLString parameters:parameters progress:nil success:successBlock failure:failureBlock];
  }
}

- (nullable NSURLSessionDataTask *)autoDataCenterPOST:(nonnull NSString *)URLString
                                           parameters:(nullable id)parameters
                                              success:(nullable void (^)(id _Nullable responseObject))success
                                              failure:(nullable void (^)(NSError *error))failure {
  if (self.autoDataCenterUsable) {
    return [self startAutoDataCenterWithHTTPMethod:@"POST"
                                         URLString:URLString
                                        parameters:parameters
                                           success:success
                                           failure:failure];
  } else {
    TCNAFFailureBlock failureBlock = ^(NSURLSessionDataTask * _Nullable task, NSError *error) {
      if (failure) {
        failure(error);
      }
    };
    
    TCNAFSuccessBlock successBlock = ^(NSURLSessionDataTask * _Nonnull task, id _Nonnull responseObject) {
      if (success) {
        success(responseObject);
      }
    };
    
    return [self POST:URLString parameters:parameters progress:nil success:successBlock failure:failureBlock];
  }
}

- (NSURLSessionDataTask *)startAutoDataCenterWithHTTPMethod:(NSString *)method
                                                  URLString:(NSString *)URLString
                                                 parameters:(id)parameters
                                                    success:(void (^)(id))success
                                                    failure:(void (^)(NSError *))failure {
  if (!self.autoDataCenterUsable) return nil;
  NSArray<TCNDataCenterMatchedURLItem *> *allItems =  [TCNDataCenterManager urlsMatchedWithOriginURL:URLString];
  /////////////////////////////////////////////////////////////////////////////////////////////////////////
  // 如果当前没有任何多线路配置，使用原始地址
  
  if (allItems.count == 0) {
    TCNDataCenterMatchedURLItem *originItem = [[TCNDataCenterMatchedURLItem alloc]initWithDataCenterName:nil
                                                                                             originalURL:URLString
                                                                                              matchedURL:URLString];
    if (originItem) {
      allItems = @[originItem];
    }
  }
  /////////////////////////////////////////////////////////////////////////////////////////////////////////
  // 过滤掉重复的URL

  NSArray<TCNDataCenterMatchedURLItem *> *items = @[];
  NSMutableSet<NSString *> *matchedURLs = [[NSMutableSet alloc] initWithCapacity:allItems.count];
  
  for (TCNDataCenterMatchedURLItem *item in allItems) {
    if ([matchedURLs containsObject:item.matchedURL]) continue;
    items = [items arrayByAddingObject:item];
    [matchedURLs addObject:item.matchedURL];
  }
  /////////////////////////////////////////////////////////////////////////////////////////////////////////
  // 处理items为空的情况

  if (items.count == 0) {
    NSURLSessionDataTask *task = [self dataTaskWithHTTPMethod:method
                                                    URLString:nil
                                                   parameters:parameters
                                               uploadProgress:nil
                                             downloadProgress:nil
                                                      success:^(NSURLSessionDataTask *task, id responseObject) {
                                                        success(responseObject);
                                                      }
                                                      failure:^(NSURLSessionDataTask *task, NSError *error) {
                                                        failure(error);
                                                      }];
    [task resume];
    return task;
  }
  /////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  __block NSInteger taskTotalCount = 0;
  __block NSInteger failedCount = 0;
  __block NSURLSessionDataTask *mainTask = nil;
  
  BOOL(^shouldStopBlock)(NSURLSessionDataTask *, NSError *) = ^BOOL(NSURLSessionDataTask *task, NSError *error) {
    BOOL shouldStop = failedCount == taskTotalCount;
    
    if (!shouldStop) {
      BOOL taskIsCancelled = [error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled;
      shouldStop = task == mainTask && taskIsCancelled;
    }
    
    if (!shouldStop) {
      for (TCNAutoDataCenterStopErrorType *type in self.acceptableErrorType) {
        if ([type isThisErrorType:error]) {
          shouldStop = YES;
          break;
        }
      }
    }
    
    return shouldStop;
  };
  
  __block BOOL didHandleCompletion = NO;
  
  TCNAFFailureBlock failBlock = ^(NSURLSessionDataTask *task, NSError *error) {
    if (didHandleCompletion) {
      return;
    }
    
    failedCount++;
    
    if (shouldStopBlock(task, error)) {
      didHandleCompletion = YES;
      
      if (failure) {
        failure(error);
      }
      
      [mainTask cancel];
    }
  };
  
  for (TCNDataCenterMatchedURLItem *item in items) {
    TCNAFSuccessBlock successBlock = ^(NSURLSessionDataTask *task, id responseObject) {
      if (didHandleCompletion) {
        return;
      }
      didHandleCompletion = YES;
      [TCNDataCenterManager requestSuccessWithItem:item];
      if (success) {
        success(responseObject);
      }
      [mainTask cancel];
    };
    
    NSURLSessionDataTask *task = [self dataTaskWithHTTPMethod:method
                                                    URLString:item.matchedURL
                                                   parameters:parameters
                                               uploadProgress:nil
                                             downloadProgress:nil
                                                      success:successBlock
                                                      failure:failBlock];
    if (task) {
      taskTotalCount += 1;
      if (mainTask) {
        mainTask.tcnadcmSubTasks = [mainTask.tcnadcmSubTasks arrayByAddingObject:task];
      } else {
        mainTask = task;
      }
    }
  }
  
  [mainTask resume];
  
  for (NSInteger i = 0; i < mainTask.tcnadcmSubTasks.count; i++) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((i + 1) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      if (!didHandleCompletion && i < mainTask.tcnadcmSubTasks.count) {
        [[mainTask.tcnadcmSubTasks objectAtIndex:i] resume];
      }
    });
  }
  
  return mainTask;
}

- (BOOL)autoDataCenterUsable {
  SEL dataTaskWithHTTPMethodSEL = @selector(dataTaskWithHTTPMethod:URLString:parameters:
                                            uploadProgress:downloadProgress:success:failure:);
  BOOL haveCreatedataTaskSEL = [self respondsToSelector:dataTaskWithHTTPMethodSEL];

#ifdef DEBUG
  NSAssert(haveCreatedataTaskSEL, @"AFHTTPSessionManager的内部实现发生变化,找不到创建dataTask的方法了");
#endif
  if (!haveCreatedataTaskSEL) return NO;
  
  BOOL swizzlingSuccess = TCNADCMURLSessionTaskSwizzlingType == TCNAutoDataCenterManagerURLSessionTaskSwizzlingTypeSuccessful;
  
#ifdef DEBUG
  NSAssert(swizzlingSuccess, @"没有成功通过runtime修改NSURLSessionDataTask类");
#endif
  
  if (!swizzlingSuccess) return NO;
  
  return YES;
}

@end
