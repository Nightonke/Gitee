//
//  VHTrendingRepository.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/21.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHTrendingRepository.h"
#import "VHUtils.h"

@interface VHTrendingRepository()

@property (nonatomic, assign, readwrite) NSInteger starNumber;
@property (nonatomic, assign, readwrite) NSInteger forkNumber;
@property (nonatomic, assign, readwrite) NSInteger trendingTipStarNumber;

@end

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
        _starNumberString = @"0";
        _forkNumberString = @"0";
        _contributorAvatars = [NSArray array];
        _trendingTip = nil;
    }
    return self;
}

- (BOOL)isValid;
{
    return self.url && self.name && self.ownerAccount;
}

- (void)setStarNumberString:(NSString *)starNumberString
{
    _starNumberString = starNumberString;
    self.starNumber = MAX(0, [VHUtils unsignIntFromString:starNumberString]);
}

- (void)setForkNumberString:(NSString *)forkNumberString
{
    _forkNumberString = forkNumberString;
    self.forkNumber = MAX(0, [VHUtils unsignIntFromString:forkNumberString]);
}

- (void)setTrendingTip:(NSString *)trendingTip
{
    _trendingTip = trendingTip;
    self.trendingTipStarNumber = [VHUtils unsignIntFromString:trendingTip];
}

@end
