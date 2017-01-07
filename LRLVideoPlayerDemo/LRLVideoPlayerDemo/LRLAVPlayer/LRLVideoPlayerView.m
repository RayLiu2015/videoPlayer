//
//  AVPlayerView.m
//
//
//  Created by 刘瑞龙 on 15/9/10.
//
//

#import "AppDelegate.h"
#import "LRLLightView.h"
#import "TimeSheetView.h"
#import "LRLVideoPlayerView.h"

#import <MediaPlayer/MediaPlayer.h>

typedef enum : NSUInteger {
    progressControl,
    voiceControl,
    lightControl,
    noneControl = 999,
} ControlType;

@interface LRLVideoPlayerView ()<UIGestureRecognizerDelegate, LRLVideoPlayerDelegate>
{
    //用来控制上下菜单view隐藏的timer
    NSTimer * _hiddenTimer;
    //用来判断手势是否移动过
    BOOL _hasMoved;
    //判断是否已经判断出手势划的方向
    BOOL _controlJudge;
    //触摸开始触碰到的点
    CGPoint _touchBeginPoint;
    //记录触摸开始时的视频播放的时间
    float _touchBeginValue;
    //记录触摸开始亮度
    float _touchBeginLightValue;
    //记录触摸开始的音量
    float _touchBeginVoiceValue;
    //音量控制控件
    MPVolumeView * _volumeView;
    //用这个来控制音量
    UISlider * _volumeSlider;
    //这个用来显示滑动屏幕时的时间
    TimeSheetView * _timeView;
    //给slider添加的手势
    UITapGestureRecognizer * _tap;
    //用来判断是否为全屏状态
    BOOL _isFullScreen;
    //用来规定是否可以全屏
    BOOL _canFullScreen;
    //判断是否为第一次布局
    BOOL _isFisrtConfig;
    //是否自动播放
    BOOL _autoPlay;
}

/**
 @b 用于显示播放到第几个视频
 */
@property (weak, nonatomic) IBOutlet UILabel *playItemIndexLabel;

/**
 *  @b 右下角的那个控制全屏的button
 */
@property (weak, nonatomic) IBOutlet UIButton *exitOrInScreenBt;

/**
 *  @b 全屏状态下,左上角的那个退出全屏的button
 */
@property (weak, nonatomic) IBOutlet UIButton *exitScreenBtn;

/**
 *  @b 视频的缓冲进度条
 */
@property (weak, nonatomic) IBOutlet UIProgressView *videoProgressView;

/**
 *  @b 视频进度滑块
 */
@property (weak, nonatomic) IBOutlet UISlider *videoSlider;

/**
 *  @b 播放或者暂停按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *playOrPauseBtn;

/**
 *  @b 显示总时间的label
 */
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;

/**
 *  @b 用来显示时间的label
 */
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

/**
 *  @b 旋转的菊花
 */
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *actIndicator;

/**
 *  @b 上侧的菜单view, 触屏时做显示隐藏操作
 */
@property (weak, nonatomic) IBOutlet UIView *topView;

/**
 *  @b 下侧的菜单view, 触屏时做显示隐藏操作
 */
@property (weak, nonatomic) IBOutlet UIView *bottomView;

/**
 *  @b 视图添加了一层透明的涂层, 用来响应手势
 */
@property (weak, nonatomic) IBOutlet UIView *clearView;

/**
 *  @b 亮度view
 */
@property (nonatomic, strong) LRLLightView * lightView;

/**
 *  @b 给显示亮度的view添加毛玻璃效果
 */
@property (nonatomic, strong) UIVisualEffectView * effectView;


/**
 *  @b 这个是用来判断当前手势是在控制进度还是声音,还是亮度;
 */
@property (nonatomic, assign) ControlType controlType;

/**
 * @b 判断滑块是否在拖动
 */
@property (nonatomic, assign) BOOL sliderValueChanging;

/**
 * @b 这个是用来切换全屏时, 将self添加到不同的位置
 */
@property (nonatomic, weak) UIView *playerSuperView;

/**
 * @b 竖屏的限制block
 */
@property (nonatomic, copy) LayoutBlock portraitBlock;

/**
 * @b 横屏的限制block
 */
@property (nonatomic, copy) LayoutBlock landscapeBlock;

/**
 @b whether auto play when initial video player
 */
@property (assign, nonatomic) BOOL autoPlay;

