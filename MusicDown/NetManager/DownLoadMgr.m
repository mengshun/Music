//
//  DownLoadMgr.m
//  MusicDown
//
//  Created by 孟顺 on 2020/3/19.
//  Copyright © 2020 mengshun. All rights reserved.
//

#import "DownLoadMgr.h"
#import <AFNetworking.h>

static NSString *const kDownLoadMgrSaveKey = @"kDownLoadMgrSaveKey";


@interface DownLoadMgr ()

@property (strong, nonatomic) NSMutableDictionary *downLoadInfoDict;
@property (nonatomic, copy) NSString *downLoadDefaultPath;

@end

@implementation DownLoadMgr

- (void)loadDownInfo
{
    self.downLoadInfoDict = @{}.mutableCopy;
    NSDictionary *info = [[NSUserDefaults standardUserDefaults] objectForKey:kDownLoadMgrSaveKey];
    if ([info isKindOfClass:NSDictionary.class]) {
        [self.downLoadInfoDict addEntriesFromDictionary:info];
    }
}

- (void)save
{
    NSLog(@"保存历史下载");
    if (self.downLoadInfoDict.allValues.count > 0) {
        [self.downLoadInfoDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if ([obj isEqualTo:@(NO)]) {
                [self.downLoadInfoDict removeObjectForKey:key];
            }
        }];
        [[NSUserDefaults standardUserDefaults] setObject:self.downLoadInfoDict.copy forKey:kDownLoadMgrSaveKey];
    }
}

+ (instancetype)shareInstance
{
    static DownLoadMgr *obj;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [DownLoadMgr new];
        [obj loadDownInfo];
        NSString *downLoadPath = NSSearchPathForDirectoriesInDomains(NSDownloadsDirectory, NSUserDomainMask, YES).firstObject;
        NSString *musicPath = [downLoadPath stringByAppendingPathComponent:@"Music"];
        NSFileManager *file = [NSFileManager defaultManager];
        BOOL isDirectory;
        BOOL hasMusictPath = [file fileExistsAtPath:musicPath isDirectory:&isDirectory];
        if (!hasMusictPath
            || !isDirectory) {
            NSError *error = nil;
            hasMusictPath = [file createDirectoryAtPath:musicPath withIntermediateDirectories:YES attributes:nil error:&error];
        }
        obj.downLoadDefaultPath = hasMusictPath ? musicPath : downLoadPath;
    });
    return obj;
}

- (NSString *)downLoadPath
{
    return self.downLoadDefaultPath;
}

- (MusicDownLoadType)getDownTypeWithUrl:(NSString *)urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        return MusicDownLoadTypeURLError;
    }
    if ([self.downLoadInfoDict.allKeys containsObject:urlString.lastPathComponent]) {
        return [self.downLoadInfoDict[urlString.lastPathComponent] isEqualTo:@(YES)] ? MusicDownLoadTypeURLHasDownComplete : MusicDownLoadTypeURLDowning;
    }
    return MusicDownLoadTypeURLCanDownLoad;
}

- (void)downLoadUrl:(NSString *)urlString title:(NSString *)title complete:(void (^)(void))completionBlock
{
    NSString *path = [self.downLoadDefaultPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp3", title]];
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        completionBlock();
        return;
    }
    if ([self.downLoadInfoDict.allKeys containsObject:urlString.lastPathComponent]) {
        completionBlock();
        return;
    } else {
        [self.downLoadInfoDict setValue:@(NO) forKey:urlString.lastPathComponent];
        completionBlock();  //将可下载变为正在下载
    }
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [[[AFHTTPSessionManager manager] downloadTaskWithRequest:urlRequest progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"%@ 进度: %.2f%%", title, downloadProgress.fractionCompleted * 100);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return [NSURL fileURLWithPath:path];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        NSLog(@"completionHandler : %@ ", filePath);
        [self.downLoadInfoDict setValue:@(YES) forKey:urlString.lastPathComponent];
        [self save];
        completionBlock();
    }] resume];
}

@end
