//
//  LRLVideoPlayer.h
//  LRLAVPlayerDemo
//
//  Created by liuRuiLong on 16/8/11.
//  Copyright © 2016年 codeWorm. All rights reserved.
//

#import "LRLVideoPlayerDefine.h"
#import "LRLVideoPlayerRenderView.h"

#import <Foundation/Foundation.h>

@interface LRLVideoPlayer : NSObject

/**
 @b 自动播放
 */
@property (nonatomic, assign) BOOL autoPlay;

-(instancetype)initWithDelegate:(id<LRLVideoPlayerDelegate>)delegate playerType:(LRLVideoPlayerType)type videoPlayView:(LRLVideoPlayerDrawView *)playView;

-(void)prepare;

-(void)play;

-(void)pause;

-(void)seekTo:(float)time;

-(void)releasePlayer;

@end
