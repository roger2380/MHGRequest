//
//  TCNDataCenterManager.m
//  Pods
//
//  Created by zhou on 2017/7/6.
//
//

#import "TCNDataCenterManager.h"
#import <AFNetworking/AFHTTPSessionManager.h>
#import "TCNDataCenter.h"
#import "TCNAutoDataCenterManager.h"
#import <TCNDeviceInfo/TCNDeviceInfo.h>
#import <TCNDataEncoding/TCNNSString+UrlEncode.h>

static NSString *TCNDataCenterManagerPriorityUserdefaultsKey = @"com.TCNRequest.DataCenterPriorityUserdefaultsKey";
static NSString *FirstFolderName = @"tcnrequest";
static NSString *SecondFolderName = @"dataCenters";
static NSString *TCNDataCenterSaveFileExtension = @"dataCenter";

static NSString *TCNDataCenterManagerDataCentersLock = @"TCNDataCenterManagerDataCentersLock";

static TCNDataCenterManager *shareManager = nil;

@interface TCNDataCenterManager() {
  NSArray<TCNDataCenter *> *_dataCenters;
}

@property (nonatomic, strong) NSArray<TCNDataCenter *> *dataCenters;
@property (nonatomic, readonly, strong) NSRecursiveLock *dataCentersLock;

@property (nonatomic, readonly, copy) TCNDCMCGetTokenBlock getTokenBlock;

@property (nonatomic, readonly, copy) NSString *configureURLString;

@property (nonatomic, readonly, assign) NSTimeInterval interval;

@property (nonatomic, readonly, copy) NSString *cachePath;

@property (nonatomic, assign) NSTimeInterval lastLoadFromServerSuccessTime;

@property (nonatomic, assign) BOOL isLoadingFromServer;

@end

@implementation TCNDataCenterManager
@dynamic dataCenters;

#pragma mark - 类方法

+ (void)initializationWithConfig:(TCNDataCenterManagerConfigure *)config {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    shareManager = [[self alloc] initWithConfig:config];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      [shareManager loadConfigurationFromServer];
    });
  });
}

+ (NSArray<TCNDataCenterMatchedURLItem *> *)urlsMatchedWithOriginURL:(NSString *)url {
  return [shareManager urlsMatchedWithOriginURL:url];
}

+ (void)requestSuccessWithItem:(TCNDataCenterMatchedURLItem *)item {
  [shareManager requestSuccessWithItem:item];
}

#pragma mark - 实例方法

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithConfig:(TCNDataCenterManagerConfigure *)config {
  BOOL success = NO;
  NSMutableArray<TCNDataCenter *> *resultArr = [[NSMutableArray alloc] init];
  NSString *documentsDirectory = nil;
  
  NSFileManager *manager = [NSFileManager defaultManager];
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  documentsDirectory = [paths objectAtIndex:0];
  documentsDirectory = [documentsDirectory stringByAppendingPathComponent:FirstFolderName];
  documentsDirectory = [documentsDirectory stringByAppendingPathComponent:SecondFolderName];
  documentsDirectory = [documentsDirectory stringByAppendingPathComponent:[config.configureURLString md5]];
  BOOL isDir = NO;
  BOOL isDirExist = [manager fileExistsAtPath:documentsDirectory isDirectory:&isDir];
  
  if (!isDirExist) {
    success = [manager createDirectoryAtPath:documentsDirectory
                 withIntermediateDirectories:YES
                                  attributes:nil
                                       error:nil];
#ifdef DEBUG
    NSAssert(success, @"创建存放dataCenter数据文件夹失败");
#endif
  } else if (isDir) {
    success = YES;
    
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:documentsDirectory] objectEnumerator];
    NSMutableDictionary<NSString *, TCNDataCenter *> *allDataCenter = [[NSMutableDictionary alloc] init];
    NSString* fileName;
    
    while ((fileName = [childFilesEnumerator nextObject]) != nil) {
      if (![[fileName pathExtension] isEqualToString:TCNDataCenterSaveFileExtension]) continue;
      NSString* fileAbsolutePath = [documentsDirectory stringByAppendingPathComponent:fileName];
      if (![manager fileExistsAtPath:fileAbsolutePath]) continue;
      TCNDataCenter *dataCenter = [NSKeyedUnarchiver unarchiveObjectWithFile:fileAbsolutePath];
      if (![dataCenter isKindOfClass:[TCNDataCenter class]]) continue;
      [allDataCenter setObject:dataCenter forKey:dataCenter.name];
    }
    
    NSArray<NSString *> *dataCenterPriorityArr = [[NSUserDefaults standardUserDefaults] objectForKey:TCNDataCenterManagerPriorityUserdefaultsKey];
    if ([dataCenterPriorityArr isKindOfClass:[NSArray class]] && dataCenterPriorityArr.count > 0) {
      for (NSString *dataCenterName in dataCenterPriorityArr) {
        TCNDataCenter *dataCenter = [allDataCenter objectForKey:dataCenterName];
        if (!dataCenter) continue;
        [resultArr addObject:dataCenter];
      }
    } else {
      [resultArr addObjectsFromArray:allDataCenter.allValues];
    }
  } else {
    success = NO;
#ifdef DEBUG
    NSAssert(NO, @"创建存放dataCenter数据的文件夹时,名字被某个文件占用了");
#endif
  }
  
  if (!success || !documentsDirectory || documentsDirectory.length == 0) return nil;
  
  if (self = [super init]) {
    _getTokenBlock = [config.getTokenBlock copy];
    _configureURLString = [config.configureURLString copy];
    _interval = config.interval;
    _cachePath = [documentsDirectory copy];
    _dataCenters = [resultArr copy];
    _dataCentersLock = [[NSRecursiveLock alloc] init];
    _dataCentersLock.name = TCNDataCenterManagerDataCentersLock;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
  }
  return self;
}

