//
//  VHGithubNotifierManager+UserNotification.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/3/1.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHGithubNotifierManager.h"
#import "VHNotification.h"
#import "CNUserNotificationCenter.h"
#import "CNUserNotificationCenterDelegate.h"

@interface VHGithubNotifierManager (UserNotification)<CNUserNotificationCenterDelegate>

- (void)innerInitializePropertiesForUserNotification;

- (void)addNotifications:(NSArray<VHNotification *> *)notifications;

@end
