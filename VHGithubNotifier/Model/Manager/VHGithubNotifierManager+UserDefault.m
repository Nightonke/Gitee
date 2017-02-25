//
//  VHGithubNotifierManager+UserDefault.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2016/12/28.
//  Copyright © 2016年 黄伟平. All rights reserved.
//

#import "VHGithubNotifierManager+UserDefault.h"
#import "VHGithubNotifierManager_Private.h"
#import "VHUtils+TransForm.h"

static NSString *userAccount;
static NSString *userPassword;

static VHGithubTrendTimeType trendTimeType;
static NSUInteger trendContentSelectedIndex;
static VHGithubWeekStartFrom weekStartFrom;
static NSUInteger trendingContentSelectedIndex;
static NSUInteger trendingTimeSelectedIndex;

@implementation VHGithubNotifierManager (UserDefault)

#pragma mark - Public Methods

- (void)innerInitializeProperties
{
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userAccount"];
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userPassword"];
    userAccount = [[NSUserDefaults standardUserDefaults] objectForKey:@"userAccount"];
    userPassword = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPassword"];
    
    trendTimeType = [[NSUserDefaults standardUserDefaults] integerForKey:@"VHGithubTrendTimeType"];
    if (trendTimeType == 0)
    {
        trendTimeType = VHGithubTrendTimeTypeDay;
    }
    
    trendContentSelectedIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"trendContentSelectedIndex"];
    
    weekStartFrom = [[NSUserDefaults standardUserDefaults] integerForKey:@"VHGithubWeekStartFrom"];
    if (weekStartFrom == 0)
    {
        weekStartFrom = VHGithubWeekStartFromMonDay;
    }
    
    trendingContentSelectedIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"trendingContentSelectedIndex"];
    trendingTimeSelectedIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"trendingTimeSelectedIndex"];
}

- (BOOL)isUserAccountNotExist
{
    return (userAccount && userPassword) == NO;
}

- (NSString *)userAccount
{
    return userAccount;
}

- (void)setUserAccount:(NSString *)_userAccount
{
    userAccount = _userAccount;
    [[NSUserDefaults standardUserDefaults] setObject:userAccount forKey:@"userAccount"];
}

- (NSString *)userPassword
{
    return userPassword;
}

- (void)setUserPassword:(NSString *)_userPassword
{
    userPassword = _userPassword;
    [[NSUserDefaults standardUserDefaults] setObject:userPassword forKey:@"userPassword"];
}

- (NSArray<NSImage *> *)imagesForGithubContentTypes;
{
    NSUInteger types = [self githubContentTypeInteger];
    NSMutableArray<NSImage *> *images = [NSMutableArray array];
    if (types & VHGithubContentTypeProfile)
    {
        [images addObject:[VHUtils imageFromGithubContentType:VHGithubContentTypeProfile]];
    }
    if (types & VHGithubContentTypeRepositoryPie)
    {
        [images addObject:[VHUtils imageFromGithubContentType:VHGithubContentTypeRepositoryPie]];
    }
    if (types & VHGithubContentTypeTrend)
    {
        [images addObject:[VHUtils imageFromGithubContentType:VHGithubContentTypeTrend]];
    }
    if (types & VHGithubContentTypeTrending)
    {
        [images addObject:[VHUtils imageFromGithubContentType:VHGithubContentTypeTrending]];
    }
    if (types & VHGithubContentTypeNotifications)
    {
        [images addObject:[VHUtils imageFromGithubContentType:VHGithubContentTypeNotifications]];
    }
    if (types & VHGithubContentTypeSettings)
    {
        [images addObject:[VHUtils imageFromGithubContentType:VHGithubContentTypeSettings]];
    }
    return images;
}

- (NSArray<NSNumber *> *)githubContentTypes
{
    NSMutableArray<NSNumber *> *numbers = [NSMutableArray array];
    NSUInteger types = [self githubContentTypeInteger];
    if (types & VHGithubContentTypeProfile)
    {
        [numbers addObject:@(VHGithubContentTypeProfile)];
    }
    if (types & VHGithubContentTypeRepositoryPie)
    {
        [numbers addObject:@(VHGithubContentTypeRepositoryPie)];
    }
    if (types & VHGithubContentTypeTrend)
    {
        [numbers addObject:@(VHGithubContentTypeTrend)];
    }
    if (types & VHGithubContentTypeTrending)
    {
        [numbers addObject:@(VHGithubContentTypeTrending)];
    }
    if (types & VHGithubContentTypeNotifications)
    {
        [numbers addObject:@(VHGithubContentTypeNotifications)];
    }
    if (types & VHGithubContentTypeSettings)
    {
        [numbers addObject:@(VHGithubContentTypeSettings)];
    }
    return numbers;
}

- (VHGithubTrendTimeType)trendTimeType
{
    return trendTimeType;
}

- (void)setTrendTimeType:(VHGithubTrendTimeType)_trendTimeType
{
    trendTimeType = _trendTimeType;
    [[NSUserDefaults standardUserDefaults] setInteger:trendTimeType forKey:@"VHGithubTrendTimeType"];
}

- (NSUInteger)trendContentSelectedIndex
{
    return trendContentSelectedIndex;
}

- (void)setTrendContentSelectedIndex:(NSUInteger)_trendContentSelectedIndex
{
    trendContentSelectedIndex = _trendContentSelectedIndex;
    [[NSUserDefaults standardUserDefaults] setInteger:trendContentSelectedIndex forKey:@"trendContentSelectedIndex"];
}

- (VHGithubWeekStartFrom)weekStartFrom
{
    return weekStartFrom;
}

- (void)setWeekStartFrom:(VHGithubWeekStartFrom)_weekStartFrom
{
    weekStartFrom = _weekStartFrom;
    [[NSUserDefaults standardUserDefaults] setInteger:weekStartFrom forKey:@"VHGithubWeekStartFrom"];
}

- (NSUInteger)trendingContentSelectedIndex
{
    return trendingContentSelectedIndex;
}

- (void)setTrendingContentSelectedIndex:(NSUInteger)_trendingContentSelectedIndex
{
    trendingContentSelectedIndex = _trendingContentSelectedIndex;
    [[NSUserDefaults standardUserDefaults] setInteger:trendingContentSelectedIndex forKey:@"trendingContentSelectedIndex"];
}

- (NSUInteger)trendingTimeSelectedIndex
{
    return trendingTimeSelectedIndex;
}

- (void)setTrendingTimeSelectedIndex:(NSUInteger)_trendingTimeSelectedIndex
{
    trendingTimeSelectedIndex = _trendingTimeSelectedIndex;
    [[NSUserDefaults standardUserDefaults] setInteger:trendingTimeSelectedIndex forKey:@"trendingTimeSelectedIndex"];
}

#pragma mark - Private Methods

- (NSUInteger)githubContentTypeInteger
{
    return
    VHGithubContentTypeProfile |
    VHGithubContentTypeRepositoryPie |
    VHGithubContentTypeTrend |
    VHGithubContentTypeTrending |
    VHGithubContentTypeNotifications |
    VHGithubContentTypeSettings;
}

@end
