//
//  VHGithubNotifierManager+Realm.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/1/5.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHGithubNotifierManager.h"
#import <Realm/Realm.h>

@interface VHGithubNotifierManager (Realm)

/**
 Get the realm.

 @return realm
 */
- (RLMRealm *)realm;

/**
 Persist user data to realm.
 */
- (void)persistUser;

/**
 Persist user data to realm.

 @param user the user needed to persist
 */
- (void)persistUser:(VHUser *)user;

/**
 Load user data from realm.
 */
- (void)loadUser;

/**
 Realm directory.

 @return url of realm directory
 */
- (NSURL *)realmDirectory;

@end
