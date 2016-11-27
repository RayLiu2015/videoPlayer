//
//  LRLAVPlayer.m
//  LRLAVPlayerDemo
//
//  Created by liuRuiLong on 16/8/11.
//  Copyright © 2016年 codeWorm. All rights reserved.
//

#import "LRLAVPlayer.h"
#import "LRLVideoPlayerTool.h"
#import "LRLVideoPlayerItem.h"

#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

#define PLAYER_STATUS_KEY           @"status"
#define LOADEDTIMERANGES_KEY        @"loadedTimeRanges"
#define PLAYBACKLIKELYTOKEEPUP_KEY  @"playbackLikelyToKeepUp"
#define PLAYBACKBUFFEREMPTY_KEY     @"playbackBufferEmpty"
#define PLAYBACKBUFFERFULL_KEY      @"playbackBufferFull"
#define PRESENTATIONSIZE_KEY        @"presentationSize"



@interface LRLAVPlayer ()<AVPictureInPictureControllerDelegate>
{
    BOOL _isFirstPlay;
    BOOL _isPlaying;
}


@property (strong, nonatomic) LRLVideoPlayerItem *playerItem;

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
@synthesize delegate = _delegate;
@synthesize autoPlay = _autoPlay;
@synthesize videoSize = _videoSize;
@synthesize backPlayMode = _backPlayMode;
@synthesize duration = _duration;
@synthesize position = _position;
@synthesize cacheDuration = _cacheDuration;

-(void)dealloc{
    VPDLog(@"LRLAVPlayer dealloc");
    if (_avplayer) {
        [self releasePlayer];
    }
}

#pragma mark - LRLVideoPlayerProtocol
-(instancetype)initWithDelegate:(id<LRLVideoPlayerCallBackDelegate>)delegate andPlayView:(LRLVideoPlayerDrawView *)playView playItem:(nonnull LRLVideoPlayerItem *)item{
    if (self = [super init]) {
        self.avplayerView = (LRLAVPlayerRenderView *)playView;
        self.delegate = delegate;
        self.playerItem = item;
    }
    return self;
}

-(void)prepare{
    if (self.autoPlay) {
        [[self createPlayer] play];
    }else{
        [[self createPlayer] pause];
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

-(void)stop{
}

-(void)seekTo:(float)time{
//    [self.avplayer pause];
    CMTime changedTime = CMTimeMakeWithSeconds(time, 1);
    [self handleEvent:LRLVideoPlayerEvent_StartBuffer error:nil];
    __weak __typeof(self) weakSelf = self;
    [self.avplayer seekToTime:changedTime completionHandler:^(BOOL finished){
        if (!weakSelf) {
            return;
        }
        __strong __typeof(weakSelf) sSelf = weakSelf;
        [sSelf handleEvent:LRLVideoPlayerEvent_EndBuffer error:nil];
//        if (_isPlaying) {
//            [weakSelf.avplayer play];
//        }
    }];
}

-(void)inBackGroundMode:(BOOL)mode{
    if (self.backPlayMode) {
        if (mode) {
            [(AVPlayerLayer *)self.avplayerView.layer setPlayer:nil];
        }else{
            [(AVPlayerLayer *)self.avplayerView.layer setPlayer:self.avplayer];
        }
    }else{
        if (mode) {
            [self pause];
        }else{
            [self play];
        }
    }
}
-(void)startPip{
    if ([AVPictureInPictureController isPictureInPictureSupported]) {
        if (self.pipC.isPictureInPicturePossible) {
            [self.pipC startPictureInPicture];
        }else{
            VPDLog(@"pip not possible");
            [self handleEvent:LRLVideoPlayerEvent_PlayError error:[LRLVideoPlayerTool createAErrorWithErrorDetail:@"pip not possible" andErrorCode:LRLVideoPlayerErrorCode_PipNotPossible]];
        }
    }else{
        VPDLog(@"pictureInPicture not Supported");
        [self handleEvent:LRLVideoPlayerEvent_PlayError error:[LRLVideoPlayerTool createAErrorWithErrorDetail:@"pictureInPicture not Supported" andErrorCode:LRLVideoPlayerErrorCode_PipNotSupported]];
    }
}

-(void)stopPip{
    if ([AVPictureInPictureController isPictureInPictureSupported]) {
        if (self.pipC.isPictureInPicturePossible) {
            [self.pipC stopPictureInPicture];
        }else{
            VPDLog(@"pip not possible");
            [self handleEvent:LRLVideoPlayerEvent_PlayError error:[LRLVideoPlayerTool createAErrorWithErrorDetail:@"pip not possible" andErrorCode:LRLVideoPlayerErrorCode_PipNotPossible]];
        }
    }else{
        VPDLog(@"pictureInPicture not Supported");
        [self handleEvent:LRLVideoPlayerEvent_PlayError error:[LRLVideoPlayerTool createAErrorWithErrorDetail:@"pictureInPicture not Supported" andErrorCode:LRLVideoPlayerErrorCode_PipNotSupported]];
    }
}

-(void)releasePlayer{
    if (_avplayerItem) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_avplayerItem];
        /*
         status
         loadedTimeRanges
         playbackLikelyToKeepUp
         playbackBufferEmpty
         playbackBufferFull
         presentationSize
         */
        [self safeRemoveObserverForKeyPath:PLAYER_STATUS_KEY];
        [self safeRemoveObserverForKeyPath:LOADEDTIMERANGES_KEY];
        [self safeRemoveObserverForKeyPath:PLAYBACKLIKELYTOKEEPUP_KEY];
        [self safeRemoveObserverForKeyPath:PLAYBACKBUFFEREMPTY_KEY];
        [self safeRemoveObserverForKeyPath:PLAYBACKBUFFERFULL_KEY];
        [self safeRemoveObserverForKeyPath:PRESENTATIONSIZE_KEY];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_timerObserver) {
        _timerObserver = nil;
    }
    [(AVPlayerLayer *)self.avplayerView.layer setPlayer:nil];
    if (_avplayer) {
        [_avplayer pause];
        _avplayer = nil;
    }
    _avplayerItem = nil;
}


