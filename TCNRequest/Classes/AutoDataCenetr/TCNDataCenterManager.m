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
    documentsDirectory = [documentsDirectory stringByAppendingString:@"/tcnrequest.dataCenters"];
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
  for (TCNDataCenter *originDataCenter in self.dataCenters) {
    if (![originDataCenter.name isEqualToString:dataCenter.name]) {
      [resultArr addObject:originDataCenter];
    }
  }
  [resultArr addObject:dataCenter];
  self.dataCenters = [resultArr copy];
}

- (void)saveConfigurationToCache {
  [NSKeyedArchiver archiveRootObject:self.dataCenters toFile:[[self class] cachePath]];
}

- (void)loadConfigurationFromCache {
  self.dataCenters = [NSKeyedUnarchiver unarchiveObjectWithFile:[[self class] cachePath]];
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
  [self saveConfigurationToCache];
}

@end
