//
//  VHSimpleRepository.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/26.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHSimpleRepository.h"
#import "VHUtils+Json.h"

@implementation VHSimpleRepository

#pragma mark - Public Methods

- (instancetype)initFromResponseDictionary:(NSDictionary *)dic
{
    self = [super init];
    if (self)
    {
        _repositoryId = [VHUtils getIntegerFromDictionary:dic forKey:@"id" withDefault:-1];
        _fullName = [VHUtils getStringFromDictionaryWithDefaultNil:dic forKey:@"full_name"];
        _htmlUrl = [VHUtils getStringFromDictionaryWithDefaultNil:dic forKey:@"html_url"];
    }
    return self;
}

- (BOOL)isValid
{
    return self.repositoryId != -1 && self.fullName && self.htmlUrl;
}

- (BOOL)isEqualToRepository:(VHSimpleRepository *)repository
{
    return self.repositoryId == repository.repositoryId;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    VHSimpleRepository *repository = [[[self class] allocWithZone:zone] init];
    repository.repositoryId = self.repositoryId;
    repository.fullName = [self.fullName copy];
    repository.htmlUrl = [self.htmlUrl copy];
    return repository;
}

#pragma mark - Private Methods

- (BOOL)isEqual:(id)object
{
    VHSimpleRepository *repository = SAFE_CAST(object, [VHSimpleRepository class]);
    if (repository)
    {
        return repository.repositoryId == self.repositoryId;
    }
    else
    {
        return NO;
    }
}

- (NSUInteger)hash
{
    return self.repositoryId;
}

@end
