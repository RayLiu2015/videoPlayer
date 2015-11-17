//
//  LRLLightView.m
//  LRLAVPlayerDemo
//
//  Created by 刘瑞龙 on 15/7/15.
//  Copyright © 2015年 刘瑞龙. All rights reserved.
//

#import "LRLLightView.h"

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

@end
