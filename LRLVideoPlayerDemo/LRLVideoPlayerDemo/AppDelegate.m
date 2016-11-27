//
//  AppDelegate.m
//  LRLVideoPlayerDemo
//
//  Created by liuRuiLong on 2016/11/26.
//  Copyright © 2016年 liuRuiLong. All rights reserved.
//

#import "AppDelegate.h"
#import "LRLUseVideoPlayerView_ViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <LRLVideoPlayerSDK/LRLVideoPlayerSDK.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //设置状态条的颜色为白色
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    //由于开启了旋转屏, 再一进入程序的时候
    [application setStatusBarOrientation:UIInterfaceOrientationPortrait];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    
    LRLUseVideoPlayerView_ViewController * av = [[LRLUseVideoPlayerView_ViewController alloc] init];
    self.window.rootViewController = av;
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
