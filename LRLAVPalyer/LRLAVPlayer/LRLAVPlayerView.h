//
//  AVPlayerView.h
//  
//
//  Created by 刘瑞龙 on 15/9/10.
//
//

#import "Masonry.h"
#import "AppDelegate.h"
#import "LRLLightView.h"
#import "TimeSheetView.h"

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

//整个屏幕代表的时间
#define TotalScreenTime 90

//获取到window
#define Window [[UIApplication sharedApplication].delegate window]

//用来标记是否调试模式
//#define AvplayerDebug //

#ifdef DEBUG

//根据是否为调试模式, 来开启打印
#ifdef AvplayerDebug
#define Log(看我的是大SB, ...) NSLog((@"函数名: %s [行: %d]" 看我的是大SB), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define Log(...) //
#endif

#else

#define Log(...) //

#endif

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define iOS8 [UIDevice currentDevice].systemVersion.floatValue >= 8.0

typedef void(^LayoutBlock)(MASConstraintMaker * make);

typedef enum : NSUInteger {
    progressControl,
    voiceControl,
    lightControl,
    noneControl = 999,
} ControlType;

@protocol LRLAVPlayDelegate <NSObject>
@optional
//开始时调用的方法
-(void)play;
//暂停时调用的方法
-(void)pause;
@end

@interface LRLAVPlayerView : UIView
{
    @public
    float * _videoHeight;
}

@property (nonatomic, weak) id<LRLAVPlayDelegate> delegate;

/**
 *  @b 是否在播放
 */
@property (nonatomic, assign, readonly) BOOL isPlaying;

/**
 *  @b 视频的总长度
 */
@property (nonatomic, assign, readonly) float totalSeconds;

/**
 * @b 视频源urlStr
 */
@property (nonatomic, copy) NSString * videoUrlStr;


-(void)seekToTheTimeValue:(float)value;

/**
 * @b 设置初始位置block和, 全屏的block
 */
-(void)setPositionWithPortraitBlock:(LayoutBlock)porBlock andLandscapeBlock:(LayoutBlock)landscapeBlock;

/**
 * @b 唯一的实例方法, 请不要用其他的实例方法
 */
+(LRLAVPlayerView *)avplayerViewWithVideoUrlStr:(NSString *)urlStr andInitialHeight:(float)height andSuperView:(UIView *)superView;

/**
 * @b 暂时性的销毁播放器, 用于节省内存, 再用时可以回到销毁点继续播放
 */
-(void)destoryAVPlayer;

/**
 * @b destory 后再次播放, 会记住之前的播放状态, 时间和是否暂停
 */
-(void)replay;

@end
