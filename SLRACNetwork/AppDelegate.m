//
//  AppDelegate.m
//  SLRACNetwork
//
//  Created by 孙立 on 2020/10/10.
//  Copyright © 2020 sl. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import <SVProgressHUD.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [UIWindow new];
    self.window.frame = [UIScreen mainScreen].bounds;
    self.window.rootViewController = [ViewController new];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setMinimumDismissTimeInterval:3.f];
    [SVProgressHUD setMaxSupportedWindowLevel:UIWindowLevelAlert];
    return YES;
}

@end
