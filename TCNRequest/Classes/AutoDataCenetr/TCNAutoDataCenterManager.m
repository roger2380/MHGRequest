//
//  TCNAutoDataCenterManager.m
//  Pods
//
//  Created by zhou on 2017/7/6.
//
//

#import "TCNAutoDataCenterManager.h"
#import "TCNDataCenterManager.h"
#import "TCNRequestError.h"

@implementation TCNAutoDataCenterStopErrorType

- (nullable instancetype)initWithErrorDomain:(nullable NSString *)errorDomain errorCode:(NSInteger)errorCode {
  if (![errorDomain isKindOfClass:[NSString class]] || errorDomain.length == 0) {
    return nil;
  }
  
  if (self = [super init]) {
    _errorDomain = errorDomain;
    _errorCode = errorCode;
  }
  
  return self;
}

- (BOOL)isThisErrorType:(nullable NSError *)error {
  if (!error) {
    return NO;
  }
  if (![error.domain isEqualToString:self.errorDomain]) {
    return NO;
  }
  if (error.code != self.errorCode) {
    return NO;
  }
  
  return YES;
}

@end

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

@implementation TCNAutoDataCenterManager

- (instancetype)initWithBaseURL:(NSURL *)url sessionConfiguration:(NSURLSessionConfiguration *)configuration {
  if (self = [super initWithBaseURL:url sessionConfiguration:configuration]) {
    TCNAutoDataCenterStopErrorType *type = [[TCNAutoDataCenterStopErrorType alloc]initWithErrorDomain:TCNRequestErrorDomain
                                                                                errorCode:TCNRequestErrorCodeBadServerResponse];
    self.acceptableErrorType = @[type];
  }
  return self;
}

- (nullable NSURLSessionDataTask *)autoDataCenterGET:(nonnull NSString *)URLString
                                          parameters:(nullable id)parameters
                                             success:(nullable void (^)(NSURLSessionDataTask * task, id _Nullable responseObject))success
                                             failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure {
  return [self startAutoDataCenterWithHTTPMethod:@"GET"
                                       URLString:URLString
                                      parameters:parameters
                                         success:success
                                         failure:failure];
}

- (nullable NSURLSessionDataTask *)autoDataCenterPOST:(nonnull NSString *)URLString
                                           parameters:(nullable id)parameters
                                              success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                                              failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure {
  return [self startAutoDataCenterWithHTTPMethod:@"POST"
                                       URLString:URLString
                                      parameters:parameters
                                         success:success
                                         failure:failure];
}

- (NSURLSessionDataTask *)startAutoDataCenterWithHTTPMethod:(NSString *)method
                                                  URLString:(NSString *)URLString
                                                 parameters:(id)parameters
                                                    success:(void (^)(NSURLSessionDataTask *, id))success
                                                    failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
  SEL dataTaskWithHTTPMethodSEL = @selector(dataTaskWithHTTPMethod:URLString:parameters:uploadProgress:downloadProgress:success:failure:);
  BOOL haveCreatedataTaskSEL = [self respondsToSelector:dataTaskWithHTTPMethodSEL];
#ifdef DEBUG
  NSAssert(haveCreatedataTaskSEL, @"AFHTTPSessionManager的内部实现发生变化,找不到创建dataTask的方法了");
#else
  if (!haveCreatedataTaskSEL) {
    return nil;
  }
#endif
  
  __block BOOL didHandleCompletion = NO;
  TCNDataCenterMatchedURLItem *originItem = [[TCNDataCenterMatchedURLItem alloc]initWithDataCenterName:nil
                                                                                           originalURL:URLString
                                                                                            matchedURL:URLString];
  NSArray<TCNDataCenterMatchedURLItem *> *items =  @[originItem];
  items = [items arrayByAddingObjectsFromArray:[[TCNDataCenterManager defaultManager]
                                                urlsMatchedWithOriginURL:URLString]];
  
  __block NSInteger failedCount = 0;
  
  TCNAFFailureBlock shouldHandlefailed = ^(NSURLSessionDataTask * _Nullable task, NSError *error) {
    failedCount++;
    if (failedCount == items.count) {
      failure(task, error);
    }
  };
  
  NSMutableArray<NSURLSessionDataTask *> *tasks = [[NSMutableArray alloc] init];
  
  TCNAFFailureBlock failBlock = ^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
    if (didHandleCompletion) {
      return;
    }
    
    BOOL shouldStop = error.code == NSURLErrorCancelled;
    
    if (!shouldStop) {
      for (TCNAutoDataCenterStopErrorType *type in self.acceptableErrorType) {
        if ([type isThisErrorType:error]) {
          shouldStop = YES;
          break;
        }
      }
    }
    
    if (shouldStop) {
      didHandleCompletion = YES;
      failure(task, error);
      [self cancelTasks:tasks];
    } else {
      shouldHandlefailed(task, error);
    }
  };

  void (^startOneTask)(NSInteger) = ^void(NSInteger index) {
    if (index < [items count]) {
      TCNDataCenterMatchedURLItem *item = [items objectAtIndex:index];
      
      TCNAFSuccessBlock successBlock = ^(NSURLSessionDataTask * _Nonnull task, id _Nonnull responseObject) {
        if (didHandleCompletion) {
          return;
        }
        didHandleCompletion = YES;
        [[TCNDataCenterManager defaultManager]requestSuccessWithItem:item];
        success(task,responseObject);
        [self cancelTasks:tasks];
      };
      
      NSURLSessionDataTask *task = [self dataTaskWithHTTPMethod:method
                                                      URLString:item.matchedURL
                                                     parameters:parameters
                                                 uploadProgress:nil
                                               downloadProgress:nil
                                                        success:successBlock
                                                        failure:failBlock];
      [task resume];
      [tasks addObject:task];
    }
  };
  
  startOneTask(0);
  
  for (NSInteger i = 1; i < [items count]; i++) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(i * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      if (!didHandleCompletion) {
        startOneTask(i);
      }
    });
  }
  
  return tasks.firstObject;
}

- (void)cancelTasks:(NSArray *)tasks {
  for (NSURLSessionDataTask *task in tasks) {
    [task cancel];
  }
}

@end