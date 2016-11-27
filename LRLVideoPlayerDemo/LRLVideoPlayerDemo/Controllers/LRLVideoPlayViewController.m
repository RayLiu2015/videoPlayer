//
//  LRLVideoPlayViewController.m
//  LRLAVPlayerDemo
//
//  Created by liuRuiLong on 2016/11/26.
//  Copyright © 2016年 codeWorm. All rights reserved.
//

#import "LRLVideoPlayViewController.h"
#import <LRLVideoPlayerSDK/LRLVideoPlayerSDK.h>

@interface LRLVideoPlayViewController ()<LRLVideoPlayerDelegate>

@property (strong, nonatomic) LRLVideoPlayer *videoPlayer;

@property (strong, nonatomic) UIView *playView;

@end

@implementation LRLVideoPlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
}

- (IBAction)playAct:(id)sender {
    
    
    
    LRLVideoPlayerItem *item = [[LRLVideoPlayerItem alloc] init];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"mp4"];
    item.videoUrlStr = filePath;
//    @"http://baobab.wdjcdn.com/1463028607774b.mp4";
    //    @"http://baobab.wdjcdn.com/1463028607774b.mp4";
    
    self.videoPlayer = [[LRLVideoPlayer alloc] initWithDelegate:self playerType:LRLVideoPlayerType_AVPlayer playItem:item];
    
    self.playView = self.videoPlayer.playView;
    self.playView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:self.playView];

    self.videoPlayer.autoPlay = YES;
    self.videoPlayer.backPlayMode = YES;
    [self.videoPlayer prepare];

}

-(void)lrlVideoPlayer:(LRLVideoPlayer *)player event:(LRLVideoPlayerEvent)event errorInfo:(NSError *)errorInfo{
    
    if (event == LRLVideoPlayerEvent_GetVideoSize) {
        CGSize size = [UIScreen mainScreen].bounds.size;
        CGSize videoSize = CGSizeMake(size.width, size.width * player.videoSize.height /player.videoSize.width);
        CGFloat topDistance = (size.height - videoSize.height)/2;
        self.playView.frame = CGRectMake(0, topDistance, videoSize.width, videoSize.height);
        NSLog(@"%@", NSStringFromCGRect(self.playView.frame));
    }
    if (errorInfo) {
        NSLog(@"error");
    }
}

-(void)lrlVideoPlayer:(LRLVideoPlayer *)player position:(float)position cacheDuration:(float)cacheDuration duration:(float)duration{
    NSLog(@"--position: %f -- cacheDuraiton: %f-- duration: %f", position, cacheDuration, duration);
}
@end