#pragma mark - private
-(void)safeRemoveObserverForKeyPath:(NSString *)keyPath{
    if (!_avplayerItem) {
        return;
    }
    @try {
        [_avplayerItem removeObserver:self forKeyPath:keyPath];
    } @catch (NSException *exception) {
        NSLog(@"remove observer: %@ exception: %@", keyPath, exception);
    } @finally {
    }
}

-(void)readyToPlay{
    _isFirstPlay = NO;
    self.duration = self.avplayerItem.duration.value/self.avplayerItem.duration.timescale;
    
    //这个是用来监测视频播放的进度做出相应的操作
    __weak __typeof(self) weakSelf = self;
    self.timerObserver = [self.avplayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:nil usingBlock:^(CMTime time) {
        if (!weakSelf) {
            return;
        }
        __strong __typeof(weakSelf) sSelf = weakSelf;
        sSelf.position = sSelf.avplayerItem.currentTime.value/sSelf.avplayerItem.currentTime.timescale;
        if ([sSelf.delegate respondsToSelector:@selector(lrlVideoPlayerCallBackposition:duration:)]) {
            [sSelf.delegate lrlVideoPlayerCallBackposition:sSelf.position duration:sSelf.duration];
        }
    }];
    
    self.pipC = [[AVPictureInPictureController alloc] initWithPlayerLayer:self.avplayerView.layer];
    self.pipC.delegate = self;
}

-(void)videoPlayEnd{
    [self handleEvent:LRLVideoPlayerEvent_PlayEnd error:nil];
}

//更新缓冲时间
-(void)updateAvailableDuration{
    NSArray * loadedTimeRanges = self.avplayerItem.loadedTimeRanges;
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    self.cacheDuration = startSeconds + durationSeconds;
    if ([self.delegate respondsToSelector:@selector(lrlVideoPlayerCallBackCacheDuration:duration:)]) {
        [self.delegate lrlVideoPlayerCallBackCacheDuration:self.cacheDuration duration:self.duration];
    }
}


-(void)handleEvent:(LRLVideoPlayerEvent)event error:(NSError *)error{
    if ([self.delegate respondsToSelector:@selector(lrlVideoPlayerCallBackevent:errorInfo:)]) {
        [self.delegate lrlVideoPlayerCallBackevent:event errorInfo:error];
    }
}

