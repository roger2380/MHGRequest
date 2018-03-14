//
//  TCNNewTrackPostRequestSerialization.m
//  AFNetworking
//
//  Created by zhou on 2018/3/14.
//

#import "TCNMangaNewTrackPostRequestSerialization.h"
#import <TCNDeviceInfo/TCNDeviceInfo.h>
#import <TCNDataEncoding/NSData+Compress.h>

@implementation TCNMangaNewTrackPostRequestSerialization

- (NSURLRequest *)requestBySerializingRequest:(NSURLRequest *)request
                               withParameters:(id)parameters
                                        error:(NSError *__autoreleasing *)error {
  NSParameterAssert(request);
  
  BOOL contain = [self.HTTPMethodsEncodingParametersInURI containsObject:[[request HTTPMethod] uppercaseString]];
  
  if (!contain && ([parameters isKindOfClass:[NSDictionary class]] || !parameters)) {
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    NSMutableDictionary *resultDic = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [resultDic setObject:[TCNDeviceInfo universalNewTrackParameters] forKey:@"device"];
    [resultDic setObject:@((NSInteger)[NSDate date].timeIntervalSince1970) forKey:@"timestamp"];
    if (![mutableRequest valueForHTTPHeaderField:@"Content-Type"]) {
      [mutableRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    NSData *body = [NSJSONSerialization dataWithJSONObject:[resultDic copy] options:0 error:nil];
    mutableRequest.HTTPBody = [body zlib];
    return [mutableRequest copy];
  } else {
    return [super requestBySerializingRequest:request withParameters:parameters error:error];
  }
}

@end
