//
//  AVPlayerView.m
//
//
//  Created by 刘瑞龙 on 15/9/10.
//
//

#import <AVKit/AVKit.h>

#import "LRLAVPlayerView.h"
#import "LRLAVPlayerTool.h"

@interface LRLAVPlayerView ()<UIGestureRecognizerDelegate, AVPictureInPictureControllerDelegate>
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
    //记录destroy时的瞬时播放时间
    float _destoryTempTime;
    //状态是否被destory
    BOOL _destoryed;
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
}

/**
 * @b 画中画控制器
 */
@property (nonatomic, strong) AVPictureInPictureController *pipC;

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
@property (nonatomic, weak) UIView * avplayerSuperView;

/**
 * @b 竖屏的限制block
 */
@property (nonatomic, copy) LayoutBlock portraitBlock;

/**
 * @b 横屏的限制block
 */
@property (nonatomic, copy) LayoutBlock landscapeBlock;

/**
 *  @b avplayerItem主要用来监听播放状态
 */
@property (nonatomic, strong) AVPlayerItem * avplayerItem;

/**
 *  @b avplayer播放器
 */
@property (nonatomic, strong) AVPlayer * viewAVplayer;

/**
 * @b 用来监控播放时间的observer
 */
@property (nonatomic, strong) id timerObserver;

@end

@implementation LRLAVPlayerView

#pragma mark - 实例化方法
+(LRLAVPlayerView *)avplayerViewWithVideoUrlStr:(NSString *)urlStr andInitialHeight:(float)height andSuperView:(UIView *)superView{
    static float videoHeight = 0.0;
    videoHeight = height;
    LRLAVPlayerView * view = [[NSBundle mainBundle] loadNibNamed:@"LRLAVPlayerView" owner:nil options:nil].lastObject;
    view.videoUrlStr = urlStr;
    view->_videoHeight = &videoHeight;
    view.avplayerSuperView = superView;
    return view;
}

#pragma mark - 从xib唤醒视图
-(void)awakeFromNib{
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
    
//    [self.viewAVplayer play];
}

#pragma mark - 初始化播放控制信息
-(void)initialSelfView{
    [self.actIndicator startAnimating];
    self.userInteractionEnabled = NO;
    self.multipleTouchEnabled = YES;
    self.exitScreenBtn.hidden = YES;
    self.controlType = noneControl;
    _isFisrtConfig = YES;
    _canFullScreen = NO;
    _isFullScreen = NO;
    //为了记住destroy时播放状态, 如果不是destroy的, 则初始值为播放,否则为原来的状态
    if (!_destoryed) {
        _isPlaying = YES;
    }
    
}

#pragma mark - 对xib拖拽的progressView和Slider重新布局
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

#pragma mark - 当缓冲好视频调用的方法
-(void)readyToPlayConfigPlayView{
    self.userInteractionEnabled = YES;
    //将总时间设置slider的最大value, 方便计算
    self.videoSlider.maximumValue = self.totalSeconds;
    self.actIndicator.hidden = YES;
    [self.actIndicator stopAnimating];
    self.totalTimeLabel.text = calculateTimeWithTimeFormatter(self.totalSeconds);
    _hiddenTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(controlViewHidden) userInfo:nil repeats:NO];
    
    self.pipC = [[AVPictureInPictureController alloc] initWithPlayerLayer:(AVPlayerLayer *)self.layer];
    self.pipC.delegate = self;
}

#pragma mark - 创建控制声音的控制器, 通过self.volumeSlider来控制声音
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

#pragma mark - 用来创建用来显示亮度的view
-(void)createLightView{
    Window.translatesAutoresizingMaskIntoConstraints = NO;
    __weak LRLAVPlayerView * weakSelf = self;
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
        
        [Window addSubview:_effectView];
        [self.effectView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(weakSelf.effectView.superview);
            make.width.equalTo(@(155));
            make.height.equalTo(@155);
        }];
    }else{
        self.lightView = [[NSBundle mainBundle] loadNibNamed:@"LRLLightView" owner:self options:nil].lastObject;
        self.lightView.translatesAutoresizingMaskIntoConstraints = NO;
        self.lightView.alpha = 0.0;
        [Window addSubview:self.lightView];
        [self.lightView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(weakSelf.lightView.superview);
            make.width.equalTo(@(155));
            make.height.equalTo(@155);
        }];
    }
    
}

