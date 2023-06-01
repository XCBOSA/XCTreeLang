//
//  AppDelegate.m
//  TestApp
//
//  Created by 邢铖 on 2023/6/1.
//

#import "AppDelegate.h"
#import "RootViewController.h"
#import <XCTreeLang/XCTreeLang.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (UIWindow *)window {
    if (!_window) {
        _window = [UIWindow new];
        _window.rootViewController = [RootViewController new];
    }
    return _window;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [XCTLEngine.shared enableAutoEvaluateForViewController];
    [self.window makeKeyAndVisible];
    return YES;
}


@end
