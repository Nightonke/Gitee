//
//  VHGithubNotifierManager+Trending.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/21.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHGithubNotifierManager.h"

@interface VHGithubNotifierManager (Trending)

- (void)startTimerOfTrending;

- (void)stopTimerOfTrending;

- (void)updateTrending;

- (VHLoadStateType)trendingContentLoadState;

@end
