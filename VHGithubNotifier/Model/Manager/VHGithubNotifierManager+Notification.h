//
//  VHGithubNotifierManager+Notification.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/26.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHGithubNotifierManager.h"
#import "VHNotification.h"

@interface VHGithubNotifierManager (Notification)

- (void)startTimerOfNotification;

- (void)stopTimerOfNotification;

- (void)updateNotification;

- (NSDictionary<VHSimpleRepository *, NSArray<VHNotification *> *> *)notificationDic;

- (VHLoadStateType)notificationLoadState;

@end
