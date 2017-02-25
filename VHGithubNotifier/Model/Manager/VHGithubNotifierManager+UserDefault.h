//
//  VHGithubNotifierManager+UserDefault.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2016/12/28.
//  Copyright © 2016年 黄伟平. All rights reserved.
//

#import "VHGithubNotifierManager.h"

@interface VHGithubNotifierManager (UserDefault)

- (void)innerInitializeProperties;

- (BOOL)isUserAccountNotExist;

- (NSString *)userAccount;

- (void)setUserAccount:(NSString *)_userAccount;

- (NSString *)userPassword;

- (void)setUserPassword:(NSString *)_userPassword;

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

- (VHGithubTrendTimeType)trendTimeType;

- (void)setTrendTimeType:(VHGithubTrendTimeType)_trendTimeType;

- (NSUInteger)trendContentSelectedIndex;

- (void)setTrendContentSelectedIndex:(NSUInteger)_trendContentSelectedIndex;

- (VHGithubWeekStartFrom)weekStartFrom;

- (void)setWeekStartFrom:(VHGithubWeekStartFrom)_weekStartFrom;

- (NSUInteger)trendingContentSelectedIndex;

- (void)setTrendingContentSelectedIndex:(NSUInteger)_trendingContentSelectedIndex;

- (NSUInteger)trendingTimeSelectedIndex;

- (void)setTrendingTimeSelectedIndex:(NSUInteger)_trendingTimeSelectedIndex;

@end
