//
//  VHTrendingRepository.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/21.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHTrendingRepository.h"

@implementation VHTrendingRepository

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _url = nil;
        _name = nil;
        _ownerAccount = nil;
        _repositoryDescription = @"";
        _languageName = nil;
        _languageColor = nil;
        _starNumber = @"0";
        _forkNumber = @"0";
        _contributorAvatars = [NSArray array];
        _trendingTip = nil;
    }
    return self;
}

- (BOOL)isValid;
{
    return self.url && self.name && self.ownerAccount;
}

@end