#pragma mark - 创建拖动屏幕时, 显示时间的view
-(void)createTimeView{
    _timeView = [[NSBundle mainBundle] loadNibNamed:@"TimeSheetView" owner:self options:nil].lastObject;
    _timeView.hidden = YES;
    _timeView.layer.cornerRadius = 10.0;
    [self addSubview:_timeView];
    
    __weak LRLAVPlayerView * weakSelf = self;
    [_timeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(weakSelf);
        make.width.equalTo(@(120));
        make.height.equalTo(@60);
    }];
}

#pragma mark - 给进度条加的手势
-(void)progressTapAct:(UITapGestureRecognizer *)tap{
    AVDLog(@"slider tap !");
    CGPoint location = [tap locationInView:self.videoSlider];
    float value = location.x/self.videoSlider.bounds.size.width * self.totalSeconds;
    [self seekToTheTimeValue:value];
    [self controlViewOutHidden];
}

-(void)addGesture{
//    UITapGestureRecognizer * onceTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAct:)];
//    onceTap.numberOfTapsRequired = 1;
//    onceTap.numberOfTouchesRequired = 1;
//    [self.clearView addGestureRecognizer:onceTap];
    
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
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
//    return NO;
//}
-(void)tapAct:(UITapGestureRecognizer *)tap{
    //点击一次
    if (tap.numberOfTapsRequired == 1) {
    }else if(tap.numberOfTapsRequired == 2){
        [self playOrPause];
    }
}

#pragma mark - 用touch这几个方法来判断, 是进度控制 . 音量控制. 还是亮度控制, 并作出相应的计算
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
//            if ([self.delegate respondsToSelector:@selector(seekToTheTimeValue:)]) {
            float value = [self moveProgressControllWithTempPoint:tempPoint];
//                [self.delegate seekToTheTimeValue:value];
            [self seekToTheTimeValue:value];
//            }
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

#pragma mark - 用来控制移动过程中计算手指划过的时间
-(float)moveProgressControllWithTempPoint:(CGPoint)tempPoint{
    float tempValue = _touchBeginValue + TotalScreenTime * ((tempPoint.x - _touchBeginPoint.x)/SCREEN_WIDTH);
    if (tempValue > self.totalSeconds) {
        tempValue = self.totalSeconds;
    }else if (tempValue < 0){
        tempValue = 0.0f;
    }
    return tempValue;
}

#pragma mark - 用来显示时间的view在时间发生变化时所作的操作
-(void)timeValueChangingWithValue:(float)value{
    if (value > _touchBeginValue) {
        _timeView.sheetStateImageView.image = [UIImage imageNamed:@"progress_icon_r"];
    }else if(value < _touchBeginValue){
        _timeView.sheetStateImageView.image = [UIImage imageNamed:@"progress_icon_l"];
    }
    _timeView.hidden = NO;
    NSString * tempTime = calculateTimeWithTimeFormatter(value);
    if (tempTime.length > 5) {
        _timeView.sheetTimeLabel.text = [NSString stringWithFormat:@"00:%@/%@", tempTime, self.totalTimeLabel.text];
    }else{
        _timeView.sheetTimeLabel.text = [NSString stringWithFormat:@"%@/%@", tempTime, self.totalTimeLabel.text];
    }
}

#pragma mark - 点击播放或者暂停按钮
- (IBAction)playOrPauseButtonClicked:(id)sender {
    [self playOrPause];
 }

-(void)playOrPause{
    if (!self.isPlaying) {
        [self.viewAVplayer play];
        [self.playOrPauseBtn setBackgroundImage:[UIImage imageNamed:@"ad_pause_f_p"] forState:UIControlStateNormal];
        _isPlaying = YES;
        if ([self.delegate respondsToSelector:@selector(pause)]) {
            [self.delegate pause];
        }
    }else{
        [self.viewAVplayer pause];
        [self.playOrPauseBtn setBackgroundImage:[UIImage imageNamed:@"ad_play_f_p"] forState:UIControlStateNormal];
        _isPlaying = NO;
        if ([self.delegate respondsToSelector:@selector(play)]) {
            [self.delegate play];
        }
    }
    //更新一下上下view的隐藏时间
    [self controlViewOutHidden];
}
#pragma mark - 滑动滑块触发的方法, 向controller传入时间值
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
}
#pragma mark - 用来控制显示亮度的view, 以及毛玻璃效果的view
-(void)hideTheLightViewWithHidden:(BOOL)hidden{
    if (hidden) {
        [UIView animateWithDuration:1.0 delay:1.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.lightView.alpha = 0.0;
            if (iOS8) {
                self.effectView.alpha = 0.0;
            }
        } completion:nil];
        
    }else{
        self.alpha = 1.0;
        if (iOS8) {
            self.lightView.alpha = 1.0;
            self.effectView.alpha = 1.0;
        }
    }
}
#pragma mark - 控制条隐藏
-(void)controlViewHidden{
    _topView.hidden = YES;
    _bottomView.hidden = YES;
    if (_isFullScreen) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
    [_hiddenTimer invalidate];
}
#pragma mark - 控制条退出隐藏
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

