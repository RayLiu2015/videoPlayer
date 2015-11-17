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
    self.avplayerView = [LRLAVPlayerView avplayerViewWithVideoUrlStr:@"http://f01.v1.cn/group2/M00/01/62/ChQB0FWBQ3SAU8dNJsBOwWrZwRc350-m.mp4" andInitialHeight:200.0 andSuperView:self.view];
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

- (IBAction)destoryButtonClicked:(id)sender {
    [self.avplayerView destoryAVPlayer];
}
- (IBAction)playButtonClicked:(id)sender {
    [self.avplayerView replay];
}

-(void)dealloc{
    NSLog(@"test controller dealloc");
    [self.avplayerView destoryAVPlayer];
    self.avplayerView = nil;
}
@end
