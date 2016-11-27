//
//  LRLVideoPlayerTool.m
//  LRLAVPlayerDemo
//
//  Created by liuRuiLong on 16/8/12.
//  Copyright © 2016年 codeWorm. All rights reserved.
//

#import "LRLVideoPlayerTool.h"

@implementation LRLVideoPlayerTool

+(NSString *)calculateTimeWithTimeFormatter:(NSUInteger)timeSecond{
    NSString * theLastTime = nil;
    if (timeSecond < 60) {
        theLastTime = [NSString stringWithFormat:@"00:%.2lu", (unsigned long)timeSecond];
    }else if(timeSecond >= 60 && timeSecond < 3600){
        theLastTime = [NSString stringWithFormat:@"%.2lu:%.2lu", timeSecond/60, timeSecond%60];
    }else if(timeSecond >= 3600){
        theLastTime = [NSString stringWithFormat:@"%.2lu:%.2lu:%.2lu", timeSecond/3600, timeSecond%3600/60, timeSecond%60];
    }
    return theLastTime;
}
@end
