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
    LRLVideoPlayerEvent_PlayEnd,         //视频播放完毕, 当队列内最后一个播放完毕, 播放器状态会变为暂停状态
    LRLVideoPlayerEvent_PipEnd,
    LRLVideoPlayerEvent_DurationChanged,
    LRLVideoPlayerEvent_PlayError
} LRLVideoPlayerEvent;

typedef enum : NSUInteger {
    LRLVideoPlayerErrorCode_PrepareError,
    LRLVideoPlayerErrorCode_UnKownError,
    LRLVideoPlayerErrorCode_PipNotSupported,
    LRLVideoPlayerErrorCode_PipNotPossible,
    LRLVideoPlayerErrorCode_PipOpenError,
    LRLVideoPlayerErrorCode_AlreadyLastVideo
} LRLVideoPlayerErrorCode;


@protocol LRLVideoPlayerDelegate <NSObject>

/**
 @b 播放事件回调, event 为 LRLVideoPlayerEvent_PlayError 时, 会回调错误信息

 @param player 当前播放器
 @param event 回调事件
 @param errorInfo 错误信息 当 event 为 LRLVideoPlayerEvent_PlayError 不为空  error 的errorCode 详见: LRLVideoPlayerErrorCode
 @param index 当前 播放的视频 下标, 从0开始
 */
-(void)lrlVideoPlayer:(LRLVideoPlayer *)player event:(LRLVideoPlayerEvent)event errorInfo:(NSError *)errorInfo atIndex:(NSInteger)index;

/**
 @b 视频长度, 播放进度 缓冲进度的回调

 @param player 当前播放器
 @param position 播放进度
 @param cacheDuration 缓冲进度
 @param duration 视频长度
 @param index 当前 播放的视频 下标, 从0开始
 */
-(void)lrlVideoPlayer:(LRLVideoPlayer *)player position:(Float64)position cacheDuration:(float)cacheDuration duration:(float)duration  atIndex:(NSInteger)index;

@end
