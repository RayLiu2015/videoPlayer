//
//  LRLVideoPlayerView.m
//  LRLAVPlayerDemo
//
//  Created by liuRuiLong on 16/8/11.
//  Copyright © 2016年 codeWorm. All rights reserved.
//

#import "LRLVideoPlayerRenderView.h"
#import <AVFoundation/AVFoundation.h>

@implementation LRLAVPlayerRenderView

+(Class)layerClass{
    return [AVPlayerLayer class];
}

@end
