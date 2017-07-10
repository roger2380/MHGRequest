//
//  TCNHTTPTrackRequestSerialization.m
//  Pods
//
//  Created by zhou on 2017/7/7.
//
//

#import "TCNHTTPTrackRequestSerialization.h"
#import "TCNHTTPRequestSerialization+Protect.h"
#import <TCNDeviceInfo/TCNDeviceInfo.h>
#include <zlib.h>

@implementation TCNHTTPTrackRequestSerialization

- (void)buildPostBodyWithRequest:(NSMutableURLRequest *)request parameters:(id)parameters {
  if ([parameters isKindOfClass:[NSDictionary class]]) {
    NSMutableDictionary *resultDic = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [resultDic setObject:[TCNDeviceInfo universalAdTrackParameters] forKey:@"device"];
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
    
    NSMutableData *compressedData = [NSMutableData dataWithLength:[body length]];
    z_stream strm;
    strm.next_in = (Bytef *)[body bytes];
    strm.avail_in = (uInt)[body length];
    strm.total_out = 0;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    if (deflateInit(&strm, 7) == Z_OK){
      strm.avail_out = (uInt)[body length];
      strm.next_out = (Bytef *)[compressedData bytes];
      deflate(&strm, Z_FINISH);
      [compressedData setLength:strm.total_out];
    }
    deflateEnd(&strm);
    request.HTTPBody = [NSData dataWithData:compressedData];
  } else {
    // TODO: 补全参数不是字典时的处理逻辑 这种情况比较少见
  }
}

@end
