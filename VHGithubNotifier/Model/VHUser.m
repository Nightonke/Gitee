//
//  VHUser.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2016/12/25.
//  Copyright © 2016年 黄伟平. All rights reserved.
//

#import "VHUser.h"
#import "VHUtils+Json.h"
#import "VHGithubNotifierManager.h"
#import "VHGithubNotifierManager+Realm.h"

@interface VHUser()

@property (nonatomic, assign) BOOL justAddRepositories;
@property (nonatomic, assign) NSUInteger starNumber;

@end

@implementation VHUser

#pragma mark - Public Methods

- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        _userId = [VHUtils getUnsignedIntegerFromDictionary:dictionary forKey:@"id"];
        _followerNumber = [VHUtils getUnsignedIntegerFromDictionary:dictionary forKey:@"followers"];
        [self updateFollowerNumber];
        
        _publicRepositoryNumber = [VHUtils getUnsignedIntegerFromDictionary:dictionary forKey:@"public_repos"];
        _privateRepositoryNumber = [VHUtils getUnsignedIntegerFromDictionary:dictionary forKey:@"owned_private_repos"];
        _repositoryNumber = _publicRepositoryNumber + _privateRepositoryNumber;
        _avatar = [VHUtils getStringFromDictionaryWithDefaultNil:dictionary forKey:@"avatar_url"];
        _bio = [VHUtils getStringFromDictionaryWithDefaultNil:dictionary forKey:@"bio"];
        _blog = [VHUtils getStringFromDictionaryWithDefaultNil:dictionary forKey:@"blog"];
        _followersUrl = [VHUtils getStringFromDictionaryWithDefaultNil:dictionary forKey:@"followers_url"];
        _followingUrl = [VHUtils getStringFromDictionaryWithDefaultNil:dictionary forKey:@"following_url"];
        _account = [VHUtils getStringFromDictionaryWithDefaultNil:dictionary forKey:@"login"];
        _name = [VHUtils getStringFromDictionaryWithDefaultNil:dictionary forKey:@"name"];
        
        _justAddRepositories = NO;
        
        [[VHGithubNotifierManager sharedManager] persistUser:self];
        BasicInfoLog(@"Total follower number: %lu", (unsigned long)[self followerNumber]);
        BasicInfoLog(@"Total repository number: %lu", (unsigned long)[self repositoryNumber]);
        NOTIFICATION_POST_IN_MAIN_THREAD(kNotifyProfileLoadedSuccessfully);
    }
    return self;
}

- (void)updateWithDataDictionary:(NSDictionary *)dictionary
{
    RLMRealm *realm = [[VHGithubNotifierManager sharedManager] realm];
    [realm beginWriteTransaction];
    
    _followerNumber = [VHUtils getUnsignedIntegerFromDictionary:dictionary forKey:@"followers"];
    self.followerNumber = _followerNumber;
    [self updateFollowerNumber];
    
    self.publicRepositoryNumber = [VHUtils getUnsignedIntegerFromDictionary:dictionary forKey:@"public_repos"];
    self.privateRepositoryNumber = [VHUtils getUnsignedIntegerFromDictionary:dictionary forKey:@"owned_private_repos"];
    self.repositoryNumber = self.publicRepositoryNumber + self.privateRepositoryNumber;
    self.avatar = [VHUtils getStringFromDictionaryWithDefaultNil:dictionary forKey:@"avatar_url"];
    self.bio = [VHUtils getStringFromDictionaryWithDefaultNil:dictionary forKey:@"bio"];
    self.blog = [VHUtils getStringFromDictionaryWithDefaultNil:dictionary forKey:@"blog"];
    self.followersUrl = [VHUtils getStringFromDictionaryWithDefaultNil:dictionary forKey:@"followers_url"];
    self.followingUrl = [VHUtils getStringFromDictionaryWithDefaultNil:dictionary forKey:@"following_url"];
    self.account = [VHUtils getStringFromDictionaryWithDefaultNil:dictionary forKey:@"login"];
    self.name = [VHUtils getStringFromDictionaryWithDefaultNil:dictionary forKey:@"name"];
    
    [realm addOrUpdateObject:self];
    [realm commitWriteTransaction];
    
    BasicInfoLog(@"Total follower number: %lu", (unsigned long)[self followerNumber]);
    BasicInfoLog(@"Total repository number: %lu", (unsigned long)[self repositoryNumber]);
    NOTIFICATION_POST_IN_MAIN_THREAD(kNotifyProfileLoadedSuccessfully);
}

- (BOOL)isOwnerOfRepository:(VHRepository *)repository
{
    return repository.ownerId == self.userId;
}