@property (strong, nonatomic) LRLVideoPlayer *videoPlayer;

@property (strong, nonatomic) UIView *playView;


@property (strong, nonatomic) NSMutableArray<LRLVideoPlayerItem *> *playItems;

@end

@implementation LRLVideoPlayerView

#pragma mark - life cycle
-(void)dealloc{
    NSLog(@"LRLVideoPlayerView dealloc");
    if (self.videoPlayer) {
        [self releasePlayer];
    }
}

+(LRLVideoPlayerView *)avplayerViewWithPlayItems:(NSArray<LRLVideoPlayerItem *> *)playItems andInitialHeight:(float)height andSuperView:(UIView *)superView{
    static float videoHeight = 0.0;
    videoHeight = height;
    LRLVideoPlayerView * view = [[NSBundle mainBundle] loadNibNamed:@"LRLVideoPlayerView" owner:nil options:nil].lastObject;
    view.playItems = [NSMutableArray arrayWithArray:playItems];
    view.autoPlay = YES;
    view.videoHeight = &videoHeight;
    view.playerSuperView = superView;
    [view congfigUI];
    [view createPlayer];
    return view;
}

#pragma mark - public
-(void)setPositionWithPortraitBlock:(LayoutBlock)porBlock andLandscapeBlock:(LayoutBlock)landscapeBlock{
    self.portraitBlock = porBlock;
    self.landscapeBlock = landscapeBlock;
    [self mas_makeConstraints:porBlock];
}

-(void)prepare{
    self.videoPlayer.backPlayMode = self.backPlayMode;
    [self.videoPlayer prepare];
}

-(void)play{
    [self.videoPlayer play];
    [self.playOrPauseBtn setBackgroundImage:[UIImage imageNamed:@"ad_pause_f_p"] forState:UIControlStateNormal];
    _isPlaying = YES;
}

-(void)pause{
    [self.videoPlayer pause];
    [self.playOrPauseBtn setBackgroundImage:[UIImage imageNamed:@"ad_play_f_p"] forState:UIControlStateNormal];
    _isPlaying = NO;
}

-(void)startPip{
    [self.videoPlayer startPip];
}

-(void)stopPip{
    [self.videoPlayer stopPip];
}

-(void)releasePlayer{
    self.landscapeBlock = nil;
    self.portraitBlock = nil;
    if (_hiddenTimer) {
        [_hiddenTimer invalidate];
        _hiddenTimer = nil;
    }
    
    [self.videoPlayer releasePlayer];
    self.videoPlayer = nil;
}

-(void)setBackPlayMode:(BOOL)backPlayMode{
    _backPlayMode = backPlayMode;
    self.videoPlayer.backPlayMode = backPlayMode;
}

#pragma mark - config UI
-(void)congfigUI{
    //从xib唤醒的时候初始化一下值
    [self initialSelfView];
    
    //对xib拖拽的progressView和Slider重新布局
    [self reConfigSlider];
    
    //创建控制声音的MPVolumeView
    [self createVolumeView];
    
    //创建显示亮度的View
    [self createLightView];
    
    //创建用于显示时间的view
    [self createTimeView];
    
    //添加手势
    [self addGesture];
}


-(void)initialSelfView{
    [self startBuffer];
    if (self.autoPlay) {
        self.playOrPauseBtn.selected = YES;
    }else{
        self.playOrPauseBtn.selected = NO;
    }
    self.userInteractionEnabled = NO;
    self.multipleTouchEnabled = YES;
    self.exitScreenBtn.hidden = YES;
    self.controlType = noneControl;
    _isFisrtConfig = YES;
    _canFullScreen = NO;
    _isFullScreen = NO;
}

//对xib拖拽的progressView和Slider重新布局
-(void)reConfigSlider{
    [self.videoSlider setThumbImage:[UIImage imageNamed:@"movieTicketsPayType_select"] forState:UIControlStateNormal];
    [self.videoSlider setThumbImage:[UIImage imageNamed:@"movieTicketsPayType_select"] forState:UIControlStateHighlighted];
    self.videoSlider.maximumTrackTintColor = [UIColor clearColor];
    self.videoProgressView.userInteractionEnabled = YES;
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(progressTapAct:)];
    _tap.numberOfTapsRequired = 1;
    _tap.numberOfTouchesRequired = 1;
    [self.videoSlider addGestureRecognizer:_tap];
}

