//
//  LRLVideoPlayerErrorInfo.h
//  LRLAVPlayerDemo
//
//  Created by liuRuiLong on 2016/11/26.
//  Copyright © 2016年 codeWorm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LRLVideoPlayerErrorInfo : NSObject

/**
 @b 视频播放地址
 */
@property (nonatomic, copy) NSString *urlStr;

/**
 @b 错误信息
 */
@property (nonatomic, copy) NSError *error;

@end
