//
//  VHGithubNotifierManager+UserNotification.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/3/1.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHGithubNotifierManager+UserNotification.h"
#import "VHGithubNotifierManager+Realm.h"
#import "NSMutableArray+Queue.h"
#import "VHUtils.h"
#import "CNUserNotification.h"
#import "VHUtils+TransForm.h"
#import "VHNotificationRecord.h"

static NSMutableArray<CNUserNotification *> *userNotifications;

@implementation VHGithubNotifierManager (UserNotification)

#pragma mark - Public Methods

- (void)innerInitializePropertiesForUserNotification
{
    [CNUserNotificationCenter customUserNotificationCenter].delegate = self;
}

- (void)addNotifications:(NSArray<VHNotification *> *)notifications
{
    @synchronized (userNotifications)
    {
        for (VHNotification *notification in notifications)
        {
            CNUserNotification *userNotification = [[CNUserNotification alloc] init];
            userNotification.title = notification.repository.fullName;
            userNotification.subtitle = notification.title;
            userNotification.informativeText = [notification toNowTimeString];
            userNotification.userInfo = @{@"type":@(VHGithubUserNotificationTypeNotification),
                                          @"url":notification.htmlUrl,
                                          @"notificationId":@(notification.notificationId),
                                          @"latestUpdateTime":notification.updateDate};
            userNotification.hasActionButton = NO;
            userNotification.feature.bannerImage = [VHUtils imageFromNotificationType:notification.type];
            [[self userNotifications] push:userNotification];
        }
    }
    [self notify];
}

#pragma mark - Private Methods

- (void)notify
{
    IN_MAIN_THREAD({
        CNUserNotification *userNotification = [[self userNotifications] pop];
        if (userNotification)
        {
            [self storeRecordOfNotification:userNotification];
            [[CNUserNotificationCenter customUserNotificationCenter] deliverNotification:userNotification];
        }
    });
}

- (NSMutableArray<CNUserNotification *> *)userNotifications
{
    if (userNotifications == nil)
    {
        userNotifications = [NSMutableArray array];
    }
    return userNotifications;
}

- (void)storeRecordOfNotification:(CNUserNotification *)userNotification
{
    dispatch_async(GLOBAL_QUEUE, ^{
        @autoreleasepool
        {
            RLMRealm *realm = [self realm];
            VHNotificationRecord *record = [[VHNotificationRecord alloc] init];
            record.notificationId = [[userNotification.userInfo objectForKey:@"notificationId"] longLongValue];
            record.latestUpdateTime = [userNotification.userInfo objectForKey:@"latestUpdateTime"];
            if (record.notificationId != 0 && record.latestUpdateTime)
            {
                [realm beginWriteTransaction];
                [realm addOrUpdateObject:record];
                [realm commitWriteTransaction];
            }
        }
    });
}

#pragma mark - NSUserNotificationCenterDelegate

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didDeliverNotification:(NSUserNotification *)notification
{
    
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    if (userInfo)
    {
        if ([[userInfo objectForKey:@"type"] integerValue] == VHGithubUserNotificationTypeNotification)
        {
            NSString *url = SAFE_CAST([userInfo objectForKey:@"url"], [NSString class]);
            [VHUtils openUrl:url];
        }
    }
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}

- (void)userNotificationCenter:(CNUserNotificationCenter *)center didRemoveNotification:(CNUserNotification *)notification
{
    [self notify];
}

@end
