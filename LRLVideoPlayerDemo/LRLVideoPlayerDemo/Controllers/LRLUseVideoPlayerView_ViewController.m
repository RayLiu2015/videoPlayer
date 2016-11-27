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

@interface LRLUseVideoPlayerView_ViewController ()<LRLAVPlayDelegate>

//用来播放视频的view
@property (nonatomic, strong) LRLVideoPlayerView * player;

@end

@implementation LRLUseVideoPlayerView_ViewController
//注意, 要实现正常的旋转屏, 设置处的旋转屏幕开启 上, 左, 右, 而代码中需要控制关闭设备自动旋转, 然后我在内部的实现是: 然后手动监测设备旋转方向来旋转avplayerView, 你要做的是各种视图控制器 实现:
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

//播放器所用的图片资源, 在压缩包里的 Resource 文件夹下有一份
//代码全在在LRLAVPlayer文件夹下

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor darkGrayColor];
}
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
}

#pragma mark - 创建用于播放的View
-(void)createAVPlayerView{
    //固定的实例化方法
    NSString *url = @"http://hc.yinyuetai.com/uploads/videos/common/B65B013CF61E82DC9766E8BDEEC8B602.flv?sc=8cafc5714c8a6265";
    //@"http://hc.yinyuetai.com/uploads/videos/common/1E6C015157BDE4808FCA91F8816299AF.flv?sc=022ea7aef9289b80"
    self.player = [LRLVideoPlayerView avplayerViewWithVideoUrlStr:url andInitialHeight:200.0 andSuperView:self.view];
    self.player.delegate = self;
    [self.view addSubview:self.player];
    __weak LRLAVPlayerController * weakSelf = self;
    //我的播放器依赖 Masonry 第三方库
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
}

#pragma mark - 关闭设备自动旋转, 然后手动监测设备旋转方向来旋转avplayerView
-(BOOL)shouldAutorotate{
    return NO;
}

@end
