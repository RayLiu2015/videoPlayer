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

#pragma mark - 用来创建错误对象
+(NSError *)createAErrorWithErrorDetail:(NSString *)errorStr andErrorCode:(LRLVideoPlayerErrorCode)errorCode{
    NSDictionary *errorInfo = [NSDictionary dictionaryWithObject:errorStr forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:@"com.codeWorm.videoPlayerSDK" code:errorCode userInfo:errorInfo];
    return error;
}

@end
