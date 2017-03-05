//
//  VHGithubNotifierEnums.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2016/12/28.
//  Copyright © 2016年 黄伟平. All rights reserved.
//

#ifndef VHGithubNotifierEnums_h
#define VHGithubNotifierEnums_h

/**
 Contents in the tab view of the main window.

 - VHGithubContentTypeProfile:       Profile
 - VHGithubContentTypeRepositoryPie: Pie of repositories
 - VHGithubContentTypeTrend:         Trend of followers of user and stargazers of repositories
 - VHGithubContentTypeTrending:      Trending
 - VHGithubContentTypeNotifications: Notifications
 */
typedef NS_ENUM(NSUInteger, VHGithubContentType)
{
    VHGithubContentTypeProfile          = 1 << 0,
    VHGithubContentTypeRepositoryPie    = 1 << 1,
    VHGithubContentTypeTrend            = 1 << 2,
    VHGithubContentTypeTrending         = 1 << 3,
    VHGithubContentTypeNotifications    = 1 << 4,
};

/**
 Time type of trend.

 - VHGithubTrendTimeTypeAnytime: Any time as long as there is a change
 - VHGithubTrendTimeTypeDay:     Day
 - VHGithubTrendTimeTypeWeek:    Week
 - VHGithubTrendTimeTypeMonth:   Month
 - VHGithubTrendTimeTypeYear:    Year
 */
typedef NS_ENUM(NSUInteger, VHGithubTrendTimeType)
{
    VHGithubTrendTimeTypeAnytime = 1,
    VHGithubTrendTimeTypeDay     = 2,
    VHGithubTrendTimeTypeWeek    = 3,
    VHGithubTrendTimeTypeMonth   = 4,
    VHGithubTrendTimeTypeYear    = 5,
};

/**
 Which day does a week start from, monday or sunday?

 - VHGithubWeekStartFromSunDay: Sun.
 - VHGithubWeekStartFromMonDay: Mon.
 */
typedef NS_ENUM(NSUInteger, VHGithubWeekStartFrom)
{
    VHGithubWeekStartFromSunDay = 1,
    VHGithubWeekStartFromMonDay = 2,
};

/**
 Load state of some content.

 - VHLoadStateTypeDidNotLoad:       Haven't been loaded
 - VHLoadStateTypeLoading:          Loading
 - VHLoadStateTypeLoadSuccessfully: Loaded successfully
 - VHLoadStateTypeLoadFailed:       Loaded failed
 */
typedef NS_ENUM(NSUInteger, VHLoadStateType)
{
    VHLoadStateTypeDidNotLoad       = 0,
    VHLoadStateTypeLoading          = 1,
    VHLoadStateTypeLoadSuccessfully = 2,
    VHLoadStateTypeLoadFailed       = 3,
};

/**
 Types of user notification.

 - VHGithubUserNotificationTypeUnknown:      Unknown
 - VHGithubUserNotificationTypeNotification: Notifications in github
 - VHGithubUserNotificationTypeTrendToday:   Tell you how many stargazers or followers you got today
 */
typedef NS_ENUM(NSUInteger, VHGithubUserNotificationType)
{
    VHGithubUserNotificationTypeUnknown      = 0,
    VHGithubUserNotificationTypeNotification = 1,
    VHGithubUserNotificationTypeTrendToday   = 2,
};

/**
 Contents in status bar button.

 - VHStatusBarButtonContentTypeGithubIcon:    Github icon is the default content, when there is nothing in status bar button
 - VHStatusBarButtonContentTypeStargazers:    Total number of stargazers of the user
 - VHStatusBarButtonContentTypeFollowers:     Number of followers of the user
 - VHStatusBarButtonContentTypeNotifications: Number of unread notifications of the user
 */
typedef NS_ENUM(NSUInteger, VHStatusBarButtonContentType)
{
    VHStatusBarButtonContentTypeGithubIcon    = 0,
    VHStatusBarButtonContentTypeStargazers    = 1 << 0,
    VHStatusBarButtonContentTypeFollowers     = 1 << 1,
    VHStatusBarButtonContentTypeNotifications = 1 << 2,
};

#endif /* VHGithubNotifierEnums_h */
