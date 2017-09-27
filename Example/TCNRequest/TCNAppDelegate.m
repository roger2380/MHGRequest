//
//  TCNAppDelegate.m
//  TCNRequest
//
//  Created by 周高举 on 07/06/2017.
//  Copyright (c) 2017 周高举. All rights reserved.
//

#import "TCNAppDelegate.h"
#import <TCNRequest/TCNAutoDataCenterManager.h>

@implementation TCNAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // Override point for customization after application launch.
  
  TCNAutoDataCenterManagerConfigure *config = [[TCNAutoDataCenterManagerConfigure alloc] init];
  
  // 设置用来获取token的block
  config.getTokenBlock = ^NSString *{
    // 返回测试的Token
    return @"testToken";
  };
  
  // 设置加载多线路配置的url
  config.configureURLString = @"https://tcconfig.1kxun.com/api/configurations/manga_web_lines_conf.json";
  
  // 设置重新从服务器获取多线路配置的最小时间间隔
  config.interval = 3600;
  
  [TCNAutoDataCenterManager initializationWithConfig:config];
  
  return YES;
}

@end
