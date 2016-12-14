//
//  AVPlayerView.h
//  
//
//  Created by 刘瑞龙 on 15/9/10.
//
//

#import "Masonry.h"
#import "LRLVideoPlayerViewDefine.h"

#import <UIKit/UIKit.h>
#import <LRLVideoPlayerSDK/LRLVideoPlayerSDK.h>

typedef void(^LayoutBlock)(MASConstraintMaker * make);

@protocol LRLAVPlayDelegate <NSObject>
@optional
@end

@interface LRLVideoPlayerView : UIView

/**
 @b 用于确定视频高度, 在内部已经根据屏幕宽度计算好了
 */
@property (nonatomic) float *videoHeight;

@property (nonatomic, weak) id<LRLAVPlayDelegate> delegate;

/**
 *  @b 是否在播放
 */
@property (nonatomic, assign, readonly) BOOL isPlaying;

/**
 *  @b 视频的总长度
 */
@property (assign, nonatomic) Float64 duration;

/**
 @b 是否开启后台播放模式, 默认关闭
 */
@property (assign, nonatomic) BOOL backPlayMode;

/**
 @b 唯一的实例方法, 请不要用其他的实例方法

 @param playItems 所要播放视频的信息
 @param height 视频的初始高度
 @param superView 视频视图被添加的父视图
 @return 视频播放器
 */
+(LRLVideoPlayerView *)avplayerViewWithPlayItems:(NSArray<LRLVideoPlayerItem *> *)playItems andInitialHeight:(float)height andSuperView:(UIView *)superView;


/**
 * @b 设置初始位置block和, 全屏的block
 */
-(void)setPositionWithPortraitBlock:(LayoutBlock)porBlock andLandscapeBlock:(LayoutBlock)landscapeBlock;

/**
 @b 进行播放准备, 如果autoPlay设置为YES, 则调用prepare后自动播放, 如果 设置autoPlay为NO, 需要在回调 LRLVideoPlayerEvent_PrepareDone 后自行调用play进行播放
 */
-(void)prepare;

/**
 @b 进行播放, 需要收到 LRLVideoPlayerEvent_PrepareDone 回调后, 调用才有效
 */
-(void)play;

/**
 @b 暂停操作
 */
-(void)pause;

/**
 @b 开始画中画
 */
-(void)startPip;

/**
 @b 结束画中画
 */
-(void)stopPip;

/**
 * @b 释放播放器
 */
-(void)releasePlayer;

@end
