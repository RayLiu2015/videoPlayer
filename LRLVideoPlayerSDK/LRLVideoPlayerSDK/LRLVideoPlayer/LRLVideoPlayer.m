//
//  LRLVideoPlayer.m
//  LRLAVPlayerDemo
//
//  Created by liuRuiLong on 16/8/11.
//  Copyright © 2016年 codeWorm. All rights reserved.
//

#import "LRLAVPlayer.h"
#import "LRLVideoPlayer.h"
#import "LRLVideoPlayerTool.h"
#import "LRLVideoPlayerConfig.h"
#import "LRLVideoPlayerRenderView.h"

@interface LRLVideoPlayer ()<LRLVideoPlayerCallBackDelegate>

@property (strong, nonatomic) id<LRLVideoPlayerProtocol> videoPlayer;

@property (strong, nonatomic) UIView *playView;

@end

@implementation LRLVideoPlayer

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]  removeObserver:self];
    VPDLog(@"LRLVideoPlayer dealloc");
}

-(nonnull instancetype)initWithDelegate:(nullable id<LRLVideoPlayerDelegate>)delegate playerType:(LRLVideoPlayerType)type playItem:(nonnull LRLVideoPlayerItem *)item{
    if (self = [super init]) {
        self.delegate = delegate;
        if (type == LRLVideoPlayerType_AVPlayer) {
            self.playView = [[LRLAVPlayerRenderView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            self.videoPlayer = [[LRLAVPlayer alloc] initWithDelegate:self andPlayView:(LRLVideoPlayerDrawView *)self.playView playItem:item];
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

-(CGSize)videoSize{
    return self.videoPlayer.videoSize;
}

-(NSTimeInterval)duration{
    return self.videoPlayer.duration;
}
-(NSTimeInterval)position{
    return self.videoPlayer.position;
}

-(NSTimeInterval)cacheDuration{
    return self.videoPlayer.cacheDuration;
}

-(void)setBackPlayMode:(BOOL)backPlayMode{
    self.videoPlayer.backPlayMode = backPlayMode;
}

-(void)setAutoPlay:(BOOL)autoPlay{
    self.videoPlayer.autoPlay = autoPlay;
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

-(void)startPip{
    [self.videoPlayer startPip];
}

-(void)stopPip{
    [self.videoPlayer stopPip];
}

-(void)releasePlayer{
    [self.videoPlayer releasePlayer];
    self.videoPlayer = nil;
}

-(void)lrlVideoPlayerCallBackevent:(LRLVideoPlayerEvent)event errorInfo:(NSError *)errorInfo{
    if ([self.delegate respondsToSelector:@selector(lrlVideoPlayer:event:errorInfo:)]) {
        [self.delegate lrlVideoPlayer:self event:event errorInfo:errorInfo];
    }
}

-(void)lrlVideoPlayerCallBackCacheDuration:(float)cacheDuration duration:(float)duration{
    if ([self.delegate  respondsToSelector:@selector(lrlVideoPlayer:cacheDuration:duration:)]) {
        [self.delegate lrlVideoPlayer:self cacheDuration:cacheDuration duration:duration];
    }
}

-(void)lrlVideoPlayerCallBackposition:(float)position duration:(float)duration{
    if ([self.delegate respondsToSelector:@selector(lrlVideoPlayer:position:duration:)]) {
        [self.delegate lrlVideoPlayer:self position:position duration:duration];
    }
}

-(void)appWillResignActive{
    [self.videoPlayer inBackGroundMode:YES];
}

-(void)appDidBecomeActive{
    [self.videoPlayer inBackGroundMode:NO];
}

@end