#pragma mark -----------------------------
#pragma mark - 视频播放相关
#pragma mark -----------------------------
#pragma mark - KVO - 监测视频状态, 视频播放的核心部分
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {        //获取到视频信息的状态, 成功就可以进行播放, 失败代表加载失败
        if (self.avplayerItem.status == AVPlayerItemStatusReadyToPlay) {   //准备好播放
            AVDLog(@"AVPlayerItemStatusReadyToPlay: 视频成功播放");
            if (_isFisrtConfig) {
                //self准备好播放
                [self readyToPlay];
                //avplayerView准备好播放
                [self readyToPlayConfigPlayView];
                if (self.isPlaying) {
                    [self.viewAVplayer play];
                }else{
                    [self.viewAVplayer pause];
                }
                if (_destoryed) {
                    [self seekToTheTimeValue:_destoryTempTime];
                }
            }
        }else if(self.avplayerItem.status == AVPlayerItemStatusFailed){    //加载失败
            AVDLog(@"AVPlayerItemStatusFailed: 视频播放失败");
        }else if(self.avplayerItem.status == AVPlayerItemStatusUnknown){   //未知错误
        }
        _destoryed = NO;
    }else if([keyPath isEqualToString:@"loadedTimeRanges"]){ //当缓冲进度有变化的时候
        [self updateAvailableDuration];
    }else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]){ //当视频播放因为各种状态播放停止的时候, 这个属性会发生变化
        if (self.pipC && self.pipC.pictureInPictureActive) {
            _isPlaying = YES;
            [self playOrPause];
        }else{
            if (self.isPlaying) {
                [self.viewAVplayer play];
                [self.actIndicator stopAnimating];
                self.actIndicator.hidden = YES;
            }
        }
        AVDLog(@"playbackLikelyToKeepUp change : %@", change);
    }else if([keyPath isEqualToString:@"playbackBufferEmpty"]){  //当没有任何缓冲部分可以播放的时候
        [self.actIndicator startAnimating];
        self.actIndicator.hidden = NO;
        AVDLog(@"playbackBufferEmpty");
    }else if ([keyPath isEqualToString:@"playbackBufferFull"]){
        AVDLog(@"playbackBufferFull: change : %@", change);
    }else if([keyPath isEqualToString:@"presentationSize"]){      //获取到视频的大小的时候调用
        if (!_isFullScreen) {
            CGSize size = self.avplayerItem.presentationSize;
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
}
#pragma mark - 缓冲好准备播放所做的操作, 并且添加时间观察, 更新播放时间
-(void)readyToPlay{
    _isFisrtConfig = NO;
    _totalSeconds = self.avplayerItem.duration.value/self.avplayerItem.duration.timescale;
    _totalSeconds = (float)self.totalSeconds;
    NSInteger tempLength = self.totalTimeLabel.text.length;
    if (tempLength > 5) {
        self.timeLabel.text = @"00:00:00";
    }else{
        self.timeLabel.text = @"00:00";
    }
    //这个是用来监测视频播放的进度做出相应的操作
    __weak LRLAVPlayerView * weakSelf = self;
    self.timerObserver = [self.viewAVplayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:nil usingBlock:^(CMTime time) {
        long long currentSecond = weakSelf.avplayerItem.currentTime.value/weakSelf.avplayerItem.currentTime.timescale;
        if (!weakSelf.sliderValueChanging) {
            [weakSelf.videoSlider setValue:(float)currentSecond animated:YES];
        }
        NSString * tempTime = calculateTimeWithTimeFormatter(currentSecond);
        if (tempTime.length > 5) {
            weakSelf.timeLabel.text = [NSString stringWithFormat:@"00:%@", tempTime];
        }else{
            weakSelf.timeLabel.text = tempTime;
        }
    }];
}
#pragma mark - 更新缓冲时间
-(void)updateAvailableDuration{
    NSArray * loadedTimeRanges = self.avplayerItem.loadedTimeRanges;
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;
    self.videoProgressView.progress = result/self.totalSeconds;
}
//跳转到指定位置
-(void)seekToTheTimeValue:(float)value{
    self.actIndicator.hidden = NO;
    [self.actIndicator startAnimating];
    [self.viewAVplayer pause];
    CMTime changedTime = CMTimeMakeWithSeconds(value, 1);
    AVDLog(@"cmtime change time : %lld", changedTime.value);
    __weak LRLAVPlayerView * weakSelf = self;
    [self.viewAVplayer seekToTime:changedTime completionHandler:^(BOOL finished){
        if (weakSelf.isPlaying) {
            [weakSelf.viewAVplayer play];
        }
        //更改avplayerView的播放状态, 并且改变button上的图片
        weakSelf.sliderValueChanging = NO;
        [weakSelf.actIndicator stopAnimating];
        weakSelf.actIndicator.hidden = YES;
    }];
}
//播放结束调用的方法
-(void)moviePlayEnd:(NSNotification *)notification{
    [self seekToTheTimeValue:0.0];
    [self.viewAVplayer pause];
    self.playOrPauseBtn.selected = YES;
    _isPlaying = NO;
}

#pragma mark -------------------------
#pragma mark - 以下是位置相关的操作
#pragma mark -------------------------
#pragma mark - 初始化位置
-(void)setPositionWithPortraitBlock:(LayoutBlock)porBlock andLandscapeBlock:(LayoutBlock)landscapeBlock{
    self.portraitBlock = porBlock;
    self.landscapeBlock = landscapeBlock;
    [self mas_makeConstraints:porBlock];
    
    //开始播放, 这个只是为了调一下get方法
    [self.viewAVplayer play];
}

#pragma mark - 处理旋转屏
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

#pragma mark - 通知中心检测到屏幕旋转
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
            [self toOrientation:UIInterfaceOrientationPortraitUpsideDown];
            break;
        default:
            break;
    }
}

