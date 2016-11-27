//
//  VideoPlayViewController.m
//  Demo_LehaiMediaPlayer
//
//  Created by liuRuiLong on 16/8/4.
//  Copyright © 2016年 xianghui. All rights reserved.
//

#import "VideoPlayViewController.h"
#import <LRLVideoPlayerSDK/LRLVideoPlayerSDK.h>

@interface VideoPlayViewController ()


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
    self.backGroundLabel.text = @"";
    self.backGroundSwitch.on = YES;
    self.videoPlaySlider.hidden = YES;
    self.videoPlayProgress.hidden = YES;
    
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
    }else{
        self.backGroundLabel.text = @"非后台模式";
    }
}

- (IBAction)sliderValueChanged:(id)sender {
    self.sliderValueChanging = YES;
}

- (IBAction)sliderTouchUpInside:(id)sender {
    self.sliderValueChanging = NO;
}

- (IBAction)play:(id)sender {
}

- (IBAction)release:(id)sender {
}

- (IBAction)pause:(id)sender {
}

- (IBAction)pip:(id)sender {
}

@end
