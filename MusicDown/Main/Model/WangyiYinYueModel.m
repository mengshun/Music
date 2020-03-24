

//
//  WangyiYinYueModel.m
//  MusicDown
//
//  Created by 孟顺 on 2020/3/18.
//  Copyright © 2020 mengshun. All rights reserved.
//

#import "WangyiYinYueModel.h"
#import "DownLoadMgr.h"

@implementation WangyiYinYueModel

+ (instancetype)initDict:(NSDictionary *)dict
{
    if ([dict isKindOfClass:NSDictionary.class]) {
        WangyiYinYueModel *model = [WangyiYinYueModel new];
        model.type = [NSString stringWithFormat:@"%@", dict[@"type"]];
        model.link = [NSString stringWithFormat:@"%@", dict[@"link"]];
        model.songid = [NSString stringWithFormat:@"%@", dict[@"songid"]];
        model.title = [NSString stringWithFormat:@"%@", dict[@"title"]];
        model.author = [NSString stringWithFormat:@"%@", dict[@"author"]];
        model.lrc = [NSString stringWithFormat:@"%@", dict[@"lrc"]];
        model.url = [NSString stringWithFormat:@"%@", dict[@"url"]];
        model.pic = [NSString stringWithFormat:@"%@", dict[@"pic"]];
        model.downType = [[DownLoadMgr shareInstance] getDownTypeWithUrl:model.url];
        return model;
    }
    return nil;
}

+ (NSArray <WangyiYinYueModel *>*)listWithDictList:(NSArray *)list
{
    if ([list isKindOfClass:NSArray.class]) {
        NSMutableArray *tempList = @[].mutableCopy;
        for (NSDictionary *temp in list) {
            WangyiYinYueModel *model = [WangyiYinYueModel initDict:temp];
            if (model) {
                [tempList addObject:model];
            }
        }
        return tempList.copy;
    }
    return list;
}

- (void)reloadDownState
{
    self.downType = [[DownLoadMgr shareInstance] getDownTypeWithUrl:self.url];
}

@end
