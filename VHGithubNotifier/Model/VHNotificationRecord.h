//
//  VHNotificationRecord.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/3/1.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import <Realm/Realm.h>

@interface VHNotificationRecord : RLMObject

@property long long notificationId;
@property NSDate *latestUpdateTime;

@end
