//
//  TestViewController.m
//  
//
//  Created by 刘瑞龙 on 15/10/10.
//
//

#import "TestViewController.h"
#import "LRLAVPlayerView.h"

@interface TestViewController ()<LRLAVPlayDelegate>
@property (nonatomic, strong) LRLAVPlayerView * avplayerView;
@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createAVPlayerView];
}

#pragma mark - 创建用于播放的View
-(void)createAVPlayerView{
    self.avplayerView = [LRLAVPlayerView avplayerViewWithVideoUrlStr:@"http://m3u8back.gougouvideo.com/m3u8_yyyy?i=4275259" andInitialHeight:200.0 andSuperView:self.view];
    self.avplayerView.delegate = self;
    [self.view addSubview:self.avplayerView];
    __weak TestViewController * weakSelf = self;
    [self.avplayerView setPositionWithPortraitBlock:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.view).with.offset(60);
        make.left.equalTo(weakSelf.view);
        make.right.equalTo(weakSelf.view);
        make.height.equalTo(@(*(weakSelf.avplayerView->_videoHeight)));
    } andLandscapeBlock:^(MASConstraintMaker *make) {
        make.width.equalTo(@(SCREEN_HEIGHT));
        make.height.equalTo(@(SCREEN_WIDTH));
        make.center.equalTo(weakSelf.view);
    }];
}
//暂时销毁
- (IBAction)destoryButtonClicked:(id)sender {
    [self.avplayerView destoryAVPlayer];
}
//根据原销毁位置, 继续播放
- (IBAction)playButtonClicked:(id)sender {
    [self.avplayerView replay];
}
//不用时, 要释放播放器
-(void)dealloc{
    NSLog(@"test controller dealloc");
    [self.avplayerView destoryAVPlayer];
    self.avplayerView = nil;
}
#pragma mark - 关闭设备自动旋转, 然后手动监测设备旋转方向来旋转avplayerView
-(BOOL)shouldAutorotate{
    return NO;
}

@end
