//
//  DownCompleteView.m
//  MusicDown
//
//  Created by 孟顺 on 2020/3/18.
//  Copyright © 2020 mengshun. All rights reserved.
//

#import "DownCompleteView.h"

@implementation DownCompleteView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = NSColor.greenColor;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    self.backgroundColor = NSColor.greenColor;
}

@end