#pragma mark - 以下是用来处理全屏旋转
-(void)toOrientation:(UIInterfaceOrientation)orientation{
    if (!_canFullScreen) {
        return;
    }
    UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (currentOrientation == orientation) {
        return;
    }
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        [self removeFromSuperview];
        [self.avplayerSuperView addSubview:self];
        [self mas_remakeConstraints:self.portraitBlock];
    }else{
        if (currentOrientation == UIInterfaceOrientationPortrait || currentOrientation == UIInterfaceOrientationPortraitUpsideDown) {
            [self removeFromSuperview];
            [Window addSubview:self];
            [self bringLightViewToFront];
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


#pragma mark ---------------
#pragma mark - 以下是销毁以及销毁后再播放的相关方法
#pragma mark ---------------

-(void)destoryAVPlayer{
    _destoryTempTime = self.avplayerItem.currentTime.value/self.avplayerItem.currentTime.timescale;
    _destoryed = YES;
    self.userInteractionEnabled = NO;
    if (_hiddenTimer && _hiddenTimer.valid) {
        [_hiddenTimer invalidate];
        _hiddenTimer = nil;
    }
    if (_avplayerItem) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_avplayerItem];
        /*
         status
         loadedTimeRanges
         playbackLikelyToKeepUp
         playbackBufferEmpty
         playbackBufferFull
         presentationSize
         */
        [_avplayerItem removeObserver:self forKeyPath:@"status"];
        [_avplayerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [_avplayerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
        [_avplayerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [_avplayerItem removeObserver:self forKeyPath:@"playbackBufferFull"];
        [_avplayerItem removeObserver:self forKeyPath:@"presentationSize"];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_timerObserver) {
        [_viewAVplayer removeTimeObserver:self.timerObserver];
        _timerObserver = nil;
    }
    [(AVPlayerLayer *)self.layer setPlayer:nil];
    _avplayerItem = nil;
    _viewAVplayer = nil;
}
-(void)replay{
    [self initialSelfView];
    [self.viewAVplayer play];
}
-(void)dealloc{
    NSLog(@"LRLAVPlayerView dealloc");
    [self destoryAVPlayer];
}

#pragma mark - 懒加载
-(AVPlayerItem *)avplayerItem{
    if (!_avplayerItem) {
        _avplayerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:self.videoUrlStr]];
        [_avplayerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [_avplayerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [_avplayerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [_avplayerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [_avplayerItem addObserver:self forKeyPath:@"playbackBufferFull" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [_avplayerItem addObserver:self forKeyPath:@"presentationSize" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_avplayerItem];
    }
    return _avplayerItem;
}

-(AVPlayer *)viewAVplayer{
    if (!_viewAVplayer) {
        _viewAVplayer = [AVPlayer playerWithPlayerItem:self.avplayerItem];
        _viewAVplayer.usesExternalPlaybackWhileExternalScreenIsActive = YES;
        [(AVPlayerLayer *)self.layer setPlayer:_viewAVplayer];
    }
    return _viewAVplayer;
}

#pragma mark - 用来将layer转为AVPlayerLayer, 必须实现的方法, 否则会崩
+(Class)layerClass{
    return [AVPlayerLayer class];
}

#pragma mark - 这个是用来在viewWillAppear 将亮度view放到最上层
-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    [self bringLightViewToFront];
}
-(void)bringLightViewToFront{
    if (iOS8) {
        [Window bringSubviewToFront:self.effectView];
    }else{
        [Window bringSubviewToFront:self.lightView];
    }
}
#pragma mark - 开启画中画
- (IBAction)startPiP:(id)sender {
    [self.pipC startPictureInPicture];
    if ([AVPictureInPictureController isPictureInPictureSupported]) {
        if (self.pipC.pictureInPicturePossible) {
        }else{
            AVDLog(@"画中画不可用");
        }
    }else{
        AVDLog(@"此设备不支持画中画");
    }

}
#pragma mark - AVPictureInPictureControllerDelegate
- (void)pictureInPictureControllerWillStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController{
    AVDLog(@"pip will start");
}
- (void)pictureInPictureControllerDidStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController{
    AVDLog(@"pip did start");
}
- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController failedToStartPictureInPictureWithError:(NSError *)error{
    AVDLog(@"pip failed");
}
- (void)pictureInPictureControllerWillStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController{
    AVDLog(@"pip will stop");
}
- (void)pictureInPictureControllerDidStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController{
    AVDLog(@"pip did stop");
    for (UIView *view in self.subviews) {
        [self bringSubviewToFront:view];
    }
//    NSLog(@"%@", NSStringFromCGRect(self.frame));
//    NSLog(@"%@", NSStringFromCGRect(self.bottomView.frame));
//    self.bottomView.backgroundColor = [UIColor redColor];
////    [self bringSubviewToFront:self.bottomView];
//    self.clearView.backgroundColor = [UIColor orangeColor];
//    self.bottomView.hidden= NO;
//    self.topView.hidden = NO;
//    NSLog(@"%@", self.subviews);
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        NSInteger count = self.subviews.count;
//        UIView *topView = self.subviews[count - 1];
//        topView.backgroundColor = [UIColor redColor];
//        topView.hidden = NO;
////        [self bringSubviewToFront:topView];
//    });
 }
- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:(void (^)(BOOL restored))completionHandler{
    AVDLog(@"pip stop with handle");
}

#pragma mark - 禁止使用其他实例化方法
-(instancetype)init{
    NSAssert(NO, @"请不要使用此实例化方法");
    return nil;
}

-(instancetype)initWithFrame:(CGRect)frame{
    NSAssert(NO, @"请不要使用此实例化方法");
    return nil;
}

@end
