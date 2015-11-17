//
//  LRLLightView.m
//  LRLAVPlayerDemo
//
//  Created by 刘瑞龙 on 15/7/15.
//  Copyright © 2015年 刘瑞龙. All rights reserved.
//

#import "LRLLightView.h"
#import "LRLAVPlayerView.h"

#define LIGHT_VIEW_COUNT 16
@implementation LRLLightView

-(void)awakeFromNib{
    self.lightViewArr = [[NSMutableArray alloc] init];
    self.layer.cornerRadius = 10.0;
    float backWidth = self.lightBackView.bounds.size.width;
    float backHeight = self.lightBackView.bounds.size.height;
    float viewWidth = (backWidth - (LIGHT_VIEW_COUNT + 1))/16;
    float viewHeight =  backHeight - 2;
    for (int i = 0; i < LIGHT_VIEW_COUNT; ++i) {
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(1 + i * (viewWidth + 1), 1, viewWidth, viewHeight)];
        view.backgroundColor = [UIColor whiteColor];
        [self.lightViewArr addObject:view];
        [self.lightBackView addSubview:view];
    }
}

-(void)changeLightViewWithValue:(float)lightValue{
    NSInteger allCount = self.lightViewArr.count;
    NSInteger lightCount = lightValue * allCount;
    for (int i = 0; i < allCount; ++i) {
        UIView * view = self.lightViewArr[i];
        if (i < lightCount) {
            view.backgroundColor = [UIColor whiteColor];
        }else{
            view.backgroundColor = [UIColor colorWithRed:65.0/255.0 green:67.0/255.0 blue:70.0/255.0 alpha:1.0];
        }
    }
}

//-(void)hideTheLightViewWithHidden:(BOOL)hidden{
//    if (hidden) {
//        [UIView animateWithDuration:1.0 delay:1.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
//            self.alpha = 0.0;
//            if (iOS8) {
//                self.superview.alpha = 0.0;
//            }
//        } completion:nil];
//    }else{
//        self.alpha = 1.0;
//        if (iOS8) {
//            self.superview.alpha = 1.0;
//        }
//    }
//}

@end
