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

@property (strong, nonatomic) NSMutableArray<LRLVideoPlayerItem *> *playerItems;

@property (strong, nonatomic) NSMutableArray<AVPlayerItem *> *avPlayerItems;

/**
 * @b 画中画控制器
 */
@property (nonatomic, strong) AVPictureInPictureController *pipC;

@property (strong, nonatomic) AVQueuePlayer *avplayer;

//@property (strong, nonatomic) AVPlayerItem *avplayerItem;

@property (strong, nonatomic) LRLAVPlayerRenderView *avplayerView;

/**
 * @b 用来监控播放时间的observer
 */
@property (nonatomic, strong) id timerObserver;

@property (strong, nonatomic) NSTimer *progressTimer;

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
-(nonnull instancetype)initWithDelegate:(nullable id<LRLVideoPlayerCallBackDelegate>)delegate andPlayView:(nonnull LRLVideoPlayerDrawView *)playView playItem:(nonnull NSArray<LRLVideoPlayerItem *> *)items{
    if (self = [super init]) {
        self.avplayerView = (LRLAVPlayerRenderView *)playView;
        self.delegate = delegate;
        self.playerItems = [[NSMutableArray alloc] initWithArray:items];
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

-(void)playNext{
    if (self.currentIndex == self.avPlayerItems.count - 1) {
        [self handleEvent:LRLVideoPlayerEvent_PlayError error:[LRLVideoPlayerTool createAErrorWithErrorDetail:@"播放的是最后一个" andErrorCode:LRLVideoPlayerErrorCode_AlreadyLastVideo]];
        return;
    }
    [self.avplayer advanceToNextItem];
}

-(void)pause{
    [self.avplayer pause];
    _isPlaying = NO;
}

-(void)stop{
}

-(void)seekTo:(float)time{
    CMTime changedTime = CMTimeMakeWithSeconds(time, 1);
    [self handleEvent:LRLVideoPlayerEvent_StartBuffer error:nil];
    __weak __typeof(self) weakSelf = self;
    [self.avplayer seekToTime:changedTime completionHandler:^(BOOL finished){
        if (!weakSelf) {
            return;
        }
        __strong __typeof(weakSelf) sSelf = weakSelf;
        [sSelf handleEvent:LRLVideoPlayerEvent_EndBuffer error:nil];
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
    if (self.progressTimer) {
        [self.progressTimer invalidate];
        self.progressTimer = nil;
    }
    
    if (self.avPlayerItems) {
        [self removeObservers];
        [self.avPlayerItems removeAllObjects];
        self.avPlayerItems = nil;
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
}
-(Float64)duration{    
    Float64 duration = CMTimeGetSeconds(self.avplayer.currentItem.duration);
    if (isnan(duration)) {
        return _duration;
    }else{
        _duration = duration;
        return duration;
    }
}

-(Float64)position{
    Float64 position = CMTimeGetSeconds(self.avplayer.currentItem.currentTime);
    if (isnan(position)) {
        return _position;
    }else{
        _position = position;
        return position;
    }
}

#pragma mark - private
-(void)removeObservers{
    for (AVPlayerItem *item in self.avPlayerItems) {
        /*
         status
         loadedTimeRanges
         playbackLikelyToKeepUp
         playbackBufferEmpty
         playbackBufferFull
         presentationSize
         */

        [self safeRemoveObserverItem:item ForKeyPath:PLAYER_STATUS_KEY];
        [self safeRemoveObserverItem:item ForKeyPath:PLAYBACKLIKELYTOKEEPUP_KEY];
        [self safeRemoveObserverItem:item ForKeyPath:PLAYBACKBUFFEREMPTY_KEY];
        [self safeRemoveObserverItem:item ForKeyPath:PLAYBACKBUFFERFULL_KEY];
        [self safeRemoveObserverItem:item ForKeyPath:PRESENTATIONSIZE_KEY];
        
    }
}
-(void)safeRemoveObserverItem:(AVPlayerItem *)item ForKeyPath:(NSString *)keyPath{
    if (!item) {
        return;
    }
    @try {
        [item removeObserver:self forKeyPath:keyPath];
    } @catch (NSException *exception) {
        VPDLog(@"remove observer: %@ exception: %@", keyPath, exception);
    } @finally {
    }
}

-(void)readyToPlay{
    _isFirstPlay = NO;
    
    //这个是用来监测视频播放的进度做出相应的操作
    if (!_progressTimer) {
        __weak __typeof(self) weakSelf = self;
        _progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 repeats:YES block:^(NSTimer * _Nonnull timer) {
            if (!weakSelf) {
                return;
            }
            __strong __typeof(weakSelf) sSelf = weakSelf;
            NSArray * loadedTimeRanges = sSelf.avplayer.currentItem.loadedTimeRanges;
            if (!loadedTimeRanges.count) {
                return;
            }
            CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];
            float startSeconds = CMTimeGetSeconds(timeRange.start);
            float durationSeconds = CMTimeGetSeconds(timeRange.duration);
            sSelf.cacheDuration = startSeconds + durationSeconds;
        
            if ([self.delegate respondsToSelector:@selector(lrlVideoPlayerCallBackPosition:cacheDuration:duration:atIndex:)]) {
                [self.delegate lrlVideoPlayerCallBackPosition:sSelf.position cacheDuration:sSelf.cacheDuration duration:sSelf.duration atIndex:sSelf.currentIndex];
            }            
        }];
    }
    
    self.pipC = [[AVPictureInPictureController alloc] initWithPlayerLayer:(AVPlayerLayer *)self.avplayerView.layer];
    self.pipC.delegate = self;
}

-(void)videoPlayEnd{
    if (self.currentIndex < self.avPlayerItems.count - 1) {
        [self.avplayer advanceToNextItem];
    }
    [self handleEvent:LRLVideoPlayerEvent_PlayEnd error:nil];
}

-(NSInteger)currentIndex{
    NSInteger index = [self.avPlayerItems indexOfObject:self.avplayer.currentItem];
    if (index >= self.playerItems.count) {
        index = 0;
    }
    return index;
}

-(void)handleEvent:(LRLVideoPlayerEvent)event error:(NSError *)error{
    if ([self.delegate respondsToSelector:@selector(lrlVideoPlayerCallBackevent:errorInfo:atIndex:)]) {
        [self.delegate lrlVideoPlayerCallBackevent:event errorInfo:error atIndex:self.currentIndex];
    }
}

#pragma mark -----------------------------
#pragma mark - 视频播放相关
#pragma mark -----------------------------
#pragma mark - KVO - 监测视频状态, 视频播放的核心部分
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:PLAYER_STATUS_KEY]) {        //获取到视频信息的状态, 成功就可以进行播放, 失败代表加载失败
        if (self.avplayer.currentItem.status == AVPlayerItemStatusReadyToPlay) {   //准备好播放
                //self准备好播放
                [self readyToPlay];
                //avplayerView准备好播放
                if (self.autoPlay) {
                    [self.avplayer play];
                }else{
                    [self.avplayer pause];
                }
                [self handleEvent:LRLVideoPlayerEvent_PrepareDone error:nil];
        }else if(self.avplayer.currentItem.status == AVPlayerItemStatusFailed){    //加载失败
                [self handleEvent:LRLVideoPlayerEvent_PlayError error:self.avplayer.currentItem.error];
        }else if(self.avplayer.currentItem.status == AVPlayerItemStatusUnknown){   //未知错误
            VPDLog(@"未知错误");
            [self handleEvent:LRLVideoPlayerEvent_PlayError error:[LRLVideoPlayerTool createAErrorWithErrorDetail:@"未知错误" andErrorCode:LRLVideoPlayerErrorCode_UnKownError]];
        }
    }else if ([keyPath isEqualToString:PLAYBACKLIKELYTOKEEPUP_KEY]){ //当视频播放因为各种状态播放停止的时候, 这个属性会发生变化
        [self handleEvent:LRLVideoPlayerEvent_EndBuffer error:nil];
    }else if([keyPath isEqualToString:PLAYBACKBUFFEREMPTY_KEY]){  //当没有任何缓冲部分可以播放的时候
        [self handleEvent:LRLVideoPlayerEvent_StartBuffer error:nil];
    }else if ([keyPath isEqualToString:PLAYBACKBUFFERFULL_KEY]){
        [self handleEvent:LRLVideoPlayerEvent_EndBuffer error:nil];
    }else if([keyPath isEqualToString:PRESENTATIONSIZE_KEY]){      //获取到视频的大小的时候调用
        self.videoSize = self.avplayer.currentItem.presentationSize;
        [self handleEvent:LRLVideoPlayerEvent_GetVideoSize error:nil];
    }
}

