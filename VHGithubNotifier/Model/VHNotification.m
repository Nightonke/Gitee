//
//  VHNotification.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/26.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHNotification.h"
#import "VHUtils+Json.h"
#import "VHUtils+TransForm.h"

@implementation VHNotification

#pragma mark - Public Methods

+ (NSDictionary<VHSimpleRepository *, NSArray<VHNotification *> *> *)dictionaryFromResponse:(id)responseObject
{
    NSArray<VHNotification *> *notifications = [VHNotification notificationsFromResponse:responseObject];
    __block NSMutableDictionary<VHSimpleRepository *, NSMutableArray<VHNotification *> *> *dic = [NSMutableDictionary dictionary];
    [notifications enumerateObjectsUsingBlock:^(VHNotification * _Nonnull notification, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableArray<VHNotification *> *notifications = (NSMutableArray *)[dic objectForKey:notification.repository];
        if (notifications)
        {
            [notifications addObject:notification];
        }
        else
        {
            [dic setObject:[NSMutableArray arrayWithObject:notification] forKey:notification.repository];
        }
    }];
    __block NSMutableDictionary<VHSimpleRepository *, NSArray<VHNotification *> *> *resultDic = [NSMutableDictionary dictionaryWithCapacity:dic.count];
    [dic enumerateKeysAndObjectsUsingBlock:^(VHSimpleRepository * _Nonnull key, NSMutableArray<VHNotification *> * _Nonnull notifications, BOOL * _Nonnull stop) {
        [resultDic setObject:[notifications copy] forKey:key];
    }];
    return [resultDic copy];
}

+ (NSArray<VHNotification *> *)notificationsFromResponse:(id)responseObject
{
    NSArray<NSDictionary *> *responseArray = SAFE_CAST(responseObject, [NSArray class]);
    __block NSMutableArray<VHNotification *> *notifications = [NSMutableArray arrayWithCapacity:responseArray.count];
    if (responseArray)
    {
        [responseArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull dic, NSUInteger idx, BOOL * _Nonnull stop) {
            VHNotification *notification = [[VHNotification alloc] initFromResponseDiction:dic];
            if ([notification isValid])
            {
                [notifications addObject:notification];
            }
        }];
    }
    return [notifications copy];
}

- (instancetype)initFromResponseDiction:(NSDictionary *)dic
{
    self = [super init];
    if (self)
    {
        _notificationId = [VHUtils getIntegerFromDictionary:dic forKey:@"id" withDefault:-1];
        _lastReadDate = [VHUtils dateFromGithubTimeString:[VHUtils getStringFromDictionaryWithDefaultNil:dic forKey:@"last_read_at"]];
        _reason = [VHUtils notificationReasonTypeFromString:[VHUtils getStringFromDictionaryWithDefaultNil:dic forKey:@"reason"]];
        _repository = [[VHSimpleRepository alloc] initFromResponseDictionary:[VHUtils getDicFromDictionaryWithDefaultNil:dic forKey:@"repository"]];
        NSDictionary *subjectDic = [VHUtils getDicFromDictionaryWithDefaultNil:dic forKey:@"subject"];
        _lastCommentUrl = [VHUtils getStringFromDictionaryWithDefaultNil:subjectDic forKey:@"latest_comment_url"];
        _title = [VHUtils getStringFromDictionaryWithDefaultNil:subjectDic forKey:@"title"];
        _url = [VHUtils getStringFromDictionaryWithDefaultNil:subjectDic forKey:@"url"];
        _unread = [VHUtils getIntegerFromDictionary:dic forKey:@"unread"];
        _updateDate = [VHUtils dateFromGithubTimeString:[VHUtils getStringFromDictionaryWithDefaultNil:dic forKey:@"updated_at"]];
        _type = [VHUtils notificationTypeFromString:[VHUtils getStringFromDictionaryWithDefaultNil:subjectDic forKey:@"type"]];
    }
    return self;
}

- (BOOL)isValid
{
    return self.notificationId != -1
    && self.reason != VHNotificationReasonTypeUnknown
    && [self.title length]
    && self.lastCommentUrl;
}

- (NSString *)toNowTimeString
{
    return [VHUtils timeStringToNowFromTime:self.updateDate];
}

#pragma mark - Private Methods

- (NSString *)description
{
    return [NSString stringWithFormat:@"%lld %zd %@ %@ %@",
            self.notificationId,
            self.reason,
            self.title,
            self.lastCommentUrl,
            self.htmlUrl];
}

@end
