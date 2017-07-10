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

@implementation TCNAutoDataCenterManager

- (instancetype)initWithBaseURL:(nullable NSURL *)url; {
  self = [super initWithBaseURL:url];
  if (self) {
    self.acceptableErrorCodes = [NSSet setWithObjects:@(TCNRequestErrorCodeBadServerResponse), nil];
  }
  return self;
}

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                               uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgressBlock
                             downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgressBlock
                            completionHandler:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))completionHandler {
  __block BOOL didHandleCompletion = NO;
  NSArray *urls =  [[TCNDataCenterManager defaultManager] urlsMatchedWithOriginURL:[request.URL absoluteString]];
  __block NSInteger failedCount = 0;
  void (^shouldHandlefailed)(NSURLResponse *response, NSError *error) = ^(NSURLResponse *response, NSError *error) {
    failedCount++;
    if (failedCount == urls.count + 1) {
      completionHandler(response, nil, error);
    }
  };
  NSMutableArray *tasks = [[NSMutableArray alloc] init];
  NSURLSessionDataTask *mainTask = [super dataTaskWithRequest:request
                                               uploadProgress:nil
                                             downloadProgress:nil
                                            completionHandler:^(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error) {
                                              if (didHandleCompletion) {
                                                return;
                                              }
                                              if (!error
                                                  || error.code == NSURLErrorCancelled
                                                  || [self.acceptableErrorCodes containsObject:@(error.code)]) {
                                                didHandleCompletion = YES;
                                                if (error.code == NSURLErrorCancelled) {
                                                  completionHandler(nil, nil, error);
                                                } else {
                                                  completionHandler(response, responseObject, error);
                                                }
                                                [self cancelTasks:tasks];
                                              } else {
                                                shouldHandlefailed(response, error);
                                              }
                                            }];
  [tasks addObject:mainTask];
  //请求其他线路
  for (NSInteger i = 0; i < urls.count; i++) {
    NSString *url = [urls objectAtIndex:i];
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (i + 1)*NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^{
      if (didHandleCompletion) {
        return;
      }
      NSMutableURLRequest *subRequest = [request mutableCopy];
      subRequest.URL = [NSURL URLWithString:url];
      NSURLSessionDataTask *subTask = [super dataTaskWithRequest:subRequest
                                                  uploadProgress:nil
                                                downloadProgress:nil
                                               completionHandler:^(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error) {
                                                 if (didHandleCompletion) {
                                                   return;
                                                 }
                                                 if (!error || [self.acceptableErrorCodes containsObject:@(error.code)]) {
                                                   didHandleCompletion = YES;
                                                   completionHandler(response, responseObject, error);
                                                   [self cancelTasks:tasks];
                                                 } else {
                                                   shouldHandlefailed(response, error);
                                                 }
                                               }];
      [tasks addObject:subTask];
    });
  }
  return mainTask;
}

- (void)cancelTasks:(NSArray *)tasks {
  for (NSURLSessionDataTask *task in tasks) {
    [task cancel];
  }
}

@end
