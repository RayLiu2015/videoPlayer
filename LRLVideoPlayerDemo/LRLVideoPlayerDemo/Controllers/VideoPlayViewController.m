//
//  VideoPlayViewController.m
//  Demo_LehaiMediaPlayer
//
//  Created by liuRuiLong on 16/8/4.
//  Copyright © 2016年 xianghui. All rights reserved.
//

#import "Tool.h"
#import "VideoPlayViewController.h"

@interface VideoPlayViewController ()<LMPMediaPlayerDelegate>

@property (strong, nonatomic) LMPMediaPlayer *mediaPlayer;

@property (assign, nonatomic) BOOL sliderValueChanging;

@property (strong, nonatomic) UIView *mediaPlayView;

@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;

@property (weak, nonatomic) IBOutlet UIProgressView *videoPlayProgress;

@property (weak, nonatomic) IBOutlet UIView *playBackView;

@property (weak, nonatomic) IBOutlet UISlider *videoPlaySlider;

@property (weak, nonatomic) IBOutlet UIView *controlBackView;

@property (weak, nonatomic) IBOutlet UILabel *backGroundLabel;

@property (weak, nonatomic) IBOutlet UISwitch *backGroundSwitch;

@end

@implementation VideoPlayViewController

-(void)dealloc{
    [self.mediaPlayer stop];
    [self.mediaPlayer releasePlayer];
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //UI
    self.backGroundLabel.text = [LMPPlayerService playInBackgroundStatus] ? @"后台模式" : @"非后台模式";
    self.backGroundSwitch.on = [LMPPlayerService playInBackgroundStatus];
    if (self.sourceType != LMPPlaySourceTypeProgramId) {
        if (self.playUrlType != LMPPlayUrlTypeVod) {
            self.videoPlaySlider.hidden = YES;
            self.videoPlayProgress.hidden = YES;
        }
    }
    
    if (self.sourceType == LMPPlaySourceTypeProgramId) { //使用 ProgramId 进行播放
        LMPMediaPlayer *player = [LMPCachePlayerManager cachePlayer:self.programId];
        if (player) {
            self.mediaPlayer = player;
            self.mediaPlayer.delegate = self;
            [player play];
        }else{
            LMPParameterModel *parameterModel = [[LMPParameterModel alloc] init];
            parameterModel.programId = self.programId;
            self.mediaPlayer = [[LMPMediaPlayer alloc] init];
            self.mediaPlayer.parameterModel = parameterModel;
            self.mediaPlayer.delegate = self;
            [self.mediaPlayer prepare];
        }
    }else if (self.sourceType == LMPPlaySourceTypeCDEUrl){ //使用CDE进行处理Url进行播放
        LMPParameterModel *paraModel = [[LMPParameterModel alloc] init];
        paraModel.playSourceType = LMPPlaySourceTypeCDEUrl;
        paraModel.playUrl = self.playUrl;
        paraModel.playUrlType = self.playUrlType;
        LMPMediaPlayer *player = [[LMPMediaPlayer alloc] init];
        player.parameterModel = paraModel;
        player.delegate = self;
        [player prepare];
        self.mediaPlayer = player;
    }else if (self.sourceType == LMPPlaySourceTypeUrl){ //使用url进行播放
        LMPParameterModel *paraModel = [[LMPParameterModel alloc] init];
        paraModel.playSourceType = LMPPlaySourceTypeUrl;
        paraModel.playUrlType = self.playUrlType;
        paraModel.playUrl = self.playUrl;
        LMPMediaPlayer *player = [[LMPMediaPlayer alloc] init];
        player.delegate = self;
        player.parameterModel = paraModel;
        [player prepare];
        self.mediaPlayer = player;
    }
}

