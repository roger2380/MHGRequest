//
//  TCNDataCenter.m
//  Pods
//
//  Created by zhou on 2017/7/13.
//
//

#import "TCNDataCenter.h"
#import <RegexKitLite/RegexKitLite.h>

@interface TCNDataCenter ()

@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *rules;

@property (nonatomic, copy) NSString *name;

@end

@implementation TCNDataCenter

#pragma mark - Lifecycle

- (nullable instancetype)initWithDictionary:(nonnull NSDictionary *)dataCenterDictionary {
  if (![dataCenterDictionary isKindOfClass:[NSDictionary class]]) {
    return nil;
  }
  NSArray<NSString *> *ruleStrs = [dataCenterDictionary objectForKey:@"rules"];
  if (ruleStrs && ![ruleStrs isKindOfClass:[NSArray class]]) {
    return nil;
  }
  NSString *name = [dataCenterDictionary objectForKey:@"name"];
  if (![name isKindOfClass:[NSString class]] || name.length == 0) {
    return nil;
  }
  
  if (self = [super init]) {
    _name = name;
    
    NSMutableDictionary<NSString *, NSString *> *rules = [[NSMutableDictionary alloc]initWithCapacity:[ruleStrs count]];
    for (NSString *ruleStr in ruleStrs) {
      NSArray<NSString *> *keyAndValue = [ruleStr componentsSeparatedByString:@" "];
      if ([keyAndValue count] == 2) {
        [rules setObject:[keyAndValue lastObject] forKey:[keyAndValue firstObject]];
      }
    }
    
    _rules = [rules copy];
  }
  
  return self;
}

- (nullable instancetype)init {
  return nil;
}

#pragma mark - Custom

- (nullable TCNDataCenterMatchedURLItem *)urlsMatchedWithOriginURL:(nonnull NSString *)url {
  if (![url isKindOfClass:[NSString class]]) return nil;
  NSString *resultURL = url;
  for (NSString *key in self.rules) {
    NSString *value = [self.rules objectForKey:key];
    resultURL = [url stringByReplacingOccurrencesOfRegex:key withString:value];
    if (![resultURL isEqualToString:url]) {
      return [[TCNDataCenterMatchedURLItem alloc]initWithDataCenterName:self.name originalURL:url matchedURL:resultURL];
    }
  }
  
  return nil;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeObject:self.name forKey:@"name"];
  [aCoder encodeObject:self.rules forKey:@"rules"];
}


- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
  NSString *name = [aDecoder decodeObjectForKey:@"name"];
  if (![name isKindOfClass:[NSString class]] || name.length == 0) {
    return nil;
  }
  NSDictionary<NSString *, NSString *> *rules = [aDecoder decodeObjectForKey:@"rules"];
  if (rules && ![rules isKindOfClass:[NSDictionary class]]) {
    return nil;
  }
  for (NSString *key in rules) {
    NSString *value = [rules objectForKey:key];
    if (![key isKindOfClass:[NSString class]] || ![value isKindOfClass:[NSString class]]) {
      return nil;
    }
  }
  
  if (self = [super init]) {
    _name = name;
    _rules = rules;
  }
  
  return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
  TCNDataCenter *dataCenter = [[self class] allocWithZone:zone];
  dataCenter.name = self.name;
  dataCenter.rules = [self.rules copy];
  return dataCenter;
}

@end
