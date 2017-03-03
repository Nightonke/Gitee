//
//  VHGithubNotifierManager+Notification.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/26.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHGithubNotifierManager+Notification.h"
#import "VHUtils+Json.h"
#import "VHGithubNotifierManager+UserDefault.h"
#import "VHGithubNotifierManager+Realm.h"
#import "VHNotificationRecord.h"
#import "UAGithubEngineRequestTypes.h"
#import "VHGithubNotifierManager+UserNotification.h"

static const NSUInteger MAX_CONCURRENT_NOTIFICATION_HTML_URL_REQUEST = 10;

static NSTimer *notificationTimer;
static NSDictionary<VHSimpleRepository *, NSArray<VHNotification *> *> *notificationDic;
static NSDictionary<VHSimpleRepository *, NSArray<VHNotification *> *> *backupNotificationDic;
static VHLoadStateType notificationLoadState = VHLoadStateTypeDidNotLoad;
static NSUInteger notificationNumber;

@implementation VHGithubNotifierManager (Notification)

#pragma mark - Public Methods

- (void)startTimerOfNotification
{
    MUST_IN_MAIN_THREAD;
    NotificationLog(@"Start Timer");
    notificationTimer = [NSTimer scheduledTimerWithTimeInterval:[self notificationUpdateTime]
                                                         target:self
                                                       selector:@selector(innerUpdateNotification)
                                                       userInfo:nil
                                                        repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:notificationTimer forMode:NSDefaultRunLoopMode];
    [notificationTimer fire];
}

- (void)stopTimerOfNotification
{
    MUST_IN_MAIN_THREAD;
    NotificationLog(@"Stop Timer");
    [notificationTimer invalidate];
    notificationTimer = nil;
}

- (void)updateNotification
{
    IN_MAIN_THREAD({
        NotificationLog(@"Update notification");
        [self stopTimerOfNotification];
        [self startTimerOfNotification];
    });
}

- (NSDictionary<VHSimpleRepository *, NSArray<VHNotification *> *> *)notificationDic
{
    return notificationDic;
}

- (NSUInteger)notificationNumber
{
    return notificationNumber;
}

- (VHLoadStateType)notificationLoadState
{
    return notificationLoadState;
}

- (void)readNotification:(VHNotification *)notification
{
    MUST_IN_MAIN_THREAD;
    
    // 1. Delete the notification model in notificationDic.
    [self deleteNotification:notification];
    
    NOTIFICATION_POST(kNotifyNotificationsChanged);
}

- (void)markNotificationAsRead:(VHNotification *)notification
{
    MUST_IN_MAIN_THREAD;

    // 1. Delete the notification model in notificationDic.
    [self deleteNotification:notification];
    
    // 2. Send a mark-as-read request to github.
    [self sendRequestToMarkAsReadNotification:notification];
    
    NOTIFICATION_POST(kNotifyNotificationsChanged);
}

- (void)markNotificationAsReadInRepository:(VHSimpleRepository *)repository
{
    MUST_IN_MAIN_THREAD;
    
    // 1. Delete the key-value model in notificationDic.
    [self deleteRepository:repository];
    
    // 2. Send a mark-all-as-read request to github.
    [self sendRequestToMarkAsReadInRepository:repository];
    
    NOTIFICATION_POST(kNotifyNotificationsChanged);
}

- (void)markAllNotificationAsRead
{
    MUST_IN_MAIN_THREAD;
    
    // 1. Send a mark-all-as-read request to github for all repositories.
    [notificationDic enumerateKeysAndObjectsUsingBlock:^(VHSimpleRepository * _Nonnull repository, NSArray<VHNotification *> * _Nonnull notifications, BOOL * _Nonnull stop) {
        [self sendRequestToMarkAsReadInRepository:repository];
    }];
    
    // 2. Clear notificationDic
    notificationDic = [NSDictionary dictionary];
    
    NOTIFICATION_POST(kNotifyNotificationsChanged);
}

