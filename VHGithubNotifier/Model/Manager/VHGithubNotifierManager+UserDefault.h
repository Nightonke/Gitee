//
//  VHGithubNotifierManager+UserDefault.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2016/12/28.
//  Copyright © 2016年 黄伟平. All rights reserved.
//

#import "VHGithubNotifierManager.h"

@interface VHGithubNotifierManager (UserDefault)

/**
 Intialize properties when manager is initialized.
 Don't call this methods outside manager.
 */
- (void)innerInitializePropertiesForUserDefault;

/**
 Get the icons of contents that need to show.
 
 @return VHGithubContentType icons.
 */
- (NSArray<NSImage *> *)imagesForGithubContentTypes;

/**
 Get the contents that need to show.
 
 @return VHGithubContenTypes.
 */
- (NSArray<NSNumber *> *)githubContentTypes;

#pragma mark - Github Account

/**
 Whether there are username and password for github user.

 @return YES / NO
 */
- (BOOL)isUserAccountNotExist;

/**
 Username of github.

 @return Username
 */
- (NSString *)userAccount;

/**
 Set username of github.

 @param _userAccount username
 */
- (void)setUserAccount:(NSString *)_userAccount;

/**
 Password of github.

 @return password
 */
- (NSString *)userPassword;

/**
 Set password of github.

 @param _userPassword password
 */
- (void)setUserPassword:(NSString *)_userPassword;

#pragma mark - Trend

/**
 Time type of trend.

 @return VHGithubTrendTimeType
 */
- (VHGithubTrendTimeType)trendTimeType;

/**
 Set time type of trend.

 @param _trendTimeType VHGithubTrendTimeType
 */
- (void)setTrendTimeType:(VHGithubTrendTimeType)_trendTimeType;

- (NSUInteger)trendContentSelectedIndex;

- (void)setTrendContentSelectedIndex:(NSUInteger)_trendContentSelectedIndex;

- (VHGithubWeekStartFrom)weekStartFrom;

- (void)setWeekStartFrom:(VHGithubWeekStartFrom)_weekStartFrom;

#pragma mark - Trending

- (NSUInteger)trendingContentSelectedIndex;

- (void)setTrendingContentSelectedIndex:(NSUInteger)_trendingContentSelectedIndex;

- (NSUInteger)trendingTimeSelectedIndex;

- (void)setTrendingTimeSelectedIndex:(NSUInteger)_trendingTimeSelectedIndex;

#pragma mark - Update Time

- (NSTimeInterval)basicInfoUpdateTime;

- (void)setBasicInfoUpdateTime:(NSTimeInterval)_basicInfoUpdateTime;

- (NSTimeInterval)languageUpdateTime;

- (void)setLanguageUpdateTime:(NSTimeInterval)_languageUpdateTime;

- (NSTimeInterval)trendingUpdateTime;

- (void)setTrendingUpdateTime:(NSTimeInterval)_trendingUpdateTime;

- (NSTimeInterval)notificationUpdateTime;

- (void)setNotificationUpdateTime:(NSTimeInterval)_notificationUpdateTime;

#pragma mark - Pie

- (NSUInteger)minimumStarNumberInPie;

- (void)setMinimumStarNumberInPie:(NSUInteger)_minimumStarNumberInPie;

#pragma mark - Status bar button

- (NSUInteger)statusBarButtonContents;

- (void)setStatusBarButtonContents:(NSUInteger)_statusBarButtonContents;

- (BOOL)onlyShowsValidContentsInStatusBar;

- (void)setOnlyShowsValidContentsInStatusBar:(BOOL)_onlyShowsValidContentsInStatusBar;

@end
