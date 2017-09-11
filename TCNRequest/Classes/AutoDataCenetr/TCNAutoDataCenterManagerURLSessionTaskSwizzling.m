//
//  TCNAutoDataCenterManagerURLSessionTaskSwizzling.m
//  Pods
//
//  Created by zhou on 2017/9/8.
//
//  这个文件的目的是修改系统NSURLSessionDataTask的cancel行为
//  模块外部不应该使用这个文件中的任何类和方法
//

#import "TCNAutoDataCenterManagerURLSessionTaskSwizzling.h"
#import <objc/runtime.h>

TCNAutoDataCenterManagerURLSessionTaskSwizzlingType TCNADCMURLSessionTaskSwizzlingType;

static inline BOOL TCNAddMethod(Class theClass, SEL selector, Method method) {
  return class_addMethod(theClass, selector,  method_getImplementation(method),  method_getTypeEncoding(method));
}

static inline void TCNSwizzleSelector(Class theClass, SEL originalSelector, SEL swizzledSelector) {
  Method originalMethod = class_getInstanceMethod(theClass, originalSelector);
  Method swizzledMethod = class_getInstanceMethod(theClass, swizzledSelector);
  method_exchangeImplementations(originalMethod, swizzledMethod);
}

static const void *TCNADCMCancelURLSessionTaskSubTasksKey = &TCNADCMCancelURLSessionTaskSubTasksKey;

@interface _TCNAutoDataCenterManagerURLSessionTaskSwizzling : NSObject

@property (nonatomic, strong) NSArray<NSURLSessionTask *> *tcnadcmSubTasks;

@end

@implementation TCNAutoDataCenterManagerURLSessionTaskSwizzling

+ (void)load {
  if (NSClassFromString(@"NSURLSessionDataTask")) {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.google.com"]];
    NSURLSessionDataTask *localDataTask = [session dataTaskWithRequest:request];
    IMP originalTCNADCMCancelIMP = method_getImplementation(class_getInstanceMethod([self class], @selector(tcnadcmCancel)));
    Class currentClass = [localDataTask class];
    
    while (class_getInstanceMethod(currentClass, @selector(cancel))) {
      Class superClass = [currentClass superclass];
      IMP classCancelIMP = method_getImplementation(class_getInstanceMethod(currentClass, @selector(cancel)));
      IMP superclassCancelIMP = method_getImplementation(class_getInstanceMethod(superClass, @selector(cancel)));
      if (classCancelIMP != superclassCancelIMP) {
        if (classCancelIMP != originalTCNADCMCancelIMP) {
          if ([self swizzleCancelMethodForClass:currentClass]) {
            TCNADCMURLSessionTaskSwizzlingType = TCNAutoDataCenterManagerURLSessionTaskSwizzlingTypeSuccessful;
          } else {
            TCNADCMURLSessionTaskSwizzlingType = TCNAutoDataCenterManagerURLSessionTaskSwizzlingTypeFailed;
          }
        }
        break;
      }
      currentClass = [currentClass superclass];
    }
    
    [localDataTask cancel];
    [session finishTasksAndInvalidate];
  }
}

+ (BOOL)swizzleCancelMethodForClass:(Class)theClass {
  Method tcnadcmCancelMethod = class_getInstanceMethod(self, @selector(tcnadcmCancel));
  Method tcnadcmCancelSubTasksMethod = class_getInstanceMethod(self, @selector(tcnadcmCancelSubTasks));
  Method tcnadcmSetSubTasks = class_getInstanceMethod(self, @selector(setTcnadcmSubTasks:));
  Method tcnadcmGetSubTasks = class_getInstanceMethod(self, @selector(tcnadcmSubTasks));
  
  BOOL success = TCNAddMethod(theClass, @selector(setTcnadcmSubTasks:), tcnadcmSetSubTasks);
#ifdef DEBUG
  NSAssert(success, @"为NSURLSessionDataTask添加setTcnadcmSubTasks:方法时发生错误");
#else
  if (!success) return NO;
#endif
  
  success = TCNAddMethod(theClass, @selector(tcnadcmSubTasks), tcnadcmGetSubTasks);
#ifdef DEBUG
  NSAssert(success, @"为NSURLSessionDataTask添加tcnadcmSubTasks方法时发生错误");
#else
  if (!success) return NO;
#endif
  
  success = TCNAddMethod(theClass, @selector(tcnadcmCancelSubTasks), tcnadcmCancelSubTasksMethod);
#ifdef DEBUG
  NSAssert(success, @"为NSURLSessionDataTask添加tcnadcmCancelSubTasks方法时发生错误");
#else
  if (!success) return NO;
#endif
  
  success = TCNAddMethod(theClass, @selector(tcnadcmCancel), tcnadcmCancelMethod);
#ifdef DEBUG
  NSAssert(success, @"为NSURLSessionDataTask添加tcnadcmCancel方法时发生错误");
#else
  if (!success) return NO;
#endif
  
  TCNSwizzleSelector(theClass, @selector(cancel), @selector(tcnadcmCancel));
  
  return YES;
}

- (void)tcnadcmCancel {
  BOOL existTcnadcmCancel = [self respondsToSelector:@selector(tcnadcmCancel)];
  BOOL existTcnadcmCancelSubTasks = [self respondsToSelector:@selector(tcnadcmCancelSubTasks)];
  
#ifdef DEBUG
  NSAssert(existTcnadcmCancel, @"调用NSURLSessionDataTask自定义的cancel方法时找不到原始的cancel方法");
  [self tcnadcmCancel];
#else
  if (existTcnadcmCancel) {
    [self tcnadcmCancel];
  } else {
    NSLog(@"调用NSURLSessionDataTask自定义的cancel方法时找不到原始的cancel方法");
  }
#endif
  
#ifdef DEBUG
  NSAssert(existTcnadcmCancelSubTasks, @"调用NSURLSessionDataTask自定义的cancel方法时找不到自定义的tcnadcmCancelSubTasks方法");
  [self tcnadcmCancelSubTasks];
#else
  if (existTcnadcmCancelSubTasks) {
    [self tcnadcmCancelSubTasks];
  } else {
    NSLog(@"调用NSURLSessionDataTask自定义的cancel方法时找不到原始的cancel方法");
  }
#endif
}

- (void)tcnadcmCancelSubTasks {
  BOOL existSubTasks = [self respondsToSelector:@selector(tcnadcmSubTasks)];
#ifdef DEBUG
  NSAssert(existSubTasks, @"调用NSURLSessionDataTask自定义的tcnadcmCancelSubTasks方法时找不到自定义的tcnadcmSubTasks方法");
#else
  if (!existSubTasks) return;
#endif
  
  for (NSURLSessionTask *task in self.tcnadcmSubTasks) {
    [task cancel];
  }
}

- (void)setTcnadcmSubTasks:(NSArray<NSURLSessionTask *> *)tcnadcmSubTasks {
  objc_setAssociatedObject(self, TCNADCMCancelURLSessionTaskSubTasksKey, tcnadcmSubTasks, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray<NSURLSessionTask *> *)tcnadcmSubTasks {
  NSArray<NSURLSessionTask *> *subTasks = objc_getAssociatedObject(self, TCNADCMCancelURLSessionTaskSubTasksKey);
  if (!subTasks) {
    subTasks = @[];
    objc_setAssociatedObject(self, TCNADCMCancelURLSessionTaskSubTasksKey, subTasks, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  }
  return subTasks;
}

@end

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wincomplete-implementation"

@implementation NSURLSessionDataTask (TCNADCMCancel)

@dynamic tcnadcmSubTasks;

@end

#pragma clang diagnostic pop
