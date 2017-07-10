//
//  TCNHTTPRequestSerialization.m
//  Pods
//
//  Created by zhou on 2017/7/6.
//
//

#import "TCNHTTPRequestSerialization.h"
#import <TCNDataEncoding/TCNBase64.h>
#import <TCNDataEncoding/TCNNSString+UrlEncode.h>
#import <TCNDeviceInfo/TCNDeviceInfo.h>

@interface TCNHTTPRequestSerialization ()

@property (nonatomic, strong) NSString *signKey;

@property (nonatomic, strong) NSString *accessToken;

- (instancetype)initWithSignKey:(NSString *)signKey accessToken:(NSString *)accessToken;

- (void)buildPostBodyWithRequest:(NSMutableURLRequest *)request parameters:(id)parameters;

@end

@implementation TCNHTTPRequestSerialization

+ (instancetype)serializer {
  return [self serializerWithSignKey:nil accessToken:nil];
}

+ (instancetype)serializerWithSignKey:(NSString *)signKey {
  return [self serializerWithSignKey:signKey accessToken:nil];
}

+ (instancetype)serializerWithAccessToken:(NSString *)accessToken {
  return [self serializerWithSignKey:nil accessToken:accessToken];
}

+ (instancetype)serializerWithSignKey:(NSString *)signKey accessToken:(NSString *)accessToken {
  return [[self alloc]initWithSignKey:signKey accessToken:accessToken];
}

- (instancetype)initWithSignKey:(NSString *)signKey accessToken:(NSString *)accessToken {
  self = [super init];
  if (self) {
    NSDictionary<NSString *, NSString *> *universalParameters = [TCNDeviceInfo universalHTTPHeadersParameters];
    for (NSString *key in universalParameters) {
      NSString *value = [universalParameters objectForKey:key];
      
      [self setValue:value forHTTPHeaderField:key];
    }
    
    if ([accessToken isKindOfClass:[NSString class]] && accessToken.length > 0) {
      [self setValue:accessToken forHTTPHeaderField:@"Access-Token"];
      _accessToken = accessToken;
    }
    if ([signKey isKindOfClass:[NSString class]] && signKey.length > 0) {
      _signKey = signKey;
    }
  }
  return self;
}

- (instancetype)init {
  return [self initWithSignKey:nil accessToken:nil];
}

- (NSURLRequest *)requestBySerializingRequest:(NSURLRequest *)request
                               withParameters:(id)parameters
                                        error:(NSError *__autoreleasing *)error
{
  NSParameterAssert(request);
  
  NSMutableURLRequest *mutableRequest = [request mutableCopy];
  
  [self.HTTPRequestHeaders enumerateKeysAndObjectsUsingBlock:^(id field, id value, BOOL * __unused stop) {
    if (![request valueForHTTPHeaderField:field]) {
      [mutableRequest setValue:value forHTTPHeaderField:field];
    }
  }];
  
  NSString *query = nil;
  BOOL contain = [self.HTTPMethodsEncodingParametersInURI containsObject:[[request HTTPMethod] uppercaseString]];
  NSMutableDictionary<NSString *, NSString *> *dict = [[NSMutableDictionary alloc]
                                                        initWithDictionary:[TCNDeviceInfo universalURLParameters]];
  if ([self.accessToken isKindOfClass:[NSString class]] && self.accessToken.length > 0) {
    [dict setObject:self.accessToken forKey:@"access_token"];
    [dict setObject:self.accessToken forKey:@"_token"];
  }
  if (contain && parameters) {
    [dict addEntriesFromDictionary:parameters];
  }
  
  if (self.signKey.length != 0) { //需要验签
    NSString *sign = nil;
    NSMutableDictionary *mDict = [dict mutableCopy];
    NSDictionary *paramesFromURL = [[self class] getParamsFromURL:request.URL];
    if (paramesFromURL) {
      [mDict addEntriesFromDictionary:paramesFromURL];
    }
    sign = [[self class] sign:mutableRequest.URL params:mDict siginKey:self.signKey];
    [dict setObject:sign forKey:@"sign"];
  }
  
  query = AFQueryStringFromParameters(dict);
  if (query && query.length > 0) {
    mutableRequest.URL = [NSURL URLWithString:[[mutableRequest.URL absoluteString] stringByAppendingFormat:mutableRequest.URL.query ? @"&%@" : @"?%@", query]];
  }
  
  if (!contain) { //POST之类 组织body
    [self buildPostBodyWithRequest:mutableRequest parameters:parameters];
  }
  
  return mutableRequest;
}

- (void)buildPostBodyWithRequest:(NSMutableURLRequest *)request parameters:(id)parameters {
  NSString *query = nil;
  if (parameters) {
    query = AFQueryStringFromParameters(parameters);
  }
  if (![request valueForHTTPHeaderField:@"Content-Type"]) {
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
  }
  [request setHTTPBody:[query dataUsingEncoding:self.stringEncoding]];
}

//获取URL上面原来的参数
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
