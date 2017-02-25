//
//  VHGithubNotifierEnums.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2016/12/28.
//  Copyright © 2016年 黄伟平. All rights reserved.
//

#ifndef VHGithubNotifierEnums_h
#define VHGithubNotifierEnums_h

typedef NS_ENUM(NSUInteger, VHGithubContentType)
{
    VHGithubContentTypeProfile          = 1 << 0,
    VHGithubContentTypeRepositoryPie    = 1 << 1,
    VHGithubContentTypeTrend            = 1 << 2,
    VHGithubContentTypeTrending         = 1 << 3,
    VHGithubContentTypeNotifications    = 1 << 4,
    VHGithubContentTypeSettings         = 1 << 5,
};

typedef NS_ENUM(NSUInteger, VHGithubTrendTimeType)
{
    VHGithubTrendTimeTypeAnytime = 1,
    VHGithubTrendTimeTypeDay     = 2,
    VHGithubTrendTimeTypeWeek    = 3,
    VHGithubTrendTimeTypeMonth   = 4,
    VHGithubTrendTimeTypeYear    = 5,
};

typedef NS_ENUM(NSUInteger, VHGithubWeekStartFrom)
{
    VHGithubWeekStartFromSunDay = 1,
    VHGithubWeekStartFromMonDay = 2,
};

typedef NS_ENUM(NSUInteger, VHLoadStateType)
{
    VHLoadStateTypeDidNotLoad       = 0,
    VHLoadStateTypeLoading          = 1,
    VHLoadStateTypeLoadSuccessfully = 2,
    VHLoadStateTypeLoadFailed       = 3,
};

#endif /* VHGithubNotifierEnums_h */
