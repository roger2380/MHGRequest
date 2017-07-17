//
//  TCNDataCenterMatchedURLItem.m
//  Pods
//
//  Created by zhou on 2017/7/17.
//
//

#import "TCNDataCenterMatchedURLItem.h"

@implementation TCNDataCenterMatchedURLItem

- (instancetype)initWithDataCenterName:(NSString *)name
                           originalURL:(NSString *)originalURL
                            matchedURL:(NSString *)matchedURL {
  if (name && ![name isKindOfClass:[NSString class]]) return nil;
  if (originalURL && ![originalURL isKindOfClass:[NSString class]]) return nil;
  if (![matchedURL isKindOfClass:[NSString class]] || matchedURL.length == 0) return nil;
  
  if (self = [super init]) {
    _dataCenterName = name;
    _originalURL = originalURL;
    _matchedURL = matchedURL;
  }
  
  return self;
}

- (instancetype)init {
  return nil;
}

@end
