//
//  DownLoadMgr.h
//  MusicDown
//
//  Created by 孟顺 on 2020/3/19.
//  Copyright © 2020 mengshun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WangyiYinYueModel.h"

@interface DownLoadMgr : NSObject

+ (instancetype)shareInstance;

- (void)downLoadUrl:(NSString *)urlString title:(NSString *)title complete:(void(^)(void))completionBlock;

- (NSString *)downLoadPath;

- (MusicDownLoadType)getDownTypeWithUrl:(NSString *)url;

- (void)save;

@end

