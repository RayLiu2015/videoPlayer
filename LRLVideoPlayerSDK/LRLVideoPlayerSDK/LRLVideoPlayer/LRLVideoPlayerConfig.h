//
//  LRLVideoPlayerConfig.h
//  LRLAVPlayerDemo
//
//  Created by liuRuiLong on 16/8/11.
//  Copyright © 2016年 codeWorm. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LRLVideoPlayerDrawView;
@class LRLVideoPlayerItem;

@protocol LRLVideoPlayerCallBackDelegate <NSObject>

-(void)lrlVideoPlayerCallBackevent:(LRLVideoPlayerEvent)event errorInfo:(nullable NSError *)errorInfo;

-(void)lrlVideoPlayerCallBackposition:(float)position  duration:(float)duration;

-(void)lrlVideoPlayerCallBackCacheDuration:(float)cacheDuration duration:(float)duration;

@end

@protocol LRLVideoPlayerProtocol <NSObject>
@required;

@property (assign, nonatomic) CGFloat position;

@property (assign, nonatomic) CGFloat duration;

@property (assign, nonatomic) NSTimeInterval cacheDuration;

@property (weak, nonatomic, nullable) id<LRLVideoPlayerCallBackDelegate> delegate;

@property (assign, nonatomic) CGSize videoSize;

/**
 @b 自动播放
 */
@property (assign, nonatomic) BOOL autoPlay;

/**
 @b 是否开启后台播放模式, 默认关闭
 */
@property (assign, nonatomic) BOOL backPlayMode;

-(nonnull instancetype)initWithDelegate:(nullable id<LRLVideoPlayerCallBackDelegate>)delegate andPlayView:(nonnull LRLVideoPlayerDrawView *)playView playItem:(nonnull LRLVideoPlayerItem *)item;

-(void)prepare;

-(void)play;

-(void)pause;

-(void)seekTo:(float)time;

-(void)inBackGroundMode:(BOOL)mode;

-(void)startPip;

-(void)stopPip;

-(void)releasePlayer;

@end

