//
//  LRLAVPlayerDefine.h
//  LRLAVPalyer
//
//  Created by 刘瑞龙 on 15/11/18.
//  Copyright © 2015年 V1. All rights reserved.
//

#ifndef LRLAVPlayerDefine_h
#define LRLAVPlayerDefine_h
#endif

//整个屏幕代表的时间
#define TotalScreenTime 90
#define LeastDistance 15

//获取到window
#define Window [[UIApplication sharedApplication].delegate window]

//用来标记是否调试模式
#define AvplayerDebug //

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

#define iOS8 [UIDevice currentDevice].systemVersion.floatValue >= 8.0

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
