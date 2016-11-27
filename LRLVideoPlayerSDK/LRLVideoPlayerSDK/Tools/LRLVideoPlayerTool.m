//
//  LRLVideoPlayerTool.m
//  LRLAVPlayerDemo
//
//  Created by liuRuiLong on 16/8/12.
//  Copyright © 2016年 codeWorm. All rights reserved.
//

#import "LRLVideoPlayerTool.h"

@implementation LRLVideoPlayerTool

+(instancetype)sharedTool{
    static LRLVideoPlayerTool *tool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool = [[LRLVideoPlayerTool alloc] init];
    });
    return tool;
}

-(instancetype)init{
    if (self = [super init]) {
        self.playTypeDic = [[NSMutableDictionary alloc] init];
    }
    return self;
}

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

#pragma mark - 用来创建错误对象
+(NSError *)createAErrorWithErrorDetail:(NSString *)errorStr andErrorCode:(LRLVideoPlayerErrorCode)errorCode{
    NSDictionary *errorInfo = [NSDictionary dictionaryWithObject:errorStr forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:@"com.codeWorm.videoPlayerSDK" code:errorCode userInfo:errorInfo];
    return error;
}

@end
