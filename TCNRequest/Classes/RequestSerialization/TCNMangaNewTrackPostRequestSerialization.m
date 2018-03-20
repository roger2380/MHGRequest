//
//  TCNNewTrackPostRequestSerialization.m
//  AFNetworking
//
//  Created by zhou on 2018/3/14.
//

#import "TCNMangaNewTrackPostRequestSerialization.h"
#import <TCNDeviceInfo/TCNDeviceInfo.h>
#import <TCNDataEncoding/NSData+Compress.h>
#import <TCNDataEncoding/TCNNSString+UrlEncode.h>

@implementation TCNMangaNewTrackPostRequestSerialization

+ (instancetype)serializer {
  return [self serializerWithSignKey:nil];
}

+ (instancetype)serializerWithSignKey:(NSString *)signKey {
  return [[self alloc] initWithSignKey:signKey];
}

- (instancetype)initWithSignKey:(NSString *)signKey {
  if (self = [super init]) {
    _signKey = [signKey copy];
  }
  
  return self;
}

- (NSURLRequest *)requestBySerializingRequest:(NSURLRequest *)request
                               withParameters:(id)parameters
                                        error:(NSError *__autoreleasing *)error {
  NSParameterAssert(request);
  
  NSMutableURLRequest *mutableRequest = [request mutableCopy];
  
  BOOL contain = [self.HTTPMethodsEncodingParametersInURI containsObject:[[request HTTPMethod] uppercaseString]];
  if (!contain && ([parameters isKindOfClass:[NSDictionary class]] || !parameters)) {
    NSMutableDictionary *resultDic = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [resultDic setObject:[TCNDeviceInfo universalNewTrackParameters] forKey:@"device"];
    [resultDic setObject:@((NSInteger)[NSDate date].timeIntervalSince1970) forKey:@"timestamp"];
    if (![mutableRequest valueForHTTPHeaderField:@"Content-Type"]) {
      [mutableRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    NSData *body = [NSJSONSerialization dataWithJSONObject:[resultDic copy] options:0 error:nil];
    mutableRequest.HTTPBody = [body zlib];
  } else {
    mutableRequest = [[super requestBySerializingRequest:request withParameters:parameters error:error] mutableCopy];
  }
  
  if (self.signKey.length == 0) return [mutableRequest copy];
  
  NSString *sign = nil;
  NSMutableDictionary *queryParames = [[[self class] getParamsFromURL:mutableRequest.URL] copy];
  sign = [[self class] sign:mutableRequest.URL params:queryParames siginKey:self.signKey];
  NSString *signQuery = [NSString stringWithFormat:@"sign=%@", AFPercentEscapedStringFromString(sign)];
  mutableRequest.URL = [NSURL URLWithString:[[mutableRequest.URL absoluteString] stringByAppendingFormat:mutableRequest.URL.query ? @"&%@" : @"?%@", signQuery]];
  return [mutableRequest copy];
}

+ (NSDictionary *)getParamsFromURL:(NSURL *)url {
  NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
  NSString *query = url.query;
  NSArray *array = [query componentsSeparatedByString:@"&"];
  for (NSString *s in array) {
    NSArray *a = [s componentsSeparatedByString:@"="];
    if (a.count == 2) {
      [dict setObject:a[1] forKey:a[0]];
    }
  }
  return dict;
}

+ (NSString *)sign:(NSURL *)url params:(NSDictionary *)params siginKey:(NSString *)signKey {
  NSArray *array = [params allKeys];
  NSMutableArray *keys = [[NSMutableArray alloc] initWithArray:array];
  NSArray *sortedKeys = [keys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
  
  NSMutableString *stringForSign = [NSMutableString stringWithString:url.path];
  
  NSMutableArray *paramsArray = [[NSMutableArray alloc] init];
  for (NSString *key in sortedKeys) {
    NSString *stringValue = [NSString stringWithFormat:@"%@", [params objectForKey:key]];
    [paramsArray addObject:[NSString stringWithFormat:@"%@=%@", key, AFPercentEscapedStringFromString(stringValue)]];
  }
  [stringForSign appendString:[paramsArray componentsJoinedByString:@"&"]];
  [stringForSign appendString:signKey];
  return [stringForSign md5];
}


@end
