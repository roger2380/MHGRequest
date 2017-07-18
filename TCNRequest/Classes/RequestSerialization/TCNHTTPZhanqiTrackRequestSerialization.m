//
//  TCNHTTPZhanqiTrackRequestSerialization.m
//  Pods
//
//  Created by zhou on 2017/7/10.
//
//

#import "TCNHTTPZhanqiTrackRequestSerialization.h"
#import "TCNHTTPRequestSerialization+Protect.h"
#import <TCNDeviceInfo/TCNDeviceInfo.h>
#import <TCNDataEncoding/NSData+TCNGzip.h>

@implementation TCNHTTPZhanqiTrackRequestSerialization

- (void)buildPostBodyWithRequest:(NSMutableURLRequest *)request parameters:(id)parameters {
  if ([parameters isKindOfClass:[NSDictionary class]]) {
    NSMutableDictionary *resultDic = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [resultDic setObject:[TCNDeviceInfo universalAdTrackParameters] forKey:@"devices_info"];
    [resultDic setObject:[NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]] forKey:@"timestamp"];
    if ([self.accessToken isKindOfClass:[NSString class]] && self.accessToken.length > 0) {
      [resultDic setObject:self.accessToken forKey:@"access_token"];
    } else {
      [resultDic setObject:@"" forKey:@"access_token"];
    }
    if (![request valueForHTTPHeaderField:@"Content-Type"]) {
      [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    NSData *body = [NSJSONSerialization dataWithJSONObject:[resultDic copy] options:0 error:nil];
    request.HTTPBody = [body gzip];
  } else {
    // TODO: 补全参数不是字典时的处理逻辑 这种情况比较少见
  }
}

@end