// 创建控制声音的控制器, 通过self.volumeSlider来控制声音
-(void)createVolumeView{
    _volumeView = [[MPVolumeView alloc] init];
    _volumeView.showsRouteButton = NO;
    _volumeView.showsVolumeSlider = NO;
    for (UIView * view in _volumeView.subviews) {
        if ([NSStringFromClass(view.class) isEqualToString:@"MPVolumeSlider"]) {
            _volumeSlider = (UISlider *)view;
            break;
        }
    }
    [self addSubview:_volumeView];
}

// 用来创建用来显示亮度的view
-(void)createLightView{
    Window.translatesAutoresizingMaskIntoConstraints = NO;
    __weak LRLVideoPlayerView * weakSelf = self;
    if (iOS8) {
        UIBlurEffect * blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        _effectView = [[UIVisualEffectView alloc] initWithEffect:blur];
        _effectView.alpha = 0.0;
        _effectView.contentView.layer.cornerRadius = 10.0;
        _effectView.layer.masksToBounds = YES;
        _effectView.layer.cornerRadius = 10.0;
        
        self.lightView = [[NSBundle mainBundle] loadNibNamed:@"LRLLightView" owner:self options:nil].lastObject;
        self.lightView.translatesAutoresizingMaskIntoConstraints = NO;
        self.lightView.alpha = 0.0;
        [_effectView.contentView addSubview:self.lightView];
        
        [self.lightView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(weakSelf.effectView);
        }];

        [self.playerSuperView addSubview:_effectView];
        [self.effectView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.effectView.superview);
            make.width.equalTo(@(155));
            make.height.equalTo(@155);
        }];
    }else{
        self.lightView = [[NSBundle mainBundle] loadNibNamed:@"LRLLightView" owner:self options:nil].lastObject;
        self.lightView.translatesAutoresizingMaskIntoConstraints = NO;
        self.lightView.alpha = 0.0;
        [self.playerSuperView addSubview:self.lightView];
        [self.lightView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(weakSelf.lightView.superview);
            make.width.equalTo(@(155));
            make.height.equalTo(@155);
        }];
    }
    
}

// 创建拖动屏幕时, 显示时间的view
-(void)createTimeView{
    _timeView = [[NSBundle mainBundle] loadNibNamed:@"TimeSheetView" owner:self options:nil].lastObject;
    _timeView.hidden = YES;
    _timeView.layer.cornerRadius = 10.0;
    [self addSubview:_timeView];
    
    __weak LRLVideoPlayerView * weakSelf = self;
    [_timeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(weakSelf);
        make.width.equalTo(@(120));
        make.height.equalTo(@60);
    }];
}

#pragma mark - act
-(void)addGesture{
    UITapGestureRecognizer * twiceTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAct:)];
    twiceTap.numberOfTapsRequired = 2;
    twiceTap.numberOfTouchesRequired = 1;
    twiceTap.delegate = self;
    [self.clearView addGestureRecognizer:twiceTap];
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    AVDLog(@"gestureRecognizer shouldReceiveTouch");
    if (_controlJudge) {
        return NO;
    }else{
        return YES;
    }
}

// 给进度条加的手势
-(void)progressTapAct:(UITapGestureRecognizer *)tap{
    AVDLog(@"slider tap !");
    CGPoint location = [tap locationInView:self.videoSlider];
    float value = location.x/self.videoSlider.bounds.size.width * self.duration;
    [self seekToTheTimeValue:value];
    [self controlViewOutHidden];
}

-(void)tapAct:(UITapGestureRecognizer *)tap{
    //点击一次
    if (tap.numberOfTapsRequired == 1) {
    }else if(tap.numberOfTapsRequired == 2){
        [self playOrPause];
    }
}
// 点击播放或者暂停按钮
- (IBAction)playOrPauseButtonClicked:(id)sender {
    [self playOrPause];
}

//拖动滑块时触发的方法
- (IBAction)sliderTouching:(id)sender {
    _sliderValueChanging = YES;
    _tap.enabled = NO;
    [self controlViewOutHidden];
}
- (IBAction)sliderValueChanged:(id)sender {
    AVDLog(@"inside value change");
    [self seekToTheTimeValue:self.videoSlider.value];
    _tap.enabled = YES;
    _sliderValueChanging = NO;
}

