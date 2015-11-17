//
//  LRLAVPlayerController.m
//  
//
//  Created by 刘瑞龙 on 15/9/10.
//
//

#import <MediaPlayer/MediaPlayer.h>

#import "LRLAVPlayerView.h"
#import "TestViewController.h"
#import "LRLAVPlayerController.h"

@interface LRLAVPlayerController ()<LRLAVPlayDelegate>

//用来播放视频的view
@property (nonatomic, strong) LRLAVPlayerView * avplayerView;

@end

@implementation LRLAVPlayerController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor darkGrayColor];
    //创建用来播放视频的View, 应用的是这个view的layer层进行视频的播放
//    [self createAVPlayerView];
}

#pragma mark - 创建用于播放的View
-(void)createAVPlayerView{
    self.avplayerView = [LRLAVPlayerView avplayerViewWithVideoUrlStr:@"http://f01.v1.cn/group2/M00/01/62/ChQB0FWBQ3SAU8dNJsBOwWrZwRc350-m.mp4" andInitialHeight:200.0 andSuperView:self.view];
    self.avplayerView.delegate = self;
    [self.view addSubview:self.avplayerView];
    __weak LRLAVPlayerController * weakSelf = self;
    [self.avplayerView setPositionWithPortraitBlock:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.view).with.offset(60);
        make.left.equalTo(weakSelf.view);
        make.right.equalTo(weakSelf.view);
        make.height.equalTo(@(*(weakSelf.avplayerView->_videoHeight)));
    } andLandscapeBlock:^(MASConstraintMaker *make) {
        make.width.equalTo(@(SCREEN_HEIGHT));
        make.height.equalTo(@(SCREEN_WIDTH));
        make.center.equalTo(Window);
    }];
}


#pragma mark - 关闭设备自动旋转, 然后手动监测设备旋转方向来旋转avplayerView
-(BOOL)shouldAutorotate{
    return NO;
}

- (IBAction)nextPage:(id)sender {
    TestViewController * test = [[TestViewController alloc] init];
    [self.navigationController pushViewController:test animated:YES];
}
- (IBAction)playButtonClicked:(id)sender {
    [self createAVPlayerView];
}
- (IBAction)destoryButton:(id)sender {
    [self.avplayerView destoryAVPlayer];
    [self.avplayerView removeFromSuperview];
    self.avplayerView = nil;
}

@end