#pragma mark - LMPMediaPlayerDelegate
- (void)mediaPlayer:(LMPMediaPlayer *)mediaPlayer createPlayerSuccess:(BOOL)success previewView:(UIView *)previewView error:(NSError *)error{
    if (success) {
        self.mediaPlayView = previewView;
        NSLog(@" --- 进行添加了播放视图: %@ --- ", previewView);
        [self.playBackView addSubview:self.mediaPlayView];
    }else{
        NSString *errorDetail = [NSString stringWithFormat:@"errorCode: %ld, 失败原因: %@", (long)error.code, error.localizedDescription];
        [Tool showAlertTitle:@"播放失败" message:errorDetail];
    }
}

- (void)mediaPlayer:(LMPMediaPlayer *)mediaPlayer getVideoSize:(CGSize)videoSize{
    //根据 视频比例 和 屏幕宽度 进行放置视图
    NSLog(@"video size: %@", NSStringFromCGSize(videoSize));
    
    //屏幕尺寸
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat showHeight = screenSize.width * (videoSize.height/videoSize.width);
    self.mediaPlayView.frame = CGRectMake(0, (screenSize.height - showHeight)/2, screenSize.width, showHeight);
}

- (void)mediaPlayerPrepareDone:(LMPMediaPlayer *)mediaPlayer{
    self.mediaPlayer.volume = 1.0;
    [self.mediaPlayer play];
}

- (void)mediaPlayerDidStartPlay:(LMPMediaPlayer *)mediaPlayer timeConsuming:(NSTimeInterval)timeConsuming{
    self.controlBackView.hidden = NO;
}

- (void)mediaPlayerPlaying:(LMPMediaPlayer *)mediaPlayer playProgress:(CGFloat)progress{
    if (!self.sliderValueChanging) {
        self.videoPlaySlider.value = progress;
    }
}

- (void)mediaPlayerPlayFinished:(LMPMediaPlayer *)mediaPlayer{
    [Tool showAlertTitle:@"播放结束" message:nil];
}

- (void)mediaPlayerReleaseDone:(LMPMediaPlayer *)mediaPlayer{
}

- (void)mediaPlayerStartBuffer:(LMPMediaPlayer *)mediaPlayer{
    NSLog(@" -- 开始 loading -- ");
    [self.indicatorView startAnimating];
}

- (void)mediaPlayerEndBuffer:(LMPMediaPlayer *)mediaPlayer{
    NSLog(@" -- 结束 loading -- ");
    [self.indicatorView stopAnimating];
}

- (void)mediaPlayer:(LMPMediaPlayer *)mediaPlayer playError:(NSError *)error{
    NSString *errorDetail = [NSString stringWithFormat:@"errorCode: %ld, 失败原因: %@", (long)error.code, error.localizedDescription];
    [Tool showAlertTitle:@"播放失败" message:errorDetail];
}

- (void)mediaPlayerCanPlayNoScalled:(LMPMediaPlayer *)mediaPlayer{
    [self.indicatorView stopAnimating];
}


#pragma mark - UI 以及 交互
-(UIActivityIndicatorView *)indicatorView{
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicatorView.frame = CGRectMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2, 0, 0);
        [self.view addSubview:_indicatorView];
    }
    return _indicatorView;
}

- (IBAction)backgroundModeChange:(id)sender {
    UISwitch *swi = (UISwitch *)sender;
    if (swi.on) {
        self.backGroundLabel.text = @"后台模式";
        self.mediaPlayer.playInBackGroundMode = YES;
    }else{
        self.backGroundLabel.text = @"非后台模式";
        self.mediaPlayer.playInBackGroundMode = NO;
    }
}

- (IBAction)sliderValueChanged:(id)sender {
    self.sliderValueChanging = YES;
}
- (IBAction)sliderTouchUpInside:(id)sender {
    self.sliderValueChanging = NO;
    [self.mediaPlayer seekToPosition:self.mediaPlayer.duration * self.videoPlaySlider.value];
}
- (IBAction)play:(id)sender {
    [self.mediaPlayer play];
}
- (IBAction)pause:(id)sender {
    [self.mediaPlayer pause];
}
- (IBAction)stop:(id)sender {
    [self.mediaPlayer stop];
}
- (IBAction)resume:(id)sender {
    [self.mediaPlayer resume];
}

@end