- (IBAction)startPiP:(id)sender {
    [self.videoPlayer startPip];
}
- (IBAction)nextVideo:(id)sender {
    [self.videoPlayer playNext];
}

#pragma mark - touch
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{   //触摸开始
    //这个是用来判断, 如果有多个手指点击则不做出响应
    UITouch * touch = (UITouch *)touches.anyObject;
    if (touches.count > 1 || [touch tapCount] > 1 || event.allTouches.count > 1) {
        return;
    }
    //这个是用来判断, 手指点击的是不是本视图, 如果不是则不做出响应
    if (![[(UITouch *)touches.anyObject view] isEqual:self.clearView] &&  ![[(UITouch *)touches.anyObject view] isEqual:self]) {
        return;
    }
    [super touchesBegan:touches withEvent:event];
    AVDLog(@"touch : touch begin %ld", touch.tapCount);

    //触摸开始, 初始化一些值
    _hasMoved = NO;
    _controlJudge = NO;
    _touchBeginValue = self.videoSlider.value;
    _touchBeginVoiceValue = _volumeSlider.value;
    _touchBeginLightValue = [UIScreen mainScreen].brightness;
    _touchBeginPoint = [touches.anyObject locationInView:self];
    
}
//触摸过程中
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch * touch = (UITouch *)touches.anyObject;
    if (touches.count > 1 || [touch tapCount] > 1  || event.allTouches.count > 1) {
        return;
    }
    if (![[(UITouch *)touches.anyObject view] isEqual:self.clearView] && ![[(UITouch *)touches.anyObject view] isEqual:self]) {
        return;
    }
    [super touchesMoved:touches withEvent:event];
    AVDLog(@"touch : touch move, tap count: %ld", touch.tapCount);

    //如果移动的距离过于小, 就判断为没有移动
    CGPoint tempPoint = [touches.anyObject locationInView:self];
    if (fabs(tempPoint.x - _touchBeginPoint.x) < LeastDistance && fabs(tempPoint.y - _touchBeginPoint.y) < LeastDistance) {
        return;
    }
    _hasMoved = YES;
    //如果还没有判断出使什么控制手势, 就进行判断
    if (!_controlJudge) {
        //滑动角度的tan值
        float tan = fabs(tempPoint.y - _touchBeginPoint.y)/fabs(tempPoint.x - _touchBeginPoint.x);
        if (tan < 1/sqrt(3)) {    //当滑动角度小于30度的时候, 进度手势
            _controlType = progressControl;
            _controlJudge = YES;
        }else if(tan > sqrt(3)){  //当滑动角度大于60度的时候, 声音和亮度
            //判断是在屏幕的左半边还是右半边滑动, 左侧控制为亮度, 右侧控制音量
            if (_touchBeginPoint.x < self.bounds.size.width/2) {
                _controlType = lightControl;
            }else{
                _controlType = voiceControl;
            }
            _controlJudge = YES;
        }else{     //如果是其他角度则不是任何控制
            _controlType = noneControl;
            return;
        }
    }
    
    if (_controlType == progressControl) {     //如果是进度手势
        float value = [self moveProgressControllWithTempPoint:tempPoint];
        [self timeValueChangingWithValue:value];
    }else if(_controlType == voiceControl){    //如果是音量手势
        //根据触摸开始时的音量和触摸开始时的点去计算出现在滑动到的音量
        float voiceValue = _touchBeginVoiceValue - ((tempPoint.y - _touchBeginPoint.y)/self.bounds.size.height);
        //判断控制一下, 不能超出 0~1
        if (voiceValue < 0) {
            _volumeSlider.value = 0;
        }else if(voiceValue > 1){
            _volumeSlider.value = 1;
        }else{
            _volumeSlider.value = voiceValue;
        }
    }else if(_controlType == lightControl){   //如果是亮度手势
        //显示音量控制的view
        [self hideTheLightViewWithHidden:NO];
        //根据触摸开始时的亮度, 和触摸开始时的点来计算出现在的亮度
        float tempLightValue = _touchBeginLightValue - ((tempPoint.y - _touchBeginPoint.y)/self.bounds.size.height);
        if (tempLightValue < 0) {
            tempLightValue = 0;
        }else if(tempLightValue > 1){
            tempLightValue = 1;
        }
        //控制亮度的方法
        [UIScreen mainScreen].brightness = tempLightValue;
        //实时改变现实亮度进度的view
        [self.lightView changeLightViewWithValue:tempLightValue];
    }
}
//触摸结束
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    AVDLog(@"touch ending");
//    if (touches.count > 1 || event.allTouches.count > 1) {
//        return;
//    }
//    if (![[(UITouch *)touches.anyObject view] isEqual:self.clearView] && ![[(UITouch *)touches.anyObject view] isEqual:self]) {
//        return;
//    }
    [super touchesEnded:touches withEvent:event];
    AVDLog(@"touch end %ld", event.allTouches.count);
    //判断是否移动过,
    if (_hasMoved) {
        if (_controlType == progressControl) { //进度控制就跳到响应的进度
            CGPoint tempPoint = [touches.anyObject locationInView:self];
            float value = [self moveProgressControllWithTempPoint:tempPoint];
            [self seekToTheTimeValue:value];
            _timeView.hidden = YES;
        }else if (_controlType == lightControl){//如果是亮度控制, 控制完亮度还要隐藏显示亮度的view
            [self hideTheLightViewWithHidden:YES];
        }
    }else{
        if (self.topView.hidden) {
            [self controlViewOutHidden];
        }else{
            [self controlViewHidden];
        }
    }
}

