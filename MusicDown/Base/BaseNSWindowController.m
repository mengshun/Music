//
//  BaseNSWindowController.m
//  MusicDown
//
//  Created by 孟顺 on 2020/3/11.
//  Copyright © 2020 mengshun. All rights reserved.
//

#import "BaseNSWindowController.h"

@interface BaseNSWindowController ()

@end

@implementation BaseNSWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    self.window.titlebarAppearsTransparent  = YES;
    self.window.movableByWindowBackground = YES;
    self.window.titleVisibility = NSWindowTitleHidden;
    [self.window setStyleMask:[self.window styleMask] | NSWindowStyleMaskFullSizeContentView];
}

@end
