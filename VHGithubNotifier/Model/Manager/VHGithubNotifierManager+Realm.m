//
//  VHGithubNotifierManager+Realm.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/1/5.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHGithubNotifierManager+Realm.h"

@implementation VHGithubNotifierManager (Realm)

- (RLMRealm *)realm
{
    return [RLMRealm defaultRealm];
}

- (void)persistUser
{
    [self persistUser:self.user];
}

- (void)persistUser:(VHUser *)user
{
    @autoreleasepool
    {
        RLMRealm *realm = [self realm];
        [realm transactionWithBlock:^{
            [realm addOrUpdateObject:user];
        }];
    }
}

- (void)loadUser
{
    VHUser *user = SAFE_CAST([[VHUser allObjects] firstObject], [VHUser class]);
    if (user != nil)
    {
        self.user = user;
        [self.user resetStarCount];
    }
}

@end