- (void)loadConfigurationFromServer {
  if (self.isLoadingFromServer) return;
  if ([NSDate date].timeIntervalSince1970 - self.lastLoadFromServerSuccessTime < self.interval) return;
  if (![self.configureURLString isKindOfClass:[NSString class]] || self.configureURLString.length == 0) return;
  
  self.isLoadingFromServer = YES;
  
  NSMutableDictionary *urlParametersDict = [[TCNDeviceInfo universalURLParameters] mutableCopy];
  NSMutableDictionary *headerParametersDict = [[TCNDeviceInfo universalHTTPHeadersParameters] mutableCopy];
  
  if (self.getTokenBlock) {
     NSString *token = self.getTokenBlock();
    if ([token isKindOfClass:[NSString class]] && token.length > 0) {
      [urlParametersDict setObject:token forKey:@"access_token"];
      [urlParametersDict setObject:token forKey:@"_token"];
      [headerParametersDict setObject:token forKey:@"Access-Token"];
    }
  }
  
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // 添加URL通用参数
  
  NSString *resultURLString = self.configureURLString;
  NSString *query = AFQueryStringFromParameters(urlParametersDict);
  
  if ([NSURL URLWithString:resultURLString].query) {
    resultURLString = [resultURLString stringByAppendingFormat:@"&%@", query];
  } else {
    resultURLString = [resultURLString stringByAppendingFormat:@"?%@", query];
  }
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // 添加Header通用参数
  
  TCNAutoDataCenterManager *manager = [TCNAutoDataCenterManager manager];
  
  for (NSString *key in headerParametersDict) {
    NSString *value = [headerParametersDict objectForKey:key];
    
    [manager.requestSerializer setValue:value forHTTPHeaderField:key];
  }
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  [manager autoDataCenterGET:resultURLString
                  parameters:nil
                     success:^(id  _Nullable responseObject) {
                       self.isLoadingFromServer = NO;
                       if (![responseObject isKindOfClass:[NSDictionary class]]) return;
                       NSString *status = [responseObject objectForKey:@"status"];
                       if (![status isKindOfClass:[NSString class]]) return;
                       if (![status isEqualToString:@"success"]) return;
                       NSArray<NSDictionary *> *arr = [responseObject objectForKey:@"data"];
                       if (![arr isKindOfClass:[NSArray class]]) return;
                       [self loadConfigurationWithArray:arr];
                       self.lastLoadFromServerSuccessTime = [NSDate date].timeIntervalSince1970;
                     }
                     failure:nil];
}

