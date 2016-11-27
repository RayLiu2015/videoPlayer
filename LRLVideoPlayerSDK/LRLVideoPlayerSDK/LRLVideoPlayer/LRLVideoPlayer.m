//
//  LRLVideoPlayer.m
//  LRLAVPlayerDemo
//
//  Created by liuRuiLong on 16/8/11.
//  Copyright © 2016年 codeWorm. All rights reserved.
//

#import "LRLAVPlayer.h"
#import "LRLVideoPlayer.h"
#import "LRLVideoPlayerConfig.h"

@interface LRLVideoPlayer ()

@property (strong, nonatomic) id<LRLVideoPlayerProtocol> videoPlayer;

@end

@implementation LRLVideoPlayer

-(instancetype)initWithDelegate:(id<LRLVideoPlayerDelegate>)delegate playerType:(LRLVideoPlayerType)type videoPlayView:(LRLVideoPlayerDrawView *)playView{
    if (self = [super init]) {
        if (type == LRLVideoPlayerType_AVPlayer) {
            self.videoPlayer = [[LRLAVPlayer alloc] initWithDelegate:delegate andPlayView:playView];
        }
    }
    return self;
}

-(void)prepare{
    [self.videoPlayer prepare];
}

-(void)play{
    [self.videoPlayer play];
}

-(void)pause{
    [self.videoPlayer pause];
}

-(void)seekTo:(float)time{
    [self.videoPlayer seekTo:time];
}

-(void)releasePlayer{
    [self.videoPlayer releasePlayer];
}

@end
