//
//  LRLVideoPlayerConfig.h
//  LRLAVPlayerDemo
//
//  Created by liuRuiLong on 16/8/11.
//  Copyright © 2016年 codeWorm. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LRLVideoPlayerDrawView;

@protocol LRLVideoPlayerProtocol <NSObject>

/**
 @b 自动播放
 */
@property (assign, nonatomic) BOOL autoPlay;

@property (copy, nonatomic) NSString *videoUrlStr;

@property (weak, nonatomic) id<LRLVideoPlayerDelegate> delegate;

@required;

-(instancetype)initWithDelegate:(id<LRLVideoPlayerDelegate>)delegate andPlayView:(LRLVideoPlayerDrawView *)playView;

-(void)prepare;

-(void)play;

-(void)pause;

-(void)stop;

-(void)seekTo:(float)time;

-(void)releasePlayer;

-(CGSize)videoSize;

@end
