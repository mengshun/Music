//
//  MusicViewModel.m
//  MusicDown
//
//  Created by 孟顺 on 2020/3/18.
//  Copyright © 2020 mengshun. All rights reserved.
//

#import "MusicViewModel.h"
#import <AFNetworking.h>

@interface MusicViewModel ()

@property (nonatomic, strong) NSString *keyWord;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) BOOL hasMoreItem;

@property (nonatomic, strong) NSMutableArray *dataList;

@end

@implementation MusicViewModel

- (void)fetchLatest
{
    self.keyWord = self.searchKeyWordBlock();
    NSLog(@"获取到搜索关键词: [%@]", self.keyWord);
    self.hasMoreItem = YES;
    self.page = 1;
    [self fetchData];
}

- (NSInteger)contentCount
{
    return self.dataList.count;
}

- (WangyiYinYueModel *)modelAtIndex:(NSInteger)idx
{
    if (idx < [self contentCount]) {
        return self.dataList[idx];
    }
    return nil;
}

- (void)fetchMore
{
    self.page += 1;
    [self fetchData];
}

- (void)fetchData
{
    NSURL *url = [NSURL URLWithString:@"https://yinyue.lkxin.cn/"];
    NSInteger page = self.page;
    NSDictionary *paramters = @{
        @"input":self.keyWord,
        @"filter":@"name",
        @"type":@"netease",
        @"page":@(page),
    };
    NSString *refer = [NSString stringWithFormat:@"https://yinyue.lkxin.cn/?name=%@&type=netease", self.keyWord];
    refer = [refer stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:url];
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    [requestSerializer setValue:@"application/json, text/javascript, */*; q=0.01" forHTTPHeaderField:@"accept"];
    [requestSerializer setValue:@"XMLHttpRequest" forHTTPHeaderField:@"x-requested-with"];
    [requestSerializer setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.132 Safari/537.36" forHTTPHeaderField:@"user-agent"];
    [requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"content-type"];
    [requestSerializer setValue:@"https://yinyue.lkxin.cn" forHTTPHeaderField:@"origin"];
    [requestSerializer setValue:refer forHTTPHeaderField:@"referer"];
    [manager setRequestSerializer:requestSerializer];
    AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/json", nil];
    [manager setResponseSerializer:responseSerializer];
    [manager POST:url.absoluteString parameters:paramters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        NSInteger code = [[dataDict objectForKey:@"code"] integerValue];
        if (code == 200) {
            NSArray *musicList = [WangyiYinYueModel listWithDictList:dataDict[@"data"]];
            if (musicList) {
                if (page == 1) {
                    [self.dataList removeAllObjects];
                }
                [self.dataList addObjectsFromArray:musicList];
                if (self.refreshBlock) self.refreshBlock();
                if (page == 1) [self fetchMore];
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error : %@", error);
    }];
    
}

- (NSMutableArray *)dataList
{
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

@end
