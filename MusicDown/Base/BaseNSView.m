//
//  BaseNSView.m
//  MusicDown
//
//  Created by 孟顺 on 2020/3/11.
//  Copyright © 2020 mengshun. All rights reserved.
//

#import "BaseNSView.h"

@implementation BaseNSView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    if (self.backgroundColor) {
        self.layer.backgroundColor = self.backgroundColor.CGColor;
    }
}

@end