-(AVPlayer *)createPlayer{
    if (!_avplayer) {
        self.avPlayerItems = [self getPlayItemsWithSourceItem:self.playerItems];
        if (!self.avPlayerItems.count) {
            [self handleEvent:LRLVideoPlayerEvent_PrepareDone error:[LRLVideoPlayerTool createAErrorWithErrorDetail:@"播放信息不足" andErrorCode:LRLVideoPlayerErrorCode_PrepareError]];
            return nil;
        }
        _avplayer = [AVQueuePlayer queuePlayerWithItems:self.avPlayerItems];
        _avplayer.actionAtItemEnd = AVPlayerActionAtItemEndPause;
        _isFirstPlay = YES;
        [(AVPlayerLayer *)self.avplayerView.layer setPlayer:_avplayer];
    }
    return _avplayer;
}

#pragma mark - 懒加载

-(NSMutableArray<AVPlayerItem *> *)getPlayItemsWithSourceItem:(NSArray<LRLVideoPlayerItem *> *)items{
    NSMutableArray *avItemsArr = [NSMutableArray array];
    for (LRLVideoPlayerItem *item in items) {
        if (!item.videoUrlStr || !item.videoUrlStr.length) {
            continue;
        }
        NSURL *url = [item.videoUrlStr isAbsolutePath] ? [NSURL fileURLWithPath:item.videoUrlStr] : [NSURL URLWithString:item.videoUrlStr];
        AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
        [item addObserver:self forKeyPath:PLAYER_STATUS_KEY options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [item addObserver:self forKeyPath:PLAYBACKLIKELYTOKEEPUP_KEY options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [item addObserver:self forKeyPath:PLAYBACKBUFFEREMPTY_KEY options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [item addObserver:self forKeyPath:PLAYBACKBUFFERFULL_KEY options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [item addObserver:self forKeyPath:PRESENTATIONSIZE_KEY options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoPlayEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:item];

        [avItemsArr addObject:item];
    }
    return avItemsArr;
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
