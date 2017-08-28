//
//  NSString+JavaScriptString.h
//  TCNDataEncoding
//
//  Created by zhou on 2017/7/26.
//  Copyright © 2017年 tangyiyuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (JavaScriptString)


/**
 将当前字符串转换为JavaScript的字符串字面量的形式
 例如
 
 |-----------------|
 |sdsdwds          |
 |ssdwwq           |
 |-----------------|
 
 编码后将变为
 
 |-----------------|
 |"sdsdwds\nssdwwq"|
 |-----------------|
 */
@property (nonatomic, readonly, copy) NSString *javaScriptLiteral;

@end
