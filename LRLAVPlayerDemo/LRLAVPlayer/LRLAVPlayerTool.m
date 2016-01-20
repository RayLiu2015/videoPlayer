//
//  LRLAVPlayerTool.m
//  LRLAVPalyer
//
//  Created by 刘瑞龙 on 15/11/18.
//  Copyright © 2015年 V1. All rights reserved.
//

#import "LRLAVPlayerTool.h"

@implementation LRLAVPlayerTool

#pragma mark - 根据秒数计算时间
NSString * calculateTimeWithTimeFormatter(long long timeSecond){
    NSString * theLastTime = nil;
    if (timeSecond < 60) {
        theLastTime = [NSString stringWithFormat:@"00:%.2lld", timeSecond];
    }else if(timeSecond >= 60 && timeSecond < 3600){
        theLastTime = [NSString stringWithFormat:@"%.2lld:%.2lld", timeSecond/60, timeSecond%60];
    }else if(timeSecond >= 3600){
        theLastTime = [NSString stringWithFormat:@"%.2lld:%.2lld:%.2lld", timeSecond/3600, timeSecond%3600/60, timeSecond%60];
    }
    return theLastTime;
}

@end