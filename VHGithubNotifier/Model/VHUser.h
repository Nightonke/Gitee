//
//  VHUser.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2016/12/25.
//  Copyright © 2016年 黄伟平. All rights reserved.
//

#import <Realm/Realm.h>
#import "VHRepository.h"

@interface VHUser : RLMObject

@property long long userId;
@property long long followerNumber;
@property long long publicRepositoryNumber;
@property long long privateRepositoryNumber;
@property long long repositoryNumber;
@property NSString *avatar;
@property NSString *bio;
@property NSString *blog;
@property NSString *followersUrl;
@property NSString *followingUrl;
@property NSString *account;
@property NSString *name;

@property RLMArray<VHRepository *><VHRepository> *allRepositories;
@property RLMArray<VHRepository *><VHRepository> *publicRepositories;
@property RLMArray<VHRepository *><VHRepository> *privateRepositories;
@property RLMArray<VHRepository *><VHRepository> *ownerRepositories;
@property RLMArray<VHRepository *><VHRepository> *memberRepositories;

@property RLMArray<VHRecord *><VHRecord> *starRecords;
@property RLMArray<VHRecord *><VHRecord> *followerRecords;

- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary;

- (void)updateWithDataDictionary:(NSDictionary *)dictionary;

- (BOOL)isOwnerOfRepository:(VHRepository *)repository;

- (void)addRepositories:(NSArray<VHRepository *> *)repositories;

- (VHRepository *)repositoryFromName:(NSString *)name;

/**
 Get total star numbers of a user. This method must be called after kNotifyRepositoriesLoadedSuccessfully.

 @return Total star numbers of a user
 */
- (NSUInteger)starNumber;

/**
 Reset the flag of star-counter.
 */
- (void)resetStarCount;

@end
