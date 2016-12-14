//
//  LRLVideoPlayer.h
//  LRLAVPlayerDemo
//
//  Created by liuRuiLong on 16/8/11.
//  Copyright © 2016年 codeWorm. All rights reserved.
//

#import "LRLVideoPlayerItem.h"
#import "LRLVideoPlayerDefine.h"

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

/**
 @b 当前播放器版本
 */
extern const NSString *_Nonnull LRLVideoPlayerVersion;

@interface LRLVideoPlayer : NSObject

/**
 @b 自动播放
 */
@property (assign, nonatomic) BOOL autoPlay;

/**
 @b 视频时长 单位: s
 */
@property (assign, nonatomic, readonly) Float64 duration;

/**
 @b 视频播放的位置 单位: s
 */
@property (assign, nonatomic, readonly) NSTimeInterval position;

/**
 @b 视频缓冲的位置 单位: s
 */
@property (assign, nonatomic, readonly) NSTimeInterval cacheDuration;

/**
 @b 视频的尺寸
 */
@property (assign, nonatomic, readonly) CGSize videoSize;

/**
 @b 进行视频绘制的视图, 在调用初始化方法后可以使用
 */
@property (strong, nonatomic, readonly, nonnull) UIView *playView;

/**
 @b 是否开启后台播放模式, 默认关闭
 */
@property (assign, nonatomic) BOOL backPlayMode;

@property (nonatomic, weak, nullable) id<LRLVideoPlayerDelegate> delegate;

/**
 @b 初始方法
 
 @param delegate 代理
 @param type 播放器类型
 @param items 视频播放所需信息
 @return 视频播放器
 */
-(nonnull instancetype)initWithDelegate:(nullable id<LRLVideoPlayerDelegate>)delegate playerType:(LRLVideoPlayerType)type playItem:(nonnull NSArray<LRLVideoPlayerItem *> *)items;

/**
 @b 进行播放准备, 如果autoPlay设置为YES, 则调用prepare后自动播放, 如果 设置autoPlay为NO, 需要在回调 LRLVideoPlayerEvent_PrepareDone 后自行调用play进行播放
 */
-(void)prepare;

/**
 @b 进行播放, 需要收到 LRLVideoPlayerEvent_PrepareDone 回调后, 调用才有效
 */
-(void)play;

/**
 @b 播放队列的下一个视频
 */
-(void)playNext;

/**
 @b 暂停操作
 */
-(void)pause;

/**
 @b seek到指定位置

 @param time 单位: s
 */
-(void)seekTo:(float)time;

/**
 @b 开始画中画
 */
-(void)startPip;

/**
 @b 结束画中画
 */
-(void)stopPip;

/**
 @b 不在使用播放器时需调用此方法释放播放器
 */
-(void)releasePlayer;

@end
