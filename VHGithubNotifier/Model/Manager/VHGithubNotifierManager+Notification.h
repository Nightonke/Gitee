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

/**
 This method does:
 1. Record the notification as read in database.
 2. Delete the notification model in notificationDic.

 @param notification notification
 */
- (void)readNotification:(VHNotification *)notification;

/**
 This method does:
 1. Record the notification as read in database.
 2. Delete the notification model in notificationDic.
 3. Send a mark-as-read request to github.

 @param notification notification
 */
- (void)markNotificationAsRead:(VHNotification *)notification;

@end
