//
//  DowningView.m
//  MusicDown
//
//  Created by 孟顺 on 2020/3/18.
//  Copyright © 2020 mengshun. All rights reserved.
//

#import "DowningView.h"

@implementation DowningView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = NSColor.redColor;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    self.backgroundColor = NSColor.redColor;
}

@end
