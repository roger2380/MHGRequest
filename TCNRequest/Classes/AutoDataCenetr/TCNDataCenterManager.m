//
//  TCNDataCenterManager.m
//  Pods
//
//  Created by zhou on 2017/7/6.
//
//

#import "TCNDataCenterManager.h"
#import <AFNetworking/AFHTTPSessionManager.h>
#import <RegexKitLite/RegexKitLite.h>

@interface TCNDataCenterManager()

@property (nonatomic, strong) NSMutableDictionary *urlRegexs;

@end

@implementation TCNDataCenterManager

+ (instancetype)defaultManager {
  static TCNDataCenterManager *manager;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    manager = [[TCNDataCenterManager alloc] init];
  });
  return manager;
}

- (id)init {
  self = [super init];
  if (self) {
    [self loadConfigurationFromCache];
  }
  return self;
}

- (NSString *)cachePath {
  NSString *documentsDirectory = nil;
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  documentsDirectory = [paths objectAtIndex:0];
  return [documentsDirectory stringByAppendingString:@"/tcrequest.urlregexs"];
}

- (void)loadConfigurationWithURL:(NSString *)url {
  if (url.length == 0) {
    return;
  }
  AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
  [manager GET:url
    parameters:nil
      progress:NULL
       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         NSArray *array = nil;
         array = [responseObject objectForKey:@"data"];
         if ([array isKindOfClass:[NSArray class]]) {
           for (NSDictionary *dict in array) {
             NSString *lineName = [dict objectForKey:@"name"];
             NSArray *rules = [dict objectForKey:@"rules"];
             if (lineName && [rules isKindOfClass:[NSArray class]]) {
               [self appendRegexs:rules forLineName:lineName];
             }
           }
         }
         [self saveConfigurationToCache];
       }
       failure:NULL];
}

- (void)appendRegexs:(NSArray *)regexs forLineName:(NSString *)lineName {
  NSMutableDictionary *dict = [self.urlRegexs objectForKey:lineName];
  if (!dict) {
    dict = [[NSMutableDictionary alloc] init];
    [self.urlRegexs setObject:dict forKey:lineName];
  }
  for (NSString *regex in regexs) {
    NSArray *segments = [regex componentsSeparatedByString:@" "];
    if ([segments count] == 2) {
      [dict setObject:[segments objectAtIndex:1] forKey:[segments objectAtIndex:0]];
    }
  }
}

- (void)saveConfigurationToCache {
  [self.urlRegexs writeToFile:[self cachePath] atomically:YES];
}

- (void)loadConfigurationFromCache {
  NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:[self cachePath]];
  self.urlRegexs = [[NSMutableDictionary alloc] init];
  for (NSString *key in dict.allKeys) {
    NSDictionary *value = [dict objectForKey:key];
    NSMutableDictionary *mdict = [[NSMutableDictionary alloc] initWithDictionary:value];
    [self.urlRegexs setObject:mdict forKey:key];
  }
}

- (NSArray *)urlsMatchedWithOriginURL:(NSString *)originUrl {
  NSMutableArray *results = [[NSMutableArray alloc] init];
  for (NSString *lineName in self.urlRegexs.allKeys) {
    NSDictionary *dict = [self.urlRegexs objectForKey:lineName];
    for (NSString *search in dict.allKeys) {
      NSString *replacement = [dict objectForKey:search];
      NSString *result = [originUrl stringByReplacingOccurrencesOfRegex:search withString:replacement];
      if (![result isEqualToString:originUrl]) {
        [results addObject:result];
      }
    }
  }
  return [results copy];
}

@end