#pragma mark -----------------------------
#pragma mark - 视频播放相关
#pragma mark -----------------------------
#pragma mark - KVO - 监测视频状态, 视频播放的核心部分
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {        //获取到视频信息的状态, 成功就可以进行播放, 失败代表加载失败
        if (self.avplayerItem.status == AVPlayerItemStatusReadyToPlay) {   //准备好播放
            if (_isFirstPlay) {
                //self准备好播放
                [self readyToPlay];
                //avplayerView准备好播放
                if (self.autoPlay) {
                    [self.avplayer play];
                }else{
                    [self.avplayer pause];
                }
                [self handleEvent:LRLVideoPlayerEvent_PrepareDone error:nil];
                _isFirstPlay = NO;
            }
        }else if(self.avplayerItem.status == AVPlayerItemStatusFailed){    //加载失败
                [self handleEvent:LRLVideoPlayerEvent_PlayError error:self.avplayerItem.error];
        }else if(self.avplayerItem.status == AVPlayerItemStatusUnknown){   //未知错误
            VPDLog(@"未知错误");
            [self handleEvent:LRLVideoPlayerEvent_PlayError error:[LRLVideoPlayerTool createAErrorWithErrorDetail:@"未知错误" andErrorCode:LRLVideoPlayerErrorCode_UnKownError]];
        }
    }else if([keyPath isEqualToString:@"loadedTimeRanges"]){ //当缓冲进度有变化的时候
        [self updateAvailableDuration];
    }else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]){ //当视频播放因为各种状态播放停止的时候, 这个属性会发生变化
        [self handleEvent:LRLVideoPlayerEvent_EndBuffer error:nil];
    }else if([keyPath isEqualToString:@"playbackBufferEmpty"]){  //当没有任何缓冲部分可以播放的时候
        [self handleEvent:LRLVideoPlayerEvent_StartBuffer error:nil];
    }else if ([keyPath isEqualToString:@"playbackBufferFull"]){
        [self handleEvent:LRLVideoPlayerEvent_EndBuffer error:nil];
    }else if([keyPath isEqualToString:@"presentationSize"]){      //获取到视频的大小的时候调用
        self.videoSize = self.avplayerItem.presentationSize;
        [self handleEvent:LRLVideoPlayerEvent_GetVideoSize error:nil];
    }
}

-(AVPlayer *)createPlayer{
    if (!_avplayer) {
        _avplayer = [AVPlayer playerWithPlayerItem:self.avplayerItem];
        _isFirstPlay = YES;
        //        _avplayer.usesExternalPlaybackWhileExternalScreenIsActive = YES;
        [(AVPlayerLayer *)self.avplayerView.layer setPlayer:_avplayer];
    }
    return _avplayer;
}

#pragma mark - 懒加载
-(AVPlayerItem *)avplayerItem{
    if (!_avplayerItem) {
        NSURL *url = [self.playerItem.videoUrlStr isAbsolutePath] ? [NSURL fileURLWithPath:self.playerItem.videoUrlStr] : [NSURL URLWithString:self.playerItem.videoUrlStr];
        _avplayerItem = [AVPlayerItem playerItemWithURL:url];
        [_avplayerItem addObserver:self forKeyPath:PLAYER_STATUS_KEY options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [_avplayerItem addObserver:self forKeyPath:LOADEDTIMERANGES_KEY options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [_avplayerItem addObserver:self forKeyPath:PLAYBACKLIKELYTOKEEPUP_KEY options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [_avplayerItem addObserver:self forKeyPath:PLAYBACKBUFFEREMPTY_KEY options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [_avplayerItem addObserver:self forKeyPath:PLAYBACKBUFFERFULL_KEY options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [_avplayerItem addObserver:self forKeyPath:PRESENTATIONSIZE_KEY options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoPlayEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:_avplayerItem];
    }
    return _avplayerItem;
}

#pragma mark - AVPictureInPictureControllerDelegate
- (void)pictureInPictureControllerWillStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController{
}
- (void)pictureInPictureControllerDidStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController{
}
- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController failedToStartPictureInPictureWithError:(NSError *)error{
    [self handleEvent:LRLVideoPlayerEvent_PlayError error:error];
}
- (void)pictureInPictureControllerWillStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController{
}
- (void)pictureInPictureControllerDidStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController{
    [self handleEvent:LRLVideoPlayerEvent_PipEnd error:nil];
}
- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:(void (^)(BOOL restored))completionHandler{
}

@end
