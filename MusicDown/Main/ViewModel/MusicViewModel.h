//
//  MusicViewModel.h
//  MusicDown
//
//  Created by 孟顺 on 2020/3/18.
//  Copyright © 2020 mengshun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WangyiYinYueModel.h"

@interface MusicViewModel : NSObject

@property (nonatomic, copy) NSString *(^searchKeyWordBlock)(void);

@property (nonatomic, copy) void (^refreshBlock) (void);

- (void)fetchLatest;

- (void)fetchMore;

- (NSInteger)contentCount;

- (WangyiYinYueModel *)modelAtIndex:(NSInteger)idx;

@end

