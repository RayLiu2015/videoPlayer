//
//  VideoPlayViewController.h
//  Demo_LehaiMediaPlayer
//
//  Created by liuRuiLong on 16/8/4.
//  Copyright © 2016年 xianghui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LHplayerSDK/LHplayerSDK.h>


@interface VideoPlayViewController : UIViewController

/**
 *  @b 视频源类型
 */
@property (assign, nonatomic) LMPPlaySourceType sourceType;

/**
 *  @b 播放链接
 */
@property (copy, nonatomic) NSString *playUrl;

/**
 *  @b 当传入视频连接时, 需要制定是直播流还是录播流
 */
@property (assign, nonatomic) LMPPlayUrlType playUrlType;

/**
 *  @b 视频id
 */
@property (copy, nonatomic) NSString *programId;

@end
