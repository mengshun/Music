//
//  AppDelegate.m
//  MusicDown
//
//  Created by 孟顺 on 2020/3/11.
//  Copyright © 2020 mengshun. All rights reserved.
//

#import "AppDelegate.h"
#import <AFNetworking.h>
#import "DownLoadMgr.h"

@interface AppDelegate ()

@property id monitor;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
//    [[AFNetworkReachabilityManager manager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
//        NSLog(@"%s net change: %d", __func__, status);
//    }];
//    [[AFNetworkReachabilityManager manager] startMonitoring];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    [[DownLoadMgr shareInstance] save];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag
{
    if (!flag) {
        [NSApp activateIgnoringOtherApps:NO];
        [NSApp.windows.firstObject makeKeyAndOrderFront:self];
    }
    return YES;

}


@end
