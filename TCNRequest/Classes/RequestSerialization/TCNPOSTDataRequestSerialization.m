//
//  TCNPOSTDataRequestSerialization.m
//  Pods
//
//  Created by zhou on 2017/9/5.
//
//

#import "TCNPOSTDataRequestSerialization.h"
#import "TCNHTTPRequestSerialization+Protect.h"

@implementation TCNPOSTDataRequestSerialization

- (void)buildPostBodyWithRequest:(NSMutableURLRequest *)request parameters:(id)parameters {
  if ([parameters isKindOfClass:[NSData class]]) {
    request.HTTPBody = parameters;
  } else {
    [super buildPostBodyWithRequest:request parameters:parameters];
  }
}

@end
