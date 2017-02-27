//
//  VHGithubNotifierManager+Notification.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/26.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHGithubNotifierManager+Notification.h"
#import "VHNotification.h"
#import "VHUtils+Json.h"

static const NSUInteger MAX_CONCURRENT_NOTIFICATION_HTML_URL_REQUEST = 10;

static NSTimer *notificationTimer;
static NSDictionary<VHSimpleRepository *, NSArray<VHNotification *> *> *notificationDic;
static NSDictionary<VHSimpleRepository *, NSArray<VHNotification *> *> *backupNotificationDic;
static VHLoadStateType notificationLoadState = VHLoadStateTypeDidNotLoad;

@implementation VHGithubNotifierManager (Notification)

#pragma mark - Public Methods

- (void)startTimerOfNotification
{
    MUST_IN_MAIN_THREAD;
    NotificationLog(@"Start Timer");
    notificationTimer = [NSTimer scheduledTimerWithTimeInterval:60 * 10 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSLog(@"----------------------------------------------------------------------------------------------------------");
        NotificationLog(@"Update notification");
        [self innerUpdateNotification];
    }];
    [[NSRunLoop currentRunLoop] addTimer:notificationTimer forMode:NSDefaultRunLoopMode];
    [notificationTimer fire];
}

- (void)stopTimerOfNotification
{
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

#pragma mark - Private Methods

- (void)innerUpdateNotification
{
    dispatch_async(GLOBAL_QUEUE, ^{
        [[self engine] notificationsAll:NO participating:NO success:^(id responseObject) {
            backupNotificationDic = notificationDic;
            notificationDic = [VHNotification dictionaryFromResponse:responseObject];
            [self innerRequestHtmlUrlForEachNotification];
        } failure:^(NSError *error) {
            NotificationLog(@"Update notification failed with error: %@", error);
        }];
    });
}

- (void)innerRequestHtmlUrlForEachNotification
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = MAX_CONCURRENT_NOTIFICATION_HTML_URL_REQUEST;
    NSOperation *completeOperation = [NSBlockOperation blockOperationWithBlock:^{
        if ([self allNotificationsAreValid])
        {
            NotificationLog(@"Update notification successfully");
            NOTIFICATION_POST(kNotifyNotificationsLoadedSuccessfully);
        }
        else
        {
            NotificationLog(@"Update notification failed");
            notificationDic = backupNotificationDic;
            NOTIFICATION_POST(kNotifyNotificationsLoadedFailed);
        }
        NSLog(@"%@", notificationDic);
        NotificationLog(@"%@", notificationDic);
    }];
    
    [notificationDic enumerateKeysAndObjectsUsingBlock:^(VHSimpleRepository * _Nonnull key, NSArray<VHNotification *> * _Nonnull notifications, BOOL * _Nonnull stop) {
        for (VHNotification *notification in notifications)
        {
            NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                [[self engine] sendRequest:notification.lastCommentUrl success:^(id responseObject) {
                    NotificationLog(@"%@", responseObject);
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

@end
