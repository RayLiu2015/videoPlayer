//
//  LRLVideoPlayerItem.h
//  LRLVideoPlayerSDK
//
//  Created by liuRuiLong on 2016/11/26.
//  Copyright © 2016年 liuRuiLong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LRLVideoPlayerItem : NSObject

/**
 @b 视频播放链接
 */
@property (nonatomic, copy) NSString *videoUrlStr;

/**
 @b 视频标题
 */
@property (nonatomic, copy) NSString *videoTitle;

@end