- (void)addRepositories:(NSArray<VHRepository *> *)repositories;
{
    if ([repositories count] == 0)
    {
        return;
    }
    @autoreleasepool
    {
        RLMRealm *realm = [[VHGithubNotifierManager sharedManager] realm];
        [realm beginWriteTransaction];
        
        for (VHRepository *repository in repositories)
        {
            VHRepository *oldRepository = [VHRepository objectForPrimaryKey:@(repository.repositoryId)];
            if (oldRepository)
            {
                [repository updateRecordsFrom:oldRepository];
                [realm addOrUpdateObject:repository];
            }
            else
            {
                [repository addRecords];
                [self addRepository:repository toRepositories:self.allRepositories];
                if (repository.isPrivate)
                {
                    [self addRepository:repository toRepositories:self.privateRepositories];
                }
                else
                {
                    [self addRepository:repository toRepositories:self.publicRepositories];
                }
                if ([self isOwnerOfRepository:repository])
                {
                    [self addRepository:repository toRepositories:self.ownerRepositories];
                }
                else
                {
                    [self addRepository:repository toRepositories:self.memberRepositories];
                }
            }
        }
        [self updateStarNumberSync];
        [realm addOrUpdateObject:self];
        [realm commitWriteTransaction];
    }
}

- (VHRepository *)repositoryFromName:(NSString *)name
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
    return [[self.allRepositories objectsWithPredicate:predicate] firstObject];
}

- (NSUInteger)starNumber
{
    if (self.justAddRepositories)
    {
        _justAddRepositories = NO;
        NSUInteger newStarNumber = 0;
        for (VHRepository *repository in self.ownerRepositories)
        {
            newStarNumber += [repository starNumber];
        }
        _starNumber = newStarNumber;
        [self updateStarNumber];
    }
    return _starNumber;
}

- (void)resetStarCount
{
    _justAddRepositories = YES;
}

- (NSString *)htmlUrl
{
    return [NSString stringWithFormat:@"https://github.com/%@", self.account];
}

#pragma mark - Private Methods

+ (NSString *)primaryKey
{
    return @"userId";
}

+ (NSArray<NSString *> *)ignoredProperties
{
    return @[@"justAddRepositories", @"starNumber"];
}

- (void)updateStarNumber
{
    VHRecord *starRecord = [[VHRecord alloc] initWithNumber:_starNumber];
    RLMThreadSafeReference *starRecordRef = [RLMThreadSafeReference referenceWithThreadConfined:self.starRecords];
    dispatch_async(GLOBAL_QUEUE, ^{
        @autoreleasepool
        {
            RLMRealm *realm = [[VHGithubNotifierManager sharedManager] realm];
            RLMArray<VHRecord *><VHRecord> *starRecords = [realm resolveThreadSafeReference:starRecordRef];
            [realm beginWriteTransaction];
            if ([starRecords count] == 0)
            {
                [starRecords addObject:starRecord];
            }
            else
            {
                if (starRecord.number != [starRecords lastObject].number)
                {
                    [starRecords addObject:starRecord];
                }
            }
            [realm commitWriteTransaction];
        }
    });
}

- (void)updateStarNumberSync
{
    NSUInteger newStarNumber = 0;
    for (VHRepository *repository in self.ownerRepositories)
    {
        newStarNumber += [repository starNumber];
    }
    _starNumber = newStarNumber;
    VHRecord *starRecord = [[VHRecord alloc] initWithNumber:_starNumber];
    if ([self.starRecords count] == 0)
    {
        [self.starRecords addObject:starRecord];
    }
    else
    {
        if (starRecord.number != [self.starRecords lastObject].number)
        {
            [self.starRecords addObject:starRecord];
        }
    }
}

- (void)updateFollowerNumber
{
    VHRecord *followerRecord = [[VHRecord alloc] initWithNumber:_followerNumber];
    if ([self.followerRecords count] == 0)
    {
        [self.followerRecords addObject:followerRecord];
    }
    else
    {
        if (followerRecord.number != [self.followerRecords lastObject].number)
        {
            [self.followerRecords addObject:followerRecord];
        }
    }
}

#pragma mark - Support Methods

- (void)addRepository:(VHRepository *)repository toRepositories:(RLMArray<VHRepository *><VHRepository> *)repositories
{
    VHRepository *oldRepository = [VHRepository objectForPrimaryKey:@(repository.repositoryId)];
    if (oldRepository != nil)
    {
        [[[VHGithubNotifierManager sharedManager] realm] addOrUpdateObject:repository];
    }
    __block int index = -1;
    for (int i = 0; i < repositories.count; i++)
    {
        if ([repositories objectAtIndex:i].repositoryId == repository.repositoryId)
        {
            index = i;
            [repositories replaceObjectAtIndex:i withObject:repository];
            break;
        }
    }
    if (index == -1)
    {
        [repositories addObject:repository];
    }
}

@end
