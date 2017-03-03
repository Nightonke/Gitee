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
 1. Delete the notification model in notificationDic.

 @param notification notification
 */
- (void)readNotification:(VHNotification *)notification;

/**
 This method does:
 1. Delete the notification model in notificationDic.
 2. Send a mark-as-read request to github.

 @param notification notification
 */
- (void)markNotificationAsRead:(VHNotification *)notification;

/**
 This methods does:
 1. Delete the key-value model in notificationDic.
 2. Send a mark-all-as-read request to github.

 @param repository repository
 */
- (void)markNotificationAsReadInRepository:(VHSimpleRepository *)repository;

/**
 1. Delete the notification model in notificationDic.
 2. Send a unsubscribe request to github.
 3. Send a mark-as-read request to github.

 @param notification notification
 */
- (void)unsubscribeThread:(VHNotification *)notification;

@end
