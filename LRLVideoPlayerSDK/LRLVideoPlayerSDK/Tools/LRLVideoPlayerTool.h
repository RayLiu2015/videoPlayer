//
//  LRLVideoPlayerTool.h
//  LRLAVPlayerDemo
//
//  Created by liuRuiLong on 16/8/12.
//  Copyright © 2016年 codeWorm. All rights reserved.
//

#import "LRLVideoPlayerDefine.h"

#import <Foundation/Foundation.h>

//用来标记是否调试模式
#define VideoPlayDebug //

//根据是否为调试模式, 来开启打印
#ifdef VideoPlayDebug
#define VPDLog(content, ...) NSLog((@"函数名: %s [行: %d]" content), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define VPDLog(...) //
#endif

@interface LRLVideoPlayerTool : NSObject

@property (strong, nonatomic) NSMutableDictionary *playTypeDic;

+(instancetype)sharedTool;

+(NSError *)createAErrorWithErrorDetail:(NSString *)errorStr andErrorCode:(LRLVideoPlayerErrorCode)errorCode;

@end
