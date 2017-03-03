//
//  VHNotification.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/26.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHSimpleRepository.h"

typedef NS_ENUM(NSUInteger, VHNotificationReasonType)
{
    VHNotificationReasonTypeUnknown     = -1, // Unknown
    VHNotificationReasonTypeAssign      = 0,  // You were assigned to the Issue.
    VHNotificationReasonTypeAuthor      = 1,  // You created the thread.
    VHNotificationReasonTypeComment     = 2,  // You commented on the thread.
    VHNotificationReasonTypeInvitation  = 3,  // You accepted an invitation to contribute to the repository.
    VHNotificationReasonTypeManual      = 4,  // You subscribed to the thread (via an Issue or Pull Request).
    VHNotificationReasonTypeMention     = 5,  // You were specifically @mentioned in the content.
    VHNotificationReasonTypeStateChange = 6,  // You changed the thread state (for example, closing an Issue or merging a Pull Request).
    VHNotificationReasonTypeSubscribed  = 7,  // You're watching the repository.
    VHNotificationReasonTypeTeamMention = 8,  // You were on a team that was mentioned.
};

typedef NS_ENUM(NSUInteger, VHNotificationType)
{
    VHNotificationTypeUnknown     = 0,
    VHNotificationTypeIssue       = 1,
    VHNotificationTypePullRequest = 2,
};

@interface VHNotification : NSObject

@property (nonatomic, assign) long long notificationId;
@property (nonatomic, strong) NSDate *lastReadDate;
@property (nonatomic, assign) VHNotificationReasonType reason;
@property (nonatomic, strong) VHSimpleRepository *repository;
@property (nonatomic, strong) NSString *lastCommentUrl;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, assign) BOOL unread;
@property (nonatomic, strong) NSDate *updateDate;
@property (nonatomic, strong) NSString *htmlUrl;
@property (nonatomic, assign) VHNotificationType type;

+ (NSDictionary<VHSimpleRepository *, NSArray<VHNotification *> *> *)dictionaryFromResponse:(id)responseObject;

+ (NSArray<VHNotification *> *)notificationsFromResponse:(id)responseObject;

- (instancetype)initFromResponseDiction:(NSDictionary *)dic;

- (BOOL)isValid;

- (NSString *)toNowTimeString;

@end
