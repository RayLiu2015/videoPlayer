//
//  AppDelegate.m
//  LRLAVPalyer
//
//  Created by 刘瑞龙 on 15/9/10.
//  Copyright (c) 2015年 V1. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "AppDelegate.h"
#import "BaseNavViewController.h"
#import "LRLAVPlayerController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //设置状态条的颜色为白色
    [application setStatusBarStyle:UIStatusBarStyleDefault];
    //由于开启了旋转屏, 再一进入程序的时候
    [application setStatusBarOrientation:UIInterfaceOrientationPortrait];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    LRLAVPlayerController * av = [[LRLAVPlayerController alloc] init];
    BaseNavViewController * nav = [[BaseNavViewController alloc] initWithRootViewController:av];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    AVAudioSession *as = [AVAudioSession sharedInstance];
    [as setActive:YES error:nil];
    [as setCategory:AVAudioSessionCategoryPlayback error:nil];
    return YES;
}

-(UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    return self.window.rootViewController.supportedInterfaceOrientations;
}

@end
