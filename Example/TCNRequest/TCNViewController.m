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

@property (nonatomic, strong) UIButton *sendBtn;

@end

@implementation TCNViewController

- (void)viewDidLoad {
  [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  self.sendBtn = [[UIButton alloc]init];
  self.sendBtn.frame = CGRectMake(50, 50, 50, 50);
  [self.sendBtn setBackgroundColor:[UIColor redColor]];
  [self.sendBtn addTarget:self action:@selector(clickSendBtn) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:self.sendBtn];
  
  NSString *dataCenterConfigurationURL = @"http://tcconfig.1kxun.com/api/configurations/manga_web_lines_conf.json";
  [self loadAutoDataCenterManagerWithConfigurationURL:dataCenterConfigurationURL];
}

- (void)clickSendBtn {
//  [self adTrackRequestTest];
//  [self qxBaseRequest];
  [self autoDataCenterRequest];
//  [self testAutoDataCenterManagerWithURL:@"http://manga.1kxun.mobi/api/home/getNewList"];
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
  void(^successBlock)(id object) = ^void(id object) {
    NSLog(@"%@", object);
  };
  
  void(^failureBlock)(NSError *error) = ^void(NSError *error) {
    NSLog(@"%@", error);
  };
  
  NSURLSessionDataTask *task = [manager autoDataCenterGET:@"https://manga.1kxun.mobi/api/home/getNewList"
                                               parameters:nil
                                                  success:successBlock
                                                  failure:failureBlock];
  
//  // 取消就执行cancel就行
//  [task cancel];
}

- (void)adTrackRequestTest {
  AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
  NSString *signKey = @"testSignKey"; // 服务器给的用于加密的SN验签
  NSString *accessToken = @"testAccessToken"; // 当前登录用户的token,没有登录的时候传空
  manager.requestSerializer = [TCNHTTPTrackRequestSerialization serializerWithSignKey:signKey accessToken:accessToken];
  AFSuccessBlock successBlock = ^void(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
    NSLog(@"%@", responseObject);
  };
  AFFailureBlock failureBlock = ^void(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    NSLog(@"%@", error);
  };
  
  // 自定义的参数,不同的接口会有不同的参数,这里模拟上传广告统计并获取广告配置信息的接口
  NSMutableDictionary<NSString *, NSString *> *parameters = [[NSMutableDictionary alloc]initWithCapacity:4];
  [parameters setObject:@"5f0eaa7576c84b551e932c7f8e23b7e0e10e8fec" forKey:@"key"];
  
  [manager POST:@"http://tcad.wedolook.com/api/sites"
     parameters:[parameters copy]
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

- (void)loadAutoDataCenterManagerWithConfigurationURL:(NSString *)url {
  [[TCNDataCenterManager defaultManager] loadConfigurationWithURL:url
                                               currentAccessToken:@"sadadscsx54555774"];
}

- (void)testAutoDataCenterManagerWithURL:(NSString *)url {
  TCNAutoDataCenterManager *manager = [TCNAutoDataCenterManager manager];
  NSArray<TCNDataCenterMatchedURLItem *> * resultURLs = [[TCNDataCenterManager defaultManager] urlsMatchedWithOriginURL:url];
  TCNAutoDataCenterSuccessBlock successBlock = ^void(id  _Nullable responseObject) {
    NSLog(@"-------------------");
    NSLog(@"请求成功");
    NSLog(@"原始地址:%@", url);
    for (TCNDataCenterMatchedURLItem *result in resultURLs) {
      NSLog(@"转换后的地址:%@", result.matchedURL);
    }
    NSLog(@"-------------------");
  };
  TCNAutoDataCenterFailureBlock failureBlock = ^void(NSError * _Nonnull error) {
    NSLog(@"-------------------");
    NSLog(@"请求失败");
    NSLog(@"原始地址:%@", url);
    for (TCNDataCenterMatchedURLItem *result in resultURLs) {
      NSLog(@"转换后的地址:%@", result.matchedURL);
    }
    NSLog(@"失败原因:%@", error);
    NSLog(@"-------------------");
  };
  
  NSURLSessionDataTask * task = [manager autoDataCenterGET:url
                                                parameters:nil
                                                   success:successBlock
                                                   failure:failureBlock];
  
//  [task cancel];
}

@end
