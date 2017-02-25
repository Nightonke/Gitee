//
//  VHRepository.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2016/12/25.
//  Copyright © 2016年 黄伟平. All rights reserved.
//

#import <Realm/Realm.h>
#import "VHRecord.h"
#import "VHGithubNotifier-Bridging-Header.h"

@interface VHRepository : RLMObject

@property long long repositoryId;
@property NSString *name;
@property NSString *repositoryDescription;
@property NSString *language;
@property NSString *url;
@property long long starNumber;
@property long long forkNumber;
@property BOOL isPrivate;
@property long long ownerId;
@property NSString *ownerAccount;
@property NSString *ownerAvatar;

@property RLMArray<VHRecord *><VHRecord> *starRecords;
@property RLMArray<VHRecord *><VHRecord> *forkRecords;

- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary;

/**
 Init records for a new repository.
 */
- (void)addRecords;

/**
 Update records from an old repository in realm.

 @param oldRepository old repository in realm
 */
- (void)updateRecordsFrom:(VHRepository *)oldRepository;

@end

RLM_ARRAY_TYPE(VHRepository)
