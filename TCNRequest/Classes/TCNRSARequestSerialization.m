//
//  TCNRSARequestSerialization.m
//  Pods
//
//  Created by zhou on 2017/7/6.
//
//

#import "TCNRSARequestSerialization.h"
#import "TCNHTTPRequestSerialization+Protect.h"
#import <TCNDataEncoding/TCNBase64.h>
#import <TCNDataEncoding/TCNRSA.h>

@implementation TCNRSARequestSerialization

- (void)buildPostBodyWithRequest:(NSMutableURLRequest *)request parameters:(id)parameters {
  int now = (int)[[[NSDate alloc] init] timeIntervalSince1970];
  NSData *data = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:NULL];
  NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  NSData *encrypted = [TCNRSA encrypt:string];
  NSString *base64 = [TCNBase64 encode:encrypted];
  NSString *offsetString = [TCNRSA doOffset:base64 offset:now % 64];
  NSDictionary *newParameters = @{@"s" : [NSNumber numberWithInt:now], @"data" : offsetString};
  [super buildPostBodyWithRequest:request parameters:newParameters];
}

@end
