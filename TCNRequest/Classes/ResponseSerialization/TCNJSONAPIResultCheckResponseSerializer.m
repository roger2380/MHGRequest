//
//  TCNJSONAPIResultCheckResponseSerializer.m
//  Pods
//
//  Created by zhou on 2017/9/27.
//
//

#import "TCNJSONAPIResultCheckResponseSerializer.h"

NSString * const TCNJSONAPIRRSErrorDomain = @"TCNJSONAPIResultCheckResponseSerializerErrorDomain";

NSString * const TCNJSONAPIRRSErrorJSONObjectUserInfoKey = @"TCNJSONAPIResultCheckResponseSerializerErrorJSONObjectUserInfoKey";

@implementation TCNJSONAPIResultCheckResponseSerializer

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error {
  NSError *superError = nil;
  id superResponseObject = [super responseObjectForResponse:response data:data error:&superError];
  if (superError) {
    *error = superError;
    return nil;
  } else {
    if ([superResponseObject isKindOfClass:[NSDictionary class]]) {
      NSString *status = [superResponseObject objectForKey:@"status"];
      if ([status isKindOfClass:[NSString class]] && [status isEqualToString:@"success"]) {
        return superResponseObject;
      } else {
        NSDictionary *userInfo = @{TCNJSONAPIRRSErrorJSONObjectUserInfoKey : superResponseObject};
        NSError *resultError = [[NSError alloc] initWithDomain:TCNJSONAPIRRSErrorDomain
                                                          code:TCNJSONAPIRRSErrorCodeStatusIsNotSuccess
                                                      userInfo:userInfo];
        *error = resultError;
        return nil;
      }
    } else {
      NSDictionary *userInfo = @{TCNJSONAPIRRSErrorJSONObjectUserInfoKey : superResponseObject};
      NSError *resultError = [[NSError alloc] initWithDomain:TCNJSONAPIRRSErrorDomain
                                                        code:TCNJSONAPIRRSErrorCodeIsNotDict
                                                    userInfo:userInfo];
      *error = resultError;
      return nil;
    }
  }
}

@end