// 用来控制移动过程中计算手指划过的时间
-(float)moveProgressControllWithTempPoint:(CGPoint)tempPoint{
    float tempValue = _touchBeginValue + TotalScreenTime * ((tempPoint.x - _touchBeginPoint.x)/SCREEN_WIDTH);
    if (tempValue > self.duration) {
        tempValue = self.duration;
    }else if (tempValue < 0){
        tempValue = 0.0f;
    }
    return tempValue;
}

// 用来控制显示亮度的view, 以及毛玻璃效果的view
-(void)hideTheLightViewWithHidden:(BOOL)hidden{
    if (hidden) {
        [self.playerSuperView bringSubviewToFront:self.effectView];
        [UIView animateWithDuration:1.0 delay:1.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.lightView.alpha = 0.0;
            if (iOS8) {
                self.effectView.alpha = 0.0;
            }
        } completion:nil];
        
    }else{
        [self.playerSuperView bringSubviewToFront:self.effectView];
        self.alpha = 1.0;
        if (iOS8) {
            self.lightView.alpha = 1.0;
            self.effectView.alpha = 1.0;
        }
    }
}

// 用来显示时间的view在时间发生变化时所作的操作
-(void)timeValueChangingWithValue:(float)value{
    if (value > _touchBeginValue) {
        _timeView.sheetStateImageView.image = [UIImage imageNamed:@"progress_icon_r"];
    }else if(value < _touchBeginValue){
        _timeView.sheetStateImageView.image = [UIImage imageNamed:@"progress_icon_l"];
    }
    _timeView.hidden = NO;
    NSString * tempTime = [self.class calculateTimeWithSecond:value];
    if (tempTime.length > 5) {
        _timeView.sheetTimeLabel.text = [NSString stringWithFormat:@"00:%@/%@", tempTime, self.totalTimeLabel.text];
    }else{
        _timeView.sheetTimeLabel.text = [NSString stringWithFormat:@"%@/%@", tempTime, self.totalTimeLabel.text];
    }
}
#pragma mark - private

-(void)createPlayer{
    if (self.videoPlayer) {
        return;
    }
    
    self.videoPlayer = [[LRLVideoPlayer alloc] initWithDelegate:self playerType:LRLVideoPlayerType_AVPlayer playItem:self.playItems];
    self.videoPlayer.backPlayMode = YES;
    self.playView = self.videoPlayer.playView;
    [self insertSubview:self.playView atIndex:0];
    [self.playView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    self.videoPlayer.autoPlay = _autoPlay;
}

-(void)playOrPause{
    if (!self.isPlaying) {
        [self.videoPlayer play];
        [self.playOrPauseBtn setBackgroundImage:[UIImage imageNamed:@"ad_pause_f_p"] forState:UIControlStateNormal];
        _isPlaying = YES;
    }else{
        [self.videoPlayer pause];
        [self.playOrPauseBtn setBackgroundImage:[UIImage imageNamed:@"ad_play_f_p"] forState:UIControlStateNormal];
        _isPlaying = NO;
    }
    //更新一下上下view的隐藏时间
    [self controlViewOutHidden];
}

-(void)readyToPlay{
    _isPlaying = self.autoPlay;
    self.playOrPauseBtn.selected = self.autoPlay;
    self.userInteractionEnabled = YES;
    //将总时间设置slider的最大value, 方便计算
    self.actIndicator.hidden = YES;
    [self endBuffer];
    if (!_hiddenTimer) {
        _hiddenTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(controlViewHidden) userInfo:nil repeats:NO];
    }
}

