//
//  VHRepository.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2016/12/25.
//  Copyright © 2016年 黄伟平. All rights reserved.
//

#import "VHRepository.h"
#import "VHUtils+Json.h"
#import "VHGithubNotifierManager.h"
#import "VHGithubNotifierManager+Realm.h"
#import "VHUtils.h"

@implementation VHRepository

#pragma mark - Public Methods

- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        _repositoryId = [VHUtils getUnsignedIntegerFromDictionary:dictionary forKey:@"id"];
        _name = [VHUtils getStringFromDictionaryWithDefaultNil:dictionary forKey:@"name"];
        _repositoryDescription = [VHUtils getStringFromDictionaryWithDefaultNil:dictionary forKey:@"description"];
        _language = [VHUtils getStringFromDictionaryWithDefaultNil:dictionary forKey:@"language"];
        _url = [VHUtils getStringFromDictionaryWithDefaultNil:dictionary forKey:@"url"];
        _starNumber = [VHUtils getUnsignedIntegerFromDictionary:dictionary forKey:@"stargazers_count"];
        _forkNumber = [VHUtils getUnsignedIntegerFromDictionary:dictionary forKey:@"forks"];
        _isPrivate = [VHUtils getIntegerFromDictionary:dictionary forKey:@"private"];
        
        NSDictionary *ownerDictionary = [VHUtils getDicFromDictionaryWithDefaultNil:dictionary forKey:@"owner"];
        if (ownerDictionary != nil)
        {
            _ownerId = [VHUtils getUnsignedIntegerFromDictionary:ownerDictionary forKey:@"id"];
            _ownerAccount = [VHUtils getStringFromDictionaryWithDefaultNil:ownerDictionary forKey:@"login"];
            _ownerAvatar = [VHUtils getStringFromDictionaryWithDefaultNil:ownerDictionary forKey:@"avatar_url"];
        }
    }
    return self;
}

- (void)addRecords
{
    [self.starRecords addObject:[[VHRecord alloc] initWithNumber:self.starNumber]];
    [self.forkRecords addObject:[[VHRecord alloc] initWithNumber:self.forkNumber]];
}

- (void)updateRecordsFrom:(VHRepository *)oldRepository
{
    VHRecord *currentStarRecord = [[VHRecord alloc] initWithNumber:self.starNumber];
    VHRecord *recentStarRecord = [oldRepository.starRecords lastObject];
    self.starRecords = oldRepository.starRecords;
    NSAssert([oldRepository.starRecords count], @"Star records for old repository should not be zero");
    if (recentStarRecord.number != currentStarRecord.number)
    {
        [self.starRecords addObject:currentStarRecord];
    }
    
    VHRecord *currentForkRecord = [[VHRecord alloc] initWithNumber:self.forkNumber];
    VHRecord *recentForkRecord = [oldRepository.forkRecords lastObject];
    self.forkRecords = oldRepository.forkRecords;
    NSAssert([oldRepository.starRecords count], @"Fork records for old repository should not be zero");
    if (recentForkRecord.number != currentForkRecord.number)
    {
        [self.forkRecords addObject:currentForkRecord];
    }
}

#pragma mark - Private Methods

+ (NSString *)primaryKey
{
    return @"repositoryId";
}

@end