- (void)unsubscribeThread:(VHNotification *)notification
{
    MUST_IN_MAIN_THREAD;
    
    // 1. Delete the notification model in notificationDic.
    [self deleteNotification:notification];
    
    // 2. Send a unsubscribe request to github.
    [self sendRequestToUnsubscribeThread:notification];
    
    // 3. Send a mark-as-read request to github.
    [self sendRequestToMarkAsReadNotification:notification];
    
    NOTIFICATION_POST(kNotifyNotificationsChanged);
}

#pragma mark - Private Methods

- (void)innerUpdateNotification
{
    NotificationLog(@"Update notification");
    notificationLoadState = VHLoadStateTypeLoading;
    dispatch_async(GLOBAL_QUEUE, ^{
        [[self engine] notificationsAll:NO participating:NO success:^(id responseObject) {
            backupNotificationDic = notificationDic;
            notificationDic = [VHNotification dictionaryFromResponse:responseObject];
            [self innerRequestHtmlUrlForEachNotification];
        } failure:^(NSError *error) {
            notificationLoadState = VHLoadStateTypeLoadFailed;
            NotificationLog(@"Update notification failed with error: %@", error);
        }];
    });
}

- (void)calculateNotificationNumber
{
    notificationNumber = 0;
    [notificationDic enumerateKeysAndObjectsUsingBlock:^(VHSimpleRepository * _Nonnull repository, NSArray<VHNotification *> * _Nonnull notifications, BOOL * _Nonnull stop) {
        notificationNumber += notifications.count;
    }];
}

- (void)innerRequestHtmlUrlForEachNotification
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = MAX_CONCURRENT_NOTIFICATION_HTML_URL_REQUEST;
    NSOperation *completeOperation = [NSBlockOperation blockOperationWithBlock:^{
        if ([self allNotificationsAreValid])
        {
            NotificationLog(@"Update notification successfully");
            notificationLoadState = VHLoadStateTypeLoadSuccessfully;
            [self calculateNotificationNumber];
            NOTIFICATION_POST_IN_MAIN_THREAD(kNotifyNotificationsLoadedSuccessfully);
            [self remindNotificatons];
        }
        else
        {
            NotificationLog(@"Update notification failed");
            notificationLoadState = VHLoadStateTypeLoadFailed;
            notificationDic = backupNotificationDic;
            NOTIFICATION_POST_IN_MAIN_THREAD(kNotifyNotificationsLoadedFailed);
        }
        NotificationLog(@"%@", notificationDic);
    }];
    
    [notificationDic enumerateKeysAndObjectsUsingBlock:^(VHSimpleRepository * _Nonnull key, NSArray<VHNotification *> * _Nonnull notifications, BOOL * _Nonnull stop) {
        for (VHNotification *notification in notifications)
        {
            NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                [[self engine] sendRequest:notification.lastCommentUrl success:^(id responseObject) {
//                    NotificationLog(@"%@", responseObject);
                    NSArray *responseArray = SAFE_CAST(responseObject, [NSArray class]);
                    NSDictionary *responseDic = SAFE_CAST([responseArray firstObject], [NSDictionary class]);
                    notification.htmlUrl = [VHUtils getStringFromDictionaryWithDefaultNil:responseDic forKey:@"html_url"];
                } failure:^(NSError *error) {
                    NotificationLog(@"Update notification html url failed with error: %@", error);
                }];
            }];
            [completeOperation addDependency:operation];
            [queue addOperation:operation];
        }
    }];
    
    [queue addOperation:completeOperation];
}

- (BOOL)allNotificationsAreValid
{
    __block BOOL allValid = YES;
    [notificationDic enumerateKeysAndObjectsUsingBlock:^(VHSimpleRepository * _Nonnull key, NSArray<VHNotification *> * _Nonnull notifications, BOOL * _Nonnull stop) {
        for (VHNotification *notification in notifications)
        {
            if ([notification isValid] == NO || notification.htmlUrl == nil)
            {
                allValid = NO;
                *stop = YES;
                break;
            }
        }
    }];
    return allValid;
}

