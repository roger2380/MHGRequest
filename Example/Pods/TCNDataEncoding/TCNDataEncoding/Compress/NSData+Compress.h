//
//  NSData+Compress.h
//  TCNDataEncoding
//
//  Created by zhou on 2017/8/28.
//  Copyright © 2017年 tangyiyuan. All rights reserved.
//

#import <Foundation/Foundation.h>

//////////////////////////////////////////////////////////////////////////////////////////
// 这部分代码是在google-toolbox-for-mac的GTMNSData+zlib基础上修改而来
// google-toolbox-for-mac的git地址:https://github.com/google/google-toolbox-for-mac.git

FOUNDATION_EXPORT NSString *const TCNNSDataZlibErrorDomain;
FOUNDATION_EXPORT NSString *const TCNNSDataZlibErrorKey;  // NSNumber

typedef NS_ENUM(NSInteger, TCNNSDataZlibError) {
  TCNNSDataZlibErrorGreaterThan32BitsToCompress = 1024,
  // An internal zlib error.
  // TCNNSDataZlibErrorKey will contain the error value.
  // NSLocalizedDescriptionKey may contain an error string from zlib.
  // Look in zlib.h for list of errors.
  TCNNSDataZlibErrorInternal
};

//////////////////////////////////////////////////////////////////////////////////////////

@interface NSData (Compress)

/**
 公司服务器使用的压缩形式.
 服务器那边约定使用gzip的数据都是使用这种方式压缩/解压的
 所以和公司服务器通讯使用gzip压缩的数据都应该使用这个方法压缩.
 */
- (NSData *)zlib;

- (NSData *)zlibWithError:(NSError **)error;


/**
 标准的gzip压缩方式.
 但是公司的服务器并没有使用这种方式.
 除非未来出现某些特殊情况.
 一般情况下用不到这个方法.
 */
- (NSData *)gzip;

- (NSData *)gzipWithError:(NSError **)error;

@end