- (void)loadConfigurationWithArray:(NSArray<NSDictionary *> *)dataCenterConfigs {
  if (![dataCenterConfigs isKindOfClass:[NSArray class]]) return;
  if (dataCenterConfigs.count == 0) return;
  
  NSMutableSet<NSString *> *resultDataCenterNameSet = [[NSMutableSet alloc]initWithCapacity:dataCenterConfigs.count];
  NSMutableArray<TCNDataCenter *> *resultArray = [NSMutableArray arrayWithCapacity:dataCenterConfigs.count];
  NSMutableArray<TCNDataCenter *> *newDataCenters = [NSMutableArray arrayWithCapacity:dataCenterConfigs.count];
  for (NSDictionary *dataCenterConfig in dataCenterConfigs) {
    TCNDataCenter *dataCenter = [[TCNDataCenter alloc]initWithDictionary:dataCenterConfig];
    if (!dataCenter) continue;
    [newDataCenters addObject:dataCenter];
  }
  
  for (TCNDataCenter *oldDataCenter in self.dataCenters) {
    TCNDataCenter *needRemoveNewDataCenter = nil;
    for (TCNDataCenter *newDataCenter in newDataCenters) {
      if ([oldDataCenter.name isEqualToString:newDataCenter.name]) {
        if (![resultDataCenterNameSet containsObject:newDataCenter.name]) {
          [resultArray addObject:newDataCenter];
          [resultDataCenterNameSet addObject:newDataCenter.name];
        }
        needRemoveNewDataCenter = newDataCenter;
        break;
      }
    }
    if (!needRemoveNewDataCenter) continue;
    [newDataCenters removeObject:needRemoveNewDataCenter];
  }
  
  for (TCNDataCenter *newDataCenter in newDataCenters) {
    if (![resultDataCenterNameSet containsObject:newDataCenter.name]) {
      [resultArray addObject:newDataCenter];
      [resultDataCenterNameSet addObject:newDataCenter.name];
    }
  }
  
  self.dataCenters = [resultArray copy];
  [self saveConfigurationToCache];
}

- (void)saveConfigurationToCache {
  if (self.cachePath) {
    NSString *fileName, *path;
    for (TCNDataCenter *dataCenter in self.dataCenters) {
      fileName = [NSString stringWithFormat:@"%@.%@", dataCenter.name, TCNDataCenterSaveFileExtension];
      path = [self.cachePath stringByAppendingPathComponent:fileName];
      [NSKeyedArchiver archiveRootObject:dataCenter toFile:path];
    }
  }
  [self saveDataCenterPriority];
}

- (void)saveDataCenterPriority {
  NSMutableArray<NSString *> *dataCenterPriorityArr = [NSMutableArray arrayWithCapacity:[self.dataCenters count]];
  for (TCNDataCenter *dataCenter in self.dataCenters) {
    [dataCenterPriorityArr addObject:dataCenter.name];
  }
  [[NSUserDefaults standardUserDefaults]setObject:[dataCenterPriorityArr copy]
                                           forKey:TCNDataCenterManagerPriorityUserdefaultsKey];
}

- (NSArray<TCNDataCenterMatchedURLItem *> *)urlsMatchedWithOriginURL:(NSString *)originUrl {
  NSMutableArray<TCNDataCenterMatchedURLItem *> *results = [[NSMutableArray alloc] init];
  for (TCNDataCenter *dataCenetr in self.dataCenters) {
    TCNDataCenterMatchedURLItem *item = [dataCenetr urlsMatchedWithOriginURL:originUrl];
    if (item) {
      [results addObject:item];
    }
  }
  return [results copy];
}

- (void)requestSuccessWithItem:(nonnull TCNDataCenterMatchedURLItem *)item {
  if (self.dataCenters.count < 2) return;
  if (![item.dataCenterName isKindOfClass:[NSString class]] || item.dataCenterName.length == 0) return;
  if ([self.dataCenters.firstObject.name isEqualToString:item.dataCenterName]) return;
  TCNDataCenter *preferentialDataCenter = nil;
  NSMutableArray<TCNDataCenter *> *resultArr = [[NSMutableArray alloc]initWithArray:self.dataCenters];
  for (TCNDataCenter *dataCenter in resultArr) {
    if ([dataCenter.name isEqualToString:item.dataCenterName]) {
      preferentialDataCenter = dataCenter;
      break;
    }
  }
  if (!preferentialDataCenter) return;
  [resultArr removeObject:preferentialDataCenter];
  [resultArr insertObject:preferentialDataCenter atIndex:0];
  self.dataCenters = [resultArr copy];
  [self saveDataCenterPriority];
}

#pragma mark - 响应广播的方法

- (void)applicationDidBecomeActive {
  [self loadConfigurationFromServer];
}

#pragma mark - set and get

- (void)setDataCenters:(NSArray<TCNDataCenter *> *)dataCenters {
  [self.dataCentersLock lock];
  if (_dataCenters != dataCenters) {
    _dataCenters = dataCenters;
  }
  [self.dataCentersLock unlock];
}

- (NSArray<TCNDataCenter *> *)dataCenters {
  NSArray<TCNDataCenter *> *tResult = nil;
  [self.dataCentersLock lock];
  tResult = _dataCenters;
  [self.dataCentersLock unlock];
  return tResult;
}

@end
