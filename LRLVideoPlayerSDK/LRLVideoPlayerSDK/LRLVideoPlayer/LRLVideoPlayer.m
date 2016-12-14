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

const NSString *LRLVideoPlayerVersion = @"1.2";

@interface LRLVideoPlayer ()<LRLVideoPlayerCallBackDelegate>

@property (strong, nonatomic) id<LRLVideoPlayerProtocol> videoPlayer;

@property (strong, nonatomic) UIView *playView;

@end

@implementation LRLVideoPlayer

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]  removeObserver:self];
    VPDLog(@"LRLVideoPlayer dealloc");
}

-(nonnull instancetype)initWithDelegate:(nullable id<LRLVideoPlayerDelegate>)delegate playerType:(LRLVideoPlayerType)type playItem:(nonnull LRLVideoPlayerItem *)items{
    if (self = [super init]) {
        self.delegate = delegate;
        if (type == LRLVideoPlayerType_AVPlayer) {
            self.playView = [[LRLAVPlayerRenderView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            self.videoPlayer = [[LRLAVPlayer alloc] initWithDelegate:self andPlayView:(LRLVideoPlayerDrawView *)self.playView playItem:items];
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

-(CGSize)videoSize{
    return self.videoPlayer.videoSize;
}

-(Float64)duration{
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

-(void)playNext{
    [self.videoPlayer playNext];
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

-(void)lrlVideoPlayerCallBackevent:(LRLVideoPlayerEvent)event errorInfo:(nullable NSError *)errorInfo atIndex:(NSInteger)index{
    if ([self.delegate respondsToSelector:@selector(lrlVideoPlayer:event:errorInfo:atIndex:)]) {
        [self.delegate lrlVideoPlayer:self event:event errorInfo:errorInfo atIndex:index];
    }
}

-(void)lrlVideoPlayerCallBackPosition:(Float64)position cacheDuration:(Float64)cacheDuration duration:(Float64)duration atIndex:(NSInteger)index{
    if ([self.delegate respondsToSelector:@selector(lrlVideoPlayer:position:cacheDuration:duration:atIndex:)]) {
        [self.delegate lrlVideoPlayer:self position:position cacheDuration:cacheDuration duration:duration atIndex:index];
    }
}

-(void)appWillResignActive{
    [self.videoPlayer inBackGroundMode:YES];
}

-(void)appDidBecomeActive{
    [self.videoPlayer inBackGroundMode:NO];
}

@end
