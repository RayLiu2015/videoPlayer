//
//  LRLVideoPlayerDefine.h
//  LRLAVPlayerDemo
//
//  Created by liuRuiLong on 16/8/11.
//  Copyright © 2016年 codeWorm. All rights reserved.
//


#import <Foundation/Foundation.h>


@class LRLVideoPlayer;

typedef enum : NSUInteger {
    LRLVideoPlayerType_AVPlayer
} LRLVideoPlayerType;


typedef enum : NSUInteger {
    LRLVideoPlayerEvent_PrepareDone,
    LRLVideoPlayerEvent_StartBuffer,
    LRLVideoPlayerEvent_EndBuffer,
    LRLVideoPlayerEvent_GetVideoSize,
    LRLVideoPlayerEvent_PlayEnd,
    LRLVideoPlayerEvent_PipEnd,
    LRLVideoPlayerEvent_PlayError
} LRLVideoPlayerEvent;

typedef enum : NSUInteger {
    LRLVideoPlayerErrorCode_PrepareError,
    LRLVideoPlayerErrorCode_UnKownError,
    LRLVideoPlayerErrorCode_PipNotSupported,
    LRLVideoPlayerErrorCode_PipNotPossible,
    LRLVideoPlayerErrorCode_PipOpenError
} LRLVideoPlayerErrorCode;




@protocol LRLVideoPlayerDelegate <NSObject>

-(void)lrlVideoPlayer:(LRLVideoPlayer *)player event:(LRLVideoPlayerEvent)event errorInfo:(NSError *)errorInfo;

-(void)lrlVideoPlayer:(LRLVideoPlayer *)player position:(float)position duration:(float)duration;

-(void)lrlVideoPlayer:(LRLVideoPlayer *)player cacheDuration:(float)cacheDuration duration:(float)duration;

@end
