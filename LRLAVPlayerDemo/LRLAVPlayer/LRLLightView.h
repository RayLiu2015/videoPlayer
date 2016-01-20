//
//  LRLLightView.h
//  LRLAVPlayerDemo
//
//  Created by 刘瑞龙 on 15/7/15.
//  Copyright © 2015年 刘瑞龙. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LRLLightView : UIView

@property (weak, nonatomic) IBOutlet UIView *lightBackView;

@property (nonatomic, strong) NSMutableArray * lightViewArr;

-(void)changeLightViewWithValue:(float)lightValue;

//-(void)hideTheLightViewWithHidden:(BOOL)hidden;

@end
