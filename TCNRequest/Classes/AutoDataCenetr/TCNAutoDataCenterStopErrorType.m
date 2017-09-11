//
//  TCNAutoDataCenterStopErrorType.m
//  Pods
//
//  Created by zhou on 2017/9/8.
//
//

#import "TCNAutoDataCenterStopErrorType.h"

@implementation TCNAutoDataCenterStopErrorType

- (instancetype)initWithErrorDomain:(NSString *)errorDomain errorCode:(NSInteger)errorCode {
  if (![errorDomain isKindOfClass:[NSString class]] || errorDomain.length == 0) {
    return nil;
  }
  
  if (self = [super init]) {
    _errorDomain = errorDomain;
    _errorCode = errorCode;
  }
  
  return self;
}

- (BOOL)isThisErrorType:(NSError *)error {
  if (![error isKindOfClass:[NSError class]]) {
    return NO;
  }
  if (![error.domain isEqualToString:self.errorDomain]) {
    return NO;
  }
  if (error.code != self.errorCode) {
    return NO;
  }
  
  return YES;
}

@end
