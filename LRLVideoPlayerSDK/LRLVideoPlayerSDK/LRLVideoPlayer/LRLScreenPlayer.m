//
//  LRLScreenPlayer.m
//  LRLVideoPlayerSDK
//
//  Created by liuRuiLong on 17/4/28.
//  Copyright © 2017年 liuRuiLong. All rights reserved.
//

#import "CLUPnPDevice.h"
#import "CLUPnPRenderer.h"
#import "LRLScreenPlayer.h"
#import "LRLVideoPlayerTool.h"
#import "LRLVideoPlayerItem.h"


@interface LRLScreenPlayer ()<CLUPnPResponseDelegate>

@property (strong, nonatomic) CLUPnPRenderer *render;


@end

@implementation LRLScreenPlayer
@synthesize playerItems = _playerItems;
@synthesize delegate = _delegate;
@synthesize autoPlay = _autoPlay;
@synthesize videoSize = _videoSize;
@synthesize backPlayMode = _backPlayMode;
@synthesize duration = _duration;
@synthesize position = _position;
@synthesize cacheDuration = _cacheDuration;
@synthesize currentIndex = _currentIndex;
@synthesize type = _type;

-(nonnull instancetype)initWithDelegate:(nullable id<LRLVideoPlayerCallBackDelegate>)delegate andPlayView:(nonnull UIView *)playView playItem:(nonnull NSArray<LRLVideoPlayerItem *> *)items{
    if (self = [super init]) {
        self.delegate = delegate;
        self.playerItems = items.mutableCopy;
    }
    return self;
}

-(void)prepare{
    self.render = [[CLUPnPRenderer alloc] initWithModel:nil];
    if (self.currentIndex < self.playerItems.count) {
        LRLVideoPlayerItem *currentItem = self.playerItems[self.currentIndex];
        [self.render setAVTransportURL:currentItem.videoUrlStr];
        if (self.currentIndex + 1 < self.playerItems.count) {
            LRLVideoPlayerItem *nextItem = self.playerItems[self.currentIndex + 1];
            [self.render setNextAVTransportURI:nextItem.videoUrlStr];
        }
    }
}

-(void)play{
    [self.render play];
}

-(void)playNext{
    [self.render next];
}

-(void)pause{
    [self.render pause];
}

-(void)seekTo:(float)time{
    [self.render seek:time];
}

-(void)inBackGroundMode:(BOOL)mode{
}

-(void)startPip{
    [self handleEvent:LRLVideoPlayerEvent_PlayError error:[LRLVideoPlayerTool createAErrorWithErrorDetail:@"投屏中, 不可画中画" andErrorCode:LRLVideoPlayerErrorCode_PipOpenError]];
}

-(void)stopPip{
    [self handleEvent:LRLVideoPlayerEvent_PlayError error:[LRLVideoPlayerTool createAErrorWithErrorDetail:@"投屏中, 不可画中画" andErrorCode:LRLVideoPlayerErrorCode_PipOpenError]];
}

-(void)releasePlayer{
    [self.render stop];
}

-(void)handleEvent:(LRLVideoPlayerEvent)event error:(NSError *)error{
    if ([self.delegate respondsToSelector:@selector(lrlVideoPlayerCallBackevent:errorInfo:atIndex:)]) {
        [self.delegate lrlVideoPlayerCallBackevent:event errorInfo:error atIndex:self.currentIndex];
    }
}

#pragma mark -------- <CLUPnPResponseDelegate> --------
// 设置url响应
- (void)upnpSetAVTransportURIResponse{
    
}

// 获取播放状态
- (void)upnpGetTransportInfoResponse:(CLUPnPTransportInfo *)info{
}

// 播放响应
- (void)upnpPlayResponse{
}

// 暂停响应
- (void)upnpPauseResponse{

}

// 停止投屏
- (void)upnpStopResponse{

}

// 跳转响应
- (void)upnpSeekResponse{
}

// 以前的响应
- (void)upnpPreviousResponse{

}

// 下一个响应
- (void)upnpNextResponse{

}

// 设置音量响应
- (void)upnpSetVolumeResponse{

}

// 设置下一个url响应
- (void)upnpSetNextAVTransportURIResponse{

}

// 获取音频信息
- (void)upnpGetVolumeResponse:(NSString *)volume{

}

// 获取播放进度
- (void)upnpGetPositionInfoResponse:(CLUPnPAVPositionInfo *)info{

}

// 未定义的响应/错误
- (void)upnpUndefinedResponse:(NSString *)xmlString{

}

@end


@interface LRLScreenPlayerSearcher ()<CLUPnPDeviceDelegate>

@property (strong, nonatomic) CLUPnPDevice *device;

@end

@implementation LRLScreenPlayerSearcher

-(instancetype)initWithDelegate:(id<LRLDLNADeviceSearchResultDelegate>)delegate{
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

-(void)search{
    [self.device stop];
    self.device = [[CLUPnPDevice alloc] init];
    self.device.delegate = self;
    [self.device search];
}

-(void)stop{
    [self.device stop];
    self.device = nil;
}

- (void)upnpSearchResultsWith:(CLUPnPModel *)model{
    LRLDLNADevice *device;
    [self.delegate searchResultsWith:device];
}

- (void)upnpSearchErrorWith:(NSError *)error{
    if ([self.delegate respondsToSelector:@selector(searchErrorWith:)]) {
        [self.delegate searchErrorWith:error];
    }
}

@end

