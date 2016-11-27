//
//  LRLAVPlayer.m
//  LRLAVPlayerDemo
//
//  Created by liuRuiLong on 16/8/11.
//  Copyright © 2016年 codeWorm. All rights reserved.
//

#import "LRLAVPlayer.h"

#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

@interface LRLAVPlayer ()<AVPictureInPictureControllerDelegate>
{
    BOOL _isFirstConfig;
    BOOL _destoryed;
    BOOL _isPlaying;
    float _destoryTempTime;
    float _totalSeconds;
    CGSize _videoSize;
}


/**
 * @b 画中画控制器
 */
@property (nonatomic, strong) AVPictureInPictureController *pipC;

@property (strong, nonatomic) AVPlayer *avplayer;

@property (strong, nonatomic) AVPlayerItem *avplayerItem;

@property (strong, nonatomic) LRLAVPlayerRenderView *avplayerView;

/**
 * @b 用来监控播放时间的observer
 */
@property (nonatomic, strong) id timerObserver;


@end

@implementation LRLAVPlayer
@synthesize videoUrlStr;
@synthesize delegate;

-(instancetype)initWithDelegate:(id<LRLVideoPlayerDelegate>)delegate andPlayView:(LRLVideoPlayerDrawView *)playView{
    if (self = [super init]) {
        self.avplayerView = (LRLAVPlayerRenderView *)playView;
        self.delegate = delegate;
    }
    return self;
}

-(void)prepare{
    if (self.autoPlay) {
        [self.avplayer play];
    }else{
        [self.avplayer pause];
    }
    
}

-(void)play{
    [self.avplayer play];
    _isPlaying = YES;
}

-(void)pause{
    [self.avplayer pause];
    _isPlaying = NO;
}

-(CGSize)videoSize{
    return _videoSize;
}

-(void)stop{
}

-(void)seekTo:(float)time{
    [self.avplayer pause];
    CMTime changedTime = CMTimeMakeWithSeconds(time, 1);
    __weak __typeof(self) weakSelf = self;
    [self.avplayer seekToTime:changedTime completionHandler:^(BOOL finished){
        if (_isPlaying) {
            [weakSelf.avplayer play];
        }
    }];
}

-(void)releasePlayer{
}

-(void)moviePlayEnd{
    [self handleEvent:LRLVideoPlayerEvent_PlayEnd];
}

-(void)readyToPlay{
    _isFirstConfig = NO;
    _totalSeconds = self.avplayerItem.duration.value/self.avplayerItem.duration.timescale;
    
    //这个是用来监测视频播放的进度做出相应的操作
    __weak __typeof(self) weakSelf = self;
    self.timerObserver = [self.avplayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:nil usingBlock:^(CMTime time) {
        long long currentSecond = weakSelf.avplayerItem.currentTime.value/weakSelf.avplayerItem.currentTime.timescale;
    }];
 
}

#pragma mark - 更新缓冲时间
-(void)updateAvailableDuration{
    NSArray * loadedTimeRanges = self.avplayerItem.loadedTimeRanges;
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;
}

-(void)handleEvent:(LRLVideoPlayerEvent)event{

}

-(void)playOrPause{
    if (_isPlaying) {
        [self.avplayer pause];
        _isPlaying = NO;
    }else{
        [self.avplayer play];
        _isPlaying = YES;
    }
}


#pragma mark -----------------------------
#pragma mark - 视频播放相关
#pragma mark -----------------------------
#pragma mark - KVO - 监测视频状态, 视频播放的核心部分
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {        //获取到视频信息的状态, 成功就可以进行播放, 失败代表加载失败
        if (self.avplayerItem.status == AVPlayerItemStatusReadyToPlay) {   //准备好播放
            if (_isFirstConfig) {
                //self准备好播放
                [self readyToPlay];
                //avplayerView准备好播放
                if (_isPlaying) {
                    [self.avplayer play];
                }else{
                    [self.avplayer pause];
                }
                if (_destoryed) {
                    [self seekTo:_destoryTempTime];
                }
            }
        }else if(self.avplayerItem.status == AVPlayerItemStatusFailed){    //加载失败
        }else if(self.avplayerItem.status == AVPlayerItemStatusUnknown){   //未知错误
        }
        _destoryed = NO;
    }else if([keyPath isEqualToString:@"loadedTimeRanges"]){ //当缓冲进度有变化的时候
        [self updateAvailableDuration];
    }else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]){ //当视频播放因为各种状态播放停止的时候, 这个属性会发生变化
        if (self.pipC && self.pipC.pictureInPictureActive) {
            _isPlaying = YES;
            [self playOrPause];
        }else{
            if (_isPlaying) {
                [self.avplayer play];
            }
        }
    }else if([keyPath isEqualToString:@"playbackBufferEmpty"]){  //当没有任何缓冲部分可以播放的时候
        [self handleEvent:LRLVideoPlayerEvent_StartBuffer];
    }else if ([keyPath isEqualToString:@"playbackBufferFull"]){
    }else if([keyPath isEqualToString:@"presentationSize"]){      //获取到视频的大小的时候调用
        _videoSize = self.avplayerItem.presentationSize;
        [self handleEvent:LRLVideoPlayerEvent_GetVideoSize];
    }
}


#pragma mark - 懒加载
-(AVPlayerItem *)avplayerItem{
    if (!_avplayerItem) {
        _avplayerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:self.videoUrlStr]];
        [_avplayerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [_avplayerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [_avplayerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [_avplayerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [_avplayerItem addObserver:self forKeyPath:@"playbackBufferFull" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [_avplayerItem addObserver:self forKeyPath:@"presentationSize" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:_avplayerItem];
    }
    return _avplayerItem;
}

-(AVPlayer *)avplayer{
    if (!_avplayer) {
        _avplayer = [AVPlayer playerWithPlayerItem:self.avplayerItem];
        _avplayer.usesExternalPlaybackWhileExternalScreenIsActive = YES;
        [(AVPlayerLayer *)self.avplayerView.layer setPlayer:_avplayer];
    }
    return _avplayer;
}


#pragma mark - AVPictureInPictureControllerDelegate
- (void)pictureInPictureControllerWillStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController{
}
- (void)pictureInPictureControllerDidStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController{
}
- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController failedToStartPictureInPictureWithError:(NSError *)error{
}
- (void)pictureInPictureControllerWillStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController{
}
- (void)pictureInPictureControllerDidStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController{
}
- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:(void (^)(BOOL restored))completionHandler{
}

@end