- (void)remindNotificatons
{
    dispatch_async(GLOBAL_QUEUE, ^{
        @autoreleasepool
        {
            __block NSMutableArray<VHNotification *> *notificatonsNeedToRemind = [NSMutableArray array];
            [notificationDic enumerateKeysAndObjectsUsingBlock:^(VHSimpleRepository * _Nonnull repository, NSArray<VHNotification *> * _Nonnull notifications, BOOL * _Nonnull stop) {
                for (VHNotification *notificaton in notifications)
                {
                    RLMResults<VHNotificationRecord *> *records = [VHNotificationRecord objectsWhere:[NSString stringWithFormat:@"notificationId = %lld", notificaton.notificationId]];
                    VHNotificationRecord *record = [records firstObject];
                    if (record)
                    {
                        if ([notificaton.updateDate compare:record.latestUpdateTime] == NSOrderedDescending)
                        {
                            // This is a new notification in a same thread!
                            [notificatonsNeedToRemind addObject:notificaton];
                        }
                    }
                    else
                    {
                        // This is a new notification
                        [notificatonsNeedToRemind addObject:notificaton];
                    }
                }
            }];
            NotificationLog(@"Notifications need to remind: %@", notificatonsNeedToRemind);
            [self addNotifications:notificatonsNeedToRemind];
        }
    });
}

- (void)deleteNotification:(VHNotification *)notificationToBeDeleted
{
    __block NSMutableDictionary<VHSimpleRepository *, NSArray<VHNotification *> *> *newNotificationDic = [NSMutableDictionary dictionary];
    [notificationDic enumerateKeysAndObjectsUsingBlock:^(VHSimpleRepository * _Nonnull repository, NSArray<VHNotification *> * _Nonnull notifications, BOOL * _Nonnull stop) {
        NSMutableArray<VHNotification *> *newNotifications = [NSMutableArray array];
        for (VHNotification *notification in notifications)
        {
            if (notification.notificationId != notificationToBeDeleted.notificationId)
            {
                [newNotifications addObject:notification];
            }
        }
        if (newNotifications.count != 0)
        {
            [newNotificationDic setObject:newNotifications forKey:repository];
        }
    }];
    notificationDic = [newNotificationDic copy];
}

- (void)deleteRepository:(VHSimpleRepository *)repository
{
    NSMutableDictionary<VHSimpleRepository *, NSArray<VHNotification *> *> *newNotificationDic = [NSMutableDictionary dictionaryWithDictionary:notificationDic];
    [newNotificationDic removeObjectForKey:repository];
    notificationDic = [newNotificationDic copy];
}

- (void)sendRequestToMarkAsReadNotification:(VHNotification *)notification
{
    dispatch_async(GLOBAL_QUEUE, ^{
        [[self engine] markNotificationAsRead:notification.notificationId success:^(id responseObject) {
            if ([responseObject intValue] == UAGithubResetContentResponse)
            {
                NotificationLog(@"Mark notification(%@) as read successfully", notification);
            }
            else
            {
                NotificationLog(@"Mark notification(%@) as read failed with error:%@", notification, responseObject);
            }
        } failure:^(NSError *error) {
            NotificationLog(@"Mark notification(%@) as read failed with error:%@", notification, error);
        }];
    });
}

- (void)sendRequestToMarkAsReadInRepository:(VHSimpleRepository *)repository
{
    dispatch_async(GLOBAL_QUEUE, ^{
        [[self engine] markNotificationAsReadInRepository:repository.name ofOwner:repository.ownerName success:^(id responseObject) {
            if ([responseObject intValue] == UAGithubResetContentResponse)
            {
                NotificationLog(@"Mark all notification in repository(%@) as read successfully", repository);
            }
            else
            {
                NotificationLog(@"Mark all notification in repository(%@) as read failed with error:%@", repository, responseObject);
            }
        } failure:^(NSError *error) {
            NotificationLog(@"Mark all notification in repository(%@) as read failed with error:%@", repository, error);
        }];
    });
}

- (void)sendRequestToUnsubscribeThread:(VHNotification *)notification
{
    dispatch_async(GLOBAL_QUEUE, ^{
        [[self engine] setThreadSubscription:notification.notificationId subscribed:NO success:^(id responseObject) {
            NotificationLog(@"Unsubscribe notification(%@) thread successfully", notification);
        } failure:^(NSError *error) {
            NotificationLog(@"Unsubscribe notification(%@) thread failed with error: %@", notification, error);
        }];
    });
}

@end
