//
//  NSString+JavaScriptString.m
//  TCNDataEncoding
//
//  Created by zhou on 2017/7/26.
//  Copyright © 2017年 tangyiyuan. All rights reserved.
//

#import "NSString+JavaScriptString.h"

@implementation NSString (JavaScriptString)

- (NSString *)javaScriptLiteral {
  NSString *resultString = self;
  resultString = [resultString stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
  resultString = [resultString stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"];
  resultString = [resultString stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
  resultString = [resultString stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
  resultString = [resultString stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];
  resultString = [resultString stringByReplacingOccurrencesOfString:@"\t" withString:@"\\t"];
  resultString = [resultString stringByReplacingOccurrencesOfString:@"\b" withString:@"\\b"];
  resultString = [resultString stringByReplacingOccurrencesOfString:@"\f" withString:@"\\f"];
  resultString = [resultString stringByReplacingOccurrencesOfString:@"\v" withString:@"\\v"];
  return [NSString stringWithFormat:@"\"%@\"", resultString];
}

@end
