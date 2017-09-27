//
//  TCNDataCenterManagerConfigure.m
//  Pods
//
//  Created by zhou on 2017/9/27.
//
//

#import "TCNDataCenterManagerConfigure.h"

@implementation TCNDataCenterManagerConfigure

- (instancetype)init {
  if (self = [super init]) {
    _interval = 7200;
  }
  return self;
}

#pragma mark - set and get

- (void)setConfigureURLString:(NSString *)configureURLString {
  if (![configureURLString isKindOfClass:[NSString class]]) return;
  if ([_configureURLString isEqualToString:configureURLString]) return;
  _configureURLString = [configureURLString copy];
}

- (void)setInterval:(NSTimeInterval)interval {
  if (_interval == interval) return;
  if (interval > 0) {
    _interval = interval;
  } else {
    _interval = 0;
  }
}

@end
