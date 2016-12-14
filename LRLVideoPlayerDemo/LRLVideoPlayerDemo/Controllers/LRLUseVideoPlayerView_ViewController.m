//
//  LRLAVPlayerController.m
//  
//
//  Created by 刘瑞龙 on 15/9/10.
//
//

#import <AVKit/AVKit.h>
#import <MediaPlayer/MediaPlayer.h>

#import "LRLVideoPlayerView.h"
#import "LRLUseVideoPlayerView_ViewController.h"

/*
 这个控制器展示的是LRLVideoPlayerView的使用, LRLVideoPlayerView是对LRLVideoPlayerSDK的UI封装,  LRLVideoPlayerSDK 也可直接进行使用
 */

@interface LRLUseVideoPlayerView_ViewController ()<LRLAVPlayDelegate>

//用来播放视频的view
@property (nonatomic, strong) LRLVideoPlayerView * player;

@end

@implementation LRLUseVideoPlayerView_ViewController

//注意, 要实现正常的旋转屏, 设置处的旋转屏幕开启 上, 左, 右, 而代码中需要控制关闭设备自动旋转, 然后我在内部的实现是: 然后手动监测设备旋转方向来旋转 LRLVideoPlayerView
/*
 -(BOOL)shouldAutorotate{
    return NO;
 }
 */

//还有AppDelegate中实现:
/*
 -(UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
 return self.window.rootViewController.supportedInterfaceOrientations;
 }
 */


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor darkGrayColor];
}

#pragma mark - 创建用于播放的View
-(void)createAVPlayerView{
    LRLVideoPlayerItem *item1 = [[LRLVideoPlayerItem alloc] init];
    item1.videoUrlStr = @"http://hc.yinyuetai.com/uploads/videos/common/B65B013CF61E82DC9766E8BDEEC8B602.flv?sc=8cafc5714c8a6265";
    
    LRLVideoPlayerItem *item2 = [[LRLVideoPlayerItem alloc] init];
    item2.videoUrlStr = @"http://baobab.wdjcdn.com/1463028607774b.mp4";
    
    LRLVideoPlayerItem *item3 = [[LRLVideoPlayerItem alloc] init];
    item3.videoUrlStr = @"http://hc.yinyuetai.com/uploads/videos/common/331C015823B0F4E886170714CD9062FD.flv?sc=8f526db9deea29c8";
    
    LRLVideoPlayerItem *item4 = [[LRLVideoPlayerItem alloc] init];
    item4.videoUrlStr = @"http://hc.yinyuetai.com/uploads/videos/common/76840156C5FC70B48E22172396283ABA.flv?sc=fe29e57cf9e45fa3";
    
    //, item2, item3, item4
    self.player = [LRLVideoPlayerView avplayerViewWithPlayItems:@[item1, item2, item3, item4] andInitialHeight:200.0 andSuperView:self.view];

    self.player.backPlayMode = NO;
    self.player.delegate = self;
    [self.view addSubview:self.player];
    __weak LRLUseVideoPlayerView_ViewController * weakSelf = self;
    //播放器的外层UI封装部分依赖 Masonry 第三方库
    [self.player setPositionWithPortraitBlock:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.view).with.offset(60);
        make.left.equalTo(weakSelf.view);
        make.right.equalTo(weakSelf.view);
        //添加竖屏时的限制, 这条也是固定的, 因为: _videoHeight 是float* 类型, 我可以通过它, 动态改视频播放器的高度;
        make.height.equalTo(@(*(weakSelf.player.videoHeight)));
    } andLandscapeBlock:^(MASConstraintMaker *make) {
        make.width.equalTo(@(SCREEN_HEIGHT));
        make.height.equalTo(@(SCREEN_WIDTH));
        make.center.equalTo(weakSelf.view);
    }];
    [self.player prepare];
}

#pragma mark - act
//播放
- (IBAction)playButtonClicked:(id)sender {
    if (!self.player) {
        [self createAVPlayerView];
    }else{
    }
}
//销毁
- (IBAction)destoryButton:(id)sender {
    [self.player releasePlayer];
    [self.player removeFromSuperview];
    self.player = nil;
}

- (IBAction)startPiP:(id)sender {
    [self.player startPip];
}

- (IBAction)playInBack:(id)sender {
    if (!self.player) {
        return;
    }
    UIButton *button = (UIButton *)sender;
    if (button.selected) {
        button.selected = NO;
        self.player.backPlayMode = NO;
    }else{
        button.selected = YES;
        self.player.backPlayMode = YES;
        
    }
}

#pragma mark - 关闭设备自动旋转, 然后手动监测设备旋转方向来旋转avplayerView
-(BOOL)shouldAutorotate{
    return NO;
}

@end
