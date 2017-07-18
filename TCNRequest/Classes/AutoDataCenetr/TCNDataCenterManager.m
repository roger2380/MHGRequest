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
    
    if (!isDirExist) {
      BOOL success = [manager createDirectoryAtPath:documentsDirectory
                        withIntermediateDirectories:YES
                                         attributes:nil
                                              error:nil];
#if DEBUG
      NSAssert(success, @"创建存放dataCenter数据文件夹失败");
    }

    else {
      NSAssert(isDir, @"创建存放dataCenter数据的文件夹时,名字被某个文件占用了");
#endif
    }
  });
  return documentsDirectory;
}

- (void)loadConfigurationWithURL:(NSString *)url {
  if (![url isKindOfClass:[NSString class]] || url.length == 0) return;
  
  AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
  [manager GET:url
    parameters:nil
      progress:NULL
       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         NSArray *arr = [responseObject objectForKey:@"data"];
         if ([arr isKindOfClass:[NSArray class]]) {
           for (NSDictionary *dic in arr) {
             [self addDataCenter:[[TCNDataCenter alloc] initWithDictionary:dic]];
           }
         }
         [self saveConfigurationToCache];
       }
       failure:NULL];
}

- (void)addDataCenter:(TCNDataCenter *)dataCenter {
  if (![dataCenter isKindOfClass:[TCNDataCenter class]]) return;
  
  NSMutableArray<TCNDataCenter *> *resultArr = [[NSMutableArray alloc] initWithCapacity:[self.dataCenters count] + 1];
  NSInteger newDataCenterIndex = -1;
  for (NSInteger i = 0; i < self.dataCenters.count; i++) {
    TCNDataCenter *originDataCenter = [self.dataCenters objectAtIndex:i];
    if (![originDataCenter.name isEqualToString:dataCenter.name]) {
      [resultArr addObject:originDataCenter];
    } else {
      newDataCenterIndex = i;
    }
  }
  if (newDataCenterIndex >= 0 && newDataCenterIndex < resultArr.count) {
    [resultArr insertObject:dataCenter atIndex:newDataCenterIndex];
  } else {
    [resultArr addObject:dataCenter];
  }
  self.dataCenters = [resultArr copy];
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
  for (NSString *dataCenterName in dataCenterPriorityArr) {
    TCNDataCenter *dataCenter = [allDataCenter objectForKey:dataCenterName];
    if (!dataCenter) continue;
    [resultArr addObject:dataCenter];
    [allDataCenter removeObjectForKey:dataCenterName];
  }
  for (TCNDataCenter *dataCenter in allDataCenter.allValues) {
    [resultArr addObject:dataCenter];
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
