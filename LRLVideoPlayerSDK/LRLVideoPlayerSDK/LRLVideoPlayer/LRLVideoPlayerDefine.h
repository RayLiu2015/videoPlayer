//
//  LRLVideoPlayerDefine.h
//  LRLAVPlayerDemo
//
//  Created by liuRuiLong on 16/8/11.
//  Copyright © 2016年 codeWorm. All rights reserved.
//


#import <Foundation/Foundation.h>

#import "LRLVideoPlayerErrorInfo.h"

@class LRLVideoPlayer;

typedef enum : NSUInteger {
    LRLVideoPlayerType_AVPlayer
} LRLVideoPlayerType;


typedef enum : NSUInteger {
    LRLVideoPlayerEvent_StartBuffer,
    LRLVideoPlayerEvent_EndBuffer,
    LRLVideoPlayerEvent_GetVideoSize,
    LRLVideoPlayerEvent_PlayEnd
} LRLVideoPlayerEvent;


@protocol LRLVideoPlayerDelegate <NSObject>

-(void)lrlVideoPlayer:(LRLVideoPlayer *)player event:(LRLVideoPlayerEvent)event errorInfo:(LRLVideoPlayerErrorInfo *)errorInfo;

-(void)lrlVideoPlayer:(LRLVideoPlayer *)player position:(float)position cacheDuration:(float)cacheDuration duration:(float)duration;

@end
