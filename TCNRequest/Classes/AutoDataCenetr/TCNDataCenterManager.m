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

static NSString *TCNDataCenterManagerPriorityUserdefaultsKey = @"com.TCNRequest.DataCenterPriorityUserdefaultsKey";
static NSString *TCNDataCenterSaveFileExtension = @"dataCenter";

@interface TCNDataCenterManager()

@property (nonatomic, strong) NSArray<TCNDataCenter *> *dataCenters;

@end

@implementation TCNDataCenterManager

+ (instancetype)defaultManager {
  static TCNDataCenterManager *manager;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    manager = [[TCNDataCenterManager alloc] init];
  });
  return manager;
}

- (id)init {
  self = [super init];
  if (self) {
    [self loadConfigurationFromCache];
  }
  return self;
}

+ (NSString *)cachePath {
  static NSString *documentsDirectory;
  static dispatch_once_t documentsDirectoryOnceToken;
  dispatch_once(&documentsDirectoryOnceToken, ^{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDirectory = [paths objectAtIndex:0];
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"tcnrequest"];
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"dataCenters"];
    NSFileManager* manager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isDirExist = [manager fileExistsAtPath:documentsDirectory isDirectory:&isDir];
    
#ifdef DEBUG
    if (!isDirExist) {
      BOOL success = [manager createDirectoryAtPath:documentsDirectory
                        withIntermediateDirectories:YES
                                         attributes:nil
                                              error:nil];
      NSAssert(success, @"创建存放dataCenter数据文件夹失败");
    } else {
      NSAssert(isDir, @"创建存放dataCenter数据的文件夹时,名字被某个文件占用了");
    }
#else
    if (!isDirExist) {
      [manager createDirectoryAtPath:documentsDirectory
         withIntermediateDirectories:YES
                          attributes:nil
                               error:nil];
    }
#endif
  });
  return documentsDirectory;
}

- (void)loadConfigurationWithURL:(NSString *)url
              currentAccessToken:(NSString *)token {
  if (![url isKindOfClass:[NSString class]] || url.length == 0) return;
  
  NSString *resultURL = url;
  NSMutableDictionary<NSString *, NSString *> *dict = [[NSMutableDictionary alloc]
                                                       initWithDictionary:[TCNDeviceInfo universalURLParameters]];
  
  if ([token isKindOfClass:[NSString class]] && token.length > 0) {
    [dict setObject:token forKey:@"access_token"];
    [dict setObject:token forKey:@"_token"];
  }
  
  NSString *query = AFQueryStringFromParameters(dict);
  if (query && query.length > 0) {
    resultURL = [resultURL stringByAppendingFormat:[NSURL URLWithString:resultURL].query ? @"&%@" : @"?%@", query];
  }
  
  TCNAutoDataCenterManager *manager = [TCNAutoDataCenterManager manager];
  
  [manager autoDataCenterGET:resultURL
                  parameters:nil
                     success:^(id  _Nullable responseObject) {
                       if (![responseObject isKindOfClass:[NSDictionary class]]) return;
                       NSString *status = [responseObject objectForKey:@"status"];
                       if (![status isKindOfClass:[NSString class]]) return;
                       if (![status isEqualToString:@"success"]) return;
                       NSArray<NSDictionary *> *arr = [responseObject objectForKey:@"data"];
                       if (![arr isKindOfClass:[NSArray class]]) return;
                       [self loadConfigurationWithArray:arr];
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
  NSString *fileName, *path;
  for (TCNDataCenter *dataCenter in self.dataCenters) {
    fileName = [NSString stringWithFormat:@"%@.%@", dataCenter.name, TCNDataCenterSaveFileExtension];
    path = [[[self class] cachePath] stringByAppendingPathComponent:fileName];
    [NSKeyedArchiver archiveRootObject:dataCenter toFile:path];
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

- (void)loadConfigurationFromCache {
  NSFileManager* manager = [NSFileManager defaultManager];
  NSString *folderPath = [[self class] cachePath];
  if (![manager fileExistsAtPath:folderPath]) return;
  NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
  NSMutableDictionary<NSString *, TCNDataCenter *> *allDataCenter = [[NSMutableDictionary alloc]init];
  NSString* fileName;
  while ((fileName = [childFilesEnumerator nextObject]) != nil) {
    if (![[fileName pathExtension] isEqualToString:TCNDataCenterSaveFileExtension]) continue;
    NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
    if (![manager fileExistsAtPath:fileAbsolutePath]) continue;
    TCNDataCenter *dataCenter = [NSKeyedUnarchiver unarchiveObjectWithFile:fileAbsolutePath];
    if (!dataCenter) continue;
    [allDataCenter setObject:dataCenter forKey:dataCenter.name];
  }
  NSArray<NSString *> *dataCenterPriorityArr = [[NSUserDefaults standardUserDefaults]objectForKey:TCNDataCenterManagerPriorityUserdefaultsKey];
  NSMutableArray<TCNDataCenter *> *resultArr = [[NSMutableArray alloc]initWithCapacity:allDataCenter.count];
  if ([dataCenterPriorityArr isKindOfClass:[NSArray class]] && dataCenterPriorityArr.count > 0) {
    for (NSString *dataCenterName in dataCenterPriorityArr) {
      TCNDataCenter *dataCenter = [allDataCenter objectForKey:dataCenterName];
      if (!dataCenter) continue;
      [resultArr addObject:dataCenter];
    }
  } else {
    for (TCNDataCenter *dataCenter in allDataCenter.allValues) {
      [resultArr addObject:dataCenter];
    }
  }
  self.dataCenters = [resultArr copy];
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

@end
