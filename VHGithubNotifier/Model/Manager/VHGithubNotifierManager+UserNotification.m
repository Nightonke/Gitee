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
#import "VHGithubNotifierManager+Notification.h"

static NSMutableArray<CNUserNotification *> *userNotifications;
static NSMutableSet<VHNotification *> *cacheNotifications;

@implementation VHGithubNotifierManager (UserNotification)

#pragma mark - Public Methods

- (void)innerInitializePropertiesForUserNotification
{
    [CNUserNotificationCenter customUserNotificationCenter].delegate = self;
}

- (void)addNotifications:(NSArray<VHNotification *> *)notifications
{
    IN_MAIN_THREAD({
        for (VHNotification *notification in notifications)
        {
            CNUserNotification *userNotification = [[CNUserNotification alloc] init];
            userNotification.title = notification.repository.fullName;
            userNotification.subtitle = notification.title;
            userNotification.informativeText = [notification toNowTimeString];
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:4];
            [userInfo setObject:@(VHGithubUserNotificationTypeNotification) forKey:@"type"];
            [userInfo setObject:@(notification.notificationId) forKey:@"notificationID"];
            userNotification.hasActionButton = NO;
            userNotification.feature.bannerImage = [VHUtils imageFromNotificationType:notification.type];
            userNotification.userInfo = userInfo;
            [[self userNotifications] push:userNotification];
        }
        [[self cacheNotifications] addObjectsFromArray:notifications];
        [self notify];
    });
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

- (NSMutableSet<VHNotification *> *)cacheNotifications
{
    if (cacheNotifications == nil)
    {
        cacheNotifications = [NSMutableSet set];
    }
    return cacheNotifications;
}

- (VHNotification *)cacheNotificationWithID:(long long)notificationID
{
    __block VHNotification *cacheNotification = nil;
    [[self cacheNotifications] enumerateObjectsUsingBlock:^(VHNotification * _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj.notificationId == notificationID)
        {
            cacheNotification = obj;
            *stop = YES;
        }
    }];
    return cacheNotification;
}

- (void)removeCacheNotificationWithID:(long long)notificationID
{
    __block VHNotification *cacheNotification = nil;
    [[self cacheNotifications] enumerateObjectsUsingBlock:^(VHNotification * _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj.notificationId == notificationID)
        {
            cacheNotification = obj;
            *stop = YES;
        }
    }];
    if (cacheNotification)
    {
        [[self cacheNotifications] removeObject:cacheNotification];
    }
}

- (void)storeRecordOfNotification:(CNUserNotification *)userNotification
{
    dispatch_async(GLOBAL_QUEUE, ^{
        @autoreleasepool
        {
            RLMRealm *realm = [self realm];
            VHNotificationRecord *record = [[VHNotificationRecord alloc] init];
            VHNotification *notification = [self cacheNotificationWithID:[[userNotification.userInfo objectForKey:@"notificationID"] longLongValue]];
            if (notification)
            {
                record.notificationId = notification.notificationId;
                record.latestUpdateTime = notification.updateDate;
                if (record.notificationId != 0 && record.latestUpdateTime)
                {
                    [realm beginWriteTransaction];
                    [realm addOrUpdateObject:record];
                    [realm commitWriteTransaction];
                }
            }
        }
    });
}

#pragma mark - NSUserNotificationCenterDelegate

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didDeliverNotification:(NSUserNotification *)userNotification
{
    
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)userNotification
{
    NSDictionary *userInfo = userNotification.userInfo;
    if (userInfo)
    {
        if ([[userInfo objectForKey:@"type"] integerValue] == VHGithubUserNotificationTypeNotification)
        {
            VHNotification *notification = [self cacheNotificationWithID:[[userInfo objectForKey:@"notificationID"] longLongValue]];
            [self openNotificationURLAndMarkAsReadBySettings:notification];
        }
    }
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)userNotification
{
    return YES;
}

- (void)userNotificationCenter:(CNUserNotificationCenter *)center didRemoveNotification:(CNUserNotification *)userNotification
{
    [self removeCacheNotificationWithID:[[userNotification.userInfo objectForKey:@"notificationID"] longLongValue]];
    [self notify];
}

@end
