//
//  TCNViewController.m
//  TCNRequest
//
//  Created by 周高举 on 07/06/2017.
//  Copyright (c) 2017 周高举. All rights reserved.
//

#import "TCNViewController.h"
#import <TCNRequest/TCNRequest.h>

typedef void(^AFSuccessBlock)(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject);
typedef void(^AFFailureBlock)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error);
typedef void(^AFDataBlock)(id<AFMultipartFormData> _Nonnull);

@interface TCNViewController ()

@end

@implementation TCNViewController

- (void)viewDidLoad {
  [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  [self adTrackRequestTest];
}

- (void)qxBaseRequest {
  AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
  manager.requestSerializer = [TCNHTTPRequestSerialization serializer];
  AFSuccessBlock successBlock = ^void(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
    NSLog(@"%@", responseObject);
  };
  AFFailureBlock failureBlock = ^void(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    NSLog(@"%@", error);
  };
  [manager GET:@"https://manga.1kxun.mobi/api/home/getNewList"
    parameters:nil
      progress:NULL
       success:successBlock
       failure:failureBlock];
  
}

- (void)passportRequest {
  AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
  manager.requestSerializer = [TCNRSARequestSerialization serializer];
  NSDictionary *dict = @{@"type" : @"1",
                         @"id" : @"2155979",
                         @"app_key" : @"b7b26b9ff13f9ece6de8488978117082",
                         @"password" : @"aaaa"};
  AFSuccessBlock successBlock = ^void(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
    NSLog(@"%@", responseObject);
  };
  AFFailureBlock failureBlock = ^void(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    NSLog(@"%@", error);
  };
  [manager POST:@"http://game.center.1kxun.mobi/api/accounts/login"
     parameters:dict
       progress:NULL
        success:successBlock
        failure:failureBlock];
}

- (void)autoDataCenterRequest {
  TCNAutoDataCenterManager *manager = [TCNAutoDataCenterManager manager];
  manager.requestSerializer = [TCNHTTPRequestSerialization serializer];
  AFSuccessBlock successBlock = ^void(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
    NSLog(@"%@", responseObject);
  };
  AFFailureBlock failureBlock = ^void(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    NSLog(@"%@", error);
  };
  [manager GET:@"https://manga.1kxun.mobi/api/home/getNewList"
    parameters:nil
      progress:NULL
       success:successBlock
       failure:failureBlock];
  
  //取消就执行cancel就行
  //[task cancel];
}

- (void)adTrackRequestTest {
  TCNAutoDataCenterManager *manager = [TCNAutoDataCenterManager manager];
  manager.requestSerializer = [TCNHTTPTrackRequestSerialization serializer];
  AFSuccessBlock successBlock = ^void(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
    NSLog(@"%@", responseObject);
  };
  AFFailureBlock failureBlock = ^void(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    NSLog(@"%@", error);
  };
  [manager POST:@"http://tcad.wedolook.com/api/sites"
     parameters:nil
       progress:nil
        success:successBlock
        failure:failureBlock];
}

- (void)postTest {
  AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
  NSString *testStr = @"testDatatestDatatestDatatestDatatestDatatestData";
  NSData *testData = [testStr dataUsingEncoding:NSUTF8StringEncoding];
  AFSuccessBlock successBlock = ^void(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
    NSLog(@"%@", responseObject);
  };
  AFFailureBlock failureBlock = ^void(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    NSLog(@"%@", error);
  };
  AFDataBlock dataBlock = ^void(id<AFMultipartFormData> FormData) {
    [FormData appendPartWithHeaders:nil body:testData];
  };
  [manager POST:@"http://game.center.1kxun.mobi/api/accounts/login"
     parameters:nil
constructingBodyWithBlock:dataBlock
       progress:NULL
        success:successBlock
        failure:failureBlock];
}

@end
