#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "TCNAutoDataCenterManager.h"
#import "TCNAutoDataCenterManagerConfigure.h"
#import "TCNAutoDataCenterManagerURLSessionTaskSwizzling.h"
#import "TCNAutoDataCenterStopErrorType.h"
#import "TCNDataCenter.h"
#import "TCNDataCenterManager.h"
#import "TCNDataCenterManagerConfigure.h"
#import "TCNDataCenterMatchedURLItem.h"
#import "TCNRequest.h"
#import "TCNHTTPRequestSerialization+Protect.h"
#import "TCNHTTPRequestSerialization.h"
#import "TCNHTTPTrackRequestSerialization.h"
#import "TCNHTTPZhanqiTrackRequestSerialization.h"
#import "TCNMangaNewTrackPostRequestSerialization.h"
#import "TCNPOSTDataRequestSerialization.h"
#import "TCNRSARequestSerialization.h"
#import "TCNJSONAPIResultCheckResponseSerializer.h"

FOUNDATION_EXPORT double TCNRequestVersionNumber;
FOUNDATION_EXPORT const unsigned char TCNRequestVersionString[];

