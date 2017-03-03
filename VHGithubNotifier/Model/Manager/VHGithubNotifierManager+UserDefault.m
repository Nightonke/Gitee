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

static const NSTimeInterval defaultBasicInfoUpdateTime = 60 * 10;
static const NSTimeInterval defaultLanguageUpdateTime = 12 * 60 * 60;
static const NSTimeInterval defaultTrendingUpdateTime = 60 * 10;
static const NSTimeInterval defaultNotificationUpdateTime = 60 * 10;
static NSTimeInterval basicInfoUpdateTime;
static NSTimeInterval languageUpdateTime;
static NSTimeInterval trendingUpdateTime;
static NSTimeInterval notificationUpdateTime;

@implementation VHGithubNotifierManager (UserDefault)

#pragma mark - Public Methods

- (void)innerInitializePropertiesForUserDefault
{
//    [[self userDefaults] removeObjectForKey:@"userAccount"];
//    [[self userDefaults] removeObjectForKey:@"userPassword"];
    userAccount = [[self userDefaults] objectForKey:@"userAccount"];
    userPassword = [[self userDefaults] objectForKey:@"userPassword"];
    
    trendTimeType = [[self userDefaults] integerForKey:@"VHGithubTrendTimeType"];
    if (trendTimeType == 0)
    {
        trendTimeType = VHGithubTrendTimeTypeDay;
    }
    
    trendContentSelectedIndex = [[self userDefaults] integerForKey:@"trendContentSelectedIndex"];
    
    weekStartFrom = [[self userDefaults] integerForKey:@"VHGithubWeekStartFrom"];
    if (weekStartFrom == 0)
    {
        weekStartFrom = VHGithubWeekStartFromMonDay;
    }
    
    trendingContentSelectedIndex = [[self userDefaults] integerForKey:@"trendingContentSelectedIndex"];
    trendingTimeSelectedIndex = [[self userDefaults] integerForKey:@"trendingTimeSelectedIndex"];
    
    basicInfoUpdateTime = [[self userDefaults] doubleForKey:@"basicInfoUpdateTime"];
    if (basicInfoUpdateTime == 0)
    {
        basicInfoUpdateTime = defaultBasicInfoUpdateTime;
    }
    
    languageUpdateTime = [[self userDefaults] doubleForKey:@"languageUpdateTime"];
    if (languageUpdateTime == 0)
    {
        languageUpdateTime = defaultLanguageUpdateTime;
    }
    
    trendingUpdateTime = [[self userDefaults] doubleForKey:@"trendingUpdateTime"];
    if (trendingUpdateTime == 0)
    {
        trendingUpdateTime = defaultTrendingUpdateTime;
    }
    
    notificationUpdateTime = [[self userDefaults] doubleForKey:@"notificationUpdateTime"];
    if (notificationUpdateTime == 0)
    {
        notificationUpdateTime = defaultNotificationUpdateTime;
    }
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
    return numbers;
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
    [[self userDefaults] setObject:userAccount forKey:@"userAccount"];
}

- (NSString *)userPassword
{
    return userPassword;
}

- (void)setUserPassword:(NSString *)_userPassword
{
    userPassword = _userPassword;
    [[self userDefaults] setObject:userPassword forKey:@"userPassword"];
}

- (VHGithubTrendTimeType)trendTimeType
{
    return trendTimeType;
}

- (void)setTrendTimeType:(VHGithubTrendTimeType)_trendTimeType
{
    trendTimeType = _trendTimeType;
    [[self userDefaults] setInteger:trendTimeType forKey:@"VHGithubTrendTimeType"];
}

- (NSUInteger)trendContentSelectedIndex
{
    return trendContentSelectedIndex;
}

- (void)setTrendContentSelectedIndex:(NSUInteger)_trendContentSelectedIndex
{
    trendContentSelectedIndex = _trendContentSelectedIndex;
    [[self userDefaults] setInteger:trendContentSelectedIndex forKey:@"trendContentSelectedIndex"];
}

- (VHGithubWeekStartFrom)weekStartFrom
{
    return weekStartFrom;
}

- (void)setWeekStartFrom:(VHGithubWeekStartFrom)_weekStartFrom
{
    weekStartFrom = _weekStartFrom;
    [[self userDefaults] setInteger:weekStartFrom forKey:@"VHGithubWeekStartFrom"];
}

- (NSUInteger)trendingContentSelectedIndex
{
    return trendingContentSelectedIndex;
}

- (void)setTrendingContentSelectedIndex:(NSUInteger)_trendingContentSelectedIndex
{
    trendingContentSelectedIndex = _trendingContentSelectedIndex;
    [[self userDefaults] setInteger:trendingContentSelectedIndex forKey:@"trendingContentSelectedIndex"];
}

- (NSUInteger)trendingTimeSelectedIndex
{
    return trendingTimeSelectedIndex;
}

- (void)setTrendingTimeSelectedIndex:(NSUInteger)_trendingTimeSelectedIndex
{
    trendingTimeSelectedIndex = _trendingTimeSelectedIndex;
    [[self userDefaults] setInteger:trendingTimeSelectedIndex forKey:@"trendingTimeSelectedIndex"];
}

- (NSTimeInterval)basicInfoUpdateTime
{
    return basicInfoUpdateTime;
}

- (void)setBasicInfoUpdateTime:(NSTimeInterval)_basicInfoUpdateTime
{
    basicInfoUpdateTime = _basicInfoUpdateTime;
    [[self userDefaults] setDouble:basicInfoUpdateTime forKey:@"basicInfoUpdateTime"];
}

- (NSTimeInterval)languageUpdateTime
{
    return languageUpdateTime;
}

- (void)setLanguageUpdateTime:(NSTimeInterval)_languageUpdateTime
{
    languageUpdateTime = _languageUpdateTime;
    [[self userDefaults] setDouble:languageUpdateTime forKey:@"languageUpdateTime"];
}

- (NSTimeInterval)trendingUpdateTime
{
    return trendingUpdateTime;
}

- (void)setTrendingUpdateTime:(NSTimeInterval)_trendingUpdateTime
{
    trendingUpdateTime = _trendingUpdateTime;
    [[self userDefaults] setDouble:trendingUpdateTime forKey:@"trendingUpdateTime"];
}

- (NSTimeInterval)notificationUpdateTime
{
    return notificationUpdateTime;
}

- (void)setNotificationUpdateTime:(NSTimeInterval)_notificationUpdateTime
{
    notificationUpdateTime = _notificationUpdateTime;
    [[self userDefaults] setDouble:notificationUpdateTime forKey:@"notificationUpdateTime"];
}

#pragma mark - Private Methods

- (NSUInteger)githubContentTypeInteger
{
    return
    VHGithubContentTypeProfile |
    VHGithubContentTypeRepositoryPie |
    VHGithubContentTypeTrend |
    VHGithubContentTypeTrending |
    VHGithubContentTypeNotifications;
}

- (NSUserDefaults *)userDefaults
{
    return [NSUserDefaults standardUserDefaults];
}

@end