//跳转到指定位置
-(void)seekToTheTimeValue:(float)value{
    [self.videoPlayer seekTo:value];;
}

-(void)startBuffer{
    [self.actIndicator startAnimating];
    self.actIndicator.hidden = YES;
}
-(void)endBuffer{
    [self.actIndicator stopAnimating];
    self.actIndicator.hidden = YES;
}

//控制条
-(void)controlViewHidden{
    _topView.hidden = YES;
    _bottomView.hidden = YES;
    if (_isFullScreen) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
    [_hiddenTimer invalidate];
}
-(void)controlViewOutHidden{
    _topView.hidden = NO;
    _bottomView.hidden = NO;
    if ([UIApplication sharedApplication].statusBarHidden) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
    if (!_hiddenTimer.valid) {
        _hiddenTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(controlViewHidden) userInfo:nil repeats:NO];
    }else{
        [_hiddenTimer invalidate];
        _hiddenTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(controlViewHidden) userInfo:nil repeats:NO];
    }
}

#pragma mark - Origentation
- (IBAction)exitOrInFullScreen:(id)sender {
    //如果全屏下
    if (_isFullScreen) {
        [self toOrientation:UIInterfaceOrientationPortrait];
    }else{
        [self toOrientation:UIInterfaceOrientationLandscapeRight];
    }
    [self controlViewOutHidden];
}
- (IBAction)exitFullScreen:(id)sender {
    if (_isFullScreen) {
        [self toOrientation:UIInterfaceOrientationPortrait];
    }else{
        [self toOrientation:UIInterfaceOrientationLandscapeRight];
    }
    [self controlViewOutHidden];
}

-(void)orientationChanged:(NSNotification *)notification{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    switch (orientation) {
        case UIDeviceOrientationPortrait:
            [self toOrientation:UIInterfaceOrientationPortrait];
            break;
        case UIDeviceOrientationLandscapeLeft:
            [self toOrientation:UIInterfaceOrientationLandscapeRight];
            break;
        case UIDeviceOrientationLandscapeRight:
            [self toOrientation:UIInterfaceOrientationLandscapeLeft];
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            break;
        default:
            break;
    }
}

-(void)toOrientation:(UIInterfaceOrientation)orientation{
    if (!_canFullScreen) {
        return;
    }
    UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (currentOrientation == orientation) {
        return;
    }
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        [self mas_remakeConstraints:self.portraitBlock];
    }else{
        if (currentOrientation == UIInterfaceOrientationPortrait || currentOrientation == UIInterfaceOrientationPortraitUpsideDown) {
            [self mas_remakeConstraints:self.landscapeBlock];
        }
    }
    [[UIApplication sharedApplication] setStatusBarOrientation:orientation animated:YES];
    [UIView beginAnimations:nil context:nil];
    //旋转视频播放的view和显示亮度的view
    self.transform = [self getOrientation];
    self.lightView.transform = [self getOrientation];
    [UIView setAnimationDuration:0.5];
    [UIView commitAnimations];
}

//根据状态条旋转的方向来旋转 avplayerView
-(CGAffineTransform)getOrientation{
     UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (IsIpad) {
        return CGAffineTransformIdentity;
    }
    if (orientation == UIInterfaceOrientationPortrait) {
        [self toPortraitUpdate];
        return CGAffineTransformIdentity;
    }else if (orientation == UIInterfaceOrientationLandscapeLeft){
        [self toLandscapeUpdate];
        return CGAffineTransformMakeRotation(-M_PI_2);
    }else if(orientation == UIInterfaceOrientationLandscapeRight){
        [self toLandscapeUpdate];
        return CGAffineTransformMakeRotation(M_PI_2);
    }
    return CGAffineTransformIdentity;
}

-(void)toPortraitUpdate{
    _isFullScreen = NO;
    self.exitScreenBtn.hidden = YES;
    //处理状态条
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    if ([UIApplication sharedApplication].statusBarHidden) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
    [self.exitOrInScreenBt setBackgroundImage:[UIImage imageNamed:@"play_mini_f_p"] forState:UIControlStateNormal];
}

