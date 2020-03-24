//
//  WangyiYinYueModel.h
//  MusicDown
//
//  Created by 孟顺 on 2020/3/18.
//  Copyright © 2020 mengshun. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MusicDownLoadType) {
    MusicDownLoadTypeURLError   = 0, //下载链接有错误 无法下载
    MusicDownLoadTypeURLCanDownLoad,    //可以下载
    MusicDownLoadTypeURLDowning,    //正在下载
    MusicDownLoadTypeURLHasDownComplete,    //下载完成
};

@interface WangyiYinYueModel : NSObject

@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *link;
@property (nonatomic, copy) NSString *songid;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *lrc;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *pic;
@property (nonatomic, assign) MusicDownLoadType downType;

+ (instancetype)initDict:(NSDictionary *)dict;

+ (NSArray <WangyiYinYueModel *>*)listWithDictList:(NSArray *)list;

- (void)reloadDownState;

@end

