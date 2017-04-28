//
//  LRLScreenPlayer.h
//  LRLVideoPlayerSDK
//
//  Created by liuRuiLong on 17/4/28.
//  Copyright © 2017年 liuRuiLong. All rights reserved.
//

#import "LRLDLNADevice.h"
#import "LRLVideoPlayerConfig.h"
#import <Foundation/Foundation.h>

@interface LRLScreenPlayer : NSObject<LRLVideoPlayerProtocol>

@end


@protocol LRLDLNADeviceSearchResultDelegate <NSObject>

- (void)searchResultsWith:(LRLDLNADevice *)device;

@optional

- (void)searchErrorWith:(NSError *)error;

@end

@interface LRLScreenPlayerSearcher : NSObject

-(instancetype)initWithDelegate:(id<LRLDLNADeviceSearchResultDelegate>)delegate;

@property (weak, nonatomic) id<LRLDLNADeviceSearchResultDelegate> delegate;

-(void)search;

-(void)stop;

@end