-(void)toLandscapeUpdate{
    _isFullScreen = YES;
    self.exitScreenBtn.hidden = NO;
    //处理状态条
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    if (self.bottomView.hidden) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }else{
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
    [self.exitOrInScreenBt setBackgroundImage:[UIImage imageNamed:@"play_full_f_p"] forState:UIControlStateNormal];
}

#pragma mark - LRLVideoPlayerDelegate
-(void)lrlVideoPlayer:(LRLVideoPlayer *)player event:(LRLVideoPlayerEvent)event errorInfo:(NSError *)errorInfo atIndex:(NSInteger)index{
    switch (event) {
        case LRLVideoPlayerEvent_PrepareDone:{
                self.playItemIndexLabel.text = [NSString stringWithFormat:@"第%ld集", index];
                //self准备好播放
                [self readyToPlay];
            }
            break;
        case LRLVideoPlayerEvent_GetVideoSize:{
            if (!self.videoPlayer.videoSize.width || !self.videoPlayer.videoSize.height) {
                return;
            }
            if (!_isFullScreen) {
                CGSize size = self.videoPlayer.videoSize;
                static float staticHeight = 0;
                staticHeight = size.height/size.width * SCREEN_WIDTH;
                self->_videoHeight = &(staticHeight);
                [self mas_remakeConstraints:self.portraitBlock];
            }
            //用来监测屏幕旋转
            [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
            _canFullScreen = YES;
            AVDLog(@"presentationSize");
            
        }
            break;
            
        case LRLVideoPlayerEvent_StartBuffer:{
            [self startBuffer];
        }
            break;
        case LRLVideoPlayerEvent_EndBuffer:{
            [self endBuffer];
        }
            break;
        case LRLVideoPlayerEvent_PlayEnd:{
            if (index == (self.playItems.count - 1)) {
                [self.playOrPauseBtn setBackgroundImage:[UIImage imageNamed:@"ad_play_f_p"] forState:UIControlStateNormal];
                _isPlaying = NO;
            }
        }
            break;
        case LRLVideoPlayerEvent_PlayError:{
            NSLog(@"- PlayError: %@", errorInfo);
        }
            break;
        default:
            break;
    }
}

-(void)lrlVideoPlayer:(LRLVideoPlayer *)player position:(Float64)position cacheDuration:(float)cacheDuration duration:(float)duration atIndex:(NSInteger)index{
    self.videoProgressView.progress = cacheDuration/self.duration;

    if (duration != self.duration) {
        self.duration = duration;
        self.videoSlider.maximumValue = (float)self.duration;
        self.totalTimeLabel.text = [self.class calculateTimeWithSecond:(float)self.duration];
    }
    
    NSInteger tempLength = self.totalTimeLabel.text.length;
    if (tempLength > 5) {
        self.timeLabel.text = @"00:00:00";
    }else{
        self.timeLabel.text = @"00:00";
    }
    
    if (!self.sliderValueChanging) {
        [self.videoSlider setValue:(float)position animated:YES];
    }
    NSString * tempTime = [self.class calculateTimeWithSecond:position];
    if (tempTime.length > 5) {
        self.timeLabel.text = [NSString stringWithFormat:@"00:%@", tempTime];
    }else{
        self.timeLabel.text = tempTime;
    }
}

#pragma mark - tool
+(NSString *)calculateTimeWithSecond:(NSTimeInterval)timeSecond{
    NSString * theLastTime = nil;
    long second = timeSecond;
    if (timeSecond < 60) {
        theLastTime = [NSString stringWithFormat:@"00:%.2ld", second];
    }else if(timeSecond >= 60 && timeSecond < 3600){
        theLastTime = [NSString stringWithFormat:@"%.2ld:%.2ld", second/60, second%60];
    }else if(timeSecond >= 3600){
        theLastTime = [NSString stringWithFormat:@"%.2ld:%.2ld:%.2ld", second/3600, second%3600/60, second%60];
    }
    return theLastTime;
}

#pragma mark - forbiden initial method
-(instancetype)init{
    NSAssert(NO, @"forbiden use this initial method to initial LRLVideoPlayerView");
    return nil;
}

-(instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if(self) {
        
    }
    NSAssert(NO, @"forbiden use this initial method to initial LRLVideoPlayerView");
    return nil;
}

@end
