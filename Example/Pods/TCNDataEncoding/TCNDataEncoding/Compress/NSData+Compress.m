//
//  NSData+Compress.m
//  TCNDataEncoding
//
//  Created by zhou on 2017/8/28.
//  Copyright © 2017年 tangyiyuan. All rights reserved.
//

#import "NSData+Compress.h"
#include <zlib.h>

//////////////////////////////////////////////////////////////////////////////////////////
// 这部分代码是在google-toolbox-for-mac的GTMDefines基础上修改而来
// google-toolbox-for-mac的git地址:https://github.com/google/google-toolbox-for-mac.git

#ifndef _TCNDevAssert
// we directly invoke the NSAssert handler so we can pass on the varargs
// (NSAssert doesn't have a macro we can use that takes varargs)
#if !defined(NS_BLOCK_ASSERTIONS)
#define _TCNDevAssert(condition, ...)                                       \
do {                                                                      \
if (!(condition)) {                                                     \
[[NSAssertionHandler currentHandler]                                  \
handleFailureInFunction:(NSString *)                              \
[NSString stringWithUTF8String:__PRETTY_FUNCTION__] \
file:(NSString *)[NSString stringWithUTF8String:__FILE__]  \
lineNumber:__LINE__                                  \
description:__VA_ARGS__];                             \
}                                                                       \
} while(0)
#else // !defined(NS_BLOCK_ASSERTIONS)
#define _TCNDevAssert(condition, ...) do { } while (0)
#endif // !defined(NS_BLOCK_ASSERTIONS)

#endif // _TCNDevAssert

//////////////////////////////////////////////////////////////////////////////////////////
// 这部分代码是在google-toolbox-for-mac的GTMNSData+zlib基础上修改而来
// google-toolbox-for-mac的git地址:https://github.com/google/google-toolbox-for-mac.git

NSString *const TCNNSDataZlibErrorDomain = @"com.truecolor.TCNNSDataZlibErrorDomain";
NSString *const TCNNSDataZlibErrorKey = @"TCNNSDataZlibErrorKey";

static uInt ChunkSize = 1024;

typedef NS_ENUM(NSInteger, TCNCompressionMode) {
  TCNCompressionModeZlib = 0,
  TCNCompressionModeGzip = 1
};

//////////////////////////////////////////////////////////////////////////////////////////

@implementation NSData (Compress)

- (NSData *)zlib {
  NSError *error;
  NSData *result = [self zlibWithError:&error];
  
  if (error) {
    return nil;
  } else {
    return result;
  }
}

- (NSData *)zlibWithError:(NSError *__autoreleasing *)error {
  return [[self class] tcnDataByCompressingBytes:[self bytes]
                                          length:[self length]
                                compressionLevel:Z_DEFAULT_COMPRESSION
                                            mode:TCNCompressionModeZlib
                                           error:error];
}

- (NSData *)gzip {
  NSError *error = nil;
  NSData *result = [self gzipWithError:&error];
  
  if (error) {
    return nil;
  } else {
    return result;
  }
}

- (NSData *)gzipWithError:(NSError *__autoreleasing *)error {
  return [[self class] tcnDataByCompressingBytes:[self bytes]
                                          length:[self length]
                                compressionLevel:Z_DEFAULT_COMPRESSION
                                            mode:TCNCompressionModeGzip
                                           error:error];
}

#pragma mark -

//////////////////////////////////////////////////////////////////////////////////////////
// 这部分代码是在google-toolbox-for-mac的GTMNSData+zlib基础上修改而来
// google-toolbox-for-mac的git地址:https://github.com/google/google-toolbox-for-mac.git

+ (NSData *)tcnDataByCompressingBytes:(const void *)bytes
                               length:(NSUInteger)length
                     compressionLevel:(int)level
                                 mode:(TCNCompressionMode)mode
                                error:(NSError **)error {
  if (!bytes || !length) {
    return nil;
  }
  
#if defined(__LP64__) && __LP64__
  // Don't support > 32bit length for 64 bit, see note in header.
  if (length > UINT_MAX) {
    if (error) {
      *error = [NSError errorWithDomain:TCNNSDataZlibErrorDomain
                                   code:TCNNSDataZlibErrorGreaterThan32BitsToCompress
                               userInfo:nil];
    }
    return nil;
  }
#endif
  
  if (level == Z_DEFAULT_COMPRESSION) {
    // the default value is actually outside the range, so we have to let it
    // through specifically.
  } else if (level < Z_BEST_SPEED) {
    level = Z_BEST_SPEED;
  } else if (level > Z_BEST_COMPRESSION) {
    level = Z_BEST_COMPRESSION;
  }
  
  z_stream strm;
  bzero(&strm, sizeof(z_stream));
  
  int memLevel = 8; // the default
  int windowBits = 15; // the default
  switch (mode) {
    case TCNCompressionModeZlib:
      // nothing to do
      break;
      
    case TCNCompressionModeGzip:
      windowBits += 16; // enable gzip header instead of zlib header
      break;
  }
  int retCode;
  if ((retCode = deflateInit2(&strm, level, Z_DEFLATED, windowBits,
                              memLevel, Z_DEFAULT_STRATEGY)) != Z_OK) {
    // COV_NF_START - no real way to force this in a unittest (we guard all args)
    if (error) {
      NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:retCode]
                                                           forKey:TCNNSDataZlibErrorKey];
      *error = [NSError errorWithDomain:TCNNSDataZlibErrorDomain
                                   code:TCNNSDataZlibErrorInternal
                               userInfo:userInfo];
    }
    return nil;
    // COV_NF_END
  }
  
  // hint the size at 1/4 the input size
  NSMutableData *result = [NSMutableData dataWithCapacity:(length/4)];
  unsigned char output[ChunkSize];
  
  // setup the input
  strm.avail_in = (unsigned int)length;
  strm.next_in = (unsigned char*)bytes;
  
  // loop to collect the data
  do {
    // update what we're passing in
    strm.avail_out = ChunkSize;
    strm.next_out = output;
    retCode = deflate(&strm, Z_FINISH);
    if ((retCode != Z_OK) && (retCode != Z_STREAM_END)) {
      // COV_NF_START - no real way to force this in a unittest
      // (in inflate, we can feed bogus/truncated data to test, but an error
      // here would be some internal issue w/in zlib, and there isn't any real
      // way to test it)
      if (error) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:retCode]
                                                             forKey:TCNNSDataZlibErrorKey];
        *error = [NSError errorWithDomain:TCNNSDataZlibErrorDomain
                                     code:TCNNSDataZlibErrorInternal
                                 userInfo:userInfo];
      }
      deflateEnd(&strm);
      return nil;
      // COV_NF_END
    }
    // collect what we got
    unsigned gotBack = ChunkSize - strm.avail_out;
    if (gotBack > 0) {
      [result appendBytes:output length:gotBack];
    }
    
  } while (retCode == Z_OK);
  
  // if the loop exits, we used all input and the stream ended
  _TCNDevAssert(strm.avail_in == 0,
                @"thought we finished deflate w/o using all input, %u bytes left",
                strm.avail_in);
  _TCNDevAssert(retCode == Z_STREAM_END,
                @"thought we finished deflate w/o getting a result of stream end, code %d",
                retCode);
  
  // clean up
  deflateEnd(&strm);
  
  return result;
}

//////////////////////////////////////////////////////////////////////////////////////////

@end
